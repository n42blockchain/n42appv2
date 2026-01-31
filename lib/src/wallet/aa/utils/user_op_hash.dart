// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:typed_data';
import 'package:web3dart/crypto.dart';

import '../core/aa_config.dart';
import '../models/user_operation.dart';

/// Utility class for UserOperation hash calculations
///
/// Implements the ERC-4337 UserOperation hash algorithm for both v0.7 and v0.8.
class UserOpHasher {
  UserOpHasher._();

  /// Calculate the UserOperation hash
  ///
  /// The hash is computed as:
  /// keccak256(abi.encode(
  ///   keccak256(packUserOp(userOp)),
  ///   entryPoint,
  ///   chainId
  /// ))
  ///
  /// Supports both v0.7 and v0.8 EntryPoint versions.
  static Uint8List hash({
    required UserOperation userOp,
    required String entryPoint,
    required BigInt chainId,
    EntryPointVersion version = EntryPointVersion.v08,
  }) {
    // Get the packed UserOp hash
    final packedHash = _hashPackedUserOp(userOp, version: version);

    // Encode: packedHash + entryPoint + chainId
    final entryPointBytes = _addressToBytes32(entryPoint);
    final chainIdBytes = _bigIntToBytes32(chainId);

    // Combine all parts
    final combined = Uint8List(96);
    combined.setAll(0, packedHash);
    combined.setAll(32, entryPointBytes);
    combined.setAll(64, chainIdBytes);

    return keccak256(combined);
  }

  /// Get hash as hex string
  static String hashHex({
    required UserOperation userOp,
    required String entryPoint,
    required BigInt chainId,
    EntryPointVersion version = EntryPointVersion.v08,
  }) {
    final hashBytes = hash(
      userOp: userOp,
      entryPoint: entryPoint,
      chainId: chainId,
      version: version,
    );
    return '0x${bytesToHex(hashBytes)}';
  }

  /// Calculate hash using v0.8 EntryPoint
  static Uint8List hashV08({
    required UserOperation userOp,
    required BigInt chainId,
  }) {
    return hash(
      userOp: userOp,
      entryPoint: AAConfig.entryPointV08,
      chainId: chainId,
      version: EntryPointVersion.v08,
    );
  }

  /// Calculate hash using v0.7 EntryPoint
  static Uint8List hashV07({
    required UserOperation userOp,
    required BigInt chainId,
  }) {
    return hash(
      userOp: userOp,
      entryPoint: AAConfig.entryPointV07,
      chainId: chainId,
      version: EntryPointVersion.v07,
    );
  }

  /// Hash the packed UserOperation (intermediate step)
  static Uint8List _hashPackedUserOp(
    UserOperation userOp, {
    EntryPointVersion version = EntryPointVersion.v08,
  }) {
    final packed = _packUserOp(userOp, version: version);
    return keccak256(packed);
  }

  /// Pack UserOperation for hashing
  ///
  /// For v0.7, the packing is:
  /// keccak256(abi.encode(
  ///   sender,
  ///   nonce,
  ///   keccak256(initCode),
  ///   keccak256(callData),
  ///   accountGasLimits,
  ///   preVerificationGas,
  ///   gasFees,
  ///   keccak256(paymasterAndData)
  /// ))
  ///
  /// For v0.8 with EIP-7702:
  /// Same as v0.7 but includes keccak256(eip7702Auth) if present
  static Uint8List _packUserOp(
    UserOperation userOp, {
    EntryPointVersion version = EntryPointVersion.v08,
  }) {
    // Hash dynamic fields
    final initCodeHash = keccak256(userOp.initCode ?? Uint8List(0));
    final callDataHash = keccak256(userOp.callData);
    final paymasterHash = keccak256(userOp.paymasterAndData ?? Uint8List(0));

    // v0.8 with EIP-7702 adds an extra field
    final hasEip7702 = version == EntryPointVersion.v08 &&
        userOp.eip7702Auth != null &&
        userOp.eip7702Auth!.isNotEmpty;
    final eip7702AuthHash = hasEip7702 ? keccak256(userOp.eip7702Auth!) : null;

    // Build packed data (base 256 bytes + optional 32 bytes for EIP-7702)
    final totalSize = hasEip7702 ? 288 : 256;
    final packed = Uint8List(totalSize);
    var offset = 0;

    // sender (20 bytes, left-padded to 32)
    packed.setAll(offset, _addressToBytes32(userOp.sender));
    offset += 32;

    // nonce
    packed.setAll(offset, _bigIntToBytes32(userOp.nonce));
    offset += 32;

    // initCode hash
    packed.setAll(offset, initCodeHash);
    offset += 32;

    // callData hash
    packed.setAll(offset, callDataHash);
    offset += 32;

    // accountGasLimits (already 32 bytes)
    packed.setAll(offset, userOp.accountGasLimits);
    offset += 32;

    // preVerificationGas
    packed.setAll(offset, _bigIntToBytes32(userOp.preVerificationGas));
    offset += 32;

    // gasFees (already 32 bytes)
    packed.setAll(offset, userOp.gasFees);
    offset += 32;

    // paymasterAndData hash
    packed.setAll(offset, paymasterHash);
    offset += 32;

    // EIP-7702 auth hash (v0.8 only)
    if (hasEip7702 && eip7702AuthHash != null) {
      packed.setAll(offset, eip7702AuthHash);
    }

    return packed;
  }

  /// Convert address to 32-byte representation
  static Uint8List _addressToBytes32(String address) {
    final bytes = Uint8List(32);
    final addrBytes = hexToBytes(address.replaceFirst('0x', '').padLeft(40, '0'));
    bytes.setAll(12, addrBytes); // Left-pad with 12 zeros
    return bytes;
  }

  /// Convert BigInt to 32-byte representation
  static Uint8List _bigIntToBytes32(BigInt value) {
    final bytes = Uint8List(32);
    final valueBytes = intToBytes(value);
    if (valueBytes.isNotEmpty && valueBytes.length <= 32) {
      bytes.setAll(32 - valueBytes.length, valueBytes);
    }
    return bytes;
  }

  /// Verify that a hash matches a UserOperation
  static bool verify({
    required String hash,
    required UserOperation userOp,
    required String entryPoint,
    required BigInt chainId,
    EntryPointVersion version = EntryPointVersion.v08,
  }) {
    final computedHash = hashHex(
      userOp: userOp,
      entryPoint: entryPoint,
      chainId: chainId,
      version: version,
    );
    return hash.toLowerCase() == computedHash.toLowerCase();
  }
}

/// Nonce utilities for ERC-4337
class NonceUtils {
  NonceUtils._();

  /// Pack a nonce with a key
  ///
  /// The nonce is packed as: key (192 bits) + sequence (64 bits)
  static BigInt packNonce(BigInt key, BigInt sequence) {
    if (key >= BigInt.two.pow(192)) {
      throw ArgumentError('Key must be less than 2^192');
    }
    if (sequence >= BigInt.two.pow(64)) {
      throw ArgumentError('Sequence must be less than 2^64');
    }
    return (key << 64) + sequence;
  }

  /// Unpack a nonce into key and sequence
  static ({BigInt key, BigInt sequence}) unpackNonce(BigInt packedNonce) {
    final sequence = packedNonce & ((BigInt.one << 64) - BigInt.one);
    final key = packedNonce >> 64;
    return (key: key, sequence: sequence);
  }

  /// Get the default nonce key
  static BigInt get defaultKey => BigInt.zero;

  /// Create a nonce for a specific purpose
  static BigInt createNonce({
    required BigInt key,
    required BigInt sequence,
  }) {
    return packNonce(key, sequence);
  }

  /// Increment the sequence part of a nonce
  static BigInt incrementSequence(BigInt currentNonce) {
    final unpacked = unpackNonce(currentNonce);
    return packNonce(unpacked.key, unpacked.sequence + BigInt.one);
  }
}

/// Helper for EIP-191 message signing
class MessageHasher {
  MessageHasher._();

  /// Hash a message for personal_sign (EIP-191)
  ///
  /// Adds the Ethereum signed message prefix.
  static Uint8List hashPersonalMessage(Uint8List message) {
    final prefix = '\x19Ethereum Signed Message:\n${message.length}';
    final prefixBytes = Uint8List.fromList(prefix.codeUnits);

    final combined = Uint8List(prefixBytes.length + message.length);
    combined.setAll(0, prefixBytes);
    combined.setAll(prefixBytes.length, message);

    return keccak256(combined);
  }

  /// Hash a message given as hex string
  static String hashPersonalMessageHex(String messageHex) {
    final message = hexToBytes(messageHex.replaceFirst('0x', ''));
    final hash = hashPersonalMessage(message);
    return '0x${bytesToHex(hash)}';
  }

  /// Create the message to sign for a UserOperation
  static Uint8List createSignMessage({
    required UserOperation userOp,
    required String entryPoint,
    required BigInt chainId,
    EntryPointVersion version = EntryPointVersion.v08,
  }) {
    return UserOpHasher.hash(
      userOp: userOp,
      entryPoint: entryPoint,
      chainId: chainId,
      version: version,
    );
  }
}
