import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/near_api.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_memo.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

import '../../../../helpers/widget_test_helpers.dart';

class Wallet extends WalletActionProvider {
  @override
  Future<bool> getBalanceWithCoinModel(CoinModel model) async => false;
}

class Api extends NearApi {
  BigInt balance = BigInt.from(10).pow(24);
  BigInt reserve = BigInt.from(100);
  bool error = false;
  Completer<void>? gate;
  @override
  Future<MessageModel> getTransferBalance(String accountId) async {
    expect(accountId, 'alice.near');
    if (gate != null) await gate!.future;
    return error
        ? MessageModel.error()
        : (MessageModel()
            ..data = {'balance': balance, 'storageReserve': reserve});
  }

  @override
  Future<MessageModel> getGasPrice() async =>
      MessageModel()..data = BigInt.from(2);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  for (final scenario in [
    'maximum',
    'ordinary',
    'insufficient',
    'error',
    'stale',
  ]) {
    testWidgets('NEAR quote $scenario', (tester) async {
      final api = Api()..error = scenario == 'error';
      final coin = CoinModel()
        ..coin = {
          'coinType': 'NEAR',
          'blockchainType': 'Near',
          'unit': 'NEAR',
          'miniName': 'NEAR',
          'decimals': 24,
          'isContract': false,
          'contract': '',
        }
        ..address = 'alice.near'
        ..balance = api.balance;
      await tester.pumpWidget(
        wrapForTest(
          WalletChainSendMemo(
            coin,
            nearApiFactory: (test) {
              expect(test, false);
              return api;
            },
          ),
          overrides: [wapBridgeProvider.overrideWith((ref) => Wallet())],
        ),
      );
      await tester.pumpAndSettle();
      final dynamic state = tester.state(find.byType(WalletChainSendMemo));
      state.transferValue = scenario == 'insufficient'
          ? api.balance
          : BigInt.one;
      if (scenario == 'stale') api.gate = Completer<void>();
      final Future<bool> result = state.prepareNearQuote(
        maximum: scenario == 'maximum',
      ) as Future<bool>;
      if (scenario == 'stale') {
        state.toCtrl.text = 'other.near';
        api.gate!.complete();
      }
      expect(await result, ['maximum', 'ordinary'].contains(scenario));
      await tester.pumpAndSettle();
      if (scenario == 'maximum') {
        expect(
          state.transferValue,
          api.balance -
              api.reserve -
              NearApi.transferGasReserve * BigInt.from(2),
        );
      }
      if (scenario == 'ordinary') expect(state.transferValue, BigInt.one);
      if (['maximum', 'ordinary'].contains(scenario)) {
        expect(
          state.totalGasPrice,
          NearApi.transferGasReserve * BigInt.from(2),
        );
      }
      if (scenario == 'error') expect(state.errorMessage, isNotEmpty);
      expect(tester.takeException(), isNull);
    });
  }
}
