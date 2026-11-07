import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:fast_base58/fast_base58.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/near_transaction_hash.dart';

void main() {
  final fixture = jsonDecode(
    File('test/native/near_reference.json').readAsStringSync(),
  ) as Map;
  final encoded = fixture['signedTransaction'] as String;
  final bytes = base64Decode(encoded);
  test('hash matches independently decoded native and CryptoKit fixture', () {
    final hash = nearSignedTransactionHash(encoded);
    expect(
      Base58Decode(hash).map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
      fixture['transactionHashHex'],
    );
  });
  test(
    'signature bytes are excluded but transaction changes alter identity',
    () {
      final changedSignature = bytes.toList()..[bytes.length - 1] ^= 1;
      expect(
        nearSignedTransactionHash(base64Encode(changedSignature)),
        nearSignedTransactionHash(encoded),
      );
      final changedTransaction = bytes.toList()..[bytes.length - 66] ^= 1;
      expect(
        nearSignedTransactionHash(base64Encode(changedTransaction)),
        isNot(nearSignedTransactionHash(encoded)),
      );
    },
  );
  for (final version in [0, 1]) {
    for (final type in [0, 1]) {
      test(
        'version $version key type $type selects the full signature boundary',
        () {
          List<int> account(String name) => [
            name.length,
            0,
            0,
            0,
            ...ascii.encode(name),
          ];
          final preimage = [
            if (version == 1) 1,
            ...account('alice.near'),
            type,
            ...List.filled(type == 0 ? 32 : 64, 7),
            if (version == 1) 0, // TransactionNonce::Nonce
            1,
            ...List.filled(7, 0),
            ...account('bob.near'),
            ...List.filled(32, 2),
            1,
            0,
            0,
            0,
            3,
            1,
            ...List.filled(15, 0),
            if (version == 1) 0,
          ];
          final signed = [
            ...preimage,
            type,
            ...List.filled(type == 0 ? 64 : 65, 9),
          ];
          expect(
            nearSignedTransactionHash(base64Encode(signed)),
            Base58Encode(sha256.convert(preimage).bytes),
          );
        },
      );
    }
  }
  for (final length in [0, 1, 5, 20, 50, 80]) {
    test('truncated envelope length $length rejected', () {
      expect(
        () => nearSignedTransactionHash(
          base64Encode(bytes.take(length).toList()),
        ),
        throwsFormatException,
      );
    });
  }
  test('mismatched signature tag rejected', () {
    final modified = bytes.toList()..[bytes.length - 65] = 1;
    expect(
      () => nearSignedTransactionHash(base64Encode(modified)),
      throwsFormatException,
    );
  });
  test('unknown key type rejected', () {
    final modified = bytes.toList()..[4 + 'alice.near'.length] = 2;
    expect(
      () => nearSignedTransactionHash(base64Encode(modified)),
      throwsFormatException,
    );
  });
  test('noncanonical encoding rejected', () {
    expect(
      () => nearSignedTransactionHash('$encoded\n'),
      throwsFormatException,
    );
  });
}
