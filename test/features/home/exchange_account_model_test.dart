// Tests for ExchangeAccountModel (home module exchange account data).
// Pure Dart data class — no platform dependencies.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/home/models/exchange_account_model.dart';

void main() {
  // ─────────────────────────────────────────────────
  // Positional constructor
  // ─────────────────────────────────────────────────

  group('ExchangeAccountModel positional constructor', () {
    test('sets all fields from positional arguments', () {
      final model = ExchangeAccountModel(
        'BTC',
        1700000000,
        'https://icon.url/btc.png',
        1,
        1700000001,
        '0.5',
        '2.3',
        'binance',
        'Bitcoin',
      );
      expect(model.coin, 'BTC');
      expect(model.created, 1700000000);
      expect(model.icon, 'https://icon.url/btc.png');
      expect(model.id, 1);
      expect(model.updated, 1700000001);
      expect(model.lock, '0.5');
      expect(model.over, '2.3');
      expect(model.platform, 'binance');
      expect(model.coinFullname, 'Bitcoin');
    });
  });

  // ─────────────────────────────────────────────────
  // fromJson
  // ─────────────────────────────────────────────────

  group('ExchangeAccountModel.fromJson', () {
    test('parses all fields from a complete JSON map', () {
      final model = ExchangeAccountModel.fromJson({
        'coin': 'ETH',
        'created': 1700000000,
        'icon': 'https://icon.url/eth.png',
        'id': 42,
        'updated': 1700000100,
        'lock': '1.0',
        'over': '5.0',
        'platform': 'okx',
        'coinFullname': 'Ethereum',
      });
      expect(model.coin, 'ETH');
      expect(model.created, 1700000000);
      expect(model.icon, 'https://icon.url/eth.png');
      expect(model.id, 42);
      expect(model.updated, 1700000100);
      expect(model.lock, '1.0');
      expect(model.over, '5.0');
      expect(model.platform, 'okx');
      expect(model.coinFullname, 'Ethereum');
    });

    test('all fields are null when map is empty', () {
      final model = ExchangeAccountModel.fromJson({});
      expect(model.coin, isNull);
      expect(model.created, isNull);
      expect(model.id, isNull);
      expect(model.lock, isNull);
      expect(model.over, isNull);
      expect(model.platform, isNull);
      expect(model.coinFullname, isNull);
    });

    test('parses partial JSON with missing optional fields', () {
      final model = ExchangeAccountModel.fromJson({
        'coin': 'USDT',
        'over': '100.0',
      });
      expect(model.coin, 'USDT');
      expect(model.over, '100.0');
      expect(model.lock, isNull);
      expect(model.platform, isNull);
    });

    test('lock and over are parsed as String', () {
      final model = ExchangeAccountModel.fromJson({
        'lock': '0.001',
        'over': '999.999',
      });
      expect(model.lock, isA<String>());
      expect(model.over, isA<String>());
      expect(model.lock, '0.001');
      expect(model.over, '999.999');
    });
  });
}
