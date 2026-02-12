// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// N42 App Widget Test

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Basic Widget Tests', () {
    testWidgets('MaterialApp should render correctly', (WidgetTester tester) async {
      // Build a simple MaterialApp
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('N42 Wallet'),
              ),
            ),
          ),
        ),
      );

      // Verify that the text is rendered
      expect(find.text('N42 Wallet'), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should support dark theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          themeMode: ThemeMode.dark,
          darkTheme: ThemeData.dark(),
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: Text(
                    'Theme: ${Theme.of(context).brightness}',
                  ),
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('Theme: Brightness.dark'), findsOneWidget);
    });

    testWidgets('should support light theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          themeMode: ThemeMode.light,
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: Text(
                    'Theme: ${Theme.of(context).brightness}',
                  ),
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('Theme: Brightness.light'), findsOneWidget);
    });
  });

  group('Riverpod Integration', () {
    testWidgets('ProviderScope should work correctly', (WidgetTester tester) async {
      final testProvider = StateProvider<int>((ref) => 0);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                final value = ref.watch(testProvider);
                return Scaffold(
                  body: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Value: $value'),
                      ElevatedButton(
                        onPressed: () => ref.read(testProvider.notifier).state++,
                        child: const Text('Increment'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Initial value
      expect(find.text('Value: 0'), findsOneWidget);

      // Tap increment button
      await tester.tap(find.text('Increment'));
      await tester.pump();

      // Value should be updated
      expect(find.text('Value: 1'), findsOneWidget);
    });
  });
}
