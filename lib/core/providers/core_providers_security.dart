// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

part of 'core_providers.dart';

// ============================================
// Screen Lock Provider
// ============================================

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

  /// Verify numeric/text password (constant-time comparison)
  bool verifyPassword(String password) {
    final a = lockPassword;
    final b = password;
    if (a.length != b.length) return false;
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  /// Verify gesture pattern
  bool verifyGesture(List<int> gesture) =>
      listEquals(gesturePassword, gesture);
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
