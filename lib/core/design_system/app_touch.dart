import 'dart:math' as math;

import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Tap-target sizes for layouts drawn on the 750-px ScreenUtil design grid.
///
/// `ScreenUtil().setWidth(88)` is 44pt only on a 375pt-wide screen; it
/// shrinks to 37.5pt at 320pt. Hit areas must never drop below the 44pt
/// minimum (HIG accessibility / layout), so scaled sizes are clamped here.
abstract final class AppTouch {
  /// Minimum hit area in logical points.
  static const double minTarget = 44;

  /// The standard 88-design-px hit area, never below [minTarget].
  static double get target => scaled(88);

  /// [designPx] on the ScreenUtil grid, never below [minTarget].
  static double scaled(double designPx) =>
      math.max(ScreenUtil().setWidth(designPx), minTarget);
}
