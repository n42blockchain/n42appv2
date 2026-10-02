import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_fil.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';

import '../../../../helpers/widget_test_helpers.dart';

class _OfflineWalletProvider extends WalletActionProvider {
  @override
  Future<bool> getBalanceWithCoinModel(CoinModel coinModel) async => false;
}

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
      'coinType': 'FIL',
      'blockchainType': 'Filecoin',
      'unit': 'FIL',
      'miniName': 'FIL',
      'decimals': 18,
      'isContract': false,
      'contract': '',
    }
    ..address = 'f1sender000000000000000000000000000000000000'
    ..balance = balance ?? BigInt.parse('10000000000000000000');

  Future<dynamic> mount(WidgetTester tester, {BigInt? balance}) async {
    await tester.pumpWidget(
      wrapForTest(
        WalletChainSendFil(makeCoin(balance: balance)),
        overrides: [
          wapBridgeProvider.overrideWith((ref) => _OfflineWalletProvider()),
        ],
      ),
    );
    await tester.pumpAndSettle();
    final state = tester.state(find.byType(WalletChainSendFil));
    expect(tester.takeException(), isNull);
    return state;
  }

  testWidgets('FIL rejects positive amounts below one base unit', (
    tester,
  ) async {
    final state = await mount(tester);

    state.amountCheck(value: '0.0000000000000000001');

    expect(state.amountErrorMessage, isNotEmpty);
    expect(state.transferValue, BigInt.zero);
    expect(tester.takeException(), isNull);
  });

  testWidgets('FIL accepts the minimum unit and enforces fee boundary', (
    tester,
  ) async {
    final state = await mount(
      tester,
      balance: BigInt.parse('3000000000000000000'),
    );
    state.totalGasPrice = BigInt.parse('50000000000000000');

    state.amountCheck(value: '0.000000000000000001');
    expect(state.amountErrorMessage, isEmpty);
    expect(state.transferValue, BigInt.one);

    state.amountCheck(value: '2.95');
    expect(state.amountErrorMessage, isEmpty);
    expect(state.transferValue, BigInt.parse('2950000000000000000'));

    state.amountCheck(value: '2.950000000000000001');
    expect(state.amountErrorMessage, isNotEmpty);
    expect(tester.takeException(), isNull);
  });
}
