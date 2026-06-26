/// VoIP 配置
/// 
/// 用于存储 TURN/STUN 服务器配置和 LiveKit 配置
/// 这些参数需要从服务端获取或在初始化时配置
library;

import '../../core/utils/debug_log.dart';

/// VoIP 配置类
class VoIPConfig {
  /// 单例实例
  static final VoIPConfig _instance = VoIPConfig._internal();
  factory VoIPConfig() => _instance;
  VoIPConfig._internal();

  // ============================================
  // TURN/STUN 服务器配置
  // ============================================
  
  /// TURN 服务器 URI 列表
  /// 格式: ["turn:turn.example.com:3478", "turns:turn.example.com:5349"]
  List<String> turnUris = [];
  
  /// TURN 服务器用户名（从服务端获取，临时凭证）
  String? turnUsername;
  
  /// TURN 服务器密码（从服务端获取，临时凭证）
  String? turnPassword;
  
  /// TURN 凭证有效期（毫秒）
  int turnTtl = 86400000; // 24小时
  
  // ============================================
  // LiveKit 配置（多人会议）
  // ============================================
  
  /// LiveKit 服务器 URL
  /// 格式: "wss://livekit.example.com"
  String? liveKitUrl;
  
  /// LiveKit API Key（用于生成 token）
  String? liveKitApiKey;
  
  /// LiveKit API Secret（用于生成 token）
  ///
  /// **安全警告**: 此字段仅用于开发测试。
  /// 生产环境中，token 应由后端服务器生成，
  /// API Secret 不应存储在客户端。
  @Deprecated('Token should be generated server-side in production')
  String? liveKitApiSecret;
  
  // ============================================
  // 通话设置
  // ============================================

  /// 默认开启视频
  bool defaultVideoEnabled = true;

  /// 默认开启音频
  bool defaultAudioEnabled = true;

  /// 默认使用扬声器
  bool defaultSpeakerEnabled = false;

  /// 通话超时时间（秒）
  int callTimeout = 60;

  /// 最大视频分辨率
  VideoResolution maxVideoResolution = VideoResolution.hd720;

  /// 最大帧率
  int maxFrameRate = 30;

  // ============================================
  // 音频处理设置 (Audio Processing)
  // ============================================

  /// 启用 AI 降噪 (Noise Suppression)
  /// 使用机器学习算法抑制背景噪声
  bool enableNoiseSuppression = true;

  /// 启用回声消除 (Acoustic Echo Cancellation)
  /// 消除扬声器反馈到麦克风的回声
  bool enableEchoCancellation = true;

  /// 启用自动增益控制 (Automatic Gain Control)
  /// 自动调节麦克风音量，保持稳定的输出电平
  bool enableAutoGainControl = true;

  /// 启用高通滤波 (High Pass Filter)
  /// 过滤低频噪声（如空调嗡嗡声）
  bool enableHighPassFilter = true;

  /// 启用音频增强模式
  /// 当启用时，使用更激进的降噪算法（适用于嘈杂环境）
  bool enableEnhancedAudioMode = false;

  /// 获取音频处理配置
  AudioProcessingConfig get audioProcessing => AudioProcessingConfig(
    noiseSuppression: enableNoiseSuppression,
    echoCancellation: enableEchoCancellation,
    autoGainControl: enableAutoGainControl,
    highPassFilter: enableHighPassFilter,
    enhancedMode: enableEnhancedAudioMode,
  );

  /// 设置音频处理配置
  void setAudioProcessing(AudioProcessingConfig config) {
    enableNoiseSuppression = config.noiseSuppression;
    enableEchoCancellation = config.echoCancellation;
    enableAutoGainControl = config.autoGainControl;
    enableHighPassFilter = config.highPassFilter;
    enableEnhancedAudioMode = config.enhancedMode;
    debugLog('VoIPConfig: Audio processing updated - NS: $enableNoiseSuppression, AEC: $enableEchoCancellation, AGC: $enableAutoGainControl');
  }

  // ============================================
  // 视频处理设置 (Video Processing)
  // ============================================

  /// 背景处理模式
  BackgroundMode backgroundMode = BackgroundMode.none;

  /// 背景模糊强度 (0.0 - 1.0)
  /// 0.0 = 无模糊, 1.0 = 最大模糊
  double backgroundBlurRadius = 0.5;

  /// 虚拟背景图片路径
  /// 可以是本地文件路径或网络 URL
  String? virtualBackgroundUrl;

  /// 预设虚拟背景列表
  List<String> presetBackgrounds = [];

  /// 获取背景处理配置
  BackgroundProcessingConfig get backgroundProcessing => BackgroundProcessingConfig(
    mode: backgroundMode,
    blurRadius: backgroundBlurRadius,
    virtualBackgroundUrl: virtualBackgroundUrl,
  );

  /// 设置背景处理配置
  void setBackgroundProcessing(BackgroundProcessingConfig config) {
    backgroundMode = config.mode;
    backgroundBlurRadius = config.blurRadius;
    virtualBackgroundUrl = config.virtualBackgroundUrl;
    debugLog('VoIPConfig: Background processing updated - mode: $backgroundMode, blur: $backgroundBlurRadius');
  }

  // ============================================
  // 通话录音设置 (Call Recording)
  // ============================================

  /// 是否启用通话录音功能
  ///
  /// 当前 LiveKit 录制仍依赖后端 Egress 接线，默认保持关闭，避免把未交付能力暴露成已启用状态。
  bool enableCallRecording = false;

  /// 录音自动开始（进入通话时自动开始录音）
  bool autoStartRecording = false;

  /// 录音音频采样率
  int recordingSampleRate = 44100;

  /// 录音音频比特率
  int recordingBitRate = 128000;

  /// 录音最大时长（秒），0 表示无限制
  int recordingMaxDuration = 0;

  /// 录音保存路径（null 使用默认路径）
  String? recordingSavePath;

  /// 获取录音配置
  CallRecordingConfig get callRecordingConfig => CallRecordingConfig(
    enabled: enableCallRecording,
    autoStart: autoStartRecording,
    sampleRate: recordingSampleRate,
    bitRate: recordingBitRate,
    maxDuration: recordingMaxDuration,
    savePath: recordingSavePath,
  );

  /// 设置录音配置
  void setCallRecordingConfig(CallRecordingConfig config) {
    enableCallRecording = config.enabled;
    autoStartRecording = config.autoStart;
    recordingSampleRate = config.sampleRate;
    recordingBitRate = config.bitRate;
    recordingMaxDuration = config.maxDuration;
    recordingSavePath = config.savePath;
    debugLog('VoIPConfig: Call recording updated - enabled: $enableCallRecording, autoStart: $autoStartRecording');
  }

  // ============================================
  // 来电推送配置
  // ============================================
  
  /// Firebase 服务器密钥（FCM 推送）
  String? fcmServerKey;
  
  /// APNs 证书路径（iOS 推送）
  String? apnsCertPath;
  
  /// VoIP 推送证书路径（iOS VoIP 推送）
  String? voipCertPath;
  
  // ============================================
  // 公共 STUN 服务器（备用）
  // ============================================
  
  /// 公共 STUN 服务器列表
  static const List<Map<String, String>> publicStunServers = [
    {'urls': 'stun:stun.l.google.com:19302'},
    {'urls': 'stun:stun1.l.google.com:19302'},
    {'urls': 'stun:stun2.l.google.com:19302'},
    {'urls': 'stun:stun.stunprotocol.org:3478'},
  ];
  
  /// 获取 ICE 服务器配置
  List<Map<String, dynamic>> getIceServers() {
    final servers = <Map<String, dynamic>>[];
    
    // 添加 TURN 服务器
    if (turnUris.isNotEmpty && turnUsername != null && turnPassword != null) {
      for (final uri in turnUris) {
        servers.add({
          'urls': uri,
          'username': turnUsername,
          'credential': turnPassword,
        });
      }
    }
    
    // 添加公共 STUN 服务器作为备用
    servers.addAll(publicStunServers);
    
    return servers;
  }
  
  /// 从 Matrix 服务器响应更新 TURN 配置
  void updateFromTurnResponse(Map<String, dynamic> response) {
    if (response['uris'] != null) {
      turnUris = List<String>.from(response['uris'] as List);
    }
    turnUsername = response['username'] as String?;
    turnPassword = response['password'] as String?;
    if (response['ttl'] != null) {
      turnTtl = response['ttl'] as int;
    }
    debugLog('VoIPConfig: Updated TURN config with ${turnUris.length} URIs');
  }
  
  /// 配置 LiveKit
  void configureLiveKit({
    required String url,
    String? apiKey,
    String? apiSecret,
  }) {
    liveKitUrl = url;
    liveKitApiKey = apiKey;
    liveKitApiSecret = apiSecret;
    debugLog('VoIPConfig: LiveKit configured with URL: $url');
  }
  
  /// 检查是否已配置 TURN
  bool get hasTurnConfig => turnUris.isNotEmpty;
  
  /// 检查是否已配置 LiveKit
  bool get hasLiveKitConfig => liveKitUrl != null && liveKitUrl!.isNotEmpty;
  
  /// 重置配置
  void reset() {
    turnUris = [];
    turnUsername = null;
    turnPassword = null;
    liveKitUrl = null;
    liveKitApiKey = null;
    liveKitApiSecret = null;
  }
  
  @override
  String toString() {
    return 'VoIPConfig('
        'turnUris: ${turnUris.length}, '
        'hasTurnCredentials: ${turnUsername != null}, '
        'liveKitUrl: $liveKitUrl'
        ')';
  }
}

/// 视频分辨率枚举
enum VideoResolution {
  /// 360p (640x360)
  sd360(640, 360),
  /// 480p (854x480)
  sd480(854, 480),
  /// 720p (1280x720)
  hd720(1280, 720),
  /// 1080p (1920x1080)
  hd1080(1920, 1080);

  final int width;
  final int height;

  const VideoResolution(this.width, this.height);

  Map<String, dynamic> toConstraints() {
    return {
      'width': {'ideal': width},
      'height': {'ideal': height},
    };
  }
}

/// 音频处理配置
///
/// 包含各种音频处理选项，用于改善通话质量
class AudioProcessingConfig {
  /// 启用降噪
  final bool noiseSuppression;

  /// 启用回声消除
  final bool echoCancellation;

  /// 启用自动增益控制
  final bool autoGainControl;

  /// 启用高通滤波
  final bool highPassFilter;

  /// 启用增强模式（更激进的降噪）
  final bool enhancedMode;

  const AudioProcessingConfig({
    this.noiseSuppression = true,
    this.echoCancellation = true,
    this.autoGainControl = true,
    this.highPassFilter = true,
    this.enhancedMode = false,
  });

  /// 全部启用的配置
  static const AudioProcessingConfig enabled = AudioProcessingConfig();

  /// 全部禁用的配置
  static const AudioProcessingConfig disabled = AudioProcessingConfig(
    noiseSuppression: false,
    echoCancellation: false,
    autoGainControl: false,
    highPassFilter: false,
    enhancedMode: false,
  );

  /// 增强模式配置（适用于嘈杂环境）
  static const AudioProcessingConfig enhanced = AudioProcessingConfig(
    noiseSuppression: true,
    echoCancellation: true,
    autoGainControl: true,
    highPassFilter: true,
    enhancedMode: true,
  );

  /// 转换为 WebRTC 音频约束
  Map<String, dynamic> toWebRTCConstraints() {
    return {
      'echoCancellation': echoCancellation,
      'noiseSuppression': noiseSuppression,
      'autoGainControl': autoGainControl,
    };
  }

  AudioProcessingConfig copyWith({
    bool? noiseSuppression,
    bool? echoCancellation,
    bool? autoGainControl,
    bool? highPassFilter,
    bool? enhancedMode,
  }) {
    return AudioProcessingConfig(
      noiseSuppression: noiseSuppression ?? this.noiseSuppression,
      echoCancellation: echoCancellation ?? this.echoCancellation,
      autoGainControl: autoGainControl ?? this.autoGainControl,
      highPassFilter: highPassFilter ?? this.highPassFilter,
      enhancedMode: enhancedMode ?? this.enhancedMode,
    );
  }

  @override
  String toString() {
    return 'AudioProcessingConfig(NS: $noiseSuppression, AEC: $echoCancellation, AGC: $autoGainControl, HPF: $highPassFilter, Enhanced: $enhancedMode)';
  }
}

/// 背景处理模式
enum BackgroundMode {
  /// 无处理（显示真实背景）
  none,

  /// 背景模糊
  blur,

  /// 虚拟背景（替换背景图片）
  virtualBackground,

  /// 纯色背景
  solidColor,
}

/// 背景处理配置
///
/// 用于视频通话中的背景模糊或虚拟背景功能
class BackgroundProcessingConfig {
  /// 背景处理模式
  final BackgroundMode mode;

  /// 模糊半径 (0.0 - 1.0)
  final double blurRadius;

  /// 虚拟背景图片 URL 或路径
  final String? virtualBackgroundUrl;

  /// 纯色背景颜色（十六进制，如 "#FFFFFF"）
  final String? solidColor;

  const BackgroundProcessingConfig({
    this.mode = BackgroundMode.none,
    this.blurRadius = 0.5,
    this.virtualBackgroundUrl,
    this.solidColor,
  });

  /// 无背景处理
  static const BackgroundProcessingConfig disabled = BackgroundProcessingConfig();

  /// 轻度模糊
  static const BackgroundProcessingConfig lightBlur = BackgroundProcessingConfig(
    mode: BackgroundMode.blur,
    blurRadius: 0.3,
  );

  /// 中度模糊
  static const BackgroundProcessingConfig mediumBlur = BackgroundProcessingConfig(
    mode: BackgroundMode.blur,
    blurRadius: 0.5,
  );

  /// 强烈模糊
  static const BackgroundProcessingConfig heavyBlur = BackgroundProcessingConfig(
    mode: BackgroundMode.blur,
    blurRadius: 0.8,
  );

  /// 创建虚拟背景配置
  factory BackgroundProcessingConfig.withVirtualBackground(String url) {
    return BackgroundProcessingConfig(
      mode: BackgroundMode.virtualBackground,
      virtualBackgroundUrl: url,
    );
  }

  /// 创建纯色背景配置
  factory BackgroundProcessingConfig.withSolidColor(String color) {
    return BackgroundProcessingConfig(
      mode: BackgroundMode.solidColor,
      solidColor: color,
    );
  }

  /// 是否启用了背景处理
  bool get isEnabled => mode != BackgroundMode.none;

  /// 是否是模糊模式
  bool get isBlurMode => mode == BackgroundMode.blur;

  /// 是否是虚拟背景模式
  bool get isVirtualBackgroundMode => mode == BackgroundMode.virtualBackground;

  BackgroundProcessingConfig copyWith({
    BackgroundMode? mode,
    double? blurRadius,
    String? virtualBackgroundUrl,
    String? solidColor,
  }) {
    return BackgroundProcessingConfig(
      mode: mode ?? this.mode,
      blurRadius: blurRadius ?? this.blurRadius,
      virtualBackgroundUrl: virtualBackgroundUrl ?? this.virtualBackgroundUrl,
      solidColor: solidColor ?? this.solidColor,
    );
  }

  @override
  String toString() {
    return 'BackgroundProcessingConfig(mode: $mode, blurRadius: $blurRadius, virtualBg: $virtualBackgroundUrl)';
  }
}

/// 通话录音配置
///
/// 用于管理通话录音功能的设置
class CallRecordingConfig {
  /// 是否启用录音功能
  final bool enabled;

  /// 是否自动开始录音
  final bool autoStart;

  /// 音频采样率
  final int sampleRate;

  /// 音频比特率
  final int bitRate;

  /// 最大录音时长（秒），0 表示无限制
  final int maxDuration;

  /// 保存路径
  final String? savePath;

  const CallRecordingConfig({
    this.enabled = false,
    this.autoStart = false,
    this.sampleRate = 44100,
    this.bitRate = 128000,
    this.maxDuration = 0,
    this.savePath,
  });

  /// 默认配置
  static const CallRecordingConfig defaultConfig = CallRecordingConfig();

  /// 禁用录音
  static const CallRecordingConfig disabled = CallRecordingConfig(
    enabled: false,
  );

  /// 自动录音配置
  static const CallRecordingConfig autoRecord = CallRecordingConfig(
    enabled: true,
    autoStart: true,
  );

  /// 高质量录音配置
  static const CallRecordingConfig highQuality = CallRecordingConfig(
    enabled: true,
    sampleRate: 48000,
    bitRate: 256000,
  );

  CallRecordingConfig copyWith({
    bool? enabled,
    bool? autoStart,
    int? sampleRate,
    int? bitRate,
    int? maxDuration,
    String? savePath,
  }) {
    return CallRecordingConfig(
      enabled: enabled ?? this.enabled,
      autoStart: autoStart ?? this.autoStart,
      sampleRate: sampleRate ?? this.sampleRate,
      bitRate: bitRate ?? this.bitRate,
      maxDuration: maxDuration ?? this.maxDuration,
      savePath: savePath ?? this.savePath,
    );
  }

  @override
  String toString() {
    return 'CallRecordingConfig(enabled: $enabled, autoStart: $autoStart, sampleRate: $sampleRate, bitRate: $bitRate)';
  }
}
