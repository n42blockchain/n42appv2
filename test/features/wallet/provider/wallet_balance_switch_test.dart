import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';

class _DelayedBalances extends TokenViewApi {
  final result = Completer<MessageModel?>();
  @override
  Future<MessageModel?> getBalance(
    String blockchain,
    String coinType,
    String address, {
    String contract = '',
    bool returnDouble = false,
    bool isTest = false,
    String? rpc,
  }) => result.future;
}

class _Wallet extends WalletActionProvider {
  _Wallet(this.api);
  final TokenViewApi api;
  @override
  TokenViewApi get tokenViewApi => api;
  String owner = 'balance-qa-owner';
  @override
  String get userUUID => owner;
}

void main() {
  for (final change in [
    'wallet',
    'replacement',
    'owner',
    'address',
    'network',
    'chainid',
    'contract',
    'unchanged',
    'failure',
  ]) {
    test('balance response respects $change context', () async {
      final api = _DelayedBalances();
      final wallet = _Wallet(api);
      addTearDown(wallet.dispose);
      final oldCoin = CoinModel()
        ..coin = {
          'coinType': 'ETH',
          'blockchainType': 'Ethereum',
          'isContract': false,
          'balance': '0',
          'decimals': 18,
        }
        ..address = '0x1111111111111111111111111111111111111111';
      final newBase = <String, dynamic>{...oldCoin.coin, 'balance': '123'};
      wallet.walletInfoLsit.addAll([
        WalletInfo(
          walletUuid: wallet.userUUID,
          coinInfo: {
            'ETH': {'baseInfo': oldCoin.coin},
          },
        ),
        WalletInfo(
          walletUuid: wallet.userUUID,
          coinInfo: {
            'ETH': {'baseInfo': newBase},
          },
        ),
      ]);
      wallet.walletIndex = 0;
      final pending = wallet.getBalanceWithCoinModel(oldCoin);
      switch (change) {
        case 'wallet':
          wallet.walletIndex = 1;
        case 'replacement':
          wallet.walletInfoLsit[0] = wallet.walletInfoLsit[1];
        case 'owner':
          wallet.owner = 'another-owner';
        case 'address':
          oldCoin.address = '0x2222222222222222222222222222222222222222';
        case 'network':
          oldCoin.isTest = true;
        case 'chainid':
          oldCoin.coin['chainId'] = 999;
        case 'contract':
          oldCoin.coin['contract'] = 'changed-contract';
      }
      api.result.complete(
        change == 'failure'
            ? MessageModel.error()
            : (MessageModel()..data = BigInt.from(999)),
      );
      await pending;
      expect(newBase['balance'], '123');
      expect(oldCoin.coin['balance'], change == 'unchanged' ? '999' : '0');
      if (change == 'wallet' || change == 'replacement') {
        expect(identical(wallet.walletMap['ETH']['baseInfo'], newBase), isTrue);
      }
      if (change == 'unchanged') expect(oldCoin.balance, BigInt.from(999));
    });
  }
}
