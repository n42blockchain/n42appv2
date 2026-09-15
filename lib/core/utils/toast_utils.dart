// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/app/app_globals.dart';

/// Toast Utility
///
/// Provides centralized toast/snackbar functionality with consistent styling.
class ToastUtils {
  static void _showToast(
    String message, {
    Toast length = Toast.LENGTH_SHORT,
    Color backgroundColor = const Color.fromRGBO(0, 0, 0, 0.5),
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: length,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 7,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  /// Show a simple toast message
  static void show(String message) => _showToast(message);

  /// Show a success toast
  static void showSuccess(String message) =>
      _showToast(message, backgroundColor: Colors.green.withValues(alpha: 0.8));

  /// Show an error toast
  static void showError(String message) => _showToast(
    message,
    length: Toast.LENGTH_LONG,
    backgroundColor: Colors.red.withValues(alpha: 0.8),
  );

  /// Show a warning toast
  static void showWarning(String message) => _showToast(
    message,
    backgroundColor: Colors.orange.withValues(alpha: 0.8),
  );

  // ========== Custom UI Toast ==========

  static FToast? _fToast;

  /// Initialize custom toast with context
  static void init(BuildContext context) {
    _fToast ??= FToast();
    _fToast?.init(context);
  }

  /// Show custom styled toast
  static void showFtToast({Widget? child, String? title, int duration = 2}) {
    _fToast?.showToast(
      child: child ?? _buildDefaultChild(title ?? ''),
      gravity: ToastGravity.CENTER,
      toastDuration: Duration(seconds: duration),
    );
  }

  /// Dispose custom toast
  static void dispose() {
    _fToast?.removeCustomToast();
  }

  static Widget _buildDefaultChild(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.blueGrey,
      ),
      child: Text(
        title,
        style: TextStyle(
          color: AppThemeUtils.getColorByKey(
            AppGlobals.navigatorKey.currentContext,
            AppThemeKeys.mainTextColor.name,
          ),
        ),
      ),
    );
  }
}
