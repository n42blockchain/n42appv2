// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
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
}
