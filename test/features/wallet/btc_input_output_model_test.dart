// Tests for InputModel and OutputModel nested classes inside BtcTransactionRecodeModel.
// These nested classes have no platform dependencies (no AppGlobals, no GetIt).

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/btc_transaction_recode_model.dart';

void main() {
  // ─────────────────────────────────────────────────
  // InputModel default constructor
  // ─────────────────────────────────────────────────

  group('InputModel default constructor', () {
    test('all fields initialise to defaults', () {
      final model = InputModel();
      expect(model.value, 0);
      expect(model.txid, '');
      expect(model.vout, 0);
      expect(model.script, '');
      expect(model.witnessValue, '');
      expect(model.lockTime, 0);
      expect(model.address, isEmpty);
    });
  });

  // ─────────────────────────────────────────────────
  // InputModel.fromMap
  // ─────────────────────────────────────────────────

  group('InputModel.fromMap', () {
    test('parses all fields from a complete map', () {
      final model = InputModel.fromMap({
        'value': '500000',
        'txid': 'abc123txid',
        'vout': 2,
        'script': '76a914...',
        'witnessValue': 'witness',
        'lockTime': 0,
        'address': ['1A1zP1eP5QGefi2DMPTfTL5SLmv7Divf', '1BvBMSEY'],
      });
      expect(model.value, 500000);
      expect(model.txid, 'abc123txid');
      expect(model.vout, 2);
      expect(model.script, '76a914...');
      expect(model.witnessValue, 'witness');
      expect(model.lockTime, 0);
      expect(model.address, ['1A1zP1eP5QGefi2DMPTfTL5SLmv7Divf', '1BvBMSEY']);
    });

    test('value is parsed via int.parse (string → int)', () {
      final model = InputModel.fromMap({
        'value': '100000000',
        'txid': 'tx',
        'vout': 0,
        'script': '',
        'witnessValue': '',
        'lockTime': 0,
        'address': <dynamic>[],
      });
      expect(model.value, 100000000);
    });

    test('address list is populated from dynamic entries', () {
      final model = InputModel.fromMap({
        'value': '0',
        'txid': '',
        'vout': 0,
        'script': '',
        'witnessValue': '',
        'lockTime': 0,
        'address': ['addr1', 'addr2', 'addr3'],
      });
      expect(model.address.length, 3);
      expect(model.address[1], 'addr2');
    });

    test('empty address list yields empty list', () {
      final model = InputModel.fromMap({
        'value': '0',
        'txid': '',
        'vout': 0,
        'script': '',
        'witnessValue': '',
        'lockTime': 0,
        'address': <dynamic>[],
      });
      expect(model.address, isEmpty);
    });
  });

  // ─────────────────────────────────────────────────
  // InputModel.valueDouble
  // ─────────────────────────────────────────────────

  group('InputModel.valueDouble', () {
    test('returns 0.0 when value is 0', () {
      final model = InputModel(value: 0);
      expect(model.valueDouble(), 0.0);
    });

    test('converts satoshis to BTC (÷ 100000000)', () {
      final model = InputModel(value: 100000000);
      expect(model.valueDouble(), 1.0);
    });

    test('fractional BTC conversion', () {
      final model = InputModel(value: 50000000);
      expect(model.valueDouble(), closeTo(0.5, 1e-9));
    });

    test('small satoshi value', () {
      final model = InputModel(value: 1);
      expect(model.valueDouble(), closeTo(1e-8, 1e-15));
    });
  });

  // ─────────────────────────────────────────────────
  // InputModel.toMap
  // ─────────────────────────────────────────────────

  group('InputModel.toMap', () {
    test('includes all expected keys', () {
      final model = InputModel(
        value: 100,
        txid: 'txid',
        vout: 1,
        script: 'sc',
        witnessValue: 'wv',
        lockTime: 5,
      );
      model.address.addAll(['addr1']);
      final map = model.toMap();
      expect(
        map.keys,
        containsAll([
          'value',
          'txid',
          'vout',
          'script',
          'witnessValue',
          'address',
          'lockTime',
        ]),
      );
    });

    test('value is serialized as String', () {
      final model = InputModel(value: 99999);
      final map = model.toMap();
      expect(map['value'], '99999');
    });

    test('address list is preserved', () {
      final model = InputModel();
      model.address.addAll(['a', 'b']);
      final map = model.toMap();
      expect(map['address'], ['a', 'b']);
    });
  });

  // ─────────────────────────────────────────────────
  // OutputModel default constructor
  // ─────────────────────────────────────────────────

  group('OutputModel default constructor', () {
    test('all fields initialise to defaults', () {
      final model = OutputModel();
      expect(model.price, 0);
      expect(model.script, '');
      expect(model.address, isEmpty);
    });
  });

  // ─────────────────────────────────────────────────
  // OutputModel.fromMap
  // ─────────────────────────────────────────────────

  group('OutputModel.fromMap', () {
    test('parses all fields from complete map', () {
      final model = OutputModel.fromMap({
        'address': ['1Receiver'],
        'price': 200000,
        'script': 'OP_DUP OP_HASH160',
      });
      expect(model.address, ['1Receiver']);
      expect(model.price, 200000);
      expect(model.script, 'OP_DUP OP_HASH160');
    });

    test('empty address list', () {
      final model = OutputModel.fromMap({
        'address': <dynamic>[],
        'price': 0,
        'script': '',
      });
      expect(model.address, isEmpty);
    });

    test('multiple addresses', () {
      final model = OutputModel.fromMap({
        'address': ['addr1', 'addr2'],
        'price': 1000,
        'script': '',
      });
      expect(model.address.length, 2);
    });
  });

  // ─────────────────────────────────────────────────
  // OutputModel.priceDoubleValue
  // ─────────────────────────────────────────────────

  group('OutputModel.priceDoubleValue', () {
    test('returns 0.0 when price is 0', () {
      final model = OutputModel(price: 0);
      expect(model.priceDoubleValue(), 0.0);
    });

    test('converts satoshis to BTC (÷ 100000000)', () {
      final model = OutputModel(price: 100000000);
      expect(model.priceDoubleValue(), 1.0);
    });

    test('fractional BTC', () {
      final model = OutputModel(price: 25000000);
      expect(model.priceDoubleValue(), closeTo(0.25, 1e-9));
    });
  });

  // ─────────────────────────────────────────────────
  // OutputModel.toMap
  // ─────────────────────────────────────────────────

  group('OutputModel.toMap', () {
    test('includes all expected keys', () {
      final model = OutputModel(price: 500, script: 'sc');
      model.address.addAll(['addr']);
      final map = model.toMap();
      expect(map.keys, containsAll(['address', 'price', 'script']));
    });

    test('price serialized as int', () {
      final model = OutputModel(price: 12345);
      final map = model.toMap();
      expect(map['price'], 12345);
    });
  });

  // ─────────────────────────────────────────────────
  // InputModel fromMap / toMap roundtrip
  // ─────────────────────────────────────────────────

  group('InputModel fromMap/toMap roundtrip', () {
    test('preserves value (int-string-int conversion)', () {
      final original = InputModel.fromMap({
        'value': '777000',
        'txid': 'roundtrip-tx',
        'vout': 3,
        'script': 'script_data',
        'witnessValue': 'wv',
        'lockTime': 10,
        'address': ['addr_roundtrip'],
      });
      final map = original.toMap();
      // value is stored as string in toMap; re-parse for roundtrip
      final restored = InputModel.fromMap(map);
      expect(restored.value, original.value);
      expect(restored.txid, original.txid);
      expect(restored.address, original.address);
    });
  });
}
