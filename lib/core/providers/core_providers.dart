// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/security/secure_storage.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/constants/language_constants.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/core/utils/theme_mode_utils.dart';
import 'package:n42_wallet/shared/domain/entities/user_info.dart';
import 'package:n42_wallet/shared/domain/entities/wallet_info.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_chat/n42_chat.dart';

part 'core_providers_ui.dart';
part 'core_providers_security.dart';

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
final currentUserProvider =
    StateNotifierProvider<CurrentUserNotifier, SharedUserInfo?>((ref) {
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
      AppLogger.w('CurrentUser', '_loadFromStorage error: $e');
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
final unreadCountProvider = StateNotifierProvider<UnreadCountNotifier, int>((
  ref,
) {
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
final appInitProvider = FutureProvider<void>((ref) async {
  final spUtil = ref.read(spUtilProvider);
  final secureStorage = SecureStorage();
  final currentUserNotifier = ref.read(currentUserProvider.notifier);
  try {
    // SharedPreferences read should be fast; 5 s timeout guards against edge
    // cases where the platform channel is slow to respond.
    final userInfoJson = await spUtil.getUserInfo().timeout(
      const Duration(seconds: 5),
      onTimeout: () => null,
    );
    if (userInfoJson != null) {
      final userInfo = UserInfo.fromJson(userInfoJson);
      // flutter_secure_storage on Android (custom AES cipher) can block
      // indefinitely when the hardware Keystore is not yet ready (first boot
      // after update, migration from legacy format, etc.).  Cap at 6 s so the
      // splash screen is never permanently stuck.
      await _syncActiveUser(
        userInfo,
        secureStorage: secureStorage,
        currentUserNotifier: currentUserNotifier,
      ).timeout(
        const Duration(seconds: 6),
        onTimeout: () {
          AppLogger.w(
            'appInit',
            '_syncActiveUser timed out – continuing anyway',
          );
        },
      );
    }
  } catch (e, s) {
    AppLogger.e('appInit', '_getUserInfo error', error: e, stackTrace: s);
  }

  ref.read(appLoadStateProvider.notifier).state = Load.finish;
});

SharedUserInfo _toSharedUserInfo(UserInfo userInfo) {
  return SharedUserInfo(
    uuid: userInfo.uuid ?? '',
    email: userInfo.email ?? '',
    name: userInfo.name,
    avatarUrl: userInfo.image,
    token: userInfo.token,
    image: userInfo.image,
    desc: userInfo.desc,
  );
}

Future<void> _syncActiveUser(
  UserInfo userInfo, {
  required SecureStorage secureStorage,
  required CurrentUserNotifier currentUserNotifier,
  SPUtil? spUtil,
}) async {
  AppGlobals.userInfo = userInfo;
  currentUserNotifier.setUser(_toSharedUserInfo(userInfo));

  final syncTasks = <Future<void>>[
    secureStorage.saveUserInfo(userInfo.toJson()),
  ];
  if (userInfo.token != null && userInfo.token!.isNotEmpty) {
    syncTasks.add(secureStorage.saveToken(userInfo.token!));
  }
  if (userInfo.uuid != null && userInfo.uuid!.isNotEmpty) {
    syncTasks.add(secureStorage.saveUuid(userInfo.uuid!));
  }
  if (userInfo.email != null && userInfo.email!.isNotEmpty) {
    syncTasks.add(secureStorage.saveEmail(userInfo.email!));
  }
  if (spUtil != null) {
    syncTasks.add(spUtil.saveUserInfo(userInfo));
  }
  await Future.wait(syncTasks);
}
