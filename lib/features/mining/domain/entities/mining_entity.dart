// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:equatable/equatable.dart';

/// Mining Session Entity
///
/// Represents an active or historical mining session.
class MiningSessionEntity extends Equatable {
  /// Session unique identifier
  final String id;

  /// Associated wallet address
  final String walletAddress;

  /// Mining plan ID
  final String planId;

  /// Session start time
  final DateTime startTime;

  /// Session end time (null if active)
  final DateTime? endTime;

  /// Current session status
  final MiningSessionStatus status;

  /// Total rewards earned in this session
  final double earnedRewards;

  /// Token symbol for rewards
  final String rewardTokenSymbol;

  /// Mining power/hashrate
  final double miningPower;

  const MiningSessionEntity({
    required this.id,
    required this.walletAddress,
    required this.planId,
    required this.startTime,
    this.endTime,
    required this.status,
    required this.earnedRewards,
    required this.rewardTokenSymbol,
    required this.miningPower,
  });

  /// Check if session is currently active
  bool get isActive => status == MiningSessionStatus.active;

  /// Get session duration
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// Get formatted duration string
  String get formattedDuration {
    final d = duration;
    if (d.inDays > 0) {
      return '${d.inDays}d ${d.inHours.remainder(24)}h';
    } else if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    } else {
      return '${d.inMinutes}m';
    }
  }

  @override
  List<Object?> get props => [
    id,
    walletAddress,
    planId,
    startTime,
    endTime,
    status,
    earnedRewards,
    rewardTokenSymbol,
    miningPower,
  ];
}

/// Mining Session Status
///
/// Describes the lifecycle state of a single [MiningSessionEntity].
/// Do NOT confuse with [MiningStatus] from the shared service interface,
/// which describes the overall mining service state.
enum MiningSessionStatus {
  /// Mining session is active
  active,

  /// Mining session is paused
  paused,

  /// Mining session completed
  completed,

  /// Mining session stopped due to error
  error,
}

/// Mining Plan Entity
class MiningPlanEntity extends Equatable {
  /// Plan unique identifier
  final String id;

  /// Plan name
  final String name;

  /// Plan description
  final String? description;

  /// Required stake amount
  final double stakeAmount;

  /// Stake token symbol
  final String stakeTokenSymbol;

  /// Daily reward rate (percentage)
  final double dailyRewardRate;

  /// Minimum mining duration in days
  final int minDurationDays;

  /// Maximum mining duration in days
  final int? maxDurationDays;

  /// Whether plan is currently available
  final bool isAvailable;

  /// Plan tier level
  final int tierLevel;

  const MiningPlanEntity({
    required this.id,
    required this.name,
    this.description,
    required this.stakeAmount,
    required this.stakeTokenSymbol,
    required this.dailyRewardRate,
    required this.minDurationDays,
    this.maxDurationDays,
    this.isAvailable = true,
    this.tierLevel = 1,
  });

  /// Get estimated monthly return
  double get estimatedMonthlyReturn => stakeAmount * dailyRewardRate * 30 / 100;

  /// Get estimated yearly return
  double get estimatedYearlyReturn => stakeAmount * dailyRewardRate * 365 / 100;

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    stakeAmount,
    stakeTokenSymbol,
    dailyRewardRate,
    minDurationDays,
    maxDurationDays,
    isAvailable,
    tierLevel,
  ];
}

/// Mining Reward Entity
class MiningRewardEntity extends Equatable {
  /// Reward ID
  final String id;

  /// Session ID this reward belongs to
  final String sessionId;

  /// Reward amount
  final double amount;

  /// Token symbol
  final String tokenSymbol;

  /// Reward timestamp
  final DateTime timestamp;

  /// Whether reward has been claimed
  final bool isClaimed;

  /// Claim transaction hash
  final String? claimTxHash;

  const MiningRewardEntity({
    required this.id,
    required this.sessionId,
    required this.amount,
    required this.tokenSymbol,
    required this.timestamp,
    this.isClaimed = false,
    this.claimTxHash,
  });

  @override
  List<Object?> get props => [
    id,
    sessionId,
    amount,
    tokenSymbol,
    timestamp,
    isClaimed,
    claimTxHash,
  ];
}

/// Full Node Entity
class FullNodeEntity extends Equatable {
  /// Node ID
  final String id;

  /// Node name
  final String name;

  /// Node status
  final NodeStatus status;

  /// Node uptime percentage
  final double uptimePercentage;

  /// Total rewards earned
  final double totalRewards;

  /// Node activation date
  final DateTime activatedAt;

  /// Node expiration date
  final DateTime? expiresAt;

  const FullNodeEntity({
    required this.id,
    required this.name,
    required this.status,
    required this.uptimePercentage,
    required this.totalRewards,
    required this.activatedAt,
    this.expiresAt,
  });

  /// Check if node is online
  bool get isOnline => status == NodeStatus.online;

  /// Days until expiration
  int? get daysUntilExpiration {
    if (expiresAt == null) return null;
    return expiresAt!.difference(DateTime.now()).inDays;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    status,
    uptimePercentage,
    totalRewards,
    activatedAt,
    expiresAt,
  ];
}

/// Node Status
enum NodeStatus { online, offline, syncing, error }

/// Mining Status Entity
///
/// Represents the current overall mining status for a wallet.
class MiningStatusEntity extends Equatable {
  /// Whether mining is currently active
  final bool isActive;

  /// Current active session (if any)
  final MiningSessionEntity? currentSession;

  /// Total hashrate/mining power
  final double totalPower;

  /// Last update time
  final DateTime lastUpdated;

  const MiningStatusEntity({
    required this.isActive,
    this.currentSession,
    required this.totalPower,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
    isActive,
    currentSession,
    totalPower,
    lastUpdated,
  ];
}

/// Mining Rewards Entity
///
/// Aggregated rewards information for a wallet.
class MiningRewardsEntity extends Equatable {
  /// Total earned rewards (all time)
  final double totalEarned;

  /// Claimable rewards (not yet claimed)
  final double claimableAmount;

  /// Claimed rewards
  final double claimedAmount;

  /// Token symbol
  final String tokenSymbol;

  /// List of individual rewards
  final List<MiningRewardEntity> rewards;

  const MiningRewardsEntity({
    required this.totalEarned,
    required this.claimableAmount,
    required this.claimedAmount,
    required this.tokenSymbol,
    this.rewards = const [],
  });

  @override
  List<Object?> get props => [
    totalEarned,
    claimableAmount,
    claimedAmount,
    tokenSymbol,
    rewards,
  ];
}

/// Mining Statistics Entity
///
/// Mining statistics and analytics for a wallet.
class MiningStatisticsEntity extends Equatable {
  /// Total mining sessions
  final int totalSessions;

  /// Total active days
  final int totalActiveDays;

  /// Average daily rewards
  final double averageDailyRewards;

  /// Best daily rewards
  final double bestDailyRewards;

  /// Total rewards earned
  final double totalRewards;

  /// Token symbol
  final String tokenSymbol;

  /// Mining start date
  final DateTime? miningStartDate;

  const MiningStatisticsEntity({
    required this.totalSessions,
    required this.totalActiveDays,
    required this.averageDailyRewards,
    required this.bestDailyRewards,
    required this.totalRewards,
    required this.tokenSymbol,
    this.miningStartDate,
  });

  @override
  List<Object?> get props => [
    totalSessions,
    totalActiveDays,
    averageDailyRewards,
    bestDailyRewards,
    totalRewards,
    tokenSymbol,
    miningStartDate,
  ];
}
