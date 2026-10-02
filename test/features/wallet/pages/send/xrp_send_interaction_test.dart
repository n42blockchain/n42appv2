import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_xrp.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';

import '../../../../helpers/widget_test_helpers.dart';

class _OfflineWalletProvider extends WalletActionProvider {
  @override
  Future<bool> getBalanceWithCoinModel(CoinModel coinModel) async => false;
}

void main() {
  const toastChannel = MethodChannel('PonnamKarthik/fluttertoast');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toastChannel, (_) async => true);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toastChannel, null);
  });

  CoinModel makeXrpCoin({BigInt? balance}) => CoinModel()
    ..coin = {
      'coinType': 'XRP',
      'blockchainType': 'Ripple',
      'unit': 'XRP',
      'decimals': 6,
      'isContract': false,
      'contract': '',
    }
    ..address = 'rSenderAddress'
    ..addrType = 'legacy'
    ..balance = balance ?? BigInt.from(25 * 1000000)
    ..other = XrpModel(1, true, 0);

  Future<dynamic> mount(WidgetTester tester, {BigInt? balance}) async {
    final coin = makeXrpCoin(balance: balance);
    await tester.pumpWidget(
      wrapForTest(
        WalletChainSendXrp(coin),
        overrides: [
          wapBridgeProvider.overrideWith((ref) => _OfflineWalletProvider()),
        ],
      ),
    );
    await tester.pump();
    // The production RPC client has a 60 second connect timeout. Advance fake
    // time so its expected offline failure is settled without contacting XRP.
    await tester.pump(const Duration(minutes: 3));
    await tester.pumpAndSettle();
    final state = tester.state(find.byType(WalletChainSendXrp)) as dynamic;
    // The network bootstrap is intentionally allowed to fail closed. These
    // cases exercise local XRP validation and reserve calculations only.
    state.load = Load.finish;
    return state;
  }

  testWidgets('XRP amount validation accounts for fee and locked reserve', (
    tester,
  ) async {
    final state = await mount(tester);
    state.totalGasPrice = BigInt.from(100);

    state.amountCheck(value: '14.999899');
    expect(state.amountErrorMessage, isEmpty);
    expect(state.transferValue, BigInt.from(14999899));

    state.amountCheck(value: '15');
    expect(state.amountErrorMessage, isNotEmpty);
  });

  testWidgets('XRP rejects amounts below one drop but accepts one drop', (
    tester,
  ) async {
    final state = await mount(tester);

    state.amountCheck(value: '0.0000009');
    expect(state.amountErrorMessage, isNotEmpty);
    expect(state.transferValue, BigInt.zero);

    state.amountCheck(value: '0.000001');
    expect(state.amountErrorMessage, isEmpty);
    expect(state.transferValue, BigInt.one);
  });

  testWidgets('XRP Max leaves reserve and fee available', (tester) async {
    final state = await mount(tester);
    state.totalGasPrice = BigInt.from(1000000);

    await state.maxTag();

    expect(state.transferValue, BigInt.from(14 * 1000000));
    expect(state.valueTextEditingController.text, '14');
    expect(state.amountErrorMessage, isEmpty);
  });

  testWidgets('XRP Max clamps at zero when reserve and fee exceed balance', (
    tester,
  ) async {
    final state = await mount(tester, balance: BigInt.from(9000000));
    state.totalGasPrice = BigInt.from(1000000);

    await state.maxTag();

    expect(state.transferValue, BigInt.zero);
    expect(state.valueTextEditingController.text, '0');
  });
}
