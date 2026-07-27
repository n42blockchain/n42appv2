import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:matrix/matrix.dart' show EncryptedFile, decryptFileImplementation;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

import '../../data/datasources/matrix/matrix_client_manager.dart';
import '../di/injection.dart';
import '../utils/debug_log.dart';

/// 语音服务
///
/// 提供语音录制和播放功能
/// 生命周期由 DI 容器管理，不使用 singleton 模式
class VoiceService {
  // 录音器/播放器都是平台通道对象，**不能在字段初始化时构造**。
  // 本服务由 configureChatDependencies 在 App 启动期建立，若此处直接 new
  // AudioPlayer()，audioplayers 的 `AudioPlayer._create` 会在启动阶段接触平台
  // 通道；一旦它抛错，异常经 FlutterError 冒泡，集成测试绑定会判定
  // "a test overrode FlutterError.onError ... had uncaught errors"，
  // 导致 integration_test 在任何用例体执行前就整体失败（T26 DEVICE-01）。
  // 改为首次真正录音/播放时才创建。
  AudioRecorder? _recorderInstance;
  AudioPlayer? _playerInstance;
  final _uuid = const Uuid();

  AudioRecorder get _recorder => _recorderInstance ??= AudioRecorder();

  /// 惰性创建播放器，并在创建时补挂状态订阅（原本在 [initialize] 里挂）。
  AudioPlayer get _player {
    final existing = _playerInstance;
    if (existing != null) return existing;
    final created = AudioPlayer();
    _playerInstance = created;
    _attachPlayerStateListener(created);
    return created;
  }

  // 录音状态
  bool _isRecording = false;
  String? _currentRecordingPath;
  DateTime? _recordingStartTime;
  Timer? _recordingTimer;
  
  // 播放状态
  bool _isPlaying = false;
  String? _currentPlayingUrl;
  String? _currentDownloadedPlaybackPath;
  
  // 状态流
  final _recordingStateController = StreamController<RecordingState>.broadcast();
  final _playbackStateController = StreamController<PlaybackState>.broadcast();
  final _amplitudeController = StreamController<double>.broadcast();

  /// 录音状态流
  Stream<RecordingState> get recordingStateStream => _recordingStateController.stream;
  
  /// 播放状态流
  Stream<PlaybackState> get playbackStateStream => _playbackStateController.stream;
  
  /// 音量振幅流（用于录音动画）
  Stream<double> get amplitudeStream => _amplitudeController.stream;

  /// 是否正在录音
  bool get isRecording => _isRecording;
  
  /// 是否正在播放
  bool get isPlaying => _isPlaying;
  
  /// 当前播放的URL
  String? get currentPlayingUrl => _currentPlayingUrl;

  // 播放器状态订阅（防止重复监听）
  StreamSubscription<PlayerState>? _playerStateSubscription;
  bool _isInitialized = false;

  /// 初始化
  ///
  /// 只置位标记，**不接触平台通道**。播放器的状态订阅移到播放器真正被创建时
  /// （见 [_player] getter），否则启动期就会实例化 audioplayers。
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // 已经播放过（播放器早于 initialize 被创建）时补挂订阅。
    final player = _playerInstance;
    if (player != null) _attachPlayerStateListener(player);
  }

  void _attachPlayerStateListener(AudioPlayer player) {
    unawaited(_playerStateSubscription?.cancel());
    _playerStateSubscription = player.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      if (state == PlayerState.completed || state == PlayerState.stopped) {
        _currentPlayingUrl = null;
        unawaited(_cleanupDownloadedPlaybackFile());
      }
      _playbackStateController.add(PlaybackState(
        isPlaying: _isPlaying,
        url: _currentPlayingUrl,
        state: state,
      ));
    });
  }

  /// 请求录音权限
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// 检查是否有录音权限
  Future<bool> hasPermission() async {
    return await Permission.microphone.isGranted;
  }

  /// 获取麦克风权限详细状态
  Future<PermissionStatus> checkPermissionStatus() async {
    return await Permission.microphone.status;
  }

  /// 开始录音
  Future<bool> startRecording() async {
    if (_isRecording) return false;

    // 检查权限 - 使用 permission_handler
    if (!await hasPermission()) {
      final granted = await requestPermission();
      if (!granted) {
        debugLog('VoiceService: Microphone permission not granted');
        return false;
      }
    }

    // 注意：不再使用 _recorder.hasPermission()，因为它与 permission_handler 可能不一致
    // permission_handler 已经确认权限已授予

    try {
      // 生成录音文件路径
      final dir = await getTemporaryDirectory();
      final filename = '${_uuid.v4()}.m4a';
      _currentRecordingPath = '${dir.path}/$filename';

      // 开始录音
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _currentRecordingPath!,
      );

      _isRecording = true;
      _recordingStartTime = DateTime.now();
      
      // 启动振幅监测
      _startAmplitudeMonitor();

      _recordingStateController.add(RecordingState(
        isRecording: true,
        duration: Duration.zero,
        path: _currentRecordingPath,
      ));

      return true;
    } catch (e) {
      debugLog('Start recording error: $e');
      return false;
    }
  }

  /// 停止录音
  Future<RecordingResult?> stopRecording() async {
    if (!_isRecording) return null;

    try {
      final path = await _recorder.stop();
      _stopAmplitudeMonitor();

      final duration = _recordingStartTime != null
          ? DateTime.now().difference(_recordingStartTime!)
          : Duration.zero;

      _isRecording = false;
      _recordingStartTime = null;

      _recordingStateController.add(RecordingState(
        isRecording: false,
        duration: duration,
        path: path,
      ));

      if (path != null && path.isNotEmpty) {
        // 检查文件是否存在
        final file = File(path);
        if (await file.exists()) {
          final fileSize = await file.length();
          return RecordingResult(
            path: path,
            duration: duration,
            fileSize: fileSize,
          );
        }
      }

      return null;
    } catch (e) {
      debugLog('Stop recording error: $e');
      _isRecording = false;
      return null;
    }
  }

  /// 取消录音
  Future<void> cancelRecording() async {
    if (!_isRecording) return;

    try {
      await _recorder.stop();
      _stopAmplitudeMonitor();

      // 删除录音文件
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      _isRecording = false;
      _recordingStartTime = null;
      _currentRecordingPath = null;

      _recordingStateController.add(RecordingState(
        isRecording: false,
        duration: Duration.zero,
        path: null,
        cancelled: true,
      ));
    } catch (e) {
      debugLog('Cancel recording error: $e');
      _isRecording = false;
    }
  }

  /// 播放语音
  /// 
  /// 支持本地文件和 HTTP URL（包括需要认证的 Matrix 媒体 URL）
  Future<void> play(
    String url, {
    String? encryptKey,
    String? encryptIv,
    String? encryptSha256,
  }) async {
    try {
      // 如果正在播放其他语音，先停止
      if (_isPlaying) {
        await stop();
      }

      await _cleanupDownloadedPlaybackFile();

      _currentPlayingUrl = url;

      if (url.startsWith('http')) {
        // 检查是否是 Matrix 媒体 URL（需要认证）
        if (url.contains('/_matrix/')) {
          final localPath = await _downloadWithAuth(
            url,
            encryptKey: encryptKey,
            encryptIv: encryptIv,
            encryptSha256: encryptSha256,
          );
          if (localPath != null) {
            _currentDownloadedPlaybackPath = localPath;
            await _player.play(DeviceFileSource(localPath));
          } else {
            debugLog('Failed to download audio file');
            _currentPlayingUrl = null;
          }
        } else {
          // 普通 HTTP URL，直接播放
          await _player.play(UrlSource(url));
        }
      } else {
        await _player.play(DeviceFileSource(url));
      }
    } catch (e) {
      debugLog('Play voice error: $e');
      _currentPlayingUrl = null;
    }
  }
  
  /// 下载需要认证的 Matrix 媒体文件，如有 E2EE key 则解密后保存
  Future<String?> _downloadWithAuth(
    String url, {
    String? encryptKey,
    String? encryptIv,
    String? encryptSha256,
  }) async {
    try {
      String? accessToken;
      try {
        final matrixManager = getIt<MatrixClientManager>();
        accessToken = matrixManager.client?.accessToken;
      } catch (e) {
        debugLog('Failed to get access token: $e');
      }

      final request = http.Request('GET', Uri.parse(url));
      if (accessToken != null) {
        request.headers['Authorization'] = 'Bearer $accessToken';
      }

      final client = http.Client();
      try {
        final response = await client.send(request);

        if (response.statusCode == 200) {
          Uint8List bytes = await response.stream.toBytes();

          // 如果有 E2EE key 材料，解密后再保存
          if (encryptKey != null && encryptIv != null && encryptSha256 != null) {
            debugLog('Decrypting encrypted audio file');
            final encryptedFile = EncryptedFile(
              data: bytes,
              k: encryptKey,
              iv: encryptIv,
              sha256: encryptSha256,
            );
            final decrypted = await decryptFileImplementation(encryptedFile);
            if (decrypted == null) {
              debugLog('Failed to decrypt audio file');
              return null;
            }
            bytes = decrypted;
          }

          final dir = await getTemporaryDirectory();
          final filename = '${_uuid.v4()}.m4a';
          final file = File('${dir.path}/$filename');
          await file.writeAsBytes(bytes);

          debugLog('Downloaded${encryptKey != null ? " and decrypted" : ""} audio to: ${file.path}');
          return file.path;
        } else {
          debugLog('Failed to download audio: ${response.statusCode}');
          return null;
        }
      } finally {
        client.close();
      }
    } catch (e) {
      debugLog('Download audio error: $e');
      return null;
    }
  }

  /// 暂停播放
  Future<void> pause() async {
    await _player.pause();
  }

  /// 继续播放
  Future<void> resume() async {
    await _player.resume();
  }

  /// 停止播放
  Future<void> stop() async {
    await _player.stop();
    _currentPlayingUrl = null;
    await _cleanupDownloadedPlaybackFile();
  }

  /// 设置播放位置
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  void _startAmplitudeMonitor() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (_) async {
      if (_isRecording) {
        try {
          final amplitude = await _recorder.getAmplitude();
          // 归一化振幅值 (dBFS 范围通常是 -160 到 0)
          final normalized = (amplitude.current + 60) / 60;
          _amplitudeController.add(normalized.clamp(0.0, 1.0));
          
          // 更新录音时长
          if (_recordingStartTime != null) {
            final duration = DateTime.now().difference(_recordingStartTime!);
            _recordingStateController.add(RecordingState(
              isRecording: true,
              duration: duration,
              path: _currentRecordingPath,
            ));
          }
        } catch (e) {
          // 忽略错误
          debugLog('Error: $e');
        }
      }
    });
  }

  void _stopAmplitudeMonitor() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  /// 释放资源
  Future<void> dispose() async {
    _isInitialized = false;
    _recordingTimer?.cancel();
    await _playerStateSubscription?.cancel();
    _playerStateSubscription = null;
    await _cleanupDownloadedPlaybackFile();
    // 只销毁真正创建过的平台对象——用 getter 会把从未用过的录音器/播放器
    // 在 dispose 时反而实例化出来。
    await _recorderInstance?.dispose();
    _recorderInstance = null;
    await _playerInstance?.dispose();
    _playerInstance = null;
    await _recordingStateController.close();
    await _playbackStateController.close();
    await _amplitudeController.close();
  }

  Future<void> _cleanupDownloadedPlaybackFile() async {
    final path = _currentDownloadedPlaybackPath;
    _currentDownloadedPlaybackPath = null;
    if (path == null || path.isEmpty) return;

    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugLog('VoiceService: Failed to delete temp playback file: $e');
    }
  }
}

/// 录音状态
class RecordingState {
  final bool isRecording;
  final Duration duration;
  final String? path;
  final bool cancelled;

  RecordingState({
    required this.isRecording,
    required this.duration,
    this.path,
    this.cancelled = false,
  });
}

/// 录音结果
class RecordingResult {
  final String path;
  final Duration duration;
  final int fileSize;

  RecordingResult({
    required this.path,
    required this.duration,
    required this.fileSize,
  });
}

/// 播放状态
class PlaybackState {
  final bool isPlaying;
  final String? url;
  final PlayerState state;

  PlaybackState({
    required this.isPlaying,
    this.url,
    required this.state,
  });
}
