import 'dart:async';
import 'dart:io' as io;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import 'package:image/image.dart' as img;

import '../../../domain/entities/call_enhancement_settings.dart';
import '../../../core/utils/debug_log.dart';

/// 虚拟背景帧处理器。
///
/// 使用 Google ML Kit Selfie Segmentation 提取人像 mask，
/// 对背景区域施加模糊或替换为指定图片。
///
/// 处理流程（每帧）：
/// 1. 将摄像头帧转为 [InputImage]
/// 2. ML Kit 返回 [SegmentationMask]（置信度 0-1 浮点矩阵）
/// 3. 基于 mask + [VirtualBackground] 设置合成输出帧
/// 4. 返回合成后的 RGBA bytes
///
/// 性能注意：
/// - ML Kit selfie segmentation 在 GPU 模式下 ~15ms/帧（中端机）
/// - 帧率自适应：如果处理时间 > 目标帧间隔，自动跳帧
/// - 建议通话分辨率降至 480p 以保证流畅
class VirtualBackgroundProcessor {
  VirtualBackgroundProcessor();

  SelfieSegmenter? _segmenter;
  VirtualBackground _background = const VirtualBackground.none();
  img.Image? _backgroundImage;
  bool _processing = false;
  int _processedFrames = 0;
  int _skippedFrames = 0;

  /// 每秒最大处理帧数。超过此数的帧会被跳过。
  int maxFps = 15;

  DateTime _lastProcessTime = DateTime.now();

  bool get isActive => _background is! VirtualBackgroundNone;
  int get processedFrames => _processedFrames;
  int get skippedFrames => _skippedFrames;

  /// 初始化 segmenter（首次通话时延迟创建）。
  Future<void> initialize() async {
    if (_segmenter != null) return;
    _segmenter = SelfieSegmenter(
      mode: SegmenterMode.stream,
      enableRawSizeMask: true,
    );
    debugLog('VirtualBackground: SelfieSegmenter initialized');
  }

  /// 更新虚拟背景设置。
  Future<void> updateBackground(VirtualBackground background) async {
    _background = background;
    _backgroundImage = null;

    if (background is VirtualBackgroundImage) {
      try {
        final bytes = await _loadImageFile(background.assetOrFilePath);
        if (bytes != null) {
          _backgroundImage = img.decodeImage(bytes);
        }
      } catch (e) {
        debugLog('VirtualBackground: Failed to load bg image: $e');
      }
    }
  }

  /// 处理一帧摄像头画面。
  ///
  /// [frameBytes] RGBA 原始像素数据。
  /// [width] / [height] 帧尺寸。
  /// 返回合成后的 RGBA bytes，或 null 表示跳帧。
  Future<Uint8List?> processFrame({
    required Uint8List frameBytes,
    required int width,
    required int height,
  }) async {
    if (!isActive || _segmenter == null) return null;
    if (_processing) {
      _skippedFrames++;
      return null;
    }

    // 帧率限制
    final now = DateTime.now();
    final elapsed = now.difference(_lastProcessTime).inMilliseconds;
    if (elapsed < (1000 ~/ maxFps)) {
      _skippedFrames++;
      return null;
    }

    _processing = true;
    _lastProcessTime = now;

    try {
      // 构造 InputImage
      final inputImage = InputImage.fromBytes(
        bytes: frameBytes,
        metadata: InputImageMetadata(
          size: ui.Size(width.toDouble(), height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.bgra8888,
          bytesPerRow: width * 4,
        ),
      );

      // 分割
      final mask = await _segmenter!.processImage(inputImage);

      if (mask == null) return null;

      // 合成
      final result = await compute(
        _compositeFrame,
        _CompositeParams(
          frameBytes: frameBytes,
          width: width,
          height: height,
          maskConfidences: mask.confidences,
          maskWidth: mask.width,
          maskHeight: mask.height,
          background: _background,
          bgImageBytes: _backgroundImage != null
              ? Uint8List.fromList(img.encodePng(_backgroundImage!))
              : null,
          bgImageWidth: _backgroundImage?.width,
          bgImageHeight: _backgroundImage?.height,
        ),
      );

      _processedFrames++;
      return result;
    } catch (e) {
      debugLog('VirtualBackground: processFrame error: $e');
      return null;
    } finally {
      _processing = false;
    }
  }

  /// 释放资源。
  Future<void> dispose() async {
    await _segmenter?.close();
    _segmenter = null;
    _backgroundImage = null;
    debugLog('VirtualBackground: disposed (processed=$_processedFrames, skipped=$_skippedFrames)');
  }

  Future<Uint8List?> _loadImageFile(String path) async {
    try {
      final file = io.File(path);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

/// Isolate 中运行的帧合成函数（避免阻塞 UI 线程）。
Uint8List _compositeFrame(_CompositeParams params) {
  final w = params.width;
  final h = params.height;
  final result = Uint8List(w * h * 4);
  final frame = params.frameBytes;
  final confidences = params.maskConfidences;
  final mw = params.maskWidth;
  final mh = params.maskHeight;

  // 预计算模糊源（仅 blur 模式需要）
  Uint8List? blurred;
  if (params.background is VirtualBackgroundBlur) {
    final sigma = (params.background as VirtualBackgroundBlur).sigma;
    blurred = _gaussianBlurRGBA(frame, w, h, sigma.toInt().clamp(1, 20));
  }

  // 背景图像解码（image 模式）
  img.Image? bgImg;
  if (params.background is VirtualBackgroundImage && params.bgImageBytes != null) {
    bgImg = img.decodeImage(params.bgImageBytes!);
    if (bgImg != null &&
        (bgImg.width != w || bgImg.height != h)) {
      bgImg = img.copyResize(bgImg, width: w, height: h);
    }
  }

  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      final pixelIdx = (y * w + x) * 4;

      // mask 坐标映射（mask 可能与帧尺寸不同）
      final mx = (x * mw / w).clamp(0, mw - 1).toInt();
      final my = (y * mh / h).clamp(0, mh - 1).toInt();
      final confidence = confidences[my * mw + mx];

      // confidence > 0.7 → 人像（保留原始帧），否则 → 背景（替换）
      final alpha = confidence.clamp(0.0, 1.0);

      if (alpha > 0.7) {
        // 人像区域：直接使用原始帧
        result[pixelIdx] = frame[pixelIdx];
        result[pixelIdx + 1] = frame[pixelIdx + 1];
        result[pixelIdx + 2] = frame[pixelIdx + 2];
        result[pixelIdx + 3] = frame[pixelIdx + 3];
      } else {
        // 背景区域
        int bgR, bgG, bgB, bgA;

        if (blurred != null) {
          bgR = blurred[pixelIdx];
          bgG = blurred[pixelIdx + 1];
          bgB = blurred[pixelIdx + 2];
          bgA = blurred[pixelIdx + 3];
        } else if (bgImg != null) {
          final pixel = bgImg.getPixel(x, y);
          bgR = pixel.r.toInt();
          bgG = pixel.g.toInt();
          bgB = pixel.b.toInt();
          bgA = 255;
        } else {
          // fallback: 纯色深灰
          bgR = 30;
          bgG = 30;
          bgB = 30;
          bgA = 255;
        }

        // 边缘过渡混合（0.3~0.7 之间做 alpha blend）
        if (alpha > 0.3) {
          final t = (alpha - 0.3) / 0.4; // 0→1
          result[pixelIdx] = _lerp(bgR, frame[pixelIdx], t);
          result[pixelIdx + 1] = _lerp(bgG, frame[pixelIdx + 1], t);
          result[pixelIdx + 2] = _lerp(bgB, frame[pixelIdx + 2], t);
          result[pixelIdx + 3] = 255;
        } else {
          result[pixelIdx] = bgR;
          result[pixelIdx + 1] = bgG;
          result[pixelIdx + 2] = bgB;
          result[pixelIdx + 3] = bgA;
        }
      }
    }
  }

  return result;
}

int _lerp(int a, int b, double t) =>
    (a + (b - a) * t).round().clamp(0, 255);

/// 简化高斯模糊（box blur 多轮近似）。
Uint8List _gaussianBlurRGBA(Uint8List src, int w, int h, int radius) {
  final result = Uint8List.fromList(src);
  // 3 轮 box blur ≈ gaussian blur
  for (int pass = 0; pass < 3; pass++) {
    _boxBlurH(result, w, h, radius);
    _boxBlurV(result, w, h, radius);
  }
  return result;
}

void _boxBlurH(Uint8List data, int w, int h, int r) {
  for (int y = 0; y < h; y++) {
    int rSum = 0, gSum = 0, bSum = 0;
    final count = r * 2 + 1;

    for (int x = 0; x < count.clamp(0, w); x++) {
      final i = (y * w + x) * 4;
      rSum += data[i];
      gSum += data[i + 1];
      bSum += data[i + 2];
    }

    for (int x = 0; x < w; x++) {
      final i = (y * w + x) * 4;
      data[i] = (rSum ~/ count).clamp(0, 255);
      data[i + 1] = (gSum ~/ count).clamp(0, 255);
      data[i + 2] = (bSum ~/ count).clamp(0, 255);

      final addX = (x + r + 1).clamp(0, w - 1);
      final subX = (x - r).clamp(0, w - 1);
      final addI = (y * w + addX) * 4;
      final subI = (y * w + subX) * 4;
      rSum += data[addI] - data[subI];
      gSum += data[addI + 1] - data[subI + 1];
      bSum += data[addI + 2] - data[subI + 2];
    }
  }
}

void _boxBlurV(Uint8List data, int w, int h, int r) {
  for (int x = 0; x < w; x++) {
    int rSum = 0, gSum = 0, bSum = 0;
    final count = r * 2 + 1;

    for (int y = 0; y < count.clamp(0, h); y++) {
      final i = (y * w + x) * 4;
      rSum += data[i];
      gSum += data[i + 1];
      bSum += data[i + 2];
    }

    for (int y = 0; y < h; y++) {
      final i = (y * w + x) * 4;
      data[i] = (rSum ~/ count).clamp(0, 255);
      data[i + 1] = (gSum ~/ count).clamp(0, 255);
      data[i + 2] = (bSum ~/ count).clamp(0, 255);

      final addY = (y + r + 1).clamp(0, h - 1);
      final subY = (y - r).clamp(0, h - 1);
      final addI = (addY * w + x) * 4;
      final subI = (subY * w + x) * 4;
      rSum += data[addI] - data[subI];
      gSum += data[addI + 1] - data[subI + 1];
      bSum += data[addI + 2] - data[subI + 2];
    }
  }
}

/// Isolate 通信参数。
class _CompositeParams {
  final Uint8List frameBytes;
  final int width;
  final int height;
  final List<double> maskConfidences;
  final int maskWidth;
  final int maskHeight;
  final VirtualBackground background;
  final Uint8List? bgImageBytes;
  final int? bgImageWidth;
  final int? bgImageHeight;

  const _CompositeParams({
    required this.frameBytes,
    required this.width,
    required this.height,
    required this.maskConfidences,
    required this.maskWidth,
    required this.maskHeight,
    required this.background,
    this.bgImageBytes,
    this.bgImageWidth,
    this.bgImageHeight,
  });
}
