import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/security/phishing_warning_dialog.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  Future<void> mount(
    WidgetTester tester,
    void Function(bool?) onResult, {
    bool nested = false,
    double scale = 1,
    String url = 'https://phishing.example.test/sign',
  }) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    Widget trigger() => Builder(
      builder: (context) => TextButton(
        onPressed: () async =>
            onResult(await showPhishingWarningDialog(context, url)),
        child: const Text('Open warning'),
      ),
    );
    await tester.pumpWidget(
      wrapForTest(
        nested
            ? Navigator(
                onGenerateRoute: (_) => MaterialPageRoute<void>(
                  builder: (_) => Scaffold(body: trigger()),
                ),
              )
            : trigger(),
      ),
    );
    await tester.tap(find.text('Open warning'));
    await tester.pumpAndSettle();
  }

  for (final nested in [false, true]) {
    for (final proceed in [false, true]) {
      testWidgets(
        'warning returns $proceed through ${nested ? 'nested' : 'root'} navigation',
        (tester) async {
          final results = <bool?>[];
          await mount(tester, results.add, nested: nested);
          expect(find.text(S.current.g_phishing_warning_title), findsOneWidget);
          expect(
            find.text('https://phishing.example.test/sign'),
            findsOneWidget,
          );
          await tester.tap(
            find.text(
              proceed
                  ? S.current.g_phishing_proceed_anyway
                  : S.current.g_phishing_go_back,
            ),
          );
          await tester.pumpAndSettle();
          expect(results, [proceed]);
          expect(find.byType(AlertDialog), findsNothing);
          expect(find.text('Open warning'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'outside taps do not consent and system back returns no consent',
    (tester) async {
      final results = <bool?>[];
      await mount(tester, results.add);
      await tester.tapAt(const Offset(2, 2));
      await tester.pumpAndSettle();
      expect(results, isEmpty);
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(results, [null]);
      expect(find.byType(AlertDialog), findsNothing);
    },
  );

  testWidgets('long URLs and enlarged text keep the safe action reachable', (
    tester,
  ) async {
    final results = <bool?>[];
    await mount(
      tester,
      results.add,
      scale: 1.6,
      url: 'https://phishing.example.test/${'long-path/' * 30}',
    );
    expect(tester.takeException(), isNull);
    final safe = find.text(S.current.g_phishing_go_back);
    await tester.ensureVisible(safe);
    await tester.tap(safe);
    await tester.pumpAndSettle();
    expect(results, [false]);
    expect(tester.takeException(), isNull);
  });
}
