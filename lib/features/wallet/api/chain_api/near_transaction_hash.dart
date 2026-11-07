import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:fast_base58/fast_base58.dart';

/// Hash the transaction portion of a canonical NEAR signed envelope.
/// Supports V0/V1 and Ed25519/secp256k1 signature sizes. Actions remain opaque;
/// this is identity extraction, not action validation or signature verification.
String nearSignedTransactionHash(String encoded) {
  final bytes = base64Decode(encoded);
  if (bytes.length < 2 || base64Encode(bytes) != encoded) {
    throw const FormatException('Invalid NEAR signed envelope');
  }
  var offset = bytes[1] == 0
      ? 0
      : bytes[0] == 1
      ? 1
      : -1;
  if (offset < 0) throw const FormatException('Unsupported NEAR version');
  void skip(int size) {
    if (size < 0 || offset + size > bytes.length) {
      throw const FormatException('Truncated NEAR envelope');
    }
    offset += size;
  }

  void account() {
    final start = offset;
    skip(4);
    final size =
        bytes[start] |
        bytes[start + 1] << 8 |
        bytes[start + 2] << 16 |
        bytes[start + 3] << 24;
    if (size < 2 || size > 64) {
      throw const FormatException('Invalid NEAR account length');
    }
    final textStart = offset;
    skip(size);
    final name = ascii.decode(bytes.sublist(textStart, offset));
    if (!RegExp(r'^[a-z0-9]+([._-][a-z0-9]+)*$').hasMatch(name) ||
        name.contains('\n') ||
        name.contains('\r')) {
      throw const FormatException('Invalid NEAR account');
    }
  }

  account();
  final typeOffset = offset;
  skip(1);
  final keyType = bytes[typeOffset];
  final publicKeyLength = switch (keyType) {
    0 => 32,
    1 => 64,
    _ => 0,
  };
  if (publicKeyLength == 0) throw const FormatException('Unsupported NEAR key');
  skip(publicKeyLength);
  // Both versions share the signer/key prefix. Keep the remaining transaction
  // opaque so hashing does not restrict action types or versioned nonce modes.
  // Require room for nonce, receiver length/minimum name, block and action count.
  skip(8 + 4 + 2 + 32 + 4);
  final signatureLength = keyType == 0 ? 64 : 65;
  final signatureOffset = bytes.length - signatureLength - 1;
  if (signatureOffset < offset || bytes[signatureOffset] != keyType) {
    throw const FormatException('Invalid NEAR signature envelope');
  }
  return Base58Encode(sha256.convert(bytes.sublist(0, signatureOffset)).bytes);
}
