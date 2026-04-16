import 'package:equatable/equatable.dart';

/// 虚拟背景类型。
sealed class VirtualBackground extends Equatable {
  const VirtualBackground();

  /// 无（直出摄像头画面）。
  const factory VirtualBackground.none() = VirtualBackgroundNone;

  /// 高斯模糊。[sigma] 取值 1-20，越大越模糊；默认 8。
  const factory VirtualBackground.blur({double sigma}) = VirtualBackgroundBlur;

  /// 用指定图片做背景（本地 asset 或文件路径）。
  const factory VirtualBackground.image(String assetOrFilePath) =
      VirtualBackgroundImage;
}

class VirtualBackgroundNone extends VirtualBackground {
  const VirtualBackgroundNone();
  @override
  List<Object?> get props => const [];
}

class VirtualBackgroundBlur extends VirtualBackground {
  final double sigma;
  const VirtualBackgroundBlur({this.sigma = 8}) : super();
  @override
  List<Object?> get props => [sigma];
}

class VirtualBackgroundImage extends VirtualBackground {
  final String assetOrFilePath;
  const VirtualBackgroundImage(this.assetOrFilePath) : super();
  @override
  List<Object?> get props => [assetOrFilePath];
}

/// 降噪强度。
enum NoiseSuppressionLevel { off, low, medium, high }

/// 通话增强用户偏好（虚拟背景 + AI 降噪）。
class CallEnhancementSettings extends Equatable {
  const CallEnhancementSettings({
    this.background = const VirtualBackgroundNone(),
    this.noiseSuppression = NoiseSuppressionLevel.medium,
    this.echoCancellation = true,
    this.autoGainControl = true,
  });

  final VirtualBackground background;
  final NoiseSuppressionLevel noiseSuppression;
  final bool echoCancellation;
  final bool autoGainControl;

  bool get noiseSuppressionEnabled =>
      noiseSuppression != NoiseSuppressionLevel.off;

  bool get hasVirtualBackground => background is! VirtualBackgroundNone;

  CallEnhancementSettings copyWith({
    VirtualBackground? background,
    NoiseSuppressionLevel? noiseSuppression,
    bool? echoCancellation,
    bool? autoGainControl,
  }) {
    return CallEnhancementSettings(
      background: background ?? this.background,
      noiseSuppression: noiseSuppression ?? this.noiseSuppression,
      echoCancellation: echoCancellation ?? this.echoCancellation,
      autoGainControl: autoGainControl ?? this.autoGainControl,
    );
  }

  @override
  List<Object?> get props => [
        background,
        noiseSuppression,
        echoCancellation,
        autoGainControl,
      ];
}
