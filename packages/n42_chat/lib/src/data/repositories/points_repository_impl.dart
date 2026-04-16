import '../../domain/entities/points/points_balance.dart';
import '../../domain/entities/points/points_config.dart';
import '../../domain/entities/points/points_transaction.dart';
import '../../domain/entities/points/redemption_item.dart';
import '../../domain/entities/points/reward_rule.dart';
import '../../domain/repositories/points_repository.dart';
import '../datasources/points/points_api_datasource.dart';
import '../models/points/points_balance_model.dart';
import '../models/points/points_transaction_model.dart';

/// Implementation of [IPointsRepository] using REST API.
class PointsRepositoryImpl implements IPointsRepository {
  final PointsApiDatasource _api;

  PointsRepositoryImpl({required PointsApiDatasource api}) : _api = api;

  @override
  Future<PointsBalance> getBalance(String userId, String roomId) async {
    final data = await _api.getBalance(userId, roomId);
    return PointsBalanceModel.fromJson(data).toEntity();
  }

  @override
  Future<List<PointsTransaction>> getTransactions(
    String userId,
    String roomId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final data = await _api.getTransactions(
      userId,
      roomId,
      limit: limit,
      offset: offset,
    );
    return data
        .map((json) => PointsTransactionModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<List<PointsBalance>> getLeaderboard(
    String roomId, {
    int limit = 50,
  }) async {
    final data = await _api.getLeaderboard(roomId, limit: limit);
    return data
        .map((json) => PointsBalanceModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<void> awardPoints({
    required String userId,
    required String roomId,
    required int amount,
    required String actionType,
    String? description,
  }) async {
    await _api.awardPoints(
      userId: userId,
      roomId: roomId,
      amount: amount,
      actionType: actionType,
      description: description,
    );
  }

  @override
  Future<PointsConfig> getConfig(String roomId) async {
    final data = await _api.getConfig(roomId);
    return _parseConfig(data);
  }

  @override
  Future<void> updateConfig(PointsConfig config) async {
    await _api.updateConfig({
      'roomId': config.roomId,
      'isEnabled': config.isEnabled,
      'pointsName': config.pointsName,
      'pointsSymbol': config.pointsSymbol,
      'allowTransfers': config.allowTransfers,
      'showLeaderboard': config.showLeaderboard,
      'dailyEarnLimit': config.dailyEarnLimit,
      'rules': config.rules
          .map(
            (r) => {
              'id': r.id,
              'action': r.action.name,
              'points': r.points,
              'dailyLimit': r.dailyLimit,
              'cooldownSeconds': r.cooldown?.inSeconds,
              'isEnabled': r.isEnabled,
            },
          )
          .toList(),
    });
  }

  @override
  Future<List<RedemptionItem>> getRedemptionItems(String roomId) async {
    final data = await _api.getRedemptionItems(roomId);
    return data.map(_parseRedemptionItem).toList();
  }

  @override
  Future<void> redeemItem({
    required String userId,
    required String roomId,
    required String itemId,
  }) async {
    await _api.redeemItem(userId: userId, roomId: roomId, itemId: itemId);
  }

  @override
  Future<int> getDailyEarnCount(
    String userId,
    String roomId,
    String actionType,
  ) async {
    return _api.getDailyEarnCount(userId, roomId, actionType);
  }

  // ---------------------------------------------------------------------------
  // Private parsing helpers
  // ---------------------------------------------------------------------------

  PointsConfig _parseConfig(Map<String, dynamic> data) {
    final rulesData = data['rules'] as List<dynamic>? ?? [];
    final rules = rulesData
        .whereType<Map<String, dynamic>>()
        .map((ruleMap) {
          final action = _parseAction(ruleMap['action'] as String? ?? '');
          if (action == null) {
            return null;
          }
          return RewardRule(
            id: ruleMap['id'] as String? ?? '',
            action: action,
            points: ruleMap['points'] as int? ?? 0,
            dailyLimit: ruleMap['dailyLimit'] as int?,
            cooldown: ruleMap['cooldownSeconds'] != null
                ? Duration(seconds: ruleMap['cooldownSeconds'] as int)
                : null,
            isEnabled: ruleMap['isEnabled'] as bool? ?? true,
          );
        })
        .whereType<RewardRule>()
        .toList();

    return PointsConfig(
      roomId: data['roomId'] as String? ?? '',
      isEnabled: data['isEnabled'] as bool? ?? true,
      pointsName: data['pointsName'] as String? ?? 'Points',
      pointsSymbol: data['pointsSymbol'] as String? ?? 'PTS',
      rules: rules,
      allowTransfers: data['allowTransfers'] as bool? ?? false,
      showLeaderboard: data['showLeaderboard'] as bool? ?? true,
      dailyEarnLimit: data['dailyEarnLimit'] as int?,
    );
  }

  PointsAction? _parseAction(String action) {
    for (final candidate in PointsAction.values) {
      if (candidate.name == action) {
        return candidate;
      }
    }
    return null;
  }

  RedemptionItem _parseRedemptionItem(Map<String, dynamic> json) {
    return RedemptionItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      cost: json['cost'] as int? ?? 0,
      category: _parseCategory(json['category'] as String?),
      imageUrl: json['imageUrl'] as String?,
      stock: json['stock'] as int?,
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  RedemptionCategory _parseCategory(String? category) {
    switch (category) {
      case 'role':
        return RedemptionCategory.role;
      case 'badge':
        return RedemptionCategory.badge;
      case 'feature':
        return RedemptionCategory.feature;
      default:
        return RedemptionCategory.custom;
    }
  }
}
