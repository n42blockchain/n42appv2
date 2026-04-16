import 'package:flutter/material.dart';

import 'app_colors.dart';

/// 文字样式定义
///
/// 基于微信设计规范
abstract class AppTextStyles {
  AppTextStyles._();

  // ============================================
  // 字体族
  // ============================================

  /// 默认字体（跟随系统）
  static const String? fontFamily = null;

  // ============================================
  // 标题样式
  // ============================================

  /// 大标题 - 20sp
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  /// 中标题 - 18sp
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  /// 小标题 - 17sp (导航栏标题)
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // ============================================
  // 正文样式
  // ============================================

  /// 大正文 - 17sp
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  /// 中正文 - 15sp (默认正文)
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  /// 小正文 - 14sp
  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  // ============================================
  // 辅助文字样式
  // ============================================

  /// 辅助文字 - 12sp
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  /// 超小辅助文字 - 10sp
  static const TextStyle captionSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    height: 1.4,
  );

  // ============================================
  // 列表样式
  // ============================================

  /// 列表标题
  static const TextStyle listTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// 列表副标题
  static const TextStyle listSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  // ============================================
  // 聊天相关样式
  // ============================================

  /// 会话列表 - 名称
  static const TextStyle conversationName = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// 会话列表 - 最后消息
  static const TextStyle conversationLastMessage = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  /// 会话列表 - 时间
  static const TextStyle conversationTime = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    height: 1.3,
  );

  /// 消息文字
  static const TextStyle messageText = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.messageTextSent,
    height: 1.4,
  );

  /// 消息时间分隔
  static const TextStyle messageTimeSeparator = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    height: 1.3,
  );

  /// 系统消息
  static const TextStyle systemMessage = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    height: 1.3,
  );

  // ============================================
  // 按钮样式
  // ============================================

  /// 主按钮文字
  static const TextStyle buttonPrimary = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    height: 1.3,
  );

  /// 次要按钮文字
  static const TextStyle buttonSecondary = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.primary,
    height: 1.3,
  );

  /// 文字按钮
  static const TextStyle buttonText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.primary,
    height: 1.3,
  );

  // ============================================
  // 输入框样式
  // ============================================

  /// 输入框文字
  static const TextStyle input = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  /// 输入框提示
  static const TextStyle inputHint = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    height: 1.4,
  );

  // ============================================
  // 徽章样式
  // ============================================

  /// 徽章数字
  static const TextStyle badge = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    height: 1.2,
  );

  // ============================================
  // 通讯录索引
  // ============================================

  /// 索引字母
  static const TextStyle indexLetter = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.2,
  );

  /// 分组标题
  static const TextStyle sectionHeader = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.3,
  );
}

/// TextStyle扩展方法
extension TextStyleExtension on TextStyle {
  /// 设置为次要颜色
  TextStyle get secondary => copyWith(color: AppColors.textSecondary);

  /// 设置为辅助颜色
  TextStyle get tertiary => copyWith(color: AppColors.textTertiary);

  /// 设置为主色
  TextStyle get primary => copyWith(color: AppColors.primary);

  /// 设置为错误颜色
  TextStyle get error => copyWith(color: AppColors.error);

  /// 加粗
  TextStyle get bold => copyWith(fontWeight: FontWeight.w600);

  /// 中等粗细
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);

  /// 设置深色模式颜色
  TextStyle get dark => copyWith(color: AppColors.textPrimaryDark);
}

