import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_text_styles.dart';

/// 微信风格导航栏
///
/// 特点：
/// - 标题居中
/// - 简洁的返回按钮
/// - 可自定义左右操作按钮
class N42AppBar extends StatelessWidget implements PreferredSizeWidget {
  /// 标题
  final String? title;

  /// 标题Widget（优先于title）
  final Widget? titleWidget;

  /// 左侧按钮
  final Widget? leading;

  /// 是否显示返回按钮
  final bool showBackButton;

  /// 返回按钮点击回调
  final VoidCallback? onBackPressed;

  /// 右侧操作按钮列表
  final List<Widget>? actions;

  /// 背景色
  final Color? backgroundColor;

  /// 前景色（标题、图标颜色）
  final Color? foregroundColor;

  /// 底部分割线
  final bool showDivider;

  /// 海拔
  final double elevation;

  /// 是否居中标题
  final bool centerTitle;

  /// 状态栏样式
  final SystemUiOverlayStyle? systemOverlayStyle;

  const N42AppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.showDivider = true,
    this.elevation = 0,
    this.centerTitle = true,
    this.systemOverlayStyle,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = backgroundColor ?? context.navBarColor;
    final fgColor = foregroundColor ?? context.textPrimary;

    return AppBar(
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      elevation: elevation,
      centerTitle: centerTitle,
      systemOverlayStyle: systemOverlayStyle ??
          (isDark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark),
      leading: _buildLeading(context, fgColor),
      title: _buildTitle(fgColor),
      actions: actions,
      bottom: showDivider
          ? PreferredSize(
              preferredSize: const Size.fromHeight(0.5),
              child: Container(
                height: 0.5,
                color: context.dividerColor,
              ),
            )
          : null,
    );
  }

  Widget? _buildLeading(BuildContext context, Color fgColor) {
    if (leading != null) return leading;

    if (showBackButton && Navigator.of(context).canPop()) {
      return IconButton(
        icon: Icon(
          AppIcons.back,
          color: fgColor,
          size: AppDimensions.iconSizeSmall,
        ),
        // 保证 44dp iOS / 48dp Material 最小可点目标
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        splashRadius: 22,
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      );
    }

    return null;
  }

  Widget? _buildTitle(Color fgColor) {
    if (titleWidget != null) return titleWidget;
    if (title == null) return null;
    // 长标题需省略，避免与 actions 重叠或换行。
    return Text(
      title!,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.headlineSmall.copyWith(color: fgColor),
    );
  }
}

/// 透明导航栏（用于滚动效果）
class N42SliverAppBar extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final bool pinned;
  final bool floating;
  final double expandedHeight;
  final Widget? flexibleSpace;

  const N42SliverAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.pinned = true,
    this.floating = false,
    this.expandedHeight = 120,
    this.flexibleSpace,
  });

  @override
  Widget build(BuildContext context) {
    final fgColor = context.textPrimary;
    return SliverAppBar(
      backgroundColor: context.navBarColor,
      foregroundColor: fgColor,
      pinned: pinned,
      floating: floating,
      expandedHeight: expandedHeight,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: titleWidget ??
          (title != null
              ? Text(
                  title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headlineSmall.copyWith(color: fgColor),
                )
              : null),
      actions: actions,
      flexibleSpace: flexibleSpace,
    );
  }
}

