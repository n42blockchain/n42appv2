import 'dart:io';

import 'package:flutter/material.dart';

/// 响应式布局工具类
///
/// 提供 iPad / 平板适配所需的屏幕判断与布局辅助方法。
/// 断点定义与 n42_chat 插件保持一致：
///   mobile  < 600
///   tablet  600–900
///   desktop >= 900
class ResponsiveUtils {
  ResponsiveUtils._();

  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;

  /// 内容区域推荐最大宽度（iPad 竖屏约 810pt，限制内容区让布局更紧凑）
  static const double contentMaxWidth = 600;

  /// 判断当前是否为平板或更宽屏幕（宽度 >= 600）
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= mobileBreakpoint;
  }

  /// 判断是否为手机屏幕
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// 判断是否为横屏
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// 获取屏幕类型
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return ScreenType.mobile;
    if (width < tabletBreakpoint) return ScreenType.tablet;
    return ScreenType.desktop;
  }

  /// 根据屏幕大小返回自适应水平间距
  static double getAdaptivePadding(BuildContext context) {
    final type = getScreenType(context);
    switch (type) {
      case ScreenType.mobile:
        return 16;
      case ScreenType.tablet:
        return 24;
      case ScreenType.desktop:
        return 32;
    }
  }

  /// 获取内容最大宽度约束。
  /// 手机：不限制（infinity）。
  /// 平板/桌面：返回 [contentMaxWidth]。
  static double getContentMaxWidth(BuildContext context) {
    if (isMobile(context)) return double.infinity;
    return contentMaxWidth;
  }

  /// 是否应使用侧边导航栏（NavigationRail）替代底部 Tab。
  /// 平板横屏时使用侧边导航。
  static bool useSideNavigation(BuildContext context) {
    return isTablet(context) && isLandscape(context);
  }

  /// 判断当前设备是否为 iPad（仅限 iOS 平台）。
  /// 在 Android 平板上也可以用 [isTablet] 做宽度判断。
  static bool get isIPad {
    if (!Platform.isIOS) return false;
    final views = WidgetsBinding.instance.platformDispatcher.views;
    if (views.isEmpty) return false;
    final view = views.first;
    return view.physicalSize.shortestSide / view.devicePixelRatio >= 600;
  }
}

/// 屏幕类型枚举
enum ScreenType { mobile, tablet, desktop }

/// 响应式布局构建器
///
/// 根据屏幕类型自动选择渲染不同的子组件。
/// - [mobile] 是必填的回退组件。
/// - [tablet] 为 null 时平板使用 [mobile]。
/// - [desktop] 为 null 时桌面使用 [tablet]（若也为 null 则用 [mobile]）。
class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    switch (ResponsiveUtils.getScreenType(context)) {
      case ScreenType.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenType.tablet:
        return tablet ?? mobile;
      case ScreenType.mobile:
        return mobile;
    }
  }
}

/// 内容约束容器 — 限制最大宽度并居中
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;

  const ResponsiveContainer({super.key, required this.child, this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final effectiveMaxWidth =
        maxWidth ?? ResponsiveUtils.getContentMaxWidth(context);

    if (effectiveMaxWidth == double.infinity) {
      return child;
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
        child: child,
      ),
    );
  }
}
