// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:typed_data';
import 'package:web3dart/web3dart.dart';

import '../../core/aa_config.dart';
import '../../models/smart_account.dart';
import '../../builder/calldata_builder.dart';

/// EIP-7702 Simple7702Account implementation
///
/// This is a hybrid EOA/smart account that uses EIP-7702 to temporarily
/// delegate EOA execution to a smart account implementation.
///
/// Key benefits:
/// - No deployment cost (uses EOA address directly)
/// - Can switch between EOA and smart account modes
/// - Maintains existing EOA balance and history
/// - Supports all smart account features when delegated
///
/// EIP-7702 allows an EOA to temporarily authorize a contract to execute
/// on its behalf through a special authorization signature.
class Simple7702AccountHelper {
  /// The implementation contract address for delegation
  final String implementationAddress;

  /// EntryPoint v0.8 address (required for EIP-7702)
  final String entryPointAddress;

  /// Chain ID for authorization
  final int chainId;

  Simple7702AccountHelper({
    required this.implementationAddress,
    required this.entryPointAddress,
    required this.chainId,
  });

  /// Create from chain configuration
  factory Simple7702AccountHelper.fromChain(String chainSymbol) {
    final config = AAConfig.getChainConfig(
      chainSymbol,
      version: EntryPointVersion.v08,
    );
    if (config == null) {
      throw ArgumentError('Unsupported chain for EIP-7702: $chainSymbol');
    }
    if (!config.supportsEIP7702) {
      throw ArgumentError('Chain $chainSymbol does not support EIP-7702');
    }
    return Simple7702AccountHelper(
      implementationAddress: config.simple7702AccountFactory ?? AAConfig.simple7702AccountFactory,
      entryPointAddress: config.entryPoint,
      chainId: config.chainId,
    );
  }

  /// Get the account address (same as EOA address)
  ///
  /// Unlike traditional smart accounts, EIP-7702 accounts use the
  /// EOA address directly - no counterfactual address calculation needed.
  String getAccountAddress(String eoaAddress) {
    return eoaAddress;
  }

  /// Build EIP-7702 authorization data
  ///
  /// The authorization allows the EOA to delegate to the implementation
  /// contract for the duration of the transaction.
  ///
  /// Authorization structure:
  /// - chainId: Target chain
  /// - address: Implementation contract address
  /// - nonce: EOA nonce to prevent replay
  Uint8List buildAuthorization({
    required BigInt nonce,
  }) {
    // EIP-7702 authorization encoding:
    // rlp([chainId, address, nonce])
    final chainIdBytes = _encodeRlpBigInt(BigInt.from(chainId));
    final addressBytes = _encodeRlpAddress(implementationAddress);
    final nonceBytes = _encodeRlpBigInt(nonce);

    // Combine into RLP list
    final combined = _encodeRlpList([chainIdBytes, addressBytes, nonceBytes]);
    return combined;
  }

  /// Create the authorization hash for signing
  ///
  /// The EOA must sign this hash to authorize delegation.
  Uint8List getAuthorizationHash({
    required BigInt nonce,
  }) {
    // EIP-7702 magic prefix: 0x05
    final authData = buildAuthorization(nonce: nonce);

    // Hash: keccak256(0x05 || authData)
    final toHash = Uint8List(1 + authData.length);
    toHash[0] = 0x05; // EIP-7702 magic byte
    toHash.setAll(1, authData);

    return keccak256(toHash);
  }

  /// Build signed authorization for UserOperation
  ///
  /// This combines the authorization data with the EOA signature.
  Uint8List buildSignedAuthorization({
    required BigInt nonce,
    required Uint8List signature, // v, r, s
  }) {
    final authData = buildAuthorization(nonce: nonce);

    // Combine auth data + signature
    final result = Uint8List(authData.length + signature.length);
    result.setAll(0, authData);
    result.setAll(authData.length, signature);

    return result;
  }

  /// Build execute call data (same interface as SimpleAccount)
  Uint8List buildExecute({
    required String target,
    required BigInt value,
    required Uint8List data,
  }) {
    return CalldataBuilder.buildExecute(
      target: target,
      value: value,
      data: data,
    );
  }

  /// Build executeBatch call data
  Uint8List buildExecuteBatch(List<ExecuteCall> calls) {
    return CalldataBuilder.buildExecuteBatch(calls);
  }

  /// Create a SmartAccount model for EIP-7702 account
  SmartAccount createAccount({
    required String eoaAddress,
    String? label,
  }) {
    return SmartAccount(
      address: eoaAddress,
      type: SmartAccountType.simple7702Account,
      ownerAddress: eoaAddress, // Owner is the EOA itself
      state: SmartAccountState.deployed, // Always "deployed" as it uses EOA
      chainId: chainId,
      salt: BigInt.zero, // No salt needed for EIP-7702
      factoryAddress: implementationAddress,
      createdAt: DateTime.now(),
      label: label ?? 'EIP-7702 Account',
    );
  }

  // RLP encoding helpers

  Uint8List _encodeRlpBigInt(BigInt value) {
    if (value == BigInt.zero) {
      return Uint8List.fromList([0x80]); // Empty string in RLP
    }
    return _encodeRlpBytes(intToBytes(value));
  }

  Uint8List _encodeRlpAddress(String address) {
    return _encodeRlpBytes(hexToBytes(address.replaceFirst('0x', '')));
  }

  Uint8List _encodeRlpBytes(Uint8List bytes) {
    if (bytes.isEmpty) {
      return Uint8List.fromList([0x80]);
    }

    if (bytes.length == 1 && bytes[0] < 0x80) {
      return bytes;
    }

    if (bytes.length <= 55) {
      final result = Uint8List(1 + bytes.length);
      result[0] = 0x80 + bytes.length;
      result.setAll(1, bytes);
      return result;
    }

    final lengthBytes = _encodeLength(bytes.length);
    final result = Uint8List(1 + lengthBytes.length + bytes.length);
    result[0] = 0xb7 + lengthBytes.length;
    result.setAll(1, lengthBytes);
    result.setAll(1 + lengthBytes.length, bytes);
    return result;
  }

  Uint8List _encodeRlpList(List<Uint8List> items) {
    var totalLength = 0;
    for (final item in items) {
      totalLength += item.length;
    }

    // Build header: short list (1 byte) or long list (1 + lengthBytes)
    Uint8List header;
    if (totalLength <= 55) {
      header = Uint8List.fromList([0xc0 + totalLength]);
    } else {
      final lengthBytes = _encodeLength(totalLength);
      header = Uint8List(1 + lengthBytes.length);
      header[0] = 0xf7 + lengthBytes.length;
      header.setAll(1, lengthBytes);
    }

    // Concatenate header + all items
    final result = Uint8List(header.length + totalLength);
    result.setAll(0, header);
    var offset = header.length;
    for (final item in items) {
      result.setAll(offset, item);
      offset += item.length;
    }
    return result;
  }

  Uint8List _encodeLength(int length) {
    if (length < 256) {
      return Uint8List.fromList([length]);
    } else if (length < 65536) {
      return Uint8List.fromList([length >> 8, length & 0xff]);
    } else if (length < 16777216) {
      return Uint8List.fromList([length >> 16, (length >> 8) & 0xff, length & 0xff]);
    } else {
      return Uint8List.fromList([
        length >> 24,
        (length >> 16) & 0xff,
        (length >> 8) & 0xff,
        length & 0xff,
      ]);
    }
  }
}

/// EIP-7702 authorization data structure
class EIP7702Authorization {
  /// Target chain ID
  final int chainId;

  /// Implementation contract address to delegate to
  final String address;

  /// EOA nonce at time of authorization
  final BigInt nonce;

  /// v component of signature
  final int v;

  /// r component of signature
  final Uint8List r;

  /// s component of signature
  final Uint8List s;

  const EIP7702Authorization({
    required this.chainId,
    required this.address,
    required this.nonce,
    required this.v,
    required this.r,
    required this.s,
  });

  /// Check if authorization is valid
  ///
  /// A valid authorization has:
  /// - 32-byte r and s components
  /// - v in {0, 1} (y-parity per EIP-7702) or {27, 28} (Ethereum legacy style)
  bool get isValid {
    return r.length == 32 && s.length == 32 && (v == 27 || v == 28 || v == 0 || v == 1);
  }

  /// Whether this authorization is a revocation.
  ///
  /// Per EIP-7702, setting [address] to the zero address cancels any active
  /// delegation for the authorizing EOA.
  bool get isRevocation =>
      address == '0x0000000000000000000000000000000000000000';

  /// Whether this authorization is chain-agnostic (chainId == 0).
  ///
  /// ⚠️ Security warning: chain-agnostic authorizations can be replayed on
  /// *any* EVM chain. Prefer a specific chainId for production use.
  bool get isAnyChain => chainId == 0;

  /// Encode to bytes for UserOperation
  Uint8List encode() {
    // Encoding: chainId(32) + address(20) + nonce(32) + v(1) + r(32) + s(32)
    final result = Uint8List(149);
    var offset = 0;

    // Chain ID (32 bytes, big-endian)
    final chainIdBytes = _bigIntToBytes32(BigInt.from(chainId));
    result.setAll(offset, chainIdBytes);
    offset += 32;

    // Address (20 bytes)
    final addressBytes = hexToBytes(address.replaceFirst('0x', ''));
    result.setAll(offset, addressBytes);
    offset += 20;

    // Nonce (32 bytes, big-endian)
    final nonceBytes = _bigIntToBytes32(nonce);
    result.setAll(offset, nonceBytes);
    offset += 32;

    // v (1 byte)
    result[offset] = v;
    offset += 1;

    // r (32 bytes)
    result.setAll(offset, r);
    offset += 32;

    // s (32 bytes)
    result.setAll(offset, s);

    return result;
  }

  /// Decode from bytes
  factory EIP7702Authorization.decode(Uint8List bytes) {
    if (bytes.length < 149) {
      throw ArgumentError('Invalid EIP-7702 authorization length');
    }

    var offset = 0;

    // Chain ID
    final chainIdBytes = bytes.sublist(offset, offset + 32);
    final chainId = bytesToInt(chainIdBytes).toInt();
    offset += 32;

    // Address
    final addressBytes = bytes.sublist(offset, offset + 20);
    final address = '0x${bytesToHex(addressBytes)}';
    offset += 20;

    // Nonce
    final nonceBytes = bytes.sublist(offset, offset + 32);
    final nonce = bytesToInt(nonceBytes);
    offset += 32;

    // v
    final v = bytes[offset];
    offset += 1;

    // r
    final r = Uint8List.fromList(bytes.sublist(offset, offset + 32));
    offset += 32;

    // s
    final s = Uint8List.fromList(bytes.sublist(offset, offset + 32));

    return EIP7702Authorization(
      chainId: chainId,
      address: address,
      nonce: nonce,
      v: v,
      r: r,
      s: s,
    );
  }

  static Uint8List _bigIntToBytes32(BigInt value) {
    final bytes = Uint8List(32);
    final valueBytes = intToBytes(value);
    if (valueBytes.isNotEmpty && valueBytes.length <= 32) {
      bytes.setAll(32 - valueBytes.length, valueBytes);
    }
    return bytes;
  }
}

/// Simple7702Account function selectors (same as SimpleAccount)
class Simple7702AccountSelectors {
  Simple7702AccountSelectors._();

  /// execute(address,uint256,bytes)
  static const String execute = '0xb61d27f6';

  /// executeBatch(address[],uint256[],bytes[])
  static const String executeBatch = '0x47e1da2a';

  /// owner() - returns the EOA address
  static const String owner = '0x8da5cb5b';

  /// entryPoint()
  static const String entryPoint = '0xb0d691fe';
}

/// Gas constants for EIP-7702 operations
class Simple7702GasConstants {
  Simple7702GasConstants._();

  /// Gas for EIP-7702 authorization verification
  static const int authorizationGas = 25000;

  /// Gas for signature validation
  static const int signatureValidation = 50000;

  /// Gas for execute call overhead
  static const int executeOverhead = 30000;

  /// Note: No deployment gas needed for EIP-7702!
  /// The EOA acts directly as the smart account.

  /// Estimate total gas for single execute
  static BigInt estimateExecuteGas(int callDataLength) {
    return BigInt.from(
      authorizationGas + signatureValidation + executeOverhead + (callDataLength ~/ 16) * 68,
    );
  }

  /// Estimate gas for batch execute
  static BigInt estimateBatchGas(List<ExecuteCall> calls) {
    var total = authorizationGas + signatureValidation + executeOverhead;
    for (final call in calls) {
      total += 25000 + (call.data.length ~/ 16) * 68;
    }
    return BigInt.from(total);
  }
}
