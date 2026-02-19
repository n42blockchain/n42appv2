// Tests for SOLTransactionItem (Solana transaction record).
// Pure Dart data class — no platform dependencies.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42appv2/src/wallet/models/transaction/sol_transaction_item.dart';

const _kFullJson = <String, dynamic>{
  '_id': 'doc-id-abc',
  'src': 'SenderSolAddress111',
  'dst': 'ReceiverSolAddress222',
  'lamport': 5000000,
  'blockTime': 1700100000,
  'slot': 200000000,
  'txHash': '5KtP...',
  'status': 'success',
  'fee': 5000,
  'decimals': 9,
  'txNumberSolTransfer': 1,
};

void main() {
  // ─────────────────────────────────────────────────
  // Positional constructor
  // ─────────────────────────────────────────────────

  group('SOLTransactionItem positional constructor', () {
    test('sets all fields correctly', () {
      final item = SOLTransactionItem(
        'doc-id', 'src', 'dst', 5000000, 1700100000,
        200000000, '5KtP', 'success', 5000, 9, 1,
      );
      expect(item.src, 'src');
      expect(item.dst, 'dst');
      expect(item.lamport, 5000000);
      expect(item.blockTime, 1700100000);
      expect(item.slot, 200000000);
      expect(item.txHash, '5KtP');
      expect(item.status, 'success');
      expect(item.fee, 5000);
      expect(item.decimals, 9);
      expect(item.txNumberSolTransfer, 1);
    });
  });

  // ─────────────────────────────────────────────────
  // fromJson
  // ─────────────────────────────────────────────────

  group('SOLTransactionItem.fromJson', () {
    test('parses all fields from complete map', () {
      final item = SOLTransactionItem.fromJson(_kFullJson);
      expect(item.src, 'SenderSolAddress111');
      expect(item.dst, 'ReceiverSolAddress222');
      expect(item.lamport, 5000000);
      expect(item.blockTime, 1700100000);
      expect(item.slot, 200000000);
      expect(item.txHash, '5KtP...');
      expect(item.status, 'success');
      expect(item.fee, 5000);
      expect(item.decimals, 9);
      expect(item.txNumberSolTransfer, 1);
    });

    test('all fields are null when map is empty', () {
      final item = SOLTransactionItem.fromJson({});
      expect(item.src, isNull);
      expect(item.dst, isNull);
      expect(item.lamport, isNull);
      expect(item.blockTime, isNull);
      expect(item.txHash, isNull);
      expect(item.status, isNull);
      expect(item.fee, isNull);
      expect(item.decimals, isNull);
      expect(item.txNumberSolTransfer, isNull);
    });

    test('parses partial map', () {
      final item = SOLTransactionItem.fromJson({
        'src': 'Alice',
        'dst': 'Bob',
        'status': 'pending',
      });
      expect(item.src, 'Alice');
      expect(item.dst, 'Bob');
      expect(item.status, 'pending');
      expect(item.lamport, isNull);
      expect(item.fee, isNull);
    });

    test('status = "fail" is parsed correctly', () {
      final item = SOLTransactionItem.fromJson({'status': 'fail'});
      expect(item.status, 'fail');
    });
  });

  // ─────────────────────────────────────────────────
  // toJson
  // ─────────────────────────────────────────────────

  group('SOLTransactionItem.toJson', () {
    test('includes all expected keys', () {
      final item = SOLTransactionItem.fromJson(_kFullJson);
      final json = item.toJson();
      expect(json.keys, containsAll([
        '_id', 'src', 'dst', 'lamport', 'blockTime',
        'slot', 'txHash', 'status', 'fee', 'decimals', 'txNumberSolTransfer',
      ]));
    });

    test('values match model fields', () {
      final item = SOLTransactionItem.fromJson(_kFullJson);
      final json = item.toJson();
      expect(json['src'], 'SenderSolAddress111');
      expect(json['dst'], 'ReceiverSolAddress222');
      expect(json['lamport'], 5000000);
      expect(json['status'], 'success');
      expect(json['fee'], 5000);
      expect(json['decimals'], 9);
    });

    test('null fields appear as null in json map', () {
      final item = SOLTransactionItem.fromJson({'src': 'Alice'});
      final json = item.toJson();
      expect(json['src'], 'Alice');
      expect(json['dst'], isNull);
      expect(json['lamport'], isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // fromJson / toJson roundtrip
  // ─────────────────────────────────────────────────

  group('SOLTransactionItem fromJson/toJson roundtrip', () {
    test('preserves all fields', () {
      final original = SOLTransactionItem.fromJson(_kFullJson);
      final restored = SOLTransactionItem.fromJson(original.toJson());
      expect(restored.src, original.src);
      expect(restored.dst, original.dst);
      expect(restored.lamport, original.lamport);
      expect(restored.blockTime, original.blockTime);
      expect(restored.slot, original.slot);
      expect(restored.txHash, original.txHash);
      expect(restored.status, original.status);
      expect(restored.fee, original.fee);
      expect(restored.decimals, original.decimals);
      expect(restored.txNumberSolTransfer, original.txNumberSolTransfer);
    });
  });
}
