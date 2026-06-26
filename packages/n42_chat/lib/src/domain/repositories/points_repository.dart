import '../entities/points/points_balance.dart';
import '../entities/points/points_config.dart';
import '../entities/points/points_transaction.dart';
import '../entities/points/redemption_item.dart';

/// Repository interface for points/rewards operations.
abstract class IPointsRepository {
  /// Get the points balance for a user in a room.
  Future<PointsBalance> getBalance(String userId, String roomId);

  /// Get points transaction history.
  Future<List<PointsTransaction>> getTransactions(
    String userId,
    String roomId, {
    int limit = 50,
    int offset = 0,
  });

  /// Get the leaderboard for a room.
  Future<List<PointsBalance>> getLeaderboard(
    String roomId, {
    int limit = 50,
  });

  /// Award points to a user.
  Future<void> awardPoints({
    required String userId,
    required String roomId,
    required int amount,
    required String actionType,
    String? description,
  });

  /// Get points configuration for a room.
  Future<PointsConfig> getConfig(String roomId);

  /// Update points configuration (admin only).
  Future<void> updateConfig(PointsConfig config);

  /// Get available redemption items for a room.
  Future<List<RedemptionItem>> getRedemptionItems(String roomId);

  /// Redeem an item with points.
  Future<void> redeemItem({
    required String userId,
    required String roomId,
    required String itemId,
  });

  /// Check daily earn count for a user/action combination.
  Future<int> getDailyEarnCount(
    String userId,
    String roomId,
    String actionType,
  );
}
