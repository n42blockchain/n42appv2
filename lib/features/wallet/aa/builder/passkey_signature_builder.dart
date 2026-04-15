// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:typed_data';

import 'package:n42_wallet/core/passkey/passkey_credential.dart';

/// Builder for encoding Passkey (P-256) signatures into the format
/// expected by on-chain smart account validators.
///
/// On-chain signature format (ABI-encoded):
/// ```solidity
/// abi.encode(
///   bytes authenticatorData,
///   string clientDataJSON,
///   uint256 challengeIndex,
///   uint256 typeIndex,
///   uint256 r,
///   uint256 s
/// )
/// ```
///
/// The smart contract verifies:
/// 1. Extract challenge from clientDataJSON[challengeIndex]
/// 2. Verify challenge matches the userOpHash
/// 3. Verify P-256 signature (r, s) over sha256(authenticatorData || sha256(clientDataJSON))
///    using RIP-7212 precompile or Solidity P256Verifier
class PasskeySignatureBuilder {
  PasskeySignatureBuilder._();

  /// Encode a Passkey authentication result into an on-chain verifiable signature.
  ///
  /// [authResult] — result from PasskeyPlatformAdapter.authenticate()
  /// containing authenticatorData, clientDataJSON, r, s, and index values.
  ///
  /// Returns ABI-encoded bytes suitable for UserOperation.signature field.
  static Uint8List formatPasskeySignature(PasskeyAuthResult authResult) {
    // ABI encode: (bytes, string, uint256, uint256, uint256, uint256)
    final encoded = _abiEncode(
      authenticatorData: authResult.authenticatorData,
      clientDataJSON: authResult.clientDataJSON,
      challengeIndex: BigInt.from(authResult.challengeIndex),
      typeIndex: BigInt.from(authResult.typeIndex),
      r: authResult.r,
      s: authResult.s,
    );

    return encoded;
  }

  /// Create a dummy Passkey signature for gas estimation.
  ///
  /// Must have the same byte length as a real signature so gas estimation
  /// is accurate. Uses plausible-looking but invalid values.
  static Uint8List createDummyPasskeySignature() {
    // Typical authenticatorData: 37 bytes (rpIdHash 32 + flags 1 + signCount 4)
    final dummyAuthData = Uint8List(37);
    dummyAuthData.fillRange(0, 32, 0xAA); // fake rpIdHash
    dummyAuthData[32] = 0x05; // flags: UP + UV
    // signCount remains 0

    // Typical clientDataJSON
    final dummyClientData =
        '{"type":"webauthn.get","challenge":"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA","origin":"https://n42.ai"}'
            .codeUnits;

    return _abiEncode(
      authenticatorData: Uint8List.fromList(dummyAuthData),
      clientDataJSON: Uint8List.fromList(dummyClientData),
      challengeIndex: BigInt.from(36),
      typeIndex: BigInt.from(1),
      r: BigInt.parse(
          'FFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC632550',
          radix: 16),
      s: BigInt.parse(
          '7FFFFFFF800000007FFFFFFFFFFFFFFFDE7375D6D53BCF4279DCE5617E3192A7',
          radix: 16),
    );
  }

  /// Check if a signature looks like a Passkey signature (vs secp256k1).
  ///
  /// Passkey signatures are ABI-encoded and typically > 200 bytes,
  /// while secp256k1 signatures are exactly 65 bytes.
  static bool isPasskeySignature(Uint8List signature) {
    return signature.length > 65;
  }

  // ==================== Internal ABI Encoding ====================

  /// ABI-encode the Passkey signature components.
  ///
  /// Layout (Solidity ABI encoding for dynamic types):
  /// - offset of authenticatorData (bytes)
  /// - offset of clientDataJSON (string)
  /// - challengeIndex (uint256)
  /// - typeIndex (uint256)
  /// - r (uint256)
  /// - s (uint256)
  /// - authenticatorData length + padded data
  /// - clientDataJSON length + padded data
  static Uint8List _abiEncode({
    required Uint8List authenticatorData,
    required Uint8List clientDataJSON,
    required BigInt challengeIndex,
    required BigInt typeIndex,
    required BigInt r,
    required BigInt s,
  }) {
    // Calculate offsets
    // 6 head slots × 32 bytes = 192 bytes for the head
    const headSize = 6 * 32;

    // authenticatorData: 32 bytes length + padded data
    final authDataPaddedLen = _padTo32(authenticatorData.length);
    final authDataSlotSize = 32 + authDataPaddedLen;

    // clientDataJSON: 32 bytes length + padded data
    final clientDataPaddedLen = _padTo32(clientDataJSON.length);
    final clientDataSlotSize = 32 + clientDataPaddedLen;

    final totalSize = headSize + authDataSlotSize + clientDataSlotSize;
    final result = Uint8List(totalSize);

    var offset = 0;

    // Head slot 0: offset to authenticatorData
    _writeUint256(result, offset, BigInt.from(headSize));
    offset += 32;

    // Head slot 1: offset to clientDataJSON
    _writeUint256(result, offset, BigInt.from(headSize + authDataSlotSize));
    offset += 32;

    // Head slot 2: challengeIndex
    _writeUint256(result, offset, challengeIndex);
    offset += 32;

    // Head slot 3: typeIndex
    _writeUint256(result, offset, typeIndex);
    offset += 32;

    // Head slot 4: r
    _writeUint256(result, offset, r);
    offset += 32;

    // Head slot 5: s
    _writeUint256(result, offset, s);
    offset += 32;

    // authenticatorData: length + data
    _writeUint256(result, offset, BigInt.from(authenticatorData.length));
    offset += 32;
    result.setAll(offset, authenticatorData);
    offset += authDataPaddedLen;

    // clientDataJSON: length + data
    _writeUint256(result, offset, BigInt.from(clientDataJSON.length));
    offset += 32;
    result.setAll(offset, clientDataJSON);

    return result;
  }

  /// Write a BigInt as a 32-byte big-endian uint256.
  static void _writeUint256(Uint8List buffer, int offset, BigInt value) {
    final bytes = _bigIntToBytes32(value);
    buffer.setAll(offset, bytes);
  }

  /// Convert BigInt to exactly 32 bytes, big-endian, zero-padded.
  static Uint8List _bigIntToBytes32(BigInt value) {
    final result = Uint8List(32);
    var v = value;
    for (var i = 31; i >= 0; i--) {
      result[i] = (v & BigInt.from(0xFF)).toInt();
      v >>= 8;
    }
    return result;
  }

  /// Round up to nearest multiple of 32.
  static int _padTo32(int length) {
    return ((length + 31) ~/ 32) * 32;
  }
}

/// Parsed Passkey signature components (for debugging/display).
class PasskeySignatureComponents {
  final Uint8List authenticatorData;
  final Uint8List clientDataJSON;
  final int challengeIndex;
  final int typeIndex;
  final BigInt r;
  final BigInt s;

  PasskeySignatureComponents({
    required this.authenticatorData,
    required this.clientDataJSON,
    required this.challengeIndex,
    required this.typeIndex,
    required this.r,
    required this.s,
  });
}
