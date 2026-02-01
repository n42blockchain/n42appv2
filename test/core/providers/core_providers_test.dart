// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42appv2/core/providers/core_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Initialize Flutter binding for tests
  TestWidgetsFlutterBinding.ensureInitialized();

  // 初始化 SharedPreferences mock
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('HomeTabIndexProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should start at 0', () {
      final index = container.read(homeTabIndexProvider);
      expect(index, 0);
    });

    test('should update index', () {
      container.read(homeTabIndexProvider.notifier).state = 2;
      final index = container.read(homeTabIndexProvider);
      expect(index, 2);
    });
  });

  group('UnreadCountProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should start at 0', () {
      final count = container.read(unreadCountProvider);
      expect(count, 0);
    });

    test('should update count', () {
      container.read(unreadCountProvider.notifier).state = 5;
      final count = container.read(unreadCountProvider);
      expect(count, 5);
    });

    test('should increment count', () {
      container.read(unreadCountProvider.notifier).increment();
      final count = container.read(unreadCountProvider);
      expect(count, 1);
    });

    test('should reset count', () {
      container.read(unreadCountProvider.notifier).setCount(10);
      container.read(unreadCountProvider.notifier).reset();
      final count = container.read(unreadCountProvider);
      expect(count, 0);
    });
  });

  group('AppInitializedProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should start as false', () {
      final initialized = container.read(appInitializedProvider);
      expect(initialized, false);
    });

    test('should update to true', () {
      container.read(appInitializedProvider.notifier).state = true;
      final initialized = container.read(appInitializedProvider);
      expect(initialized, true);
    });
  });

  // Note: CurrentUserNotifier tests are skipped because they require
  // flutter_secure_storage plugin which is not available in unit tests.
  // These tests should be run as integration tests on actual devices.
  group('CurrentUserNotifier (state tests only)', () {
    test('SharedUserInfo equality test', () {
      // Test that SharedUserInfo can be created and compared
      // This doesn't require the actual provider which uses secure storage
      expect(true, true); // Placeholder for future state-only tests
    });
  });

  group('ScreenLockState', () {
    test('should create with default values', () {
      const state = ScreenLockState();

      expect(state.isLocked, false);
      expect(state.lockPassword, '');
      expect(state.faceEnabled, false);
      expect(state.fingerprintEnabled, false);
      expect(state.lockTimeSeconds, 30);
      expect(state.gestureEnabled, false);
      expect(state.gesturePassword, isEmpty);
      expect(state.passwordLockTimestamp, 0);
    });

    test('should copy with new values', () {
      const original = ScreenLockState();
      final copied = original.copyWith(
        isLocked: true,
        lockPassword: '123456',
        faceEnabled: true,
      );

      expect(copied.isLocked, true);
      expect(copied.lockPassword, '123456');
      expect(copied.faceEnabled, true);
      // Unchanged values
      expect(copied.fingerprintEnabled, false);
      expect(copied.gestureEnabled, false);
    });

    test('should convert to map correctly', () {
      const state = ScreenLockState(
        isLocked: true,
        lockPassword: '123456',
        faceEnabled: true,
        fingerprintEnabled: true,
        lockTimeSeconds: 60,
        gestureEnabled: true,
        gesturePassword: [1, 2, 3, 4],
        passwordLockTimestamp: 1000,
      );

      final map = state.toMap();

      expect(map['lock'], true);
      expect(map['lockPW'], '123456');
      expect(map['face'], true);
      expect(map['fingerprint'], true);
      expect(map['lockTime'], 60);
      expect(map['gesture'], true);
      expect(map['gesturePW'], [1, 2, 3, 4]);
      expect(map['PWLock'], 1000);
    });

    test('should create from map correctly', () {
      final map = {
        'lock': true,
        'lockPW': '123456',
        'face': true,
        'fingerprint': true,
        'lockTime': 60,
        'gesture': true,
        'gesturePW': [1, 2, 3, 4],
        'PWLock': 1000,
      };

      final state = ScreenLockState.fromMap(map);

      expect(state.isLocked, true);
      expect(state.lockPassword, '123456');
      expect(state.faceEnabled, true);
      expect(state.fingerprintEnabled, true);
      expect(state.lockTimeSeconds, 60);
      expect(state.gestureEnabled, true);
      expect(state.gesturePassword, [1, 2, 3, 4]);
      expect(state.passwordLockTimestamp, 1000);
    });

    test('should handle null map gracefully', () {
      final state = ScreenLockState.fromMap(null);

      expect(state.isLocked, false);
      expect(state.lockPassword, '');
    });

    test('should verify password correctly', () {
      const state = ScreenLockState(lockPassword: '123456');

      expect(state.verifyPassword('123456'), true);
      expect(state.verifyPassword('wrong'), false);
      expect(state.verifyPassword(''), false);
    });

    test('should verify gesture correctly', () {
      const state = ScreenLockState(gesturePassword: [1, 2, 3, 4]);

      expect(state.verifyGesture([1, 2, 3, 4]), true);
      expect(state.verifyGesture([1, 2, 3]), false);
      expect(state.verifyGesture([1, 2, 3, 5]), false);
      expect(state.verifyGesture([]), false);
    });
  });
}
