import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import 'n42_avatar.dart';
import 'n42_badge.dart';

/// 微信风格列表项
///
/// 特点：
/// - 头像 + 标题 + 副标题 + 右侧内容
/// - 点击效果
/// - 支持分割线
class N42ListTile extends StatelessWidget {
  /// 左侧头像URL
  final String? avatarUrl;

  /// 左侧头像名称（用于默认头像）
  final String? avatarName;

  /// 自定义左侧Widget
  final Widget? leading;

  /// 标题
  final String title;

  /// 副标题
  final String? subtitle;

  /// 右侧文字（如时间）
  final String? trailing;

  /// 自定义右侧Widget
  final Widget? trailingWidget;

  /// 未读数量
  final int unreadCount;

  /// 是否免打扰
  final bool isMuted;

  /// 是否置顶
  final bool isPinned;

  /// 点击回调
  final VoidCallback? onTap;

  /// 长按回调
  final VoidCallback? onLongPress;

  /// 是否显示底部分割线
  final bool showDivider;

  /// 分割线缩进
  final double dividerIndent;

  /// 高度
  final double height;

  /// 背景色
  final Color? backgroundColor;

  const N42ListTile({
    super.key,
    this.avatarUrl,
    this.avatarName,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.trailingWidget,
    this.unreadCount = 0,
    this.isMuted = false,
    this.isPinned = false,
    this.onTap,
    this.onLongPress,
    this.showDivider = true,
    this.dividerIndent = 72,
    this.height = 72,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final bgColor = backgroundColor ??
        (isPinned
            ? (isDark ? const Color(0xFF252525) : const Color(0xFFF5F5F5))
            : (isDark ? AppColors.surfaceDark : AppColors.surface));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: bgColor,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            child: Container(
              height: height,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // 左侧头像
                  _buildLeading(),
                  const SizedBox(width: 12),

                  // 中间内容
                  Expanded(
                    child: _buildContent(isDark),
                  ),

                  // 右侧内容
                  _buildTrailing(isDark),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Container(
            margin: EdgeInsets.only(left: dividerIndent),
            height: 0.5,
            color: isDark ? AppColors.dividerDark : AppColors.divider,
          ),
      ],
    );
  }

  Widget _buildLeading() {
    if (leading != null) return leading!;

    return N42Avatar(
      imageUrl: avatarUrl,
      name: avatarName ?? title,
      size: 48,
    );
  }

  Widget _buildContent(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题行
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              Text(
                trailing!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ],
        ),

        // 副标题
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              if (isMuted) ...[
                const N42MutedIcon(size: 14),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTrailing(bool isDark) {
    if (trailingWidget != null) return trailingWidget!;

    // 显示未读徽章
    if (unreadCount > 0) {
      if (isMuted) {
        // 免打扰时显示灰色点
        return Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.textTertiary,
            shape: BoxShape.circle,
          ),
        );
      }
      return N42Badge.count(
        count: unreadCount,
        child: const SizedBox.shrink(),
      );
    }

    return const SizedBox.shrink();
  }
}

/// 设置页列表项
class N42SettingsTile extends StatelessWidget {
  /// 图标
  final IconData? icon;

  /// 图标颜色
  final Color? iconColor;

  /// 图标背景色
  final Color? iconBackgroundColor;

  /// 标题
  final String title;

  /// 副标题
  final String? subtitle;

  /// 右侧文字
  final String? trailing;

  /// 是否显示箭头
  final bool showArrow;

  /// 是否是开关类型
  final bool? switchValue;

  /// 开关变化回调
  final ValueChanged<bool>? onSwitchChanged;

  /// 点击回调
  final VoidCallback? onTap;

  /// 是否显示底部分割线
  final bool showDivider;

  const N42SettingsTile({
    super.key,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showArrow = true,
    this.switchValue,
    this.onSwitchChanged,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          child: InkWell(
            onTap: switchValue == null ? onTap : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // 图标
                  if (icon != null) ...[
                    _buildIcon(),
                    const SizedBox(width: 12),
                  ],

                  // 标题
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // 右侧内容
                  _buildTrailing(isDark),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Container(
            margin: EdgeInsets.only(left: icon != null ? 56 : 16),
            height: 0.5,
            color: isDark ? AppColors.dividerDark : AppColors.divider,
          ),
      ],
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: iconBackgroundColor ?? iconColor ?? AppColors.primary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        icon,
        size: 18,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTrailing(bool isDark) {
    if (switchValue != null) {
      return Switch(
        value: switchValue!,
        onChanged: onSwitchChanged,
        activeTrackColor: AppColors.primary,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (trailing != null)
          Text(
            trailing!,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        if (showArrow) ...[
          const SizedBox(width: 4),
          const Icon(
            Icons.chevron_right,
            size: 20,
            color: AppColors.textTertiary,
          ),
        ],
      ],
    );
  }
}

