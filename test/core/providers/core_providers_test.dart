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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:n42_wallet/shared/domain/entities/wallet_info.dart';

class _MemorySpUtil extends SPUtil {
  Map<String, dynamic>? storedUser;

  @override
  Future<Map<String, dynamic>?> getUserInfo() async => storedUser;

  @override
  Future<void> saveUserInfoJson(Map<String, dynamic> info) async {
    storedUser = Map<String, dynamic>.of(info);
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

  group('SharedUserInfo', () {
    const alice = SharedUserInfo(
      uuid: 'alice-id',
      email: 'alice@example.com',
      name: 'Alice',
      avatarUrl: 'https://example.com/alice.png',
      token: 'access-token',
      desc: 'Wallet owner',
    );

    test('compares every profile field and round-trips JSON', () {
      expect(
        alice,
        const SharedUserInfo(
          uuid: 'alice-id',
          email: 'alice@example.com',
          name: 'Alice',
          avatarUrl: 'https://example.com/alice.png',
          token: 'access-token',
          image: null,
          desc: 'Wallet owner',
        ),
      );
      expect(SharedUserInfo.fromJson(alice.toJson()), alice);
      expect(
        const SharedUserInfo(uuid: 'alice-id', email: 'other@example.com'),
        isNot(alice),
      );
    });

    test('reads the legacy image field as avatar URL', () {
      final user = SharedUserInfo.fromJson({
        'uuid': 'legacy-id',
        'email': 'legacy@example.com',
        'image': 'https://example.com/legacy.png',
      });

      expect(user.avatarUrl, 'https://example.com/legacy.png');
      expect(user.image, 'https://example.com/legacy.png');
      expect(user.isLoggedIn, isTrue);
    });
  });

  group('CurrentUserNotifier', () {
    test('loads, publishes, persists, and clears the active profile', () async {
      final storage = _MemorySpUtil()
        ..storedUser = const SharedUserInfo(
          uuid: 'saved-id',
          email: 'saved@example.com',
          name: 'Saved user',
        ).toJson();
      final notifier = CurrentUserNotifier(storage);
      addTearDown(notifier.dispose);

      await Future<void>.delayed(Duration.zero);
      expect(notifier.state?.uuid, 'saved-id');
      expect(notifier.isLoggedIn, isTrue);

      const nextUser = SharedUserInfo(
        uuid: 'next-id',
        email: 'next@example.com',
        name: 'Next user',
      );
      notifier.setUser(nextUser);
      expect(notifier.state, nextUser);
      expect(storage.storedUser, nextUser.toJson());

      notifier.clearUser();
      expect(notifier.state, isNull);
      expect(notifier.isLoggedIn, isFalse);
    });
  });
}
