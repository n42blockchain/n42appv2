import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// WCAG 2.x contrast helpers used to derive text-safe shades of the brand
/// accent. The accent is user-customisable, so these shades are computed
/// rather than hard-coded: hue and saturation are kept, and only the HSL
/// lightness moves (in 0.5% steps) until the requested ratio is reached.
abstract final class AppContrast {
  /// Minimum ratio for body-size text (WCAG 1.4.3 AA).
  static const double minText = 4.5;

  /// Highest tint alpha that [textOnTint] guarantees by default; covers the
  /// 8%-15% brand tints used by chips, tags and selected rows.
  static const double maxTintAlpha = 0.15;

  static const Color _white = Color(0xFFFFFFFF);

  /// WCAG contrast ratio between two opaque colors (1.0 - 21.0).
  static double ratio(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
  }

  /// Shifts the lightness of [color] (darker when [darken], else lighter)
  /// until it reaches [min] against every color in [backgrounds]. Returns
  /// [color] unchanged when it already passes.
  static Color ensure(
    Color color,
    List<Color> backgrounds, {
    required bool darken,
    double min = minText,
  }) {
    bool passes(Color c) => backgrounds.every((b) => ratio(c, b) >= min);
    if (passes(color)) return color;
    var hsl = HSLColor.fromColor(color);
    var result = color;
    while (!passes(result)) {
      final lightness = hsl.lightness + (darken ? -0.005 : 0.005);
      if (lightness < 0 || lightness > 1) break;
      hsl = hsl.withLightness(lightness);
      result = hsl.toColor();
    }
    return result;
  }

  /// Fill shade of [brand] that carries white text at >= 4.5:1. When
  /// [whiteOverlay] > 0 the text also sits on that much white layered over
  /// the fill (e.g. translucent pills on a brand card), and that composite
  /// must reach 4.5:1 as well.
  static Color fillForWhiteText(Color brand, {double whiteOverlay = 0}) {
    bool passes(Color fill) {
      final top = whiteOverlay > 0
          ? Color.alphaBlend(_white.withValues(alpha: whiteOverlay), fill)
          : fill;
      return ratio(top, _white) >= minText;
    }

    var hsl = HSLColor.fromColor(brand);
    var result = brand;
    while (!passes(result) && hsl.lightness > 0) {
      hsl = hsl.withLightness(math.max(0, hsl.lightness - 0.005));
      result = hsl.toColor();
    }
    return result;
  }

  /// Text shade of [brand] for labels drawn on a [brand] tint of up to
  /// [alpha] over any of [surfaces]: darker in light mode, lighter in dark.
  static Color textOnTint(
    Color brand,
    List<Color> surfaces, {
    required bool dark,
    double alpha = maxTintAlpha,
  }) {
    final tint = brand.withValues(alpha: alpha);
    return ensure(brand, [
      for (final surface in surfaces) Color.alphaBlend(tint, surface),
    ], darken: !dark);
  }
}
