import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

/// BuildContext 扩展方法
extension ContextExtension on BuildContext {
  // ============================================
  // 主题相关
  // ============================================

  /// 获取当前ThemeData
  ThemeData get theme => Theme.of(this);

  /// 获取ColorScheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// 获取TextTheme
  TextTheme get textTheme => theme.textTheme;

  /// 是否为深色模式
  bool get isDarkMode => theme.brightness == Brightness.dark;

  // ============================================
  // 品牌 token 颜色（自动深浅切换）
  // ============================================

  /// 主文字颜色（自动深浅）
  Color get textPrimary =>
      isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary;

  /// 次文字颜色（自动深浅）
  Color get textSecondary =>
      isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary;

  /// 辅助文字颜色（自动深浅）
  Color get textTertiary =>
      isDarkMode ? AppColors.textTertiaryDark : AppColors.textTertiary;

  /// 卡片/列表项背景（自动深浅）
  Color get surfaceColor =>
      isDarkMode ? AppColors.surfaceDark : AppColors.surface;

  /// 分割线颜色（自动深浅）
  Color get dividerColor =>
      isDarkMode ? AppColors.dividerDark : AppColors.divider;

  /// 极细分割线 / 列表分组背景（自动深浅）
  Color get dividerThin =>
      isDarkMode ? AppColors.dividerThinDark : AppColors.dividerThin;

  /// 页面背景（自动深浅）
  Color get pageBackground =>
      isDarkMode ? AppColors.backgroundDark : AppColors.background;

  /// 导航栏背景（自动深浅）
  Color get navBarColor => isDarkMode ? AppColors.navBarDark : AppColors.navBar;

  /// 输入栏背景（自动深浅）
  Color get inputBarColor =>
      isDarkMode ? AppColors.inputBarDark : AppColors.inputBar;

  // ============================================
  // 屏幕尺寸
  // ============================================

  /// 获取MediaQueryData
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// 屏幕宽度
  double get screenWidth => mediaQuery.size.width;

  /// 屏幕高度
  double get screenHeight => mediaQuery.size.height;

  /// 状态栏高度
  double get statusBarHeight => mediaQuery.padding.top;

  /// 底部安全区域高度
  double get bottomSafeArea => mediaQuery.padding.bottom;

  /// 键盘高度
  double get keyboardHeight => mediaQuery.viewInsets.bottom;

  /// 键盘是否可见
  bool get isKeyboardVisible => keyboardHeight > 0;

  /// 设备像素比
  double get devicePixelRatio => mediaQuery.devicePixelRatio;

  /// 是否为平板
  bool get isTablet => screenWidth > 600;

  /// 是否为横屏
  bool get isLandscape => mediaQuery.orientation == Orientation.landscape;

  // ============================================
  // 导航相关
  // ============================================

  /// 返回上一页
  void pop<T>([T? result]) => Navigator.of(this).pop(result);

  /// 是否可以返回
  bool get canPop => Navigator.of(this).canPop();

  /// 使用GoRouter导航
  void goTo(String location, {Object? extra}) => go(location, extra: extra);

  /// 推入新页面
  void pushTo(String location, {Object? extra}) => push(location, extra: extra);

  /// 替换当前页面
  void replaceTo(String location, {Object? extra}) =>
      pushReplacement(location, extra: extra);

  // ============================================
  // 焦点相关
  // ============================================

  /// 隐藏键盘
  void hideKeyboard() => FocusScope.of(this).unfocus();

  /// 请求焦点
  void requestFocus(FocusNode node) => FocusScope.of(this).requestFocus(node);

  // ============================================
  // SnackBar / Dialog
  // ============================================

  /// 显示SnackBar
  ///
  /// Features:
  /// - Auto-dismiss after duration (no manual swipe needed)
  /// - Clears previous SnackBar to prevent queue buildup
  /// - Floating behavior to avoid iPhone home indicator gesture conflicts
  /// - Horizontal swipe to dismiss (easier than vertical)
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
    Color? backgroundColor,
  }) {
    final messenger = ScaffoldMessenger.of(this);
    // Clear any existing SnackBar to prevent queue buildup
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }

  /// 显示错误SnackBar
  void showErrorSnackBar(String message, {Duration duration = const Duration(seconds: 3)}) {
    showSnackBar(message, duration: duration, backgroundColor: AppColors.error);
  }

  /// 显示成功SnackBar
  void showSuccessSnackBar(String message, {Duration duration = const Duration(seconds: 2)}) {
    showSnackBar(message, duration: duration, backgroundColor: AppColors.success);
  }

  /// 清除所有 SnackBar
  void clearSnackBars() {
    ScaffoldMessenger.of(this).clearSnackBars();
  }

  /// 显示确认对话框
  Future<bool> showConfirmDialog({
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    bool isDanger = false,
  }) async {
    final l10n = S.of(this);
    final confirm = confirmText ?? l10n?.commonConfirm ?? 'OK';
    final cancel = cancelText ?? l10n?.commonCancel ?? 'Cancel';
    final result = await showDialog<bool>(
      context: this,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              cancel,
              style: const TextStyle(color: AppColors.textTertiary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              confirm,
              style: TextStyle(
                color: isDanger ? AppColors.error : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 显示加载对话框
  void showLoadingDialog({String? message}) {
    showDialog<void>(
      context: this,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              if (message != null) ...[
                const SizedBox(width: 16),
                Text(message),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 隐藏加载对话框
  void hideLoadingDialog() {
    if (canPop) {
      pop<void>();
    }
  }
}
