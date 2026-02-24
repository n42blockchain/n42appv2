// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/aa/core/aa_config.dart';

void main() {
  group('EntryPointVersion Tests', () {
    test('should have v07 and v08 versions', () {
      expect(EntryPointVersion.values.length, 2);
      expect(EntryPointVersion.values.contains(EntryPointVersion.v07), true);
      expect(EntryPointVersion.values.contains(EntryPointVersion.v08), true);
    });

    test('default version should be v08', () {
      expect(AAConfig.defaultVersion, EntryPointVersion.v08);
    });
  });

  group('AAConfig EntryPoint Address Tests', () {
    test('v0.7 EntryPoint address should be correct', () {
      expect(
        AAConfig.entryPointV07,
        '0x0000000071727De22E5E9d8BAf0edAc6f37da032',
      );
    });

    test('v0.8 EntryPoint address should be correct', () {
      expect(
        AAConfig.entryPointV08,
        '0x4337084D9E255Ff0702461CF8895CE9E3b5Ff108',
      );
    });

    test('getEntryPoint should return v0.8 by default', () {
      expect(AAConfig.getEntryPoint(), AAConfig.entryPointV08);
    });

    test('getEntryPoint should return correct address for specified version', () {
      expect(
        AAConfig.getEntryPoint(version: EntryPointVersion.v07),
        AAConfig.entryPointV07,
      );
      expect(
        AAConfig.getEntryPoint(version: EntryPointVersion.v08),
        AAConfig.entryPointV08,
      );
    });
  });

  group('AAConfig Factory Address Tests', () {
    test('SimpleAccount factory addresses should be defined', () {
      expect(AAConfig.simpleAccountFactoryV07.isNotEmpty, true);
      expect(AAConfig.simpleAccountFactoryV08.isNotEmpty, true);
    });

    test('Simple7702Account factory should be defined', () {
      expect(AAConfig.simple7702AccountFactory.isNotEmpty, true);
      expect(
        AAConfig.simple7702AccountFactory.startsWith('0x'),
        true,
      );
    });

    test('getSimpleAccountFactory should return correct address', () {
      expect(
        AAConfig.getSimpleAccountFactory(version: EntryPointVersion.v07),
        AAConfig.simpleAccountFactoryV07,
      );
      expect(
        AAConfig.getSimpleAccountFactory(version: EntryPointVersion.v08),
        AAConfig.simpleAccountFactoryV08,
      );
    });
  });

  group('AAConfig Supported Chains Tests', () {
    test('should support major EVM chains', () {
      expect(AAConfig.supportedChains.contains('ETH'), true);
      expect(AAConfig.supportedChains.contains('BASE'), true);
      expect(AAConfig.supportedChains.contains('ARB'), true);
      expect(AAConfig.supportedChains.contains('OP'), true);
      expect(AAConfig.supportedChains.contains('MATIC'), true);
    });

    test('isChainSupported should work correctly', () {
      expect(AAConfig.isChainSupported('ETH'), true);
      expect(AAConfig.isChainSupported('eth'), true); // case insensitive
      expect(AAConfig.isChainSupported('INVALID'), false);
    });

    test('chain IDs should be correct', () {
      expect(AAConfig.chainIds['ETH'], 1);
      expect(AAConfig.chainIds['BASE'], 8453);
      expect(AAConfig.chainIds['ARB'], 42161);
      expect(AAConfig.chainIds['OP'], 10);
      expect(AAConfig.chainIds['MATIC'], 137);
    });
  });

  group('AAConfig Bundler URLs Tests', () {
    test('all supported chains should have bundler URLs', () {
      for (final chain in AAConfig.supportedChains) {
        expect(
          AAConfig.bundlerUrls.containsKey(chain),
          true,
          reason: '$chain should have bundler URL',
        );
      }
    });

    test('bundler URLs should be valid HTTPS', () {
      for (final url in AAConfig.bundlerUrls.values) {
        expect(url.startsWith('https://'), true);
      }
    });

    test('backup bundler URLs should exist', () {
      for (final chain in AAConfig.supportedChains) {
        expect(
          AAConfig.backupBundlerUrls.containsKey(chain),
          true,
          reason: '$chain should have backup bundler URL',
        );
      }
    });
  });

  group('AAConfig getChainConfig Tests', () {
    test('should return config for supported chains', () {
      final config = AAConfig.getChainConfig('ETH');
      expect(config, isNotNull);
      expect(config!.chainId, 1);
      expect(config.entryPoint.isNotEmpty, true);
    });

    test('should return null for unsupported chains', () {
      final config = AAConfig.getChainConfig('INVALID');
      expect(config, isNull);
    });

    test('should return correct version-specific config', () {
      final v07Config = AAConfig.getChainConfig('ETH', version: EntryPointVersion.v07);
      final v08Config = AAConfig.getChainConfig('ETH', version: EntryPointVersion.v08);

      expect(v07Config!.entryPoint, AAConfig.entryPointV07);
      expect(v08Config!.entryPoint, AAConfig.entryPointV08);
    });

    test('should handle case insensitive chain symbols', () {
      final config1 = AAConfig.getChainConfig('eth');
      final config2 = AAConfig.getChainConfig('ETH');

      expect(config1, isNotNull);
      expect(config2, isNotNull);
      expect(config1!.chainId, config2!.chainId);
    });
  });

  group('AAConfig Testnet Tests', () {
    test('should have testnet configurations', () {
      expect(AAConfig.testnetConfigs.isNotEmpty, true);
    });

    test('SEPOLIA testnet should be configured', () {
      final config = AAConfig.getTestnetConfig('SEPOLIA');
      expect(config, isNotNull);
      expect(config!.chainId, 11155111);
    });

    test('BASE_SEPOLIA testnet should be configured', () {
      final config = AAConfig.getTestnetConfig('BASE_SEPOLIA');
      expect(config, isNotNull);
      expect(config!.chainId, 84532);
    });

    test('getTestnetConfig should respect version parameter', () {
      final v07Config = AAConfig.getTestnetConfig('SEPOLIA', version: EntryPointVersion.v07);
      final v08Config = AAConfig.getTestnetConfig('SEPOLIA', version: EntryPointVersion.v08);

      expect(v07Config!.entryPoint, AAConfig.entryPointV07);
      expect(v08Config!.entryPoint, AAConfig.entryPointV08);
    });
  });

  group('AAChainConfig Tests', () {
    test('should create config with all required fields', () {
      final config = AAChainConfig(
        chainId: 1,
        bundlerUrl: 'https://example.com/bundler',
        entryPoint: AAConfig.entryPointV08,
        simpleAccountFactory: AAConfig.simpleAccountFactoryV08,
      );

      expect(config.chainId, 1);
      expect(config.bundlerUrl, 'https://example.com/bundler');
      expect(config.entryPoint, AAConfig.entryPointV08);
    });

    test('supportsEIP7702 should be true for v0.8', () {
      final v08Config = AAChainConfig(
        chainId: 1,
        bundlerUrl: 'https://example.com',
        entryPoint: AAConfig.entryPointV08,
        simpleAccountFactory: AAConfig.simpleAccountFactoryV08,
        version: EntryPointVersion.v08,
      );

      final v07Config = AAChainConfig(
        chainId: 1,
        bundlerUrl: 'https://example.com',
        entryPoint: AAConfig.entryPointV07,
        simpleAccountFactory: AAConfig.simpleAccountFactoryV07,
        version: EntryPointVersion.v07,
      );

      expect(v08Config.supportsEIP7702, true);
      expect(v07Config.supportsEIP7702, false);
    });

    test('simple7702AccountFactory should only be available for v0.8', () {
      final v08Config = AAChainConfig(
        chainId: 1,
        bundlerUrl: 'https://example.com',
        entryPoint: AAConfig.entryPointV08,
        simpleAccountFactory: AAConfig.simpleAccountFactoryV08,
        version: EntryPointVersion.v08,
      );

      final v07Config = AAChainConfig(
        chainId: 1,
        bundlerUrl: 'https://example.com',
        entryPoint: AAConfig.entryPointV07,
        simpleAccountFactory: AAConfig.simpleAccountFactoryV07,
        version: EntryPointVersion.v07,
      );

      expect(v08Config.simple7702AccountFactory, isNotNull);
      expect(v07Config.simple7702AccountFactory, isNull);
    });

    test('getBundlerUrlWithKey returns bundlerUrl regardless of key (deprecated: key via Authorization header)', () {
      final config = AAChainConfig(
        chainId: 1,
        bundlerUrl: 'https://example.com/bundler',
        entryPoint: AAConfig.entryPointV08,
        simpleAccountFactory: AAConfig.simpleAccountFactoryV08,
      );

      expect(
        config.getBundlerUrlWithKey(null),
        'https://example.com/bundler',
      );
      expect(
        config.getBundlerUrlWithKey(''),
        'https://example.com/bundler',
      );
      expect(
        config.getBundlerUrlWithKey('myapikey'),
        'https://example.com/bundler',
      );
    });
  });
}
