// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42appv2/core/providers/core_providers.dart';
import 'package:n42appv2/core/storage/sp_util.dart';
import 'package:n42appv2/shared/domain/entities/wallet_info.dart';
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

  group('CurrentUserNotifier', () {
    late ProviderContainer container;

    setUp(() async {
      container = ProviderContainer();
      // 等待异步初始化完成
      await Future.delayed(const Duration(milliseconds: 50));
    });

    tearDown(() {
      container.dispose();
    });

    test('should start with null user', () async {
      final user = container.read(currentUserProvider);
      expect(user, isNull);
    });

    test('should set user', () async {
      const user = SharedUserInfo(
        uuid: 'test-uuid',
        email: 'test@example.com',
        name: 'Test User',
      );
      container.read(currentUserProvider.notifier).setUser(user);
      await Future.delayed(const Duration(milliseconds: 10));

      final currentUser = container.read(currentUserProvider);
      expect(currentUser, isNotNull);
      expect(currentUser!.uuid, 'test-uuid');
      expect(currentUser.email, 'test@example.com');
    });

    test('should clear user', () async {
      const user = SharedUserInfo(
        uuid: 'test-uuid',
        email: 'test@example.com',
      );
      container.read(currentUserProvider.notifier).setUser(user);
      await Future.delayed(const Duration(milliseconds: 10));
      container.read(currentUserProvider.notifier).clearUser();
      await Future.delayed(const Duration(milliseconds: 10));

      final currentUser = container.read(currentUserProvider);
      expect(currentUser, isNull);
    });

    test('isLoggedIn should reflect user state', () async {
      await Future.delayed(const Duration(milliseconds: 10));
      expect(container.read(currentUserProvider.notifier).isLoggedIn, false);

      const user = SharedUserInfo(
        uuid: 'test-uuid',
        email: 'test@example.com',
      );
      container.read(currentUserProvider.notifier).setUser(user);
      await Future.delayed(const Duration(milliseconds: 10));

      expect(container.read(currentUserProvider.notifier).isLoggedIn, true);
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
}
