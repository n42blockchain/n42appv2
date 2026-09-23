import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/widgets/wallet_chain_info_board.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../helpers/widget_test_helpers.dart';

void main() {
  testWidgets('asset board exposes balances and routes each wallet action', (
    tester,
  ) async {
    final tapped = <String>[];
    await _pumpBoard(
      tester,
      xmlLockInfoTap: () => tapped.add('lock'),
      sendTap: () => tapped.add('send'),
      receiveTap: () => tapped.add('receive'),
      browserTap: () => tapped.add('browser'),
    );

    expect(find.text('0.25 BTC'), findsOneWidget);
    expect(find.text('\$12,500.00'), findsOneWidget);
    expect(find.textContaining(S.current.g_key_xml_0), findsOneWidget);

    await tester.tap(find.text(S.current.g_key_48));
    await tester.tap(find.text(S.current.g_key_33));
    await tester.tap(find.text(S.current.g_key_196));
    await tester.tap(find.byIcon(Icons.info_outline));

    expect(tapped, ['send', 'receive', 'browser', 'lock']);
  });

  testWidgets('asset board omits lock detail when no action is available', (
    tester,
  ) async {
    await _pumpBoard(tester);

    expect(find.textContaining(S.current.g_key_xml_0), findsNothing);
    expect(find.byIcon(Icons.info_outline), findsNothing);
  });
}

Future<void> _pumpBoard(
  WidgetTester tester, {
  VoidCallback? xmlLockInfoTap,
  VoidCallback? sendTap,
  VoidCallback? receiveTap,
  VoidCallback? browserTap,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    wrapForTest(
      Scaffold(
        body: SingleChildScrollView(
          child: WalletChainInfoBoard(
            address: 'bc1qexampleaddress',
            coinType: 'BTC',
            balanceStr: '0.25 BTC',
            balanceDollarStr: '\$12,500.00',
            marketValueStr: '\$50,000.00 / BTC',
            lockAmountStr: '0.05 BTC',
            xmlLockInfoTap: xmlLockInfoTap,
            sendTap: sendTap,
            receiveTap: receiveTap,
            browserTap: browserTap,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
