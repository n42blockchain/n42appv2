import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
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
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  final _uuid = const Uuid();

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
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    await _playerStateSubscription?.cancel();
    _playerStateSubscription = _player.onPlayerStateChanged.listen((state) {
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
  Future<void> play(String url) async {
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
          // 下载到本地再播放
          final localPath = await _downloadWithAuth(url);
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
  
  /// 下载需要认证的 Matrix 媒体文件
  Future<String?> _downloadWithAuth(String url) async {
    try {
      // 获取 access token
      String? accessToken;
      try {
        final matrixManager = getIt<MatrixClientManager>();
        accessToken = matrixManager.client?.accessToken;
      } catch (e) {
        debugLog('Failed to get access token: $e');
      }
      
      // 创建请求
      final request = http.Request('GET', Uri.parse(url));
      if (accessToken != null) {
        request.headers['Authorization'] = 'Bearer $accessToken';
      }
      
      // 发送请求
      final client = http.Client();
      try {
        final response = await client.send(request);
        
        if (response.statusCode == 200) {
          // 保存到临时文件
          final bytes = await response.stream.toBytes();
          final dir = await getTemporaryDirectory();
          final filename = '${_uuid.v4()}.m4a';
          final file = File('${dir.path}/$filename');
          await file.writeAsBytes(bytes);
          
          debugLog('Downloaded audio to: ${file.path}');
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
    await _recorder.dispose();
    await _player.dispose();
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
