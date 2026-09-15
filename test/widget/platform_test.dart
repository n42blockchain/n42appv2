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
  group('Platform Consistency Tests', () {
    group('Widget Structure', () {
      testWidgets('should render basic widgets correctly', (tester) async {
        // Arrange
        final widget = Column(
          children: [
            const Text('Test Header'),
            ElevatedButton(onPressed: () {}, child: const Text('Button')),
            const TextField(decoration: InputDecoration(labelText: 'Input')),
          ],
        );

        // Act
        await tester.pumpWidget(wrapWithMaterial(widget));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Test Header'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('should detect platform from theme', (tester) async {
        // Arrange
        final widget = Builder(
          builder: (context) {
            final platform = Theme.of(context).platform;
            return Text('Platform: $platform');
          },
        );

        // Act
        await tester.pumpWidget(wrapWithMaterial(widget));
        await tester.pumpAndSettle();

        // Assert - Platform should be detected (TargetPlatform enum)
        expect(find.textContaining('Platform: TargetPlatform'), findsOneWidget);
      });
    });

    group('Behavior Consistency', () {
      testWidgets('should handle button tap', (tester) async {
        // Arrange
        int tapCount = 0;
        final widget = ElevatedButton(
          onPressed: () => tapCount++,
          child: const Text('Tap Me'),
        );

        // Act
        await tester.pumpWidget(wrapWithMaterial(widget));
        await tester.tap(find.text('Tap Me'));
        await tester.pump();

        // Assert
        expect(tapCount, 1);
      });

      testWidgets('should handle text input', (tester) async {
        // Arrange
        final controller = TextEditingController();
        final widget = TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Input'),
        );

        // Act
        await tester.pumpWidget(wrapWithMaterial(widget));
        await tester.enterText(find.byType(TextField), 'Hello World');

        // Assert
        expect(controller.text, 'Hello World');
      });

      testWidgets('should handle scrolling', (tester) async {
        // Arrange
        final widget = ListView.builder(
          itemCount: 100,
          itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
        );

        // Act
        await tester.pumpWidget(wrapWithMaterial(widget));
        await tester.pumpAndSettle();

        // Initially item 0 should be visible
        expect(find.text('Item 0'), findsOneWidget);

        // Scroll down
        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.pumpAndSettle();

        // Item 0 should no longer be visible
        expect(find.text('Item 0'), findsNothing);
      });
    });

    group('Form Interactions', () {
      testWidgets('should validate form fields', (tester) async {
        // Arrange
        final formKey = GlobalKey<FormState>();
        String? savedEmail;

        final widget = Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  return null;
                },
                onSaved: (value) => savedEmail = value,
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    formKey.currentState?.save();
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        );

        // Act - Submit without input
        await tester.pumpWidget(wrapWithMaterial(widget));
        await tester.tap(find.text('Submit'));
        await tester.pumpAndSettle();

        // Assert - Validation error should show
        expect(find.text('Email is required'), findsOneWidget);

        // Act - Enter valid email and submit
        await tester.enterText(find.byType(TextFormField), 'test@example.com');
        await tester.tap(find.text('Submit'));
        await tester.pumpAndSettle();

        // Assert - No validation error and email should be saved
        expect(find.text('Email is required'), findsNothing);
        expect(savedEmail, 'test@example.com');
      });
    });

    group('Navigation', () {
      testWidgets('should navigate to new page', (tester) async {
        // Arrange
        final widget = MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const Scaffold(body: Text('Second Page')),
                    ),
                  );
                },
                child: const Text('Go to Second'),
              ),
            ),
          ),
        );

        // Act
        await tester.pumpWidget(widget);
        await tester.tap(find.text('Go to Second'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Second Page'), findsOneWidget);
      });

      testWidgets('should navigate back', (tester) async {
        // Arrange
        final widget = MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        body: Builder(
                          builder: (ctx) => ElevatedButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Go Back'),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('Go to Second'),
              ),
            ),
          ),
        );

        // Act - Navigate forward
        await tester.pumpWidget(widget);
        await tester.tap(find.text('Go to Second'));
        await tester.pumpAndSettle();

        // Assert - On second page
        expect(find.text('Go Back'), findsOneWidget);

        // Act - Navigate back
        await tester.tap(find.text('Go Back'));
        await tester.pumpAndSettle();

        // Assert - Back to first page
        expect(find.text('Go to Second'), findsOneWidget);
      });
    });
  });
}
