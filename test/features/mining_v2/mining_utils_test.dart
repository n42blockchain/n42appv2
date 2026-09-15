// Copyright 2021-2026 N42 Inc. All rights reserved.
//
// Tests for the beacon-chain reward calculation formula used by mining v2.
//
//   reward = (effective_balance * base_reward_factor) /
//            (sqrt(total_effective_balance) * base_rewards_per_epoch)
//
// This is the canonical Eth2-style validator reward formula. The mining
// dashboard shows the result of this function as the projected
// per-epoch reward; an off-by-one in the formula manifests as a wrong
// APR estimate on the staking page (real, visible UI regression).

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/mining_v2/utils/mining_utils.dart';

void main() {
  group('miningCalculateReward', () {
    // Default validator effective balance is 32 N (= 32e9 in 9-decimal
    // beacon units). The default base reward factor and per-epoch
    // divisor are both 1, so the formula simplifies to:
    //   reward = 32e9 / sqrt(total_effective_balance)
    const defaultEffectiveBalance = 32000000000;

    test('with 1 validator (total == self), reward == sqrt(EB)', () {
      // total = 32e9, sqrt ≈ 178885.4, reward ≈ 32e9/178885.4 ≈ 178885
      final r = miningCalculateReward(defaultEffectiveBalance);
      final expected = (defaultEffectiveBalance / sqrt(defaultEffectiveBalance))
          .toInt();
      expect(r, expected);
    });

    test(
      'reward decreases as total_effective_balance grows (inverse sqrt)',
      () {
        // Doubling the network's total stake should drop the per-validator
        // reward by a factor of sqrt(2).
        final base = miningCalculateReward(defaultEffectiveBalance);
        final doubled = miningCalculateReward(defaultEffectiveBalance * 2);
        expect(
          doubled,
          lessThan(base),
          reason: 'larger total should reduce per-validator reward',
        );

        // sqrt(2) ≈ 1.414, so ratio base/doubled should be ~1.414.
        // Use a loose band to tolerate the int truncation.
        final ratio = base / doubled;
        expect(ratio, greaterThan(1.30));
        expect(ratio, lessThan(1.55));
      },
    );

    test('larger effective_balance produces proportionally larger reward', () {
      const big = 64000000000; // 64 N
      final defaultReward = miningCalculateReward(
        big,
        effectiveBalance: defaultEffectiveBalance,
      );
      final doubledReward = miningCalculateReward(
        big,
        effectiveBalance: defaultEffectiveBalance * 2,
      );
      // reward is linear in effectiveBalance with all else equal.
      expect(doubledReward, defaultReward * 2);
    });

    test('baseRewardFactor scales the reward linearly', () {
      const total = 64000000000;
      final r1 = miningCalculateReward(total, baseRewardFactor: 1);
      final r2 = miningCalculateReward(total, baseRewardFactor: 2);
      final r4 = miningCalculateReward(total, baseRewardFactor: 4);
      expect(r2, r1 * 2);
      expect(r4, r1 * 4);
    });

    test('baseRewardsPerEpoch divides the reward inversely', () {
      const total = 64000000000;
      final r1 = miningCalculateReward(total, baseRewardsPerEpoch: 1);
      final r2 = miningCalculateReward(total, baseRewardsPerEpoch: 2);
      final r4 = miningCalculateReward(total, baseRewardsPerEpoch: 4);
      expect(r2, r1 ~/ 2);
      expect(r4, r1 ~/ 4);
    });

    test('1024-validator network yields a small but positive reward', () {
      // Sanity check around realistic network sizes.
      const oneValidator = 32000000000;
      const totalEffective = oneValidator * 1024;
      final r = miningCalculateReward(totalEffective);
      expect(r, greaterThan(0));
      expect(
        r,
        lessThan(oneValidator),
        reason: 'reward should never exceed the validators own EB',
      );
    });

    test('matches reference formula across a sweep of total balances', () {
      // Spot-check the function output against an independent computation
      // for several total-balance points.
      const sweepPoints = [
        32000000000, // 1 validator
        320000000000, // 10 validators
        3200000000000, // 100 validators
        32000000000000, // 1000 validators
      ];
      for (final total in sweepPoints) {
        final got = miningCalculateReward(total);
        final reference = (defaultEffectiveBalance / sqrt(total)).toInt();
        expect(got, reference, reason: 'total=$total');
      }
    });

    test('does not divide by zero for tiny but non-zero total', () {
      // The function does sqrt(total) in the divisor; total=1 is the
      // smallest realistic input (1 wei effective balance).
      final r = miningCalculateReward(1, effectiveBalance: 1);
      // Formula: 1 * 1 / (sqrt(1) * 1) = 1
      expect(r, 1);
    });
  });
}
