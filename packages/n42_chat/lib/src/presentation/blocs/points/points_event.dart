import 'package:equatable/equatable.dart';

import '../../../domain/entities/points/points_config.dart';

/// Base event for the points BLoC.
abstract class PointsEvent extends Equatable {
  const PointsEvent();

  @override
  List<Object?> get props => [];
}

/// Load the points balance for a user in a room.
class PointsLoadBalance extends PointsEvent {
  final String userId;
  final String roomId;

  const PointsLoadBalance({required this.userId, required this.roomId});

  @override
  List<Object?> get props => [userId, roomId];
}

/// Load points transaction history.
class PointsLoadTransactions extends PointsEvent {
  final String userId;
  final String roomId;

  const PointsLoadTransactions({required this.userId, required this.roomId});

  @override
  List<Object?> get props => [userId, roomId];
}

/// Load the leaderboard for a room.
class PointsLoadLeaderboard extends PointsEvent {
  final String roomId;

  const PointsLoadLeaderboard({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}

/// Load the points configuration for a room.
class PointsLoadConfig extends PointsEvent {
  final String roomId;

  const PointsLoadConfig({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}

/// Update the points configuration (admin only).
class PointsUpdateConfig extends PointsEvent {
  final PointsConfig config;

  const PointsUpdateConfig({required this.config});

  @override
  List<Object?> get props => [config];
}

/// Load available redemption items for a room.
class PointsLoadRedemptionItems extends PointsEvent {
  final String roomId;

  const PointsLoadRedemptionItems({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}

/// Redeem an item with points.
class PointsRedeemItem extends PointsEvent {
  final String userId;
  final String roomId;
  final String itemId;

  const PointsRedeemItem({
    required this.userId,
    required this.roomId,
    required this.itemId,
  });

  @override
  List<Object?> get props => [userId, roomId, itemId];
}

/// Clear the last redemption feedback after the UI has handled it.
class PointsClearRedemptionFeedback extends PointsEvent {
  const PointsClearRedemptionFeedback();
}
