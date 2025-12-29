// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42appv2/core/storage/sp_util.dart';
import 'package:n42appv2/shared/domain/entities/wallet_info.dart';
import 'package:n42appv2/shared/domain/services/wallet_service_interface.dart';

/// SPUtil Provider
final spUtilProvider = Provider<SPUtil>((ref) => SPUtil());

/// Theme Mode Provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref.watch(spUtilProvider));
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SPUtil _spUtil;
  
  ThemeModeNotifier(this._spUtil) : super(ThemeMode.system) {
    _loadFromStorage();
  }
  
  Future<void> _loadFromStorage() async {
    final mode = await _spUtil.getThemeMode();
    state = _intToThemeMode(mode ?? 0);
  }
  
  void setTheme(ThemeMode mode) {
    state = mode;
    _spUtil.setThemeMode(_themeModeToInt(mode));
  }
  
  ThemeMode _intToThemeMode(int value) {
    switch (value) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
  
  int _themeModeToInt(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 1;
      case ThemeMode.dark:
        return 2;
      case ThemeMode.system:
        return 0;
    }
  }
}

/// Locale Provider
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier(ref.watch(spUtilProvider));
});

class LocaleNotifier extends StateNotifier<Locale> {
  final SPUtil _spUtil;
  
  LocaleNotifier(this._spUtil) : super(const Locale('en')) {
    _loadFromStorage();
  }
  
  Future<void> _loadFromStorage() async {
    final code = await _spUtil.getSysLang();
    if (code != null) {
      state = _codeToLocale(code);
    }
  }
  
  void setLocale(String code) {
    state = _codeToLocale(code);
    _spUtil.setSysLang(code);
  }
  
  Locale _codeToLocale(String code) {
    if (code == 'zh_TW') return const Locale('zh', 'TW');
    if (code == 'zh_CN') return const Locale('zh', 'CN');
    if (code == 'es_ES') return const Locale('es', 'ES');
    return Locale(code);
  }
}

/// Home Tab Index Provider
final homeTabIndexProvider = StateProvider<int>((ref) => 0);

/// Current User Provider
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, SharedUserInfo?>((ref) {
  return CurrentUserNotifier();
});

class CurrentUserNotifier extends StateNotifier<SharedUserInfo?> {
  CurrentUserNotifier() : super(null);
  
  void setUser(SharedUserInfo user) {
    state = user;
  }
  
  void clearUser() {
    state = null;
  }
  
  bool get isLoggedIn => state != null;
}

/// Unread Message Count Provider
final unreadCountProvider = StateProvider<int>((ref) => 0);

/// App Initialization State Provider
final appInitializedProvider = StateProvider<bool>((ref) => false);

