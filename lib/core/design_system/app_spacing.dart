import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 间距令牌（8pt 网格，750 设计基准）。见 `docs/DESIGN_SYSTEM.md` §1.4。
///
/// 业务代码禁止再写硬编码 `EdgeInsets` / `SizedBox` 数值；统一引用本类。
/// 数值为 `.w`（按宽度等比缩放，与项目既有 `setWidth` 惯例一致），
/// 括号内为 375 基准下的等效 dp。
abstract final class AppSpacing {
  static double get space2 => 8.w; // ≈4dp 图标与文字、紧凑内距
  static double get space4 => 16.w; // ≈8dp 元素最小间距
  static double get space6 => 24.w; // ≈12dp 卡片内距、行距
  static double get space8 => 32.w; // ≈16dp 标准页边距、卡片间距
  static double get space12 => 48.w; // ≈24dp 区块间距
  static double get space16 => 64.w; // ≈32dp 大区块、空状态留白

  /// 标准页面水平内距。
  static EdgeInsets get pageHorizontal =>
      EdgeInsets.symmetric(horizontal: space8);

  /// 标准卡片内距。
  static EdgeInsets get cardInset =>
      EdgeInsets.symmetric(horizontal: space6, vertical: space6);
}
