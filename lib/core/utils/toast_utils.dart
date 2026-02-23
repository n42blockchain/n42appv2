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
  /// Show a simple toast message
  static void show(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 7,
      backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
      textColor: const Color(0xffffffff),
      fontSize: 14.0,
    );
  }

  /// Show a success toast
  static void showSuccess(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.green.withValues(alpha:0.8),
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  /// Show an error toast
  static void showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red.withValues(alpha:0.8),
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  /// Show a warning toast
  static void showWarning(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.orange.withValues(alpha:0.8),
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  // ========== Custom UI Toast ==========

  static FToast? _fToast;

  /// Initialize custom toast with context
  static void init(BuildContext context) {
    _fToast ??= FToast();
    _fToast?.init(context);
  }

  /// Show custom styled toast
  static void showFtToast({
    Widget? child,
    String? title,
    int duration = 2,
  }) {
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                AppGlobals.navigatorKey.currentContext,
                AppThemeKeys.mainTextColor.name,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

