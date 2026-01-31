// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:typed_data';
import 'package:web3dart/crypto.dart';

import '../core/aa_config.dart';
import '../models/user_operation.dart';
import '../account/account_types/simple7702_account.dart';

/// Handler for EIP-7702 operations
///
/// EIP-7702 allows EOAs to temporarily delegate execution to a contract,
/// enabling smart account features without deployment.
class EIP7702Handler {
  EIP7702Handler._();

  /// Magic byte prefix for EIP-7702 authorization
  static const int magicByte = 0x05;

  /// Check if a UserOperation uses EIP-7702
  static bool isEIP7702UserOp(UserOperation userOp) {
    return userOp.hasEIP7702Auth;
  }

  /// Create authorization hash for signing
  ///
  /// The hash follows EIP-7702 specification:
  /// keccak256(0x05 || rlp([chainId, address, nonce]))
  static Uint8List createAuthorizationHash({
    required int chainId,
    required String implementationAddress,
    required BigInt nonce,
  }) {
    // Build RLP encoded authorization
    final chainIdBytes = _rlpEncodeBigInt(BigInt.from(chainId));
    final addressBytes = _rlpEncodeAddress(implementationAddress);
    final nonceBytes = _rlpEncodeBigInt(nonce);

    final rlpList = _rlpEncodeList([chainIdBytes, addressBytes, nonceBytes]);

    // Prepend magic byte and hash
    final toHash = Uint8List(1 + rlpList.length);
    toHash[0] = magicByte;
    toHash.setAll(1, rlpList);

    return keccak256(toHash);
  }

  /// Build signed EIP-7702 authorization for UserOperation
  static Uint8List buildSignedAuthorization(EIP7702Authorization auth) {
    return auth.encode();
  }

  /// Parse EIP-7702 authorization from UserOperation
  static EIP7702Authorization? parseAuthorization(UserOperation userOp) {
    if (!userOp.hasEIP7702Auth) return null;
    try {
      return EIP7702Authorization.decode(userOp.eip7702Auth!);
    } catch (e) {
      return null;
    }
  }

  /// Verify EIP-7702 authorization signature
  static bool verifyAuthorization({
    required EIP7702Authorization auth,
    required String expectedSigner,
  }) {
    // Recreate the hash that was signed
    final hash = createAuthorizationHash(
      chainId: auth.chainId,
      implementationAddress: auth.address,
      nonce: auth.nonce,
    );

    // Recover the signer from signature
    final recovered = _ecRecover(hash, auth.v, auth.r, auth.s);

    return recovered.toLowerCase() == expectedSigner.toLowerCase();
  }

  /// Create a UserOperation with EIP-7702 authorization
  static UserOperation createEIP7702UserOp({
    required String eoaAddress,
    required BigInt nonce,
    required Uint8List callData,
    required EIP7702Authorization authorization,
    required Uint8List accountGasLimits,
    required BigInt preVerificationGas,
    required Uint8List gasFees,
    Uint8List? paymasterAndData,
  }) {
    return UserOperation(
      sender: eoaAddress,
      nonce: nonce,
      initCode: null, // No init code for EIP-7702
      callData: callData,
      accountGasLimits: accountGasLimits,
      preVerificationGas: preVerificationGas,
      gasFees: gasFees,
      paymasterAndData: paymasterAndData,
      eip7702Auth: authorization.encode(),
    );
  }

  /// Estimate gas overhead for EIP-7702 authorization
  static BigInt estimateAuthorizationGas() {
    return BigInt.from(Simple7702GasConstants.authorizationGas);
  }

  /// Check if chain supports EIP-7702
  static bool isChainSupported(String chainSymbol) {
    final config = AAConfig.getChainConfig(
      chainSymbol,
      version: EntryPointVersion.v08,
    );
    return config?.supportsEIP7702 ?? false;
  }

  /// Get implementation address for EIP-7702 accounts
  static String getImplementationAddress(String chainSymbol) {
    final config = AAConfig.getChainConfig(
      chainSymbol,
      version: EntryPointVersion.v08,
    );
    return config?.simple7702AccountFactory ?? AAConfig.simple7702AccountFactory;
  }

  // RLP encoding helpers

  static Uint8List _rlpEncodeBigInt(BigInt value) {
    if (value == BigInt.zero) {
      return Uint8List.fromList([0x80]);
    }

    final bytes = intToBytes(value);
    if (bytes.length == 1 && bytes[0] < 0x80) {
      return bytes;
    }

    return _rlpEncodeBytes(bytes);
  }

  static Uint8List _rlpEncodeAddress(String address) {
    final addrBytes = hexToBytes(address.replaceFirst('0x', ''));
    return _rlpEncodeBytes(addrBytes);
  }

  static Uint8List _rlpEncodeBytes(Uint8List bytes) {
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

  static Uint8List _rlpEncodeList(List<Uint8List> items) {
    var totalLength = 0;
    for (final item in items) {
      totalLength += item.length;
    }

    Uint8List result;
    if (totalLength <= 55) {
      result = Uint8List(1 + totalLength);
      result[0] = 0xc0 + totalLength;
      var offset = 1;
      for (final item in items) {
        result.setAll(offset, item);
        offset += item.length;
      }
    } else {
      final lengthBytes = _encodeLength(totalLength);
      result = Uint8List(1 + lengthBytes.length + totalLength);
      result[0] = 0xf7 + lengthBytes.length;
      result.setAll(1, lengthBytes);
      var offset = 1 + lengthBytes.length;
      for (final item in items) {
        result.setAll(offset, item);
        offset += item.length;
      }
    }

    return result;
  }

  static Uint8List _encodeLength(int length) {
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

  /// Recover signer address from signature
  ///
  /// Uses ecrecover to derive the signer's public key from the signature,
  /// then converts it to an Ethereum address.
  static String _ecRecover(Uint8List hash, int v, Uint8List r, Uint8List s) {
    // Adjust v for EIP-155
    final adjustedV = v < 27 ? v + 27 : v;

    try {
      // Use web3dart's ecRecover to recover public key
      final msgSig = MsgSignature(
        bytesToInt(r),
        bytesToInt(s),
        adjustedV,
      );

      // ecRecover returns Uint8List (public key bytes)
      final Uint8List pubKeyBytes = ecRecover(hash, msgSig);

      // Ensure we have the right length for address calculation
      // Public key should be 64 bytes (uncompressed, without 0x04 prefix)
      final paddedBytes = Uint8List(64);
      if (pubKeyBytes.length <= 64) {
        final offset = 64 - pubKeyBytes.length;
        paddedBytes.setAll(offset, pubKeyBytes);
      } else {
        // Take last 64 bytes if longer
        paddedBytes.setAll(0, pubKeyBytes.sublist(pubKeyBytes.length - 64));
      }

      // Address is last 20 bytes of keccak256(publicKey)
      final addressHash = keccak256(paddedBytes);
      return '0x${bytesToHex(addressHash.sublist(12))}';
    } catch (e) {
      // Return empty string if recovery fails
      return '';
    }
  }
}

/// Version adapter for handling both v0.7 and v0.8 UserOperations
class EntryPointVersionAdapter {
  EntryPointVersionAdapter._();

  /// Get appropriate EntryPoint address for version
  static String getEntryPoint(EntryPointVersion version) {
    return version == EntryPointVersion.v08
        ? AAConfig.entryPointV08
        : AAConfig.entryPointV07;
  }

  /// Check if operation requires v0.8
  static bool requiresV08(UserOperation userOp) {
    return userOp.hasEIP7702Auth;
  }

  /// Upgrade UserOperation from v0.7 to v0.8 format
  ///
  /// v0.8 is backwards compatible with v0.7, so this mainly involves
  /// ensuring the operation is sent to the correct EntryPoint.
  static UserOperation upgradeToV08(UserOperation userOp) {
    // v0.8 format is the same as v0.7 for non-EIP-7702 operations
    return userOp;
  }

  /// Add EIP-7702 authorization to an existing UserOperation
  static UserOperation addEIP7702Auth({
    required UserOperation userOp,
    required EIP7702Authorization authorization,
  }) {
    return userOp.copyWith(
      eip7702Auth: authorization.encode(),
    );
  }

  /// Get gas penalty threshold for v0.8
  ///
  /// v0.8 does not penalize unused gas under 40k,
  /// unlike v0.7 which has a 10% penalty on all unused gas.
  static BigInt getGasPenaltyThreshold(EntryPointVersion version) {
    return version == EntryPointVersion.v08
        ? BigInt.from(40000) // 40k threshold in v0.8
        : BigInt.zero; // No threshold in v0.7
  }

  /// Estimate gas savings when using v0.8 vs v0.7
  ///
  /// v0.8 is generally more gas efficient due to:
  /// 1. Reduced unused gas penalty
  /// 2. Optimized validation flow
  /// 3. EIP-7702 eliminates deployment costs
  static BigInt estimateGasSavings({
    required UserOperation userOp,
    required bool isFirstTransaction,
  }) {
    var savings = BigInt.zero;

    // EIP-7702 saves deployment gas
    if (userOp.hasEIP7702Auth && isFirstTransaction) {
      savings += BigInt.from(Simple7702GasConstants.authorizationGas);
      // Minus the deployment gas that would have been needed
      savings -= BigInt.from(200000); // Typical deployment cost
    }

    // v0.8 penalty reduction
    final unusedGas = userOp.verificationGasLimit - BigInt.from(20000); // Estimate
    if (unusedGas > BigInt.zero && unusedGas < BigInt.from(40000)) {
      savings += unusedGas * BigInt.from(10) ~/ BigInt.from(100); // 10% saved
    }

    return savings;
  }
}

/// Migration helper for transitioning accounts from v0.7 to v0.8
class V08MigrationHelper {
  V08MigrationHelper._();

  /// Check if an existing SimpleAccount can be migrated to v0.8
  static bool canMigrate(String accountAddress, int chainId) {
    // v0.8 is backwards compatible, existing accounts work with v0.8 EntryPoint
    return true;
  }

  /// Check if account should use EIP-7702 instead
  ///
  /// EIP-7702 is preferred for new accounts when:
  /// 1. Chain supports EIP-7702
  /// 2. Account is not yet deployed
  /// 3. User prefers gas efficiency over smart account features
  static bool shouldUseEIP7702({
    required String chainSymbol,
    required bool isDeployed,
    required bool preferGasEfficiency,
  }) {
    if (isDeployed) return false; // Already deployed, keep using smart account
    if (!EIP7702Handler.isChainSupported(chainSymbol)) return false;
    return preferGasEfficiency;
  }

  /// Get migration recommendations
  static List<String> getMigrationRecommendations({
    required EntryPointVersion currentVersion,
    required bool hasDeployedAccount,
    required String chainSymbol,
  }) {
    final recommendations = <String>[];

    if (currentVersion == EntryPointVersion.v07) {
      recommendations.add('Upgrade to v0.8 EntryPoint for reduced gas costs');
    }

    if (!hasDeployedAccount && EIP7702Handler.isChainSupported(chainSymbol)) {
      recommendations.add('Consider EIP-7702 account to avoid deployment costs');
    }

    if (currentVersion == EntryPointVersion.v08) {
      recommendations.add('Already using optimal v0.8 configuration');
    }

    return recommendations;
  }
}
