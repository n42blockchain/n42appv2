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
    if (!mounted) return;
    state = ThemeModeUtils.fromInt(mode ?? 0);
    _syncToN42Chat(state);
  }

  void setTheme(ThemeMode mode) {
    state = mode;
    _spUtil.setThemeMode(ThemeModeUtils.toInt(mode));
    _syncToN42Chat(mode);
  }

  void _syncToN42Chat(ThemeMode mode) {
    if (N42Chat.isInitialized) N42Chat.setThemeMode(mode);
  }
}

// ============================================
// Accent Color Provider
// ============================================

/// Accent color provider — persisted via SharedPreferences.
/// Default is [ThemeAdapter.defaultAccent] (N42 brand blue).
final accentColorProvider = StateNotifierProvider<AccentColorNotifier, Color>((ref) {
  return AccentColorNotifier(ref.watch(spUtilProvider));
});

class AccentColorNotifier extends StateNotifier<Color> {
  final SPUtil _spUtil;

  AccentColorNotifier(this._spUtil) : super(ThemeAdapter.defaultAccent) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final value = await _spUtil.getAccentColor();
    if (!mounted) return;
    if (value != null && value != 0) {
      state = Color(value);
    }
  }

  void setAccent(Color color) {
    state = color;
    _spUtil.setAccentColor(color.toARGB32());
  }

  void reset() {
    state = ThemeAdapter.defaultAccent;
    _spUtil.setAccentColor(0); // 0 = default
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
    if (!mounted) return;
    if (code != null) {
      state = _codeToLocale(code);
      _syncToN42Chat(state);
    }
  }

  void setLocale(String code) {
    state = _codeToLocale(code);
    _spUtil.setSysLang(code);
    _syncToN42Chat(state);
  }

  void _syncToN42Chat(Locale locale) {
    if (N42Chat.isInitialized) N42Chat.setLocale(locale);
  }
  
  Locale _codeToLocale(String code) {
    if (code == 'zh_TW') return const Locale('zh', 'TW');
    if (code == 'zh_CN') return const Locale('zh', 'CN');
    if (code == 'es_ES') return const Locale('es', 'ES');
    return Locale(code);
  }
  
  /// Get locale info for display
  Map<String, String> getLocaleInfo(Locale locale) {
    final lang = getLanguageByCode(locale.languageCode);
    return {"icon": lang.icon, "title": lang.name};
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
      if (!mounted) return;
      if (userJson != null) {
        state = SharedUserInfo.fromJson(userJson);
      }
    } catch (e) {
      // Ignore loading errors
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
    if (!mounted) return;
    state = useNewChat;
  }

  Future<void> setUseNewChat(bool value) async {
    if (!mounted) return;
    state = value;
    await _spUtil.setUseNewChat(value);
  }

  void toggle() {
    if (!mounted) return;
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

  /// Verify numeric/text password
  bool verifyPassword(String password) => lockPassword == password;

  /// Verify gesture pattern
  bool verifyGesture(List<int> gesture) {
    if (gesturePassword.length != gesture.length) return false;
    for (int i = 0; i < gesture.length; i++) {
      if (gesturePassword[i] != gesture[i]) return false;
    }
    return true;
  }
}

class ScreenLockNotifier extends StateNotifier<ScreenLockState> {
  final SPUtil _spUtil;

  ScreenLockNotifier(this._spUtil) : super(const ScreenLockState()) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final data = await _spUtil.getLockScreen();
    if (!mounted) return;
    state = ScreenLockState.fromMap(data);
  }

  Future<void> setLockEnabled(bool enabled) async {
    if (!mounted) return;
    state = state.copyWith(isLocked: enabled);
    await _saveToStorage();
  }

  Future<void> setLockPassword(String password) async {
    if (!mounted) return;
    state = state.copyWith(lockPassword: password, isLocked: password.isNotEmpty);
    await _saveToStorage();
  }

  Future<void> setFaceEnabled(bool enabled) async {
    if (!mounted) return;
    state = state.copyWith(faceEnabled: enabled);
    await _saveToStorage();
  }

  Future<void> setFingerprintEnabled(bool enabled) async {
    if (!mounted) return;
    state = state.copyWith(fingerprintEnabled: enabled);
    await _saveToStorage();
  }

  Future<void> setLockTime(int seconds) async {
    if (!mounted) return;
    state = state.copyWith(lockTimeSeconds: seconds);
    await _saveToStorage();
  }

  Future<void> setGestureEnabled(bool enabled) async {
    if (!mounted) return;
    state = state.copyWith(gestureEnabled: enabled);
    await _saveToStorage();
  }

  Future<void> setGesturePassword(List<int> password) async {
    if (!mounted) return;
    state = state.copyWith(gesturePassword: password, gestureEnabled: password.isNotEmpty);
    await _saveToStorage();
  }

  Future<void> setPasswordLockTimestamp(int timestamp) async {
    if (!mounted) return;
    state = state.copyWith(passwordLockTimestamp: timestamp);
    await _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    if (!mounted) return;
    await _spUtil.setLockScreen(state.toMap());
  }

  bool get hasAnyLockEnabled => 
      state.isLocked || state.gestureEnabled || state.faceEnabled || state.fingerprintEnabled;

  /// Delegates to [ScreenLockState.verifyPassword] — single source of truth.
  bool verifyPassword(String password) => state.verifyPassword(password);

  /// Delegates to [ScreenLockState.verifyGesture] — single source of truth.
  bool verifyGesture(List<int> gesture) => state.verifyGesture(gesture);
}

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
  try {
    final userInfoJson = await spUtil.getUserInfo();
    if (userInfoJson != null) {
      final userInfo = UserInfo.fromJson(userInfoJson);
      AppGlobals.userInfo = userInfo;
      // Sync token to SecureStorage on startup load
      if (userInfo.token != null && userInfo.token!.isNotEmpty) {
        await secureStorage.saveToken(userInfo.token!);
      }
      final sharedInfo = SharedUserInfo(
        uuid: userInfo.uuid ?? '',
        email: userInfo.email ?? '',
        name: userInfo.name,
        avatarUrl: userInfo.image,
        token: userInfo.token,
        image: userInfo.image,
        desc: userInfo.desc,
      );
      ref.read(currentUserProvider.notifier).setUser(sharedInfo);

      // Fetch fresh user info from server (with timeout to prevent startup hang)
      final loginApi = UserInfoApi();
      final freshUser = await loginApi.getUserInfo(
        userInfo.uuid ?? '',
        userInfo.token ?? '',
        userInfo.hashCode.toString(),
      ).timeout(const Duration(seconds: 8), onTimeout: () => null);
      if (freshUser != null) {
        AppGlobals.userInfo = freshUser;
        // Sync fresh token to SecureStorage
        if (freshUser.token != null && freshUser.token!.isNotEmpty) {
          await secureStorage.saveToken(freshUser.token!);
        }
        final freshShared = SharedUserInfo(
          uuid: freshUser.uuid ?? '',
          email: freshUser.email ?? '',
          name: freshUser.name,
          avatarUrl: freshUser.image,
          token: freshUser.token,
          image: freshUser.image,
          desc: freshUser.desc,
        );
        ref.read(currentUserProvider.notifier).setUser(freshShared);
        await spUtil.saveUserInfo(freshUser);
      }
    }
  } catch (e) {
    debugPrint('appInitProvider._getUserInfo error: $e');
  }

  // Load lock screen data
  // (ScreenLockNotifier loads from storage in its constructor)
  // Just ensure the provider is read so it initializes
  ref.read(screenLockProvider);

  ref.read(appLoadStateProvider.notifier).state = Load.finish;
});

// ============================================
// User Profile Provider
// ============================================

/// Handles user profile editing (avatar upload + info update)
final userProfileProvider = Provider<UserProfileService>((ref) {
  return UserProfileService(ref);
});

class UserProfileService {
  final Ref _ref;

  UserProfileService(this._ref);

  /// Edit user info, optionally uploading a new avatar image
  Future<MessageModel> editUserInfo(UserInfo uInfo, {Uint8List? imageData}) async {
    MessageModel mm = MessageModel();
    if (imageData != null) {
      Map<String, dynamic> rData = await IpfsApi().uploadIPFSImage(
        imageData,
        "aImage.png",
        (int count, int total) {},
        type: 1,
      );
      if (rData["error"]) {
        mm.error = true;
        mm.data = "Upload failed";
        return mm;
      } else {
        uInfo.image = "${AppConfig.apiUrl['ipfsAddress']}${rData['data']['Hash']}";
      }
    }
    Map<String, dynamic> uMap = {
      "desc": uInfo.desc ?? "",
      "image": uInfo.image ?? "",
      "name": uInfo.name ?? "",
    };
    final userInfoAPI = UserInfoApi();
    mm = await userInfoAPI.updateUserInfo(uMap);
    if (mm.error == false) {
      await _ref.read(spUtilProvider).saveUserInfo(uInfo);
      AppGlobals.userInfo = uInfo;
      final sharedInfo = SharedUserInfo(
        uuid: uInfo.uuid ?? '',
        email: uInfo.email ?? '',
        name: uInfo.name,
        avatarUrl: uInfo.image,
        token: uInfo.token,
        image: uInfo.image,
        desc: uInfo.desc,
      );
      _ref.read(currentUserProvider.notifier).setUser(sharedInfo);
    }
    return mm;
  }
}


// ============================================
// Mining UI Version Provider
// ============================================

/// Controls whether to use V2 (beacon-chain staking, default) or V1 (APOS mining) UI.
/// true = V2, false = V1
final miningUseV2Provider = StateNotifierProvider<MiningUiVersionNotifier, bool>((ref) {
  return MiningUiVersionNotifier(ref.read(spUtilProvider));
});

class MiningUiVersionNotifier extends StateNotifier<bool> {
  final SPUtil _sp;

  MiningUiVersionNotifier(this._sp) : super(true) {
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    final useV2 = await _sp.getMiningUseV2();
    if (mounted) state = useV2;
  }

  Future<void> setUseV2(bool useV2) async {
    await _sp.setMiningUseV2(useV2);
    state = useV2;
  }
}
