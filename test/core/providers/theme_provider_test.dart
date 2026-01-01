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
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('ThemeModeNotifier', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
      // 等待异步初始化
      await Future.delayed(const Duration(milliseconds: 100));
    });

    tearDown(() {
      container.dispose();
    });

    test('should start with system theme by default', () async {
      final themeMode = container.read(themeModeProvider);
      expect(themeMode, ThemeMode.system);
    });

    test('should set light theme', () async {
      container.read(themeModeProvider.notifier).setTheme(ThemeMode.light);
      await Future.delayed(const Duration(milliseconds: 50));
      
      final themeMode = container.read(themeModeProvider);
      expect(themeMode, ThemeMode.light);
    });

    test('should set dark theme', () async {
      container.read(themeModeProvider.notifier).setTheme(ThemeMode.dark);
      await Future.delayed(const Duration(milliseconds: 50));
      
      final themeMode = container.read(themeModeProvider);
      expect(themeMode, ThemeMode.dark);
    });

    test('should set system theme', () async {
      // First set to dark
      container.read(themeModeProvider.notifier).setTheme(ThemeMode.dark);
      await Future.delayed(const Duration(milliseconds: 50));
      
      // Then set to system
      container.read(themeModeProvider.notifier).setTheme(ThemeMode.system);
      await Future.delayed(const Duration(milliseconds: 50));
      
      final themeMode = container.read(themeModeProvider);
      expect(themeMode, ThemeMode.system);
    });

    test('should persist theme mode within same session', () async {
      // Set to dark
      container.read(themeModeProvider.notifier).setTheme(ThemeMode.dark);
      await Future.delayed(const Duration(milliseconds: 50));
      
      // Verify it's dark
      expect(container.read(themeModeProvider), ThemeMode.dark);
      
      // Change to light
      container.read(themeModeProvider.notifier).setTheme(ThemeMode.light);
      await Future.delayed(const Duration(milliseconds: 50));
      
      // Verify it's light
      expect(container.read(themeModeProvider), ThemeMode.light);
    });

    test('should notify listeners on theme change', () async {
      int notifyCount = 0;
      
      container.listen<ThemeMode>(
        themeModeProvider,
        (previous, next) {
          notifyCount++;
        },
        fireImmediately: false,
      );
      
      container.read(themeModeProvider.notifier).setTheme(ThemeMode.dark);
      await Future.delayed(const Duration(milliseconds: 50));
      
      expect(notifyCount, greaterThanOrEqualTo(1));
    });

    test('should cycle through all theme modes', () async {
      final modes = [ThemeMode.light, ThemeMode.dark, ThemeMode.system];
      
      for (final mode in modes) {
        container.read(themeModeProvider.notifier).setTheme(mode);
        await Future.delayed(const Duration(milliseconds: 50));
        
        final currentMode = container.read(themeModeProvider);
        expect(currentMode, mode);
      }
    });
  });

  group('Theme Mode Integration', () {
    testWidgets('MaterialApp should respond to theme changes', (tester) async {
      final container = ProviderContainer();
      
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Consumer(
            builder: (context, ref, child) {
              final themeMode = ref.watch(themeModeProvider);
              return MaterialApp(
                themeMode: themeMode,
                theme: ThemeData.light(),
                darkTheme: ThemeData.dark(),
                home: Builder(
                  builder: (context) {
                    return Scaffold(
                      body: Text('Brightness: ${Theme.of(context).brightness}'),
                    );
                  },
                ),
              );
            },
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Initial state (system - defaults to light in tests)
      expect(find.textContaining('Brightness:'), findsOneWidget);
      
      // Change to dark
      container.read(themeModeProvider.notifier).setTheme(ThemeMode.dark);
      await tester.pumpAndSettle();
      
      expect(find.text('Brightness: Brightness.dark'), findsOneWidget);
      
      // Change to light
      container.read(themeModeProvider.notifier).setTheme(ThemeMode.light);
      await tester.pumpAndSettle();
      
      expect(find.text('Brightness: Brightness.light'), findsOneWidget);
      
      container.dispose();
    });
  });
}

