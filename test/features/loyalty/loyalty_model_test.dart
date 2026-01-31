// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42appv2/src/loyalty/models/loyalty_model.dart';

void main() {
  group('LoyaltyModel Tests', () {
    group('LoyaltyTier enum', () {
      test('should have correct tier order', () {
        expect(LoyaltyTier.values.length, 5);
        expect(LoyaltyTier.values[0], LoyaltyTier.bronze);
        expect(LoyaltyTier.values[1], LoyaltyTier.silver);
        expect(LoyaltyTier.values[2], LoyaltyTier.gold);
        expect(LoyaltyTier.values[3], LoyaltyTier.platinum);
        expect(LoyaltyTier.values[4], LoyaltyTier.diamond);
      });
    });

    group('TaskType enum', () {
      test('should have correct values', () {
        expect(TaskType.values.contains(TaskType.dailyCheckIn), true);
        expect(TaskType.values.contains(TaskType.transaction), true);
        expect(TaskType.values.contains(TaskType.referral), true);
        expect(TaskType.values.contains(TaskType.staking), true);
        expect(TaskType.values.contains(TaskType.dappUsage), true);
        expect(TaskType.values.contains(TaskType.social), true);
        expect(TaskType.values.contains(TaskType.special), true);
      });
    });

    group('TaskStatus enum', () {
      test('should have correct values', () {
        expect(TaskStatus.values.contains(TaskStatus.available), true);
        expect(TaskStatus.values.contains(TaskStatus.completed), true);
        expect(TaskStatus.values.contains(TaskStatus.expired), true);
        expect(TaskStatus.values.contains(TaskStatus.locked), true);
      });
    });

    group('RewardType enum', () {
      test('should have correct values', () {
        expect(RewardType.values.contains(RewardType.gasDiscount), true);
        expect(RewardType.values.contains(RewardType.feeDiscount), true);
        expect(RewardType.values.contains(RewardType.nft), true);
        expect(RewardType.values.contains(RewardType.token), true);
        expect(RewardType.values.contains(RewardType.membership), true);
        expect(RewardType.values.contains(RewardType.raffle), true);
        expect(RewardType.values.contains(RewardType.other), true);
      });
    });

    group('PointsAction enum', () {
      test('should have correct values', () {
        expect(PointsAction.values.contains(PointsAction.earn), true);
        expect(PointsAction.values.contains(PointsAction.spend), true);
        expect(PointsAction.values.contains(PointsAction.expire), true);
        expect(PointsAction.values.contains(PointsAction.adjust), true);
      });
    });

    group('ReferralStatus enum', () {
      test('should have correct values', () {
        expect(ReferralStatus.values.contains(ReferralStatus.pending), true);
        expect(ReferralStatus.values.contains(ReferralStatus.confirmed), true);
        expect(ReferralStatus.values.contains(ReferralStatus.invalid), true);
      });
    });

    group('LoyaltyAccount', () {
      test('should create empty account correctly', () {
        final emptyAccount = LoyaltyAccount.empty();

        expect(emptyAccount.odAddress, '');
        expect(emptyAccount.totalPoints, 0);
        expect(emptyAccount.availablePoints, 0);
        expect(emptyAccount.tier, LoyaltyTier.bronze);
      });

      test('should return correct tier name', () {
        final account = LoyaltyAccount(
          odAddress: '0x123',
          totalPoints: 1000,
          availablePoints: 1000,
          usedPoints: 0,
          tier: LoyaltyTier.gold,
          tierProgress: 50,
          nextTierPoints: 5000,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(account.tierName, 'Gold');
      });

      test('should return correct tier emoji', () {
        final bronzeAccount = LoyaltyAccount(
          odAddress: '0x123',
          totalPoints: 100,
          availablePoints: 100,
          usedPoints: 0,
          tier: LoyaltyTier.bronze,
          tierProgress: 10,
          nextTierPoints: 1000,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(bronzeAccount.tierEmoji, '🥉');
      });
    });

    group('LoyaltyTask', () {
      test('should detect if task can be completed', () {
        final availableTask = LoyaltyTask(
          id: 'task_1',
          title: 'Test Task',
          description: 'Test',
          type: TaskType.transaction,
          status: TaskStatus.available,
          points: 50,
        );

        expect(availableTask.canComplete, true);

        final completedTask = LoyaltyTask(
          id: 'task_2',
          title: 'Test Task',
          description: 'Test',
          type: TaskType.transaction,
          status: TaskStatus.completed,
          points: 50,
        );

        expect(completedTask.canComplete, false);
      });

      test('should respect max completions', () {
        final taskWithRemaining = LoyaltyTask(
          id: 'task_2',
          title: 'Limited Task',
          description: 'Test',
          type: TaskType.transaction,
          status: TaskStatus.available,
          points: 50,
          maxCompletions: 5,
          completedCount: 3,
        );

        expect(taskWithRemaining.canComplete, true);
        expect(taskWithRemaining.remainingCompletions, 2);
      });

      test('should return correct task icon', () {
        final checkInTask = LoyaltyTask(
          id: 'task_1',
          title: 'Check-in',
          description: 'Test',
          type: TaskType.dailyCheckIn,
          status: TaskStatus.available,
          points: 10,
        );

        expect(checkInTask.icon, '📅');
      });
    });

    group('Reward', () {
      test('should detect if reward can be redeemed', () {
        final availableReward = Reward(
          id: 'reward_1',
          name: 'Test Reward',
          description: 'Test',
          type: RewardType.gasDiscount,
          pointsCost: 100,
          isAvailable: true,
        );

        expect(availableReward.canRedeem, true);
      });
    });
  });

  group('Points Calculation Tests', () {
    test('should calculate tier progress correctly', () {
      const currentPoints = 1500;
      const currentTierThreshold = 1000;
      const nextTierThreshold = 2500;

      final progress = ((currentPoints - currentTierThreshold) /
              (nextTierThreshold - currentTierThreshold) *
              100)
          .toInt();

      expect(progress, 33);
    });

    test('should calculate points needed for next tier', () {
      const currentPoints = 1500;
      const nextTierThreshold = 2500;

      final pointsNeeded = nextTierThreshold - currentPoints;

      expect(pointsNeeded, 1000);
    });
  });
}
