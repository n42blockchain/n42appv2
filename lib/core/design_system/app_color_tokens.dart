import 'package:flutter/material.dart';

import '../../presentation/themes/theme_adapter.dart';

/// 语义颜色令牌。见 `docs/DESIGN_SYSTEM.md` §1.1 / §1.2。
///
/// 分两组：
/// - **随主题色（实例 getter，需 context）**：普通页面 / 模态使用，亮暗自动切换。
///   封装现有 [AppThemeKeys] 主题表为语义层，保证迁移**零视觉断层**。
/// - **固定叠层色（static const）**：直播 / 图片上的叠层语境——背景永远深色，
///   前景必须固定为亮色，**不能**随 app 主题变（否则亮色主题下叠层文字会变黑、
///   在视频上不可见）。直播间 top bar / 弹幕 / 侧栏 / 预测卡等一律用这组。
///
/// 用法：
/// ```dart
/// // 普通页 / 模态（随主题）
/// final c = AppColorTokens.of(context);
/// Container(color: c.bgSurface, child: Text('x', style: TextStyle(color: c.textPrimary)));
///
/// // 直播叠层（固定深色语境）
/// Container(color: AppColorTokens.overlay,
///   child: Text('x', style: TextStyle(color: AppColorTokens.onOverlayPrimary)));
/// ```
class AppColorTokens {
  const AppColorTokens(this._context, this._isDark);

  factory AppColorTokens.of(BuildContext context) =>
      AppColorTokens(context, Theme.of(context).brightness == Brightness.dark);

  final BuildContext _context;
  final bool _isDark;

  Color _key(AppThemeKeys k) => AppThemeUtils.getColorByKey(_context, k.name);
  Color _tone(Color light, Color dark) => _isDark ? dark : light;

  // ════════ 随主题色（普通页 / 模态）════════

  // ── 品牌 ──
  // mainBlueColor 经 colorScheme.primary 解析，自动反映用户自定义 accent。
  Color get brand => _key(AppThemeKeys.mainBlueColor);
  Color get brandSubtle =>
      _tone(const Color(0xFFE8F1FE), const Color(0xFF16365E));

  // ── 语义（复用现有表，缺失者补常量）──
  Color get success => _key(AppThemeKeys.rightTextColor); // #44A677
  Color get danger => _key(AppThemeKeys.errorTextColor); // #F03450
  Color get warning => _key(AppThemeKeys.textColorOrange); // #FF6F16
  Color get info => _tone(const Color(0xFF2E90FA), const Color(0xFF52A6FF));

  // ── 中性分层 ──
  Color get bgBase => _key(AppThemeKeys.backGroundColor);
  Color get bgSurface => _key(AppThemeKeys.itemBgColor);
  Color get bgElevated =>
      _tone(const Color(0xFFFFFFFF), const Color(0xFF1E212B));
  Color get border => _key(AppThemeKeys.dividerColor);
  Color get textPrimary => _key(AppThemeKeys.mainTextColor);
  Color get textSecondary =>
      _key(AppThemeKeys.mainTextColor6); // light #5C616D / dark #BEBEBE
  Color get textTertiary => _key(AppThemeKeys.mainTextColor4); // #8A8A8E

  // ── 聊天专用（勿外溢到钱包 / 直播）──
  Color get chatBubbleSelf =>
      _tone(const Color(0xFF95EC69), const Color(0xFF3EB575));

  // ════════ 固定叠层色（直播 / 图片语境，不随主题）════════

  /// 半透明黑叠层（rgba(0,0,0,.55)）——直播间面板 / 标签底。
  static const Color overlay = Color(0x8C000000);

  /// 更深叠层（0.7）——需更高对比时。
  static const Color overlayStrong = Color(0xB3000000);

  /// 叠层前景主文字（固定白）。
  static const Color onOverlayPrimary = Color(0xFFFFFFFF);

  /// 叠层前景次文字（white70）。
  static const Color onOverlaySecondary = Color(0xB3FFFFFF);

  /// 叠层前景弱文字 / 占位（≈white55）。
  static const Color onOverlayTertiary = Color(0x8CFFFFFF);

  /// 叠层细描边（white12）。
  static const Color onOverlayBorder = Color(0x1FFFFFFF);

  // 叠层语境下的语义色（取规范 dark 列定值，保证深背景上对比足够）。
  static const Color brandOnOverlay = Color(0xFF3B8CFF);
  static const Color successOnOverlay = Color(0xFF2ED391);
  static const Color dangerOnOverlay = Color(0xFFFF5C6C);
  static const Color warningOnOverlay = Color(0xFFFFA53D);

  /// 「我的内容」强调金（持仓、自己的弹幕名）——功能性区分，非装饰。
  static const Color highlight = Color(0xFFFFD24D);
}
