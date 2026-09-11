import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/security/totp_util.dart';
import 'package:n42_wallet/features/home/setting/security/google_auth_setup_page.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  Future<void> mount(WidgetTester tester, void Function(String?) result) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async => result(
              await Navigator.of(context).push<String>(
                MaterialPageRoute(builder: (_) => const GoogleAuthSetupPage()),
              ),
            ),
            child: const Text('Set up authenticator'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Set up authenticator'));
    await tester.pumpAndSettle();
  }

  Finder keyText() => find.byWidgetPredicate(
    (widget) =>
        widget is Text && RegExp(r'^[A-Z2-7]{32}$').hasMatch(widget.data ?? ''),
  );
  Future<String> revealKey(WidgetTester tester) async {
    await tester.ensureVisible(find.text(S.current.g_google_auth_key3));
    await tester.tap(find.text(S.current.g_google_auth_key3));
    await tester.pumpAndSettle();
    return tester.widget<Text>(keyText()).data!;
  }

  testWidgets(
    'setup exposes QR, expandable manual key and clipboard feedback',
    (tester) async {
      final results = <String?>[];
      final copied = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied.add((call.arguments as Map)['text'] as String);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await mount(tester, results.add);
      expect(find.byType(QrImageView), findsOneWidget);
      expect(keyText(), findsNothing);
      final secret = await revealKey(tester);
      await tester.tap(keyText());
      await tester.pumpAndSettle();
      expect(copied, [secret]);
      expect(find.text(S.current.g_google_auth_key8), findsOneWidget);
      await tester.tap(find.text(S.current.g_google_auth_key3));
      await tester.pumpAndSettle();
      expect(keyText(), findsNothing);
      expect(results, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'invalid code stays on setup, editing clears error, keyboard submit verifies',
    (tester) async {
      final results = <String?>[];
      await mount(tester, results.add);
      final secret = await revealKey(tester);
      await tester.enterText(find.byType(TextField), '123');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text(S.current.g_google_auth_key6), findsOneWidget);
      expect(results, isEmpty);
      await tester.enterText(find.byType(TextField), TotpUtil.generate(secret));
      await tester.pump();
      expect(find.text(S.current.g_google_auth_key6), findsNothing);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(results, [secret]);
      expect(find.byType(GoogleAuthSetupPage), findsNothing);
    },
  );

  testWidgets('confirmation button returns only a verified secret', (
    tester,
  ) async {
    final results = <String?>[];
    await mount(tester, results.add);
    final secret = await revealKey(tester);
    await tester.enterText(find.byType(TextField), TotpUtil.generate(secret));
    tester.testTextInput.hide();
    final confirm = find.widgetWithText(ElevatedButton, S.current.g_key_78);
    await tester.ensureVisible(confirm);
    await tester.tap(confirm);
    await tester.pumpAndSettle();
    expect(results, [secret]);
    expect(find.text('Set up authenticator'), findsOneWidget);
  });

  testWidgets('duplicate confirmation cannot pop the page behind setup', (
    tester,
  ) async {
    final results = <String?>[];
    await mount(tester, results.add);
    final secret = await revealKey(tester);
    await tester.enterText(find.byType(TextField), TotpUtil.generate(secret));
    final confirm = tester
        .widget<ElevatedButton>(find.byType(ElevatedButton))
        .onPressed!;
    confirm();
    confirm();
    await tester.pumpAndSettle();
    expect(results, [secret]);
    expect(find.text('Set up authenticator'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('leaving setup without verification returns no binding', (
    tester,
  ) async {
    final results = <String?>[];
    await mount(tester, results.add);
    await revealKey(tester);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(results, [null]);
    expect(find.byType(GoogleAuthSetupPage), findsNothing);
  });
}
