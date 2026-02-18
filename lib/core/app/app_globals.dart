// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter/material.dart';
import 'package:n42appv2/data/models/user_info.dart';
import 'package:n42appv2/core/providers/legacy_wallet_adapter.dart';
import 'package:n42appv2/core/storage/sp_util.dart';
import 'package:n42appv2/features/wallet_connect/presentation/providers/wallet_connect_providers.dart';

/// Application Globals
///
/// Centralized storage for application-wide state.
///
/// For new code, prefer using Riverpod providers from `core_providers.dart`:
/// - `currentUserProvider` for user info
/// - `themeModeProvider` for theme
/// - `localeProvider` for locale
///
/// This class provides static access for legacy code compatibility.
/// The underlying data is synchronized with Riverpod providers.
class AppGlobals {
  /// Global Navigator Key
  ///
  /// This is the preferred way to access navigation from outside the widget tree.
  /// Use `navigatorKey.currentContext` to get the current context if needed.
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Route Observer for navigation tracking
  static RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  /// Global BuildContext
  ///
  /// This is a convenience accessor that returns `navigatorKey.currentContext`.
  /// For new code, prefer passing context through the widget tree.
  ///
  /// Usage:
  /// - Access: `AppGlobals.appContext` (may be null if navigator not mounted)
  /// - Set: `AppGlobals.appContext = context;` (sets the backing context)
  static BuildContext get appContext {
    // Try to get context from navigatorKey first
    final navContext = navigatorKey.currentContext;
    if (navContext != null) return navContext;
    // Fallback to manually set context
    return _appContext!;
  }

  static set appContext(BuildContext context) {
    _appContext = context;
  }

  static BuildContext? _appContext;

  /// Current logged-in user
  static UserInfo? userInfo;

  /// Current active ID (use nextId for thread-safe auto-increment)
  static int _currentId = 0;
  static int get nextId => ++_currentId;

  /// Handle user login
  /// 
  /// Sets up user state and initializes related services.
  static Future<void> login(UserInfo info) async {
    userInfo = info;
    globalWapAdapter.initWallet(shouldInitCoinInfo: true);
    globalWcpInstance.cleanDataLogout();
    // Note: Provider access should be done through proper DI
    // The following calls should be refactored to use events or DI
  }

  /// Handle user logout
  /// 
  /// Clears user state and related data.
  static Future<void> logout() async {
    try {
      await SPUtil().saveUserInfo(null);
      userInfo = null;
    } catch (err) {
      debugPrint('Logout error: $err');
    }
  }

  /// Check if user is logged in
  static bool get isLoggedIn => userInfo != null;

  /// Get current user UUID
  static String? get currentUserUuid => userInfo?.uuid;

  /// Get current user email
  static String? get currentUserEmail => userInfo?.email;

  /// Get current user token
  static String? get currentUserToken => userInfo?.token;
}

// Legacy alias for backwards compatibility
// ignore: camel_case_types
typedef Application = AppGlobals;

