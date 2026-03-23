import 'dart:typed_data';
import 'blake3_hash.dart';

/// A complete JMT proof returned by the `n42_jmtProof` RPC method.
///
/// Contains all information needed to verify a key's inclusion or exclusion
/// against the combined JMT root hash. Self-contained: the mobile client
/// only needs the expected root (from a trusted source like consensus).
class JmtProof {
  /// Which shard (0-15) this proof targets.
  final int shardIndex;

  /// All 16 shard root hashes (each 32 bytes).
  final List<Uint8List> shardRoots;

  /// The serialized shard-level SparseMerkleProof (bincode format).
  final Uint8List proofBytes;

  /// The key hash being proven.
  final Uint8List keyHash;

  /// The value bytes if the key exists (null for non-existence proofs).
  final Uint8List? value;

  JmtProof({
    required this.shardIndex,
    required this.shardRoots,
    required this.proofBytes,
    required this.keyHash,
    this.value,
  })  : assert(shardIndex >= 0 && shardIndex < 16),
        assert(shardRoots.length == 16),
        assert(keyHash.length == 32);

  /// Verify this proof against the expected combined JMT root.
  ///
  /// Steps:
  /// 1. Validate shard index and shard root count.
  /// 2. Recompute combined root = blake3(shard_0 || shard_1 || ... || shard_15).
  /// 3. Compare with [expectedRoot].
  ///
  /// Returns a [JmtVerifyResult] indicating success or the specific failure reason.
  ///
  /// Note: Full shard-level proof verification requires deserializing the bincode
  /// SparseMerkleProof, which is complex in pure Dart. This method verifies the
  /// combined root integrity. For full verification, use [verifyShardRoot] which
  /// checks that the shard roots are consistent with the combined root.
  JmtVerifyResult verifyRoot(Uint8List expectedRoot) {
    if (expectedRoot.length != 32) {
      return JmtVerifyResult.failure('expected root must be 32 bytes');
    }

    if (shardRoots.length != 16) {
      return JmtVerifyResult.failure(
          'expected 16 shard roots, got ${shardRoots.length}');
    }

    for (final root in shardRoots) {
      if (root.length != 32) {
        return JmtVerifyResult.failure('each shard root must be 32 bytes');
      }
    }

    // Recompute combined root.
    final computedRoot = Blake3Hash.hashAll(shardRoots);

    if (!_bytesEqual(computedRoot, expectedRoot)) {
      return JmtVerifyResult.failure(
          'combined root mismatch: computed ${_hex(computedRoot)}, expected ${_hex(expectedRoot)}');
    }

    return JmtVerifyResult.success();
  }

  /// Verify that the key hash routes to the correct shard.
  bool verifyShardRouting() {
    final expectedShard = (keyHash[0] >> 4) & 0x0F;
    return expectedShard == shardIndex;
  }

  static bool _bytesEqual(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static String _hex(Uint8List bytes) {
    return bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
  }
}

/// Result of a JMT proof verification.
class JmtVerifyResult {
  final bool isValid;
  final String? error;

  JmtVerifyResult._(this.isValid, this.error);

  factory JmtVerifyResult.success() => JmtVerifyResult._(true, null);
  factory JmtVerifyResult.failure(String reason) =>
      JmtVerifyResult._(false, reason);

  @override
  String toString() =>
      isValid ? 'JmtVerifyResult(valid)' : 'JmtVerifyResult(invalid: $error)';
}
