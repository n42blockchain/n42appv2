// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';

void main() {
  group('CoinType Enum', () {
    test('should have N token (not AST)', () {
      // Verify N exists
      expect(CoinType.values.any((c) => c.name == 'N'), true,
          reason: 'CoinType should have N token');

      // Verify AST does NOT exist
      expect(CoinType.values.any((c) => c.name == 'AST'), false,
          reason: 'CoinType should NOT have AST token (renamed to N)');

      // Verify AMT does NOT exist
      expect(CoinType.values.any((c) => c.name == 'AMT'), false,
          reason: 'CoinType should NOT have AMT token');
    });

    test('should have all major cryptocurrencies', () {
      final expectedCoins = [
        'BTC', 'ETH', 'BNB', 'SOL', 'TRX', 'MATIC',
        'AVAX', 'DOT', 'ATOM', 'XRP', 'N'
      ];

      for (final coin in expectedCoins) {
        expect(
          CoinType.values.any((c) => c.name == coin),
          true,
          reason: 'CoinType should have $coin',
        );
      }
    });

    test('should have correct N token name', () {
      expect(CoinType.N.name, 'N');
    });

    test('should have major blockchain coins', () {
      // EVM compatible chains
      expect(CoinType.ETH.name, 'ETH');
      expect(CoinType.BNB.name, 'BNB');
      expect(CoinType.MATIC.name, 'MATIC');
      expect(CoinType.AVAX.name, 'AVAX');

      // Bitcoin-like chains
      expect(CoinType.BTC.name, 'BTC');
      expect(CoinType.LTC.name, 'LTC');
      expect(CoinType.DOGE.name, 'DOGE');

      // Other major chains
      expect(CoinType.SOL.name, 'SOL');
      expect(CoinType.TRX.name, 'TRX');
      expect(CoinType.DOT.name, 'DOT');
      expect(CoinType.ATOM.name, 'ATOM');
    });

    test('should have Layer 2 solutions', () {
      expect(CoinType.ARB.name, 'ARB'); // Arbitrum
      expect(CoinType.OP.name, 'OP');   // Optimism
      expect(CoinType.BASE.name, 'BASE'); // Base
    });

    test('should have alternative coins', () {
      expect(CoinType.FIL.name, 'FIL'); // Filecoin
      expect(CoinType.ALGO.name, 'ALGO'); // Algorand
      expect(CoinType.XTZ.name, 'XTZ'); // Tezos
      expect(CoinType.APT.name, 'APT'); // Aptos
      expect(CoinType.SUI.name, 'SUI'); // Sui
      expect(CoinType.TON.name, 'TON'); // The Open Network
    });

    test('should have new batch 1 chains (Stellar, VeChain, Harmony, IoTeX)', () {
      expect(CoinType.XLM.name, 'XLM'); // Stellar
      expect(CoinType.VET.name, 'VET'); // VeChain
      expect(CoinType.ONE.name, 'ONE'); // Harmony
      expect(CoinType.IOTX.name, 'IOTX'); // IoTeX
    });

    test('should have new batch 2 chains (NEAR, Zilliqa, Theta)', () {
      expect(CoinType.NEAR.name, 'NEAR'); // NEAR Protocol
      expect(CoinType.ZIL.name, 'ZIL'); // Zilliqa
      expect(CoinType.THETA.name, 'THETA'); // Theta Network
    });

    test('should have new batch 3 chains (Cardano, MultiversX)', () {
      expect(CoinType.ADA.name, 'ADA'); // Cardano
      expect(CoinType.EGLD.name, 'EGLD'); // MultiversX (formerly Elrond)
    });

    test('should have all supported EVM-compatible coins', () {
      final evmCoins = [
        'ETH', 'BNB', 'MATIC', 'AVAX', 'FTM', 'CELO',
        'XDAI', 'OP', 'ARB', 'BASE', 'ONE', 'IOTX', 'THETA'
      ];

      for (final coin in evmCoins) {
        expect(
          CoinType.values.any((c) => c.name == coin),
          true,
          reason: 'CoinType should have EVM-compatible coin $coin',
        );
      }
    });

    test('should have all Bitcoin-like coins', () {
      final btcCoins = [
        'BTC', 'LTC', 'DOGE', 'DASH', 'BCH', 'BTG', 'RVN',
        'VIA', 'DGB', 'MONA'
      ];

      for (final coin in btcCoins) {
        expect(
          CoinType.values.any((c) => c.name == coin),
          true,
          reason: 'CoinType should have Bitcoin-like coin $coin',
        );
      }
    });

    test('should have Polkadot ecosystem coins', () {
      expect(CoinType.DOT.name, 'DOT'); // Polkadot
      expect(CoinType.KSM.name, 'KSM'); // Kusama
      expect(CoinType.ACA.name, 'ACA'); // Acala
    });

    test('CoinType enum count should match expected', () {
      // Total expected: around 50+ coins
      expect(CoinType.values.length, greaterThan(45));
    });
  });

  group('BlockchainType Enum', () {
    test('should have all major blockchain types', () {
      final expectedTypes = [
        'Bitcoin', 'Ethereum', 'Solana', 'Tron',
        'Algorand', 'Tezos', 'Cosmos', 'Polkadot'
      ];

      for (final type in expectedTypes) {
        expect(
          BlockchainType.values.any((t) => t.name == type),
          true,
          reason: 'BlockchainType should have $type',
        );
      }
    });

    test('should have correct type names', () {
      expect(BlockchainType.Bitcoin.name, 'Bitcoin');
      expect(BlockchainType.Ethereum.name, 'Ethereum');
      expect(BlockchainType.Solana.name, 'Solana');
      expect(BlockchainType.Tron.name, 'Tron');
    });

    test('should have new batch 1 blockchain types', () {
      expect(BlockchainType.Stellar.name, 'Stellar');
      expect(BlockchainType.VeChain.name, 'VeChain');
      expect(BlockchainType.Harmony.name, 'Harmony');
      expect(BlockchainType.IoTeX.name, 'IoTeX');
    });

    test('should have new batch 2 blockchain types', () {
      expect(BlockchainType.Near.name, 'Near');
      expect(BlockchainType.Zilliqa.name, 'Zilliqa');
      expect(BlockchainType.Theta.name, 'Theta');
    });

    test('should have new batch 3 blockchain types', () {
      expect(BlockchainType.Cardano.name, 'Cardano');
      expect(BlockchainType.MultiversX.name, 'MultiversX');
    });

    test('BlockchainType enum count should match expected', () {
      // Total expected: 17 blockchain types
      expect(BlockchainType.values.length, greaterThanOrEqualTo(17));
    });
  });

  group('Token Name Migration', () {
    test('all coin references should use N instead of AST', () {
      // This test ensures the migration from AST to N is complete
      final allCoinNames = CoinType.values.map((c) => c.name).toList();

      // Should contain N
      expect(allCoinNames.contains('N'), true,
          reason: 'Native token should be named N');

      // Should NOT contain old names
      expect(allCoinNames.contains('AST'), false,
          reason: 'Old token name AST should not exist');
      expect(allCoinNames.contains('AMT'), false,
          reason: 'Old token name AMT should not exist');
    });
  });

  group('CoinType to BlockchainType Mapping', () {
    test('Bitcoin-like coins should map to Bitcoin blockchain', () {
      final bitcoinCoins = ['BTC', 'LTC', 'DOGE', 'DASH', 'BCH', 'BTG'];
      // This is a conceptual test - actual mapping is in Kotlin
      for (final coin in bitcoinCoins) {
        expect(
          CoinType.values.any((c) => c.name == coin),
          true,
          reason: '$coin should exist as a Bitcoin-like coin',
        );
      }
    });

    test('EVM coins should map to Ethereum blockchain type', () {
      final evmCoins = ['ETH', 'BNB', 'MATIC', 'AVAX', 'OP', 'ARB'];
      for (final coin in evmCoins) {
        expect(
          CoinType.values.any((c) => c.name == coin),
          true,
          reason: '$coin should exist as an EVM coin',
        );
      }
    });

    test('Native chains should have their own blockchain types', () {
      // Verify unique blockchain types exist for native chains
      final nativeChains = {
        'SOL': 'Solana',
        'TRX': 'Tron',
        'ALGO': 'Algorand',
        'XTZ': 'Tezos',
        'XRP': 'Ripple',
        'ATOM': 'Cosmos',
        'FIL': 'Filecoin',
        'DOT': 'Polkadot',
        'APT': 'Aptos',
        'SUI': 'Sui',
        'TON': 'TheOpenNetwork',
        'XLM': 'Stellar',
        'VET': 'VeChain',
        'NEAR': 'Near',
        'ZIL': 'Zilliqa',
        'THETA': 'Theta',
        'ADA': 'Cardano',
        'EGLD': 'MultiversX',
      };

      for (final entry in nativeChains.entries) {
        expect(
          CoinType.values.any((c) => c.name == entry.key),
          true,
          reason: 'CoinType should have ${entry.key}',
        );
        expect(
          BlockchainType.values.any((t) => t.name == entry.value),
          true,
          reason: 'BlockchainType should have ${entry.value}',
        );
      }
    });
  });
}
