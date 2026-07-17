import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:n42_jmt_verify/n42_jmt_verify.dart';

void main() {
  group('Blake3Hash', () {
    test('matches the official empty-input BLAKE3 vector', () {
      final expected = _hexToBytes(
        'af1349b9f5f9a1a6a0404dea36dcc9499'
        'bcb25c9adc112b7cc9a93cae41f3262',
      );

      expect(Blake3Hash.hash(Uint8List(0)), expected);
    });

    test('deterministic hashing', () {
      final data = Uint8List.fromList([1, 2, 3, 4, 5]);
      final hash1 = Blake3Hash.hash(data);
      final hash2 = Blake3Hash.hash(data);
      expect(hash1, equals(hash2));
      expect(hash1.length, equals(32));
    });

    test('different inputs produce different hashes', () {
      final a = Blake3Hash.hash(Uint8List.fromList([1]));
      final b = Blake3Hash.hash(Uint8List.fromList([2]));
      expect(a, isNot(equals(b)));
    });

    test('hashAll concatenation', () {
      final parts = [
        Uint8List.fromList([1, 2]),
        Uint8List.fromList([3, 4]),
      ];
      final combined = Uint8List.fromList([1, 2, 3, 4]);
      expect(Blake3Hash.hashAll(parts), equals(Blake3Hash.hash(combined)));
    });

    test('accountKey produces 32-byte hash', () {
      final address = Uint8List(20);
      address[19] = 0x42;
      final key = Blake3Hash.accountKey(address);
      expect(key.length, equals(32));
    });

    test('storageKey produces 32-byte hash', () {
      final address = Uint8List(20);
      final slot = Uint8List(32);
      slot[31] = 1;
      final key = Blake3Hash.storageKey(address, slot);
      expect(key.length, equals(32));
    });

    test('different addresses produce different account keys', () {
      final addr1 = Uint8List(20)..fillRange(0, 20, 0x01);
      final addr2 = Uint8List(20)..fillRange(0, 20, 0x02);
      expect(Blake3Hash.accountKey(addr1),
          isNot(equals(Blake3Hash.accountKey(addr2))));
    });
  });

  group('JmtProof', () {
    List<Uint8List> makeFakeShardRoots() {
      return List.generate(16, (i) {
        final root = Uint8List(32);
        root[0] = i;
        return root;
      });
    }

    test('verifyRoot succeeds with correct combined root', () {
      final shardRoots = makeFakeShardRoots();
      final combinedRoot = Blake3Hash.hashAll(shardRoots);

      final proof = JmtProof(
        shardIndex: 0,
        shardRoots: shardRoots,
        proofBytes: Uint8List(0),
        keyHash: Uint8List(32),
      );

      final result = proof.verifyRoot(combinedRoot);
      expect(result.isValid, isTrue);
    });

    test('verifyRoot fails with wrong combined root', () {
      final shardRoots = makeFakeShardRoots();
      final wrongRoot = Uint8List(32)..fillRange(0, 32, 0xFF);

      final proof = JmtProof(
        shardIndex: 0,
        shardRoots: shardRoots,
        proofBytes: Uint8List(0),
        keyHash: Uint8List(32),
      );

      final result = proof.verifyRoot(wrongRoot);
      expect(result.isValid, isFalse);
      expect(result.error, contains('mismatch'));
    });

    test('verifyShardRouting checks first nibble', () {
      // Key hash with first byte 0x5A → first nibble = 5 → shard 5.
      final keyHash = Uint8List(32);
      keyHash[0] = 0x5A;

      final proof = JmtProof(
        shardIndex: 5,
        shardRoots: makeFakeShardRoots(),
        proofBytes: Uint8List(0),
        keyHash: keyHash,
      );

      expect(proof.verifyShardRouting(), isTrue);
    });

    test('verifyShardRouting rejects wrong shard', () {
      final keyHash = Uint8List(32);
      keyHash[0] = 0xA0; // First nibble = 0xA = 10.

      final proof = JmtProof(
        shardIndex: 3, // Wrong shard.
        shardRoots: makeFakeShardRoots(),
        proofBytes: Uint8List(0),
        keyHash: keyHash,
      );

      expect(proof.verifyShardRouting(), isFalse);
    });

    test('verifyRoot rejects wrong shard root count', () {
      expect(
        () => JmtProof(
          shardIndex: 0,
          shardRoots: List.generate(15, (_) => Uint8List(32)),
          proofBytes: Uint8List(0),
          keyHash: Uint8List(32),
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('SparseMerkleProof', () {
    test('constructs without error', () {
      final proof = SparseMerkleProof(
        siblings: [Uint8List(32), Uint8List(32)],
        leaf: SparseMerkleLeaf(
          keyHash: Uint8List(32),
          valueHash: Uint8List(32),
        ),
      );
      expect(proof.siblings.length, equals(2));
      expect(proof.leaf, isNotNull);
    });
  });
}

Uint8List _hexToBytes(String value) {
  return Uint8List.fromList([
    for (var i = 0; i < value.length; i += 2)
      int.parse(value.substring(i, i + 2), radix: 16),
  ]);
}
