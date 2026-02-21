// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42appv2/src/earn/provider/earn_provider.dart';
import 'package:n42appv2/src/staking/models/staking_models.dart';

void main() {
  group('EarnState Tests', () {
    group('default values', () {
      test('should have correct default APY values', () {
        const state = EarnState();
        expect(state.ethApy, 4.0);
        expect(state.solApy, 7.0);
        expect(state.atomApy, 15.0);
      });

      test('should default to not loading', () {
        const state = EarnState();
        expect(state.apyLoading, false);
        expect(state.positionsLoading, false);
      });

      test('should default to empty positions', () {
        const state = EarnState();
        expect(state.activePositions, isEmpty);
      });
    });

    group('maxApy', () {
      test('should return the highest APY among the three chains', () {
        const state = EarnState(ethApy: 4.0, solApy: 7.0, atomApy: 15.0);
        expect(state.maxApy, 15.0);
      });

      test('should return ETH APY when it is highest', () {
        const state = EarnState(ethApy: 20.0, solApy: 7.0, atomApy: 15.0);
        expect(state.maxApy, 20.0);
      });

      test('should handle equal APY values', () {
        const state = EarnState(ethApy: 10.0, solApy: 10.0, atomApy: 10.0);
        expect(state.maxApy, 10.0);
      });
    });

    group('totalStakedRaw', () {
      test('should return zero for empty positions', () {
        const state = EarnState();
        expect(state.totalStakedRaw, BigInt.zero);
      });

      test('should sum all position staked amounts', () {
        final protocol = StakingProtocol(
          id: 'lido',
          name: 'Lido',
          description: 'Liquid ETH staking',
          chainType: StakingChainType.ethereum,
          chainSymbol: 'ETH',
          logoUri: '',
          apy: 4.0,
          minStakeAmount: 0.01,
          unbondingPeriodDays: 0,
          isLiquid: true,
          liquidTokenSymbol: 'stETH',
        );
        final p1 = StakingPosition(
          id: '1',
          protocol: protocol,
          stakedAmount: BigInt.from(1000000),
          rewardsEarned: BigInt.zero,
          pendingRewards: BigInt.zero,
          stakedAt: DateTime.now(),
          status: StakingPositionStatus.active,
        );
        final p2 = StakingPosition(
          id: '2',
          protocol: protocol,
          stakedAmount: BigInt.from(2000000),
          rewardsEarned: BigInt.zero,
          pendingRewards: BigInt.zero,
          stakedAt: DateTime.now(),
          status: StakingPositionStatus.active,
        );
        final state = EarnState(activePositions: [p1, p2]);
        expect(state.totalStakedRaw, BigInt.from(3000000));
      });
    });

    group('copyWith', () {
      test('should preserve unchanged fields', () {
        const original = EarnState(ethApy: 5.0, solApy: 8.0, atomApy: 12.0);
        final updated = original.copyWith(apyLoading: true);
        expect(updated.ethApy, 5.0);
        expect(updated.solApy, 8.0);
        expect(updated.atomApy, 12.0);
        expect(updated.apyLoading, true);
      });

      test('should update only specified fields', () {
        const original = EarnState();
        final updated = original.copyWith(ethApy: 6.5);
        expect(updated.ethApy, 6.5);
        expect(updated.solApy, original.solApy);
        expect(updated.atomApy, original.atomApy);
      });

      test('should be immutable — copyWith returns new instance', () {
        const original = EarnState();
        final updated = original.copyWith(ethApy: 99.0);
        expect(identical(original, updated), false);
        expect(original.ethApy, 4.0);
        expect(updated.ethApy, 99.0);
      });
    });
  });
}
