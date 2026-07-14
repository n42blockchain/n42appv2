// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/sender/cosmos_sender.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';

void main() {
  group('usesConfiguredCosmosRest', () {
    test('keeps ATOM on its dedicated API', () {
      expect(
        usesConfiguredCosmosRest('ATOM', 'https://rest.cosmos.directory'),
        isFalse,
      );
    });

    test('routes other Cosmos chains to their configured REST endpoint', () {
      expect(
        usesConfiguredCosmosRest('OSMO', 'https://osmosis-rest.publicnode.com'),
        isTrue,
      );
      expect(
        usesConfiguredCosmosRest(
          'inj',
          'https://rest.cosmos.directory/injective',
        ),
        isTrue,
      );
    });

    test('rejects empty configured endpoints', () {
      expect(usesConfiguredCosmosRest('TIA', ''), isFalse);
      expect(usesConfiguredCosmosRest('DYDX', '  '), isFalse);
    });

    test('every default non-ATOM Cosmos chain has a REST endpoint', () {
      for (final entry in chainUrlMap.entries) {
        final config = entry.value as Map<String, dynamic>;
        final baseInfo = config['baseInfo'] as Map<String, dynamic>;
        if (baseInfo['blockchainType'] != 'Cosmos' || entry.key == 'ATOM') {
          continue;
        }
        final service = CoinConfigView(baseInfo).service;
        expect(
          usesConfiguredCosmosRest(entry.key, service),
          isTrue,
          reason: '${entry.key} must not fall back to the ATOM API',
        );
      }
    });
  });
}
