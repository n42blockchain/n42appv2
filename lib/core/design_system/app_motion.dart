import 'package:flutter/animation.dart';

/// 动效令牌。见 `docs/DESIGN_SYSTEM.md` §1.7。
///
/// 动效服务于反馈，不做无意义循环动画。
abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 150); // 点击反馈、开关
  static const Duration base = Duration(milliseconds: 250); // 页面 / 弹窗入场
  static const Duration slow = Duration(milliseconds: 400); // 飘心、强调

  static const Curve curveStandard = Curves.easeInOut; // 默认
  static const Curve curveEnter = Curves.easeOut; // 入场
  static const Curve curveEmphasized = Curves.easeInOutCubic; // 强调
}
