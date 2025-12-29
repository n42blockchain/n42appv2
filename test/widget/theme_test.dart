// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/widget_test_helpers.dart';

void main() {
  group('Theme Tests', () {
    group('Light Theme', () {
      testWidgets('should render with light background', (tester) async {
        // Arrange
        final widget = Container(
          color: Colors.white,
          child: const Text('Light Mode'),
        );

        // Act
        await tester.pumpWidget(wrapForTest(
          widget,
          themeMode: ThemeMode.light,
        ));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Light Mode'), findsOneWidget);
      });

      testWidgets('should use light theme colors', (tester) async {
        // Arrange
        final widget = Builder(
          builder: (context) {
            final theme = Theme.of(context);
            return Text(
              'Brightness: ${theme.brightness}',
              key: const Key('brightness_text'),
            );
          },
        );

        // Act
        await tester.pumpWidget(wrapForTest(
          widget,
          themeMode: ThemeMode.light,
        ));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Brightness: Brightness.light'), findsOneWidget);
      });
    });

    group('Dark Theme', () {
      testWidgets('should render with dark background', (tester) async {
        // Arrange
        final widget = Container(
          color: Colors.black,
          child: const Text('Dark Mode'),
        );

        // Act
        await tester.pumpWidget(wrapForTest(
          widget,
          themeMode: ThemeMode.dark,
        ));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Dark Mode'), findsOneWidget);
      });

      testWidgets('should use dark theme colors', (tester) async {
        // Arrange
        final widget = Builder(
          builder: (context) {
            final theme = Theme.of(context);
            return Text(
              'Brightness: ${theme.brightness}',
              key: const Key('brightness_text'),
            );
          },
        );

        // Act
        await tester.pumpWidget(wrapForTest(
          widget,
          themeMode: ThemeMode.dark,
        ));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Brightness: Brightness.dark'), findsOneWidget);
      });
    });

    group('Theme Consistency', () {
      testWidgets('should apply same widget structure in both themes', (tester) async {
        // Arrange
        final widget = Column(
          children: [
            const Text('Header'),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Button'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Input'),
            ),
          ],
        );

        // Test Light Theme
        await tester.pumpWidget(wrapForTest(widget, themeMode: ThemeMode.light));
        await tester.pumpAndSettle();

        expect(find.text('Header'), findsOneWidget);
        expect(find.text('Button'), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);

        // Test Dark Theme
        await tester.pumpWidget(wrapForTest(widget, themeMode: ThemeMode.dark));
        await tester.pumpAndSettle();

        expect(find.text('Header'), findsOneWidget);
        expect(find.text('Button'), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('should maintain functionality in both themes', (tester) async {
        // Arrange
        bool buttonPressed = false;
        final widget = ElevatedButton(
          onPressed: () => buttonPressed = true,
          child: const Text('Press Me'),
        );

        // Test Light Theme
        await tester.pumpWidget(wrapForTest(widget, themeMode: ThemeMode.light));
        await tester.tap(find.text('Press Me'));
        expect(buttonPressed, true);

        // Reset
        buttonPressed = false;

        // Test Dark Theme
        await tester.pumpWidget(wrapForTest(widget, themeMode: ThemeMode.dark));
        await tester.tap(find.text('Press Me'));
        expect(buttonPressed, true);
      });
    });

    group('Theme Switching', () {
      testWidgets('should switch theme dynamically', (tester) async {
        // Arrange
        ThemeMode currentMode = ThemeMode.light;

        final widget = StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              themeMode: currentMode,
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    return Column(
                      children: [
                        Text('Mode: ${Theme.of(context).brightness}'),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              currentMode = currentMode == ThemeMode.light
                                  ? ThemeMode.dark
                                  : ThemeMode.light;
                            });
                          },
                          child: const Text('Toggle'),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        );

        // Act & Assert - Initial Light
        await tester.pumpWidget(widget);
        await tester.pumpAndSettle();
        expect(find.text('Mode: Brightness.light'), findsOneWidget);

        // Toggle to Dark
        await tester.tap(find.text('Toggle'));
        await tester.pumpAndSettle();
        expect(find.text('Mode: Brightness.dark'), findsOneWidget);

        // Toggle back to Light
        await tester.tap(find.text('Toggle'));
        await tester.pumpAndSettle();
        expect(find.text('Mode: Brightness.light'), findsOneWidget);
      });
    });
  });
}

