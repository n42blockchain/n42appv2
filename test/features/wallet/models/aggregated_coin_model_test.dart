import 'dart:async';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/aggregated_coin_model.dart';
import 'package:n42_wallet/features/wallet/models/aggregated_token.dart';

const aggregateFixture = AggregatedToken(
  symbol: 'USD',
  name: 'Dollar',
  icon: '',
  chains: [
    ChainTokenConfig(
      chainSymbol: 'ETH',
      contract: 'eth-token',
      decimals: 6,
      chainId: 1,
    ),
    ChainTokenConfig(
      chainSymbol: 'BNB',
      contract: 'bnb-token',
      decimals: 18,
      chainId: 56,
    ),
  ],
);

void main() {
  test(
    'sums mixed precision exactly, including dust and large integer parts',
    () {
      final coin = AggregatedCoinModel(tokenConfig: aggregateFixture);
      coin.updateChainBalance(
        'eth',
        BigInt.parse('9007199254740993000001'),
        'a',
      );
      coin.updateChainBalance('BNB', BigInt.one, 'b');
      expect(coin.balanceString(), '9007199254740993.000001000000000001');
      expect(coin.totalBalance, BigInt.parse('9007199254740993000001'));
      expect(
        coin.getChainBalance('eth')!.balance,
        BigInt.parse('9007199254740993000001'),
      );
    },
  );

  test(
    'failure is distinct from zero and missing accounts are unavailable',
    () async {
      final coin = AggregatedCoinModel(
        tokenConfig: aggregateFixture,
        balanceReader: (_, _) async => throw StateError('offline'),
      );
      await coin.fetchAllBalances({'ETH': 'a'});
      expect(coin.statusFor('ETH'), AggregateBalanceStatus.error);
      expect(coin.statusFor('BNB'), AggregateBalanceStatus.unavailable);
      expect(coin.chainBalances, isEmpty);
      expect(coin.loadError, isTrue);
      expect(coin.isRefresh, isFalse);
      expect(coin.hasIncompleteBalance, isTrue);
    },
  );

  test(
    'retry preserves saved balance on error then accepts a real zero',
    () async {
      var fail = true;
      final coin = AggregatedCoinModel(
        tokenConfig: aggregateFixture,
        balanceReader: (_, _) async {
          if (fail) throw StateError('offline');
          return BigInt.zero;
        },
      );
      coin.updateChainBalance('ETH', BigInt.from(123), 'a');
      await coin.fetchAllBalances({'ETH': 'a'});
      expect(coin.statusFor('ETH'), AggregateBalanceStatus.stale);
      expect(coin.getChainBalance('ETH')!.balance, BigInt.from(123));
      fail = false;
      await coin.fetchAllBalances({'ETH': 'a'});
      expect(coin.statusFor('ETH'), AggregateBalanceStatus.ready);
      expect(coin.getChainBalance('ETH')!.balance, BigInt.zero);
      expect(coin.loadError, isFalse);
    },
  );

  test(
    'coalesces identical requests and publishes each chain independently',
    () async {
      final a = Completer<BigInt>();
      final b = Completer<BigInt>();
      var calls = 0;
      var updates = 0;
      final coin = AggregatedCoinModel(
        tokenConfig: aggregateFixture,
        balanceReader: (c, _) {
          calls++;
          return c.chainSymbol == 'ETH' ? a.future : b.future;
        },
      );
      final task = coin.fetchAllBalances({
        'eth': 'a',
        'BNB': 'b',
      }, onChanged: () => updates++);
      expect(
        identical(task, coin.fetchAllBalances({'ETH': 'a', 'BNB': 'b'})),
        isTrue,
      );
      expect(calls, 2);
      a.complete(BigInt.from(1000000));
      await Future<void>.delayed(Duration.zero);
      expect(coin.statusFor('ETH'), AggregateBalanceStatus.ready);
      expect(coin.statusFor('BNB'), AggregateBalanceStatus.loading);
      expect(coin.totalBalanceString, '1');
      b.complete(BigInt.from(2));
      await task;
      expect(coin.hasIncompleteBalance, isFalse);
      expect(coin.totalBalanceString, '1.000000000000000002');
      expect(updates, greaterThanOrEqualTo(3));
    },
  );

  test('address change discards old balances and late responses', () async {
    final old = Completer<BigInt>();
    final coin = AggregatedCoinModel(
      tokenConfig: aggregateFixture,
      balanceReader: (_, a) =>
          a == 'old' ? old.future : Future.value(BigInt.from(7)),
    );
    coin.updateChainBalance('ETH', BigInt.from(99), 'old');
    final first = coin.fetchAllBalances({'ETH': 'old'});
    await coin.fetchAllBalances({'ETH': 'new'});
    old.complete(BigInt.from(999));
    await first;
    expect(coin.getChainBalance('ETH')!.address, 'new');
    expect(coin.getChainBalance('ETH')!.balance, BigInt.from(7));
    await coin.fetchAllBalances({});
    expect(coin.chainBalances, isEmpty);
    expect(coin.value, 0);
  });

  test('timeout and negative response cannot create a zero-success state', () {
    fakeAsync((async) {
      final coin = AggregatedCoinModel(
        tokenConfig: aggregateFixture,
        balanceReader: (c, _) => c.chainSymbol == 'ETH'
            ? Completer<BigInt>().future
            : Future.value(BigInt.from(-1)),
      );
      coin.fetchAllBalances({'ETH': 'a', 'BNB': 'b'});
      async.elapse(const Duration(seconds: 15));
      expect(coin.statusFor('ETH'), AggregateBalanceStatus.error);
      expect(coin.statusFor('BNB'), AggregateBalanceStatus.error);
      expect(coin.chainBalances, isEmpty);
      expect(coin.isRefresh, isFalse);
    });
  });
}
