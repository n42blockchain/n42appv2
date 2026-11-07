import 'package:flutter/material.dart';
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
  Future<void> open(WidgetTester tester) async {
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
    await tester.enterText(target, value);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
  }

  Future<void> reject(WidgetTester tester, String error) async {
    final before = find.text(error).evaluate().length;
    await tester.tap(find.text(S.current.g_key_115));
    await tester.pumpAndSettle();
    expect(find.text(error).evaluate().length, greaterThan(before));
    expect(find.byType(CreatePassword), findsOneWidget);
    expect(find.byType(CreateFinish), findsNothing);
    expect(tester.takeException(), isNull);
    // Let the native toast lifetime end before the next case or disposal.
    await tester.pump(const Duration(seconds: 8));
  }

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
