import '../../../domain/entities/points/points_balance.dart';

/// API model for points balance with JSON serialization.
class PointsBalanceModel {
  final String userId;
  final String roomId;
  final int totalPoints;
  final int availablePoints;
  final int redeemedPoints;
  final int rank;
  final int streakDays;
  final String? lastActiveDate;

  const PointsBalanceModel({
    required this.userId,
    required this.roomId,
    this.totalPoints = 0,
    this.availablePoints = 0,
    this.redeemedPoints = 0,
    this.rank = 0,
    this.streakDays = 0,
    this.lastActiveDate,
  });

  factory PointsBalanceModel.fromJson(Map<String, dynamic> json) {
    return PointsBalanceModel(
      userId: json['userId'] as String? ?? '',
      roomId: json['roomId'] as String? ?? '',
      totalPoints: json['totalPoints'] as int? ?? 0,
      availablePoints: json['availablePoints'] as int? ?? 0,
      redeemedPoints: json['redeemedPoints'] as int? ?? 0,
      rank: json['rank'] as int? ?? 0,
      streakDays: json['streakDays'] as int? ?? 0,
      lastActiveDate: json['lastActiveDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'roomId': roomId,
        'totalPoints': totalPoints,
        'availablePoints': availablePoints,
        'redeemedPoints': redeemedPoints,
        'rank': rank,
        'streakDays': streakDays,
        'lastActiveDate': lastActiveDate,
      };

  /// Convert to domain entity.
  PointsBalance toEntity() {
    return PointsBalance(
      userId: userId,
      roomId: roomId,
      totalPoints: totalPoints,
      availablePoints: availablePoints,
      redeemedPoints: redeemedPoints,
      rank: rank,
      streakDays: streakDays,
      lastActiveDate:
          lastActiveDate != null ? DateTime.tryParse(lastActiveDate!) : null,
    );
  }
}
