// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/aa/core/aa_config.dart';
import 'package:n42_wallet/features/wallet/aa/models/user_operation.dart';

void main() {
  group('UserOperation Basic Tests', () {
    late UserOperation userOp;

    setUp(() {
      userOp = UserOperation(
        sender: '0x1234567890123456789012345678901234567890',
        nonce: BigInt.from(1),
        callData: Uint8List.fromList([0x01, 0x02, 0x03]),
        accountGasLimits: PackedGasLimits.pack(
          BigInt.from(100000),
          BigInt.from(200000),
        ),
        preVerificationGas: BigInt.from(50000),
        gasFees: PackedGasFees.pack(
          BigInt.from(1000000000), // 1 gwei priority fee
          BigInt.from(20000000000), // 20 gwei max fee
        ),
      );
    });

    test('should create UserOperation with required fields', () {
      expect(userOp.sender, '0x1234567890123456789012345678901234567890');
      expect(userOp.nonce, BigInt.from(1));
      expect(userOp.callData.length, 3);
    });

    test('should correctly unpack verificationGasLimit', () {
      expect(userOp.verificationGasLimit, BigInt.from(100000));
    });

    test('should correctly unpack callGasLimit', () {
      expect(userOp.callGasLimit, BigInt.from(200000));
    });

    test('should correctly unpack maxPriorityFeePerGas', () {
      expect(userOp.maxPriorityFeePerGas, BigInt.from(1000000000));
    });

    test('should correctly unpack maxFeePerGas', () {
      expect(userOp.maxFeePerGas, BigInt.from(20000000000));
    });

    test('should calculate estimated gas cost', () {
      // (100000 + 200000 + 50000) * 20000000000 = 7,000,000,000,000,000
      final expectedCost = BigInt.from(350000) * BigInt.from(20000000000);
      expect(userOp.estimatedGasCost, expectedCost);
    });

    test('should return false for hasEIP7702Auth when no auth data', () {
      expect(userOp.hasEIP7702Auth, false);
    });

    test('should return true for hasEIP7702Auth when auth data present', () {
      final userOpWithAuth = UserOperation(
        sender: '0x1234567890123456789012345678901234567890',
        nonce: BigInt.from(1),
        callData: Uint8List.fromList([0x01]),
        accountGasLimits: Uint8List(32),
        preVerificationGas: BigInt.zero,
        gasFees: Uint8List(32),
        eip7702Auth: Uint8List.fromList([0x01, 0x02, 0x03]),
      );

      expect(userOpWithAuth.hasEIP7702Auth, true);
    });
  });

  group('UserOperation Hash Tests', () {
    late UserOperation userOp;

    setUp(() {
      userOp = UserOperation(
        sender: '0x1234567890123456789012345678901234567890',
        nonce: BigInt.from(0),
        callData: Uint8List.fromList([]),
        accountGasLimits: Uint8List(32),
        preVerificationGas: BigInt.zero,
        gasFees: Uint8List(32),
      );
    });

    test('should produce deterministic hash', () {
      final hash1 = userOp.getUserOpHash(
        AAConfig.entryPointV08,
        BigInt.from(1),
      );
      final hash2 = userOp.getUserOpHash(
        AAConfig.entryPointV08,
        BigInt.from(1),
      );

      expect(hash1, equals(hash2));
    });

    test('hash should be 32 bytes', () {
      final hash = userOp.getUserOpHash(
        AAConfig.entryPointV08,
        BigInt.from(1),
      );

      expect(hash.length, 32);
    });

    test('different entryPoints should produce different hashes', () {
      final hash1 = userOp.getUserOpHash(
        AAConfig.entryPointV07,
        BigInt.from(1),
      );
      final hash2 = userOp.getUserOpHash(
        AAConfig.entryPointV08,
        BigInt.from(1),
      );

      expect(hash1, isNot(equals(hash2)));
    });

    test('different chainIds should produce different hashes', () {
      final hash1 = userOp.getUserOpHash(
        AAConfig.entryPointV08,
        BigInt.from(1),
      );
      final hash2 = userOp.getUserOpHash(
        AAConfig.entryPointV08,
        BigInt.from(137),
      );

      expect(hash1, isNot(equals(hash2)));
    });

    test('getUserOpHashV07 and getUserOpHashV08 should use correct versions', () {
      final hashV07 = userOp.getUserOpHashV07(
        AAConfig.entryPointV07,
        BigInt.from(1),
      );
      final hashV08 = userOp.getUserOpHashV08(
        AAConfig.entryPointV08,
        BigInt.from(1),
      );

      // V07 and V08 with different entry points should produce different hashes
      expect(hashV07, isNot(equals(hashV08)));
    });
  });

  group('UserOperation EIP-7702 Tests', () {
    test('hash should differ when EIP-7702 auth is present', () {
      final userOpWithoutAuth = UserOperation(
        sender: '0x1234567890123456789012345678901234567890',
        nonce: BigInt.from(0),
        callData: Uint8List.fromList([]),
        accountGasLimits: Uint8List(32),
        preVerificationGas: BigInt.zero,
        gasFees: Uint8List(32),
      );

      final userOpWithAuth = UserOperation(
        sender: '0x1234567890123456789012345678901234567890',
        nonce: BigInt.from(0),
        callData: Uint8List.fromList([]),
        accountGasLimits: Uint8List(32),
        preVerificationGas: BigInt.zero,
        gasFees: Uint8List(32),
        eip7702Auth: Uint8List.fromList([0x01, 0x02, 0x03]),
      );

      final hashWithoutAuth = userOpWithoutAuth.getUserOpHash(
        AAConfig.entryPointV08,
        BigInt.from(1),
        version: EntryPointVersion.v08,
      );

      final hashWithAuth = userOpWithAuth.getUserOpHash(
        AAConfig.entryPointV08,
        BigInt.from(1),
        version: EntryPointVersion.v08,
      );

      expect(hashWithoutAuth, isNot(equals(hashWithAuth)));
    });
  });

  group('UserOperation JSON Serialization Tests', () {
    test('toJson should produce valid JSON map', () {
      final userOp = UserOperation(
        sender: '0x1234567890123456789012345678901234567890',
        nonce: BigInt.from(5),
        callData: Uint8List.fromList([0xab, 0xcd]),
        accountGasLimits: Uint8List(32),
        preVerificationGas: BigInt.from(1000),
        gasFees: Uint8List(32),
      );

      final json = userOp.toJson();

      expect(json['sender'], '0x1234567890123456789012345678901234567890');
      expect(json['nonce'], '0x5');
      expect(json['preVerificationGas'], '0x3e8');
    });

    test('toJson should include eip7702Auth when present', () {
      final userOp = UserOperation(
        sender: '0x1234567890123456789012345678901234567890',
        nonce: BigInt.from(0),
        callData: Uint8List.fromList([]),
        accountGasLimits: Uint8List(32),
        preVerificationGas: BigInt.zero,
        gasFees: Uint8List(32),
        eip7702Auth: Uint8List.fromList([0x01, 0x02]),
      );

      final json = userOp.toJson(version: EntryPointVersion.v08);

      expect(json.containsKey('eip7702Auth'), true);
      expect(json['eip7702Auth'], '0x0102');
    });

    test('fromJson should parse JSON correctly', () {
      final json = {
        'sender': '0x1234567890123456789012345678901234567890',
        'nonce': '0x5',
        'initCode': '0x',
        'callData': '0xabcd',
        'accountGasLimits': '0x${'00' * 32}',
        'preVerificationGas': '0x3e8',
        'gasFees': '0x${'00' * 32}',
        'paymasterAndData': '0x',
        'signature': '0x',
      };

      final userOp = UserOperation.fromJson(json);

      expect(userOp.sender, '0x1234567890123456789012345678901234567890');
      expect(userOp.nonce, BigInt.from(5));
      expect(userOp.preVerificationGas, BigInt.from(1000));
    });
  });

  group('UserOperation copyWith Tests', () {
    test('copyWith should create new instance with updated fields', () {
      final original = UserOperation(
        sender: '0x1234567890123456789012345678901234567890',
        nonce: BigInt.from(1),
        callData: Uint8List.fromList([0x01]),
        accountGasLimits: Uint8List(32),
        preVerificationGas: BigInt.from(1000),
        gasFees: Uint8List(32),
      );

      final copied = original.copyWith(
        nonce: BigInt.from(2),
        eip7702Auth: Uint8List.fromList([0x01, 0x02]),
      );

      expect(copied.sender, original.sender);
      expect(copied.nonce, BigInt.from(2));
      expect(copied.hasEIP7702Auth, true);
      expect(original.nonce, BigInt.from(1)); // Original unchanged
    });
  });

  group('PackedGasLimits Tests', () {
    test('should pack verification and call gas limits correctly', () {
      final packed = PackedGasLimits.pack(
        BigInt.from(100000),
        BigInt.from(200000),
      );

      expect(packed.length, 32);
    });

    test('packed data should unpack to same values', () {
      final vgl = BigInt.from(100000);
      final cgl = BigInt.from(200000);
      final packed = PackedGasLimits.pack(vgl, cgl);

      final userOp = UserOperation(
        sender: '0x1234567890123456789012345678901234567890',
        nonce: BigInt.zero,
        callData: Uint8List(0),
        accountGasLimits: packed,
        preVerificationGas: BigInt.zero,
        gasFees: Uint8List(32),
      );

      expect(userOp.verificationGasLimit, vgl);
      expect(userOp.callGasLimit, cgl);
    });
  });

  group('PackedGasFees Tests', () {
    test('should pack gas fees correctly', () {
      final packed = PackedGasFees.pack(
        BigInt.from(1000000000), // 1 gwei
        BigInt.from(20000000000), // 20 gwei
      );

      expect(packed.length, 32);
    });

    test('packed data should unpack to same values', () {
      final mpf = BigInt.from(1000000000);
      final mf = BigInt.from(20000000000);
      final packed = PackedGasFees.pack(mpf, mf);

      final userOp = UserOperation(
        sender: '0x1234567890123456789012345678901234567890',
        nonce: BigInt.zero,
        callData: Uint8List(0),
        accountGasLimits: Uint8List(32),
        preVerificationGas: BigInt.zero,
        gasFees: packed,
      );

      expect(userOp.maxPriorityFeePerGas, mpf);
      expect(userOp.maxFeePerGas, mf);
    });
  });

  group('UserOperation Edge Cases', () {
    test('should handle zero values', () {
      final userOp = UserOperation(
        sender: '0x0000000000000000000000000000000000000000',
        nonce: BigInt.zero,
        callData: Uint8List(0),
        accountGasLimits: Uint8List(32),
        preVerificationGas: BigInt.zero,
        gasFees: Uint8List(32),
      );

      expect(userOp.verificationGasLimit, BigInt.zero);
      expect(userOp.callGasLimit, BigInt.zero);
      expect(userOp.estimatedGasCost, BigInt.zero);
    });

    test('should handle very large values', () {
      final largeValue = BigInt.parse('ffffffffffffffff', radix: 16);
      final packed = PackedGasLimits.pack(largeValue, largeValue);

      expect(packed.length, 32);
    });

    test('toString should return readable format', () {
      final userOp = UserOperation(
        sender: '0x1234567890123456789012345678901234567890',
        nonce: BigInt.from(42),
        callData: Uint8List(0),
        accountGasLimits: Uint8List(32),
        preVerificationGas: BigInt.zero,
        gasFees: Uint8List(32),
      );

      final str = userOp.toString();
      expect(str.contains('sender'), true);
      expect(str.contains('nonce'), true);
      expect(str.contains('42'), true);
    });
  });
}
