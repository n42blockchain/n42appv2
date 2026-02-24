// Tests for AddressBookModel (wallet module address book entry).
// Pure Dart data class — no platform dependencies.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/address_book_model.dart';

void main() {
  // ─────────────────────────────────────────────────
  // Default constructor
  // ─────────────────────────────────────────────────

  group('AddressBookModel default constructor', () {
    test('all fields default to null', () {
      final model = AddressBookModel();
      expect(model.id, isNull);
      expect(model.coinName, isNull);
      expect(model.coinIcon, isNull);
      expect(model.address, isNull);
      expect(model.name, isNull);
      expect(model.desc, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // fromJson
  // ─────────────────────────────────────────────────

  group('AddressBookModel.fromJson', () {
    test('parses all fields from complete map', () {
      final model = AddressBookModel.fromJson({
        'id': 1,
        'coinName': 'ETH',
        'coinIcon': 'https://icon.url/eth.png',
        'address': '0xABCDEF123456',
        'name': 'My Wallet',
        'desc': 'Personal Ethereum wallet',
      });
      expect(model.id, 1);
      expect(model.coinName, 'ETH');
      expect(model.coinIcon, 'https://icon.url/eth.png');
      expect(model.address, '0xABCDEF123456');
      expect(model.name, 'My Wallet');
      expect(model.desc, 'Personal Ethereum wallet');
    });

    test('all fields are null when map is empty', () {
      final model = AddressBookModel.fromJson({});
      expect(model.id, isNull);
      expect(model.coinName, isNull);
      expect(model.address, isNull);
    });

    test('parses partial map', () {
      final model = AddressBookModel.fromJson({
        'coinName': 'BTC',
        'address': '1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2',
      });
      expect(model.coinName, 'BTC');
      expect(model.address, '1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2');
      expect(model.id, isNull);
      expect(model.desc, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // toJson
  // ─────────────────────────────────────────────────

  group('AddressBookModel.toJson', () {
    test('includes all expected keys', () {
      final model = AddressBookModel();
      model.id = 5;
      model.coinName = 'USDT';
      model.address = '0x1234';
      final json = model.toJson();
      expect(json.keys, containsAll(['id', 'coinName', 'coinIcon', 'address', 'name', 'desc']));
    });

    test('values match model fields', () {
      final model = AddressBookModel();
      model.id = 10;
      model.coinName = 'ETH';
      model.coinIcon = 'icon.png';
      model.address = '0xABC';
      model.name = 'Test';
      model.desc = 'Desc';
      final json = model.toJson();
      expect(json['id'], 10);
      expect(json['coinName'], 'ETH');
      expect(json['coinIcon'], 'icon.png');
      expect(json['address'], '0xABC');
      expect(json['name'], 'Test');
      expect(json['desc'], 'Desc');
    });

    test('null fields appear as null in map', () {
      final model = AddressBookModel();
      model.coinName = 'SOL';
      final json = model.toJson();
      expect(json['coinName'], 'SOL');
      expect(json['id'], isNull);
      expect(json['address'], isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // fromJson / toJson roundtrip
  // ─────────────────────────────────────────────────

  group('AddressBookModel fromJson/toJson roundtrip', () {
    test('preserves all fields through roundtrip', () {
      final original = AddressBookModel.fromJson({
        'id': 7,
        'coinName': 'BNB',
        'coinIcon': 'bnb.png',
        'address': '0xBNB',
        'name': 'BNB Wallet',
        'desc': 'BEP-20 wallet',
      });
      final restored = AddressBookModel.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.coinName, original.coinName);
      expect(restored.coinIcon, original.coinIcon);
      expect(restored.address, original.address);
      expect(restored.name, original.name);
      expect(restored.desc, original.desc);
    });
  });
}
