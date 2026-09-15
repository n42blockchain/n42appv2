// Tests for mining_entity.dart — pure Equatable entity classes and enums.
// Covers: MiningSessionStatus, NodeStatus enums; MiningSessionEntity (duration,
// formattedDuration, isActive); MiningPlanEntity (monthly/yearly return);
// MiningRewardEntity; FullNodeEntity (isOnline, daysUntilExpiration);
// MiningStatusEntity; MiningRewardsEntity; MiningStatisticsEntity.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/mining/domain/entities/mining_entity.dart';

void main() {
  // ─────────────────────────────────────────────────
  // MiningStatus enum
  // ─────────────────────────────────────────────────

  group('MiningSessionStatus enum', () {
    test('contains all four expected values', () {
      expect(
        MiningSessionStatus.values,
        containsAll([
          MiningSessionStatus.active,
          MiningSessionStatus.paused,
          MiningSessionStatus.completed,
          MiningSessionStatus.error,
        ]),
      );
    });

    test('four values total', () {
      expect(MiningSessionStatus.values.length, 4);
    });
  });

  // ─────────────────────────────────────────────────
  // NodeStatus enum
  // ─────────────────────────────────────────────────

  group('NodeStatus enum', () {
    test('has all four values', () {
      expect(NodeStatus.values.length, 4);
    });

    test('values: online, offline, syncing, error', () {
      expect(
        NodeStatus.values,
        containsAll([
          NodeStatus.online,
          NodeStatus.offline,
          NodeStatus.syncing,
          NodeStatus.error,
        ]),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // MiningSessionEntity
  // ─────────────────────────────────────────────────

  group('MiningSessionEntity constructor', () {
    final start = DateTime.utc(2024, 1, 1, 8, 0);

    test('stores required fields', () {
      final e = MiningSessionEntity(
        id: 'sess1',
        walletAddress: '0xABC',
        planId: 'plan1',
        startTime: start,
        status: MiningSessionStatus.active,
        earnedRewards: 5.0,
        rewardTokenSymbol: 'N42',
        miningPower: 100.0,
      );
      expect(e.id, 'sess1');
      expect(e.walletAddress, '0xABC');
      expect(e.planId, 'plan1');
      expect(e.startTime, start);
      expect(e.status, MiningSessionStatus.active);
      expect(e.earnedRewards, 5.0);
      expect(e.rewardTokenSymbol, 'N42');
      expect(e.miningPower, 100.0);
    });

    test('endTime defaults to null', () {
      final e = MiningSessionEntity(
        id: 's',
        walletAddress: '0x',
        planId: 'p',
        startTime: start,
        status: MiningSessionStatus.active,
        earnedRewards: 0,
        rewardTokenSymbol: 'TK',
        miningPower: 1.0,
      );
      expect(e.endTime, isNull);
    });

    test('stores endTime when provided', () {
      final end = DateTime.utc(2024, 1, 1, 10, 0);
      final e = MiningSessionEntity(
        id: 's',
        walletAddress: '0x',
        planId: 'p',
        startTime: start,
        endTime: end,
        status: MiningSessionStatus.completed,
        earnedRewards: 10.0,
        rewardTokenSymbol: 'N42',
        miningPower: 100.0,
      );
      expect(e.endTime, end);
    });
  });

  group('MiningSessionEntity.isActive', () {
    final start = DateTime.utc(2024, 1, 1);

    test('true when status is active', () {
      final e = MiningSessionEntity(
        id: 's',
        walletAddress: '0x',
        planId: 'p',
        startTime: start,
        status: MiningSessionStatus.active,
        earnedRewards: 0,
        rewardTokenSymbol: 'T',
        miningPower: 1.0,
      );
      expect(e.isActive, isTrue);
    });

    test('false when status is completed', () {
      final e = MiningSessionEntity(
        id: 's',
        walletAddress: '0x',
        planId: 'p',
        startTime: start,
        status: MiningSessionStatus.completed,
        earnedRewards: 0,
        rewardTokenSymbol: 'T',
        miningPower: 1.0,
      );
      expect(e.isActive, isFalse);
    });

    test('false when status is paused', () {
      final e = MiningSessionEntity(
        id: 's',
        walletAddress: '0x',
        planId: 'p',
        startTime: start,
        status: MiningSessionStatus.paused,
        earnedRewards: 0,
        rewardTokenSymbol: 'T',
        miningPower: 1.0,
      );
      expect(e.isActive, isFalse);
    });

    test('false when status is error', () {
      final e = MiningSessionEntity(
        id: 's',
        walletAddress: '0x',
        planId: 'p',
        startTime: start,
        status: MiningSessionStatus.error,
        earnedRewards: 0,
        rewardTokenSymbol: 'T',
        miningPower: 1.0,
      );
      expect(e.isActive, isFalse);
    });
  });

  group('MiningSessionEntity.duration and formattedDuration', () {
    test('duration uses endTime when provided', () {
      final start = DateTime.utc(2024, 1, 1, 8, 0);
      final end = DateTime.utc(2024, 1, 1, 10, 30);
      final e = MiningSessionEntity(
        id: 's',
        walletAddress: '0x',
        planId: 'p',
        startTime: start,
        endTime: end,
        status: MiningSessionStatus.completed,
        earnedRewards: 0,
        rewardTokenSymbol: 'T',
        miningPower: 1.0,
      );
      expect(e.duration, equals(const Duration(hours: 2, minutes: 30)));
    });

    test('formattedDuration shows hours and minutes when < 1 day', () {
      final start = DateTime.utc(2024, 1, 1, 8, 0);
      final end = DateTime.utc(2024, 1, 1, 11, 45);
      final e = MiningSessionEntity(
        id: 's',
        walletAddress: '0x',
        planId: 'p',
        startTime: start,
        endTime: end,
        status: MiningSessionStatus.completed,
        earnedRewards: 0,
        rewardTokenSymbol: 'T',
        miningPower: 1.0,
      );
      expect(e.formattedDuration, '3h 45m');
    });

    test('formattedDuration shows days when >= 1 day', () {
      final start = DateTime.utc(2024, 1, 1);
      final end = DateTime.utc(2024, 1, 3, 5, 0); // 2d 5h
      final e = MiningSessionEntity(
        id: 's',
        walletAddress: '0x',
        planId: 'p',
        startTime: start,
        endTime: end,
        status: MiningSessionStatus.completed,
        earnedRewards: 0,
        rewardTokenSymbol: 'T',
        miningPower: 1.0,
      );
      expect(e.formattedDuration, '2d 5h');
    });

    test('formattedDuration shows minutes when < 1 hour', () {
      final start = DateTime.utc(2024, 1, 1, 12, 0);
      final end = DateTime.utc(2024, 1, 1, 12, 45);
      final e = MiningSessionEntity(
        id: 's',
        walletAddress: '0x',
        planId: 'p',
        startTime: start,
        endTime: end,
        status: MiningSessionStatus.completed,
        earnedRewards: 0,
        rewardTokenSymbol: 'T',
        miningPower: 1.0,
      );
      expect(e.formattedDuration, '45m');
    });
  });

  group('MiningSessionEntity equality', () {
    final start = DateTime.utc(2024, 1, 1);

    MiningSessionEntity make(String id) => MiningSessionEntity(
      id: id,
      walletAddress: '0x',
      planId: 'p',
      startTime: start,
      status: MiningSessionStatus.active,
      earnedRewards: 1.0,
      rewardTokenSymbol: 'T',
      miningPower: 50.0,
    );

    test('same id → equal', () {
      expect(make('s1'), equals(make('s1')));
    });

    test('different id → not equal', () {
      expect(make('s1'), isNot(equals(make('s2'))));
    });
  });

  // ─────────────────────────────────────────────────
  // MiningPlanEntity
  // ─────────────────────────────────────────────────

  group('MiningPlanEntity', () {
    const plan = MiningPlanEntity(
      id: 'plan1',
      name: 'Gold Plan',
      stakeAmount: 1000.0,
      stakeTokenSymbol: 'N42',
      dailyRewardRate: 1.0, // 1% per day
      minDurationDays: 30,
    );

    test('stores required fields', () {
      expect(plan.id, 'plan1');
      expect(plan.name, 'Gold Plan');
      expect(plan.stakeAmount, 1000.0);
      expect(plan.stakeTokenSymbol, 'N42');
      expect(plan.dailyRewardRate, 1.0);
      expect(plan.minDurationDays, 30);
    });

    test('description defaults to null', () {
      expect(plan.description, isNull);
    });

    test('maxDurationDays defaults to null', () {
      expect(plan.maxDurationDays, isNull);
    });

    test('isAvailable defaults to true', () {
      expect(plan.isAvailable, isTrue);
    });

    test('tierLevel defaults to 1', () {
      expect(plan.tierLevel, 1);
    });

    test('estimatedMonthlyReturn = stakeAmount * dailyRate * 30 / 100', () {
      // 1000 * 1.0 * 30 / 100 = 300
      expect(plan.estimatedMonthlyReturn, closeTo(300.0, 0.001));
    });

    test('estimatedYearlyReturn = stakeAmount * dailyRate * 365 / 100', () {
      // 1000 * 1.0 * 365 / 100 = 3650
      expect(plan.estimatedYearlyReturn, closeTo(3650.0, 0.001));
    });

    test('same fields → equal', () {
      expect(
        const MiningPlanEntity(
          id: 'p',
          name: 'N',
          stakeAmount: 100.0,
          stakeTokenSymbol: 'T',
          dailyRewardRate: 0.5,
          minDurationDays: 7,
        ),
        equals(
          const MiningPlanEntity(
            id: 'p',
            name: 'N',
            stakeAmount: 100.0,
            stakeTokenSymbol: 'T',
            dailyRewardRate: 0.5,
            minDurationDays: 7,
          ),
        ),
      );
    });

    test('different id → not equal', () {
      expect(
        const MiningPlanEntity(
          id: 'p1',
          name: 'N',
          stakeAmount: 100.0,
          stakeTokenSymbol: 'T',
          dailyRewardRate: 0.5,
          minDurationDays: 7,
        ),
        isNot(
          equals(
            const MiningPlanEntity(
              id: 'p2',
              name: 'N',
              stakeAmount: 100.0,
              stakeTokenSymbol: 'T',
              dailyRewardRate: 0.5,
              minDurationDays: 7,
            ),
          ),
        ),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // MiningRewardEntity
  // ─────────────────────────────────────────────────

  group('MiningRewardEntity', () {
    final ts = DateTime.utc(2024, 6, 1, 12, 0);

    test('stores required fields', () {
      final e = MiningRewardEntity(
        id: 'r1',
        sessionId: 'sess1',
        amount: 2.5,
        tokenSymbol: 'N42',
        timestamp: ts,
      );
      expect(e.id, 'r1');
      expect(e.sessionId, 'sess1');
      expect(e.amount, 2.5);
      expect(e.tokenSymbol, 'N42');
      expect(e.timestamp, ts);
    });

    test('isClaimed defaults to false', () {
      final e = MiningRewardEntity(
        id: 'r',
        sessionId: 's',
        amount: 1.0,
        tokenSymbol: 'T',
        timestamp: ts,
      );
      expect(e.isClaimed, isFalse);
    });

    test('claimTxHash defaults to null', () {
      final e = MiningRewardEntity(
        id: 'r',
        sessionId: 's',
        amount: 1.0,
        tokenSymbol: 'T',
        timestamp: ts,
      );
      expect(e.claimTxHash, isNull);
    });

    test('stores isClaimed and claimTxHash when provided', () {
      final e = MiningRewardEntity(
        id: 'r',
        sessionId: 's',
        amount: 1.0,
        tokenSymbol: 'T',
        timestamp: ts,
        isClaimed: true,
        claimTxHash: '0xtx',
      );
      expect(e.isClaimed, isTrue);
      expect(e.claimTxHash, '0xtx');
    });

    test('same fields → equal', () {
      final a = MiningRewardEntity(
        id: 'r',
        sessionId: 's',
        amount: 1.0,
        tokenSymbol: 'T',
        timestamp: ts,
      );
      final b = MiningRewardEntity(
        id: 'r',
        sessionId: 's',
        amount: 1.0,
        tokenSymbol: 'T',
        timestamp: ts,
      );
      expect(a, equals(b));
    });

    test('different amount → not equal', () {
      final a = MiningRewardEntity(
        id: 'r',
        sessionId: 's',
        amount: 1.0,
        tokenSymbol: 'T',
        timestamp: ts,
      );
      final b = MiningRewardEntity(
        id: 'r',
        sessionId: 's',
        amount: 2.0,
        tokenSymbol: 'T',
        timestamp: ts,
      );
      expect(a, isNot(equals(b)));
    });
  });

  // ─────────────────────────────────────────────────
  // FullNodeEntity
  // ─────────────────────────────────────────────────

  group('FullNodeEntity', () {
    final activated = DateTime.utc(2024, 1, 1);

    test('stores required fields', () {
      final e = FullNodeEntity(
        id: 'node1',
        name: 'My Node',
        status: NodeStatus.online,
        uptimePercentage: 99.5,
        totalRewards: 100.0,
        activatedAt: activated,
      );
      expect(e.id, 'node1');
      expect(e.name, 'My Node');
      expect(e.status, NodeStatus.online);
      expect(e.uptimePercentage, 99.5);
      expect(e.totalRewards, 100.0);
      expect(e.activatedAt, activated);
    });

    test('expiresAt defaults to null', () {
      final e = FullNodeEntity(
        id: 'n',
        name: 'N',
        status: NodeStatus.offline,
        uptimePercentage: 0,
        totalRewards: 0,
        activatedAt: activated,
      );
      expect(e.expiresAt, isNull);
    });

    test('isOnline is true when status is online', () {
      final e = FullNodeEntity(
        id: 'n',
        name: 'N',
        status: NodeStatus.online,
        uptimePercentage: 100,
        totalRewards: 0,
        activatedAt: activated,
      );
      expect(e.isOnline, isTrue);
    });

    test('isOnline is false when status is offline', () {
      final e = FullNodeEntity(
        id: 'n',
        name: 'N',
        status: NodeStatus.offline,
        uptimePercentage: 0,
        totalRewards: 0,
        activatedAt: activated,
      );
      expect(e.isOnline, isFalse);
    });

    test('daysUntilExpiration is null when expiresAt is null', () {
      final e = FullNodeEntity(
        id: 'n',
        name: 'N',
        status: NodeStatus.online,
        uptimePercentage: 100,
        totalRewards: 0,
        activatedAt: activated,
      );
      expect(e.daysUntilExpiration, isNull);
    });

    test('daysUntilExpiration returns positive days for future expiresAt', () {
      // Use a fixed far-future date so the test is deterministic regardless
      // of when it runs. 10000 days from epoch is well past any reasonable
      // test execution time.
      final farFuture = DateTime.utc(2100, 1, 1);
      final e = FullNodeEntity(
        id: 'n',
        name: 'N',
        status: NodeStatus.online,
        uptimePercentage: 100,
        totalRewards: 0,
        activatedAt: activated,
        expiresAt: farFuture,
      );
      expect(e.daysUntilExpiration, isNotNull);
      expect(e.daysUntilExpiration!, greaterThan(0));
    });

    test('daysUntilExpiration returns 0 or negative for past expiresAt', () {
      final yesterday = DateTime.utc(2000, 1, 1); // far in the past
      final e = FullNodeEntity(
        id: 'n',
        name: 'N',
        status: NodeStatus.online,
        uptimePercentage: 100,
        totalRewards: 0,
        activatedAt: activated,
        expiresAt: yesterday,
      );
      expect(e.daysUntilExpiration!, lessThanOrEqualTo(0));
    });

    test('same fields → equal', () {
      final a = FullNodeEntity(
        id: 'n',
        name: 'N',
        status: NodeStatus.online,
        uptimePercentage: 99.0,
        totalRewards: 10.0,
        activatedAt: activated,
      );
      final b = FullNodeEntity(
        id: 'n',
        name: 'N',
        status: NodeStatus.online,
        uptimePercentage: 99.0,
        totalRewards: 10.0,
        activatedAt: activated,
      );
      expect(a, equals(b));
    });

    test('different status → not equal', () {
      final a = FullNodeEntity(
        id: 'n',
        name: 'N',
        status: NodeStatus.online,
        uptimePercentage: 99.0,
        totalRewards: 10.0,
        activatedAt: activated,
      );
      final b = FullNodeEntity(
        id: 'n',
        name: 'N',
        status: NodeStatus.offline,
        uptimePercentage: 99.0,
        totalRewards: 10.0,
        activatedAt: activated,
      );
      expect(a, isNot(equals(b)));
    });
  });

  // ─────────────────────────────────────────────────
  // MiningStatusEntity
  // ─────────────────────────────────────────────────

  group('MiningStatusEntity', () {
    final updated = DateTime.utc(2024, 6, 1);

    test('stores isActive, totalPower, lastUpdated', () {
      final e = MiningStatusEntity(
        isActive: true,
        totalPower: 500.0,
        lastUpdated: updated,
      );
      expect(e.isActive, isTrue);
      expect(e.totalPower, 500.0);
      expect(e.lastUpdated, updated);
    });

    test('currentSession defaults to null', () {
      final e = MiningStatusEntity(
        isActive: false,
        totalPower: 0,
        lastUpdated: updated,
      );
      expect(e.currentSession, isNull);
    });

    test('same fields → equal', () {
      final a = MiningStatusEntity(
        isActive: false,
        totalPower: 0,
        lastUpdated: updated,
      );
      final b = MiningStatusEntity(
        isActive: false,
        totalPower: 0,
        lastUpdated: updated,
      );
      expect(a, equals(b));
    });
  });

  // ─────────────────────────────────────────────────
  // MiningRewardsEntity
  // ─────────────────────────────────────────────────

  group('MiningRewardsEntity', () {
    const e = MiningRewardsEntity(
      totalEarned: 100.0,
      claimableAmount: 30.0,
      claimedAmount: 70.0,
      tokenSymbol: 'N42',
    );

    test('stores reward fields', () {
      expect(e.totalEarned, 100.0);
      expect(e.claimableAmount, 30.0);
      expect(e.claimedAmount, 70.0);
      expect(e.tokenSymbol, 'N42');
    });

    test('rewards defaults to empty list', () {
      expect(e.rewards, isEmpty);
    });

    test('same fields → equal', () {
      const a = MiningRewardsEntity(
        totalEarned: 50.0,
        claimableAmount: 10.0,
        claimedAmount: 40.0,
        tokenSymbol: 'T',
      );
      const b = MiningRewardsEntity(
        totalEarned: 50.0,
        claimableAmount: 10.0,
        claimedAmount: 40.0,
        tokenSymbol: 'T',
      );
      expect(a, equals(b));
    });

    test('different totalEarned → not equal', () {
      const a = MiningRewardsEntity(
        totalEarned: 50.0,
        claimableAmount: 0,
        claimedAmount: 0,
        tokenSymbol: 'T',
      );
      const b = MiningRewardsEntity(
        totalEarned: 60.0,
        claimableAmount: 0,
        claimedAmount: 0,
        tokenSymbol: 'T',
      );
      expect(a, isNot(equals(b)));
    });
  });

  // ─────────────────────────────────────────────────
  // MiningStatisticsEntity
  // ─────────────────────────────────────────────────

  group('MiningStatisticsEntity', () {
    const e = MiningStatisticsEntity(
      totalSessions: 10,
      totalActiveDays: 30,
      averageDailyRewards: 5.0,
      bestDailyRewards: 12.0,
      totalRewards: 150.0,
      tokenSymbol: 'N42',
    );

    test('stores all fields', () {
      expect(e.totalSessions, 10);
      expect(e.totalActiveDays, 30);
      expect(e.averageDailyRewards, 5.0);
      expect(e.bestDailyRewards, 12.0);
      expect(e.totalRewards, 150.0);
      expect(e.tokenSymbol, 'N42');
    });

    test('miningStartDate defaults to null', () {
      expect(e.miningStartDate, isNull);
    });

    test('stores miningStartDate when provided', () {
      final date = DateTime.utc(2024, 1, 1);
      final e2 = MiningStatisticsEntity(
        totalSessions: 1,
        totalActiveDays: 1,
        averageDailyRewards: 1.0,
        bestDailyRewards: 1.0,
        totalRewards: 1.0,
        tokenSymbol: 'T',
        miningStartDate: date,
      );
      expect(e2.miningStartDate, date);
    });

    test('same fields → equal', () {
      const a = MiningStatisticsEntity(
        totalSessions: 5,
        totalActiveDays: 10,
        averageDailyRewards: 2.0,
        bestDailyRewards: 5.0,
        totalRewards: 20.0,
        tokenSymbol: 'T',
      );
      const b = MiningStatisticsEntity(
        totalSessions: 5,
        totalActiveDays: 10,
        averageDailyRewards: 2.0,
        bestDailyRewards: 5.0,
        totalRewards: 20.0,
        tokenSymbol: 'T',
      );
      expect(a, equals(b));
    });
  });
}
