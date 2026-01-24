// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter/material.dart';

/// BuildContext 安全工具
///
/// 提供安全使用 BuildContext 的辅助方法，避免跨异步使用问题
class ContextUtils {
  ContextUtils._();

  /// 安全执行需要 BuildContext 的操作
  ///
  /// 在异步操作后使用 BuildContext 前，自动检查 mounted 状态
  ///
  /// 示例:
  /// ```dart
  /// await someAsyncOperation();
  /// ContextUtils.safeUse(context, (ctx) {
  ///   Navigator.pop(ctx);
  /// });
  /// ```
  static void safeUse(
    BuildContext context,
    void Function(BuildContext context) action,
  ) {
    // 检查 context 是否仍然有效
    if (!context.mounted) return;
    action(context);
  }

  /// 安全执行需要 BuildContext 的异步操作
  ///
  /// 示例:
  /// ```dart
  /// await ContextUtils.safeUseAsync(context, (ctx) async {
  ///   await showDialog(...);
  /// });
  /// ```
  static Future<T?> safeUseAsync<T>(
    BuildContext context,
    Future<T> Function(BuildContext context) action,
  ) async {
    if (!context.mounted) return null;
    return action(context);
  }

  /// 在异步操作后安全显示 SnackBar
  static void showSnackBarSafe(
    BuildContext context,
    SnackBar snackBar,
  ) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// 在异步操作后安全导航
  static void popSafe(BuildContext context, [Object? result]) {
    if (!context.mounted) return;
    Navigator.of(context).pop(result);
  }

  /// 在异步操作后安全导航到新页面
  static Future<T?> pushSafe<T extends Object?>(
    BuildContext context,
    Route<T> route,
  ) async {
    if (!context.mounted) return null;
    return Navigator.of(context).push(route);
  }

  /// 在异步操作后安全显示对话框
  static Future<T?> showDialogSafe<T>(
    BuildContext context, {
    required Widget Function(BuildContext) builder,
    bool barrierDismissible = true,
  }) async {
    if (!context.mounted) return null;
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: builder,
    );
  }
}

/// StatefulWidget 扩展
///
/// 提供 mounted 检查的便捷方法
extension SafeStateExtension<T extends StatefulWidget> on State<T> {
  /// 安全执行 setState
  ///
  /// 在异步操作后调用，自动检查 mounted 状态
  void setStateSafe(VoidCallback fn) {
    if (!mounted) return;
    // ignore: invalid_use_of_protected_member
    setState(fn);
  }

  /// 安全执行需要 context 的操作
  void useContextSafe(void Function(BuildContext context) action) {
    if (!mounted) return;
    action(context);
  }

  /// 安全执行需要 context 的异步操作
  Future<R?> useContextSafeAsync<R>(
    Future<R> Function(BuildContext context) action,
  ) async {
    if (!mounted) return null;
    return action(context);
  }
}
