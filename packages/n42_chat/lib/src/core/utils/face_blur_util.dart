import 'dart:io';
import 'dart:ui' show Rect;

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'debug_log.dart';

/// 人脸自动模糊工具类
///
/// 使用 Google ML Kit 检测图片中的人脸区域，
/// 并对检测到的人脸区域进行高斯模糊处理。
///
/// 使用示例：
/// ```dart
/// final blurredBytes = await FaceBlurUtil.blurFaces(imageBytes);
/// ```
class FaceBlurUtil {
  FaceBlurUtil._();

  static FaceDetector? _detector;

  static FaceDetector get _faceDetector {
    _detector ??= FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
        enableLandmarks: false,
        enableClassification: false,
        // 最小人脸尺寸比例（相对于图片）
        minFaceSize: 0.1,
      ),
    );
    return _detector!;
  }

  /// 检测图片中是否有人脸
  ///
  /// 返回 true 表示检测到人脸，false 表示未检测到。
  /// 如果检测过程出错，也返回 false。
  static Future<bool> hasFaces(Uint8List imageBytes) async {
    if (kIsWeb) return false;

    try {
      final faces = await _detectFaces(imageBytes);
      return faces.isNotEmpty;
    } catch (e) {
      debugLog('FaceBlurUtil.hasFaces error: $e');
      return false;
    }
  }

  /// 检测并模糊图片中的人脸
  ///
  /// 如果未检测到人脸，返回原图字节。
  /// [blurRadius] 模糊半径，值越大越模糊，默认 25。
  static Future<Uint8List> blurFaces(
    Uint8List imageBytes, {
    int blurRadius = 25,
  }) async {
    if (kIsWeb) return imageBytes;

    try {
      final faces = await _detectFaces(imageBytes);
      if (faces.isEmpty) {
        debugLog('FaceBlurUtil: No faces detected, returning original image');
        return imageBytes;
      }

      debugLog('FaceBlurUtil: Detected ${faces.length} face(s), applying blur');

      // 在 isolate 中处理图片模糊（避免阻塞 UI 线程）
      return await compute(
        _blurFacesInIsolate,
        _BlurParams(
          imageBytes: imageBytes,
          faceRects: faces.map((f) => _FaceRect.fromRect(f.boundingBox)).toList(),
          blurRadius: blurRadius,
        ),
      );
    } catch (e) {
      debugLog('FaceBlurUtil.blurFaces error: $e');
      return imageBytes;
    }
  }

  /// 检测人脸（内部方法）
  static Future<List<Face>> _detectFaces(Uint8List imageBytes) async {
    // ML Kit 需要文件路径来创建 InputImage
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(
      '${tempDir.path}/face_detect_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    try {
      await tempFile.writeAsBytes(imageBytes);
      final inputImage = InputImage.fromFilePath(tempFile.path);
      final faces = await _faceDetector.processImage(inputImage);
      return faces;
    } finally {
      // 清理临时文件
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }

  /// 在 isolate 中执行人脸模糊（避免阻塞 UI）
  static Uint8List _blurFacesInIsolate(_BlurParams params) {
    final image = img.decodeImage(params.imageBytes);
    if (image == null) return params.imageBytes;

    for (final faceRect in params.faceRects) {
      // 扩大模糊区域（人脸边界外扩 20%），确保完全覆盖
      const expandRatio = 0.2;
      final expandW = (faceRect.width * expandRatio).round();
      final expandH = (faceRect.height * expandRatio).round();

      final x = (faceRect.left - expandW).clamp(0, image.width - 1).round();
      final y = (faceRect.top - expandH).clamp(0, image.height - 1).round();
      final w = (faceRect.width + expandW * 2).clamp(1, image.width - x).round();
      final h = (faceRect.height + expandH * 2).clamp(1, image.height - y).round();

      // 提取人脸区域
      final faceRegion = img.copyCrop(
        image,
        x: x,
        y: y,
        width: w,
        height: h,
      );

      // 对人脸区域进行高斯模糊
      final blurred = img.gaussianBlur(faceRegion, radius: params.blurRadius);

      // 将模糊后的区域写回原图
      img.compositeImage(image, blurred, dstX: x, dstY: y);
    }

    // 编码为 JPEG
    return Uint8List.fromList(img.encodeJpg(image, quality: 90));
  }

  /// 释放资源
  static void dispose() {
    _detector?.close();
    _detector = null;
  }
}

/// 用于在 isolate 间传递的参数
class _BlurParams {
  final Uint8List imageBytes;
  final List<_FaceRect> faceRects;
  final int blurRadius;

  const _BlurParams({
    required this.imageBytes,
    required this.faceRects,
    required this.blurRadius,
  });
}

/// 可序列化的人脸矩形区域（用于 isolate 间传递）
class _FaceRect {
  final double left;
  final double top;
  final double width;
  final double height;

  const _FaceRect({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  factory _FaceRect.fromRect(Rect rect) => _FaceRect(
        left: rect.left,
        top: rect.top,
        width: rect.width,
        height: rect.height,
      );
}
