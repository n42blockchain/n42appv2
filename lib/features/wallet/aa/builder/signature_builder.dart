// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:typed_data';
import 'package:web3dart/web3dart.dart';

import 'package:n42_wallet/core/passkey/passkey_credential.dart';

import '../core/aa_errors.dart';
import '../models/user_operation.dart';
import 'passkey_signature_builder.dart';

/// Builder for creating signatures for UserOperations
///
/// Handles the signing flow for smart account transactions,
/// including EIP-191 personal signatures and EIP-712 typed data.
class SignatureBuilder {
  SignatureBuilder._();

  /// Format a raw signature for use in a UserOperation
  ///
  /// Ensures the signature is in the correct format (65 bytes: r + s + v)
  /// and adjusts v if necessary.
  static Uint8List formatSignature(String rawSignature) {
    final sigBytes = hexToBytes(rawSignature.replaceFirst('0x', ''));

    if (sigBytes.length != 65) {
      throw SignatureError(
        'Invalid signature length',
        details: 'Expected 65 bytes, got ${sigBytes.length}',
      );
    }

    // Adjust v value if needed (should be 27 or 28 for Ethereum)
    if (sigBytes[64] < 27) {
      sigBytes[64] += 27;
    }

    return sigBytes;
  }

  /// Parse signature into components (r, s, v)
  static SignatureComponents parseSignature(Uint8List signature) {
    if (signature.length != 65) {
      throw SignatureError('Invalid signature length');
    }

    final r = bytesToHex(signature.sublist(0, 32));
    final s = bytesToHex(signature.sublist(32, 64));
    final v = signature[64];

    return SignatureComponents(r: r, s: s, v: v);
  }

  /// Combine signature components into bytes
  static Uint8List combineSignature(SignatureComponents components) {
    final result = Uint8List(65);

    final rBytes = hexToBytes(
      components.r.replaceFirst('0x', '').padLeft(64, '0'),
    );
    final sBytes = hexToBytes(
      components.s.replaceFirst('0x', '').padLeft(64, '0'),
    );

    result.setAll(0, rBytes);
    result.setAll(32, sBytes);
    result[64] = components.v;

    return result;
  }

  /// Create a signed UserOperation
  ///
  /// Takes a UserOperation and signature, returns a new UserOperation with
  /// the signature attached.
  static UserOperation attachSignature(
    UserOperation userOp,
    Uint8List signature,
  ) {
    return userOp.copyWith(signature: signature);
  }

  /// Prepare the message hash for signing (EIP-191 personal sign format)
  ///
  /// Returns the hash that should be signed using eth_sign or personal_sign.
  /// The prefix "\x19Ethereum Signed Message:\n32" is added by the wallet.
  static Uint8List preparePersonalSignHash(Uint8List userOpHash) {
    // For personal_sign, we just return the raw hash
    // The wallet will add the prefix
    return userOpHash;
  }

  /// Get the message to sign as a hex string
  static String getSignMessage(
    UserOperation userOp,
    String entryPoint,
    BigInt chainId,
  ) {
    final hash = userOp.getUserOpHash(entryPoint, chainId);
    return '0x${bytesToHex(hash)}';
  }

  /// Validate a signature against a UserOperation
  ///
  /// Returns true if the signature is valid for the given UserOperation
  /// and signer address.
  static bool validateSignature({
    required UserOperation userOp,
    required String entryPoint,
    required BigInt chainId,
    required String signerAddress,
    required Uint8List signature,
  }) {
    try {
      final userOpHash = userOp.getUserOpHash(entryPoint, chainId);

      // Recover the signer from the signature
      final recoveredAddress = recoverSignerAddress(
        hash: userOpHash,
        signature: signature,
      );

      return recoveredAddress.toLowerCase() == signerAddress.toLowerCase();
    } catch (_) {
      return false;
    }
  }

  /// Recover signer address from a signature
  ///
  /// Uses ecrecover to determine the address that signed the message.
  static String recoverSignerAddress({
    required Uint8List hash,
    required Uint8List signature,
  }) {
    if (signature.length != 65) {
      throw SignatureError('Invalid signature length');
    }

    final r = bytesToUnsignedInt(Uint8List.fromList(signature.sublist(0, 32)));
    final s = bytesToUnsignedInt(Uint8List.fromList(signature.sublist(32, 64)));
    int v = signature[64];
    if (v < 27) v += 27;

    final msgSig = MsgSignature(r, s, v);
    final pubKeyBytes = ecRecover(hash, msgSig);

    // ecRecover may return fewer than 64 bytes if leading zeros are stripped.
    // publicKeyToAddress asserts length == 64, so pad if needed.
    final Uint8List padded;
    if (pubKeyBytes.length < 64) {
      padded = Uint8List(64);
      padded.setAll(64 - pubKeyBytes.length, pubKeyBytes);
    } else {
      padded = pubKeyBytes;
    }

    final addressBytes = publicKeyToAddress(padded);
    return '0x${bytesToHex(addressBytes)}';
  }

  /// Create a dummy signature for gas estimation
  static Uint8List createDummySignature() {
    // Create a valid-looking but fake signature
    // This is used for gas estimation when we don't have the real signature yet
    return Uint8List.fromList(List.filled(65, 0xFF));
  }

  /// Create a dummy Passkey signature for gas estimation.
  ///
  /// Passkey signatures are larger than secp256k1 (ABI-encoded vs 65 bytes),
  /// so gas estimation must use a correctly-sized dummy.
  static Uint8List createDummyPasskeySignature() {
    return PasskeySignatureBuilder.createDummyPasskeySignature();
  }

  /// Format a Passkey (P-256) authentication result for on-chain verification.
  ///
  /// Returns ABI-encoded (authenticatorData, clientDataJSON,
  /// challengeIndex, typeIndex, r, s).
  static Uint8List formatPasskeySignature(PasskeyAuthResult authResult) {
    return PasskeySignatureBuilder.formatPasskeySignature(authResult);
  }

  /// Check if a signature is a Passkey signature (> 65 bytes).
  static bool isPasskeySignature(Uint8List signature) {
    return PasskeySignatureBuilder.isPasskeySignature(signature);
  }

  /// Check if a signature looks valid (basic format check)
  static bool isValidSignatureFormat(Uint8List signature) {
    if (signature.length != 65) return false;

    // v should be 27 or 28 (or 0/1 before adjustment)
    final v = signature[64];
    if (v != 27 && v != 28 && v != 0 && v != 1) return false;

    return true;
  }
}

/// Signature components (r, s, v)
class SignatureComponents {
  /// r component (32 bytes as hex)
  final String r;

  /// s component (32 bytes as hex)
  final String s;

  /// v component (recovery id, 27 or 28)
  final int v;

  const SignatureComponents({
    required this.r,
    required this.s,
    required this.v,
  });

  /// Convert to compact signature format
  String toCompact() {
    return '0x$r$s${v.toRadixString(16).padLeft(2, '0')}';
  }

  /// Parse from compact signature string
  factory SignatureComponents.fromCompact(String signature) {
    final sig = signature.replaceFirst('0x', '');
    if (sig.length != 130) {
      throw SignatureError('Invalid compact signature length');
    }

    return SignatureComponents(
      r: sig.substring(0, 64),
      s: sig.substring(64, 128),
      v: int.parse(sig.substring(128), radix: 16),
    );
  }

  @override
  String toString() {
    return 'SignatureComponents(r: 0x${r.substring(0, 8)}..., s: 0x${s.substring(0, 8)}..., v: $v)';
  }
}

/// EIP-712 typed data for UserOperation signing
class UserOpTypedData {
  static const String domainName = 'Account Abstraction';
  static const String domainVersion = '1';

  /// Build EIP-712 typed data structure for a UserOperation
  static Map<String, dynamic> build({
    required UserOperation userOp,
    required String entryPoint,
    required BigInt chainId,
  }) {
    return {
      'types': {
        'EIP712Domain': [
          {'name': 'name', 'type': 'string'},
          {'name': 'version', 'type': 'string'},
          {'name': 'chainId', 'type': 'uint256'},
          {'name': 'verifyingContract', 'type': 'address'},
        ],
        'UserOperation': [
          {'name': 'sender', 'type': 'address'},
          {'name': 'nonce', 'type': 'uint256'},
          {'name': 'initCode', 'type': 'bytes'},
          {'name': 'callData', 'type': 'bytes'},
          {'name': 'accountGasLimits', 'type': 'bytes32'},
          {'name': 'preVerificationGas', 'type': 'uint256'},
          {'name': 'gasFees', 'type': 'bytes32'},
          {'name': 'paymasterAndData', 'type': 'bytes'},
        ],
      },
      'primaryType': 'UserOperation',
      'domain': {
        'name': domainName,
        'version': domainVersion,
        'chainId': chainId.toString(),
        'verifyingContract': entryPoint,
      },
      'message': {
        'sender': userOp.sender,
        'nonce': userOp.nonce.toString(),
        'initCode': '0x${bytesToHex(userOp.initCode ?? Uint8List(0))}',
        'callData': '0x${bytesToHex(userOp.callData)}',
        'accountGasLimits': '0x${bytesToHex(userOp.accountGasLimits)}',
        'preVerificationGas': userOp.preVerificationGas.toString(),
        'gasFees': '0x${bytesToHex(userOp.gasFees)}',
        'paymasterAndData':
            '0x${bytesToHex(userOp.paymasterAndData ?? Uint8List(0))}',
      },
    };
  }
}
