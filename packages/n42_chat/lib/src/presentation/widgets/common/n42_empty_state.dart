import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import 'n42_button.dart';

/// 空状态组件
///
/// 用于展示空列表、加载失败等状态
class N42EmptyState extends StatelessWidget {
  /// 图标
  final IconData? icon;

  /// 图片路径
  final String? imagePath;

  /// 标题
  final String? title;

  /// 描述
  final String? description;

  /// 按钮文字
  final String? buttonText;

  /// 按钮点击回调
  final VoidCallback? onButtonPressed;

  /// 图标大小
  final double iconSize;

  /// 图标颜色
  final Color? iconColor;

  const N42EmptyState({
    super.key,
    this.icon,
    this.imagePath,
    this.title,
    this.description,
    this.buttonText,
    this.onButtonPressed,
    this.iconSize = 80,
    this.iconColor,
  });

  /// 空列表
  factory N42EmptyState.noData({
    String? title,
    String? description,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return N42EmptyState(
      icon: Icons.inbox_outlined,
      title: title ?? 'No data',
      description: description,
      buttonText: buttonText,
      onButtonPressed: onButtonPressed,
    );
  }

  /// 无搜索结果
  factory N42EmptyState.noSearchResult({
    String? title,
    String? description,
  }) {
    return N42EmptyState(
      icon: Icons.search_off,
      title: title ?? 'No search results',
      description: description ?? 'Try a different keyword',
    );
  }

  /// 加载失败
  factory N42EmptyState.error({
    String? title,
    String? description,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return N42EmptyState(
      icon: Icons.error_outline,
      title: title ?? 'Failed to load',
      description: description ?? 'Please check your network connection',
      buttonText: buttonText ?? 'Retry',
      onButtonPressed: onButtonPressed,
    );
  }

  /// 无网络
  factory N42EmptyState.noNetwork({
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return N42EmptyState(
      icon: Icons.wifi_off,
      title: 'Network connection failed',
      description: 'Please check your network settings',
      buttonText: buttonText ?? 'Retry',
      onButtonPressed: onButtonPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标或图片
            _buildIcon(isDark),

            // 标题
            if (title != null) ...[
              const SizedBox(height: 16),
              Text(
                title!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // 描述
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // 按钮
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              N42Button.primary(
                text: buttonText!,
                onPressed: onButtonPressed,
                expanded: false,
                size: N42ButtonSize.medium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(bool isDark) {
    if (imagePath != null) {
      return Image.asset(
        imagePath!,
        width: iconSize,
        height: iconSize,
        fit: BoxFit.contain,
      );
    }

    return Icon(
      icon ?? Icons.inbox_outlined,
      size: iconSize,
      color: iconColor ?? AppColors.textTertiary,
    );
  }
}

/// 加载中状态
class N42Loading extends StatelessWidget {
  /// 提示文字
  final String? message;

  /// 大小
  final double size;

  const N42Loading({
    super.key,
    this.message,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

