import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';

class _DelayedBalances extends TokenViewApi {
  final result = Completer<MessageModel?>();
  var balanceCalls = 0;
  @override
  Future<MessageModel?> getBalance(
    String blockchain,
    String coinType,
    String address, {
    String contract = '',
    bool returnDouble = false,
    bool isTest = false,
    String? rpc,
  }) {
    balanceCalls++;
    return result.future;
  }
}

class _DelayedMetadata extends _DelayedBalances {
  final decimals = Completer<int?>();
  @override
  Future<int?> getErc20Decimals(String contractAddress, String rpcUrl) =>
      decimals.future;
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
  for (final metadata in [true, false]) {
    for (final switched in [true, false]) {
      test(
        '${metadata ? 'metadata' : 'ALGO'} response preserves wallet context (switch=$switched)',
        () async {
          final api = metadata ? _DelayedMetadata() : _DelayedBalances();
          final wallet = _Wallet(api);
          addTearDown(wallet.dispose);
          final coin = CoinModel()
            ..coin = {
              'coinType': metadata ? 'ETH' : 'ALGO',
              'blockchainType': metadata ? 'Ethereum' : 'Algorand',
              'isContract': true,
              'canEdit': true,
              'balance': '0',
              'decimals': 18,
              'mKey': 'asset',
              'contract': '0x3333333333333333333333333333333333333333',
            }
            ..address = '0x1111111111111111111111111111111111111111';
          wallet.coinModels.add(CoinModel()..coin = {'coinType': 'ALGO'});
          wallet.walletInfoLsit.addAll([
            WalletInfo(walletUuid: wallet.userUUID, coinInfo: {}),
            WalletInfo(walletUuid: wallet.userUUID, coinInfo: {}),
          ]);
          wallet.walletIndex = 0;
          final pending = wallet.getBalanceWithCoinModel(coin);
          if (switched) wallet.walletIndex = 1;
          if (metadata) {
            (api as _DelayedMetadata).decimals.complete(6);
            api.result.complete(MessageModel()..data = BigInt.from(123));
          } else {
            api.result.complete(
              MessageModel()..data = {'balance': BigInt.from(123), 'code': 1},
            );
          }
          await pending;
          expect(coin.coin['balance'], switched ? '0' : '123');
          if (metadata) {
            expect(coin.coin['decimals'], switched ? 18 : 6);
            expect(coin.coin['decimals_verified'], switched ? isNull : isTrue);
            expect(api.balanceCalls, switched ? 0 : 1);
          } else {
            expect(coin.other is AlgoModel, !switched);
          }
        },
      );
    }
  }
}
