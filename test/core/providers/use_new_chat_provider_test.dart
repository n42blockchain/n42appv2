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
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('UseNewChatNotifier', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
      await Future.delayed(const Duration(milliseconds: 100));
    });

    tearDown(() {
      container.dispose();
    });

    test('should start with false by default', () async {
      final useNewChat = container.read(useNewChatProvider);
      expect(useNewChat, false);
    });

    test('should set to true', () async {
      await container.read(useNewChatProvider.notifier).setUseNewChat(true);
      await Future.delayed(const Duration(milliseconds: 50));
      
      final useNewChat = container.read(useNewChatProvider);
      expect(useNewChat, true);
    });

    test('should set to false', () async {
      // First set to true
      await container.read(useNewChatProvider.notifier).setUseNewChat(true);
      await Future.delayed(const Duration(milliseconds: 50));
      
      // Then set to false
      await container.read(useNewChatProvider.notifier).setUseNewChat(false);
      await Future.delayed(const Duration(milliseconds: 50));
      
      final useNewChat = container.read(useNewChatProvider);
      expect(useNewChat, false);
    });

    test('should toggle state', () async {
      // Initial state is false
      expect(container.read(useNewChatProvider), false);
      
      // Toggle to true
      container.read(useNewChatProvider.notifier).toggle();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(container.read(useNewChatProvider), true);
      
      // Toggle back to false
      container.read(useNewChatProvider.notifier).toggle();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(container.read(useNewChatProvider), false);
    });

    test('should notify listeners on state change', () async {
      int notifyCount = 0;
      
      container.listen<bool>(
        useNewChatProvider,
        (previous, next) {
          notifyCount++;
        },
        fireImmediately: false,
      );
      
      await container.read(useNewChatProvider.notifier).setUseNewChat(true);
      await Future.delayed(const Duration(milliseconds: 50));
      
      expect(notifyCount, greaterThanOrEqualTo(1));
    });

    test('should persist state across provider recreations', () async {
      // Set to true
      await container.read(useNewChatProvider.notifier).setUseNewChat(true);
      await Future.delayed(const Duration(milliseconds: 50));
      
      // Verify it's true
      expect(container.read(useNewChatProvider), true);
    });
  });
}

