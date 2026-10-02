import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_memo.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';

import '../../../../helpers/widget_test_helpers.dart';

class _OfflineWalletProvider extends WalletActionProvider {
  @override
  Future<bool> getBalanceWithCoinModel(CoinModel coinModel) async => false;
}

void main() {
  CoinModel makeCoin({int decimals = 6}) => CoinModel()
    ..coin = {
      'coinType': 'ATOM',
      'blockchainType': 'Cosmos',
      'unit': 'ATOM',
      'miniName': 'ATOM',
      'decimals': decimals,
      'isContract': false,
      'contract': '',
    }
    ..address = 'cosmos1syntheticwalletaddress'
    ..balance = BigInt.parse('100000000000');

  Future<dynamic> mount(WidgetTester tester, {int decimals = 6}) async {
    await tester.pumpWidget(
      wrapForTest(
        WalletChainSendMemo(makeCoin(decimals: decimals)),
        overrides: [
          wapBridgeProvider.overrideWith((ref) => _OfflineWalletProvider()),
        ],
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();
    final dynamic state = tester.state(find.byType(WalletChainSendMemo));
    // Isolate amount validation from fee/network work during initData.
    state.totalGasPrice = BigInt.zero;
    expect(tester.takeException(), isNull);
    return state;
  }

  testWidgets('rejects a positive amount truncated to zero base units', (
    tester,
  ) async {
    final state = await mount(tester);

    state.amountCheck(value: '0.0000001');

    expect(state.amountError, isNotEmpty);
    expect(state.transferValue, BigInt.zero);
    expect(tester.takeException(), isNull);
  });

  testWidgets('malformed values show validation errors without throwing', (
    tester,
  ) async {
    final state = await mount(tester);

    for (final value in ['', '0', '-1', '1e2', 'NaN', 'Infinity', 'abc']) {
      state.amountCheck(value: value);
      expect(state.amountError, isNotEmpty, reason: value);
      expect(tester.takeException(), isNull, reason: value);
    }

    state.amountCheck(value: '0.000001');
    expect(state.amountError, isEmpty);
    expect(state.transferValue, BigInt.one);
  });

  testWidgets('accepts a valid whole-base-unit amount', (tester) async {
    final state = await mount(tester);

    state.amountCheck(value: '1.234567');

    expect(state.amountError, isEmpty);
    expect(state.transferValue, BigInt.from(1234567));
    expect(tester.takeException(), isNull);
  });
}
