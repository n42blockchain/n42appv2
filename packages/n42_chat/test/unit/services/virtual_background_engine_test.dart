import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:n42_chat/src/services/voip/virtual_background_processor.dart';
import 'package:n42_chat/src/services/voip/voip_config.dart';

/// 生成纯色 PNG（无损，作为合成输入）
Uint8List _solidPng(int w, int h, int r, int g, int b) {
  final im = img.Image(width: w, height: h);
  img.fill(im, color: img.ColorRgb8(r, g, b));
  return Uint8List.fromList(img.encodePng(im));
}

/// 左右分块：左半 [lr,lg,lb]，右半 [rr,rg,rb]
Uint8List _splitPng(
  int w,
  int h,
  List<int> left,
  List<int> right,
) {
  final im = img.Image(width: w, height: h);
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final c = x < w ~/ 2 ? left : right;
      im.setPixel(x, y, img.ColorRgb8(c[0], c[1], c[2]));
    }
  }
  return Uint8List.fromList(img.encodePng(im));
}

/// 左半前景(conf=1)、右半背景(conf=0) 的 mask
List<double> _leftForegroundMask(int w, int h) {
  final m = List<double>.filled(w * h, 0);
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      m[y * w + x] = x < w ~/ 2 ? 1.0 : 0.0;
    }
  }
  return m;
}

img.Image _decode(Uint8List bytes) => img.decodeImage(bytes)!;

int _r(img.Pixel p) => p.r.toInt();
int _g(img.Pixel p) => p.g.toInt();
int _b(img.Pixel p) => p.b.toInt();

void main() {
  const w = 32, h = 32;

  test('foregroundThreshold 暴露且在 (0,1)', () {
    expect(VirtualBackgroundEngine.foregroundThreshold, greaterThan(0));
    expect(VirtualBackgroundEngine.foregroundThreshold, lessThan(1));
  });

  test('solidColor：前景保留原图、背景替换为指定色', () {
    // 整幅红色原图；左半前景、右半背景；背景填蓝
    final frame = _solidPng(w, h, 255, 0, 0);
    final out = VirtualBackgroundEngine.composeFrame(
      frame,
      maskWidth: w,
      maskHeight: h,
      confidences: _leftForegroundMask(w, h),
      mode: BackgroundMode.solidColor,
      solidColorHex: '#0000FF',
    );
    final im = _decode(out);
    final fg = im.getPixel(2, 8); // 左半（前景）
    final bg = im.getPixel(w - 2, 8); // 右半（背景）
    // 前景仍偏红
    expect(_r(fg), greaterThan(_b(fg)));
    // 背景被替换为偏蓝
    expect(_b(bg), greaterThan(_r(bg)));
  });

  test('virtualBackground：背景替换为给定背景图', () {
    final frame = _solidPng(w, h, 255, 0, 0); // 红
    final greenBg = _solidPng(w, h, 0, 255, 0); // 绿背景
    final out = VirtualBackgroundEngine.composeFrame(
      frame,
      maskWidth: w,
      maskHeight: h,
      confidences: _leftForegroundMask(w, h),
      mode: BackgroundMode.virtualBackground,
      backgroundImageBytes: greenBg,
    );
    final im = _decode(out);
    final fg = im.getPixel(2, 8);
    final bg = im.getPixel(w - 2, 8);
    expect(_r(fg), greaterThan(_g(fg))); // 前景仍红
    expect(_g(bg), greaterThan(_r(bg))); // 背景变绿
  });

  test('全前景 mask：整幅保留原图（不应用背景）', () {
    final frame = _solidPng(w, h, 255, 0, 0);
    final allFg = List<double>.filled(w * h, 1.0);
    final out = VirtualBackgroundEngine.composeFrame(
      frame,
      maskWidth: w,
      maskHeight: h,
      confidences: allFg,
      mode: BackgroundMode.solidColor,
      solidColorHex: '#0000FF',
    );
    final im = _decode(out);
    final c = im.getPixel(w ~/ 2, h ~/ 2);
    expect(_r(c), greaterThan(_b(c))); // 仍红，背景未生效
  });

  test('blur：全背景 mask 下高对比边界被平滑（混入邻域）', () {
    // 左半黑、右半白，全背景 → 整幅模糊；边界列应出现中间灰
    final frame = _splitPng(w, h, [0, 0, 0], [255, 255, 255]);
    final allBg = List<double>.filled(w * h, 0.0);
    final out = VirtualBackgroundEngine.composeFrame(
      frame,
      maskWidth: w,
      maskHeight: h,
      confidences: allBg,
      mode: BackgroundMode.blur,
      blurRadius: 1.0,
    );
    final im = _decode(out);
    // 边界列附近（x≈w/2）应被模糊为中间灰，而非纯黑/纯白
    final boundary = im.getPixel(w ~/ 2, h ~/ 2);
    final lum = (_r(boundary) + _g(boundary) + _b(boundary)) ~/ 3;
    expect(lum, greaterThan(30));
    expect(lum, lessThan(225));
  });

  test('none 模式：原样返回输入字节', () {
    final frame = _solidPng(w, h, 10, 20, 30);
    final out = VirtualBackgroundEngine.composeFrame(
      frame,
      maskWidth: w,
      maskHeight: h,
      confidences: List<double>.filled(w * h, 0),
      mode: BackgroundMode.none,
    );
    expect(out, same(frame));
  });

  group('美颜 (#18)', () {
    test('mode none + beauty=0 直接透传原字节', () {
      final frame = _solidPng(w, h, 128, 128, 128);
      final out = VirtualBackgroundEngine.composeFrame(
        frame,
        maskWidth: w,
        maskHeight: h,
        confidences: _leftForegroundMask(w, h),
        mode: BackgroundMode.none,
        beautyStrength: 0,
      );
      expect(out, same(frame));
    });

    test('beauty 提亮人像区域，背景区域不变（mode none）', () {
      final frame = _solidPng(w, h, 128, 128, 128);
      final out = _decode(
        VirtualBackgroundEngine.composeFrame(
          frame,
          maskWidth: w,
          maskHeight: h,
          confidences: _leftForegroundMask(w, h), // 左前景右背景
          mode: BackgroundMode.none,
          beautyStrength: 1.0,
        ),
      );
      final person = out.getPixel(2, 2);
      final bg = out.getPixel(w - 2, 2);
      expect(_r(person), greaterThan(132)); // 人像提亮
      expect((_r(bg) - 128).abs(), lessThanOrEqualTo(4)); // 背景未替换
    });

    test('beauty 与背景替换可叠加', () {
      final frame = _solidPng(w, h, 128, 128, 128);
      final out = _decode(
        VirtualBackgroundEngine.composeFrame(
          frame,
          maskWidth: w,
          maskHeight: h,
          confidences: _leftForegroundMask(w, h),
          mode: BackgroundMode.solidColor,
          solidColorHex: '#0000FF',
          beautyStrength: 1.0,
        ),
      );
      final person = out.getPixel(2, 2);
      final bg = out.getPixel(w - 2, 2);
      expect(_b(bg), greaterThan(200)); // 背景替换为蓝
      expect(_r(bg), lessThan(60));
      expect(_r(person), greaterThan(132)); // 人像提亮
    });
  });
}
