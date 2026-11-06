import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet_connect/validation/aptos_raw_transaction.dart';

List<int> text(String value) => [value.length, ...utf8.encode(value)];
List<int> entry() => [
  ...List.filled(31, 0),
  1,
  ...text('coin'),
  ...text('transfer'),
  0,
  2,
  32,
  ...List.filled(31, 0),
  2,
  8,
  1,
  ...List.filled(7, 0),
];
List<int> raw(List<int> payload, {int chain = 1}) => [
  ...List.filled(31, 0),
  1,
  ...List.filled(8, 0),
  ...payload,
  ...List.filled(24, 0),
  chain,
];
AptosRawTransaction parse(
  List<int> bytes, {
  String sender = '0x1',
  int chain = 1,
}) => AptosRawTransaction.parse(
  base64Encode(bytes),
  expectedSender: sender,
  expectedChainId: chain,
);

void main() {
  test('independent Node transfer vectors parse without changing bytes', () {
    final vectors = jsonDecode(
      File('test/fixtures/aptos/raw_signing_vectors.json').readAsStringSync(),
    ) as List;
    for (final v in vectors) {
      final hex = v['raw'] as String;
      final transaction = AptosRawTransaction.parse(
        '0x$hex',
        expectedSender: '0x${hex.substring(0, 64)}',
        expectedChainId: v['chain'] as int,
      );
      expect(
        transaction.bytes
            .map((b) => b.toRadixString(16).padLeft(2, '0'))
            .join(),
        hex,
      );
      expect(
        () => AptosRawTransaction.parse(
          '0x${v['signed']}',
          expectedSender: transaction.sender,
          expectedChainId: transaction.chainId,
        ),
        throwsFormatException,
      );
    }
  });

  final payloads = <String, List<int>>{
    'entry': [2, ...entry()],
    'script': [0, 1, 42, 0, 2, 0, 7, 5, 1],
    'legacy module': [1, 1, 2, 42, 43],
    'multisig reference': [3, ...List.filled(32, 2), 0],
    'multisig entry': [3, ...List.filled(32, 2), 1, 0, ...entry()],
  };
  for (final item in payloads.entries) {
    test('${item.key} preserves bytes and rejects every truncation', () {
      final bytes = raw(item.value);
      final decoded = parse(bytes);
      expect(decoded.bytes, bytes);
      expect(decoded.chainId, 1);
      for (var size = 0; size < bytes.length; size++) {
        expect(
          () => parse(bytes.sublist(0, size)),
          throwsFormatException,
          reason: 'prefix $size',
        );
      }
      expect(() => parse([...bytes, 0]), throwsFormatException);
      expect(() => parse(bytes, sender: '0x2'), throwsFormatException);
      expect(() => parse(bytes, chain: 2), throwsFormatException);
      final copy = decoded.bytes..[0] = 99;
      expect(decoded.bytes, isNot(copy));
    });
  }
  test(
    'explicit hex and normalized short addresses preserve raw transaction',
    () {
      final bytes = raw([2, ...entry()], chain: 2);
      final hex = bytes.map((v) => v.toRadixString(16).padLeft(2, '0')).join();
      final tx = AptosRawTransaction.parse(
        '0x$hex',
        expectedSender: '0001',
        expectedChainId: 2,
      );
      expect(tx.bytes, bytes);
    },
  );
  for (final payload in <List<int>>[
    [0x82, 0, ...entry()],
    [255, 255, 255, 255, 16],
    [4],
    [2, ...List.filled(32, 1), 0],
    [3, ...List.filled(32, 1), 2],
    [0, 0, 0, 1, 5, 2],
    [0, 0, 1, ...List.filled(66, 6), 0, 0],
  ]) {
    test('invalid/noncanonical payload $payload fails', () {
      expect(() => parse(raw(payload)), throwsFormatException);
    });
  }
  test(
    'Move identifiers follow bytecode rules without accepting trailing data',
    () {
      for (final name in [
        r'$internal',
        '_name',
        '<SELF>',
        '<SELF>_12',
        'normal',
      ]) {
        final payload = [
          2,
          ...List.filled(32, 1),
          ...text(name),
          ...text('f'),
          0,
          0,
        ];
        expect(parse(raw(payload)).chainId, 1);
      }
      for (final name in ['_', r'$', 'name\n', '1name', '<SELF>_x']) {
        final payload = [
          2,
          ...List.filled(32, 1),
          ...text(name),
          ...text('f'),
          0,
          0,
        ];
        expect(() => parse(raw(payload)), throwsFormatException);
      }
    },
  );
  test('invalid input encoding and size fail', () {
    for (final encoded in ['', '!!!', '0x0', '0xgg', 'A' * 131075]) {
      expect(
        () => AptosRawTransaction.parse(
          encoded,
          expectedSender: '0x1',
          expectedChainId: 1,
        ),
        throwsFormatException,
      );
    }
  });
}
