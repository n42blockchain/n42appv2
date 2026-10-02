import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  const toast = MethodChannel('PonnamKarthik/fluttertoast');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toast, (_) async => true);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toast, null);
  });

  CoinModel makeCoin({BigInt? balance}) => CoinModel()
    ..coin = {
      // An empty type makes initData fail closed before balance or gas RPCs.
      'coinType': '',
      'blockchainType': 'Ethereum',
      'unit': 'ETH',
      'miniName': 'ETH',
      'decimals': 18,
      'isContract': false,
      'contract': '',
    }
    ..address = '0x1111111111111111111111111111111111111111'
    ..balance = balance ?? BigInt.parse('1000000000000000000');

  Future<dynamic> mount(WidgetTester tester, {BigInt? balance}) async {
    await tester.pumpWidget(
      wrapForTest(WalletChainSend(makeCoin(balance: balance))),
    );
    await tester.pumpAndSettle();
    final dynamic state = tester.state(find.byType(WalletChainSend));
    state.load = Load.finish;
    // Invalid config emits a toast; advance past its transient timer.
    await tester.pump(const Duration(seconds: 8));
    expect(tester.takeException(), isNull);
    return state;
  }

  testWidgets('amount validation includes fee in the available balance', (
    tester,
  ) async {
    final state = await mount(
      tester,
      balance: BigInt.parse('1000000000000000000'),
    );
    state.totalGasPrice = BigInt.parse('100000000000000000');

    state.amountCheck(value: '0.9');
    expect(state.amountErrorMessage, isEmpty);
    expect(state.transferValue, BigInt.parse('900000000000000000'));

    state.amountCheck(value: '0.900000000000000001');
    await tester.pump();
    expect(state.amountErrorMessage, isNotEmpty);
    expect(find.text(state.amountErrorMessage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('standard miner fee shows gas price, limit, and total', (
    tester,
  ) async {
    final state = await mount(tester);
    state.gasPrice = BigInt.from(2000000000);
    state.gas = BigInt.from(21000);
    state.totalGasPrice = BigInt.from(42000000000000);
    state.amountCheck(value: '0.1');
    await tester.pump();

    expect(find.text('2Gwei'), findsOneWidget);
    expect(find.text('21000'), findsOneWidget);
    expect(find.text('0.000042ETH'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('send button does not open confirmation for an invalid amount', (
    tester,
  ) async {
    final state = await mount(tester);
    state.valueTextEditingController.text = '0';
    state.amountCheck(value: '0');
    await tester.pump();

    final sendLabel = S
        .of(tester.element(find.byType(WalletChainSend)))
        .g_key_48;
    await tester.tap(find.text(sendLabel));
    await tester.pumpAndSettle();

    expect(find.text(state.amountErrorMessage), findsOneWidget);
    expect(find.byType(WalletChainSend), findsOneWidget);
    expect(state.load, Load.finish);
    expect(tester.takeException(), isNull);
  });
}
