// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42appv2/src/staking/models/staking_models.dart';

void main() {
  group('DOT Staking Feature Flag', () {
    // The feature flag value at compile-time is 'false' (default).
    // We test the filtering logic directly by simulating both states.

    test('when dotStakingEnabled=false, protocols exclude polkadot', () {
      const bool dotStakingEnabled =
          bool.fromEnvironment('FEATURE_DOT_STAKING', defaultValue: false);

      final protocols = dotStakingEnabled
          ? StakingProtocols.all
          : StakingProtocols.all
              .where((p) => p.chainType != StakingChainType.polkadot)
              .toList();

      // In test environment FEATURE_DOT_STAKING is not set, so it should be false.
      // Polkadot should be excluded.
      expect(
        protocols.any((p) => p.chainType == StakingChainType.polkadot),
        isFalse,
        reason: 'polkadot protocol must be excluded when flag is off',
      );
    });

    test('when dotStakingEnabled=false, all other chain protocols are retained', () {
      final filteredProtocols = StakingProtocols.all
          .where((p) => p.chainType != StakingChainType.polkadot)
          .toList();

      expect(
        filteredProtocols.any((p) => p.chainType == StakingChainType.ethereum),
        isTrue,
        reason: 'ethereum staking should be preserved',
      );
      expect(
        filteredProtocols.any((p) => p.chainType == StakingChainType.solana),
        isTrue,
        reason: 'solana staking should be preserved',
      );
      expect(
        filteredProtocols.any((p) => p.chainType == StakingChainType.cosmos),
        isTrue,
        reason: 'cosmos staking should be preserved',
      );
    });

    test('StakingProtocols.all contains exactly 4 protocols including polkadot', () {
      expect(StakingProtocols.all.length, 4);
      expect(
        StakingProtocols.all.where((p) => p.chainType == StakingChainType.polkadot).length,
        1,
      );
    });

    test('filter removes only polkadot, leaving 3 protocols', () {
      final filtered = StakingProtocols.all
          .where((p) => p.chainType != StakingChainType.polkadot)
          .toList();
      expect(filtered.length, 3);
    });
  });
}
