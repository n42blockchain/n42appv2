import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/api_hub/aggregators/market_data_aggregator.dart';
import 'package:n42_wallet/core/api_hub/models/coin_price.dart';

CoinPrice _price(String symbol, double value) {
  return CoinPrice(
    symbol: symbol,
    priceUsd: value,
    source: 'cache',
    fetchedAt: DateTime.now(),
  );
}

void main() {
  group('MarketDataAggregator.addStaleFallback', () {
    test(
      'fills missing symbols from stale cache without replacing fresh data',
      () {
        final result = <String, CoinPrice>{'BTC': _price('BTC', 100000)};
        final cache = <String, CoinPrice>{
          'BTC': _price('BTC', 99999),
          'ETH': _price('ETH', 3500),
        };

        MarketDataAggregator.addStaleFallback(
          result: result,
          missingSymbols: const ['BTC', 'ETH', 'SOL'],
          cache: cache,
        );

        expect(result['BTC']?.priceUsd, 100000);
        expect(result['ETH']?.priceUsd, 3500);
        expect(result.containsKey('SOL'), isFalse);
      },
    );
  });
}
