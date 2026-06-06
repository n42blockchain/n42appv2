// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:typed_data';
import 'package:web3dart/web3dart.dart';

import '../core/aa_config.dart';

/// ERC-4337 UserOperation structure
///
/// Represents a user's intent to perform an action through their smart account.
/// Supports both v0.7 and v0.8 EntryPoint specifications.
class UserOperation {
  /// Smart account address that will execute this operation
  final String sender;

  /// Anti-replay parameter (unique per account per key)
  final BigInt nonce;

  /// Account bytecode + factory call data for first-time deployment
  /// Empty if account is already deployed
  Uint8List? initCode;

  /// The actual operation data (encoded function calls)
  final Uint8List callData;

  /// Packed gas limits: verificationGasLimit (16 bytes) + callGasLimit (16 bytes)
  final Uint8List accountGasLimits;

  /// Gas overhead for pre-execution validation
  final BigInt preVerificationGas;

  /// Packed gas prices: maxPriorityFeePerGas (16 bytes) + maxFeePerGas (16 bytes)
  final Uint8List gasFees;

  /// Paymaster address + verification data + post-op data
  /// Empty if not using paymaster
  Uint8List? paymasterAndData;

  /// Signature over the hash of the operation
  Uint8List? signature;

  /// EIP-7702 authorization data (v0.8 only)
  /// Contains the signed authorization for EOA to act as smart account
  Uint8List? eip7702Auth;

  UserOperation({
    required this.sender,
    required this.nonce,
    this.initCode,
    required this.callData,
    required this.accountGasLimits,
    required this.preVerificationGas,
    required this.gasFees,
    this.paymasterAndData,
    this.signature,
    this.eip7702Auth,
  });

  /// Get verification gas limit from packed accountGasLimits
  BigInt get verificationGasLimit {
    if (accountGasLimits.length != 32) return BigInt.zero;
    return bytesToInt(accountGasLimits.sublist(0, 16));
  }

  /// Get call gas limit from packed accountGasLimits
  BigInt get callGasLimit {
    if (accountGasLimits.length != 32) return BigInt.zero;
    return bytesToInt(accountGasLimits.sublist(16, 32));
  }

  /// Get max priority fee per gas from packed gasFees
  BigInt get maxPriorityFeePerGas {
    if (gasFees.length != 32) return BigInt.zero;
    return bytesToInt(gasFees.sublist(0, 16));
  }

  /// Get max fee per gas from packed gasFees
  BigInt get maxFeePerGas {
    if (gasFees.length != 32) return BigInt.zero;
    return bytesToInt(gasFees.sublist(16, 32));
  }

  /// Calculate the UserOperation hash for signing
  ///
  /// The hash is computed as:
  /// keccak256(abi.encode(
  ///   keccak256(pack(userOp)),
  ///   entryPoint,
  ///   chainId
  /// ))
  ///
  /// For v0.8, the packing includes additional EIP-7702 auth data if present.
  Uint8List getUserOpHash(
    String entryPoint,
    BigInt chainId, {
    EntryPointVersion version = EntryPointVersion.v08,
  }) {
    final packedHash = keccak256(_packUserOp(version: version));
    final entryPointBytes = hexToBytes(
      entryPoint.replaceFirst('0x', '').padLeft(64, '0'),
    );
    final chainIdBytes = _bigIntToBytes32(chainId);

    final combined = Uint8List(32 + 32 + 32);
    combined.setAll(0, packedHash);
    combined.setAll(32, entryPointBytes);
    combined.setAll(64, chainIdBytes);

    return keccak256(combined);
  }

  /// Calculate hash using default version (v0.8)
  Uint8List getUserOpHashV08(String entryPoint, BigInt chainId) {
    return getUserOpHash(entryPoint, chainId, version: EntryPointVersion.v08);
  }

  /// Calculate hash using legacy version (v0.7)
  Uint8List getUserOpHashV07(String entryPoint, BigInt chainId) {
    return getUserOpHash(entryPoint, chainId, version: EntryPointVersion.v07);
  }

  /// Pack UserOperation fields for hashing
  ///
  /// For v0.7:
  /// sender(32) + nonce(32) + initCodeHash(32) + callDataHash(32) +
  /// accountGasLimits(32) + preVerificationGas(32) + gasFees(32) +
  /// paymasterHash(32) = 256 bytes
  ///
  /// For v0.8 with EIP-7702:
  /// Same as v0.7 but includes eip7702AuthHash if present = 288 bytes
  Uint8List _packUserOp({EntryPointVersion version = EntryPointVersion.v08}) {
    // Calculate total size
    final initCodeHash = keccak256(initCode ?? Uint8List(0));
    final callDataHash = keccak256(callData);
    final paymasterHash = keccak256(paymasterAndData ?? Uint8List(0));

    // v0.8 with EIP-7702 adds an extra field
    final hasEip7702 = version == EntryPointVersion.v08 && eip7702Auth != null;
    final eip7702AuthHash = hasEip7702 ? keccak256(eip7702Auth!) : null;

    // Total size: base 256 bytes + optional 32 bytes for EIP-7702
    final totalSize = hasEip7702 ? 288 : 256;
    final packed = Uint8List(totalSize);
    var offset = 0;

    // Sender (padded to 32 bytes)
    final senderBytes = hexToBytes(
      sender.replaceFirst('0x', '').padLeft(64, '0'),
    );
    packed.setAll(offset, senderBytes);
    offset += 32;

    // Nonce
    packed.setAll(offset, _bigIntToBytes32(nonce));
    offset += 32;

    // InitCode hash
    packed.setAll(offset, initCodeHash);
    offset += 32;

    // CallData hash
    packed.setAll(offset, callDataHash);
    offset += 32;

    // AccountGasLimits
    packed.setAll(offset, accountGasLimits);
    offset += 32;

    // PreVerificationGas
    packed.setAll(offset, _bigIntToBytes32(preVerificationGas));
    offset += 32;

    // GasFees
    packed.setAll(offset, gasFees);
    offset += 32;

    // Paymaster hash
    packed.setAll(offset, paymasterHash);
    offset += 32;

    // EIP-7702 auth hash (v0.8 only)
    if (hasEip7702) {
      packed.setAll(offset, eip7702AuthHash!);
    }

    return packed;
  }

  /// Convert to JSON format for RPC calls
  Map<String, String> toJson({
    EntryPointVersion version = EntryPointVersion.v08,
  }) {
    final json = {
      'sender': sender,
      'nonce': '0x${nonce.toRadixString(16)}',
      'initCode': '0x${bytesToHex(initCode ?? Uint8List(0))}',
      'callData': '0x${bytesToHex(callData)}',
      'accountGasLimits': '0x${bytesToHex(accountGasLimits)}',
      'preVerificationGas': '0x${preVerificationGas.toRadixString(16)}',
      'gasFees': '0x${bytesToHex(gasFees)}',
      'paymasterAndData': '0x${bytesToHex(paymasterAndData ?? Uint8List(0))}',
      'signature': '0x${bytesToHex(signature ?? Uint8List(0))}',
    };

    // Include EIP-7702 auth data for v0.8 if present
    if (version == EntryPointVersion.v08 && eip7702Auth != null) {
      json['eip7702Auth'] = '0x${bytesToHex(eip7702Auth!)}';
    }

    return json;
  }

  /// Create UserOperation from JSON
  factory UserOperation.fromJson(Map<String, dynamic> json) {
    return UserOperation(
      sender: json['sender'] as String,
      nonce: BigInt.parse(json['nonce'] as String),
      initCode: _parseHexBytes(json['initCode'] as String?),
      callData: _parseHexBytes(json['callData'] as String) ?? Uint8List(0),
      accountGasLimits:
          _parseHexBytes(json['accountGasLimits'] as String) ?? Uint8List(32),
      preVerificationGas: BigInt.parse(json['preVerificationGas'] as String),
      gasFees: _parseHexBytes(json['gasFees'] as String) ?? Uint8List(32),
      paymasterAndData: _parseHexBytes(json['paymasterAndData'] as String?),
      signature: _parseHexBytes(json['signature'] as String?),
      eip7702Auth: _parseHexBytes(json['eip7702Auth'] as String?),
    );
  }

  /// Copy with updated fields
  UserOperation copyWith({
    String? sender,
    BigInt? nonce,
    Uint8List? initCode,
    Uint8List? callData,
    Uint8List? accountGasLimits,
    BigInt? preVerificationGas,
    Uint8List? gasFees,
    Uint8List? paymasterAndData,
    Uint8List? signature,
    Uint8List? eip7702Auth,
  }) {
    return UserOperation(
      sender: sender ?? this.sender,
      nonce: nonce ?? this.nonce,
      initCode: initCode ?? this.initCode,
      callData: callData ?? this.callData,
      accountGasLimits: accountGasLimits ?? this.accountGasLimits,
      preVerificationGas: preVerificationGas ?? this.preVerificationGas,
      gasFees: gasFees ?? this.gasFees,
      paymasterAndData: paymasterAndData ?? this.paymasterAndData,
      signature: signature ?? this.signature,
      eip7702Auth: eip7702Auth ?? this.eip7702Auth,
    );
  }

  /// Check if this UserOperation uses EIP-7702 authorization
  bool get hasEIP7702Auth => eip7702Auth != null && eip7702Auth!.isNotEmpty;

  /// Calculate estimated total gas cost
  BigInt get estimatedGasCost {
    return (verificationGasLimit + callGasLimit + preVerificationGas) *
        maxFeePerGas;
  }

  @override
  String toString() {
    return 'UserOperation(sender: $sender, nonce: $nonce)';
  }

  // Helper methods

  static Uint8List? _parseHexBytes(String? hex) {
    if (hex == null || hex == '0x' || hex.isEmpty) return null;
    return hexToBytes(hex.replaceFirst('0x', ''));
  }

  Uint8List _bigIntToBytes32(BigInt value) {
    final bytes = Uint8List(32);
    final valueBytes = intToBytes(value);
    final start = 32 - valueBytes.length;
    if (start >= 0) {
      bytes.setAll(start, valueBytes);
    }
    return bytes;
  }
}

// Shared helper: big-endian encode a BigInt into exactly 16 bytes.
Uint8List _bigIntToBytes16(BigInt value) {
  final bytes = Uint8List(16);
  final valueBytes = intToBytes(value);
  final start = 16 - valueBytes.length;
  if (start >= 0 && valueBytes.length <= 16) {
    bytes.setAll(start, valueBytes);
  }
  return bytes;
}

/// Helper class for building packed gas limits
class PackedGasLimits {
  /// Pack verification and call gas limits into 32 bytes
  static Uint8List pack(BigInt verificationGasLimit, BigInt callGasLimit) {
    final packed = Uint8List(32);
    packed.setAll(0, _bigIntToBytes16(verificationGasLimit));
    packed.setAll(16, _bigIntToBytes16(callGasLimit));
    return packed;
  }
}

/// Helper class for building packed gas fees
class PackedGasFees {
  /// Pack maxPriorityFeePerGas and maxFeePerGas into 32 bytes
  static Uint8List pack(BigInt maxPriorityFeePerGas, BigInt maxFeePerGas) {
    final packed = Uint8List(32);
    packed.setAll(0, _bigIntToBytes16(maxPriorityFeePerGas));
    packed.setAll(16, _bigIntToBytes16(maxFeePerGas));
    return packed;
  }
}
