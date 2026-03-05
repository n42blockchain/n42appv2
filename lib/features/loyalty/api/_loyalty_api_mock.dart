// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

part of 'loyalty_api.dart';

/// Mock 数据（开发环境降级使用）
extension LoyaltyApiMock on LoyaltyApi {
  LoyaltyAccount _getMockAccount(String walletAddress) {
    return LoyaltyAccount(
      odAddress: walletAddress,
      totalPoints: 1250,
      availablePoints: 1050,
      usedPoints: 200,
      tier: LoyaltyTier.silver,
      tierProgress: 65,
      nextTierPoints: 2000,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    );
  }

  List<LoyaltyTask> _getMockTasks() {
    final now = DateTime.now();
    return [
      LoyaltyTask(
        id: 'daily-checkin',
        title: 'Daily Check-in',
        description: 'Check in every day to earn points',
        type: TaskType.dailyCheckIn,
        status: TaskStatus.available,
        points: 10,
        maxCompletions: 1,
        completedCount: 0,
        expiresAt: DateTime(now.year, now.month, now.day, 23, 59, 59),
      ),
      LoyaltyTask(
        id: 'first-tx',
        title: 'Complete a Transaction',
        description: 'Send any token to earn points',
        type: TaskType.transaction,
        status: TaskStatus.available,
        points: 50,
        maxCompletions: 10,
        completedCount: 2,
      ),
      LoyaltyTask(
        id: 'invite-friend',
        title: 'Invite a Friend',
        description: 'Invite friends to join N42 wallet',
        type: TaskType.referral,
        status: TaskStatus.available,
        points: 100,
      ),
      LoyaltyTask(
        id: 'stake-eth',
        title: 'Stake ETH',
        description: 'Stake at least 0.1 ETH',
        type: TaskType.staking,
        status: TaskStatus.available,
        points: 200,
        maxCompletions: 1,
        completedCount: 0,
        requirements: {'min_amount': '0.1', 'token': 'ETH'},
        actionUrl: '/staking',
      ),
      LoyaltyTask(
        id: 'use-swap',
        title: 'Use Token Swap',
        description: 'Complete a swap transaction',
        type: TaskType.dappUsage,
        status: TaskStatus.available,
        points: 30,
        maxCompletions: 5,
        completedCount: 1,
      ),
      LoyaltyTask(
        id: 'follow-twitter',
        title: 'Follow on Twitter',
        description: 'Follow @N42_Official on Twitter',
        type: TaskType.social,
        status: TaskStatus.available,
        points: 20,
        maxCompletions: 1,
        completedCount: 0,
        actionUrl: 'https://twitter.com/N42_Official',
      ),
      LoyaltyTask(
        id: 'join-discord',
        title: 'Join Discord',
        description: 'Join N42 Discord community',
        type: TaskType.social,
        status: TaskStatus.completed,
        points: 20,
        maxCompletions: 1,
        completedCount: 1,
        lastCompletedAt: now.subtract(const Duration(days: 5)),
      ),
      LoyaltyTask(
        id: 'bridge-special',
        title: 'Bridge Week Special',
        description: 'Use cross-chain bridge during promotion',
        type: TaskType.special,
        status: TaskStatus.available,
        points: 150,
        maxCompletions: 3,
        completedCount: 0,
        expiresAt: now.add(const Duration(days: 7)),
      ),
      LoyaltyTask(
        id: 'weekly-trader',
        title: 'Weekly Trader',
        description: 'Complete 5 transactions in a single week',
        type: TaskType.transaction,
        status: TaskStatus.available,
        points: 80,
        maxCompletions: 4,
        completedCount: 1,
        expiresAt: now.add(const Duration(days: 5)),
        requirements: {'min_count': 5, 'period': 'week'},
      ),
      LoyaltyTask(
        id: 'use-bridge',
        title: 'Cross-Chain Bridge',
        description: 'Bridge assets to another network',
        type: TaskType.dappUsage,
        status: TaskStatus.available,
        points: 60,
        maxCompletions: 3,
        completedCount: 0,
        actionUrl: '/bridge',
      ),
      LoyaltyTask(
        id: 'join-telegram',
        title: 'Join Telegram Group',
        description: 'Join the N42 official Telegram community',
        type: TaskType.social,
        status: TaskStatus.available,
        points: 15,
        maxCompletions: 1,
        completedCount: 0,
        actionUrl: 'https://t.me/N42_Official',
      ),
      LoyaltyTask(
        id: 'portfolio-100',
        title: 'Portfolio Milestone',
        description: 'Hold assets worth at least \$100 in your wallet',
        type: TaskType.staking,
        status: TaskStatus.available,
        points: 50,
        maxCompletions: 1,
        completedCount: 0,
        requirements: {'min_usd_value': 100},
      ),
    ];
  }

  List<PointsHistory> _getMockHistory() {
    final now = DateTime.now();
    return [
      PointsHistory(
        id: '1',
        action: PointsAction.earn,
        points: 10,
        description: 'Daily check-in',
        taskId: 'daily-checkin',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      PointsHistory(
        id: '2',
        action: PointsAction.earn,
        points: 50,
        description: 'Completed transaction',
        taskId: 'first-tx',
        txHash: '0x123...abc',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      PointsHistory(
        id: '3',
        action: PointsAction.spend,
        points: -200,
        description: 'Redeemed: Gas Fee Discount',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      PointsHistory(
        id: '4',
        action: PointsAction.earn,
        points: 100,
        description: 'Referral bonus',
        taskId: 'invite-friend',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      PointsHistory(
        id: '5',
        action: PointsAction.earn,
        points: 20,
        description: 'Joined Discord',
        taskId: 'join-discord',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
    ];
  }

  List<Reward> _getMockRewards() {
    return [
      Reward(
        id: 'gas-50',
        name: '50% Gas Fee Discount',
        description: 'Get 50% off on your next transaction gas fee',
        type: RewardType.gasDiscount,
        pointsCost: 200,
        userLimit: 5,
        userRedeemed: 1,
        isAvailable: true,
      ),
      Reward(
        id: 'gas-free',
        name: 'Free Gas Transaction',
        description: 'One free gas transaction (up to 0.01 ETH)',
        type: RewardType.gasDiscount,
        pointsCost: 500,
        stock: 100,
        userLimit: 2,
        userRedeemed: 0,
        isAvailable: true,
      ),
      Reward(
        id: 'fee-discount',
        name: 'Trading Fee Discount',
        description: '30% off swap fees for 7 days',
        type: RewardType.feeDiscount,
        pointsCost: 300,
        isAvailable: true,
      ),
      Reward(
        id: 'nft-og',
        name: 'N42 OG Badge NFT',
        description: 'Exclusive NFT badge for early supporters',
        type: RewardType.nft,
        pointsCost: 1000,
        stock: 500,
        userLimit: 1,
        userRedeemed: 0,
        isAvailable: true,
      ),
      Reward(
        id: 'raffle-iphone',
        name: 'iPhone Raffle Ticket',
        description: 'Enter the monthly iPhone giveaway',
        type: RewardType.raffle,
        pointsCost: 100,
        expiresAt: DateTime.now().add(const Duration(days: 30)),
        isAvailable: true,
      ),
      Reward(
        id: 'premium-1m',
        name: 'Premium Membership (1 Month)',
        description: 'Unlock premium features for 1 month',
        type: RewardType.membership,
        pointsCost: 800,
        isAvailable: true,
      ),
    ];
  }

  List<PointsRule> _getMockRules() {
    return [
      PointsRule(
        id: 'rule-checkin',
        name: 'Daily Check-in',
        description: 'Check in every day to earn points',
        taskType: TaskType.dailyCheckIn,
        points: 10,
        dailyLimit: 1,
        isActive: true,
      ),
      PointsRule(
        id: 'rule-tx',
        name: 'Complete Transaction',
        description: 'Earn points for each transaction',
        taskType: TaskType.transaction,
        points: 50,
        dailyLimit: 10,
        isActive: true,
      ),
      PointsRule(
        id: 'rule-referral',
        name: 'Invite Friends',
        description: 'Earn points when friends join and complete first tx',
        taskType: TaskType.referral,
        points: 100,
        isActive: true,
      ),
      PointsRule(
        id: 'rule-staking',
        name: 'Staking Rewards',
        description: 'Earn points for staking assets',
        taskType: TaskType.staking,
        points: 200,
        totalLimit: 5,
        isActive: true,
      ),
      PointsRule(
        id: 'rule-social',
        name: 'Social Tasks',
        description: 'Follow and engage with N42 social media',
        taskType: TaskType.social,
        points: 20,
        isActive: true,
      ),
    ];
  }
}
