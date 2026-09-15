// Tests for BtcResponse and Txref (BTC address UTxO/history response).
// Pure Dart data classes — no platform dependencies.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/transaction/btc_response.dart';

const _kTxrefJson = <String, dynamic>{
  'tx_hash': '0xabcdef1234567890',
  'block_height': 700000,
  'value': 50000000,
  'ref_balance': 100000000,
  'confirmations': 6,
  'tx_input_n': -1,
  'tx_output_n': 0,
  'confirmed': '2023-01-01T12:00:00Z',
};

Map<String, dynamic> _makeBtcResponseJson({List<dynamic>? txrefs}) => {
  'address': '1A1zP1eP5QGefi2DMPTfTL5SLmv7Divf',
  'total_received': 200000000,
  'total_sent': 50000000,
  'balance': 150000000,
  'unconfirmed_balance': 0,
  'txrefs': txrefs ?? [_kTxrefJson],
};

void main() {
  // ─────────────────────────────────────────────────
  // Txref.fromJson
  // ─────────────────────────────────────────────────

  group('Txref.fromJson', () {
    test('parses all fields correctly', () {
      final txref = Txref.fromJson(_kTxrefJson);
      expect(txref.txHash, '0xabcdef1234567890');
      expect(txref.blockHeight, 700000);
      expect(txref.value, 50000000);
      expect(txref.refBalance, 100000000);
      expect(txref.confirmations, 6);
      expect(txref.txInputN, -1);
      expect(txref.txOutputN, 0);
      expect(txref.confirmed, '2023-01-01T12:00:00Z');
    });

    test('incoming tx has txInputN = -1', () {
      // By convention, received UTXOs have txInputN == -1
      final txref = Txref.fromJson(_kTxrefJson);
      expect(txref.txInputN, -1);
    });

    test('outgoing tx has txInputN >= 0', () {
      final txref = Txref.fromJson({
        ..._kTxrefJson,
        'tx_input_n': 0,
        'tx_output_n': -1,
      });
      expect(txref.txInputN, 0);
    });
  });

  // ─────────────────────────────────────────────────
  // Txref.toJson
  // ─────────────────────────────────────────────────

  group('Txref.toJson', () {
    test('includes all expected snake_case keys', () {
      final json = Txref.fromJson(_kTxrefJson).toJson();
      expect(
        json.keys,
        containsAll([
          'tx_hash',
          'block_height',
          'value',
          'ref_balance',
          'confirmations',
          'tx_input_n',
          'tx_output_n',
          'confirmed',
        ]),
      );
    });

    test('values match the original fields', () {
      final txref = Txref.fromJson(_kTxrefJson);
      final json = txref.toJson();
      expect(json['tx_hash'], txref.txHash);
      expect(json['block_height'], txref.blockHeight);
      expect(json['value'], txref.value);
      expect(json['confirmations'], txref.confirmations);
      expect(json['confirmed'], txref.confirmed);
    });
  });

  // ─────────────────────────────────────────────────
  // Txref fromJson / toJson roundtrip
  // ─────────────────────────────────────────────────

  group('Txref fromJson/toJson roundtrip', () {
    test('preserves all fields', () {
      final original = Txref.fromJson(_kTxrefJson);
      final restored = Txref.fromJson(original.toJson());
      expect(restored.txHash, original.txHash);
      expect(restored.blockHeight, original.blockHeight);
      expect(restored.value, original.value);
      expect(restored.refBalance, original.refBalance);
      expect(restored.confirmations, original.confirmations);
      expect(restored.txInputN, original.txInputN);
      expect(restored.txOutputN, original.txOutputN);
      expect(restored.confirmed, original.confirmed);
    });
  });

  // ─────────────────────────────────────────────────
  // BtcResponse.fromJson
  // ─────────────────────────────────────────────────

  group('BtcResponse.fromJson', () {
    test('parses all scalar fields', () {
      final response = BtcResponse.fromJson(_makeBtcResponseJson());
      expect(response.address, '1A1zP1eP5QGefi2DMPTfTL5SLmv7Divf');
      expect(response.totalReceived, 200000000);
      expect(response.totalSent, 50000000);
      expect(response.balance, 150000000);
      expect(response.unconfirmedBalance, 0);
    });

    test('parses txrefs list with one entry', () {
      final response = BtcResponse.fromJson(_makeBtcResponseJson());
      expect(response.txrefs.length, 1);
      expect(response.txrefs.first.txHash, '0xabcdef1234567890');
    });

    test('parses txrefs list with multiple entries', () {
      final txref2 = {
        ..._kTxrefJson,
        'tx_hash': '0xsecondtxhash',
        'value': 10000000,
        'block_height': 700001,
      };
      final response = BtcResponse.fromJson(
        _makeBtcResponseJson(txrefs: [_kTxrefJson, txref2]),
      );
      expect(response.txrefs.length, 2);
      expect(response.txrefs[1].txHash, '0xsecondtxhash');
    });

    test('empty txrefs list is accepted', () {
      final response = BtcResponse.fromJson(_makeBtcResponseJson(txrefs: []));
      expect(response.txrefs, isEmpty);
    });

    test('unconfirmedBalance = 0 indicates no pending transactions', () {
      final response = BtcResponse.fromJson(_makeBtcResponseJson());
      expect(response.unconfirmedBalance, 0);
    });

    test('balance arithmetic is consistent with received - sent', () {
      final response = BtcResponse.fromJson(_makeBtcResponseJson());
      // 200000000 - 50000000 = 150000000
      expect(response.balance, response.totalReceived - response.totalSent);
    });
  });

  // ─────────────────────────────────────────────────
  // BtcResponse.toJson
  // ─────────────────────────────────────────────────

  group('BtcResponse.toJson', () {
    test('includes all expected keys', () {
      final json = BtcResponse.fromJson(_makeBtcResponseJson()).toJson();
      expect(
        json.keys,
        containsAll([
          'address',
          'total_received',
          'total_sent',
          'balance',
          'unconfirmed_balance',
          'txrefs',
        ]),
      );
    });

    test('txrefs is a List in toJson', () {
      final json = BtcResponse.fromJson(_makeBtcResponseJson()).toJson();
      expect(json['txrefs'], isA<List>());
    });

    test('scalar values match fields', () {
      final response = BtcResponse.fromJson(_makeBtcResponseJson());
      final json = response.toJson();
      expect(json['address'], response.address);
      expect(json['total_received'], response.totalReceived);
      expect(json['balance'], response.balance);
    });
  });
}
