// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/aa/account/account_deployer.dart';
import 'package:n42_wallet/features/wallet/aa/core/aa_errors.dart';
import 'package:n42_wallet/features/wallet/aa/models/smart_account.dart';

void main() {
  group('AccountDeployer — buildInitCodeForAccountType', () {
    late AccountDeployer deployer;

    setUp(() {
      // Use ETH chain which is well-configured for AA
      deployer = AccountDeployer.forChain('ETH');
    });

    test('simpleAccount returns non-null init code', () {
      final initCode = deployer.buildInitCodeForAccountType(
        type: SmartAccountType.simpleAccount,
        owner: '0x1234567890abcdef1234567890abcdef12345678',
        salt: BigInt.zero,
      );
      expect(initCode, isNotNull);
      expect(initCode!.isNotEmpty, true);
    });

    test('simple7702Account returns null (no init code needed)', () {
      final initCode = deployer.buildInitCodeForAccountType(
        type: SmartAccountType.simple7702Account,
        owner: '0x1234567890abcdef1234567890abcdef12345678',
        salt: BigInt.zero,
      );
      expect(initCode, isNull);
    });

    test('safe throws AAConfigurationError', () {
      expect(
        () => deployer.buildInitCodeForAccountType(
          type: SmartAccountType.safe,
          owner: '0x1234567890abcdef1234567890abcdef12345678',
          salt: BigInt.zero,
        ),
        throwsA(isA<AAConfigurationError>()),
      );
    });

    test('kernel throws AAConfigurationError', () {
      expect(
        () => deployer.buildInitCodeForAccountType(
          type: SmartAccountType.kernel,
          owner: '0x1234567890abcdef1234567890abcdef12345678',
          salt: BigInt.zero,
        ),
        throwsA(isA<AAConfigurationError>()),
      );
    });

    test('biconomy throws AAConfigurationError', () {
      expect(
        () => deployer.buildInitCodeForAccountType(
          type: SmartAccountType.biconomy,
          owner: '0x1234567890abcdef1234567890abcdef12345678',
          salt: BigInt.zero,
        ),
        throwsA(isA<AAConfigurationError>()),
      );
    });

    test('custom throws AAConfigurationError', () {
      expect(
        () => deployer.buildInitCodeForAccountType(
          type: SmartAccountType.custom,
          owner: '0x1234567890abcdef1234567890abcdef12345678',
          salt: BigInt.zero,
        ),
        throwsA(isA<AAConfigurationError>()),
      );
    });

    test('AAConfigurationError message includes type name', () {
      try {
        deployer.buildInitCodeForAccountType(
          type: SmartAccountType.safe,
          owner: '0x1234567890abcdef1234567890abcdef12345678',
          salt: BigInt.zero,
        );
        fail('Expected AAConfigurationError');
      } on AAConfigurationError catch (e) {
        expect(e.message, contains('safe'));
      }
    });
  });

  group('AccountDeployer — needsInitCode', () {
    late AccountDeployer deployer;

    setUp(() {
      deployer = AccountDeployer.forChain('ETH');
    });

    test('returns true for not-deployed simpleAccount', () {
      final account = SmartAccount(
        address: '0x1234567890abcdef1234567890abcdef12345678',
        ownerAddress: '0xabcdef1234567890abcdef1234567890abcdef12',
        type: SmartAccountType.simpleAccount,
        state: SmartAccountState.notDeployed,
        salt: BigInt.zero,
        chainId: 1,
        factoryAddress: '0x0000000000000000000000000000000000000000',
        createdAt: DateTime.now(),
      );
      expect(deployer.needsInitCode(account), true);
    });

    test('returns false for deployed simpleAccount', () {
      final account = SmartAccount(
        address: '0x1234567890abcdef1234567890abcdef12345678',
        ownerAddress: '0xabcdef1234567890abcdef1234567890abcdef12',
        type: SmartAccountType.simpleAccount,
        state: SmartAccountState.deployed,
        salt: BigInt.zero,
        chainId: 1,
        factoryAddress: '0x0000000000000000000000000000000000000000',
        createdAt: DateTime.now(),
      );
      expect(deployer.needsInitCode(account), false);
    });

    test('returns false for simple7702Account regardless of state', () {
      final account = SmartAccount(
        address: '0x1234567890abcdef1234567890abcdef12345678',
        ownerAddress: '0xabcdef1234567890abcdef1234567890abcdef12',
        type: SmartAccountType.simple7702Account,
        state: SmartAccountState.notDeployed,
        salt: BigInt.zero,
        chainId: 1,
        factoryAddress: '0x0000000000000000000000000000000000000000',
        createdAt: DateTime.now(),
      );
      expect(deployer.needsInitCode(account), false);
    });
  });

  group('AccountDeployer — factory constructors', () {
    test('forChain with unsupported chain throws AAUnsupportedChainError', () {
      expect(
        () => AccountDeployer.forChain('NOSUCHCHAIN'),
        throwsA(isA<AAUnsupportedChainError>()),
      );
    });

    test('forChain with ETH succeeds', () {
      expect(() => AccountDeployer.forChain('ETH'), returnsNormally);
    });
  });
}
