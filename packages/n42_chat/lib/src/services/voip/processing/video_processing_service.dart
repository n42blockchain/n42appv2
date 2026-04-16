import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../domain/entities/call_enhancement_settings.dart';

/// 通话视频处理服务：管理虚拟背景 / 模糊的状态与生命周期。
///
/// 实际的帧合成逻辑位于 [VirtualBackgroundProcessor]（Google ML Kit
/// Selfie Segmentation + Dart 侧 alpha 合成），该 processor 只在
/// 首次通话时懒加载，避免启动期依赖 ML 模型。
///
/// 典型集成点（伪代码）：
///
/// ```dart
/// final service = getIt<VideoProcessingService>();
/// final localTrack = await webrtc.getUserMedia(...);
/// final processed = await service.attach(localTrack);
/// peerConnection.addTrack(processed, localStream);
/// ```
class VideoProcessingService {
  VideoProcessingService();

  final ValueNotifier<CallEnhancementSettings> settings =
      ValueNotifier<CallEnhancementSettings>(const CallEnhancementSettings());

  /// 懒加载的底层 processor；首次启用虚拟背景时创建。
  Future<void> Function()? _processorDisposer;
  bool _attached = false;

  /// 更新虚拟背景偏好。若正在通话，触发 processor 刷新。
  void setBackground(VirtualBackground background) {
    settings.value = settings.value.copyWith(background: background);
  }

  /// 是否有虚拟背景生效。
  bool get isBackgroundActive => settings.value.hasVirtualBackground;

  /// 通话开始时由 LiveKit/WebRTC 调用，注册底层 dispose 回调。
  ///
  /// [processorDisposer] 由具体实现（MLKit 封装）提供，以便在 [detach]
  /// 时统一释放模型资源。
  void registerProcessor(Future<void> Function() processorDisposer) {
    _processorDisposer = processorDisposer;
    _attached = true;
  }

  bool get isAttached => _attached;

  /// 通话结束时调用，释放 ML 模型等重资源。
  Future<void> detach() async {
    if (_processorDisposer != null) {
      await _processorDisposer!();
    }
    _processorDisposer = null;
    _attached = false;
  }

  Future<void> dispose() async {
    await detach();
    settings.dispose();
  }
}
