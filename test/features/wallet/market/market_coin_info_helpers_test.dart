import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/market/market_coin_info_helpers.dart';

void main() {
  test('marketCoinMatchesSymbol compares symbols case-insensitively', () {
    expect(marketCoinMatchesSymbol({'coin': 'ETH'}, 'eth'), isTrue);
    expect(marketCoinMatchesSymbol({'coin': 'btc'}, 'eth'), isFalse);
  });

  test(
    'mergeMarketCoinSnapshot preserves missing stable fields from existing snapshot',
    () {
      final merged = mergeMarketCoinSnapshot(
        {
          'coin': 'eth',
          'coin_gecko_id': 'ethereum',
          'name': 'Ethereum',
          'image': 'https://example.com/eth.png',
        },
        {'coin': 'eth', 'price': 3200.0},
      );

      expect(merged['coin_gecko_id'], 'ethereum');
      expect(merged['name'], 'Ethereum');
      expect(merged['image'], 'https://example.com/eth.png');
      expect(merged['price'], 3200.0);
    },
  );
}
