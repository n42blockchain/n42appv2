// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/security/secure_storage.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/constants/language_constants.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/core/utils/theme_mode_utils.dart';
import 'package:n42_wallet/data/models/user_info.dart';
import 'package:n42_wallet/shared/domain/entities/wallet_info.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/core/network/ipfs_api.dart';
import 'package:n42_wallet/features/login/api/user_info_api.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_chat/n42_chat.dart';

part 'core_providers_ui.dart';
part 'core_providers_security.dart';
part 'core_providers_profile.dart';

/// SPUtil Provider
final spUtilProvider = Provider<SPUtil>((ref) => SPUtil());

// ============================================
// Navigation & Tab Providers
// ============================================

/// Home Tab Index Provider
final homeTabIndexProvider = StateProvider<int>((ref) => 0);

/// Main Tab Select Index (for guide pages)
final mainTabSelectIndexProvider = StateProvider<int>((ref) => 0);

// ============================================
// User & Auth Providers
// ============================================

/// Current User Provider
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, SharedUserInfo?>((ref) {
  return CurrentUserNotifier(ref.watch(spUtilProvider));
});

class CurrentUserNotifier extends StateNotifier<SharedUserInfo?> {
  final SPUtil _spUtil;

  CurrentUserNotifier(this._spUtil) : super(null) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final userJson = await _spUtil.getUserInfo();
      if (!mounted) return;
      if (userJson != null) {
        state = SharedUserInfo.fromJson(userJson);
      }
    } catch (e) {
      debugPrint('CurrentUserNotifier._loadFromStorage error: $e');
    }
  }

  void setUser(SharedUserInfo user) {
    if (!mounted) return;
    state = user;
    _spUtil.saveUserInfoJson(user.toJson());
  }

  void clearUser() {
    state = null;
  }

  bool get isLoggedIn => state != null;
}

/// Wallet Password Verification State
final walletPasswordVerifiedProvider = StateProvider<bool>((ref) => false);

// ============================================
// Message & Notification Providers
// ============================================

/// Unread Message Count Provider
final unreadCountProvider = StateNotifierProvider<UnreadCountNotifier, int>((ref) {
  return UnreadCountNotifier();
});

class UnreadCountNotifier extends StateNotifier<int> {
  UnreadCountNotifier() : super(0);

  void increment() {
    state++;
  }

  void setCount(int count) {
    state = count;
  }

  void reset() {
    state = 0;
  }
}

// ============================================
// App State Providers
// ============================================

/// App Load State Provider
final appLoadStateProvider = StateProvider<Load>((ref) => Load.loading);

/// App Initialization State Provider
final appInitializedProvider = StateProvider<bool>((ref) => false);

// ============================================
// App Initialization Provider
// ============================================

/// Performs app startup initialization: loads user info, lock screen data,
/// and sets app load state to finished.
///
/// Not autoDispose: this is a one-shot initialization provider.
/// Its completed state is intentionally kept alive for the lifetime of the app.
SharedUserInfo _toSharedUserInfo(UserInfo u) => SharedUserInfo(
      uuid: u.uuid ?? '',
      email: u.email ?? '',
      name: u.name,
      avatarUrl: u.image,
      token: u.token,
      image: u.image,
      desc: u.desc,
    );

Future<void> _syncTokenToSecureStorage(
    SecureStorage secureStorage, UserInfo userInfo) async {
  if (userInfo.token != null && userInfo.token!.isNotEmpty) {
    await secureStorage.saveToken(userInfo.token!);
  }
}

final appInitProvider = FutureProvider<void>((ref) async {
  final spUtil = ref.read(spUtilProvider);
  final secureStorage = SecureStorage();
  try {
    final userInfoJson = await spUtil.getUserInfo();
    if (userInfoJson != null) {
      final userInfo = UserInfo.fromJson(userInfoJson);
      AppGlobals.userInfo = userInfo;
      await _syncTokenToSecureStorage(secureStorage, userInfo);
      ref.read(currentUserProvider.notifier).setUser(_toSharedUserInfo(userInfo));

      // Fetch fresh user info from server (with timeout to prevent startup hang)
      final loginApi = UserInfoApi();
      final freshUser = await loginApi.getUserInfo(
        userInfo.uuid ?? '',
        userInfo.token ?? '',
        userInfo.hashCode.toString(),
      ).timeout(const Duration(seconds: 8), onTimeout: () => null);
      if (freshUser != null) {
        AppGlobals.userInfo = freshUser;
        await _syncTokenToSecureStorage(secureStorage, freshUser);
        ref.read(currentUserProvider.notifier).setUser(_toSharedUserInfo(freshUser));
        await spUtil.saveUserInfo(freshUser);
      }
    }
  } catch (e) {
    debugPrint('appInitProvider._getUserInfo error: $e');
  }

  ref.read(screenLockProvider);
  ref.read(appLoadStateProvider.notifier).state = Load.finish;
});
