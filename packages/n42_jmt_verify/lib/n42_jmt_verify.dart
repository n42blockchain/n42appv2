/// N42 Jellyfish Merkle Tree proof verification.
///
/// Pure Dart implementation for mobile clients. Only needs:
/// - Blake3 hashing (via hashlib)
/// - SparseMerkleProof verification logic
///
/// No FFI, no native dependencies — works on all Flutter platforms.
library n42_jmt_verify;

export 'src/blake3_hash.dart';
export 'src/jmt_proof.dart';
export 'src/sparse_merkle_proof.dart';
