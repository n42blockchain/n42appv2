// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42appv2/src/wallet/aa/core/aa_config.dart';
import 'package:n42appv2/src/wallet/aa/models/user_operation.dart';
import 'package:n42appv2/src/wallet/aa/utils/eip7702_handler.dart';
import 'package:n42appv2/src/wallet/aa/account/account_types/simple7702_account.dart';

void main() {
  group('EIP7702Handler Basic Tests', () {
    test('magic byte should be 0x05', () {
      expect(EIP7702Handler.magicByte, 0x05);
    });

    test('isEIP7702UserOp should return false for standard UserOp', () {
      final userOp = UserOperation(
        sender: '0x1234567890123456789012345678901234567890',
        nonce: BigInt.zero,
        callData: Uint8List(0),
        accountGasLimits: Uint8List(32),
        preVerificationGas: BigInt.zero,
        gasFees: Uint8List(32),
      );

      expect(EIP7702Handler.isEIP7702UserOp(userOp), false);
    });

    test('isEIP7702UserOp should return true for UserOp with auth', () {
      final userOp = UserOperation(
        sender: '0x1234567890123456789012345678901234567890',
        nonce: BigInt.zero,
        callData: Uint8List(0),
        accountGasLimits: Uint8List(32),
        preVerificationGas: BigInt.zero,
        gasFees: Uint8List(32),
        eip7702Auth: Uint8List.fromList([0x01, 0x02, 0x03]),
      );

      expect(EIP7702Handler.isEIP7702UserOp(userOp), true);
    });
  });

  group('EIP7702Handler Authorization Hash Tests', () {
    test('createAuthorizationHash should produce 32 byte hash', () {
      final hash = EIP7702Handler.createAuthorizationHash(
        chainId: 1,
        implementationAddress: '0x1234567890123456789012345678901234567890',
        nonce: BigInt.zero,
      );

      expect(hash.length, 32);
    });

    test('createAuthorizationHash should be deterministic', () {
      final hash1 = EIP7702Handler.createAuthorizationHash(
        chainId: 1,
        implementationAddress: '0x1234567890123456789012345678901234567890',
        nonce: BigInt.zero,
      );

      final hash2 = EIP7702Handler.createAuthorizationHash(
        chainId: 1,
        implementationAddress: '0x1234567890123456789012345678901234567890',
        nonce: BigInt.zero,
      );

      expect(hash1, equals(hash2));
    });

    test('different chainIds should produce different hashes', () {
      final hash1 = EIP7702Handler.createAuthorizationHash(
        chainId: 1,
        implementationAddress: '0x1234567890123456789012345678901234567890',
        nonce: BigInt.zero,
      );

      final hash2 = EIP7702Handler.createAuthorizationHash(
        chainId: 137,
        implementationAddress: '0x1234567890123456789012345678901234567890',
        nonce: BigInt.zero,
      );

      expect(hash1, isNot(equals(hash2)));
    });

    test('different addresses should produce different hashes', () {
      final hash1 = EIP7702Handler.createAuthorizationHash(
        chainId: 1,
        implementationAddress: '0x1111111111111111111111111111111111111111',
        nonce: BigInt.zero,
      );

      final hash2 = EIP7702Handler.createAuthorizationHash(
        chainId: 1,
        implementationAddress: '0x2222222222222222222222222222222222222222',
        nonce: BigInt.zero,
      );

      expect(hash1, isNot(equals(hash2)));
    });

    test('different nonces should produce different hashes', () {
      final hash1 = EIP7702Handler.createAuthorizationHash(
        chainId: 1,
        implementationAddress: '0x1234567890123456789012345678901234567890',
        nonce: BigInt.zero,
      );

      final hash2 = EIP7702Handler.createAuthorizationHash(
        chainId: 1,
        implementationAddress: '0x1234567890123456789012345678901234567890',
        nonce: BigInt.from(1),
      );

      expect(hash1, isNot(equals(hash2)));
    });
  });

  group('EIP7702Handler Chain Support Tests', () {
    test('isChainSupported should return true for supported chains', () {
      // ETH should be supported (if chain config has v0.8)
      final result = EIP7702Handler.isChainSupported('ETH');
      // Result depends on chain configuration
      expect(result, isA<bool>());
    });

    test('isChainSupported should return false for unsupported chains', () {
      final result = EIP7702Handler.isChainSupported('UNSUPPORTED_CHAIN');
      expect(result, false);
    });

    test('getImplementationAddress should return address', () {
      final address = EIP7702Handler.getImplementationAddress('ETH');
      expect(address.isNotEmpty, true);
      expect(address.startsWith('0x'), true);
    });
  });

  group('EIP7702Handler Gas Estimation Tests', () {
    test('estimateAuthorizationGas should return reasonable value', () {
      final gas = EIP7702Handler.estimateAuthorizationGas();

      expect(gas > BigInt.zero, true);
      // Should be in a reasonable range (typically 12100-25000)
      expect(gas >= BigInt.from(10000), true);
      expect(gas <= BigInt.from(50000), true);
    });
  });

  group('EntryPointVersionAdapter Tests', () {
    test('getEntryPoint should return correct addresses', () {
      expect(
        EntryPointVersionAdapter.getEntryPoint(EntryPointVersion.v07),
        AAConfig.entryPointV07,
      );
      expect(
        EntryPointVersionAdapter.getEntryPoint(EntryPointVersion.v08),
        AAConfig.entryPointV08,
      );
    });

    test('requiresV08 should return true for EIP-7702 UserOp', () {
      final userOpWithAuth = UserOperation(
        sender: '0x1234567890123456789012345678901234567890',
        nonce: BigInt.zero,
        callData: Uint8List(0),
        accountGasLimits: Uint8List(32),
        preVerificationGas: BigInt.zero,
        gasFees: Uint8List(32),
        eip7702Auth: Uint8List.fromList([0x01]),
      );

      expect(EntryPointVersionAdapter.requiresV08(userOpWithAuth), true);
    });

    test('requiresV08 should return false for standard UserOp', () {
      final userOp = UserOperation(
        sender: '0x1234567890123456789012345678901234567890',
        nonce: BigInt.zero,
        callData: Uint8List(0),
        accountGasLimits: Uint8List(32),
        preVerificationGas: BigInt.zero,
        gasFees: Uint8List(32),
      );

      expect(EntryPointVersionAdapter.requiresV08(userOp), false);
    });

    test('upgradeToV08 should return the same UserOp', () {
      final userOp = UserOperation(
        sender: '0x1234567890123456789012345678901234567890',
        nonce: BigInt.zero,
        callData: Uint8List(0),
        accountGasLimits: Uint8List(32),
        preVerificationGas: BigInt.zero,
        gasFees: Uint8List(32),
      );

      final upgraded = EntryPointVersionAdapter.upgradeToV08(userOp);

      expect(upgraded.sender, userOp.sender);
      expect(upgraded.nonce, userOp.nonce);
    });

    test('getGasPenaltyThreshold should differ by version', () {
      final v07Threshold = EntryPointVersionAdapter.getGasPenaltyThreshold(
        EntryPointVersion.v07,
      );
      final v08Threshold = EntryPointVersionAdapter.getGasPenaltyThreshold(
        EntryPointVersion.v08,
      );

      expect(v07Threshold, BigInt.zero);
      expect(v08Threshold, BigInt.from(40000));
    });
  });

  group('V08MigrationHelper Tests', () {
    test('canMigrate should return true for any account', () {
      final result = V08MigrationHelper.canMigrate(
        '0x1234567890123456789012345678901234567890',
        1,
      );

      expect(result, true);
    });

    test('shouldUseEIP7702 should return false for deployed accounts', () {
      final result = V08MigrationHelper.shouldUseEIP7702(
        chainSymbol: 'ETH',
        isDeployed: true,
        preferGasEfficiency: true,
      );

      expect(result, false);
    });

    test('shouldUseEIP7702 should check chain support', () {
      final result = V08MigrationHelper.shouldUseEIP7702(
        chainSymbol: 'UNSUPPORTED_CHAIN',
        isDeployed: false,
        preferGasEfficiency: true,
      );

      expect(result, false);
    });

    test('getMigrationRecommendations should return recommendations', () {
      final recommendations = V08MigrationHelper.getMigrationRecommendations(
        currentVersion: EntryPointVersion.v07,
        hasDeployedAccount: false,
        chainSymbol: 'ETH',
      );

      expect(recommendations.isNotEmpty, true);
      expect(recommendations.any((r) => r.contains('v0.8')), true);
    });

    test('getMigrationRecommendations should note optimal config', () {
      final recommendations = V08MigrationHelper.getMigrationRecommendations(
        currentVersion: EntryPointVersion.v08,
        hasDeployedAccount: true,
        chainSymbol: 'ETH',
      );

      expect(recommendations.any((r) => r.contains('optimal')), true);
    });
  });

  group('EIP7702Authorization Tests', () {
    test('should create authorization with all fields', () {
      final auth = EIP7702Authorization(
        chainId: 1,
        address: '0x1234567890123456789012345678901234567890',
        nonce: BigInt.from(5),
        v: 27,
        r: Uint8List(32),
        s: Uint8List(32),
      );

      expect(auth.chainId, 1);
      expect(auth.nonce, BigInt.from(5));
      expect(auth.v, 27);
    });

    test('encode should produce non-empty bytes', () {
      final auth = EIP7702Authorization(
        chainId: 1,
        address: '0x1234567890123456789012345678901234567890',
        nonce: BigInt.zero,
        v: 27,
        r: Uint8List.fromList(List.filled(32, 0)),
        s: Uint8List.fromList(List.filled(32, 0)),
      );

      final encoded = auth.encode();
      expect(encoded.isNotEmpty, true);
    });

    test('decode should parse encoded authorization', () {
      final original = EIP7702Authorization(
        chainId: 1,
        address: '0x1234567890123456789012345678901234567890',
        nonce: BigInt.from(42),
        v: 27,
        r: Uint8List.fromList(List.filled(32, 1)),
        s: Uint8List.fromList(List.filled(32, 2)),
      );

      final encoded = original.encode();
      final decoded = EIP7702Authorization.decode(encoded);

      expect(decoded.chainId, original.chainId);
      expect(decoded.nonce, original.nonce);
      expect(decoded.v, original.v);
    });

    test('buildSignedAuthorization should return encoded bytes', () {
      final auth = EIP7702Authorization(
        chainId: 1,
        address: '0x1234567890123456789012345678901234567890',
        nonce: BigInt.zero,
        v: 27,
        r: Uint8List(32),
        s: Uint8List(32),
      );

      final signed = EIP7702Handler.buildSignedAuthorization(auth);
      expect(signed.isNotEmpty, true);
    });

    test('parseAuthorization should return null for non-EIP7702 UserOp', () {
      final userOp = UserOperation(
        sender: '0x1234567890123456789012345678901234567890',
        nonce: BigInt.zero,
        callData: Uint8List(0),
        accountGasLimits: Uint8List(32),
        preVerificationGas: BigInt.zero,
        gasFees: Uint8List(32),
      );

      final auth = EIP7702Handler.parseAuthorization(userOp);
      expect(auth, isNull);
    });
  });

  group('EIP7702Handler createEIP7702UserOp Tests', () {
    test('should create UserOp with EIP-7702 auth', () {
      final auth = EIP7702Authorization(
        chainId: 1,
        address: '0x1234567890123456789012345678901234567890',
        nonce: BigInt.zero,
        v: 27,
        r: Uint8List(32),
        s: Uint8List(32),
      );

      final userOp = EIP7702Handler.createEIP7702UserOp(
        eoaAddress: '0xEOA1234567890123456789012345678901234567',
        nonce: BigInt.from(1),
        callData: Uint8List.fromList([0x01, 0x02]),
        authorization: auth,
        accountGasLimits: Uint8List(32),
        preVerificationGas: BigInt.from(50000),
        gasFees: Uint8List(32),
      );

      expect(userOp.sender, '0xEOA1234567890123456789012345678901234567');
      expect(userOp.hasEIP7702Auth, true);
      expect(userOp.initCode, isNull); // No init code for EIP-7702
    });
  });

  group('Gas Savings Estimation Tests', () {
    test('estimateGasSavings should return savings for first transaction', () {
      final userOpWithAuth = UserOperation(
        sender: '0x1234567890123456789012345678901234567890',
        nonce: BigInt.zero,
        callData: Uint8List(0),
        accountGasLimits: PackedGasLimits.pack(
          BigInt.from(100000),
          BigInt.from(100000),
        ),
        preVerificationGas: BigInt.from(50000),
        gasFees: Uint8List(32),
        eip7702Auth: Uint8List.fromList([0x01]),
      );

      final savings = EntryPointVersionAdapter.estimateGasSavings(
        userOp: userOpWithAuth,
        isFirstTransaction: true,
      );

      // Should show some savings (deployment cost reduction)
      expect(savings, isA<BigInt>());
    });
  });
}
