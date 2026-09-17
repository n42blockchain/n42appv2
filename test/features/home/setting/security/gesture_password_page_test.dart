import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gesture_password_widget/gesture_password_widget.dart';
import 'package:n42_wallet/features/home/setting/security/gesture_password_page.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  Future<List<String?>> mount(
    WidgetTester tester, {
    String? oldPassword,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final results = <String?>[];
    await tester.pumpWidget(
      wrapForTest(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              results.add(
                await Navigator.of(context).push<String>(
                  MaterialPageRoute(
                    builder: (_) =>
                        GesturePasswordPage(oldPassword: oldPassword),
                  ),
                ),
              );
            },
            child: const Text('Open gesture password'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open gesture password'));
    await tester.pumpAndSettle();
    return results;
  }

  GesturePasswordWidget gesture(WidgetTester tester) =>
      tester.widget<GesturePasswordWidget>(find.byType(GesturePasswordWidget));

  Future<void> complete(WidgetTester tester, List<int> pattern) async {
    gesture(tester).onComplete!(pattern);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'new gesture requires confirmation and returns matching pattern',
    (tester) async {
      final results = await mount(tester);
      expect(find.text(S.current.g_lock_key17), findsOneWidget);
      expect(find.text(S.current.g_lock_key18), findsOneWidget);
      expect(gesture(tester).answer, isNull);

      await complete(tester, [0, 1, 4, 7]);
      expect(find.text(S.current.g_lock_key19), findsOneWidget);
      expect(gesture(tester).answer, [0, 1, 4, 7]);

      await complete(tester, [0, 1, 4, 7]);
      expect(results, ['0,1,4,7']);
      expect(find.byType(GesturePasswordPage), findsNothing);
    },
  );

  testWidgets('three confirmation mismatches reset the new gesture flow', (
    tester,
  ) async {
    final results = await mount(tester);
    await complete(tester, [0, 1, 4, 7]);

    await complete(tester, [0, 3, 6, 7]);
    expect(find.text(S.current.g_lock_key21('2')), findsOneWidget);
    await complete(tester, [0, 3, 6, 7]);
    expect(find.text(S.current.g_lock_key25('1')), findsOneWidget);
    await complete(tester, [0, 3, 6, 7]);
    expect(find.text(S.current.g_lock_key23), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, S.current.g_key_78));
    await tester.pumpAndSettle();
    expect(find.text(S.current.g_lock_key18), findsOneWidget);
    expect(gesture(tester).answer, isNull);
    expect(results, isEmpty);
  });

  testWidgets('reset verifies old pattern before accepting a new one', (
    tester,
  ) async {
    final results = await mount(tester, oldPassword: '0,1,2,5');
    expect(find.text(S.current.g_lock_key20), findsOneWidget);
    expect(gesture(tester).answer, [0, 1, 2, 5]);

    await complete(tester, [0, 1, 2, 5]);
    expect(find.text(S.current.g_lock_key22), findsOneWidget);
    expect(find.text(S.current.g_lock_key18), findsOneWidget);
    expect(gesture(tester).answer, isNull);

    await complete(tester, [0, 3, 4, 5]);
    expect(find.text(S.current.g_lock_key19), findsOneWidget);
    expect(gesture(tester).answer, [0, 3, 4, 5]);
    await complete(tester, [0, 3, 4, 5]);
    expect(results, ['0,3,4,5']);
  });

  testWidgets('three invalid old patterns close reset without a result', (
    tester,
  ) async {
    final results = await mount(tester, oldPassword: '0,1,2,5');
    for (var attempt = 0; attempt < 3; attempt++) {
      await complete(tester, [0, 3, 6, 7]);
    }
    expect(find.text(S.current.g_lock_key23), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, S.current.g_key_78));
    await tester.pumpAndSettle();
    expect(results, [null]);
    expect(find.byType(GesturePasswordPage), findsNothing);
  });

  testWidgets('back navigation cancels without returning a password', (
    tester,
  ) async {
    final results = await mount(tester);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(results, [null]);
  });
}
