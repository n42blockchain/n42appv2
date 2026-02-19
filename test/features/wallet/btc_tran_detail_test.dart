// Tests for BtcTranDetail, Input, and Output (BTC block explorer transaction detail).
// Pure Dart data classes — no platform dependencies.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42appv2/src/wallet/models/transaction/btc_tran_detail.dart';

const _kInputJson = <String, dynamic>{
  'prev_hash': 'prevTxHash001',
  'output_index': 0,
  'script': '47304402...',
  'output_value': 100000,
  'addresses': ['1SenderAddress'],
};

const _kOutputJson = <String, dynamic>{
  'value': 90000,
  'script': '76a914...',
  'addresses': ['1ReceiverAddress'],
};

const _kDetailJson = <String, dynamic>{
  'block_hash': '0000000000000000000abc',
  'block_index': 512345,
  'hash': 'txhash_abcdef',
  'addresses': ['1addr1', '1addr2'],
  'total': 180000,
  'fees': 10000,
  'confirmed': '2023-12-01T10:00:00Z',
  'confirmations': 30,
  'inputs': [
    {
      'prev_hash': 'prevTxHash001',
      'output_index': 0,
      'script': '47304402...',
      'output_value': 100000,
      'addresses': ['1SenderAddress'],
    }
  ],
  'outputs': [
    {
      'value': 90000,
      'script': '76a914...',
      'addresses': ['1ReceiverAddress'],
    }
  ],
};

void main() {
  // ─────────────────────────────────────────────────
  // Input.fromJson
  // ─────────────────────────────────────────────────

  group('Input.fromJson', () {
    test('parses all fields from complete map', () {
      final input = Input.fromJson(_kInputJson);
      expect(input.prevHash, 'prevTxHash001');
      expect(input.outputIndex, 0);
      expect(input.script, '47304402...');
      expect(input.outputValue, 100000);
      expect(input.addresses, ['1SenderAddress']);
    });

    test('script is nullable', () {
      final input = Input.fromJson({
        'prev_hash': 'ph',
        'output_index': 1,
        'script': null,
        'output_value': 500,
        'addresses': ['addr'],
      });
      expect(input.script, isNull);
    });

    test('multiple addresses are parsed', () {
      final input = Input.fromJson({
        'prev_hash': 'ph',
        'output_index': 0,
        'script': null,
        'output_value': 0,
        'addresses': ['addr1', 'addr2'],
      });
      expect(input.addresses.length, 2);
      expect(input.addresses[1], 'addr2');
    });
  });

  // ─────────────────────────────────────────────────
  // Input.toJson
  // ─────────────────────────────────────────────────

  group('Input.toJson', () {
    test('includes all expected keys', () {
      final input = Input.fromJson(_kInputJson);
      final json = input.toJson();
      expect(json.keys, containsAll(['prev_hash', 'output_index', 'script', 'output_value', 'addresses']));
    });

    test('values match fields', () {
      final input = Input.fromJson(_kInputJson);
      final json = input.toJson();
      expect(json['prev_hash'], 'prevTxHash001');
      expect(json['output_index'], 0);
      expect(json['output_value'], 100000);
      expect(json['addresses'], ['1SenderAddress']);
    });
  });

  // ─────────────────────────────────────────────────
  // Output.fromJson
  // ─────────────────────────────────────────────────

  group('Output.fromJson', () {
    test('parses all fields from complete map', () {
      final output = Output.fromJson(_kOutputJson);
      expect(output.value, 90000);
      expect(output.script, '76a914...');
      expect(output.addresses, ['1ReceiverAddress']);
    });

    test('script is nullable', () {
      final output = Output.fromJson({'value': 100, 'script': null, 'addresses': null});
      expect(output.script, isNull);
    });

    test('addresses is nullable', () {
      final output = Output.fromJson({'value': 100, 'script': null, 'addresses': null});
      expect(output.addresses, isNull);
    });

    test('multiple addresses', () {
      final output = Output.fromJson({
        'value': 1000,
        'script': null,
        'addresses': ['addr1', 'addr2', 'addr3'],
      });
      expect(output.addresses!.length, 3);
    });
  });

  // ─────────────────────────────────────────────────
  // Output.toJson
  // ─────────────────────────────────────────────────

  group('Output.toJson', () {
    test('includes all expected keys', () {
      final output = Output.fromJson(_kOutputJson);
      final json = output.toJson();
      expect(json.keys, containsAll(['value', 'script', 'addresses']));
    });

    test('values match fields', () {
      final output = Output.fromJson(_kOutputJson);
      final json = output.toJson();
      expect(json['value'], 90000);
      expect(json['script'], '76a914...');
    });
  });

  // ─────────────────────────────────────────────────
  // BtcTranDetail.fromJson
  // ─────────────────────────────────────────────────

  group('BtcTranDetail.fromJson', () {
    test('parses all scalar fields', () {
      final detail = BtcTranDetail.fromJson(_kDetailJson);
      expect(detail.blockHash, '0000000000000000000abc');
      expect(detail.blockIndex, 512345);
      expect(detail.hash, 'txhash_abcdef');
      expect(detail.total, 180000);
      expect(detail.fees, 10000);
      expect(detail.confirmed, '2023-12-01T10:00:00Z');
      expect(detail.confirmations, 30);
    });

    test('parses addresses list', () {
      final detail = BtcTranDetail.fromJson(_kDetailJson);
      expect(detail.addresses, ['1addr1', '1addr2']);
    });

    test('parses nested Input list', () {
      final detail = BtcTranDetail.fromJson(_kDetailJson);
      expect(detail.inputs!.length, 1);
      expect(detail.inputs!.first.prevHash, 'prevTxHash001');
      expect(detail.inputs!.first.outputValue, 100000);
    });

    test('parses nested Output list', () {
      final detail = BtcTranDetail.fromJson(_kDetailJson);
      expect(detail.outputs!.length, 1);
      expect(detail.outputs!.first.value, 90000);
      expect(detail.outputs!.first.addresses, ['1ReceiverAddress']);
    });

    test('block_hash and confirmed are nullable', () {
      final detail = BtcTranDetail.fromJson({
        'block_hash': null,
        'block_index': 0,
        'hash': 'unconfirmed_tx',
        'addresses': null,
        'total': 0,
        'fees': 0,
        'confirmed': null,
        'confirmations': 0,
        'inputs': null,
        'outputs': null,
      });
      expect(detail.blockHash, isNull);
      expect(detail.confirmed, isNull);
      expect(detail.addresses, isNull);
      expect(detail.inputs, isNull);
      expect(detail.outputs, isNull);
    });

    test('confirmations >= 26 indicates success', () {
      final detail = BtcTranDetail.fromJson(_kDetailJson);
      // Business rule: confirmations > 26 means confirmed
      expect(detail.confirmations, greaterThan(26));
    });
  });

  // ─────────────────────────────────────────────────
  // Input fromJson / toJson roundtrip
  // ─────────────────────────────────────────────────

  group('Input fromJson/toJson roundtrip', () {
    test('preserves all fields', () {
      final original = Input.fromJson(_kInputJson);
      final restored = Input.fromJson(original.toJson());
      expect(restored.prevHash, original.prevHash);
      expect(restored.outputIndex, original.outputIndex);
      expect(restored.script, original.script);
      expect(restored.outputValue, original.outputValue);
      expect(restored.addresses, original.addresses);
    });
  });

  // ─────────────────────────────────────────────────
  // Output fromJson / toJson roundtrip
  // ─────────────────────────────────────────────────

  group('Output fromJson/toJson roundtrip', () {
    test('preserves all fields', () {
      final original = Output.fromJson(_kOutputJson);
      final restored = Output.fromJson(original.toJson());
      expect(restored.value, original.value);
      expect(restored.script, original.script);
      expect(restored.addresses, original.addresses);
    });
  });
}
