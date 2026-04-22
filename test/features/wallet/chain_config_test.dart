// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/utils/chain/chain_url_registry.dart';

// Alias for easier usage in tests
Map<String, dynamic> get all_chain => allChainUrlMap;

void main() {
  group('Chain Configuration Data Format Tests', () {
    test('all_chain should contain major CoinType entries', () {
      // Major coins that must have configurations
      final majorCoins = [
        'BTC', 'ETH', 'BNB', 'SOL', 'TRX', 'MATIC', 'N',
        'XLM', 'VET', 'ONE', 'IOTX', 'NEAR', 'ZIL', 'THETA', 'ADA', 'EGLD'
      ];

      for (final coin in majorCoins) {
        expect(
          all_chain.containsKey(coin),
          true,
          reason: 'all_chain should contain configuration for $coin',
        );
      }
    });

    test('chain config should have required baseInfo fields', () {
      final requiredFields = [
        'blockchainType',
        'coinType',
        'name',
        'miniName',
        'decimals',
        'path',
        'service',
      ];

      for (final entry in all_chain.entries) {
        final config = entry.value as Map<String, dynamic>;
        final baseInfo = config['baseInfo'] as Map<String, dynamic>?;

        expect(baseInfo, isNotNull,
            reason: '${entry.key} should have baseInfo');

        for (final field in requiredFields) {
          expect(
            baseInfo!.containsKey(field),
            true,
            reason: '${entry.key} baseInfo should contain $field',
          );
        }
      }
    });

    test('decimals should be valid for all chains', () {
      final expectedDecimals = {
        'BTC': 8,
        'ETH': 18,
        'BNB': 18,
        'SOL': 9,
        'TRX': 6,
        'XRP': 6,
        'XLM': 7,
        'VET': 18,
        'ONE': 18,
        'IOTX': 18,
        'NEAR': 24,
        'ZIL': 12,
        'THETA': 18,
        'ADA': 6,
        'EGLD': 18,
      };

      for (final entry in expectedDecimals.entries) {
        if (all_chain.containsKey(entry.key)) {
          final config = all_chain[entry.key] as Map<String, dynamic>;
          final baseInfo = config['baseInfo'] as Map<String, dynamic>;
          expect(
            baseInfo['decimals'],
            entry.value,
            reason: '${entry.key} should have ${entry.value} decimals',
          );
        }
      }
    });

    test('path should have valid derivation path format', () {
      // Different chains use different path formats:
      // - Standard BIP44: m/44'/coin'/account'/change/index
      // - Solana: m/44'/501'/account'
      // - Cardano CIP-1852: m/1852'/1815'/account'/change/index
      final pathPattern = RegExp(r"^m/\d+'(/\d+')*(/\d+)*$");

      for (final entry in all_chain.entries) {
        final config = entry.value as Map<String, dynamic>;
        final baseInfo = config['baseInfo'] as Map<String, dynamic>;
        final pathMap = baseInfo['path'] as Map<String, dynamic>?;

        if (pathMap != null && pathMap.isNotEmpty) {
          for (final pathEntry in pathMap.entries) {
            final path = pathEntry.value as String;
            expect(
              pathPattern.hasMatch(path),
              true,
              reason: '${entry.key} path "$path" should match derivation path format',
            );
          }
        }
      }
    });

    test('service URLs should be valid HTTPS', () {
      for (final entry in all_chain.entries) {
        final config = entry.value as Map<String, dynamic>;
        final baseInfo = config['baseInfo'] as Map<String, dynamic>;
        final service = baseInfo['service'] as String?;

        if (service != null && service.isNotEmpty) {
          expect(
            service.startsWith('http'),
            true,
            reason: '${entry.key} service URL should start with http(s)',
          );
        }
      }
    });
  });

  group('New Chain Configuration Tests - Batch 1', () {
    test('XLM (Stellar) configuration should be correct', () {
      expect(all_chain.containsKey('XLM'), true);
      final config = all_chain['XLM'] as Map<String, dynamic>;
      final baseInfo = config['baseInfo'] as Map<String, dynamic>;

      expect(baseInfo['blockchainType'], 'Stellar');
      expect(baseInfo['coinType'], 'XLM');
      expect(baseInfo['decimals'], 7);
      expect(baseInfo['name'], 'Stellar');
      expect(baseInfo['miniName'], 'XLM');
    });

    test('VET (VeChain) configuration should be correct', () {
      expect(all_chain.containsKey('VET'), true);
      final config = all_chain['VET'] as Map<String, dynamic>;
      final baseInfo = config['baseInfo'] as Map<String, dynamic>;

      expect(baseInfo['blockchainType'], 'VeChain');
      expect(baseInfo['coinType'], 'VET');
      expect(baseInfo['decimals'], 18);
      expect(baseInfo['name'], 'VeChain');
      expect(baseInfo['miniName'], 'VET');
    });

    test('ONE (Harmony) configuration should be correct', () {
      expect(all_chain.containsKey('ONE'), true);
      final config = all_chain['ONE'] as Map<String, dynamic>;
      final baseInfo = config['baseInfo'] as Map<String, dynamic>;

      // ONE is EVM compatible, uses Ethereum blockchain type for signing
      expect(baseInfo['blockchainType'], 'Ethereum');
      expect(baseInfo['coinType'], 'ONE');
      expect(baseInfo['decimals'], 18);
      expect(baseInfo['name'], 'Harmony');
      expect(baseInfo['miniName'], 'ONE');
    });

    test('IOTX (IoTeX) configuration should be correct', () {
      expect(all_chain.containsKey('IOTX'), true);
      final config = all_chain['IOTX'] as Map<String, dynamic>;
      final baseInfo = config['baseInfo'] as Map<String, dynamic>;

      // IOTX is EVM compatible, uses Ethereum blockchain type for signing
      expect(baseInfo['blockchainType'], 'Ethereum');
      expect(baseInfo['coinType'], 'IOTX');
      expect(baseInfo['decimals'], 18);
      expect(baseInfo['name'], 'IoTeX');
      expect(baseInfo['miniName'], 'IOTX');
    });
  });

  group('New Chain Configuration Tests - Batch 2', () {
    test('NEAR configuration should be correct', () {
      expect(all_chain.containsKey('NEAR'), true);
      final config = all_chain['NEAR'] as Map<String, dynamic>;
      final baseInfo = config['baseInfo'] as Map<String, dynamic>;

      expect(baseInfo['blockchainType'], 'Near');
      expect(baseInfo['coinType'], 'NEAR');
      expect(baseInfo['decimals'], 24);
      expect(baseInfo['name'], 'NEAR Protocol');
      expect(baseInfo['miniName'], 'NEAR');
    });

    test('ZIL (Zilliqa) configuration should be correct', () {
      expect(all_chain.containsKey('ZIL'), true);
      final config = all_chain['ZIL'] as Map<String, dynamic>;
      final baseInfo = config['baseInfo'] as Map<String, dynamic>;

      expect(baseInfo['blockchainType'], 'Zilliqa');
      expect(baseInfo['coinType'], 'ZIL');
      expect(baseInfo['decimals'], 12);
      expect(baseInfo['name'], 'Zilliqa');
      expect(baseInfo['miniName'], 'ZIL');
    });

    test('THETA configuration should be correct', () {
      expect(all_chain.containsKey('THETA'), true);
      final config = all_chain['THETA'] as Map<String, dynamic>;
      final baseInfo = config['baseInfo'] as Map<String, dynamic>;

      expect(baseInfo['blockchainType'], 'Theta');
      expect(baseInfo['coinType'], 'THETA');
      expect(baseInfo['decimals'], 18);
      expect(baseInfo['name'], 'Theta Network');
      expect(baseInfo['miniName'], 'THETA');
    });
  });

  group('New Chain Configuration Tests - Batch 3', () {
    test('ADA (Cardano) configuration should be correct', () {
      expect(all_chain.containsKey('ADA'), true);
      final config = all_chain['ADA'] as Map<String, dynamic>;
      final baseInfo = config['baseInfo'] as Map<String, dynamic>;

      expect(baseInfo['blockchainType'], 'Cardano');
      expect(baseInfo['coinType'], 'ADA');
      expect(baseInfo['decimals'], 6);
      expect(baseInfo['name'], 'Cardano');
      expect(baseInfo['miniName'], 'ADA');
    });

    test('EGLD (MultiversX) configuration should be correct', () {
      expect(all_chain.containsKey('EGLD'), true);
      final config = all_chain['EGLD'] as Map<String, dynamic>;
      final baseInfo = config['baseInfo'] as Map<String, dynamic>;

      expect(baseInfo['blockchainType'], 'MultiversX');
      expect(baseInfo['coinType'], 'EGLD');
      expect(baseInfo['decimals'], 18);
      expect(baseInfo['name'], 'MultiversX');
      expect(baseInfo['miniName'], 'EGLD');
      expect(baseInfo['rules'], 'ESDT'); // MultiversX token standard
    });
  });

  group('Chain Configuration Testnet Support', () {
    test('new chains should support testnet', () {
      final newChains = ['XLM', 'VET', 'ONE', 'IOTX', 'NEAR', 'ZIL', 'THETA', 'ADA', 'EGLD'];

      for (final chain in newChains) {
        if (all_chain.containsKey(chain)) {
          final config = all_chain[chain] as Map<String, dynamic>;
          expect(
            config['supportTest'],
            true,
            reason: '$chain should support testnet',
          );
        }
      }
    });

    test('testnet RPC URLs should be different from mainnet', () {
      final newChains = ['XLM', 'VET', 'ONE', 'IOTX', 'NEAR', 'ZIL', 'THETA', 'ADA', 'EGLD'];

      for (final chain in newChains) {
        if (all_chain.containsKey(chain)) {
          final config = all_chain[chain] as Map<String, dynamic>;
          final baseInfo = config['baseInfo'] as Map<String, dynamic>;
          final testnets = config['testnets'] as List?;

          if (testnets != null && testnets.isNotEmpty) {
            final testnetConfig = testnets[0] as Map<String, dynamic>;
            final mainnetService = baseInfo['service'] as String?;
            final testnetRPC = testnetConfig['testnetRPC'] as String?;

            if (mainnetService != null && testnetRPC != null &&
                mainnetService.isNotEmpty && testnetRPC.isNotEmpty) {
              expect(
                mainnetService != testnetRPC,
                true,
                reason: '$chain mainnet and testnet URLs should be different',
              );
            }
          }
        }
      }
    });
  });

  group('Chain Token Standards', () {
    test('EVM chains should have correct token rules', () {
      final evmChainsWithRules = {
        'ETH': 'ERC20',
        'BNB': 'BEP20',
        'MATIC': 'ERC20',
        'AVAX': 'ERC20',
        'ONE': 'HRC20',
        'IOTX': 'XRC20',
        'THETA': 'TNT20',
      };

      for (final entry in evmChainsWithRules.entries) {
        if (all_chain.containsKey(entry.key)) {
          final config = all_chain[entry.key] as Map<String, dynamic>;
          final baseInfo = config['baseInfo'] as Map<String, dynamic>;
          expect(
            baseInfo['rules'],
            entry.value,
            reason: '${entry.key} should have ${entry.value} token standard',
          );
        }
      }
    });

    test('MultiversX should support ESDT tokens', () {
      final config = all_chain['EGLD'] as Map<String, dynamic>;
      final baseInfo = config['baseInfo'] as Map<String, dynamic>;
      expect(baseInfo['rules'], 'ESDT');
    });
  });

  group('Derivation Path Tests', () {
    test('Stellar should use SEP-0005 path', () {
      final config = all_chain['XLM'] as Map<String, dynamic>;
      final baseInfo = config['baseInfo'] as Map<String, dynamic>;
      final pathMap = baseInfo['path'] as Map<String, dynamic>;
      final path = pathMap['legacy'] as String;

      // Stellar uses coin type 148
      expect(path.contains("148'"), true,
          reason: 'Stellar should use coin type 148');
    });

    test('VeChain should use BIP44 path', () {
      final config = all_chain['VET'] as Map<String, dynamic>;
      final baseInfo = config['baseInfo'] as Map<String, dynamic>;
      final pathMap = baseInfo['path'] as Map<String, dynamic>;
      final path = pathMap['legacy'] as String;

      // VeChain uses coin type 818
      expect(path.contains("818'"), true,
          reason: 'VeChain should use coin type 818');
    });

    test('NEAR should use BIP44 path', () {
      final config = all_chain['NEAR'] as Map<String, dynamic>;
      final baseInfo = config['baseInfo'] as Map<String, dynamic>;
      final pathMap = baseInfo['path'] as Map<String, dynamic>;
      final path = pathMap['legacy'] as String;

      // NEAR uses coin type 397
      expect(path.contains("397'"), true,
          reason: 'NEAR should use coin type 397');
    });

    test('Zilliqa should use BIP44 path', () {
      final config = all_chain['ZIL'] as Map<String, dynamic>;
      final baseInfo = config['baseInfo'] as Map<String, dynamic>;
      final pathMap = baseInfo['path'] as Map<String, dynamic>;
      final path = pathMap['legacy'] as String;

      // Zilliqa uses coin type 313
      expect(path.contains("313'"), true,
          reason: 'Zilliqa should use coin type 313');
    });

    test('Cardano should use CIP-1852 path', () {
      final config = all_chain['ADA'] as Map<String, dynamic>;
      final baseInfo = config['baseInfo'] as Map<String, dynamic>;
      final pathMap = baseInfo['path'] as Map<String, dynamic>;
      final path = pathMap['legacy'] as String;

      // Cardano uses purpose 1852 and coin type 1815
      expect(path.contains("1852'"), true,
          reason: 'Cardano should use purpose 1852');
      expect(path.contains("1815'"), true,
          reason: 'Cardano should use coin type 1815');
    });

    test('MultiversX should use BIP44 path', () {
      final config = all_chain['EGLD'] as Map<String, dynamic>;
      final baseInfo = config['baseInfo'] as Map<String, dynamic>;
      final pathMap = baseInfo['path'] as Map<String, dynamic>;
      final path = pathMap['legacy'] as String;

      // MultiversX uses coin type 508
      expect(path.contains("508'"), true,
          reason: 'MultiversX should use coin type 508');
    });
  });
}
