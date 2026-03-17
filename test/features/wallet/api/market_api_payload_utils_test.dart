import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/market_api_payload_utils.dart';

void main() {
  group('extractMarketCoinItems', () {
    test('extracts list payloads directly', () {
      final result = extractMarketCoinItems([
        {'coin': 'btc', 'price': 1},
        {'coin': 'eth', 'price': 2},
      ]);

      expect(result, hasLength(2));
      expect(result.first['coin'], 'btc');
    });

    test('extracts nested data payloads', () {
      final result = extractMarketCoinItems({
        'data': [
          {'coin': 'sol', 'price': 3},
        ],
      });

      expect(result, hasLength(1));
      expect(result.first['coin'], 'sol');
    });

    test('accepts single coin map payloads', () {
      final result = extractMarketCoinItems({
        'coin': 'trx',
        'coin_gecko_id': 'tron',
        'price': 0.11,
      });

      expect(result, hasLength(1));
      expect(result.first['coin_gecko_id'], 'tron');
    });

    test('returns empty list for unsupported payloads', () {
      expect(extractMarketCoinItems(null), isEmpty);
      expect(extractMarketCoinItems({'message': 'ok'}), isEmpty);
    });
  });
}
