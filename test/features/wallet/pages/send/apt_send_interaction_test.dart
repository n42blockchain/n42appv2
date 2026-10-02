import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_apt.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';

import '../../../../helpers/widget_test_helpers.dart';

class _OfflineWalletProvider extends WalletActionProvider {
  @override
  Future<bool> getBalanceWithCoinModel(CoinModel coinModel) async => false;
}

class _RejectingHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw const SocketException('Unexpected HTTP in Aptos send test');
}

class _FailFastHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      _RejectingHttpClient();
}

void main() {
  setUp(() => HttpOverrides.global = _FailFastHttpOverrides());
  tearDown(() => HttpOverrides.global = null);

  CoinModel makeCoin({BigInt? balance}) => CoinModel()
    ..coin = {
      'coinType': 'APT',
      'blockchainType': 'Aptos',
      'unit': 'APT',
      'miniName': 'APT',
      'decimals': 8,
      'isContract': false,
      'contract': '',
    }
    ..address =
        '0x1111111111111111111111111111111111111111111111111111111111111111'
    ..addrType = 'legacy'
    ..balance = balance ?? BigInt.from(20001);

  Future<dynamic> mount(WidgetTester tester, {BigInt? balance}) async {
    await tester.pumpWidget(
      wrapForTest(
        WalletChainSendApt(makeCoin(balance: balance)),
        overrides: [
          wapBridgeProvider.overrideWith((ref) => _OfflineWalletProvider()),
        ],
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();
    final dynamic state = tester.state(find.byType(WalletChainSendApt));
    // Isolate local amount/fee behavior from the blocked network gas lookup.
    state.gasPrice = BigInt.from(100);
    state.gas = BigInt.from(100);
    state.totalGasPrice = BigInt.from(10000);
    expect(tester.takeException(), isNull);
    return state;
  }

  testWidgets(
    'APT validates syntax, precision and native fee against balance',
    (tester) async {
      final state = await mount(tester);
      for (final value in ['', '0', '-1', '1e2', 'not-a-number']) {
        state.amountCheck(value: value);
        expect(state.amountErrorMessage, isNotEmpty, reason: value);
      }

      state.amountCheck(value: '0.00000001');
      expect(state.amountErrorMessage, isEmpty);
      expect(state.transferValue, BigInt.one);

      state.amountCheck(value: '0.000000010001');
      expect(
        state.amountErrorMessage,
        isNotEmpty,
        reason: 'non-zero precision beyond APT units must not truncate',
      );
      state.amountCheck(value: '0.000000010000');
      expect(
        state.amountErrorMessage,
        isEmpty,
        reason: 'extra fractional zeroes preserve the same APT amount',
      );
      expect(state.transferValue, BigInt.one);

      // A positive amount below one on-chain unit must not truncate to zero.
      state.transferValue = BigInt.zero;
      state.amountCheck(value: '0.000000001');
      expect(state.amountErrorMessage, isNotEmpty);
      expect(state.transferValue, BigInt.zero);

      // 10,002 base units transfer + 10,000 base units fee exceeds 20,001.
      state.amountCheck(value: '0.00010002');
      expect(state.amountErrorMessage, isNotEmpty);

      state.amountCheck(value: '0.00009999');
      expect(state.amountErrorMessage, isEmpty);
      expect(state.transferValue, BigInt.from(9999));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('APT Max subtracts fee and clamps balances below fee to zero', (
    tester,
  ) async {
    final state = await mount(tester, balance: BigInt.from(25000));
    await state.maxTag();
    expect(state.transferValue, BigInt.from(15000));
    expect(state.valueTextEditingController.text, '0.00015');
    expect(state.amountErrorMessage, isEmpty);

    await tester.pumpWidget(const SizedBox.shrink());
    final belowFee = await mount(tester, balance: BigInt.from(9999));
    await belowFee.maxTag();
    expect(belowFee.transferValue, BigInt.zero);
    expect(belowFee.valueTextEditingController.text, '0');
    expect(tester.takeException(), isNull);
  });
}
