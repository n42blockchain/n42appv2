import 'dart:typed_data';
import 'blake3_hash.dart';

/// A sibling node in the Merkle proof path.
class ProofSibling {
  /// Hash of the sibling node.
  final Uint8List hash;

  ProofSibling(this.hash) : assert(hash.length == 32);
}

/// Sparse Merkle Proof for a single key in a JMT shard.
///
/// Verifies inclusion (key exists with a specific value) or exclusion
/// (key does not exist in the tree).
///
/// The proof structure matches the Rust `jmt::proof::SparseMerkleProof`:
/// - A list of sibling hashes along the path from root to leaf
/// - An optional leaf node (present for inclusion, absent for exclusion in empty subtrees)
class SparseMerkleProof {
  /// Sibling hashes from root to leaf (top-down).
  final List<Uint8List> siblings;

  /// The leaf node at the proof path, if any.
  /// For inclusion proofs: matches the queried key.
  /// For exclusion proofs: may be a different key (proving the queried key's slot is occupied by another key).
  /// null if the subtree is entirely empty.
  final SparseMerkleLeaf? leaf;

  SparseMerkleProof({required this.siblings, this.leaf});

  /// Verify this proof against a shard root hash.
  ///
  /// For inclusion: [expectedValue] must match the leaf value.
  /// For exclusion: [expectedValue] must be null.
  ///
  /// Returns true if the proof is valid.
  bool verify({
    required Uint8List shardRoot,
    required Uint8List keyHash,
    Uint8List? expectedValue,
  }) {
    assert(shardRoot.length == 32);
    assert(keyHash.length == 32);

    // Determine what the leaf hash should be.
    Uint8List currentHash;

    if (leaf != null) {
      // Compute leaf node hash.
      final leafHash = _hashLeaf(leaf!.keyHash, leaf!.valueHash);

      if (expectedValue != null) {
        // Inclusion proof: leaf key must match.
        if (!_bytesEqual(leaf!.keyHash, keyHash)) {
          return false;
        }
        // Value hash must match.
        final computedValueHash = Blake3Hash.hash(expectedValue);
        if (!_bytesEqual(leaf!.valueHash, computedValueHash)) {
          return false;
        }
      } else {
        // Exclusion proof with a different leaf: leaf key must NOT match.
        if (_bytesEqual(leaf!.keyHash, keyHash)) {
          return false; // Key exists, but we expected exclusion.
        }
      }
      currentHash = leafHash;
    } else {
      // Empty subtree: only valid for exclusion proofs.
      if (expectedValue != null) {
        return false;
      }
      // Hash of empty node (placeholder).
      currentHash = _emptyHash();
    }

    // Walk up from leaf to root, incorporating siblings.
    final bits = _keyBits(keyHash);
    for (int i = siblings.length - 1; i >= 0; i--) {
      final sibling = siblings[i];
      final bit = bits[i];

      if (bit == 0) {
        // Current node is left child.
        currentHash = _hashInternal(currentHash, sibling);
      } else {
        // Current node is right child.
        currentHash = _hashInternal(sibling, currentHash);
      }
    }

    return _bytesEqual(currentHash, shardRoot);
  }

  /// Hash an internal node: blake3(left || right).
  static Uint8List _hashInternal(Uint8List left, Uint8List right) {
    return Blake3Hash.hashAll([left, right]);
  }

  /// Hash a leaf node: blake3(key_hash || value_hash).
  static Uint8List _hashLeaf(Uint8List keyHash, Uint8List valueHash) {
    return Blake3Hash.hashAll([keyHash, valueHash]);
  }

  /// 256-bit zero hash representing an empty subtree.
  static Uint8List _emptyHash() {
    return Uint8List(32); // All zeros.
  }

  /// Extract bit path from key hash (MSB first).
  static List<int> _keyBits(Uint8List keyHash) {
    final bits = <int>[];
    for (final byte in keyHash) {
      for (int bit = 7; bit >= 0; bit--) {
        bits.add((byte >> bit) & 1);
      }
    }
    return bits;
  }

  static bool _bytesEqual(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// A leaf node in the sparse Merkle tree.
class SparseMerkleLeaf {
  /// Blake3 hash of the key.
  final Uint8List keyHash;

  /// Blake3 hash of the value.
  final Uint8List valueHash;

  SparseMerkleLeaf({required this.keyHash, required this.valueHash})
      : assert(keyHash.length == 32),
        assert(valueHash.length == 32);
}
