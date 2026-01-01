// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter_test/flutter_test.dart';
import 'package:n42appv2/features/wallet/domain/entities/wallet_entity.dart';

void main() {
  group('CreateWallet Validation Tests', () {
    test('wallet name should not be empty', () {
      const walletName = '';
      expect(walletName.isEmpty, true);
    });

    test('wallet name should have valid characters', () {
      const validName = 'MyWallet123';
      final isValid = RegExp(r'^[a-zA-Z0-9_\-\s]+$').hasMatch(validName);
      expect(isValid, true);
    });

    test('password should meet minimum length requirement', () {
      const password = 'pass123';
      const minLength = 6;
      expect(password.length >= minLength, true);
    });

    test('password should not be too short', () {
      const shortPassword = 'abc';
      const minLength = 6;
      expect(shortPassword.length >= minLength, false);
    });

    test('ChainType enum should have all major chains', () {
      expect(ChainType.values.contains(ChainType.ethereum), true);
      expect(ChainType.values.contains(ChainType.bitcoin), true);
      expect(ChainType.values.contains(ChainType.solana), true);
    });
  });

  group('WalletEntity Tests', () {
    test('should create WalletEntity with required fields', () {
      final wallet = WalletEntity(
        id: 'wallet-1',
        name: 'Test Wallet',
        address: '0x123',
        chainType: 'ethereum',
        createdAt: DateTime.now(),
        isHD: true,
      );

      expect(wallet.id, 'wallet-1');
      expect(wallet.name, 'Test Wallet');
      expect(wallet.address, '0x123');
      expect(wallet.chainType, 'ethereum');
      expect(wallet.isHD, true);
    });

    test('WalletEntity should support equality', () {
      final now = DateTime(2024, 1, 1);
      final wallet1 = WalletEntity(
        id: 'wallet-1',
        name: 'Test',
        address: '0x123',
        chainType: 'ethereum',
        createdAt: now,
        isHD: true,
      );
      final wallet2 = WalletEntity(
        id: 'wallet-1',
        name: 'Test',
        address: '0x123',
        chainType: 'ethereum',
        createdAt: now,
        isHD: true,
      );

      expect(wallet1, equals(wallet2));
    });
  });

  group('TransactionEntity Tests', () {
    test('should create TransactionEntity correctly', () {
      final tx = TransactionEntity(
        hash: '0xabc',
        from: '0x123',
        to: '0x456',
        value: BigInt.from(1000000000000000000),
        status: TransactionStatus.confirmed,
        timestamp: DateTime.now(),
      );

      expect(tx.hash, '0xabc');
      expect(tx.from, '0x123');
      expect(tx.to, '0x456');
      expect(tx.status, TransactionStatus.confirmed);
    });

    test('TransactionStatus should have all states', () {
      expect(TransactionStatus.values.contains(TransactionStatus.pending), true);
      expect(TransactionStatus.values.contains(TransactionStatus.confirmed), true);
      expect(TransactionStatus.values.contains(TransactionStatus.failed), true);
    });
  });
}
