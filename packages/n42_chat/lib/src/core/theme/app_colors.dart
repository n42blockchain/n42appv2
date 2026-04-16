import 'package:flutter/material.dart';

/// 微信风格颜色配置
///
/// 所有颜色常量都按照微信设计规范定义
abstract class AppColors {
  AppColors._();

  // ============================================
  // 主色调 - WeChat Green
  // ============================================

  /// 主色 - 微信绿
  static const Color primary = Color(0xFF07C160);

  /// 主色 - 浅色变体
  static const Color primaryLight = Color(0xFF4CD964);

  /// 主色 - 深色变体
  static const Color primaryDark = Color(0xFF06AD56);

  /// 主色 - 透明变体
  static const Color primaryWithOpacity = Color(0x1A07C160);

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

  /// 细分割线
  static const Color dividerThin = Color(0xFFF0F0F0);

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

  /// 辅助文字 - 深色模式
  static const Color textTertiaryDark = Color(0xFF888888);

  /// 禁用文字
  static const Color textDisabled = Color(0xFFCCCCCC);

  /// 链接文字
  static const Color textLink = Color(0xFF576B95);

  /// 链接颜色
  static const Color link = Color(0xFF576B95);

  // ============================================
  // 消息气泡
  // ============================================

  /// 发送消息气泡 - 浅色 (微信绿)
  static const Color messageSent = Color(0xFF95EC69);

  /// 接收消息气泡 - 浅色
  static const Color messageReceived = Color(0xFFFFFFFF);

  /// 发送消息气泡 - 深色
  static const Color messageSentDark = Color(0xFF3EB575);

  /// 接收消息气泡 - 深色
  static const Color messageReceivedDark = Color(0xFF2C2C2C);

  /// 消息文字 - 发送方
  static const Color messageTextSent = Color(0xFF000000);

  /// 消息文字 - 接收方
  static const Color messageTextReceived = Color(0xFF000000);

  /// 自己发送的消息气泡 - 浅色
  static const Color bubbleSelf = Color(0xFF95EC69);

  /// 自己发送的消息气泡 - 深色
  static const Color bubbleSelfDark = Color(0xFF3EB575);

  /// 对方发送的消息气泡 - 浅色
  static const Color bubbleOther = Color(0xFFFFFFFF);

  /// 对方发送的消息气泡 - 深色
  static const Color bubbleOtherDark = Color(0xFF2C2C2C);

  /// 自己气泡颜色（微信风格：浅色亮绿，深色暗绿）
  static Color selfBubble(bool isDark) => isDark ? bubbleSelfDark : bubbleSelf;

  /// 发送消息文字颜色（微信风格：始终黑色，不论深浅模式）
  static Color sentText(bool isDark) => messageTextSent;

  // ============================================
  // 状态颜色
  // ============================================

  /// 错误/危险
  static const Color error = Color(0xFFFA5151);

  /// 警告
  static const Color warning = Color(0xFFFF9900);

  /// 成功
  static const Color success = Color(0xFF07C160);

  /// 信息
  static const Color info = Color(0xFF10AEFF);

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

  /// 输入框焦点边框
  static const Color inputFocusBorder = Color(0xFF07C160);

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

  /// 图片加载占位背景
  static const Color placeholder = Color(0xFFE5E5E5);

  // ============================================
  // 特殊用途
  // ============================================

  /// 在线状态
  static const Color online = Color(0xFF07C160);

  /// 离线状态
  static const Color offline = Color(0xFFCCCCCC);

  /// 选中状态
  static const Color selected = Color(0x1A07C160);

  /// 按压状态
  static const Color pressed = Color(0x0D000000);

  /// 加密标识
  static const Color encrypted = Color(0xFF07C160);

  /// 红包
  static const Color redPacket = Color(0xFFFD9B2D);

  /// 时间分隔器文字（已弃用背景色，改为纯文字）
  static const Color timeSeparator = Color(0xFF808080);
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

