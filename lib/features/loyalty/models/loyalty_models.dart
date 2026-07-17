// Copyright 2021-2026 N42 Inc. All rights reserved.

enum LoyaltyTier { bronze, silver, gold, platinum, diamond }

class LoyaltyAccount {
  const LoyaltyAccount({
    required this.totalPoints,
    required this.availablePoints,
    required this.usedPoints,
    required this.tier,
    required this.tierProgress,
    required this.nextTierPoints,
  });

  const LoyaltyAccount.empty()
    : totalPoints = 0,
      availablePoints = 0,
      usedPoints = 0,
      tier = LoyaltyTier.bronze,
      tierProgress = 0,
      nextTierPoints = 1000;

  final int totalPoints;
  final int availablePoints;
  final int usedPoints;
  final LoyaltyTier tier;
  final int tierProgress;
  final int nextTierPoints;

  factory LoyaltyAccount.fromJson(Map<String, dynamic> json) {
    return LoyaltyAccount(
      totalPoints: _integer(json['total_points']),
      availablePoints: _integer(json['available_points']),
      usedPoints: _integer(json['used_points']),
      tier: LoyaltyTier.values.firstWhere(
        (tier) => tier.name == json['tier']?.toString().toLowerCase(),
        orElse: () => LoyaltyTier.bronze,
      ),
      tierProgress: _integer(json['tier_progress']).clamp(0, 100),
      nextTierPoints: _integer(json['next_tier_points'], fallback: 1000),
    );
  }

  LoyaltyAccount addPoints(int points) => LoyaltyAccount(
    totalPoints: totalPoints + points,
    availablePoints: availablePoints + points,
    usedPoints: usedPoints,
    tier: tier,
    tierProgress: tierProgress,
    nextTierPoints: nextTierPoints,
  );
}

enum LoyaltyTaskStatus { available, completed, locked, expired }

class LoyaltyTask {
  const LoyaltyTask({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.status,
  });

  final String id;
  final String title;
  final String description;
  final int points;
  final LoyaltyTaskStatus status;

  bool get canComplete => status == LoyaltyTaskStatus.available;

  factory LoyaltyTask.fromJson(Map<String, dynamic> json) => LoyaltyTask(
    id: _text(json['id']),
    title: _text(json['title']),
    description: _text(json['description']),
    points: _integer(json['points']),
    status: LoyaltyTaskStatus.values.firstWhere(
      (status) => status.name == json['status']?.toString().toLowerCase(),
      orElse: () => LoyaltyTaskStatus.available,
    ),
  );
}

class LoyaltyReward {
  const LoyaltyReward({
    required this.id,
    required this.name,
    required this.description,
    required this.pointsCost,
    required this.isAvailable,
  });

  final String id;
  final String name;
  final String description;
  final int pointsCost;
  final bool isAvailable;

  factory LoyaltyReward.fromJson(Map<String, dynamic> json) => LoyaltyReward(
    id: _text(json['id']),
    name: _text(json['name']),
    description: _text(json['description']),
    pointsCost: _integer(json['points_cost']),
    isAvailable: json['is_available'] as bool? ?? true,
  );
}

class LoyaltyHistoryItem {
  const LoyaltyHistoryItem({
    required this.id,
    required this.description,
    required this.points,
    required this.createdAt,
  });

  final String id;
  final String description;
  final int points;
  final DateTime? createdAt;

  factory LoyaltyHistoryItem.fromJson(Map<String, dynamic> json) {
    final action = json['action']?.toString().toLowerCase();
    final rawPoints = _integer(json['points']);
    final signedPoints = action == 'spend' || action == 'expire'
        ? -rawPoints.abs()
        : rawPoints;
    return LoyaltyHistoryItem(
      id: _text(json['id']),
      description: _text(json['description']),
      points: signedPoints,
      createdAt: DateTime.tryParse(_text(json['created_at']))?.toLocal(),
    );
  }
}

class LoyaltySnapshot {
  const LoyaltySnapshot({
    required this.account,
    required this.tasks,
    required this.rewards,
    required this.history,
    required this.referrals,
    required this.leaderboard,
  });

  final LoyaltyAccount account;
  final List<LoyaltyTask> tasks;
  final List<LoyaltyReward> rewards;
  final List<LoyaltyHistoryItem> history;
  final List<LoyaltyReferral> referrals;
  final List<LoyaltyLeaderboardEntry> leaderboard;

  bool get checkedInToday => tasks.any(
    (task) =>
        task.id == 'daily-checkin' &&
        task.status == LoyaltyTaskStatus.completed,
  );
}

class LoyaltyReferral {
  const LoyaltyReferral({
    required this.address,
    required this.pointsEarned,
    required this.createdAt,
  });

  final String address;
  final int pointsEarned;
  final DateTime? createdAt;

  factory LoyaltyReferral.fromJson(Map<String, dynamic> json) {
    return LoyaltyReferral(
      address: _text(
        json['referred_address'] ?? json['wallet_address'] ?? json['address'],
      ),
      pointsEarned: _integer(json['points_earned']),
      createdAt: DateTime.tryParse(_text(json['created_at']))?.toLocal(),
    );
  }
}

class LoyaltyLeaderboardEntry {
  const LoyaltyLeaderboardEntry({
    required this.rank,
    required this.address,
    required this.points,
  });

  final int rank;
  final String address;
  final int points;

  factory LoyaltyLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LoyaltyLeaderboardEntry(
      rank: _integer(json['rank']),
      address: _text(json['wallet_address'] ?? json['address']),
      points: _integer(json['points'] ?? json['available_points']),
    );
  }
}

class LoyaltyCheckInResult {
  const LoyaltyCheckInResult({required this.points, this.transactionHash});

  final int points;
  final String? transactionHash;
}

String _text(dynamic value) => value?.toString().trim() ?? '';

int _integer(dynamic value, {int fallback = 0}) {
  if (value is num) return value.toInt();
  return int.tryParse(_text(value)) ?? fallback;
}
