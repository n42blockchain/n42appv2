import 'package:equatable/equatable.dart';

/// Type of points transaction
enum PointsTransactionType {
  /// Points earned
  earned,

  /// Points redeemed/spent
  redeemed,

  /// Points received from transfer
  received,

  /// Points sent via transfer
  sent,

  /// Points adjustment by admin
  adjustment,
}

/// A single points transaction record.
class PointsTransaction extends Equatable {
  final String id;
  final String userId;
  final String roomId;
  final PointsTransactionType type;
  final int amount;
  final String description;
  final String? actionType;
  final DateTime createdAt;

  const PointsTransaction({
    required this.id,
    required this.userId,
    required this.roomId,
    required this.type,
    required this.amount,
    required this.description,
    this.actionType,
    required this.createdAt,
  });

  /// Whether this transaction represents earned points
  bool get isEarned => type == PointsTransactionType.earned;

  /// Whether this transaction represents spent points
  bool get isSpent =>
      type == PointsTransactionType.redeemed ||
      type == PointsTransactionType.sent;

  @override
  List<Object?> get props => [id, userId, roomId, type, amount, createdAt];
}
