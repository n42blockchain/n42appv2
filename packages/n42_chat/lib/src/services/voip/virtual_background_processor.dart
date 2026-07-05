/// 通话虚拟背景 / 背景模糊处理器
///
/// 使用 Google ML Kit 人像分割（Selfie Segmentation）生成前景遮罩，
/// 再用 `image` 库把背景替换为模糊画面、纯色或自定义图片。
///
/// ## 真实能力边界（请勿夸大）
///
/// - **分割引擎与合成是真实的**：[renderComposite] 接收一帧 RGBA/编码图像，
///   跑真正的人像分割并产出合成后的图像字节。可用于本地自视图预览、
///   头像/资料图背景替换等场景，已可单测、可直接渲染。
/// - **WebRTC 帧注入是平台边界**：本类实现了 LiveKit [TrackProcessor] 接口
///   并被挂到摄像头采集链路（[VoipCameraProcessor]）。但 flutter_webrtc 当前
///   不向 Dart 暴露摄像头轨道的逐帧回调，因此 [processedTrack] 暂时透传源轨道
///   （视觉效果落在本地预览层）。真正把合成帧写回发布轨道需要原生侧
///   frame processor 接线 —— 这部分与录制（Egress）一样属于待接线的原生能力，
///   不在此谎称已完成。详见 [VoipCameraProcessor.processedTrack] 注释。
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import 'package:image/image.dart' as img;
import 'package:livekit_client/livekit_client.dart';
import 'package:path_provider/path_provider.dart';

import 'voip_config.dart';
import '../../core/utils/debug_log.dart';

/// 人像分割合成引擎（与 LiveKit 解耦，可独立使用 / 单测）
class VirtualBackgroundEngine {
  VirtualBackgroundEngine._();

  static SelfieSegmenter? _segmenter;

  /// 前景置信度阈值：>= 该值判定为人像（前景）
  static const double _foregroundThreshold = 0.5;

  static SelfieSegmenter get _selfieSegmenter {
    _segmenter ??= SelfieSegmenter(
      mode: SegmenterMode.single,
      enableRawSizeMask: true,
    );
    return _segmenter!;
  }

  /// 对一帧编码图像（JPEG/PNG 字节）应用背景处理，返回 JPEG 字节。
  ///
  /// 分割失败 / 平台不支持时返回原图字节（绝不抛出，保证调用方降级）。
  /// [backgroundImageBytes] 仅 [BackgroundMode.virtualBackground] 时需要。
  static Future<Uint8List> renderComposite(
    Uint8List frameBytes, {
    required BackgroundMode mode,
    double blurRadius = 0.5,
    String? solidColorHex,
    Uint8List? backgroundImageBytes,
    double beautyStrength = 0.0,
  }) async {
    final beauty = beautyStrength.clamp(0.0, 1.0);
    // 背景替换或美颜任一开启才需要分割；都关则直接透传。
    if (kIsWeb || (mode == BackgroundMode.none && beauty <= 0)) {
      return frameBytes;
    }

    SegmentationMask? mask;
    File? tempFile;
    try {
      final tempDir = await getTemporaryDirectory();
      tempFile = File(
        '${tempDir.path}/vbg_${frameBytes.length}_${frameBytes.hashCode}.jpg',
      );
      await tempFile.writeAsBytes(frameBytes);
      final inputImage = InputImage.fromFilePath(tempFile.path);
      mask = await _selfieSegmenter.processImage(inputImage);
    } catch (e) {
      debugLog('VirtualBackgroundEngine: segmentation failed: $e');
      return frameBytes;
    } finally {
      if (tempFile != null && await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
    }

    if (mask == null) {
      debugLog('VirtualBackgroundEngine: no mask, returning original frame');
      return frameBytes;
    }

    try {
      return await compute(
        _composeInIsolate,
        _ComposeParams(
          frameBytes: frameBytes,
          maskWidth: mask.width,
          maskHeight: mask.height,
          confidences: mask.confidences,
          mode: mode,
          blurRadius: blurRadius,
          solidColorHex: solidColorHex,
          backgroundImageBytes: backgroundImageBytes,
          beautyStrength: beauty,
        ),
      );
    } catch (e) {
      debugLog('VirtualBackgroundEngine: compose failed: $e');
      return frameBytes;
    }
  }

  /// 纯函数合成入口（供单测直接调用，绕过分割器与 isolate）。
  ///
  /// 给定原图字节 + 人像 mask（[confidences] 行优先，长度 = maskW×maskH，
  /// 值越大越偏前景），按 [mode] 产出合成后的 JPEG 字节。前景保留原图、
  /// 背景按模式替换（模糊/纯色/虚拟背景图）。
  @visibleForTesting
  static Uint8List composeFrame(
    Uint8List frameBytes, {
    required int maskWidth,
    required int maskHeight,
    required List<double> confidences,
    required BackgroundMode mode,
    double blurRadius = 0.5,
    String? solidColorHex,
    Uint8List? backgroundImageBytes,
    double beautyStrength = 0.0,
  }) => _composeInIsolate(
    _ComposeParams(
      frameBytes: frameBytes,
      maskWidth: maskWidth,
      maskHeight: maskHeight,
      confidences: confidences,
      mode: mode,
      blurRadius: blurRadius,
      solidColorHex: solidColorHex,
      backgroundImageBytes: backgroundImageBytes,
      beautyStrength: beautyStrength,
    ),
  );

  /// 前景判定阈值（供单测断言用）
  @visibleForTesting
  static double get foregroundThreshold => _foregroundThreshold;

  /// 在 isolate 中执行像素级合成（避免阻塞 UI）
  static Uint8List _composeInIsolate(_ComposeParams p) {
    final beauty = p.beautyStrength.clamp(0.0, 1.0);
    final replaceBg = p.mode != BackgroundMode.none;
    if (!replaceBg && beauty <= 0) return p.frameBytes;

    final original = img.decodeImage(p.frameBytes);
    if (original == null) return p.frameBytes;

    final width = original.width;
    final height = original.height;
    final minSide = width < height ? width : height;

    // 背景图层（仅替换背景时构造）
    img.Image? background;
    if (replaceBg) {
      switch (p.mode) {
        case BackgroundMode.blur:
          // 模糊半径 0..1 映射到像素半径 1..40，并按帧尺寸夹紧
          // （半径过大会越界，gaussianBlur 在小帧上崩溃）
          final maxR = (minSide ~/ 2 - 1).clamp(1, 40);
          final radius = (p.blurRadius.clamp(0.0, 1.0) * 39 + 1).round().clamp(
            1,
            maxR,
          );
          background = img.gaussianBlur(original.clone(), radius: radius);
          break;
        case BackgroundMode.solidColor:
          final color =
              _parseHexColor(p.solidColorHex) ??
              img.ColorRgb8(0x07, 0xC1, 0x60);
          background = img.Image(width: width, height: height)..clear(color);
          break;
        case BackgroundMode.virtualBackground:
          final bgBytes = p.backgroundImageBytes;
          final bg = bgBytes != null ? img.decodeImage(bgBytes) : null;
          if (bg != null) {
            background = img.copyResize(bg, width: width, height: height);
          } else {
            final r = (minSide ~/ 2 - 1).clamp(1, 20);
            background = img.gaussianBlur(original.clone(), radius: r);
          }
          break;
        case BackgroundMode.none:
          break;
      }
    }

    // 美颜：对人像区域做磨皮（混入模糊层）+ 提亮。预算一张模糊层。
    img.Image? smooth;
    if (beauty > 0) {
      final maxR = (minSide ~/ 2 - 1).clamp(1, 12);
      final r = (beauty * 6).round().clamp(1, maxR);
      smooth = img.gaussianBlur(original.clone(), radius: r);
    }

    // 逐像素合成：mask 分辨率可能与原图不同，按比例映射采样。
    final maskW = p.maskWidth;
    final maskH = p.maskHeight;
    final conf = p.confidences;
    final scaleX = maskW / width;
    final scaleY = maskH / height;
    final smoothBlend = beauty * 0.6; // 磨皮强度上限，保留五官细节
    final brighten = beauty * 0.12; // 提亮强度

    for (var y = 0; y < height; y++) {
      final my = (y * scaleY).floor().clamp(0, maskH - 1);
      final rowBase = my * maskW;
      for (var x = 0; x < width; x++) {
        final mx = (x * scaleX).floor().clamp(0, maskW - 1);
        final c = conf[rowBase + mx];
        final isPerson = c >= _foregroundThreshold;
        // ML Kit：置信度越高越偏前景。低于阈值 → 用背景像素。
        if (!isPerson) {
          if (background != null) {
            original.setPixel(x, y, background.getPixel(x, y));
          }
        } else if (smooth != null) {
          // 人像像素：向模糊层混合（磨皮）+ 提亮
          final o = original.getPixel(x, y);
          final s = smooth.getPixel(x, y);
          original.setPixel(x, y, _beautyPixel(o, s, smoothBlend, brighten));
        }
      }
    }

    return Uint8List.fromList(img.encodeJpg(original, quality: 88));
  }

  /// 美颜单像素：原色 → 模糊色按 [blend] 混合（磨皮），再按 [brighten] 提亮。
  static img.Color _beautyPixel(
    img.Color o,
    img.Color s,
    double blend,
    double brighten,
  ) {
    int chan(num orig, num smooth) {
      final mixed = orig + (smooth - orig) * blend;
      final lit = mixed + (255 - mixed) * brighten;
      return lit.round().clamp(0, 255);
    }

    return img.ColorRgba8(
      chan(o.r, s.r),
      chan(o.g, s.g),
      chan(o.b, s.b),
      o.a.round().clamp(0, 255),
    );
  }

  static img.Color? _parseHexColor(String? hex) {
    if (hex == null) return null;
    var h = hex.replaceFirst('#', '').trim();
    if (h.length == 6) h = 'FF$h';
    if (h.length != 8) return null;
    final v = int.tryParse(h, radix: 16);
    if (v == null) return null;
    return img.ColorRgba8(
      (v >> 16) & 0xFF,
      (v >> 8) & 0xFF,
      v & 0xFF,
      (v >> 24) & 0xFF,
    );
  }

  /// 释放分割器资源
  static Future<void> dispose() async {
    await _segmenter?.close();
    _segmenter = null;
  }
}

/// isolate 入参（全部可序列化）
class _ComposeParams {
  final Uint8List frameBytes;
  final int maskWidth;
  final int maskHeight;
  final List<double> confidences;
  final BackgroundMode mode;
  final double blurRadius;
  final String? solidColorHex;
  final Uint8List? backgroundImageBytes;
  final double beautyStrength;

  const _ComposeParams({
    required this.frameBytes,
    required this.maskWidth,
    required this.maskHeight,
    required this.confidences,
    required this.mode,
    required this.blurRadius,
    this.solidColorHex,
    this.backgroundImageBytes,
    this.beautyStrength = 0.0,
  });
}

/// LiveKit 摄像头帧处理器
///
/// 实现 [TrackProcessor] 接口并挂到本地摄像头采集链路。承载虚拟背景 /
/// 背景模糊的配置与分割引擎。
///
/// 关于 [processedTrack] 的真实边界见文件头注释。
///
/// 实现接口为 `TrackProcessor<VideoProcessorOptions>` 以满足
/// [CameraCaptureOptions.processor] 的静态类型；但 [init]/[restart] 形参声明为
/// 更宽的 [ProcessorOptions]（逆变实现，Dart 合法），以兼容 livekit 2.6.2 base
/// `setProcessor` 恒传入 `AudioProcessorOptions` 的实现，避免运行时类型错。
class VoipCameraProcessor implements TrackProcessor<VideoProcessorOptions> {
  VoipCameraProcessor(this._config);

  final VoIPConfig _config;
  MediaStreamTrack? _sourceTrack;
  Uint8List? _backgroundImageBytes;
  // 上次下发给原生的图片字节标识(长度+首尾字节),避免每次 pushConfig 都
  // 把 MB 级图片重过 MethodChannel(复审 P2)。
  int? _sentImageSignature;

  /// 原生 frame processor 配置通道。
  ///
  /// 当宿主在原生侧（Android libwebrtc `VideoProcessor` / iOS
  /// `RTCVideoCapturerDelegate`）实现真正的发布轨道逐帧替换时，会监听本通道获取
  /// 当前背景配置。原生未实现时调用经 [MissingPluginException] 优雅 no-op——
  /// 不抛错、不误导。这是发布侧替换的**真实契约**，待原生接入即生效。
  static const MethodChannel _nativeChannel = MethodChannel(
    'n42.chat/virtual_background',
  );

  @override
  String get name => 'n42-virtual-background';

  /// 当前是否启用了背景处理
  bool get isEnabled =>
      _config.backgroundMode != BackgroundMode.none ||
      _config.beautyStrength > 0;

  /// 预加载虚拟背景图片字节（供后续合成使用）
  set backgroundImageBytes(Uint8List? bytes) => _backgroundImageBytes = bytes;

  /// 从本地文件路径加载虚拟背景图片字节。
  ///
  /// 网络 URL 请由调用方自行下载后用 [backgroundImageBytes] 注入
  /// （本类不引入 http 依赖）。读取失败时清空背景图，合成会降级为模糊。
  Future<void> loadBackgroundImage(String pathOrUrl) async {
    try {
      final file = File(pathOrUrl);
      if (await file.exists()) {
        _backgroundImageBytes = await file.readAsBytes();
        debugLog('VoipCameraProcessor: background image loaded ($pathOrUrl)');
      } else {
        _backgroundImageBytes = null;
        debugLog(
          'VoipCameraProcessor: background not a local file, '
          'caller should inject bytes ($pathOrUrl)',
        );
      }
    } catch (e) {
      _backgroundImageBytes = null;
      debugLog('VoipCameraProcessor: loadBackgroundImage failed: $e');
    }
  }

  @override
  Future<void> init(ProcessorOptions options) async {
    _sourceTrack = options.track;
    debugLog('VoipCameraProcessor: init (mode=${_config.backgroundMode})');
    await pushConfigToNative();
  }

  @override
  Future<void> restart(ProcessorOptions options) async {
    _sourceTrack = options.track;
    debugLog('VoipCameraProcessor: restart (mode=${_config.backgroundMode})');
    await pushConfigToNative();
  }

  @override
  Future<void> onPublish(Room room) async {
    debugLog('VoipCameraProcessor: onPublish');
  }

  @override
  Future<void> onUnpublish() async {
    debugLog('VoipCameraProcessor: onUnpublish');
  }

  @override
  Future<void> destroy() async {
    _sourceTrack = null;
    debugLog('VoipCameraProcessor: destroy');
    await _safeNative('clearBackground');
  }

  /// 把当前背景配置下发给原生 frame processor（native-first，未接则优雅 no-op）。
  ///
  /// 配置变更后（[LiveKitService] 调用）应调用本方法，使原生侧拿到最新模式。
  Future<void> pushConfigToNative() async {
    final bytes = _backgroundImageBytes;
    // 只在虚拟背景图模式携带图片字节;且仅当字节自上次下发后变化时才带,
    // 否则切模糊/纯色/摄像头 restart 等无关操作也会把 MB 级图重过通道
    // (编解码双侧拷贝,复审 P2)。
    final needImage = _config.backgroundMode == BackgroundMode.virtualBackground &&
        bytes != null;
    final sig = bytes == null
        ? null
        : bytes.length ^ (bytes.first << 8) ^ bytes.last;
    final changed = sig != _sentImageSignature;

    await _safeNative('setBackgroundConfig', <String, dynamic>{
      'mode': _config.backgroundMode.name,
      'blurRadius': _config.backgroundBlurRadius,
      'solidColor': _config.backgroundProcessing.solidColor,
      'hasBackgroundImage': bytes != null,
      // 实际图片字节（原生按 `backgroundImageBytes as? ByteArray` 取，
      // Flutter 的 Uint8List 经 MethodChannel 自动映射为 Kotlin ByteArray）。
      // 仅在需要且变化时携带,否则传 null,原生保留上次已缓存的图。
      if (needImage && changed) 'backgroundImageBytes': bytes,
      'beauty': _config.beautyStrength,
      // 本地相机轨道 id：原生据此定位 libwebrtc VideoSource 挂处理器
      // （见 docs/virtual-background-frame-injection.md §3.4）。
      'trackId': _sourceTrack?.id,
    });
    if (needImage && changed) _sentImageSignature = sig;
  }

  Future<void> _safeNative(String method, [Object? args]) async {
    if (kIsWeb) return;
    try {
      await _nativeChannel.invokeMethod<void>(method, args);
    } on MissingPluginException {
      // 原生 frame processor 未实现：优雅降级（发布轨道仍透传）
    } catch (e) {
      debugLog('VoipCameraProcessor: native $method failed: $e');
    }
  }

  /// 透传源轨道。
  ///
  /// flutter_webrtc 暂未向 Dart 暴露摄像头轨道逐帧回调，无法在纯 Dart 侧把
  /// [VirtualBackgroundEngine] 的合成帧重新编码为 WebRTC 轨道。因此发布轨道
  /// 维持源轨道，背景效果落在本地自视图预览（用 [renderFrame]）。
  /// 真正的发布侧替换由原生 frame processor 完成——配置经 [_nativeChannel]
  /// 下发（[pushConfigToNative]），原生接好即对发布帧生效；当前为透传。
  @override
  MediaStreamTrack? get processedTrack => _sourceTrack;

  /// 对给定帧应用当前背景配置（供本地预览 / 单帧场景调用）。
  ///
  /// 这是**真实可用**的合成路径：本地自视图可周期性抓帧调用本方法渲染。
  Future<Uint8List> renderFrame(Uint8List frameBytes) {
    return VirtualBackgroundEngine.renderComposite(
      frameBytes,
      mode: _config.backgroundMode,
      blurRadius: _config.backgroundBlurRadius,
      solidColorHex: _config.backgroundProcessing.solidColor,
      backgroundImageBytes: _backgroundImageBytes,
      beautyStrength: _config.beautyStrength,
    );
  }
}
