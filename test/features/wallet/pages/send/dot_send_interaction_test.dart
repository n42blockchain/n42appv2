import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_dot.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';

import '../../../../helpers/widget_test_helpers.dart';

class _OfflineWalletProvider extends WalletActionProvider {
  @override
  Future<bool> getBalanceWithCoinModel(CoinModel coinModel) async => false;
}

class _RejectingHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw const SocketException('Unexpected HTTP in DOT send test');
}

class _FailFastHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      _RejectingHttpClient();
}

void main() {
  const toast = MethodChannel('PonnamKarthik/fluttertoast');

  setUp(() {
    HttpOverrides.global = _FailFastHttpOverrides();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toast, (_) async => true);
  });

  tearDown(() {
    HttpOverrides.global = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toast, null);
  });

  CoinModel makeCoin({BigInt? balance}) => CoinModel()
    ..coin = {
      'coinType': 'DOT',
      'blockchainType': 'Polkadot',
      'unit': 'DOT',
      'miniName': 'DOT',
      'decimals': 10,
      'isContract': false,
      'contract': '',
      'path': {'legacy': "m/44'/354'/0'/0/0"},
    }
    ..address = 'synthetic-dot-sender'
    ..addrType = 'legacy'
    ..balance = balance ?? BigInt.from(100000000000);

  Future<dynamic> mount(WidgetTester tester, {BigInt? balance}) async {
    await tester.pumpWidget(
      wrapForTest(
        WalletChainSendDot(makeCoin(balance: balance)),
        overrides: [
          wapBridgeProvider.overrideWith((ref) => _OfflineWalletProvider()),
        ],
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();
    final dynamic state = tester.state(find.byType(WalletChainSendDot));
    expect(tester.takeException(), isNull);
    return state;
  }

  testWidgets('DOT amount checks syntax, minimum unit, fee and balance', (
    tester,
  ) async {
    final state = await mount(tester);
    state.totalGasPrice = BigInt.from(10000000);

    for (final value in ['', '0', '-1', '1e2', 'not-a-number']) {
      state.amountCheck(value: value);
      expect(state.amountErrorMessage, isNotEmpty, reason: value);
    }

    state.amountCheck(value: '0.0000000001');
    expect(state.amountErrorMessage, isEmpty);
    expect(state.transferValue, BigInt.one);

    state.amountCheck(value: '0.00000000001');
    expect(
      state.amountErrorMessage,
      isNotEmpty,
      reason: 'positive amount below one planck must not truncate to zero',
    );

    state.amountCheck(value: '9.999');
    expect(state.amountErrorMessage, isEmpty);
    expect(state.transferValue, BigInt.from(99990000000));

    state.amountCheck(value: '10');
    expect(
      state.amountErrorMessage,
      isNotEmpty,
      reason: 'amount plus estimated fee must fit the wallet balance',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('DOT Max subtracts the fixed network fee and clamps at zero', (
    tester,
  ) async {
    final state = await mount(tester, balance: BigInt.from(100000000000));
    state.totalGasPrice = BigInt.from(10000000);
    await state.maxTag();
    expect(state.transferValue, BigInt.from(99990000000));
    expect(state.valueTextEditingController.text, '9.999');
    expect(state.amountErrorMessage, isEmpty);

    await tester.pumpWidget(const SizedBox.shrink());
    final small = await mount(tester, balance: BigInt.from(5000000));
    small.totalGasPrice = BigInt.from(10000000);
    await small.maxTag();
    expect(small.transferValue, BigInt.zero);
    expect(small.valueTextEditingController.text, '0.0');
    expect(tester.takeException(), isNull);
  });
}
