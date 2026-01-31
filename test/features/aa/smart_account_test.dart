// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42appv2/src/wallet/aa/models/smart_account.dart';

void main() {
  group('SmartAccountType Tests', () {
    test('should have all expected account types', () {
      expect(SmartAccountType.values.length, 6);
      expect(SmartAccountType.values.contains(SmartAccountType.simpleAccount), true);
      expect(SmartAccountType.values.contains(SmartAccountType.simple7702Account), true);
      expect(SmartAccountType.values.contains(SmartAccountType.safe), true);
      expect(SmartAccountType.values.contains(SmartAccountType.kernel), true);
      expect(SmartAccountType.values.contains(SmartAccountType.biconomy), true);
      expect(SmartAccountType.values.contains(SmartAccountType.custom), true);
    });

    test('fromString should parse account types correctly', () {
      expect(
        SmartAccountType.fromString('simpleAccount'),
        SmartAccountType.simpleAccount,
      );
      expect(
        SmartAccountType.fromString('simple7702Account'),
        SmartAccountType.simple7702Account,
      );
      expect(
        SmartAccountType.fromString('safe'),
        SmartAccountType.safe,
      );
    });

    test('fromString should be case insensitive', () {
      expect(
        SmartAccountType.fromString('SIMPLEACCOUNT'),
        SmartAccountType.simpleAccount,
      );
      expect(
        SmartAccountType.fromString('SimpleAccount'),
        SmartAccountType.simpleAccount,
      );
    });

    test('fromString should return custom for unknown types', () {
      expect(SmartAccountType.fromString('unknown'), SmartAccountType.custom);
      expect(SmartAccountType.fromString(''), SmartAccountType.custom);
    });

    test('displayName should return human-readable names', () {
      expect(SmartAccountType.simpleAccount.displayName, 'Simple Account');
      expect(SmartAccountType.simple7702Account.displayName, 'EIP-7702 Account');
      expect(SmartAccountType.safe.displayName, 'Safe');
      expect(SmartAccountType.kernel.displayName, 'Kernel');
      expect(SmartAccountType.biconomy.displayName, 'Biconomy');
      expect(SmartAccountType.custom.displayName, 'Custom');
    });

    test('requiresV08 should be true only for EIP-7702', () {
      expect(SmartAccountType.simpleAccount.requiresV08, false);
      expect(SmartAccountType.simple7702Account.requiresV08, true);
      expect(SmartAccountType.safe.requiresV08, false);
      expect(SmartAccountType.kernel.requiresV08, false);
      expect(SmartAccountType.biconomy.requiresV08, false);
      expect(SmartAccountType.custom.requiresV08, false);
    });

    test('isEIP7702 should be true only for EIP-7702', () {
      expect(SmartAccountType.simpleAccount.isEIP7702, false);
      expect(SmartAccountType.simple7702Account.isEIP7702, true);
      expect(SmartAccountType.safe.isEIP7702, false);
    });
  });

  group('SmartAccountState Tests', () {
    test('should have all expected states', () {
      expect(SmartAccountState.values.length, 4);
      expect(SmartAccountState.values.contains(SmartAccountState.notDeployed), true);
      expect(SmartAccountState.values.contains(SmartAccountState.deploying), true);
      expect(SmartAccountState.values.contains(SmartAccountState.deployed), true);
      expect(SmartAccountState.values.contains(SmartAccountState.error), true);
    });

    test('fromString should parse states correctly', () {
      expect(
        SmartAccountState.fromString('notDeployed'),
        SmartAccountState.notDeployed,
      );
      expect(
        SmartAccountState.fromString('deployed'),
        SmartAccountState.deployed,
      );
    });

    test('fromString should be case insensitive', () {
      expect(
        SmartAccountState.fromString('DEPLOYED'),
        SmartAccountState.deployed,
      );
    });

    test('fromString should return notDeployed for unknown states', () {
      expect(
        SmartAccountState.fromString('unknown'),
        SmartAccountState.notDeployed,
      );
    });

    test('canExecute should be true only for deployed state', () {
      expect(SmartAccountState.notDeployed.canExecute, false);
      expect(SmartAccountState.deploying.canExecute, false);
      expect(SmartAccountState.deployed.canExecute, true);
      expect(SmartAccountState.error.canExecute, false);
    });

    test('needsInitCode should be true only for notDeployed state', () {
      expect(SmartAccountState.notDeployed.needsInitCode, true);
      expect(SmartAccountState.deploying.needsInitCode, false);
      expect(SmartAccountState.deployed.needsInitCode, false);
      expect(SmartAccountState.error.needsInitCode, false);
    });
  });

  group('SmartAccount Tests', () {
    late SmartAccount account;

    setUp(() {
      account = SmartAccount(
        address: '0x1234567890123456789012345678901234567890',
        type: SmartAccountType.simpleAccount,
        ownerAddress: '0xOwner1234567890123456789012345678901234',
        state: SmartAccountState.notDeployed,
        chainId: 1,
        salt: BigInt.from(0),
        factoryAddress: '0xFactory12345678901234567890123456789012',
        createdAt: DateTime(2024, 1, 1),
      );
    });

    test('should create SmartAccount with required fields', () {
      expect(account.address, '0x1234567890123456789012345678901234567890');
      expect(account.type, SmartAccountType.simpleAccount);
      expect(account.chainId, 1);
    });

    test('isDeployed should reflect state correctly', () {
      expect(account.isDeployed, false);

      final deployedAccount = account.copyWith(state: SmartAccountState.deployed);
      expect(deployedAccount.isDeployed, true);
    });

    test('needsDeployment should reflect state correctly', () {
      expect(account.needsDeployment, true);

      final deployedAccount = account.copyWith(state: SmartAccountState.deployed);
      expect(deployedAccount.needsDeployment, false);
    });

    test('displayName should return label if set', () {
      expect(account.displayName, 'simpleAccount Account');

      final namedAccount = account.copyWith(label: 'My Account');
      expect(namedAccount.displayName, 'My Account');
    });

    test('shortAddress should truncate correctly', () {
      expect(account.shortAddress, '0x1234...7890');
    });

    test('shortAddress should handle short addresses', () {
      final shortAddrAccount = account.copyWith(address: '0x1234');
      expect(shortAddrAccount.shortAddress, '0x1234');
    });

    test('toJson should serialize correctly', () {
      final json = account.toJson();

      expect(json['address'], account.address);
      expect(json['type'], 'simpleAccount');
      expect(json['ownerAddress'], account.ownerAddress);
      expect(json['state'], 'notDeployed');
      expect(json['chainId'], 1);
      expect(json['salt'], '0');
    });

    test('fromJson should deserialize correctly', () {
      final json = account.toJson();
      final parsed = SmartAccount.fromJson(json);

      expect(parsed.address, account.address);
      expect(parsed.type, account.type);
      expect(parsed.ownerAddress, account.ownerAddress);
      expect(parsed.state, account.state);
      expect(parsed.chainId, account.chainId);
    });

    test('copyWith should create modified copy', () {
      final modified = account.copyWith(
        state: SmartAccountState.deployed,
        label: 'Updated Account',
      );

      expect(modified.address, account.address);
      expect(modified.state, SmartAccountState.deployed);
      expect(modified.label, 'Updated Account');
      expect(account.state, SmartAccountState.notDeployed); // Original unchanged
    });

    test('equality should compare address and chainId', () {
      final account1 = SmartAccount(
        address: '0x1234567890123456789012345678901234567890',
        type: SmartAccountType.simpleAccount,
        ownerAddress: '0xOwner',
        state: SmartAccountState.notDeployed,
        chainId: 1,
        salt: BigInt.zero,
        factoryAddress: '0xFactory',
        createdAt: DateTime.now(),
      );

      final account2 = SmartAccount(
        address: '0x1234567890123456789012345678901234567890',
        type: SmartAccountType.safe, // Different type
        ownerAddress: '0xDifferentOwner',
        state: SmartAccountState.deployed, // Different state
        chainId: 1, // Same chainId
        salt: BigInt.from(1),
        factoryAddress: '0xDifferentFactory',
        createdAt: DateTime.now(),
      );

      expect(account1 == account2, true);
    });

    test('equality should be case insensitive for address', () {
      final account1 = SmartAccount(
        address: '0xABCD1234',
        type: SmartAccountType.simpleAccount,
        ownerAddress: '0x',
        state: SmartAccountState.notDeployed,
        chainId: 1,
        salt: BigInt.zero,
        factoryAddress: '0x',
        createdAt: DateTime.now(),
      );

      final account2 = SmartAccount(
        address: '0xabcd1234',
        type: SmartAccountType.simpleAccount,
        ownerAddress: '0x',
        state: SmartAccountState.notDeployed,
        chainId: 1,
        salt: BigInt.zero,
        factoryAddress: '0x',
        createdAt: DateTime.now(),
      );

      expect(account1 == account2, true);
    });

    test('toString should return readable format', () {
      final str = account.toString();
      expect(str.contains('SmartAccount'), true);
      expect(str.contains('address'), true);
      expect(str.contains('type'), true);
    });
  });

  group('AAAccountInfo Tests', () {
    late AAAccountInfo info;
    late SmartAccount account1;
    late SmartAccount account2;

    setUp(() {
      account1 = SmartAccount(
        address: '0x1111111111111111111111111111111111111111',
        type: SmartAccountType.simpleAccount,
        ownerAddress: '0xOwner',
        state: SmartAccountState.deployed,
        chainId: 1,
        salt: BigInt.zero,
        factoryAddress: '0xFactory',
        createdAt: DateTime.now(),
      );

      account2 = SmartAccount(
        address: '0x2222222222222222222222222222222222222222',
        type: SmartAccountType.safe,
        ownerAddress: '0xOwner',
        state: SmartAccountState.notDeployed,
        chainId: 137,
        salt: BigInt.zero,
        factoryAddress: '0xFactory',
        createdAt: DateTime.now(),
      );

      info = AAAccountInfo(
        smartAccounts: {
          1: [account1],
          137: [account2],
        },
      );
    });

    test('getAccountsForChain should return correct accounts', () {
      expect(info.getAccountsForChain(1).length, 1);
      expect(info.getAccountsForChain(1).first, account1);
      expect(info.getAccountsForChain(137).length, 1);
      expect(info.getAccountsForChain(999).isEmpty, true);
    });

    test('getPrimaryAccount should return first account', () {
      expect(info.getPrimaryAccount(1), account1);
      expect(info.getPrimaryAccount(999), isNull);
    });

    test('addAccount should add to correct chain', () {
      final newAccount = SmartAccount(
        address: '0x3333333333333333333333333333333333333333',
        type: SmartAccountType.kernel,
        ownerAddress: '0xOwner',
        state: SmartAccountState.notDeployed,
        chainId: 1,
        salt: BigInt.from(1),
        factoryAddress: '0xFactory',
        createdAt: DateTime.now(),
      );

      info.addAccount(newAccount);

      expect(info.getAccountsForChain(1).length, 2);
    });

    test('removeAccount should remove correct account', () {
      final result = info.removeAccount(account1.address, 1);

      expect(result, true);
      expect(info.getAccountsForChain(1).isEmpty, true);
    });

    test('removeAccount should return false for non-existent account', () {
      final result = info.removeAccount('0xNonExistent', 1);
      expect(result, false);
    });

    test('findAccount should find account across chains', () {
      final found = info.findAccount(account2.address);
      expect(found, account2);
    });

    test('findAccount should return null for non-existent address', () {
      final found = info.findAccount('0xNonExistent');
      expect(found, isNull);
    });

    test('totalAccounts should return correct count', () {
      expect(info.totalAccounts, 2);
    });

    test('toJson/fromJson should round-trip correctly', () {
      final json = info.toJson();
      final parsed = AAAccountInfo.fromJson(json);

      expect(parsed.totalAccounts, info.totalAccounts);
      expect(parsed.preferAA, info.preferAA);
    });

    test('should handle defaultPaymasters', () {
      final infoWithPaymaster = AAAccountInfo(
        smartAccounts: {},
        defaultPaymasters: {
          1: '0xPaymaster1',
          137: '0xPaymaster2',
        },
      );

      final json = infoWithPaymaster.toJson();
      final parsed = AAAccountInfo.fromJson(json);

      expect(parsed.defaultPaymasters?[1], '0xPaymaster1');
      expect(parsed.defaultPaymasters?[137], '0xPaymaster2');
    });
  });

  group('SmartAccount EIP-7702 Specific Tests', () {
    test('EIP-7702 account should require v0.8', () {
      final account = SmartAccount(
        address: '0x1234567890123456789012345678901234567890',
        type: SmartAccountType.simple7702Account,
        ownerAddress: '0xOwner',
        state: SmartAccountState.notDeployed,
        chainId: 1,
        salt: BigInt.zero,
        factoryAddress: '0xFactory',
        createdAt: DateTime.now(),
      );

      expect(account.type.requiresV08, true);
      expect(account.type.isEIP7702, true);
    });

    test('EIP-7702 account displayName should be descriptive', () {
      expect(
        SmartAccountType.simple7702Account.displayName,
        'EIP-7702 Account',
      );
    });
  });
}
