import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_trx.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';

import '../../../../helpers/widget_test_helpers.dart';

class _OfflineWalletProvider extends WalletActionProvider {
  @override
  Future<bool> getBalanceWithCoinModel(CoinModel coinModel) async => false;
}

class _RejectingHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw const SocketException('Unexpected HTTP in TRX send test');
}

class _FailFastHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      _RejectingHttpClient();
}

void main() {
  const toastChannel = MethodChannel('PonnamKarthik/fluttertoast');

  setUp(() {
    HttpOverrides.global = _FailFastHttpOverrides();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toastChannel, (_) async => true);
  });

  tearDown(() {
    HttpOverrides.global = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toastChannel, null);
  });

  CoinModel makeCoin({BigInt? balance}) => CoinModel()
    ..coin = {
      'coinType': 'TRX',
      'blockchainType': 'Tron',
      'unit': 'TRX',
      'miniName': 'TRX',
      'decimals': 6,
      'isContract': false,
      'contract': '',
    }
    ..address = 'TJRabPrwbZy45sbavfcjinPJC18kjpRTv8'
    ..addrType = 'legacy'
    ..balance = balance ?? BigInt.from(10 * 1000000);

  Future<dynamic> mount(WidgetTester tester, {BigInt? balance}) async {
    await tester.pumpWidget(
      wrapForTest(
        WalletChainSendTrx(makeCoin(balance: balance)),
        overrides: [
          wapBridgeProvider.overrideWith((ref) => _OfflineWalletProvider()),
        ],
      ),
    );
    await tester.pump();
    // Let both bootstrap RPC attempts hit the fail-fast offline client.
    await tester.pump(const Duration(minutes: 3));
    await tester.pumpAndSettle();
    final dynamic state = tester.state(find.byType(WalletChainSendTrx));
    state.load = Load.finish;
    expect(tester.takeException(), isNull);
    return state;
  }

  testWidgets(
    'TRX validation rejects malformed, zero, and over-balance amounts',
    (tester) async {
      final state = await mount(tester, balance: BigInt.from(1000100));
      state.totalGasPrice = BigInt.from(100);

      state.amountCheck(value: '0.0000001');
      expect(state.amountErrorMessage, isNotEmpty);

      state.amountCheck(value: '0.000001');
      expect(state.amountErrorMessage, isEmpty);
      expect(state.transferValue, BigInt.one);

      for (final value in ['', '0', '-1', '1e2', 'not-a-number']) {
        state.amountCheck(value: value);
        expect(state.amountErrorMessage, isNotEmpty, reason: value);
      }
      state.amountCheck(value: '1');
      expect(state.amountErrorMessage, isEmpty);
      expect(state.transferValue, BigInt.from(1000000));

      state.amountCheck(value: '1.000001');
      expect(state.amountErrorMessage, isNotEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('TRX Max keeps the full amount when fee estimation fails', (
    tester,
  ) async {
    final state = await mount(tester, balance: BigInt.from(10 * 1000000));
    // Gas estimation intentionally fails offline. Max must leave the form in a
    // safe state and must not claim a spendable amount without a fee estimate.
    state.totalGasPrice = BigInt.from(100000);
    await state.maxTag();

    expect(state.transferValue, BigInt.zero);
    expect(state.valueTextEditingController.text, '10');
    expect(state.amountErrorMessage, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
