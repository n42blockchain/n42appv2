import 'package:flutter/material.dart';

/// 响应式布局工具类
///
/// 提供跨平台的响应式布局支持
class ResponsiveUtils {
  ResponsiveUtils._();

  /// 手机屏幕宽度断点
  static const double mobileBreakpoint = 600;

  /// 平板屏幕宽度断点
  static const double tabletBreakpoint = 900;

  /// 桌面屏幕宽度断点
  static const double desktopBreakpoint = 1200;

  /// 大桌面屏幕宽度断点
  static const double largeDesktopBreakpoint = 1800;

  /// 判断是否是手机屏幕
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// 判断是否是平板屏幕
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  /// 判断是否是桌面屏幕
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  /// 判断是否是大桌面屏幕
  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= largeDesktopBreakpoint;
  }

  /// 获取屏幕类型
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return ScreenSize.mobile;
    if (width < tabletBreakpoint) return ScreenSize.tablet;
    if (width < desktopBreakpoint) return ScreenSize.desktop;
    return ScreenSize.largeDesktop;
  }

  /// 获取适配的边距
  static double getAdaptivePadding(BuildContext context) {
    final size = getScreenSize(context);
    switch (size) {
      case ScreenSize.mobile:
        return 16;
      case ScreenSize.tablet:
        return 24;
      case ScreenSize.desktop:
        return 32;
      case ScreenSize.largeDesktop:
        return 48;
    }
  }

  /// 获取适配的内容宽度
  static double getContentMaxWidth(BuildContext context) {
    final size = getScreenSize(context);
    switch (size) {
      case ScreenSize.mobile:
        return double.infinity;
      case ScreenSize.tablet:
        return 720;
      case ScreenSize.desktop:
        return 960;
      case ScreenSize.largeDesktop:
        return 1200;
    }
  }

  /// 获取聊天列表宽度（桌面端侧边栏）
  static double getChatListWidth(BuildContext context) {
    final size = getScreenSize(context);
    switch (size) {
      case ScreenSize.mobile:
        return MediaQuery.of(context).size.width;
      case ScreenSize.tablet:
        return 320;
      case ScreenSize.desktop:
      case ScreenSize.largeDesktop:
        return 360;
    }
  }

  /// 是否显示侧边导航
  static bool showSideNavigation(BuildContext context) {
    return !isMobile(context);
  }

  /// 是否使用分屏布局（会话列表 + 聊天）
  static bool useSplitLayout(BuildContext context) {
    return !isMobile(context);
  }

  /// 获取网格列数
  static int getGridColumns(BuildContext context) {
    final size = getScreenSize(context);
    switch (size) {
      case ScreenSize.mobile:
        return 2;
      case ScreenSize.tablet:
        return 3;
      case ScreenSize.desktop:
        return 4;
      case ScreenSize.largeDesktop:
        return 6;
    }
  }
}

/// 屏幕尺寸枚举
enum ScreenSize {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// 响应式构建器
///
/// 根据屏幕尺寸自动选择不同的布局
class ResponsiveBuilder extends StatelessWidget {
  /// 手机布局
  final Widget mobile;

  /// 平板布局（可选，默认使用手机布局）
  final Widget? tablet;

  /// 桌面布局（可选，默认使用平板布局）
  final Widget? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final size = ResponsiveUtils.getScreenSize(context);

    switch (size) {
      case ScreenSize.mobile:
        return mobile;
      case ScreenSize.tablet:
        return tablet ?? mobile;
      case ScreenSize.desktop:
      case ScreenSize.largeDesktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}

/// 响应式约束容器
///
/// 限制内容的最大宽度，居中显示
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMaxWidth = maxWidth ?? ResponsiveUtils.getContentMaxWidth(context);
    final effectivePadding = padding ?? EdgeInsets.all(ResponsiveUtils.getAdaptivePadding(context));

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
        child: Padding(
          padding: effectivePadding,
          child: child,
        ),
      ),
    );
  }
}

/// 分屏布局
///
/// 在桌面/平板上显示分屏，在手机上显示单页
class SplitView extends StatelessWidget {
  /// 左侧面板（会话列表）
  final Widget leftPanel;

  /// 右侧面板（聊天内容）
  final Widget? rightPanel;

  /// 左侧面板宽度
  final double? leftPanelWidth;

  /// 是否显示分隔线
  final bool showDivider;

  /// 空状态占位
  final Widget? emptyState;

  const SplitView({
    super.key,
    required this.leftPanel,
    this.rightPanel,
    this.leftPanelWidth,
    this.showDivider = true,
    this.emptyState,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveUtils.isMobile(context)) {
      // 手机上显示单页
      return rightPanel ?? leftPanel;
    }

    // 桌面/平板上显示分屏
    final leftWidth = leftPanelWidth ?? ResponsiveUtils.getChatListWidth(context);

    return Row(
      children: [
        SizedBox(
          width: leftWidth,
          child: leftPanel,
        ),
        if (showDivider)
          const VerticalDivider(width: 1),
        Expanded(
          child: rightPanel ?? emptyState ?? const _EmptyRightPanel(),
        ),
      ],
    );
  }
}

class _EmptyRightPanel extends StatelessWidget {
  const _EmptyRightPanel();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            IconData(0xe0b7, fontFamily: 'MaterialIcons'), // chat_bubble_outline
            size: 64,
            color: Color(0xFFBDBDBD),
          ),
          SizedBox(height: 16),
          Text(
            'Select a conversation',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF9E9E9E),
            ),
          ),
        ],
      ),
    );
  }
}
