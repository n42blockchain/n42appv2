// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/aa/session_key_models.dart';

void main() {
  group('SessionKeyPermission Tests', () {
    test('should have all expected permission types', () {
      expect(SessionKeyPermission.values.length, 4);
      expect(
        SessionKeyPermission.values.contains(SessionKeyPermission.transfer),
        true,
      );
      expect(
        SessionKeyPermission.values.contains(SessionKeyPermission.approve),
        true,
      );
      expect(
        SessionKeyPermission.values.contains(SessionKeyPermission.contractCall),
        true,
      );
      expect(
        SessionKeyPermission.values.contains(SessionKeyPermission.full),
        true,
      );
    });
  });

  group('SessionKeyStatus Tests', () {
    test('should have all expected status types', () {
      expect(SessionKeyStatus.values.length, 3);
      expect(SessionKeyStatus.values.contains(SessionKeyStatus.active), true);
      expect(SessionKeyStatus.values.contains(SessionKeyStatus.expired), true);
      expect(SessionKeyStatus.values.contains(SessionKeyStatus.revoked), true);
    });
  });

  group('SessionKeyData Tests', () {
    late SessionKeyData activeKey;
    late SessionKeyData expiredKey;

    setUp(() {
      activeKey = SessionKeyData(
        keyAddress: '0x1234567890abcdef1234567890abcdef12345678',
        label: 'Test Session',
        permission: SessionKeyPermission.transfer,
        status: SessionKeyStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        expiresAt: DateTime.now().add(const Duration(days: 25)),
        dappName: 'Test DApp',
        spendingLimit: BigInt.from(10) * BigInt.from(10).pow(18),
        usedAmount: BigInt.from(3) * BigInt.from(10).pow(18),
        transactionCount: 12,
      );

      expiredKey = SessionKeyData(
        keyAddress: '0xabcdef1234567890abcdef1234567890abcdef12',
        label: 'Expired Session',
        permission: SessionKeyPermission.approve,
        status: SessionKeyStatus.expired,
        createdAt: DateTime.now().subtract(const Duration(days: 35)),
        expiresAt: DateTime.now().subtract(const Duration(days: 5)),
        transactionCount: 28,
      );
    });

    test('shortAddress should truncate correctly', () {
      expect(activeKey.shortAddress, '0x1234...5678');
    });

    test('shortAddress should handle short addresses', () {
      final shortKey = SessionKeyData(
        keyAddress: '0x1234',
        label: 'Short',
        permission: SessionKeyPermission.transfer,
        status: SessionKeyStatus.active,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 1)),
      );
      expect(shortKey.shortAddress, '0x1234');
    });

    test('isActive should return correct value', () {
      expect(activeKey.isActive, true);
      expect(expiredKey.isActive, false);
    });

    test('remainingTime should return positive duration for active key', () {
      expect(activeKey.remainingTime.inDays, greaterThan(0));
    });

    test('remainingTime should return zero for expired key', () {
      expect(expiredKey.remainingTime, Duration.zero);
    });

    test('usagePercentage should calculate correctly', () {
      // 3/10 = 0.3 = 30%
      expect(activeKey.usagePercentage, closeTo(0.3, 0.01));
    });

    test('usagePercentage should return 0 for null spending limit', () {
      final noLimitKey = SessionKeyData(
        keyAddress: '0x1234',
        label: 'No Limit',
        permission: SessionKeyPermission.full,
        status: SessionKeyStatus.active,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 1)),
      );
      expect(noLimitKey.usagePercentage, 0);
    });

    test('usagePercentage should return 0 for zero spending limit', () {
      final zeroLimitKey = SessionKeyData(
        keyAddress: '0x1234',
        label: 'Zero Limit',
        permission: SessionKeyPermission.full,
        status: SessionKeyStatus.active,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 1)),
        spendingLimit: BigInt.zero,
      );
      expect(zeroLimitKey.usagePercentage, 0);
    });

    test('usagePercentage should be clamped to 1.0', () {
      final overusedKey = SessionKeyData(
        keyAddress: '0x1234',
        label: 'Overused',
        permission: SessionKeyPermission.transfer,
        status: SessionKeyStatus.active,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 1)),
        spendingLimit: BigInt.from(10),
        usedAmount: BigInt.from(15), // More than limit
      );
      expect(overusedKey.usagePercentage, 1.0);
    });
  });

  group('SessionKeyData Edge Cases', () {
    test('should handle null dappName and dappIcon', () {
      final key = SessionKeyData(
        keyAddress: '0x1234567890abcdef1234567890abcdef12345678',
        label: 'Test',
        permission: SessionKeyPermission.transfer,
        status: SessionKeyStatus.active,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 1)),
      );

      expect(key.dappName, isNull);
      expect(key.dappIcon, isNull);
    });

    test('should handle null allowedContracts', () {
      final key = SessionKeyData(
        keyAddress: '0x1234567890abcdef1234567890abcdef12345678',
        label: 'Test',
        permission: SessionKeyPermission.contractCall,
        status: SessionKeyStatus.active,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 1)),
      );

      expect(key.allowedContracts, isNull);
    });

    test('should handle empty allowedContracts list', () {
      final key = SessionKeyData(
        keyAddress: '0x1234567890abcdef1234567890abcdef12345678',
        label: 'Test',
        permission: SessionKeyPermission.contractCall,
        status: SessionKeyStatus.active,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 1)),
        allowedContracts: [],
      );

      expect(key.allowedContracts, isEmpty);
    });
  });
}
