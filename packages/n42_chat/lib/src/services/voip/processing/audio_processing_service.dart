import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../domain/entities/call_enhancement_settings.dart';

/// 通话音频处理服务
///
/// 负责把用户偏好（[CallEnhancementSettings.noiseSuppression] /
/// [CallEnhancementSettings.echoCancellation] /
/// [CallEnhancementSettings.autoGainControl]）映射成 WebRTC /
/// LiveKit 的 audio capture options。
///
/// 具体到底层（WebRTC `getUserMedia` 的 `MediaStreamConstraints` 或 LiveKit
/// `AudioCaptureOptions`）的对接放在 [LiveKitService] / [WebRTCService]
/// 侧——本服务只持有 [ValueNotifier] 状态，供这些底层读取最新值并在
/// 通话启动时作为参数传入。
///
/// 本服务刻意不直接持有 MediaStreamTrack，以保持与 flutter_webrtc 的类型
/// 解耦——若后续接入原生 RNNoise 处理器，可扩展 [attach] 方法。
class AudioProcessingService {
  AudioProcessingService();

  final ValueNotifier<CallEnhancementSettings> settings =
      ValueNotifier<CallEnhancementSettings>(const CallEnhancementSettings());

  /// 更新降噪强度。
  void setNoiseSuppression(NoiseSuppressionLevel level) {
    settings.value = settings.value.copyWith(noiseSuppression: level);
  }

  void setEchoCancellation(bool enabled) {
    settings.value = settings.value.copyWith(echoCancellation: enabled);
  }

  void setAutoGainControl(bool enabled) {
    settings.value = settings.value.copyWith(autoGainControl: enabled);
  }

  /// 构造 WebRTC `getUserMedia` 需要的 `audio` 约束 map。
  Map<String, dynamic> buildAudioConstraints() {
    final s = settings.value;
    return {
      'echoCancellation': s.echoCancellation,
      'autoGainControl': s.autoGainControl,
      'noiseSuppression': s.noiseSuppressionEnabled,
      if (s.noiseSuppressionEnabled)
        'googNoiseSuppression2': s.noiseSuppression == NoiseSuppressionLevel.high,
    };
  }

  Future<void> dispose() async {
    settings.dispose();
  }
}
