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
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42_chat/n42_chat.dart';

/// SPUtil Provider
final spUtilProvider = Provider<SPUtil>((ref) => SPUtil());

// ============================================
// Theme Provider
// ============================================

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
    // 同步主题到 n42_chat
    _syncToN42Chat(state);
  }
  
  void setTheme(ThemeMode mode) {
    state = mode;
    _spUtil.setThemeMode(_themeModeToInt(mode));
    // 同步主题到 n42_chat
    _syncToN42Chat(mode);
  }
  
  /// 同步主题到 n42_chat 模块
  void _syncToN42Chat(ThemeMode mode) {
    if (N42Chat.isInitialized) {
      N42Chat.setThemeMode(mode);
    }
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

// ============================================
// Locale Provider
// ============================================

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
  
  /// Get locale info for display
  Map<String, String> getLocaleInfo(Locale locale) {
    final code = locale.languageCode;
    switch (code) {
      case "en":
        return {"icon": "assets/setting/english.png", "title": "English"};
      case "ja":
        return {"icon": "assets/setting/japanese.png", "title": "日本語"};
      case "es":
        return {"icon": "assets/setting/spanish.png", "title": "España"};
      case "zh":
        if (locale.countryCode == 'CN') {
          return {"icon": "assets/setting/chinese.png", "title": "中文简体"};
        }
        return {"icon": "assets/setting/chinese_tw.png", "title": "中文繁體"};
      default:
        return {"icon": "assets/setting/english.png", "title": "English"};
    }
  }
}

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
      if (userJson != null) {
        state = SharedUserInfo.fromJson(userJson);
      }
    } catch (e) {
      // Ignore loading errors
    }
  }
  
  void setUser(SharedUserInfo user) {
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
// Chat Mode Provider
// ============================================

/// Use New Chat Provider (N42 Chat)
final useNewChatProvider = StateNotifierProvider<UseNewChatNotifier, bool>((ref) {
  return UseNewChatNotifier(ref.watch(spUtilProvider));
});

class UseNewChatNotifier extends StateNotifier<bool> {
  final SPUtil _spUtil;
  
  UseNewChatNotifier(this._spUtil) : super(true) {
    _loadFromStorage();
  }
  
  Future<void> _loadFromStorage() async {
    final useNewChat = await _spUtil.getUseNewChat();
    state = useNewChat;
  }
  
  Future<void> setUseNewChat(bool value) async {
    state = value;
    await _spUtil.setUseNewChat(value);
  }
  
  void toggle() {
    setUseNewChat(!state);
  }
}

/// Screen Lock State Provider
final screenLockProvider = StateNotifierProvider<ScreenLockNotifier, ScreenLockState>((ref) {
  return ScreenLockNotifier(ref.watch(spUtilProvider));
});

class ScreenLockState {
  final bool isLocked;
  final String lockPassword;
  final bool faceEnabled;
  final bool fingerprintEnabled;
  final int lockTimeSeconds;
  final bool gestureEnabled;
  final List<int> gesturePassword;
  final int passwordLockTimestamp;

  const ScreenLockState({
    this.isLocked = false,
    this.lockPassword = '',
    this.faceEnabled = false,
    this.fingerprintEnabled = false,
    this.lockTimeSeconds = 30,
    this.gestureEnabled = false,
    this.gesturePassword = const [],
    this.passwordLockTimestamp = 0,
  });

  ScreenLockState copyWith({
    bool? isLocked,
    String? lockPassword,
    bool? faceEnabled,
    bool? fingerprintEnabled,
    int? lockTimeSeconds,
    bool? gestureEnabled,
    List<int>? gesturePassword,
    int? passwordLockTimestamp,
  }) {
    return ScreenLockState(
      isLocked: isLocked ?? this.isLocked,
      lockPassword: lockPassword ?? this.lockPassword,
      faceEnabled: faceEnabled ?? this.faceEnabled,
      fingerprintEnabled: fingerprintEnabled ?? this.fingerprintEnabled,
      lockTimeSeconds: lockTimeSeconds ?? this.lockTimeSeconds,
      gestureEnabled: gestureEnabled ?? this.gestureEnabled,
      gesturePassword: gesturePassword ?? this.gesturePassword,
      passwordLockTimestamp: passwordLockTimestamp ?? this.passwordLockTimestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lock': isLocked,
      'lockPW': lockPassword,
      'face': faceEnabled,
      'fingerprint': fingerprintEnabled,
      'lockTime': lockTimeSeconds,
      'gesture': gestureEnabled,
      'gesturePW': gesturePassword,
      'PWLock': passwordLockTimestamp,
    };
  }

  /// Verify password
  bool verifyPassword(String password) => lockPassword == password;

  /// Verify gesture pattern
  bool verifyGesture(List<int> gesture) {
    if (gesturePassword.length != gesture.length) return false;
    for (int i = 0; i < gesture.length; i++) {
      if (gesturePassword[i] != gesture[i]) return false;
    }
    return true;
  }

  factory ScreenLockState.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const ScreenLockState();
    return ScreenLockState(
      isLocked: map['lock'] ?? false,
      lockPassword: map['lockPW'] ?? '',
      faceEnabled: map['face'] ?? false,
      fingerprintEnabled: map['fingerprint'] ?? false,
      lockTimeSeconds: map['lockTime'] ?? 30,
      gestureEnabled: map['gesture'] ?? false,
      gesturePassword: List<int>.from(map['gesturePW'] ?? []),
      passwordLockTimestamp: map['PWLock'] ?? 0,
    );
  }
}

class ScreenLockNotifier extends StateNotifier<ScreenLockState> {
  final SPUtil _spUtil;

  ScreenLockNotifier(this._spUtil) : super(const ScreenLockState()) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final data = await _spUtil.getLockScreen();
    state = ScreenLockState.fromMap(data);
  }

  Future<void> setLockEnabled(bool enabled) async {
    state = state.copyWith(isLocked: enabled);
    await _saveToStorage();
  }

  Future<void> setLockPassword(String password) async {
    state = state.copyWith(lockPassword: password, isLocked: password.isNotEmpty);
    await _saveToStorage();
  }

  Future<void> setFaceEnabled(bool enabled) async {
    state = state.copyWith(faceEnabled: enabled);
    await _saveToStorage();
  }

  Future<void> setFingerprintEnabled(bool enabled) async {
    state = state.copyWith(fingerprintEnabled: enabled);
    await _saveToStorage();
  }

  Future<void> setLockTime(int seconds) async {
    state = state.copyWith(lockTimeSeconds: seconds);
    await _saveToStorage();
  }

  Future<void> setGestureEnabled(bool enabled) async {
    state = state.copyWith(gestureEnabled: enabled);
    await _saveToStorage();
  }

  Future<void> setGesturePassword(List<int> password) async {
    state = state.copyWith(gesturePassword: password, gestureEnabled: password.isNotEmpty);
    await _saveToStorage();
  }

  Future<void> setPasswordLockTimestamp(int timestamp) async {
    state = state.copyWith(passwordLockTimestamp: timestamp);
    await _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    await _spUtil.setLockScreen(state.toMap());
  }

  bool get hasAnyLockEnabled => 
      state.isLocked || state.gestureEnabled || state.faceEnabled || state.fingerprintEnabled;

  bool verifyPassword(String password) => state.lockPassword == password;
  
  bool verifyGesture(List<int> gesture) => 
      state.gesturePassword.length == gesture.length &&
      List.generate(gesture.length, (i) => state.gesturePassword[i] == gesture[i]).every((e) => e);
}

