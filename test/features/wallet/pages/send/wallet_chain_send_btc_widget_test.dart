import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_btc.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../helpers/widget_test_helpers.dart';

class _LocalWallet extends WalletActionProvider {
  @override
  Future<bool> getBalanceWithCoinModel(CoinModel coinModel) async => false;
}

CoinModel _litecoin() {
  final coin = CoinModel.fromMap({
    'coinType': 'LTC',
    'miniName': 'LTC',
    'name': 'Litecoin',
    'unit': 'LTC',
    'decimals': 8,
    'blockchainType': 'Bitcoin',
    'path': {'legacy': "m/44'/2'/0'/0/0"},
  });
  coin
    ..balance = BigInt.from(250000000)
    ..address = 'ltc1qsenderaddress';
  return coin;
}

Future<void> _pumpLitecoinSendPage(WidgetTester tester) async {
  final wallet = _LocalWallet();
  await tester.pumpWidget(
    wrapForTest(
      WalletChainSendBtc(_litecoin()),
      overrides: [wapBridgeProvider.overrideWith((ref) => wallet)],
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('DApp send keeps its requested recipient and amount locked', (
    tester,
  ) async {
    final wallet = _LocalWallet();
    const recipient = 'ltc1qrequestedrecipient';

    await tester.pumpWidget(
      wrapForTest(
        WalletChainSendBtc(_litecoin(), toAddress: recipient, toAmount: '0.25'),
        overrides: [wapBridgeProvider.overrideWith((ref) => wallet)],
      ),
    );
    await tester.pumpAndSettle();

    final fields = tester.widgetList<TextField>(find.byType(TextField));
    expect(
      fields.any(
        (field) =>
            field.enabled == false && field.controller?.text == recipient,
      ),
      isTrue,
    );
    expect(
      fields.any(
        (field) => field.enabled == false && field.controller?.text == '0.25',
      ),
      isTrue,
    );
    expect(find.text('2.5 LTC'), findsOneWidget);
    expect(find.byIcon(Icons.local_gas_station), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('amount above available balance is rejected before UTXO lookup', (
    tester,
  ) async {
    await _pumpLitecoinSendPage(tester);

    await tester.enterText(find.byType(TextField).at(1), '3');
    await tester.pump(const Duration(milliseconds: 301));

    final context = tester.element(find.byType(WalletChainSendBtc));
    expect(find.text(S.of(context).g_key_47), findsOneWidget);

    await tester.tap(find.text(S.of(context).g_key_48));
    await tester.pumpAndSettle();

    expect(Navigator.of(context).canPop(), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('non-numeric amount shows validation feedback', (tester) async {
    await _pumpLitecoinSendPage(tester);

    await tester.enterText(find.byType(TextField).at(1), 'not-a-number');
    await tester.pump(const Duration(milliseconds: 301));

    final context = tester.element(find.byType(WalletChainSendBtc));
    expect(find.text(S.of(context).g_key_134), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
