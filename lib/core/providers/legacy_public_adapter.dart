// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42appv2/core/providers/core_providers.dart';
import 'package:n42appv2/core/storage/sp_util.dart';
import 'package:n42appv2/data/models/user_info.dart';
import 'package:n42appv2/shared/domain/entities/wallet_info.dart';
import 'package:n42appv2/src/component/enums/load.dart';

/// Legacy Public Provider Adapter
///
/// This adapter bridges the old PublicProvider (ChangeNotifier) with
/// the new Riverpod providers. It allows existing UI code to continue
/// working while gradually migrating to Riverpod.
///
/// Usage:
/// - In the app's MultiProvider, replace PublicProvider with this adapter
/// - Pass a ProviderContainer to the adapter
/// - The adapter will sync state between old and new systems
class LegacyPublicProviderAdapter extends ChangeNotifier with DiagnosticableTreeMixin {
  final ProviderContainer _container;
  final SPUtil _spUtil = SPUtil();
  
  // Subscriptions to Riverpod providers
  late final ProviderSubscription<ThemeMode> _themeSubscription;
  late final ProviderSubscription<Locale> _localeSubscription;
  late final ProviderSubscription<int> _homeTabSubscription;
  late final ProviderSubscription<int> _unreadCountSubscription;
  late final ProviderSubscription<ScreenLockState> _lockScreenSubscription;
  late final ProviderSubscription<SharedUserInfo?> _userSubscription;
  late final ProviderSubscription<bool> _walletPasswordSubscription;

  LegacyPublicProviderAdapter(this._container) {
    _initSubscriptions();
    _initLegacyData();
  }

  void _initSubscriptions() {
    // Subscribe to Riverpod providers and update legacy state
    _themeSubscription = _container.listen<ThemeMode>(
      themeModeProvider,
      (_, next) {
        _themeMode = next;
        notifyListeners();
      },
    );

    _localeSubscription = _container.listen<Locale>(
      localeProvider,
      (_, next) {
        _locale = next;
        notifyListeners();
      },
    );

    _homeTabSubscription = _container.listen<int>(
      homeTabIndexProvider,
      (_, next) {
        homeCurrentIndex = next;
        notifyListeners();
      },
    );

    _unreadCountSubscription = _container.listen<int>(
      unreadCountProvider,
      (_, next) {
        messageNotReadCount = next;
        notifyListeners();
      },
    );

    _lockScreenSubscription = _container.listen<ScreenLockState>(
      screenLockProvider,
      (_, next) {
        _lockScreenMap = next.toMap();
        notifyListeners();
      },
    );

    _userSubscription = _container.listen<SharedUserInfo?>(
      currentUserProvider,
      (_, next) {
        if (next != null) {
          _userInfo = UserInfo.fromJson(next.toJson());
        } else {
          _userInfo = null;
        }
        notifyListeners();
      },
    );

    _walletPasswordSubscription = _container.listen<bool>(
      walletPasswordVerifiedProvider,
      (_, next) {
        checkWalletPassword = next;
        notifyListeners();
      },
    );
  }

  Future<void> _initLegacyData() async {
    // Initial sync from Riverpod state
    _themeMode = _container.read(themeModeProvider);
    _locale = _container.read(localeProvider);
    homeCurrentIndex = _container.read(homeTabIndexProvider);
    messageNotReadCount = _container.read(unreadCountProvider);
    _lockScreenMap = _container.read(screenLockProvider).toMap();
    
    final user = _container.read(currentUserProvider);
    if (user != null) {
      _userInfo = UserInfo.fromJson(user.toJson());
    }
    
    checkWalletPassword = _container.read(walletPasswordVerifiedProvider);
  }

  // ============================================
  // Legacy Properties & Methods
  // ============================================

  bool unlockIsPush = false;
  bool checkWalletPassword = false;
  
  setCheckWalletPassword(bool value) {
    _container.read(walletPasswordVerifiedProvider.notifier).state = value;
  }

  Load load = Load.loading;

  UserInfo? _userInfo;
  UserInfo? get userInfo => _userInfo;
  
  setUserInfo(UserInfo? info) {
    if (info != null) {
      final sharedInfo = SharedUserInfo(
        uuid: info.uuid ?? '',
        email: info.email ?? '',
        name: info.name,
        avatarUrl: info.image,
        token: info.token,
        image: info.image,
        desc: info.desc,
      );
      _container.read(currentUserProvider.notifier).setUser(sharedInfo);
    } else {
      _container.read(currentUserProvider.notifier).clearUser();
    }
  }

  // Message count
  int messageNotReadCount = 0;
  
  setMessageNotReadCount({int? value}) {
    final notifier = _container.read(unreadCountProvider.notifier);
    if (value == null) {
      notifier.increment();
    } else {
      notifier.setCount(value);
    }
  }

  // Locale
  Locale _locale = const Locale('en');
  Locale get locale => _locale;
  
  switchLocale(String code) {
    _container.read(localeProvider.notifier).setLocale(code);
  }
  
  Map<String, dynamic> get getLocaleInfo {
    return _container.read(localeProvider.notifier).getLocaleInfo(_locale);
  }

  // Theme
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;
  
  switchTheme(int type) {
    ThemeMode mode;
    switch (type) {
      case 1:
        mode = ThemeMode.light;
        break;
      case 2:
        mode = ThemeMode.dark;
        break;
      default:
        mode = ThemeMode.system;
    }
    _container.read(themeModeProvider.notifier).setTheme(mode);
  }

  // Home tab index
  int homeCurrentIndex = 0;
  
  setHomeCurrentIndex(int value) {
    _container.read(homeTabIndexProvider.notifier).state = value;
  }

  // Select index (for guide pages)
  int selectIndex = 0;
  
  setSelectIndex(int value) {
    selectIndex = value;
    _container.read(mainTabSelectIndexProvider.notifier).state = value;
    notifyListeners();
  }

  // Lock screen
  Map<String, dynamic> _lockScreenMap = {
    "lock": false,
    "lockPW": "",
    "face": false,
    "fingerprint": false,
    "lockTime": 30,
    "gesture": false,
    "gesturePW": [],
    "PWLock": 0,
  };
  
  Map<String, dynamic> get lockScreenMap => _lockScreenMap;
  
  set lockScreenMap(Map<String, dynamic> value) {
    _lockScreenMap = value;
    // Update Riverpod state
    final state = ScreenLockState.fromMap(value);
    _container.read(screenLockProvider.notifier).setLockEnabled(state.isLocked);
  }

  Future<void> getLockScreenData() async {
    // Data is loaded from Riverpod provider
    _lockScreenMap = _container.read(screenLockProvider).toMap();
  }

  Future<void> setLockScreenData() async {
    await _spUtil.setLockScreen(_lockScreenMap);
    // Also update Riverpod state
    final lockNotifier = _container.read(screenLockProvider.notifier);
    await lockNotifier.setLockPassword(_lockScreenMap['lockPW'] ?? '');
    await lockNotifier.setFaceEnabled(_lockScreenMap['face'] ?? false);
    await lockNotifier.setFingerprintEnabled(_lockScreenMap['fingerprint'] ?? false);
    await lockNotifier.setLockTime(_lockScreenMap['lockTime'] ?? 30);
    await lockNotifier.setGestureEnabled(_lockScreenMap['gesture'] ?? false);
    if (_lockScreenMap['gesturePW'] != null) {
      await lockNotifier.setGesturePassword(List<int>.from(_lockScreenMap['gesturePW']));
    }
    await lockNotifier.setPasswordLockTimestamp(_lockScreenMap['PWLock'] ?? 0);
  }

  /// Check data on init
  Future<void> checkData() async {
    try {
      var userInfoJson = await _spUtil.getUserInfo();
      if (userInfoJson != null) {
        _userInfo = UserInfo.fromJson(userInfoJson);
        setUserInfo(_userInfo);
      }
      await getLockScreenData();
      load = Load.finish;
      _container.read(appLoadStateProvider.notifier).state = Load.finish;
      notifyListeners();
    } catch (e) {
      load = Load.finish;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _themeSubscription.close();
    _localeSubscription.close();
    _homeTabSubscription.close();
    _unreadCountSubscription.close();
    _lockScreenSubscription.close();
    _userSubscription.close();
    _walletPasswordSubscription.close();
    super.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<UserInfo?>("userInfo", userInfo));
  }
}

