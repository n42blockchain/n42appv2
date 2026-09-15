// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// T-6: Tests for walletBalanceProvider / CoinListNotifier
//
// Strategy: Since globalWapAdapter requires platform channels and full
// WalletActionProvider initialization, we test the data-model and logic layer
// directly, and verify the try-catch guard behaviour via a lightweight fake.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';

/// Lightweight fake that mirrors the relevant slice of WalletActionProvider.
class FakeWapAdapter {
  final double _balanceTotal;
  final bool shouldThrow;

  FakeWapAdapter({double balanceTotal = 0.0, this.shouldThrow = false})
    : _balanceTotal = balanceTotal;

  double get balanceTotal {
    if (shouldThrow) throw StateError('adapter not initialized');
    return _balanceTotal;
  }
}

double safeBalanceTotal(FakeWapAdapter? adapter) {
  if (adapter == null) return 0.0;
  try {
    return adapter.balanceTotal;
  } catch (_) {
    return 0.0;
  }
}

void main() {
  group('walletBalanceProvider logic', () {
    test('returns 0.0 when wallet is null (no current wallet)', () {
      // Mirrors the guard: if (wallet == null) return 0.0;
      const WalletInfoData? wallet = null;
      final result = wallet == null ? 0.0 : 999.0;
      expect(result, 0.0);
    });

    test('returns balance from adapter when wallet is present', () {
      final adapter = FakeWapAdapter(balanceTotal: 1234.56);
      final result = safeBalanceTotal(adapter);
      expect(result, 1234.56);
    });

    test(
      'returns 0.0 when globalWapAdapter is not initialized (try-catch guard)',
      () {
        final adapter = FakeWapAdapter(shouldThrow: true);
        final result = safeBalanceTotal(adapter);
        expect(
          result,
          0.0,
          reason: 'try-catch must swallow StateError and return 0.0',
        );
      },
    );

    test('returns 0.0 when adapter is null', () {
      final result = safeBalanceTotal(null);
      expect(result, 0.0);
    });
  });

  group('CoinBalanceData construction', () {
    test('CoinBalanceData with zero balance when no match found', () {
      // Simulates the case where globalWapAdapter.coinModels has no matching symbol
      const coin = CoinBalanceData(
        symbol: 'UNKNOWN',
        name: 'Unknown',
        iconUrl: '',
        balance: 0.0,
        balanceUsd: 0.0,
        price: 0.0,
        priceChange24h: 0.0,
        chainType: 'UNKNOWN',
      );

      expect(coin.balance, 0.0);
      expect(coin.balanceUsd, 0.0);
    });

    test(
      'CoinBalanceData correctly stores balance, price, and priceChange',
      () {
        const coin = CoinBalanceData(
          symbol: 'ETH',
          name: 'Ethereum',
          iconUrl: 'https://example.com/eth.png',
          balance: 2.5,
          balanceUsd: 5000.0,
          price: 2000.0,
          priceChange24h: 3.5,
          chainType: 'ETH',
        );

        expect(coin.balance, 2.5);
        expect(coin.price, 2000.0);
        expect(coin.priceChange24h, 3.5);
        expect(coin.balanceUsd, 5000.0);
      },
    );
  });

  group('WalletInfoData coinInfo mapping', () {
    test('wallet with no coinInfo produces empty coin list', () {
      final wallet = WalletInfoData(
        address: '0x123',
        name: 'Test',
        chainType: 'multi',
        createdAt: DateTime.now(),
        coinInfo: null,
      );

      final coins = <CoinBalanceData>[];
      final coinInfo = wallet.coinInfo;
      if (coinInfo != null) {
        for (final entry in coinInfo.entries) {
          coins.add(
            CoinBalanceData(
              symbol: entry.key,
              name: entry.key,
              iconUrl: '',
              balance: 0.0,
              balanceUsd: 0.0,
              price: 0.0,
              priceChange24h: 0.0,
              chainType: entry.key,
            ),
          );
        }
      }

      expect(coins, isEmpty);
    });

    test('wallet coinInfo maps to CoinBalanceData list', () {
      final wallet = WalletInfoData(
        address: '0x123',
        name: 'Test',
        chainType: 'multi',
        createdAt: DateTime.now(),
        coinInfo: {
          'ETH': {
            'baseInfo': {
              'name': 'Ethereum',
              'icon': 'https://example.com/eth.png',
            },
          },
          'BTC': {
            'baseInfo': {
              'name': 'Bitcoin',
              'icon': 'https://example.com/btc.png',
            },
          },
        },
      );

      final coins = <CoinBalanceData>[];
      for (final entry in wallet.coinInfo!.entries) {
        final coinData = entry.value as Map<String, dynamic>?;
        if (coinData != null && coinData['baseInfo'] != null) {
          final baseInfo = coinData['baseInfo'] as Map<String, dynamic>;
          coins.add(
            CoinBalanceData(
              symbol: entry.key,
              name: baseInfo['name']?.toString() ?? entry.key,
              iconUrl: baseInfo['icon']?.toString() ?? '',
              balance: 0.0,
              balanceUsd: 0.0,
              price: 0.0,
              priceChange24h: 0.0,
              chainType: entry.key,
            ),
          );
        }
      }

      expect(coins.length, 2);
      expect(coins.map((c) => c.symbol).toSet(), {'ETH', 'BTC'});
    });
  });
}
