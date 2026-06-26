import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import 'n42_avatar.dart';
import 'n42_badge.dart';

// 文本样式 hoist：会话列表是高频重建路径（每次 sync 重渲染所有可见行）。
// 提到顶层 static final 避免 4× copyWith × N 行的 TextStyle 分配开销。
final TextStyle _convNameLight =
    AppTextStyles.conversationName.copyWith(color: AppColors.textPrimary);
final TextStyle _convNameDark =
    AppTextStyles.conversationName.copyWith(color: AppColors.textPrimaryDark);
final TextStyle _convTimeLight = AppTextStyles.conversationTime
    .copyWith(color: AppColors.textTertiary);
final TextStyle _convTimeDark = AppTextStyles.conversationTime
    .copyWith(color: AppColors.textTertiaryDark);
final TextStyle _convLastMsgLight = AppTextStyles.conversationLastMessage
    .copyWith(color: AppColors.textSecondary);
final TextStyle _convLastMsgDark = AppTextStyles.conversationLastMessage
    .copyWith(color: AppColors.textSecondaryDark);

const BoxDecoration _mutedDotLight = BoxDecoration(
  color: AppColors.textTertiary,
  shape: BoxShape.circle,
);
const BoxDecoration _mutedDotDark = BoxDecoration(
  color: AppColors.textTertiaryDark,
  shape: BoxShape.circle,
);

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
    this.dividerIndent = AppDimensions.dividerIndent,
    this.height = AppDimensions.conversationItemHeight,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final bgColor = backgroundColor ??
        (isPinned ? context.dividerThin : context.surfaceColor);

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
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.listItemPadding,
              ),
              child: Row(
                children: [
                  _buildLeading(),
                  const SizedBox(width: AppDimensions.spacingM),
                  Expanded(child: _buildContent(isDark)),
                  _buildTrailing(isDark),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Container(
            margin: EdgeInsets.only(left: dividerIndent),
            height: AppDimensions.dividerThickness,
            color: context.dividerColor,
          ),
      ],
    );
  }

  Widget _buildLeading() {
    if (leading != null) return leading!;
    return N42Avatar(
      imageUrl: avatarUrl,
      name: avatarName ?? title,
      size: AppDimensions.avatarSizeConversation,
    );
  }

  Widget _buildContent(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: isDark ? _convNameDark : _convNameLight,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppDimensions.spacingS),
              Text(
                trailing!,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: isDark ? _convTimeDark : _convTimeLight,
              ),
            ],
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppDimensions.spacingXS),
          Row(
            children: [
              if (isMuted) ...[
                const N42MutedIcon(size: 14),
                const SizedBox(width: AppDimensions.spacingXS),
              ],
              Expanded(
                child: Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: isDark ? _convLastMsgDark : _convLastMsgLight,
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

    if (unreadCount > 0) {
      if (isMuted) {
        return Container(
          width: AppDimensions.badgeDotSize,
          height: AppDimensions.badgeDotSize,
          decoration: isDark ? _mutedDotDark : _mutedDotLight,
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
    final textPrimary = context.textPrimary;
    final textSecondary = context.textSecondary;
    final textTertiary = context.textTertiary;
    // 当 icon 存在：左侧 icon(28) + 间距(12) + 内边距(16) = 56；否则等于内边距 16。
    final dividerIndentLeft = icon != null
        ? AppDimensions.listItemPadding + 28 + AppDimensions.spacingM
        : AppDimensions.listItemPadding;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: context.surfaceColor,
          child: InkWell(
            onTap: switchValue == null ? onTap : null,
            child: Container(
              constraints: const BoxConstraints(
                minHeight: AppDimensions.settingsItemHeight,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.listItemPadding,
                vertical: AppDimensions.spacingM,
              ),
              child: Row(
                children: [
                  if (icon != null) ...[
                    _buildIcon(),
                    const SizedBox(width: AppDimensions.spacingM),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.listTitle.copyWith(
                            color: textPrimary,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.listSubtitle.copyWith(
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  _buildTrailing(textSecondary, textTertiary),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Container(
            margin: EdgeInsets.only(left: dividerIndentLeft),
            height: AppDimensions.dividerThickness,
            color: context.dividerColor,
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
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Icon(icon, size: 18, color: Colors.white),
    );
  }

  Widget _buildTrailing(Color textSecondary, Color textTertiary) {
    if (switchValue != null) {
      // Switch 颜色由 SwitchTheme 提供（n42_chat_theme.toThemeData）。
      return Switch(value: switchValue!, onChanged: onSwitchChanged);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (trailing != null)
          // 限宽防止长 trailing（如长地址）挤压标题。
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(
              trailing!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodySmall.copyWith(color: textSecondary),
            ),
          ),
        if (showArrow) ...[
          const SizedBox(width: AppDimensions.spacingXS),
          Icon(
            Icons.chevron_right,
            size: AppDimensions.iconSizeSmall,
            color: textTertiary,
          ),
        ],
      ],
    );
  }
}

