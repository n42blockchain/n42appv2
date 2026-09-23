import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/keystore/import_privatekey.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../helpers/widget_test_helpers.dart';

void main() {
  testWidgets(
    'empty private key shows validation error without wallet access',
    (tester) async {
      await _pumpImportPage(tester);

      await tester.tap(find.text(S.current.g_key_78));
      await tester.pumpAndSettle();

      expect(find.text(S.current.g_key_210), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    },
  );

  testWidgets('malformed private key is rejected before native derivation', (
    tester,
  ) async {
    await _pumpImportPage(tester);
    await tester.enterText(find.byType(TextField).first, '!' * 65);

    await tester.tap(find.text(S.current.g_key_78));
    await tester.pumpAndSettle();

    expect(find.text(S.current.g_key_210), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}

Future<void> _pumpImportPage(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(wrapForTest(const ImportPrivatekey()));
  await tester.pumpAndSettle();
}
