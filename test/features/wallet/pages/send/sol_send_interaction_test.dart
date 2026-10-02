import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_sol.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';

import '../../../../helpers/widget_test_helpers.dart';

class _OfflineWalletProvider extends WalletActionProvider {
  @override
  Future<bool> getBalanceWithCoinModel(CoinModel coinModel) async => false;
}

class _RejectingHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw const SocketException('blocked by test');
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
      'coinType': 'SOL',
      'blockchainType': 'Solana',
      'unit': 'SOL',
      'miniName': 'SOL',
      'decimals': 9,
      'isContract': false,
      'contract': '',
      'path': "m/44'/501'/0'",
    }
    ..address = 'SenderPublicKey'
    ..addrType = 'legacy'
    ..balance = balance ?? BigInt.from(5005000000);

  Future<dynamic> mount(WidgetTester tester, {BigInt? balance}) async {
    await tester.pumpWidget(
      wrapForTest(
        WalletChainSendSol(makeCoin(balance: balance)),
        overrides: [
          wapBridgeProvider.overrideWith((ref) => _OfflineWalletProvider()),
        ],
      ),
    );
    final dynamic state = tester.state(find.byType(WalletChainSendSol));
    await tester.pump();
    await tester.pumpAndSettle();
    state.load = Load.finish;
    expect(tester.takeException(), isNull);
    return state;
  }

  testWidgets(
    'SOL amount validation rejects invalid and fee-over-balance values',
    (tester) async {
      final state = await mount(tester);
      // Native SOL fee is 5,000 lamports.
      expect(state.totalGasPrice, BigInt.from(5000));
      for (final value in [
        '',
        '0',
        '-1',
        '1e2',
        'not-a-number',
        '0.0000000001',
        '5.005',
      ]) {
        state.amountCheck(value: value);
        expect(state.amountErrorMessage, isNotEmpty, reason: value);
      }

      state.amountCheck(value: '5.004995');
      expect(state.amountErrorMessage, isEmpty);
      expect(state.transferValue, BigInt.from(5004995000));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('SOL Max subtracts the network fee from lamports', (
    tester,
  ) async {
    final state = await mount(tester);

    await state.maxTag();

    expect(state.transferValue, BigInt.from(5004995000));
    expect(state.valueTextEditingController.text, '5.004995');
    expect(state.amountErrorMessage, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('SOL accepts its smallest representable unit', (tester) async {
    final state = await mount(tester);

    state.amountCheck(value: '0.000000001');

    expect(state.amountErrorMessage, isEmpty);
    expect(state.transferValue, BigInt.one);
    expect(tester.takeException(), isNull);
  });

  testWidgets('SOL Max clamps at zero when fee exhausts balance', (
    tester,
  ) async {
    final state = await mount(tester, balance: BigInt.from(5000));

    await state.maxTag();

    expect(state.transferValue, BigInt.zero);
    expect(state.valueTextEditingController.text, '0');
    expect(state.amountErrorMessage, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
