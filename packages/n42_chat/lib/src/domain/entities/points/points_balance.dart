import 'package:equatable/equatable.dart';

/// User's points balance in a specific room/group.
class PointsBalance extends Equatable {
  final String userId;
  final String roomId;
  final int totalPoints;
  final int availablePoints;
  final int redeemedPoints;
  final int rank;
  final int streakDays;
  final DateTime? lastActiveDate;

  const PointsBalance({
    required this.userId,
    required this.roomId,
    this.totalPoints = 0,
    this.availablePoints = 0,
    this.redeemedPoints = 0,
    this.rank = 0,
    this.streakDays = 0,
    this.lastActiveDate,
  });

  /// Whether the user has been active today
  bool get isActiveToday {
    if (lastActiveDate == null) return false;
    final now = DateTime.now();
    return lastActiveDate!.year == now.year &&
        lastActiveDate!.month == now.month &&
        lastActiveDate!.day == now.day;
  }

  @override
  List<Object?> get props => [
        userId,
        roomId,
        totalPoints,
        availablePoints,
        rank,
        streakDays,
      ];
}
