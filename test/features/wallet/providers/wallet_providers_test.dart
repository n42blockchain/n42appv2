// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter_test/flutter_test.dart';
import 'package:n42appv2/features/wallet/presentation/providers/wallet_providers.dart';

void main() {
  // Initialize Flutter binding for tests
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WalletInfoData', () {
    test('should create WalletInfoData with required fields', () {
      final wallet = WalletInfoData(
        address: '0x1234567890abcdef',
        name: 'Test Wallet',
        chainType: 'ETH',
        createdAt: DateTime.now(),
      );

      expect(wallet.address, '0x1234567890abcdef');
      expect(wallet.name, 'Test Wallet');
      expect(wallet.chainType, 'ETH');
      expect(wallet.isMainWallet, false);
    });

    test('should create from legacy JSON', () {
      final json = {
        'walletName': 'My Wallet',
        'mnemonic': 'test mnemonic words',
        'privateKey': '0xprivatekey',
        'timestamp': '1234567890',
        'mainWallet': true,
        'networkIndex': 0,
        'coinSort': {'assets': 0, 'name': -1},
        'coinInfo': {
          'ETH': {
            'baseInfo': {
              'name': 'Ethereum',
              'icon': 'https://example.com/eth.png',
            },
          },
        },
      };

      final wallet = WalletInfoData.fromLegacyJson(json);

      expect(wallet.name, 'My Wallet');
      expect(wallet.isMainWallet, true);
      expect(wallet.mnemonic, 'test mnemonic words');
    });

    test('should convert to legacy JSON', () {
      final wallet = WalletInfoData(
        address: '0x123',
        name: 'Test',
        chainType: 'multi',
        createdAt: DateTime.now(),
        timestamp: '123456',
        isMainWallet: true,
      );

      final json = wallet.toLegacyJson();

      expect(json['walletName'], 'Test');
      expect(json['mainWallet'], true);
      expect(json['timestamp'], '123456');
    });

    test('should copy with new values', () {
      final wallet = WalletInfoData(
        address: '0x123',
        name: 'Original',
        chainType: 'ETH',
        createdAt: DateTime.now(),
      );

      final updated = wallet.copyWith(name: 'Updated');

      expect(updated.name, 'Updated');
      expect(updated.address, '0x123'); // unchanged
    });
  });

  group('CoinBalanceData', () {
    test('should create CoinBalanceData', () {
      const coin = CoinBalanceData(
        symbol: 'ETH',
        name: 'Ethereum',
        iconUrl: 'https://example.com/eth.png',
        balance: 1.5,
        balanceUsd: 3000.0,
        price: 2000.0,
        priceChange24h: 5.0,
        chainType: 'ETH',
      );

      expect(coin.symbol, 'ETH');
      expect(coin.balance, 1.5);
      expect(coin.balanceUsd, 3000.0);
    });
  });

  group('Wallet Providers (Pure State)', () {
    // Note: Tests that access SPUtil require SharedPreferences mocking.
    // These tests focus on pure state management logic.

    test('WalletInfoData default values', () {
      final wallet = WalletInfoData(
        address: '0x123',
        name: 'Test',
        chainType: 'ETH',
        createdAt: DateTime.now(),
      );

      expect(wallet.isMainWallet, false);
      expect(wallet.networkIndex, -1);
      expect(wallet.coinSort, {'assets': 0, 'name': -1});
    });

    test('WalletInfoData with all optional fields', () {
      final wallet = WalletInfoData(
        address: '0x123',
        name: 'Test',
        chainType: 'multi',
        createdAt: DateTime.now(),
        mnemonic: 'word1 word2 word3',
        privateKey: '0xpk',
        avatarUrl: 'https://example.com/avatar.png',
        isMainWallet: true,
        timestamp: '12345',
        coinInfo: {'ETH': {}},
        coinSort: {'assets': 1, 'name': 1},
        networkIndex: 1,
        faceBinding: true,
      );

      expect(wallet.isMainWallet, true);
      expect(wallet.mnemonic, 'word1 word2 word3');
      expect(wallet.faceBinding, true);
    });
  });
}
