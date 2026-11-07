import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/import/import_one.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/create_password.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/create_finish.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../test/helpers/widget_test_helpers.dart';

// Real form, disposable in-memory provider, invalid inputs only. No persistence,
// key generation, network calls or signing is reached by these cases.
void registerWalletFormCases() {
  void useControlledKeyboard() {
    // enterText injects framework editing values, not Android IME keystrokes.
    // Keep both sides on the test input channel so the real IME cannot commit
    // its previous value when focus moves. This suite tests form validation;
    // real keyboard/IME behavior remains a separate device acceptance item.
    final input = TestWidgetsFlutterBinding.instance.testTextInput;
    if (!input.isRegistered) {
      input.register();
      addTearDown(input.unregister);
    }
  }

  Future<void> open(WidgetTester tester) async {
    useControlledKeyboard();
    final store = WalletActionProvider();
    await tester.pumpWidget(
      wrapForTest(
        CreatePassword(WalletInfo(walletUuid: 'synthetic-form-only')),
        overrides: [wapBridgeProvider.overrideWith((ref) => store)],
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> enter(WidgetTester tester, int field, String value) async {
    final target = find.byType(TextField).at(field);
    await tester.ensureVisible(target);
    // A real Android IME can attach after showKeyboard returns. Settle focus
    // before injecting the fixture, then deliver it before dismissing the IME.
    await tester.showKeyboard(target);
    await tester.pumpAndSettle();
    await tester.enterText(target, value);
    await tester.pumpAndSettle();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(target).controller!.text == value,
      isTrue,
      reason:
          'Synthetic field $field did not retain the entered fixture '
          '(length ${tester.widget<TextField>(target).controller!.text.length}, '
          'expected ${value.length}).',
    );
  }

  Future<void> reject(WidgetTester tester, String error) async {
    final before = find.text(error).evaluate().length;
    await tester.tap(find.text(S.current.g_key_115));
    for (var attempt = 0; attempt < 100; attempt++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.text(error).evaluate().length > before) break;
    }
    expect(
      find.text(error).evaluate().length,
      greaterThan(before),
      reason: 'Expected inline validation did not appear after submit.',
    );
    expect(find.byType(CreatePassword), findsOneWidget);
    expect(find.byType(CreateFinish), findsNothing);
    expect(tester.takeException(), isNull);
    // Let the native toast lifetime end before the next case or disposal.
    await tester.pump(const Duration(seconds: 8));
  }

  testWidgets('WLT-02 rejects invalid mnemonic formats', (tester) async {
    useControlledKeyboard();
    await tester.runAsync(
      () => Clipboard.setData(const ClipboardData(text: '')),
    );
    final store = WalletActionProvider();
    await tester.pumpWidget(
      wrapForTest(
        const ImportOne(),
        overrides: [wapBridgeProvider.overrideWith((ref) => store)],
      ),
    );
    await tester.pumpAndSettle();
    await enter(tester, 0, 'this is not a valid mnemonic');
    await tester.tap(find.text(S.current.g_key_11));
    for (var attempt = 0; attempt < 200; attempt++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.text(S.current.w_key_12).evaluate().isNotEmpty) break;
    }
    expect(find.text(S.current.w_key_12), findsOneWidget);
    expect(find.byType(ImportOne), findsOneWidget);
    expect(find.byType(CreatePassword), findsNothing);
    expect(store.walletInfoLsit, isEmpty);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 8));
  });

  testWidgets('WLT-02 validates wallet name input', (tester) async {
    await open(tester);
    await enter(tester, 0, '   ');
    await reject(tester, S.current.g_key_wallet_c34);
  });

  testWidgets('WLT-01 validates wallet password requirements', (tester) async {
    await open(tester);
    await reject(tester, S.current.g_key_21);
    await enter(tester, 1, 'short');
    await reject(tester, S.current.rest_Choose_password);
    await enter(tester, 1, 'SyntheticPass123!');
    await enter(tester, 2, 'DifferentPass123!');
    await reject(tester, S.current.g_key_25);
  });
}
