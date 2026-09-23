import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_xrp.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../helpers/widget_test_helpers.dart';

class _OfflineWalletProvider extends WalletActionProvider {
  @override
  Future<bool> getBalanceWithCoinModel(CoinModel coinModel) async => false;

  @override
  void calculateBalanceWidthCoinModel() {}

  @override
  void refresh() {}
}

CoinModel _xrpCoin() => CoinModel()
  ..coin = {
    'coinType': 'XRP',
    'blockchainType': 'Ripple',
    'miniName': 'XRP',
    'unit': 'XRP',
    'decimals': 6,
    'isContract': false,
    'service': '',
    'contract': '',
    'contract_test': '',
    'path': {'legacy': "m/44'/144'/0'/0/0"},
  }
  ..addrType = 'legacy'
  ..address = 'rN42OfflineWalletAddress'
  ..balance = BigInt.from(100000000)
  ..other = XrpModel(1, true, 0);

Future<void> _mountOffline(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await HttpOverrides.runZoned(
    () async {
      await tester.pumpWidget(
        wrapForTest(
          WalletChainSendXrp(_xrpCoin()),
          overrides: [
            wapBridgeProvider.overrideWith((ref) => _OfflineWalletProvider()),
          ],
        ),
      );
      await tester.pumpAndSettle();
    },
    createHttpClient: (_) => throw StateError('Live network disabled in test'),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('XRP amount input rejects invalid and non-positive values', (
    tester,
  ) async {
    await _mountOffline(tester);
    final amountField = find.byType(TextField).at(2);

    for (final value in ['0.0', '-1']) {
      await tester.enterText(amountField, value);
      await tester.pump();
      expect(
        find.text(value == '0.0' ? S.current.g_key_46(0) : S.current.g_key_134),
        findsOneWidget,
        reason: value,
      );
    }

    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 8));
  });

  testWidgets(
    'XRP amount must leave the reserve and fee from spendable balance',
    (tester) async {
      await _mountOffline(tester);
      final amountField = find.byType(TextField).at(2);

      await tester.enterText(amountField, '90');
      await tester.pump();
      expect(find.text(S.current.g_key_47), findsOneWidget);

      await tester.enterText(amountField, '50');
      await tester.pump();
      expect(find.text(S.current.g_key_47), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(seconds: 8));
    },
  );
}
