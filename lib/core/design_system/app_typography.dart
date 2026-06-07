import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 字阶令牌（.sp，750 设计基准）。见 `docs/DESIGN_SYSTEM.md` §1.3。
///
/// 业务代码禁止再写散落的 `TextStyle(fontSize: N)`；统一引用本类，
/// 颜色按需 `.copyWith(color: AppColorTokens.of(context).textPrimary)`。
/// 字重仅用 w400 / w500 / w600，字体族跟随系统。括号内为 375 基准等效 dp。
abstract final class AppTypography {
  static TextStyle get displayLg => TextStyle(
    fontSize: 48.sp, // ≈24dp 资产总额、开屏大数字
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.5, // 大标题/数字紧排，现代质感
  );

  static TextStyle get titleLg => TextStyle(
    fontSize: 40.sp, // ≈20dp 页面大标题
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.4,
  );

  static TextStyle get title => TextStyle(
    fontSize: 36.sp, // ≈18dp 卡片标题、AppBar
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.3,
  );

  static TextStyle get headline => TextStyle(
    fontSize: 32.sp, // ≈16dp 小节标题、重要项
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.2,
  );

  static TextStyle get body => TextStyle(
    fontSize: 28.sp, // ≈14dp 正文（默认）
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static TextStyle get bodyStrong => TextStyle(
    fontSize: 28.sp, // ≈14dp 正文强调、金额
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static TextStyle get bodySm => TextStyle(
    fontSize: 26.sp, // ≈13dp 次要正文
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static TextStyle get caption => TextStyle(
    fontSize: 24.sp, // ≈12dp 时间戳、辅助
    fontWeight: FontWeight.w400,
    height: 1.3,
  );

  static TextStyle get captionSm => TextStyle(
    fontSize: 20.sp, // ≈10dp 标签、徽章
    fontWeight: FontWeight.w500,
    height: 1.2,
  );
}
