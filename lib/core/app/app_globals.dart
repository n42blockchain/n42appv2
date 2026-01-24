// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter/material.dart';
import 'package:n42appv2/data/models/user_info.dart';
import 'package:n42appv2/core/storage/sp_util.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:provider/provider.dart';

/// Application Globals
///
/// Centralized storage for application-wide state.
/// 
/// Note: This is a legacy pattern. New code should use dependency injection
/// and proper state management instead of static globals.
/// 
/// TODO: Migrate to proper DI pattern with get_it
@Deprecated('Use dependency injection instead. This class will be removed.')
class AppGlobals {
  /// Global BuildContext (use with caution)
  @Deprecated('Avoid using global context. Pass context through widget tree.')
  static late BuildContext appContext;

  /// Global Navigator Key
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Route Observer for navigation tracking
  static RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  /// Current logged-in user
  static UserInfo? userInfo;

  /// Current active ID
  static int currentId = 0;

  /// Handle user login
  /// 
  /// Sets up user state and initializes related services.
  static Future<void> login(UserInfo info) async {
    userInfo = info;
    Provider.of<WalletActionProvider>(appContext,listen: false).initWallet(initCoinInfo: true);
    Provider.of<WalletConnectProvider>(appContext,listen: false).cleannData_loginout();
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
@Deprecated('Use AppGlobals instead')
typedef Application = AppGlobals;

