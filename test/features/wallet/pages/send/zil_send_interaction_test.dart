import 'package:flutter/material.dart';

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_zil.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';

import '../../../../helpers/widget_test_helpers.dart';

class _OfflineWalletProvider extends WalletActionProvider {
  @override
  Future<bool> getBalanceWithCoinModel(CoinModel coinModel) async => false;
}

class _RejectingHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw const SocketException('Unexpected HTTP in ZIL send test');
}

class _FailFastHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      _RejectingHttpClient();
}

void main() {
  setUp(() => HttpOverrides.global = _FailFastHttpOverrides());
  tearDown(() => HttpOverrides.global = null);

  CoinModel makeCoin({BigInt? balance, int decimals = 12}) => CoinModel()
    ..coin = {
      'coinType': 'ZIL',
      'blockchainType': 'Zilliqa',
      'unit': 'ZIL',
      'miniName': 'ZIL',
      'decimals': decimals,
      'isContract': false,
      'contract': '',
    }
    ..address = 'zil1sender0000000000000000000000000000000000'
    ..addrType = 'legacy'
    ..balance = balance ?? BigInt.parse('5000000000000');

  Future<dynamic> mount(WidgetTester tester, {BigInt? balance}) async {
    await tester.pumpWidget(
      wrapForTest(
        WalletChainSendZil(makeCoin(balance: balance)),
        overrides: [
          wapBridgeProvider.overrideWith((ref) => _OfflineWalletProvider()),
        ],
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(minutes: 3));
    await tester.pumpAndSettle();
    final dynamic state = tester.state(find.byType(WalletChainSendZil));
    state.totalGasPrice = BigInt.from(1000);
    expect(tester.takeException(), isNull);
    return state;
  }

  testWidgets(
    'ZIL validation covers syntax, base-unit precision and fee guard',
    (tester) async {
      final state = await mount(tester, balance: BigInt.from(2000));
      for (final value in ['', '0', '-1', '1e2', 'not-a-number']) {
        state.amountCheck(value: value);
        expect(state.amountErrorMessage, isNotEmpty, reason: value);
      }

      state.amountCheck(value: '0.000000000001');
      expect(state.amountErrorMessage, isEmpty);
      expect(state.transferValue, BigInt.one);

      // A positive value below one Qa currently converts to zero.
      state.transferValue = BigInt.from(77);
      state.amountCheck(value: '0.0000000000001');
      expect(state.amountErrorMessage, isNotEmpty);
      expect(state.transferValue, BigInt.from(77));

      state.amountCheck(value: '0.000000001001');
      expect(state.amountErrorMessage, isNotEmpty);
      state.amountCheck(value: '0.000000000001');
      expect(state.amountErrorMessage, isEmpty);
      expect(state.transferValue, BigInt.one);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('ZIL Max subtracts network fee and clamps at zero', (
    tester,
  ) async {
    final state = await mount(tester, balance: BigInt.from(5000));
    await state.maxTag();
    expect(state.transferValue, BigInt.from(4000));
    expect(state.valueTextEditingController.text, '0.000000004');
    expect(state.amountErrorMessage, isEmpty);

    await tester.pumpWidget(const SizedBox.shrink());
    final belowFee = await mount(tester, balance: BigInt.from(999));
    await belowFee.maxTag();
    expect(belowFee.transferValue, BigInt.zero);
    expect(belowFee.valueTextEditingController.text, '0');
    expect(tester.takeException(), isNull);
  });
}
