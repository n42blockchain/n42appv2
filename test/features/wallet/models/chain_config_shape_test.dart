// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/utils/chain/chain_url_registry.dart';

void main() {
  group('chain config shape compatibility', () {
    test('reads chain IDs from registry and runtime baseInfo shapes', () {
      final polygon = allChainUrlMap['MATIC']! as Map<String, dynamic>;
      final baseInfo = polygon['baseInfo'] as Map<String, dynamic>;

      expect(resolveChainConfigId(polygon), 137);
      expect(resolveChainConfigId(baseInfo), 137);
    });

    test('uses the configured testnet chain ID', () {
      final ethereum = allChainUrlMap['ETH']! as Map<String, dynamic>;
      final baseInfo = ethereum['baseInfo'] as Map<String, dynamic>;

      expect(
        resolveChainConfigId(ethereum, isTest: true),
        baseInfo['chainId_test'],
      );
      expect(
        resolveChainConfigId(baseInfo, isTest: true),
        baseInfo['chainId_test'],
      );
    });

    test('all EVM registry entries retain their nonzero chain ID', () {
      for (final entry in allChainUrlMap.entries) {
        final config = entry.value as Map<String, dynamic>;
        final baseInfo = config['baseInfo'] as Map<String, dynamic>;
        if (baseInfo['blockchainType'] != 'Ethereum') continue;

        expect(
          resolveChainConfigId(baseInfo),
          baseInfo['chainId'],
          reason: '${entry.key} runtime config must not fall back to chain 1',
        );
      }
    });

    test('missing testnet chain ID resolves to null, never to mainnet', () {
      // 测试网缺 chainId_test 时若回退主网值/1，签出的「测试网」交易在
      // 以太坊主网完全合法（可重放）。发送方据 null 拒发。
      final config = <String, dynamic>{'chainId': 56};
      expect(resolveChainConfigIdOrNull(config, isTest: true), isNull);
      expect(resolveChainConfigIdOrNull(config), 56);
      expect(resolveChainConfigIdOrNull(null), isNull);
      expect(
        resolveChainConfigIdOrNull(<String, dynamic>{
          'chainId': 56,
          'chainId_test': 97,
        }, isTest: true),
        97,
      );
    });

    test('Aptos config carries the real testnet chain ID', () {
      final apt = allChainUrlMap['APT']! as Map<String, dynamic>;
      expect(resolveChainConfigIdOrNull(apt, isTest: true), 2);
    });
  });
}
