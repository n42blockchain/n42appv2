import 'dart:async';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/wallet/api/market_api.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';

class _Market extends MarketApi {
  final requests = <String>[];
  Future<Map<String, dynamic>> Function() respond = () async => {
    'error': false,
    'data': [
      {'coin': 'btc', 'price': '12.5', 'price_change_per_24h': 2},
    ],
  };
  @override
  Future<Map<String, dynamic>> getWalletCoinsInfo(String coins) {
    requests.add(coins);
    return respond();
  }
}

CoinModel coin(String symbol) => CoinModel()
  ..coin = {'miniName': symbol, 'unit': symbol, 'decimals': 0}
  ..balance = BigInt.from(2);

void main() {
  late _Market api;
  late WalletActionProvider provider;
  late DateTime now;
  setUp(() {
    now = DateTime.utc(2026, 9, 10, 12);
    api = _Market();
    provider = WalletActionProvider(
      marketApi: api,
      stablecoinPriceRequest: (_) async => null,
      now: () => now,
    )..coinList = [coin('btc')];
  });
  tearDown(() {
    if (!provider.isDisposed) provider.dispose();
  });

  test(
    'successful quote updates price, valuation and completion timestamp',
    () async {
      await provider.getCoinInfo();
      expect(provider.coinList.single.coinPrice, 12.5);
      expect(provider.coinList.single.value, 25);
      expect(provider.priceLastUpdated, now);
      expect(provider.priceRefreshFailed, isFalse);
      expect(provider.coinRefreshMap, isEmpty);
    },
  );

  test('fresh cached quote keeps the original successful timestamp', () async {
    await provider.getCoinInfo();
    final original = now;
    now = now.add(const Duration(minutes: 4, seconds: 59));
    await provider.getCoinInfo();
    expect(api.requests, ['btc']);
    expect(provider.priceLastUpdated, original);
  });

  test('expired quote refreshes at the cache boundary', () async {
    await provider.getCoinInfo();
    now = now.add(const Duration(minutes: 5));
    await provider.getCoinInfo();
    expect(api.requests, ['btc', 'btc']);
    expect(provider.priceLastUpdated, now);
  });

  test(
    'clock moving backwards does not make cached data indefinitely fresh',
    () async {
      await provider.getCoinInfo();
      now = now.subtract(const Duration(minutes: 1));
      await provider.getCoinInfo();
      expect(api.requests, hasLength(2));
    },
  );

  test('newly selected coins are fetched despite a recent cache', () async {
    await provider.getCoinInfo();
    provider.coinList.add(coin('eth'));
    await provider.getCoinInfo();
    expect(api.requests, ['btc', 'btc,eth']);
  });

  test(
    '401 preserves saved prices and their age until a successful retry',
    () async {
      await provider.getCoinInfo();
      final original = now;
      now = now.add(const Duration(minutes: 1));
      api.respond = () async => {'error': true, 'data': 'unauthorized'};
      await provider.refreshWalletCoinInfo(forcePrices: true);
      expect(provider.priceRefreshFailed, isTrue);
      expect(provider.priceLastUpdated, original);
      expect(provider.coinList.single.coinPrice, 12.5);
      expect(provider.load, Load.finish);
      api.respond = () async => {
        'error': false,
        'data': [
          {'coin': 'btc', 'price': 20},
        ],
      };
      await provider.refreshWalletCoinInfo(forcePrices: true);
      expect(provider.priceRefreshFailed, isFalse);
      expect(provider.priceLastUpdated, now);
      expect(provider.coinList.single.coinPrice, 20);
    },
  );

  test('first failure does not create a last-success timestamp', () async {
    api.respond = () async => {'error': true};
    await provider.getCoinInfo();
    expect(provider.priceLastUpdated, isNull);
    expect(provider.priceRefreshFailed, isTrue);
  });

  for (final payload in [
    null,
    [],
    {'message': 'ok'},
    [
      {'coin': 'btc'},
    ],
    [
      {'coin': '', 'price': 1},
    ],
    [
      {'coin': 'btc', 'price': -1},
    ],
    [
      {'coin': 'btc', 'price': 'NaN'},
    ],
    [
      {'coin': 'btc', 'price': 'Infinity'},
    ],
  ]) {
    test('malformed or unusable quote is not marked fresh: $payload', () async {
      api.respond = () async => {'error': false, 'data': payload};
      await provider.getCoinInfo();
      expect(provider.priceLastUpdated, isNull);
      expect(provider.priceRefreshFailed, isTrue);
      expect(provider.coinList.single.coinPrice, 0);
    });
  }

  test(
    'valid entries survive invalid neighbours in nested API payload',
    () async {
      api.respond = () async => {
        'error': false,
        'data': {
          'data': [
            null,
            {'coin': 'btc', 'price': 0},
            {'coin': 'eth', 'price': 'NaN'},
          ],
        },
      };
      await provider.getCoinInfo();
      expect(provider.priceLastUpdated, now);
      expect(provider.priceRefreshFailed, isFalse);
      expect(provider.getCoinPriceWithUnitAll('eth'), isNull);
    },
  );

  test(
    'concurrent refreshes share one request and timestamp at completion',
    () async {
      final pending = Completer<Map<String, dynamic>>();
      api.respond = () => pending.future;
      final first = provider.getCoinInfo();
      final second = provider.getCoinInfo();
      expect(identical(first, second), isTrue);
      await Future<void>.delayed(Duration.zero);
      expect(api.requests, ['btc']);
      now = now.add(const Duration(seconds: 10));
      pending.complete({
        'error': false,
        'data': [
          {'coin': 'btc', 'price': 30},
        ],
      });
      await Future.wait([first, second]);
      expect(provider.priceLastUpdated, now);
    },
  );

  test(
    'exception completes pull-to-refresh and a later request can retry',
    () async {
      api.respond = () async => throw StateError('offline');
      await provider.initCoinInfo();
      expect(provider.load, Load.finish);
      expect(provider.priceRefreshFailed, isTrue);
      await provider.getCoinInfo();
      expect(api.requests, hasLength(2));
    },
  );

  test('timeout ends loading and ignores a late response', () {
    fakeAsync((async) {
      final pending = Completer<Map<String, dynamic>>();
      api.respond = () => pending.future;
      var completed = false;
      provider.refreshWalletCoinInfo().then((_) => completed = true);
      async.flushMicrotasks();
      expect(provider.load, Load.refresh);
      async.elapse(const Duration(seconds: 15));
      expect(completed, isTrue);
      expect(provider.load, Load.finish);
      expect(provider.priceRefreshFailed, isTrue);
      pending.complete({
        'error': false,
        'data': [
          {'coin': 'btc', 'price': 90},
        ],
      });
      async.flushMicrotasks();
      expect(provider.priceLastUpdated, isNull);
      expect(provider.coinList.single.coinPrice, 0);
    });
  });

  test(
    'disposed provider ignores a pending response and stops new refreshes',
    () async {
      final pending = Completer<Map<String, dynamic>>();
      api.respond = () => pending.future;
      final task = provider.getCoinInfo();
      await Future<void>.delayed(Duration.zero);
      provider.dispose();
      pending.complete({
        'error': false,
        'data': [
          {'coin': 'btc', 'price': 90},
        ],
      });
      await task;
      await provider.getCoinInfo();
      expect(provider.priceLastUpdated, isNull);
      expect(api.requests, ['btc']);
    },
  );

  test(
    'empty wallet does not submit an empty market request or queue balances',
    () async {
      provider.coinList.clear();
      await provider.getCoinInfo();
      expect(api.requests, isEmpty);
      expect(provider.priceLastUpdated, isNull);
      expect(provider.loadBalance, Load.finish);
    },
  );

  test(
    'automatic requests reuse quotes throughout the five-minute window',
    () async {
      await provider.getCoinInfo();
      final original = now;
      for (var minute = 1; minute < 5; minute++) {
        now = original.add(Duration(minutes: minute));
        await provider.refreshWalletCoinInfo(refresh: false);
      }
      expect(api.requests, ['btc']);
      expect(provider.priceLastUpdated, original);
      expect(provider.load, isNot(Load.refresh));
    },
  );

  test(
    'manual refresh bypasses fresh prices and updates their timestamp',
    () async {
      await provider.getCoinInfo();
      now = now.add(const Duration(seconds: 10));
      api.respond = () async => {
        'error': false,
        'data': [
          {'coin': 'btc', 'price': 99},
        ],
      };
      await provider.refreshWalletCoinInfo(forcePrices: true);
      expect(api.requests, ['btc', 'btc']);
      expect(provider.coinList.single.coinPrice, 99);
      expect(provider.priceLastUpdated, now);
      expect(provider.load, Load.finish);
    },
  );

  test(
    'background quote update does not start balance syncing for a ready wallet',
    () async {
      provider.walletInfoLsit.add(WalletInfo());
      provider.walletIndex = 0;
      expect(provider.isWalletReady, isTrue);
      await provider.getCoinInfo();
      expect(provider.coinList.single.coinPrice, 12.5);
      expect(
        provider.coinList.single.loadError,
        isFalse,
        reason: 'Balance queue would flag this addressless fixture',
      );
      expect(provider.coinRefreshMap, isEmpty);
      expect(provider.loadBalance, Load.finish);
      expect(provider.load, isNot(Load.refresh));
    },
  );

  test(
    'manual requests coalesce with an already running automatic request',
    () async {
      final pending = Completer<Map<String, dynamic>>();
      api.respond = () => pending.future;
      final automatic = provider.refreshWalletCoinInfo(refresh: false);
      final manual = provider.refreshWalletCoinInfo(forcePrices: true);
      await Future<void>.delayed(Duration.zero);
      expect(api.requests, ['btc']);
      pending.complete({
        'error': false,
        'data': [
          {'coin': 'btc', 'price': 10},
        ],
      });
      await Future.wait([automatic, manual]);
      expect(provider.coinList.single.coinPrice, 10);
      expect(provider.load, Load.finish);
    },
  );

  test('manual refresh also bypasses the stablecoin cache', () async {
    var stableRequests = 0;
    final stable = WalletActionProvider(
      marketApi: api,
      stablecoinPriceRequest: (_) async {
        stableRequests++;
        return {
          'tether': {'usd': stableRequests == 1 ? 1.0 : 0.99},
        };
      },
      now: () => now,
    )..coinList = [coin('usdt')];
    addTearDown(stable.dispose);
    await stable.getCoinInfo();
    await stable.getCoinInfo();
    expect(stableRequests, 1);
    await stable.refreshWalletCoinInfo(forcePrices: true);
    expect(stableRequests, 2);
    expect(stable.coinList.single.coinPrice, 0.99);
  });
  test(
    'partial response preserves missing quotes and does not reset age',
    () async {
      provider.coinList.add(coin('eth'));
      api.respond = () async => {
        'error': false,
        'data': [
          {'coin': 'btc', 'price': 10},
          {'coin': 'eth', 'price': 20},
        ],
      };
      await provider.getCoinInfo();
      final original = now;
      now = now.add(const Duration(minutes: 5));
      api.respond = () async => {
        'error': false,
        'data': [
          {'coin': ' BTC ', 'price': 30},
        ],
      };
      await provider.getCoinInfo();
      expect(provider.hasPartialPrices, isTrue);
      expect(provider.coinList.first.coinPrice, 30);
      expect(provider.coinList.last.coinPrice, 20);
      expect(provider.getCoinPriceWithUnit('eth')?['coinPrice'], 20);
      expect(provider.priceLastUpdated, original);
      expect(provider.priceRefreshFailed, isTrue);
      await provider.getCoinInfo();
      expect(api.requests, hasLength(2));
      expect(provider.priceRefreshFailed, isTrue);
      await provider.getCoinInfo(force: true);
      expect(api.requests, hasLength(3));
    },
  );

  test('unrelated quote cannot mark the selected wallet fresh', () async {
    api.respond = () async => {
      'error': false,
      'data': [
        {'coin': 'eth', 'price': 20},
      ],
    };
    await provider.getCoinInfo();
    expect(provider.priceLastUpdated, isNull);
    expect(provider.priceRefreshFailed, isTrue);
    expect(provider.coinList.single.coinPrice, 0);
  });

  test(
    'coin selection changed during request is not marked fully fresh',
    () async {
      final pending = Completer<Map<String, dynamic>>();
      api.respond = () => pending.future;
      final task = provider.getCoinInfo();
      await Future<void>.delayed(Duration.zero);
      provider.coinList.add(coin('eth'));
      pending.complete({
        'error': false,
        'data': [
          {'coin': 'btc', 'price': 10},
        ],
      });
      await task;
      expect(provider.priceRefreshFailed, isTrue);
      expect(provider.priceLastUpdated, isNull);
      api.respond = () async => {
        'error': false,
        'data': [
          {'coin': 'btc', 'price': 10},
          {'coin': 'eth', 'price': 20},
        ],
      };
      await provider.getCoinInfo();
      expect(api.requests, ['btc', 'btc,eth']);
      expect(provider.priceRefreshFailed, isFalse);
      expect(provider.coinList.last.coinPrice, 20);
      expect(provider.hasPartialPrices, isFalse);
    },
  );

  test('stablecoin cache expires if the clock moves backwards', () async {
    var calls = 0;
    final stable = WalletActionProvider(
      marketApi: api,
      stablecoinPriceRequest: (_) async {
        calls++;
        return {
          'tether': {'usd': calls == 1 ? 1.0 : 0.99},
        };
      },
      now: () => now,
    )..coinList = [coin('usdt')];
    addTearDown(stable.dispose);
    await stable.getCoinInfo();
    now = now.subtract(const Duration(minutes: 1));
    await stable.getCoinInfo();
    expect(calls, 2);
    expect(stable.coinList.single.coinPrice, 0.99);
  });
}
