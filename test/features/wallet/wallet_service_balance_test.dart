// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Tests for WalletServiceImpl.getBalance blockchain type derivation.
//
// Strategy: test the chain-config lookup logic that resolves coinType → blockchainType,
// verifying that 'multi' wallet chainType is never passed to TokenViewApi.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';

void main() {
  group('WalletServiceImpl — blockchain type resolution', () {
    // Mirrors the logic in wallet_service_impl.dart:getBalance
    String resolveBlockchainType(String coinType) {
      final chainConfig = chainUrlMap[coinType];
      return chainConfig?['baseInfo']?['blockchainType'] as String? ??
          'Ethereum';
    }

    test('N coin resolves to Ethereum blockchain', () {
      expect(resolveBlockchainType('N'), 'Ethereum');
    });

    test('BTC coin resolves to Bitcoin blockchain', () {
      expect(resolveBlockchainType('BTC'), 'Bitcoin');
    });

    test('ETH coin resolves to Ethereum blockchain', () {
      expect(resolveBlockchainType('ETH'), 'Ethereum');
    });

    test('SOL coin resolves to Solana blockchain', () {
      expect(resolveBlockchainType('SOL'), 'Solana');
    });

    test('TRX coin resolves to Tron blockchain', () {
      expect(resolveBlockchainType('TRX'), 'Tron');
    });

    test('DOT coin resolves to Polkadot blockchain', () {
      expect(resolveBlockchainType('DOT'), 'Polkadot');
    });

    test('ATOM coin resolves to Cosmos blockchain', () {
      expect(resolveBlockchainType('ATOM'), 'Cosmos');
    });

    test('FIL coin resolves to Filecoin blockchain', () {
      expect(resolveBlockchainType('FIL'), 'Filecoin');
    });

    test('unknown coin falls back to Ethereum', () {
      expect(resolveBlockchainType('NONEXISTENT'), 'Ethereum');
    });

    test('result is never "multi"', () {
      // Verify that no chain config returns 'multi' as blockchainType
      for (final entry in chainUrlMap.entries) {
        final bt = entry.value?['baseInfo']?['blockchainType'];
        if (bt != null) {
          expect(
            bt,
            isNot('multi'),
            reason: '${entry.key} blockchainType should not be "multi"',
          );
        }
      }
    });
  });

  group('chainUrlMap integrity', () {
    test('all entries have baseInfo.blockchainType', () {
      for (final entry in chainUrlMap.entries) {
        final baseInfo = entry.value['baseInfo'];
        expect(
          baseInfo,
          isNotNull,
          reason: '${entry.key} should have baseInfo',
        );
        expect(
          baseInfo['blockchainType'],
          isNotNull,
          reason: '${entry.key} should have blockchainType',
        );
        expect(
          baseInfo['blockchainType'],
          isA<String>(),
          reason: '${entry.key} blockchainType should be a String',
        );
      }
    });

    test('all entries have baseInfo.coinType', () {
      for (final entry in chainUrlMap.entries) {
        final coinType = entry.value['baseInfo']?['coinType'];
        expect(
          coinType,
          isNotNull,
          reason: '${entry.key} should have coinType',
        );
      }
    });

    test('all entries have baseInfo.decimals', () {
      for (final entry in chainUrlMap.entries) {
        final decimals = entry.value['baseInfo']?['decimals'];
        expect(
          decimals,
          isNotNull,
          reason: '${entry.key} should have decimals',
        );
        expect(
          decimals,
          isA<int>(),
          reason: '${entry.key} decimals should be int',
        );
        expect(
          decimals > 0,
          true,
          reason: '${entry.key} decimals should be positive',
        );
      }
    });
  });
}
