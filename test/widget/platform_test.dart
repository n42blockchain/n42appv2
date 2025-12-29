// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/widget_test_helpers.dart';

void main() {
  group('Platform Consistency Tests', () {
    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    group('Android Platform', () {
      testWidgets('should render correctly on Android', (tester) async {
        // Arrange
        debugDefaultTargetPlatformOverride = TargetPlatform.android;

        final widget = Column(
          children: [
            const Text('Android Test'),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Button'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Input'),
            ),
          ],
        );

        // Act
        await tester.pumpWidget(wrapForTest(widget));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Android Test'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('should use Material design on Android', (tester) async {
        // Arrange
        debugDefaultTargetPlatformOverride = TargetPlatform.android;

        final widget = Builder(
          builder: (context) {
            return Text('Platform: ${Theme.of(context).platform}');
          },
        );

        // Act
        await tester.pumpWidget(wrapForTest(widget));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Platform: TargetPlatform.android'), findsOneWidget);
      });

      testWidgets('should handle back button on Android', (tester) async {
        // Arrange
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        bool backPressed = false;

        final widget = WillPopScope(
          onWillPop: () async {
            backPressed = true;
            return false;
          },
          child: const Text('Back Test'),
        );

        // Act
        await tester.pumpWidget(wrapForTest(widget));
        await tester.pumpAndSettle();

        // Simulate back button
        final dynamic widgetsAppState = tester.state(find.byType(WidgetsApp));
        await widgetsAppState.didPopRoute();
        await tester.pump();

        // Assert
        expect(backPressed, true);
      });
    });

    group('iOS Platform', () {
      testWidgets('should render correctly on iOS', (tester) async {
        // Arrange
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

        final widget = Column(
          children: [
            const Text('iOS Test'),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Button'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Input'),
            ),
          ],
        );

        // Act
        await tester.pumpWidget(wrapForTest(widget));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('iOS Test'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('should detect iOS platform', (tester) async {
        // Arrange
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

        final widget = Builder(
          builder: (context) {
            return Text('Platform: ${Theme.of(context).platform}');
          },
        );

        // Act
        await tester.pumpWidget(wrapForTest(widget));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Platform: TargetPlatform.iOS'), findsOneWidget);
      });
    });

    group('Cross-Platform Consistency', () {
      testWidgets('should have same widget structure on both platforms', (tester) async {
        // Arrange
        final widget = Column(
          children: [
            const Text('Header'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Action'),
            ),
            const SizedBox(height: 10),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter email',
              ),
            ),
          ],
        );

        // Test on Android
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        await tester.pumpWidget(wrapForTest(widget));
        await tester.pumpAndSettle();

        final androidWidgetCount = find.byType(Widget).evaluate().length;
        expect(find.text('Header'), findsOneWidget);
        expect(find.text('Action'), findsOneWidget);

        // Test on iOS
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        await tester.pumpWidget(wrapForTest(widget));
        await tester.pumpAndSettle();

        final iosWidgetCount = find.byType(Widget).evaluate().length;
        expect(find.text('Header'), findsOneWidget);
        expect(find.text('Action'), findsOneWidget);

        // Widget counts should be similar (may differ slightly due to platform-specific implementations)
        expect((androidWidgetCount - iosWidgetCount).abs(), lessThan(10));
      });

      testWidgets('should have consistent behavior on both platforms', (tester) async {
        // Arrange
        int tapCount = 0;
        final widget = ElevatedButton(
          onPressed: () => tapCount++,
          child: const Text('Tap Me'),
        );

        // Test on Android
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        await tester.pumpWidget(wrapForTest(widget));
        await tester.tap(find.text('Tap Me'));
        await tester.pump();
        expect(tapCount, 1);

        // Test on iOS
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        await tester.pumpWidget(wrapForTest(widget));
        await tester.tap(find.text('Tap Me'));
        await tester.pump();
        expect(tapCount, 2);
      });

      testWidgets('should handle text input consistently', (tester) async {
        // Arrange
        final controller = TextEditingController();
        final widget = TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Input'),
        );

        // Test on Android
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        await tester.pumpWidget(wrapForTest(widget));
        await tester.enterText(find.byType(TextField), 'Hello Android');
        expect(controller.text, 'Hello Android');

        // Clear
        controller.clear();

        // Test on iOS
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        await tester.pumpWidget(wrapForTest(widget));
        await tester.enterText(find.byType(TextField), 'Hello iOS');
        expect(controller.text, 'Hello iOS');
      });

      testWidgets('should handle scrolling consistently', (tester) async {
        // Arrange
        final widget = ListView.builder(
          itemCount: 100,
          itemBuilder: (context, index) => ListTile(
            title: Text('Item $index'),
          ),
        );

        // Test on Android
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        await tester.pumpWidget(wrapForTest(widget));
        await tester.pumpAndSettle();
        
        expect(find.text('Item 0'), findsOneWidget);
        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.pumpAndSettle();
        expect(find.text('Item 0'), findsNothing);

        // Test on iOS
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        await tester.pumpWidget(wrapForTest(widget));
        await tester.pumpAndSettle();
        
        expect(find.text('Item 0'), findsOneWidget);
        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.pumpAndSettle();
        expect(find.text('Item 0'), findsNothing);
      });
    });
  });
}

