import 'dart:async';
import 'package:n42_wallet/main.dart' as app;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/core/providers/service_providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/market_api.dart';
import 'package:n42_wallet/features/wallet/models/aggregated_coin_model.dart';
import 'package:n42_wallet/features/wallet/models/aggregated_token.dart';
import '../../../helpers/aggregate_wallet_fixtures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';

class _Market extends MarketApi {
  @override
  Future<Map<String, dynamic>> getWalletCoinsInfo(String coins) async => {
    'error': false,
    'data': [
      {'coin': 'USDT', 'price': 1},
    ],
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late WalletActionProvider wallet;
  late AggregatedCoinModel coin;
  var calls = 0;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    app.globalProviderContainer = ProviderContainer(
      overrides: [walletServiceProvider.overrideWithValue(null)],
    );
    calls = 0;
    wallet =
        WalletActionProvider(
            marketApi: _Market(),
            stablecoinPriceRequest: (_) async => null,
          )
          ..walletInfoLsit.add(WalletInfo())
          ..walletIndex = 0;
    wallet.coinModels.add(aggregateMainFixture());
    coin = AggregatedCoinModel(
      tokenConfig: AggregatedTokens.usdt,
      balanceReader: (_, _) async {
        calls++;
        return BigInt.from(2000000);
      },
    )..coinPrice = 1;
    wallet.coinList.add(coin);
  });
  tearDown(() {
    wallet.dispose();
    app.globalProviderContainer.dispose();
  });

  test(
    'manual and background refresh both include aggregated balances and total',
    () async {
      await wallet.refreshWalletCoinInfo(refresh: false);
      expect(calls, 1);
      expect(wallet.balanceTotal, 2);
      await wallet.refreshWalletCoinInfo(forcePrices: true);
      expect(calls, 2);
      expect(wallet.balanceTotal, 2);
      expect(coin.statusFor('ETH'), AggregateBalanceStatus.ready);
    },
  );
  test(
    'testnet/custom/mismatched chains are excluded from mainnet requests',
    () async {
      for (final mode in ['test', 'custom', 'id']) {
        final chain = wallet.coinModels.single;
        chain.isTest = mode == 'test';
        chain.custom = mode == 'custom';
        chain.coin['chainId'] = mode == 'id' ? 11155111 : 1;
        await wallet.refreshAggregatedBalances();
        expect(calls, 0);
        expect(coin.chainBalances, isEmpty);
        expect(wallet.aggregateReceiveToken(coin, 'ETH'), isNull);
      }
    },
  );
  test(
    'switching a network to testnet removes its cached mainnet subtotal',
    () async {
      await wallet.refreshAggregatedBalances();
      expect(wallet.balanceTotal, 2);
      wallet.coinModels.single.isTest = true;
      await wallet.refreshAggregatedBalances();
      expect(coin.chainBalances, isEmpty);
      expect(wallet.balanceTotal, 0);
      expect(calls, 1);
    },
  );
  test(
    'late completion after wallet switch cannot overwrite active total',
    () async {
      final pending = Completer<BigInt>();
      coin = AggregatedCoinModel(
        tokenConfig: AggregatedTokens.usdt,
        balanceReader: (_, _) => pending.future,
      );
      wallet.coinList = [coin];
      final task = wallet.refreshAggregatedBalances();
      wallet.walletInfoLsit.add(WalletInfo());
      wallet.walletIndex = 1;
      wallet.coinList = [];
      wallet.setBalanceTotal(77);
      pending.complete(BigInt.from(2000000));
      await task;
      expect(wallet.balanceTotal, 77);
    },
  );
  test(
    'removed aggregate does not fetch or expose a receive descriptor',
    () async {
      wallet.coinList.clear();
      await wallet.refreshAggregatedBalances(only: coin);
      expect(calls, 0);
      expect(wallet.aggregateReceiveToken(coin, 'ETH'), isNull);
    },
  );
  test(
    'receive descriptor binds chain contract and decimals without signer material',
    () {
      wallet.coinModels.single.privateKey = 'fixture-do-not-copy';
      final token = wallet.aggregateReceiveToken(coin, 'eth')!;
      expect(
        token.coin['contract'],
        AggregatedTokens.usdt.chains.first.contract,
      );
      expect(token.coin['decimals'], 6);
      expect(token.coin['coinType'], 'ETH');
      expect(token.address, wallet.coinModels.single.address);
      expect(token.isTest, isFalse);
      expect(token.privateKey, isNull);
    },
  );
  test(
    'single-chain detail projection refreshes without double-counting holdings',
    () async {
      final source = aggregateSourceFixture()..value = 55;
      wallet.coinList = [source];
      wallet.setBalanceTotal(55);
      await wallet.refreshAggregatedBalances(only: coin, source: source);
      expect(calls, 1);
      expect(coin.totalBalanceString, '2');
      expect(wallet.balanceTotal, 55);
      expect(wallet.coinList.single, source);
      expect(
        wallet.aggregateReceiveToken(coin, 'ETH', source: source),
        isNotNull,
      );
      wallet.coinList.clear();
      expect(wallet.aggregateReceiveToken(coin, 'ETH', source: source), isNull);
    },
  );
  test(
    'ticker spoof and wrong preset cannot authorize a detached projection',
    () async {
      final source = aggregateSourceFixture()
        ..coin['contract'] = '0x0000000000000000000000000000000000000001';
      wallet.coinList = [source];
      expect(aggregatedTokenForCoin(source), isNull);
      await wallet.refreshAggregatedBalances(only: coin, source: source);
      expect(calls, 0);
      expect(wallet.aggregateReceiveToken(coin, 'ETH', source: source), isNull);
      source.coin['contract'] = AggregatedTokens.usdc.chains.first.contract;
      await wallet.refreshAggregatedBalances(only: coin, source: source);
      expect(calls, 0);
    },
  );
}
