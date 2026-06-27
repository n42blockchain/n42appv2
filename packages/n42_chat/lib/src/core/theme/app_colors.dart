import 'package:flutter/material.dart';

/// 微信风格颜色配置
///
/// 所有颜色常量都按照微信设计规范定义
abstract class AppColors {
  AppColors._();

  // ============================================
  // 主色调 - 品牌靛蓝 (AI-native, 与主 App 对齐 #5B6CFF)
  // 注意: 微信绿仅保留于消息气泡 / success / 在线 / 加密标识等语义场景,
  //       品牌 CTA / 强调 / 选中 / 焦点 / ripple 统一走品牌靛蓝。
  // ============================================

  /// 主色 - 品牌靛蓝
  static const Color primary = Color(0xFF5B6CFF);

  /// 主色 - 浅色变体
  static const Color primaryLight = Color(0xFF8290FF);

  /// 主色 - 深色变体
  static const Color primaryDark = Color(0xFF4856E6);

  /// 主色 - 透明变体
  static const Color primaryWithOpacity = Color(0x1A5B6CFF);

  // ============================================
  // 背景色
  // ============================================

  /// 页面背景色 - 浅色模式
  static const Color background = Color(0xFFEDEDED);

  /// 页面背景色 - 深色模式
  static const Color backgroundDark = Color(0xFF111111);

  /// 卡片/列表项背景色 - 浅色
  static const Color surface = Color(0xFFFFFFFF);

  /// 卡片/列表项背景色 - 深色
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // ============================================
  // 导航栏
  // ============================================

  /// 导航栏背景 - 浅色
  static const Color navBar = Color(0xFFF7F7F7);

  /// 导航栏背景 - 深色
  static const Color navBarDark = Color(0xFF2C2C2C);

  /// 底部导航栏背景 - 浅色
  static const Color bottomNavBar = Color(0xFFF7F7F7);

  /// 底部导航栏背景 - 深色
  static const Color bottomNavBarDark = Color(0xFF1E1E1E);

  // ============================================
  // 分割线
  // ============================================

  /// 分割线 - 浅色
  static const Color divider = Color(0xFFE5E5E5);

  /// 分割线 - 深色
  static const Color dividerDark = Color(0xFF3D3D3D);

  /// 细分割线 - 浅色
  static const Color dividerThin = Color(0xFFF0F0F0);

  /// 细分割线 - 深色
  static const Color dividerThinDark = Color(0xFF2A2A2A);

  // ============================================
  // 文字颜色
  // ============================================

  /// 主要文字 - 浅色模式
  static const Color textPrimary = Color(0xFF181818);

  /// 主要文字 - 深色模式
  static const Color textPrimaryDark = Color(0xFFE5E5E5);

  /// 次要文字 - 浅色模式
  static const Color textSecondary = Color(0xFF888888);

  /// 次要文字 - 深色模式
  static const Color textSecondaryDark = Color(0xFFAAAAAA);

  /// 辅助文字 - 浅色模式
  static const Color textTertiary = Color(0xFFB2B2B2);

  /// 辅助文字 - 深色模式（比 textSecondaryDark 浅一档，避免与之同色失去层次）
  static const Color textTertiaryDark = Color(0xFF6B6B6B);

  /// 禁用文字 - 浅色
  static const Color textDisabled = Color(0xFFCCCCCC);

  /// 禁用文字 - 深色
  static const Color textDisabledDark = Color(0xFF555555);

  /// 链接颜色（textLink 是别名，新代码请用 link）
  static const Color link = Color(0xFF576B95);
  @Deprecated('Use AppColors.link')
  static const Color textLink = link;

  // ============================================
  // 消息气泡
  // ============================================

  /// 发送消息气泡 - 浅色 (微信绿)
  static const Color bubbleSelf = Color(0xFF95EC69);

  /// 发送消息气泡 - 深色
  static const Color bubbleSelfDark = Color(0xFF3EB575);

  /// 接收消息气泡 - 浅色
  static const Color bubbleOther = Color(0xFFFFFFFF);

  /// 接收消息气泡 - 深色（比 backgroundDark 浅一档，保证可视边界）
  static const Color bubbleOtherDark = Color(0xFF262626);

  /// 消息文字 - 发送方（深浅都用黑——亮绿气泡上黑字最清晰）
  static const Color messageTextSent = Color(0xFF000000);

  /// 消息文字 - 接收方（白底黑字 / 深底白字由 messageTextReceived* 切换）
  static const Color messageTextReceived = Color(0xFF181818);

  /// 接收消息文字 - 深色
  static const Color messageTextReceivedDark = Color(0xFFE5E5E5);

  // 旧别名（保留为弃用兼容）
  @Deprecated('Use AppColors.bubbleSelf')
  static const Color messageSent = bubbleSelf;
  @Deprecated('Use AppColors.bubbleOther')
  static const Color messageReceived = bubbleOther;
  @Deprecated('Use AppColors.bubbleSelfDark')
  static const Color messageSentDark = bubbleSelfDark;
  @Deprecated('Use AppColors.bubbleOtherDark')
  static const Color messageReceivedDark = bubbleOtherDark;

  /// 自己气泡颜色（微信风格：浅色亮绿，深色暗绿）
  static Color selfBubble(bool isDark) => isDark ? bubbleSelfDark : bubbleSelf;

  /// 发送消息文字颜色（微信风格：始终黑色，不论深浅模式）
  static Color sentText(bool isDark) => messageTextSent;

  /// 接收消息文字颜色（深浅模式自适应）
  static Color receivedText(bool isDark) =>
      isDark ? messageTextReceivedDark : messageTextReceived;

  // ============================================
  // 状态颜色
  // ============================================

  /// 错误/危险
  static const Color error = Color(0xFFFA5151);

  /// 错误背景（浅色淡红，用于 SnackBar / 错误提示框等）
  static const Color errorBg = Color(0x14FA5151);

  /// 警告
  static const Color warning = Color(0xFFFF9900);

  /// 警告背景
  static const Color warningBg = Color(0x14FF9900);

  /// 成功（对齐设计系统 success 绿 #1FB67A，§1.1；微信绿仅保留给聊天气泡）
  static const Color success = Color(0xFF1FB67A);

  /// 成功背景
  static const Color successBg = Color(0x141FB67A);

  /// 信息
  static const Color info = Color(0xFF10AEFF);

  /// 信息背景
  static const Color infoBg = Color(0x1410AEFF);

  // ============================================
  // 徽章/红点
  // ============================================

  /// 红点徽章
  static const Color badge = Color(0xFFFA5151);

  /// 免打扰标识
  static const Color muted = Color(0xFFCCCCCC);

  // ============================================
  // 输入框
  // ============================================

  /// 输入框背景
  static const Color inputBackground = Color(0xFFF7F7F7);

  /// 输入框边框
  static const Color inputBorder = Color(0xFFE5E5E5);

  /// 输入框焦点边框 (品牌强调)
  static const Color inputFocusBorder = Color(0xFF5B6CFF);

  /// 搜索框背景
  static const Color searchBackground = Color(0xFFEDEDED);

  /// 输入栏背景 - 浅色
  static const Color inputBar = Color(0xFFF7F7F7);

  /// 输入栏背景 - 深色
  static const Color inputBarDark = Color(0xFF2C2C2C);

  // ============================================
  // 遮罩/覆盖层
  // ============================================

  /// 半透明遮罩
  static const Color overlay = Color(0x80000000);

  /// 浅色遮罩
  static const Color overlayLight = Color(0x33000000);

  /// 图片加载占位背景 - 浅色
  static const Color placeholder = Color(0xFFE5E5E5);

  /// 图片加载占位背景 - 深色
  static const Color placeholderDark = Color(0xFF2A2A2A);

  /// 卡片浅阴影色（elevation 替代——AppBar 边界 / 浮层）
  static const Color cardShadow = Color(0x0F000000);

  // ============================================
  // 特殊用途
  // ============================================

  /// 在线状态（对齐设计系统 success 绿 #1FB67A，§1.1）
  static const Color online = Color(0xFF1FB67A);

  /// 离线状态
  static const Color offline = Color(0xFFCCCCCC);

  /// 选中状态 (品牌强调)
  static const Color selected = Color(0x1A5B6CFF);

  /// 品牌 ripple/highlight（带主色调的 InkWell 反馈）
  static const Color brandRipple10 = Color(0x1A5B6CFF);
  static const Color brandRipple05 = Color(0x0D5B6CFF);

  /// 按压状态 - 浅色
  static const Color pressed = Color(0x0D000000);

  /// 按压状态 - 深色
  static const Color pressedDark = Color(0x1FFFFFFF);

  /// 加密标识（对齐设计系统 success 绿 #1FB67A，§1.1）
  static const Color encrypted = Color(0xFF1FB67A);

  /// 红包
  static const Color redPacket = Color(0xFFFD9B2D);

  /// 时间分隔器文字（已弃用背景色，改为纯文字）
  static const Color timeSeparator = Color(0xFF808080);

  // ============================================
  // 主题解析器 (Theme resolvers)
  // 设计文档 §3：消除散落的 `isDark ? light : dark` 三元，统一走命名令牌解析。
  // 暗色采用设计系统既定档（如主文字 #E5E5E5 而非纯白、辅助文字 #6B6B6B），
  // 故个别站点从裸 white/black/grey[N]/inline-hex 归一到这些档会有细微但合规的位移。
  // 仅用于「成对语义色」；纯 alpha 调节(primary.withValues)/非色值(brightness/elevation) 不在此列。
  // ============================================

  /// 页面背景：浅 #EDEDED / 深 #111111
  static Color bgOf(bool isDark) => isDark ? backgroundDark : background;

  /// 卡片 / Sheet / 弹层表面：浅 #FFFFFF / 深 #1E1E1E
  static Color surfaceOf(bool isDark) => isDark ? surfaceDark : surface;

  /// 主文字：浅 #181818 / 深 #E5E5E5
  static Color textPrimaryOf(bool isDark) => isDark ? textPrimaryDark : textPrimary;

  /// 次要文字：浅 #888888 / 深 #AAAAAA
  static Color textSecondaryOf(bool isDark) =>
      isDark ? textSecondaryDark : textSecondary;

  /// 辅助 / 占位 / hint 文字：浅 #B2B2B2 / 深 #6B6B6B
  static Color textTertiaryOf(bool isDark) =>
      isDark ? textTertiaryDark : textTertiary;

  /// 分隔线 / 描边：浅 #E5E5E5 / 深 #3D3D3D
  static Color dividerOf(bool isDark) => isDark ? dividerDark : divider;

  /// 细分隔线：浅 #F0F0F0 / 深 #2A2A2A
  static Color dividerThinOf(bool isDark) =>
      isDark ? dividerThinDark : dividerThin;

  /// 输入 / 填充背景：浅 #F7F7F7 / 深 #2C2C2C
  static Color inputBgOf(bool isDark) => isDark ? inputBarDark : inputBackground;

  /// 占位 / 图片加载底 / 中性填充：浅 #E5E5E5 / 深 #2A2A2A
  static Color placeholderOf(bool isDark) =>
      isDark ? placeholderDark : placeholder;
}

/// 颜色调色板
///
/// 用于头像、标签等需要动态颜色的场景
abstract class AppColorPalettes {
  AppColorPalettes._();

  /// 头像颜色列表
  static const List<Color> avatarColors = [
    Color(0xFF1AAD19), // 绿
    Color(0xFF576B95), // 蓝
    Color(0xFFFA9D3B), // 橙
    Color(0xFFE64340), // 红
    Color(0xFF9B59B6), // 紫
    Color(0xFF3498DB), // 浅蓝
    Color(0xFF1ABC9C), // 青
    Color(0xFFF39C12), // 黄
  ];

  /// 根据名称获取固定头像颜色
  ///
  /// 同一名称总是返回相同的颜色
  static Color getAvatarColor(String name) {
    if (name.isEmpty) return avatarColors[0];
    final index = name.codeUnits.fold<int>(0, (sum, c) => sum + c) % avatarColors.length;
    return avatarColors[index];
  }
}

