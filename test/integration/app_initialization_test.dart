// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App Initialization Tests
///
/// These tests verify the app's core providers can be initialized correctly.
/// Note: Some tests that require platform plugins (flutter_secure_storage)
/// have been simplified to avoid MissingPluginException in unit tests.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('App Initialization Tests', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
      await Future.delayed(const Duration(milliseconds: 100));
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize basic providers', () async {
      // Tab index provider
      final tabIndex = container.read(homeTabIndexProvider);
      expect(tabIndex, 0);

      // Unread count provider
      final unreadCount = container.read(unreadCountProvider);
      expect(unreadCount, 0);

      // App initialized provider
      final initialized = container.read(appInitializedProvider);
      expect(initialized, false);
    });

    test('should have correct default theme', () async {
      final themeMode = container.read(themeModeProvider);
      expect(themeMode, ThemeMode.system);
    });

    test('should have correct default locale', () async {
      final locale = container.read(localeProvider);
      expect(locale.languageCode, 'en');
    });
  });

  group('Provider Dependencies', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
      await Future.delayed(const Duration(milliseconds: 100));
    });

    tearDown(() {
      container.dispose();
    });

    test('app initialized should start as false', () async {
      final initialized = container.read(appInitializedProvider);
      expect(initialized, false);
    });

    test('home tab index should start at 0', () async {
      final index = container.read(homeTabIndexProvider);
      expect(index, 0);
    });

    test('unread count should start at 0', () async {
      final count = container.read(unreadCountProvider);
      expect(count, 0);
    });
  });

  group('ScreenLockState Tests', () {
    test('default state should be unlocked', () {
      const state = ScreenLockState();
      expect(state.isLocked, false);
    });

    test('should create from map', () {
      final map = {'lock': true, 'lockPW': '123456'};
      final state = ScreenLockState.fromMap(map);
      expect(state.isLocked, true);
      expect(state.lockPassword, '123456');
    });

    test('should verify password', () {
      const state = ScreenLockState(lockPassword: '123456');
      expect(state.verifyPassword('123456'), true);
      expect(state.verifyPassword('wrong'), false);
    });
  });
}
