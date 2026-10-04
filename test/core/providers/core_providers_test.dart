// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/shared/domain/entities/wallet_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MemorySpUtil extends SPUtil {
  Map<String, dynamic>? persistedUser;

  @override
  Future<Map<String, dynamic>?> getUserInfo() async => persistedUser;

  @override
  Future<void> saveUserInfoJson(Map<String, dynamic> info) async {
    persistedUser = Map<String, dynamic>.from(info);
  }
}

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

  group('Current user state', () {
    test(
      'SharedUserInfo compares every profile field and round-trips JSON',
      () {
        const user = SharedUserInfo(
          uuid: 'user-1',
          email: 'alice@example.org',
          name: 'Alice',
          avatarUrl: 'https://example.org/alice.png',
          token: 'test-token',
          image: 'https://example.org/alice.png',
          desc: 'Wallet owner',
        );
        const matchingUser = SharedUserInfo(
          uuid: 'user-1',
          email: 'alice@example.org',
          name: 'Alice',
          avatarUrl: 'https://example.org/alice.png',
          token: 'test-token',
          image: 'https://example.org/alice.png',
          desc: 'Wallet owner',
        );

        expect(user, matchingUser);
        expect(SharedUserInfo.fromJson(user.toJson()), user);
        expect(
          user,
          isNot(
            const SharedUserInfo(
              uuid: 'user-2',
              email: 'alice@example.org',
              name: 'Alice',
              avatarUrl: 'https://example.org/alice.png',
              token: 'test-token',
              image: 'https://example.org/alice.png',
              desc: 'Wallet owner',
            ),
          ),
        );
      },
    );

    test('SharedUserInfo reads the legacy image field as avatar URL', () {
      final user = SharedUserInfo.fromJson({
        'uuid': 'user-1',
        'email': 'alice@example.org',
        'image': 'https://example.org/legacy.png',
      });

      expect(user.avatarUrl, 'https://example.org/legacy.png');
      expect(user.image, 'https://example.org/legacy.png');
    });

    test(
      'CurrentUserNotifier loads, publishes, persists, and clears the user',
      () async {
        final storage = _MemorySpUtil();
        final notifier = CurrentUserNotifier(storage);
        addTearDown(notifier.dispose);
        await Future<void>.delayed(Duration.zero);
        expect(notifier.state, isNull);
        expect(notifier.isLoggedIn, isFalse);

        const user = SharedUserInfo(
          uuid: 'user-1',
          email: 'alice@example.org',
          name: 'Alice',
        );
        notifier.setUser(user);

        expect(notifier.state, user);
        expect(notifier.isLoggedIn, isTrue);
        expect(storage.persistedUser, user.toJson());

        notifier.clearUser();

        expect(notifier.state, isNull);
        expect(notifier.isLoggedIn, isFalse);
      },
    );
  });
}
