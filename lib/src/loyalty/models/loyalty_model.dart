// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

/// 用户积分等级
enum LoyaltyTier {
  bronze,
  silver,
  gold,
  platinum,
  diamond,
}

/// 任务类型
enum TaskType {
  /// 每日签到
  dailyCheckIn,
  /// 完成交易
  transaction,
  /// 邀请好友
  referral,
  /// 质押
  staking,
  /// 使用 DApp
  dappUsage,
  /// 社交任务
  social,
  /// 特殊活动
  special,
}

/// 任务状态
enum TaskStatus {
  /// 可完成
  available,
  /// 已完成
  completed,
  /// 已过期
  expired,
  /// 锁定
  locked,
}

/// 用户积分账户
class LoyaltyAccount {
  final String odAddress;
  final int totalPoints;
  final int availablePoints;
  final int usedPoints;
  final LoyaltyTier tier;
  final int tierProgress; // 0-100 到下一等级的进度
  final int nextTierPoints; // 升级所需积分
  final DateTime createdAt;
  final DateTime updatedAt;

  LoyaltyAccount({
    required this.odAddress,
    required this.totalPoints,
    required this.availablePoints,
    required this.usedPoints,
    required this.tier,
    required this.tierProgress,
    required this.nextTierPoints,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 等级名称
  String get tierName {
    switch (tier) {
      case LoyaltyTier.bronze:
        return 'Bronze';
      case LoyaltyTier.silver:
        return 'Silver';
      case LoyaltyTier.gold:
        return 'Gold';
      case LoyaltyTier.platinum:
        return 'Platinum';
      case LoyaltyTier.diamond:
        return 'Diamond';
    }
  }

  /// 等级图标 emoji
  String get tierEmoji {
    switch (tier) {
      case LoyaltyTier.bronze:
        return '🥉';
      case LoyaltyTier.silver:
        return '🥈';
      case LoyaltyTier.gold:
        return '🥇';
      case LoyaltyTier.platinum:
        return '💎';
      case LoyaltyTier.diamond:
        return '👑';
    }
  }

  factory LoyaltyAccount.fromJson(Map<String, dynamic> json) {
    return LoyaltyAccount(
      odAddress: json['wallet_address'] ?? '',
      totalPoints: json['total_points'] ?? 0,
      availablePoints: json['available_points'] ?? 0,
      usedPoints: json['used_points'] ?? 0,
      tier: LoyaltyTier.values.firstWhere(
        (e) => e.name == json['tier'],
        orElse: () => LoyaltyTier.bronze,
      ),
      tierProgress: json['tier_progress'] ?? 0,
      nextTierPoints: json['next_tier_points'] ?? 1000,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  factory LoyaltyAccount.empty() {
    return LoyaltyAccount(
      odAddress: '',
      totalPoints: 0,
      availablePoints: 0,
      usedPoints: 0,
      tier: LoyaltyTier.bronze,
      tierProgress: 0,
      nextTierPoints: 1000,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

/// 积分任务
class LoyaltyTask {
  final String id;
  final String title;
  final String description;
  final TaskType type;
  final TaskStatus status;
  final int points;
  final int? maxCompletions; // 最大完成次数（null 表示无限）
  final int completedCount;
  final DateTime? expiresAt;
  final DateTime? lastCompletedAt;
  final Map<String, dynamic>? requirements;
  final String? actionUrl;

  LoyaltyTask({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.points,
    this.maxCompletions,
    this.completedCount = 0,
    this.expiresAt,
    this.lastCompletedAt,
    this.requirements,
    this.actionUrl,
  });

  /// 是否可完成
  bool get canComplete {
    if (status != TaskStatus.available) return false;
    if (maxCompletions != null && completedCount >= maxCompletions!) return false;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) return false;
    return true;
  }

  /// 剩余完成次数
  int? get remainingCompletions {
    if (maxCompletions == null) return null;
    return maxCompletions! - completedCount;
  }

  /// 任务图标
  String get icon {
    switch (type) {
      case TaskType.dailyCheckIn:
        return '📅';
      case TaskType.transaction:
        return '💸';
      case TaskType.referral:
        return '👥';
      case TaskType.staking:
        return '🔒';
      case TaskType.dappUsage:
        return '📱';
      case TaskType.social:
        return '🐦';
      case TaskType.special:
        return '⭐';
    }
  }

  factory LoyaltyTask.fromJson(Map<String, dynamic> json) {
    return LoyaltyTask(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: TaskType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TaskType.special,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.available,
      ),
      points: json['points'] ?? 0,
      maxCompletions: json['max_completions'],
      completedCount: json['completed_count'] ?? 0,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      lastCompletedAt: json['last_completed_at'] != null
          ? DateTime.parse(json['last_completed_at'])
          : null,
      requirements: json['requirements'],
      actionUrl: json['action_url'],
    );
  }
}

/// 积分历史记录
class PointsHistory {
  final String id;
  final PointsAction action;
  final int points;
  final String description;
  final String? taskId;
  final String? txHash;
  final DateTime createdAt;

  PointsHistory({
    required this.id,
    required this.action,
    required this.points,
    required this.description,
    this.taskId,
    this.txHash,
    required this.createdAt,
  });

  factory PointsHistory.fromJson(Map<String, dynamic> json) {
    return PointsHistory(
      id: json['id'] ?? '',
      action: PointsAction.values.firstWhere(
        (e) => e.name == json['action'],
        orElse: () => PointsAction.earn,
      ),
      points: json['points'] ?? 0,
      description: json['description'] ?? '',
      taskId: json['task_id'],
      txHash: json['tx_hash'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}

/// 积分操作类型
enum PointsAction {
  /// 获得
  earn,
  /// 消费
  spend,
  /// 过期
  expire,
  /// 调整
  adjust,
}

/// 奖励商品
class Reward {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final RewardType type;
  final int pointsCost;
  final int? stock; // null 表示无限
  final int? userLimit; // 每用户限制
  final int userRedeemed; // 用户已兑换数量
  final DateTime? expiresAt;
  final bool isAvailable;

  Reward({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.type,
    required this.pointsCost,
    this.stock,
    this.userLimit,
    this.userRedeemed = 0,
    this.expiresAt,
    required this.isAvailable,
  });

  /// 是否可兑换
  bool get canRedeem {
    if (!isAvailable) return false;
    if (stock != null && stock! <= 0) return false;
    if (userLimit != null && userRedeemed >= userLimit!) return false;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) return false;
    return true;
  }

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'],
      type: RewardType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RewardType.other,
      ),
      pointsCost: json['points_cost'] ?? 0,
      stock: json['stock'],
      userLimit: json['user_limit'],
      userRedeemed: json['user_redeemed'] ?? 0,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      isAvailable: json['is_available'] ?? true,
    );
  }
}

/// 奖励类型
enum RewardType {
  /// Gas 费减免
  gasDiscount,
  /// 交易费折扣
  feeDiscount,
  /// NFT
  nft,
  /// 代币
  token,
  /// 会员权益
  membership,
  /// 抽奖券
  raffle,
  /// 其他
  other,
}

/// 邀请记录
class ReferralRecord {
  final String id;
  final String referredAddress;
  final String? referredName;
  final int pointsEarned;
  final ReferralStatus status;
  final DateTime createdAt;

  ReferralRecord({
    required this.id,
    required this.referredAddress,
    this.referredName,
    required this.pointsEarned,
    required this.status,
    required this.createdAt,
  });

  factory ReferralRecord.fromJson(Map<String, dynamic> json) {
    return ReferralRecord(
      id: json['id'] ?? '',
      referredAddress: json['referred_address'] ?? '',
      referredName: json['referred_name'],
      pointsEarned: json['points_earned'] ?? 0,
      status: ReferralStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReferralStatus.pending,
      ),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}

/// 邀请状态
enum ReferralStatus {
  /// 待确认
  pending,
  /// 已确认
  confirmed,
  /// 已失效
  invalid,
}

/// 积分规则
class PointsRule {
  final String id;
  final String name;
  final String description;
  final TaskType taskType;
  final int points;
  final int? dailyLimit;
  final int? totalLimit;
  final bool isActive;

  PointsRule({
    required this.id,
    required this.name,
    required this.description,
    required this.taskType,
    required this.points,
    this.dailyLimit,
    this.totalLimit,
    required this.isActive,
  });

  factory PointsRule.fromJson(Map<String, dynamic> json) {
    return PointsRule(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      taskType: TaskType.values.firstWhere(
        (e) => e.name == json['task_type'],
        orElse: () => TaskType.special,
      ),
      points: json['points'] ?? 0,
      dailyLimit: json['daily_limit'],
      totalLimit: json['total_limit'],
      isActive: json['is_active'] ?? true,
    );
  }
}
