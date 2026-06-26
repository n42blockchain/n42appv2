import 'package:equatable/equatable.dart';

import 'reward_rule.dart';

/// Points system configuration for a group/room.
class PointsConfig extends Equatable {
  final String roomId;
  final bool isEnabled;
  final String pointsName;
  final String pointsSymbol;
  final List<RewardRule> rules;
  final bool allowTransfers;
  final bool showLeaderboard;
  final int? dailyEarnLimit;

  const PointsConfig({
    required this.roomId,
    this.isEnabled = true,
    this.pointsName = 'Points',
    this.pointsSymbol = 'PTS',
    this.rules = const [],
    this.allowTransfers = false,
    this.showLeaderboard = true,
    this.dailyEarnLimit,
  });

  @override
  List<Object?> get props => [
        roomId,
        isEnabled,
        pointsName,
        pointsSymbol,
        rules,
        allowTransfers,
        showLeaderboard,
        dailyEarnLimit,
      ];
}
