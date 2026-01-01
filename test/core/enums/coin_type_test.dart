// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter_test/flutter_test.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';

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
}

