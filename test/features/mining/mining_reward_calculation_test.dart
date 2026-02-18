// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// T-6: Tests for miningCalculateReward pure function
//
// The function is in lib/src/miningV2/utils/mining_utils.dart and uses only
// dart:math — no platform dependencies.

import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:n42appv2/src/miningV2/utils/mining_utils.dart';

void main() {
  group('miningCalculateReward — pure math function', () {
    // Default params from the function signature:
    //   effectiveBalance = 32_000_000_000 (32 ETH in Gwei)
    //   baseRewardsPerEpoch = 1.0
    //   baseRewardFactor = 1.0

    group('nominal behaviour', () {
      test('typical mainnet total balance returns positive reward', () {
        // totalEffectiveBalance ≈ 15_000_000 ETH in Gwei on mainnet
        const totalBalance = 15000000 * 1000000000; // ~1.5e16
        final reward = miningCalculateReward(totalBalance);

        expect(reward, greaterThan(0));
      });

      test('reward decreases as totalEffectiveBalance grows (inverse sqrt)', () {
        final rewardSmall = miningCalculateReward(1000000);
        final rewardLarge = miningCalculateReward(4000000);

        // sqrt(4x) = 2*sqrt(x), so reward halves
        expect(rewardSmall, greaterThan(rewardLarge));
      });

      test('reward = effectiveBalance/sqrt(total) for default params', () {
        const total = 1000000;
        const effective = 32000000000;
        final expected = (effective / math.sqrt(total.toDouble())).toInt();
        final result = miningCalculateReward(total);

        expect(result, expected);
      });

      test('larger effectiveBalance produces proportionally larger reward', () {
        const total = 1000000;
        final rewardDefault = miningCalculateReward(total);
        final rewardDouble = miningCalculateReward(
          total,
          effectiveBalance: 64000000000, // 2×
        );

        // Should be approximately 2×
        expect(rewardDouble, closeTo(rewardDefault * 2, rewardDefault * 0.01));
      });

      test('higher baseRewardFactor produces proportionally higher reward', () {
        const total = 1000000;
        final rewardBase1 = miningCalculateReward(total, baseRewardFactor: 1.0);
        final rewardBase2 = miningCalculateReward(total, baseRewardFactor: 2.0);

        expect(rewardBase2, closeTo(rewardBase1 * 2, rewardBase1 * 0.01));
      });

      test('higher baseRewardsPerEpoch reduces reward proportionally', () {
        const total = 1000000;
        final rewardEpoch1 =
            miningCalculateReward(total, baseRewardsPerEpoch: 1.0);
        final rewardEpoch2 =
            miningCalculateReward(total, baseRewardsPerEpoch: 2.0);

        expect(rewardEpoch2, closeTo(rewardEpoch1 ~/ 2, 1));
      });
    });

    group('edge cases', () {
      test('totalEffectiveBalance=1 does not divide by zero', () {
        // sqrt(1)=1, so reward = effectiveBalance/1 = effectiveBalance
        final reward = miningCalculateReward(1);
        expect(reward, isNonNegative);
      });

      test('totalEffectiveBalance very large (no integer overflow)', () {
        // Use a representative large value
        const bigTotal = 1000000000000000; // 1e15
        expect(
          () => miningCalculateReward(bigTotal),
          returnsNormally,
        );
        final reward = miningCalculateReward(bigTotal);
        expect(reward, isNonNegative);
      });

      test('effectiveBalance=0 returns 0', () {
        final reward = miningCalculateReward(1000000, effectiveBalance: 0);
        expect(reward, 0);
      });

      test('baseRewardFactor=0 returns 0', () {
        final reward =
            miningCalculateReward(1000000, baseRewardFactor: 0.0);
        expect(reward, 0);
      });
    });

    group('return type', () {
      test('returns an int (truncated, not rounded)', () {
        final result = miningCalculateReward(1000000);
        expect(result, isA<int>());
      });

      test('fractional part is truncated (floor semantics)', () {
        // Choose values that produce a non-integer intermediate result
        // reward = (32e9 * 1) / sqrt(3) ≈ 18475208614.86...  → 18475208614
        const total = 3;
        final result = miningCalculateReward(total);
        final exact = (32000000000.0 / math.sqrt(3.0));
        expect(result, exact.toInt());
      });
    });
  });
}
