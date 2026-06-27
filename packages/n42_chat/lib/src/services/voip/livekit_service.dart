/// LiveKit 多人会议服务
///
/// 封装 livekit_client，提供多人音视频会议功能
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart';

import 'call_e2ee_provider.dart';
import 'virtual_background_processor.dart';
import 'voip_config.dart';
import '../../core/utils/debug_log.dart';

/// 会议状态
enum MeetingState {
  idle,
  connecting,
  connected,
  reconnecting,
  disconnected,
  failed,
}

/// 会议错误类型（用于国际化）
enum MeetingErrorType {
  /// LiveKit 服务器未配置
  serverNotConfigured,
  /// 加入会议失败
  joinFailed,
  /// 屏幕共享失败
  screenShareFailed,
  /// 连接断开
  connectionLost,
  /// 未知错误
  unknown,
}

/// 参与者信息
class MeetingParticipant {
  final String id;
  final String name;
  final String? avatarUrl;
  final bool isLocal;
  final bool isSpeaking;
  final bool isMuted;
  final bool isVideoEnabled;
  final bool isScreenSharing;
  final VideoTrack? videoTrack;
  final AudioTrack? audioTrack;
  final VideoTrack? screenTrack;

  MeetingParticipant({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.isLocal = false,
    this.isSpeaking = false,
    this.isMuted = false,
    this.isVideoEnabled = true,
    this.isScreenSharing = false,
    this.videoTrack,
    this.audioTrack,
    this.screenTrack,
  });

  MeetingParticipant copyWith({
    bool? isSpeaking,
    bool? isMuted,
    bool? isVideoEnabled,
    bool? isScreenSharing,
    VideoTrack? videoTrack,
    AudioTrack? audioTrack,
    VideoTrack? screenTrack,
  }) {
    return MeetingParticipant(
      id: id,
      name: name,
      avatarUrl: avatarUrl,
      isLocal: isLocal,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      isMuted: isMuted ?? this.isMuted,
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
      isScreenSharing: isScreenSharing ?? this.isScreenSharing,
      videoTrack: videoTrack ?? this.videoTrack,
      audioTrack: audioTrack ?? this.audioTrack,
      screenTrack: screenTrack ?? this.screenTrack,
    );
  }
}

/// 会议信息
class MeetingInfo {
  final String roomId;
  final String roomName;
  final DateTime startTime;
  final int maxParticipants;
  final bool isRecording;

  MeetingInfo({
    required this.roomId,
    required this.roomName,
    required this.startTime,
    this.maxParticipants = 50,
    this.isRecording = false,
  });
}

/// LiveKit 服务
class LiveKitService extends ChangeNotifier {
  final VoIPConfig _config;

  Room? _room;
  LocalParticipant? _localParticipant;
  EventsListener<RoomEvent>? _roomListener;

  /// 摄像头帧处理器（虚拟背景 / 背景模糊）
  late final VoipCameraProcessor _cameraProcessor = VoipCameraProcessor(_config);

  /// 通话端到端加密提供器（LiveKit 帧加密）
  final CallE2EEProvider _e2ee = CallE2EEProvider();
  bool _e2eeEnabled = false;

  MeetingState _state = MeetingState.idle;
  MeetingInfo? _currentMeeting;
  final Map<String, MeetingParticipant> _participants = {};

  // 本地控制状态
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isScreenSharing = false;

  // 事件回调
  void Function(MeetingState state)? onStateChanged;
  void Function(List<MeetingParticipant> participants)? onParticipantsChanged;
  void Function(MeetingParticipant participant)? onParticipantJoined;
  void Function(MeetingParticipant participant)? onParticipantLeft;
  void Function(MeetingParticipant participant)? onActiveSpeakerChanged;
  /// 错误回调，传递错误类型和可选的详细信息
  /// 调用方应根据 [MeetingErrorType] 显示国际化的错误消息
  void Function(MeetingErrorType type, [String? details])? onError;
  void Function(bool isRecording)? onRecordingStateChanged;

  // 通话时长
  Timer? _durationTimer;
  Duration _duration = Duration.zero;
  void Function(Duration duration)? onDurationUpdate;

  LiveKitService() : _config = VoIPConfig();

  // ============================================
  // Getters
  // ============================================

  MeetingState get state => _state;
  MeetingInfo? get currentMeeting => _currentMeeting;
  List<MeetingParticipant> get participants => _participants.values.toList();
  bool get isMuted => _isMuted;
  bool get isVideoEnabled => _isVideoEnabled;
  bool get isScreenSharing => _isScreenSharing;
  bool get isInMeeting => _state == MeetingState.connected;
  LocalParticipant? get localParticipant => _localParticipant;
  Duration get duration => _duration;
  Room? get room => _room;

  /// 当前通话是否启用了端到端加密
  bool get isE2EEEnabled => _e2eeEnabled;

  /// 摄像头帧处理器（虚拟背景 / 背景模糊），供本地自视图预览调用 renderFrame
  VoipCameraProcessor get cameraProcessor => _cameraProcessor;

  // ============================================
  // 端到端加密（帧加密）
  // ============================================

  /// 运行时切换帧加密开关（房间已用 e2eeOptions 初始化时有效）
  Future<void> setE2EEEnabled(bool enabled) async {
    if (_room == null) return;
    try {
      await _room!.setE2EEEnabled(enabled);
      _e2eeEnabled = enabled;
      notifyListeners();
      debugLog('LiveKitService: E2EE ${enabled ? "enabled" : "disabled"}');
    } catch (e) {
      debugLog('LiveKitService: setE2EEEnabled failed: $e');
    }
  }

  /// 棘轮推进共享密钥（前向保密；各端需同步调用）
  Future<void> ratchetE2EEKey() => _e2ee.ratchet();

  // ============================================
  // 加入/离开会议
  // ============================================

  /// 加入会议
  ///
  /// [roomName] 房间名称
  /// [token] LiveKit 访问令牌（从服务端获取）
  /// [participantName] 参与者名称
  /// [enableVideo] 是否开启视频
  /// [enableAudio] 是否开启音频
  /// [enableE2EE] 是否开启通话端到端加密（LiveKit 帧加密）。开启时必须提供
  /// [e2eeSharedKey]，且参会各端密钥需一致（详见 [CallE2EEProvider]）。
  Future<bool> joinMeeting({
    required String roomName,
    required String token,
    required String participantName,
    String? participantAvatarUrl,
    bool enableVideo = true,
    bool enableAudio = true,
    bool enableE2EE = false,
    String? e2eeSharedKey,
  }) async {
    if (_state != MeetingState.idle) {
      debugLog('LiveKitService: Already in a meeting');
      return false;
    }

    if (_config.liveKitUrl == null) {
      onError?.call(MeetingErrorType.serverNotConfigured);
      return false;
    }

    try {
      _setState(MeetingState.connecting);

      // 获取音频处理配置
      final audioConfig = _config.audioProcessing;

      // 构建通话端到端加密选项（如启用）
      E2EEOptions? e2eeOptions;
      if (enableE2EE && e2eeSharedKey != null && e2eeSharedKey.isNotEmpty) {
        e2eeOptions = await _e2ee.buildOptions(e2eeSharedKey);
        _e2eeEnabled = true;
        debugLog('LiveKitService: E2EE enabled for this meeting');
      } else {
        _e2eeEnabled = false;
      }

      // 创建房间实例
      _room = Room(
        roomOptions: RoomOptions(
          adaptiveStream: true,
          dynacast: true,
          encryption: e2eeOptions,
          defaultAudioPublishOptions: const AudioPublishOptions(),
          defaultVideoPublishOptions: const VideoPublishOptions(
            simulcast: true,
            videoCodec: 'VP8',
          ),
          defaultScreenShareCaptureOptions: const ScreenShareCaptureOptions(
            useiOSBroadcastExtension: true,
            maxFrameRate: 15.0,
          ),
          // 音频处理配置
          defaultAudioCaptureOptions: AudioCaptureOptions(
            echoCancellation: audioConfig.echoCancellation,
            noiseSuppression: audioConfig.noiseSuppression,
            autoGainControl: audioConfig.autoGainControl,
            highPassFilter: audioConfig.highPassFilter,
          ),
          // 摄像头采集挂载虚拟背景 / 背景模糊处理器
          defaultCameraCaptureOptions: CameraCaptureOptions(
            processor: _cameraProcessor,
          ),
        ),
      );
      debugLog('LiveKitService: Room created with audio processing: $audioConfig');

      // 设置事件监听
      _setupRoomListeners();

      // 连接到房间
      await _room!.connect(
        _config.liveKitUrl!,
        token,
        fastConnectOptions: FastConnectOptions(
          microphone: TrackOption(enabled: enableAudio),
          camera: TrackOption(enabled: enableVideo),
        ),
      );

      // 连接成功后启用帧加密
      if (_e2eeEnabled) {
        try {
          await _room!.setE2EEEnabled(true);
          debugLog('LiveKitService: Frame encryption activated');
        } catch (e) {
          debugLog('LiveKitService: Failed to activate E2EE: $e');
        }
      }

      _localParticipant = _room!.localParticipant;

      // 创建会议信息
      _currentMeeting = MeetingInfo(
        roomId: _room!.name ?? roomName,
        roomName: roomName,
        startTime: DateTime.now(),
      );

      // 添加本地参与者
      _participants[_localParticipant!.identity] = MeetingParticipant(
        id: _localParticipant!.identity,
        name: participantName,
        avatarUrl: participantAvatarUrl,
        isLocal: true,
        isMuted: !enableAudio,
        isVideoEnabled: enableVideo,
      );

      _isMuted = !enableAudio;
      _isVideoEnabled = enableVideo;

      // 添加已有参与者
      for (final participant in _room!.remoteParticipants.values) {
        _addRemoteParticipant(participant);
      }

      _setState(MeetingState.connected);
      _startDurationTimer();
      _notifyParticipantsChanged();

      debugLog('LiveKitService: Joined meeting $roomName');
      return true;
    } catch (e, stackTrace) {
      debugLog('LiveKitService: Join meeting failed: $e');
      debugLog('Stack: $stackTrace');
      _setState(MeetingState.failed);
      onError?.call(MeetingErrorType.joinFailed, e.toString());
      await _cleanup();
      return false;
    }
  }

  /// 离开会议
  Future<void> leaveMeeting() async {
    if (_room == null) return;

    try {
      await _room!.disconnect();
    } catch (e) {
      debugLog('LiveKitService: Leave meeting failed: $e');
    }

    await _cleanup();
    _setState(MeetingState.disconnected);
    debugLog('LiveKitService: Left meeting');
  }

  // ============================================
  // 媒体控制
  // ============================================

  /// 切换麦克风
  Future<void> toggleMicrophone() async {
    if (_localParticipant == null) return;

    _isMuted = !_isMuted;
    await _localParticipant!.setMicrophoneEnabled(!_isMuted);

    _updateLocalParticipant();
    debugLog('LiveKitService: Microphone ${_isMuted ? "muted" : "unmuted"}');
  }

  /// 切换摄像头
  Future<void> toggleCamera() async {
    if (_localParticipant == null) return;

    _isVideoEnabled = !_isVideoEnabled;
    await _localParticipant!.setCameraEnabled(_isVideoEnabled);

    _updateLocalParticipant();
    debugLog('LiveKitService: Camera ${_isVideoEnabled ? "enabled" : "disabled"}');
  }

  /// 切换前后摄像头
  Future<void> switchCamera() async {
    final publication = _localParticipant?.videoTrackPublications
        .where((pub) => pub.source == TrackSource.camera)
        .firstOrNull;

    final videoTrack = publication?.track;
    if (videoTrack is LocalVideoTrack) {
      // 切换摄像头
      final captureOptions = videoTrack.currentOptions;
      if (captureOptions is CameraCaptureOptions) {
        final newPosition = captureOptions.cameraPosition == CameraPosition.front
            ? CameraPosition.back
            : CameraPosition.front;
        await videoTrack.setCameraPosition(newPosition);
        debugLog('LiveKitService: Camera switched to $newPosition');
      }
    }
  }

  /// 开始屏幕共享
  Future<bool> startScreenShare() async {
    if (_localParticipant == null) return false;

    try {
      await _localParticipant!.setScreenShareEnabled(true);
      _isScreenSharing = true;
      _updateLocalParticipant();
      debugLog('LiveKitService: Screen share started');
      return true;
    } catch (e) {
      debugLog('LiveKitService: Start screen share failed: $e');
      onError?.call(MeetingErrorType.screenShareFailed, e.toString());
      return false;
    }
  }

  /// 停止屏幕共享
  Future<void> stopScreenShare() async {
    if (_localParticipant == null) return;

    try {
      await _localParticipant!.setScreenShareEnabled(false);
      _isScreenSharing = false;
      _updateLocalParticipant();
      debugLog('LiveKitService: Screen share stopped');
    } catch (e) {
      debugLog('LiveKitService: Stop screen share failed: $e');
    }
  }

  /// 切换屏幕共享
  Future<void> toggleScreenShare() async {
    if (_isScreenSharing) {
      await stopScreenShare();
    } else {
      await startScreenShare();
    }
  }

  // ============================================
  // 音频处理控制
  // ============================================

  /// 切换降噪功能
  Future<void> toggleNoiseSuppression() async {
    _config.enableNoiseSuppression = !_config.enableNoiseSuppression;
    await _updateAudioProcessing();
  }

  /// 切换回声消除
  Future<void> toggleEchoCancellation() async {
    _config.enableEchoCancellation = !_config.enableEchoCancellation;
    await _updateAudioProcessing();
  }

  /// 切换自动增益控制
  Future<void> toggleAutoGainControl() async {
    _config.enableAutoGainControl = !_config.enableAutoGainControl;
    await _updateAudioProcessing();
  }

  /// 切换增强模式
  Future<void> toggleEnhancedMode() async {
    _config.enableEnhancedAudioMode = !_config.enableEnhancedAudioMode;
    await _updateAudioProcessing();
  }

  /// 获取当前音频处理配置
  AudioProcessingConfig get audioProcessingConfig => _config.audioProcessing;

  /// 更新音频处理设置
  Future<void> _updateAudioProcessing() async {
    if (_localParticipant == null) return;

    final audioConfig = _config.audioProcessing;
    debugLog('LiveKitService: Updating audio processing: $audioConfig');

    // LiveKit 需要重新发布音轨来应用新的音频处理设置
    // 先禁用麦克风，再重新启用
    try {
      await _localParticipant!.setMicrophoneEnabled(false);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await _localParticipant!.setMicrophoneEnabled(!_isMuted);
      debugLog('LiveKitService: Audio processing updated successfully');
    } catch (e) {
      debugLog('LiveKitService: Failed to update audio processing: $e');
    }

    notifyListeners();
  }

  // ============================================
  // 背景处理控制
  // ============================================

  /// 获取当前背景处理配置
  BackgroundProcessingConfig get backgroundProcessingConfig => _config.backgroundProcessing;

  /// 是否启用了背景处理
  bool get isBackgroundProcessingEnabled => _config.backgroundMode != BackgroundMode.none;

  /// 启用背景模糊
  ///
  /// [radius] 模糊半径 (0.0 - 1.0)
  Future<void> enableBackgroundBlur({double radius = 0.5}) async {
    _config.backgroundMode = BackgroundMode.blur;
    _config.backgroundBlurRadius = radius.clamp(0.0, 1.0);
    await _updateBackgroundProcessing();
  }

  /// 设置虚拟背景
  ///
  /// [imageUrl] 背景图片的 URL 或本地路径
  Future<void> setVirtualBackground(String imageUrl) async {
    _config.backgroundMode = BackgroundMode.virtualBackground;
    _config.virtualBackgroundUrl = imageUrl;
    await _cameraProcessor.loadBackgroundImage(imageUrl);
    await _updateBackgroundProcessing();
  }

  /// 设置虚拟背景（直接提供图片字节，适用于网络图 / 内存图）
  Future<void> setVirtualBackgroundBytes(Uint8List imageBytes) async {
    _config.backgroundMode = BackgroundMode.virtualBackground;
    _cameraProcessor.backgroundImageBytes = imageBytes;
    await _updateBackgroundProcessing();
  }

  /// 禁用背景处理
  Future<void> disableBackgroundProcessing() async {
    _config.backgroundMode = BackgroundMode.none;
    await _updateBackgroundProcessing();
  }

  /// 切换背景模糊
  Future<void> toggleBackgroundBlur() async {
    if (_config.backgroundMode == BackgroundMode.blur) {
      await disableBackgroundProcessing();
    } else {
      await enableBackgroundBlur();
    }
  }

  /// 调整背景模糊强度
  Future<void> setBackgroundBlurRadius(double radius) async {
    if (_config.backgroundMode != BackgroundMode.blur) return;

    _config.backgroundBlurRadius = radius.clamp(0.0, 1.0);
    await _updateBackgroundProcessing();
  }

  /// 更新背景处理设置
  ///
  /// 配置存于 [VoIPConfig] 单例，已挂载的 [VoipCameraProcessor]（虚拟背景 /
  /// 背景模糊处理器）会实时读取最新配置：本地自视图通过
  /// `cameraProcessor.renderFrame` 渲染合成效果（真实可用），发布轨道的逐帧
  /// 替换待原生 frame processor 接线（见 [VoipCameraProcessor.processedTrack]）。
  Future<void> _updateBackgroundProcessing() async {
    final bgConfig = _config.backgroundProcessing;
    debugLog('LiveKitService: Updating background processing: $bgConfig');

    // 下发最新配置给原生 frame processor（发布轨道替换；未接则优雅 no-op）
    await _cameraProcessor.pushConfigToNative();

    // LiveKit 背景模糊通过 LocalVideoTrack 的处理器实现
    // 需要重新设置视频轨道来应用新设置
    if (_localParticipant == null || !_isVideoEnabled) {
      debugLog('LiveKitService: No active video to apply background processing');
      notifyListeners();
      return;
    }

    try {
      // 获取当前的视频轨道
      final publication = _localParticipant?.videoTrackPublications
          .where((pub) => pub.source == TrackSource.camera)
          .firstOrNull;

      final videoTrack = publication?.track;
      if (videoTrack is LocalVideoTrack) {
        // 根据背景模式应用不同的处理
        switch (_config.backgroundMode) {
          case BackgroundMode.blur:
            debugLog('LiveKitService: Background blur enabled with radius: ${_config.backgroundBlurRadius}');
            // 实际的模糊处理需要通过 VideoProcessor 实现
            // 这里记录配置，由 UI 层应用实际的视觉效果
            break;
          case BackgroundMode.virtualBackground:
            debugLog('LiveKitService: Virtual background set: ${_config.virtualBackgroundUrl}');
            // 虚拟背景需要使用人像分割和图像合成
            break;
          case BackgroundMode.solidColor:
            debugLog('LiveKitService: Solid color background applied');
            break;
          case BackgroundMode.none:
            debugLog('LiveKitService: Background processing disabled');
            break;
        }
      }

      notifyListeners();
    } catch (e) {
      debugLog('LiveKitService: Failed to update background processing: $e');
    }
  }

  // ============================================
  // 录制控制
  // ============================================

  /// 开始录制（服务端功能，当前不可用）
  ///
  /// 录制需要服务端通过 LiveKit Egress API 驱动，客户端仅负责发起请求。
  /// 完整流程：
  ///   1. 客户端调用自有后端接口（需鉴权）发起录制任务
  ///   2. 后端使用 LiveKit Server SDK 调用 EgressClient.startRoomCompositeEgress()
  ///   3. 后端返回 egressId，客户端持有用于后续停止/查询
  ///
  /// 此功能尚未实现，调用方应检查返回值并向用户展示"录制功能即将上线"提示。
  Future<bool> startRecording() async {
    debugLog('LiveKitService: startRecording called — '
        'server-side Egress API integration not yet implemented; returning false');
    return false;
  }

  /// 停止录制（服务端功能，当前不可用）
  ///
  /// 需配合 startRecording() 返回的 egressId 调用后端停止接口。
  Future<void> stopRecording() async {
    debugLog('LiveKitService: stopRecording called — '
        'server-side Egress API integration not yet implemented; no-op');
  }

  // ============================================
  // 通话中聊天 (DataChannel)
  // ============================================

  /// 通话中聊天消息列表
  final List<InCallChatMessage> _chatMessages = [];

  /// 聊天消息通知
  final _chatMessageController = StreamController<InCallChatMessage>.broadcast();

  /// 聊天消息流
  Stream<InCallChatMessage> get onChatMessage => _chatMessageController.stream;

  /// 获取所有聊天消息
  List<InCallChatMessage> get chatMessages => List.unmodifiable(_chatMessages);

  /// 发送通话中文本消息
  ///
  /// 使用 LiveKit DataChannel 在参与者间传递文本
  Future<bool> sendChatMessage(String text) async {
    if (_localParticipant == null || text.trim().isEmpty) return false;

    try {
      final message = InCallChatMessage(
        senderId: _localParticipant!.identity,
        senderName: _localParticipant!.name,
        content: text.trim(),
        timestamp: DateTime.now(),
        isLocal: true,
      );

      // 通过 DataChannel 发送
      final data = utf8.encode(jsonEncode({
        'type': 'chat',
        'sender': _localParticipant!.identity,
        'name': _localParticipant!.name,
        'content': text.trim(),
        'ts': DateTime.now().millisecondsSinceEpoch,
      }));

      await _localParticipant!.publishData(data, reliable: true);

      _chatMessages.add(message);
      if (!_chatMessageController.isClosed) {
        _chatMessageController.add(message);
      }
      notifyListeners();

      debugLog('LiveKitService: Chat message sent');
      return true;
    } catch (e) {
      debugLog('LiveKitService: Failed to send chat message: $e');
      return false;
    }
  }

  /// 处理接收到的 DataChannel 消息
  void _handleDataReceived(List<int> data, RemoteParticipant? participant) {
    try {
      final json = jsonDecode(utf8.decode(data)) as Map<String, dynamic>;

      if (json['type'] == 'chat') {
        final message = InCallChatMessage(
          senderId: json['sender'] as String? ?? participant?.identity ?? '',
          senderName: json['name'] as String? ?? participant?.name ?? '',
          content: json['content'] as String? ?? '',
          timestamp: DateTime.fromMillisecondsSinceEpoch(
            json['ts'] as int? ?? DateTime.now().millisecondsSinceEpoch,
          ),
          isLocal: false,
        );

        _chatMessages.add(message);
        if (!_chatMessageController.isClosed) {
          _chatMessageController.add(message);
        }
        notifyListeners();

        debugLog('LiveKitService: Chat message received');
      }
    } catch (e) {
      debugLog('LiveKitService: Failed to parse data message: $e');
    }
  }

  // ============================================
  // 私有方法
  // ============================================

  /// 设置房间事件监听
  void _setupRoomListeners() {
    if (_room == null) return;

    _roomListener = _room!.createListener();

    // 参与者加入
    _roomListener!.on<ParticipantConnectedEvent>((event) {
      _addRemoteParticipant(event.participant);
      _notifyParticipantsChanged();
    });

    // 参与者离开
    _roomListener!.on<ParticipantDisconnectedEvent>((event) {
      final participant = _participants.remove(event.participant.identity);
      if (participant != null) {
        onParticipantLeft?.call(participant);
      }
      _notifyParticipantsChanged();
    });

    // 轨道订阅
    _roomListener!.on<TrackSubscribedEvent>((event) {
      _updateRemoteParticipant(event.participant);
      _notifyParticipantsChanged();
    });

    // 轨道取消订阅
    _roomListener!.on<TrackUnsubscribedEvent>((event) {
      _updateRemoteParticipant(event.participant);
      _notifyParticipantsChanged();
    });

    // 轨道静音状态变化
    _roomListener!.on<TrackMutedEvent>((event) {
      if (event.participant is RemoteParticipant) {
        _updateRemoteParticipant(event.participant as RemoteParticipant);
      }
      _notifyParticipantsChanged();
    });

    _roomListener!.on<TrackUnmutedEvent>((event) {
      if (event.participant is RemoteParticipant) {
        _updateRemoteParticipant(event.participant as RemoteParticipant);
      }
      _notifyParticipantsChanged();
    });

    // 活跃说话人变化
    _roomListener!.on<ActiveSpeakersChangedEvent>((event) {
      final activeSpeakerIds = <String>{
        for (final speaker in event.speakers) speaker.identity,
      };
      for (final entry in _participants.entries) {
        final isSpeaking = activeSpeakerIds.contains(entry.key);
        if (entry.value.isSpeaking != isSpeaking) {
          _participants[entry.key] = entry.value.copyWith(isSpeaking: isSpeaking);
          if (isSpeaking) {
            onActiveSpeakerChanged?.call(_participants[entry.key]!);
          }
        }
      }
      _notifyParticipantsChanged();
    });

    // 连接状态变化
    _roomListener!.on<RoomDisconnectedEvent>((event) {
      debugLog('LiveKitService: Room disconnected: ${event.reason}');
      _setState(MeetingState.disconnected);
    });

    _roomListener!.on<RoomReconnectingEvent>((event) {
      debugLog('LiveKitService: Room reconnecting');
      _setState(MeetingState.reconnecting);
    });

    _roomListener!.on<RoomReconnectedEvent>((event) {
      debugLog('LiveKitService: Room reconnected');
      _setState(MeetingState.connected);
    });

    // 录制状态变化
    _roomListener!.on<RoomRecordingStatusChanged>((event) {
      onRecordingStateChanged?.call(event.activeRecording);
    });

    // DataChannel 消息（通话中聊天）
    _roomListener!.on<DataReceivedEvent>((event) {
      _handleDataReceived(event.data, event.participant);
    });
  }

  /// 添加远程参与者
  void _addRemoteParticipant(RemoteParticipant participant) {
    final meetingParticipant = MeetingParticipant(
      id: participant.identity,
      name: participant.name.isNotEmpty ? participant.name : participant.identity,
      avatarUrl: participant.metadata,
      isLocal: false,
      isMuted: !participant.isMicrophoneEnabled(),
      isVideoEnabled: participant.isCameraEnabled(),
      isScreenSharing: participant.isScreenShareEnabled(),
      videoTrack: _getVideoTrack(participant),
      audioTrack: _getAudioTrack(participant),
      screenTrack: _getScreenTrack(participant),
    );

    _participants[participant.identity] = meetingParticipant;
    onParticipantJoined?.call(meetingParticipant);

    debugLog('LiveKitService: Participant joined: ${participant.name}');
  }

  /// 更新远程参与者
  void _updateRemoteParticipant(RemoteParticipant participant) {
    final existing = _participants[participant.identity];
    if (existing == null) return;

    _participants[participant.identity] = existing.copyWith(
      isMuted: !participant.isMicrophoneEnabled(),
      isVideoEnabled: participant.isCameraEnabled(),
      isScreenSharing: participant.isScreenShareEnabled(),
      videoTrack: _getVideoTrack(participant),
      audioTrack: _getAudioTrack(participant),
      screenTrack: _getScreenTrack(participant),
    );
  }

  /// 更新本地参与者
  void _updateLocalParticipant() {
    if (_localParticipant == null) return;

    final existing = _participants[_localParticipant!.identity];
    if (existing == null) return;

    _participants[_localParticipant!.identity] = existing.copyWith(
      isMuted: _isMuted,
      isVideoEnabled: _isVideoEnabled,
      isScreenSharing: _isScreenSharing,
      videoTrack: _getLocalVideoTrack(),
      screenTrack: _getLocalScreenTrack(),
    );

    _notifyParticipantsChanged();
  }

  /// 获取视频轨道
  VideoTrack? _getVideoTrack(RemoteParticipant participant) {
    for (final pub in participant.videoTrackPublications) {
      if (pub.source == TrackSource.camera && pub.track != null) {
        return pub.track as VideoTrack;
      }
    }
    return null;
  }

  /// 获取音频轨道
  AudioTrack? _getAudioTrack(RemoteParticipant participant) {
    for (final pub in participant.audioTrackPublications) {
      if (pub.track != null) {
        return pub.track as AudioTrack;
      }
    }
    return null;
  }

  /// 获取屏幕共享轨道
  VideoTrack? _getScreenTrack(RemoteParticipant participant) {
    for (final pub in participant.videoTrackPublications) {
      if (pub.source == TrackSource.screenShareVideo && pub.track != null) {
        return pub.track as VideoTrack;
      }
    }
    return null;
  }

  /// 获取本地视频轨道
  VideoTrack? _getLocalVideoTrack() {
    for (final pub in _localParticipant?.videoTrackPublications ?? []) {
      if (pub.source == TrackSource.camera && pub.track != null) {
        return pub.track as VideoTrack;
      }
    }
    return null;
  }

  /// 获取本地屏幕共享轨道
  VideoTrack? _getLocalScreenTrack() {
    for (final pub in _localParticipant?.videoTrackPublications ?? []) {
      if (pub.source == TrackSource.screenShareVideo && pub.track != null) {
        return pub.track as VideoTrack;
      }
    }
    return null;
  }

  /// 通知参与者变化
  void _notifyParticipantsChanged() {
    onParticipantsChanged?.call(participants);
    notifyListeners();
  }

  /// 设置状态
  void _setState(MeetingState newState) {
    if (_state == newState) return;
    _state = newState;
    onStateChanged?.call(_state);
    notifyListeners();
    debugLog('LiveKitService: State changed to $_state');
  }

  /// 启动通话时长计时器
  void _startDurationTimer() {
    _durationTimer?.cancel();
    _duration = Duration.zero;
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _duration += const Duration(seconds: 1);
      onDurationUpdate?.call(_duration);
    });
  }

  /// 清理资源
  Future<void> _cleanup() async {
    _durationTimer?.cancel();
    _durationTimer = null;
    _duration = Duration.zero;

    // 异步释放资源
    await _roomListener?.dispose();
    _roomListener = null;

    await _room?.dispose();
    _room = null;

    _localParticipant = null;
    _participants.clear();
    _currentMeeting = null;

    _isMuted = false;
    _isVideoEnabled = true;
    _isScreenSharing = false;
    _chatMessages.clear();

    _e2ee.reset();
    _e2eeEnabled = false;

    // 释放 ML Kit 人像分割器（虚拟背景），避免原生分割器泄漏到进程生命周期；
    // 下次需要时 renderComposite 会惰性重建。
    await VirtualBackgroundEngine.dispose();

    debugLog('LiveKitService: Cleaned up');
  }

  /// 释放资源
  @override
  void dispose() {
    // 注意: dispose 必须是同步的（ChangeNotifier 要求）
    // 如果需要异步清理，应在调用 dispose 前手动调用 leaveMeeting
    _durationTimer?.cancel();
    _chatMessageController.close();
    _roomListener?.dispose();
    _room?.dispose();
    super.dispose();
  }
}

/// 通话中聊天消息
class InCallChatMessage {
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isLocal;

  const InCallChatMessage({
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.isLocal = false,
  });
}
