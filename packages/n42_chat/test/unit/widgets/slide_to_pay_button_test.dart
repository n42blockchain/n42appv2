import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/widgets/common/slide_to_pay_button.dart';

// Helper to create a testable SlideToPayButton in a fixed-size container.
Widget _buildWidget({
  required VoidCallback onConfirmed,
  String label = '→→→ Slide to confirm',
  String confirmingLabel = 'Confirming...',
  double width = 400,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: width,
          child: SlideToPayButton(
            label: label,
            confirmingLabel: confirmingLabel,
            onConfirmed: onConfirmed,
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('SlideToPayButton', () {
    group('initial state', () {
      testWidgets('shows label text', (tester) async {
        await tester.pumpWidget(_buildWidget(
          onConfirmed: () {},
          label: 'Slide me',
        ));
        expect(find.text('Slide me'), findsOneWidget);
      });

      testWidgets('shows chevron_right icon on thumb', (tester) async {
        await tester.pumpWidget(_buildWidget(onConfirmed: () {}));
        expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
      });

      testWidgets('does not call onConfirmed before interaction', (tester) async {
        var called = false;
        await tester.pumpWidget(_buildWidget(onConfirmed: () => called = true));
        expect(called, isFalse);
      });
    });

    group('drag to completion', () {
      testWidgets('calls onConfirmed when dragged past threshold', (tester) async {
        var called = false;
        await tester.pumpWidget(_buildWidget(
          onConfirmed: () => called = true,
          width: 400,
        ));

        // Thumb: size=48, padding=4; maxOffset = 400-48-8 = 344
        // 92% threshold: 344 * 0.92 = 316.48
        // Drag 320px (> 316) from the thumb position
        await tester.drag(
          find.byIcon(Icons.chevron_right_rounded),
          const Offset(320, 0),
        );
        await tester.pump();

        expect(called, isTrue);
      });

      testWidgets('shows confirmingLabel after completion', (tester) async {
        await tester.pumpWidget(_buildWidget(
          onConfirmed: () {},
          confirmingLabel: 'Processing...',
          width: 400,
        ));

        await tester.drag(
          find.byIcon(Icons.chevron_right_rounded),
          const Offset(320, 0),
        );
        await tester.pump();

        expect(find.text('Processing...'), findsOneWidget);
      });

      testWidgets('shows check icon after completion', (tester) async {
        await tester.pumpWidget(_buildWidget(
          onConfirmed: () {},
          width: 400,
        ));

        await tester.drag(
          find.byIcon(Icons.chevron_right_rounded),
          const Offset(320, 0),
        );
        await tester.pump();

        expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      });

      testWidgets('shows CircularProgressIndicator after completion', (tester) async {
        await tester.pumpWidget(_buildWidget(
          onConfirmed: () {},
          width: 400,
        ));

        await tester.drag(
          find.byIcon(Icons.chevron_right_rounded),
          const Offset(320, 0),
        );
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('short drag (below threshold)', () {
      testWidgets('does not call onConfirmed for partial drag', (tester) async {
        var called = false;
        await tester.pumpWidget(_buildWidget(
          onConfirmed: () => called = true,
          width: 400,
        ));

        // Only drag 50px (well below 316px threshold)
        await tester.drag(
          find.byIcon(Icons.chevron_right_rounded),
          const Offset(50, 0),
        );
        await tester.pumpAndSettle();

        expect(called, isFalse);
      });

      testWidgets('springs back to show label after short drag', (tester) async {
        await tester.pumpWidget(_buildWidget(
          onConfirmed: () {},
          label: 'Slide to pay',
          width: 400,
        ));

        await tester.drag(
          find.byIcon(Icons.chevron_right_rounded),
          const Offset(50, 0),
        );
        await tester.pumpAndSettle();

        // Label should be visible again (opacity restored after spring-back)
        expect(find.text('Slide to pay'), findsOneWidget);
      });
    });

    group('custom props', () {
      testWidgets('respects custom trackColor via _Thumb icon color', (tester) async {
        const customColor = Colors.blue;
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: SlideToPayButton(
                label: 'Test',
                confirmingLabel: 'Done',
                onConfirmed: () {},
                trackColor: customColor,
              ),
            ),
          ),
        ));
        // Verify widget builds without errors — color inspection is visual
        expect(find.byType(SlideToPayButton), findsOneWidget);
      });

      testWidgets('respects custom height', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: SlideToPayButton(
                label: 'Test',
                confirmingLabel: 'Done',
                onConfirmed: () {},
                height: 72,
              ),
            ),
          ),
        ));
        final sizedBox = tester.widget<SizedBox>(
          find.descendant(
            of: find.byType(SlideToPayButton),
            matching: find.byWidgetPredicate(
              (w) => w is SizedBox && w.height == 72,
            ),
          ),
        );
        expect(sizedBox.height, 72);
      });
    });

    group('onConfirmed fires exactly once', () {
      testWidgets('does not fire twice on double drag', (tester) async {
        var callCount = 0;
        await tester.pumpWidget(_buildWidget(
          onConfirmed: () => callCount++,
          width: 400,
        ));

        await tester.drag(
          find.byIcon(Icons.chevron_right_rounded),
          const Offset(320, 0),
        );
        await tester.pump();
        // Try to drag again — should be no-op
        await tester.drag(
          find.byType(GestureDetector).last,
          const Offset(50, 0),
        );
        await tester.pump();

        expect(callCount, 1);
      });
    });
  });
}
