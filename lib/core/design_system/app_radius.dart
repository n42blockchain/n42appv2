import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 圆角令牌。见 `docs/DESIGN_SYSTEM.md` §1.5。
///
/// 业务代码禁止再写越界的 `BorderRadius.circular(N)`；统一引用本类。
abstract final class AppRadius {
  static double get sm => 8.w; // ≈4dp 标签、徽章、小输入
  static double get md => 16.w; // ≈8dp 二级卡片、图片
  static double get lg => 24.w; // ≈12dp 弹窗内卡片
  static double get xl => 32.w; // ≈16dp 主卡片 / 按钮（标准）
  static double get sheet => 40.w; // ≈20dp BottomSheet / Dialog 顶部
  static const double pill = 999; // 胶囊按钮、头像角标

  static BorderRadius get brSm => BorderRadius.circular(sm);
  static BorderRadius get brMd => BorderRadius.circular(md);
  static BorderRadius get brLg => BorderRadius.circular(lg);
  static BorderRadius get brXl => BorderRadius.circular(xl);
  static BorderRadius get brPill => BorderRadius.circular(pill);

  /// BottomSheet / Dialog 顶部圆角。
  static BorderRadius get brSheetTop =>
      BorderRadius.vertical(top: Radius.circular(sheet));
}
