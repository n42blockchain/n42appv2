// Tests for CommonResponseItemModel (on-chain transaction record from block explorer).
// Pure Dart data class — no platform dependencies.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/transaction/common_response_item_model.dart';

const _kFullJson = {
  'blockNumber': '10475175',
  'timeStamp': '1630314219',
  'hash': '0x9c12ea64',
  'nonce': '851069',
  'blockHash': '0x52754e79',
  'transactionIndex': '22',
  'from': '0x161ba15a',
  'to': '0xf426a8d0',
  'value': '90541060000000000',
  'gas': '207128',
  'gasPrice': '10000000000',
  'isError': '0',
  'txreceipt_status': '1',
  'input': '0x',
  'contractAddress': '',
  'cumulativeGasUsed': '894108',
  'gasUsed': '21000',
  'confirmations': '2362',
};

void main() {
  // ─────────────────────────────────────────────────
  // Default constructor
  // ─────────────────────────────────────────────────

  group('CommonResponseItemModel default constructor', () {
    test('all fields default to null', () {
      final model = CommonResponseItemModel();
      expect(model.blockNumber, isNull);
      expect(model.hash, isNull);
      expect(model.from, isNull);
      expect(model.to, isNull);
      expect(model.value, isNull);
      expect(model.gasUsed, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // fromJson
  // ─────────────────────────────────────────────────

  group('CommonResponseItemModel.fromJson', () {
    test('parses all fields from complete map', () {
      final model = CommonResponseItemModel.fromJson(_kFullJson);
      expect(model.blockNumber, '10475175');
      expect(model.timeStamp, '1630314219');
      expect(model.hash, '0x9c12ea64');
      expect(model.nonce, '851069');
      expect(model.blockHash, '0x52754e79');
      expect(model.transactionIndex, '22');
      expect(model.from, '0x161ba15a');
      expect(model.to, '0xf426a8d0');
      expect(model.value, '90541060000000000');
      expect(model.gas, '207128');
      expect(model.gasPrice, '10000000000');
      expect(model.isError, '0');
      // Note: txreceipt_status maps to txreceiptStatus field
      expect(model.txreceiptStatus, '1');
      expect(model.input, '0x');
      expect(model.contractAddress, '');
      expect(model.cumulativeGasUsed, '894108');
      expect(model.gasUsed, '21000');
      expect(model.confirmations, '2362');
    });

    test('all fields are null when map is empty', () {
      final model = CommonResponseItemModel.fromJson({});
      expect(model.blockNumber, isNull);
      expect(model.hash, isNull);
      expect(model.txreceiptStatus, isNull);
    });

    test('isError = "0" indicates no error', () {
      final model = CommonResponseItemModel.fromJson({'isError': '0'});
      expect(model.isError, '0');
    });

    test('isError = "1" indicates error', () {
      final model = CommonResponseItemModel.fromJson({'isError': '1'});
      expect(model.isError, '1');
    });

    test('txreceipt_status key maps to txreceiptStatus field', () {
      final model = CommonResponseItemModel.fromJson({'txreceipt_status': '1'});
      expect(model.txreceiptStatus, '1');
    });

    test('maps TokenView native transaction fields into common fields', () {
      final model = CommonResponseItemModel.fromJson({
        'block_no': 22929695,
        'time': 1725239842,
        'txid': '0xabc',
        'from': '0xfrom',
        'to': '0xto',
        'value': '0.1',
        'gasLimit': 21000,
        'gasPrice': '1156960484',
        'gasused': 21000,
        'confirmations': 14,
      });

      expect(model.blockNumber, '22929695');
      expect(model.timeStamp, '1725239842');
      expect(model.hash, '0xabc');
      expect(model.value, '0.1');
      expect(model.gas, '21000');
      expect(model.gasPrice, '1156960484');
      expect(model.gasUsed, '21000');
      expect(model.confirmations, '14');
      expect(model.normalizedState, 1);
    });

    test('maps TokenView token transfer fields into contract metadata', () {
      final model = CommonResponseItemModel.fromJson({
        'txid': '0xdef',
        'tokenAddr': '0xtoken',
        'value': '12345',
        'confirmations': 9,
      });

      expect(model.hash, '0xdef');
      expect(model.contractAddress, '0xtoken');
      expect(model.value, '12345');
      expect(model.normalizedState, 1);
    });

    test('maps failed receipt status to failed transaction state', () {
      final model = CommonResponseItemModel.fromJson({'txreceipt_status': '0'});

      expect(model.normalizedState, 2);
    });

    test('maps explicit isError flag to failed transaction state', () {
      final model = CommonResponseItemModel.fromJson({'isError': '1'});

      expect(model.normalizedState, 2);
    });
  });

  // ─────────────────────────────────────────────────
  // toJson
  // ─────────────────────────────────────────────────

  group('CommonResponseItemModel.toJson', () {
    test('includes all expected keys', () {
      final model = CommonResponseItemModel.fromJson(_kFullJson);
      final json = model.toJson();
      expect(
        json.keys,
        containsAll([
          'blockNumber',
          'timeStamp',
          'hash',
          'nonce',
          'blockHash',
          'transactionIndex',
          'from',
          'to',
          'value',
          'gas',
          'gasPrice',
          'isError',
          'txreceipt_status',
          'input',
          'contractAddress',
          'cumulativeGasUsed',
          'gasUsed',
          'confirmations',
        ]),
      );
    });

    test('txreceiptStatus maps back to txreceipt_status key in toJson', () {
      final model = CommonResponseItemModel.fromJson({'txreceipt_status': '1'});
      final json = model.toJson();
      expect(json['txreceipt_status'], '1');
    });
  });

  // ─────────────────────────────────────────────────
  // fromJson / toJson roundtrip
  // ─────────────────────────────────────────────────

  group('CommonResponseItemModel fromJson/toJson roundtrip', () {
    test('preserves all fields', () {
      final original = CommonResponseItemModel.fromJson(_kFullJson);
      final restored = CommonResponseItemModel.fromJson(original.toJson());
      expect(restored.blockNumber, original.blockNumber);
      expect(restored.hash, original.hash);
      expect(restored.from, original.from);
      expect(restored.to, original.to);
      expect(restored.value, original.value);
      expect(restored.gasUsed, original.gasUsed);
      expect(restored.txreceiptStatus, original.txreceiptStatus);
    });
  });
}
