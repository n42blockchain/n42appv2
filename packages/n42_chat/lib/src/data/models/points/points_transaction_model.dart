import '../../../domain/entities/points/points_transaction.dart';

/// API model for points transaction with JSON serialization.
class PointsTransactionModel {
  final String id;
  final String userId;
  final String roomId;
  final String type;
  final int amount;
  final String description;
  final String? actionType;
  final String createdAt;

  const PointsTransactionModel({
    required this.id,
    required this.userId,
    required this.roomId,
    required this.type,
    required this.amount,
    required this.description,
    this.actionType,
    required this.createdAt,
  });

  factory PointsTransactionModel.fromJson(Map<String, dynamic> json) {
    return PointsTransactionModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      roomId: json['roomId'] as String? ?? '',
      type: json['type'] as String? ?? 'earned',
      amount: json['amount'] as int? ?? 0,
      description: json['description'] as String? ?? '',
      actionType: json['actionType'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'roomId': roomId,
        'type': type,
        'amount': amount,
        'description': description,
        'actionType': actionType,
        'createdAt': createdAt,
      };

  /// Convert to domain entity.
  PointsTransaction toEntity() {
    return PointsTransaction(
      id: id,
      userId: userId,
      roomId: roomId,
      type: _mapType(type),
      amount: amount,
      description: description,
      actionType: actionType,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }

  static PointsTransactionType _mapType(String type) {
    switch (type) {
      case 'earned':
        return PointsTransactionType.earned;
      case 'redeemed':
        return PointsTransactionType.redeemed;
      case 'received':
        return PointsTransactionType.received;
      case 'sent':
        return PointsTransactionType.sent;
      case 'adjustment':
        return PointsTransactionType.adjustment;
      default:
        return PointsTransactionType.earned;
    }
  }
}
