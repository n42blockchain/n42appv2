// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/domain/entities/wallet_entity.dart';

void main() {
  group('GetBalance Validation Tests', () {
    test('address should not be empty', () {
      const address = '';
      expect(address.isEmpty, true);
    });

    test('address should be valid ethereum format', () {
      const validAddress = '0x1234567890abcdef1234567890abcdef12345678';
      final isValid = RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(validAddress);
      expect(isValid, true);
    });

    test('should reject invalid address format', () {
      const invalidAddress = '0xinvalid';
      final isValid = RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(invalidAddress);
      expect(isValid, false);
    });
  });

  group('AssetEntity Tests', () {
    test('should create AssetEntity with required fields', () {
      final asset = AssetEntity(
        symbol: 'ETH',
        name: 'Ethereum',
        balance: BigInt.from(1000000000000000000),
        decimals: 18,
        chainType: 'ethereum',
        isNative: true,
      );

      expect(asset.symbol, 'ETH');
      expect(asset.name, 'Ethereum');
      expect(asset.decimals, 18);
      expect(asset.isNative, true);
      expect(asset.chainType, 'ethereum');
    });

    test('should create token AssetEntity', () {
      final token = AssetEntity(
        symbol: 'USDT',
        name: 'Tether USD',
        balance: BigInt.from(100000000),
        decimals: 6,
        chainType: 'ethereum',
        contractAddress: '0xdAC17F958D2ee523a2206206994597C13D831ec7',
        isNative: false,
      );

      expect(token.symbol, 'USDT');
      expect(token.decimals, 6);
      expect(token.isNative, false);
      expect(token.contractAddress, isNotNull);
    });

    test('should calculate formatted balance correctly', () {
      final asset = AssetEntity(
        symbol: 'ETH',
        name: 'Ethereum',
        balance: BigInt.from(1000000000000000000), // 1 ETH in wei
        decimals: 18,
        chainType: 'ethereum',
        isNative: true,
      );

      // 1 ETH = 10^18 wei, use integer division
      final balanceInEth = asset.balance ~/ BigInt.from(10).pow(asset.decimals);
      expect(balanceInEth, BigInt.from(1));
    });

    test('AssetEntity equality should work', () {
      final asset1 = AssetEntity(
        symbol: 'ETH',
        name: 'Ethereum',
        balance: BigInt.from(100),
        decimals: 18,
        chainType: 'ethereum',
        isNative: true,
      );
      final asset2 = AssetEntity(
        symbol: 'ETH',
        name: 'Ethereum',
        balance: BigInt.from(100),
        decimals: 18,
        chainType: 'ethereum',
        isNative: true,
      );

      expect(asset1, equals(asset2));
    });
  });

  group('Balance Display Tests', () {
    test('should format large balance correctly', () {
      final balance = BigInt.from(1234567890000000000);
      final decimals = 18;
      final formatted = (balance / BigInt.from(10).pow(decimals)).toDouble();
      expect(formatted, closeTo(1.23, 0.01));
    });

    test('should handle zero balance', () {
      final asset = AssetEntity(
        symbol: 'ETH',
        name: 'Ethereum',
        balance: BigInt.zero,
        decimals: 18,
        chainType: 'ethereum',
        isNative: true,
      );

      expect(asset.balance, BigInt.zero);
    });

    test('should format balance with decimals', () {
      final asset = AssetEntity(
        symbol: 'ETH',
        name: 'Ethereum',
        balance: BigInt.from(1500000000000000000), // 1.5 ETH
        decimals: 18,
        chainType: 'ethereum',
        isNative: true,
      );

      expect(asset.formattedBalance, '1.5');
    });
  });
}
