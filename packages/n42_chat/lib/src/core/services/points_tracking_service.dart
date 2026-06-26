import 'dart:async';

import '../../data/datasources/matrix/matrix_client_manager.dart';
import '../../domain/entities/points/points_config.dart';
import '../../domain/entities/points/reward_rule.dart';
import '../../domain/repositories/points_repository.dart';
import '../utils/debug_log.dart';

/// Service that automatically tracks user actions and awards points.
///
/// Listens to Matrix sync events and triggers point awards based
/// on configured rules (message sending, reactions, etc.).
class PointsTrackingService {
  final IPointsRepository _repository;
  final MatrixClientManager _clientManager;

  StreamSubscription<dynamic>? _syncSubscription;
  final Map<String, DateTime> _lastActionTimes = {};
  final Map<String, PointsConfig> _configCache = {};
  final Map<String, DateTime> _configCacheTimestamps = {};
  static const Duration _configCacheTtl = Duration(minutes: 10);
  bool _isTracking = false;

  PointsTrackingService({
    required IPointsRepository repository,
    required MatrixClientManager clientManager,
  }) : _repository = repository,
       _clientManager = clientManager;

  /// Whether the service is currently tracking events.
  bool get isTracking => _isTracking;

  /// Start tracking Matrix sync events for automatic point awards.
  void startTracking() {
    if (_isTracking) return;

    final client = _clientManager.client;
    if (client == null) {
      debugLog('PointsTrackingService: Cannot start - client not available');
      return;
    }

    _syncSubscription = client.onSync.stream.listen((sync) {
      _processSyncUpdate(sync);
    });
    _isTracking = true; // Only set after subscription is successfully created

    debugLog('PointsTrackingService: Started tracking');
  }

  /// Stop tracking events.
  void stopTracking() {
    _syncSubscription?.cancel();
    _syncSubscription = null;
    _isTracking = false;
    debugLog('PointsTrackingService: Stopped tracking');
  }

  /// Award daily login points for a user in a room.
  ///
  /// Checks whether the daily login has already been awarded today
  /// before sending the award request.
  Future<void> awardDailyLogin(String userId, String roomId) async {
    try {
      final settings = await _resolveRuleSettings(
        roomId: roomId,
        action: PointsAction.dailyLogin,
        fallbackPoints: 5,
        fallbackDailyLimit: 1,
      );
      if (!settings.isEnabled || settings.points <= 0) {
        return;
      }

      final count = await _repository.getDailyEarnCount(
        userId,
        roomId,
        PointsAction.dailyLogin.name,
      );
      final dailyLimit = settings.dailyLimit ?? 1;
      if (count < dailyLimit) {
        await _repository.awardPoints(
          userId: userId,
          roomId: roomId,
          amount: settings.points,
          actionType: PointsAction.dailyLogin.name,
          description: 'Daily login bonus',
        );
      }
    } catch (e) {
      debugLog('PointsTrackingService: Failed to award daily login: $e');
    }
  }

  /// Release resources.
  void dispose() {
    stopTracking();
    _lastActionTimes.clear();
    _configCache.clear();
    _configCacheTimestamps.clear();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  void _processSyncUpdate(dynamic sync) {
    try {
      final client = _clientManager.client;
      if (client == null) return;

      final joinedRooms = sync.rooms?.join;
      if (joinedRooms == null) return;
      if (joinedRooms is! Map) return;

      for (final entry in joinedRooms.entries) {
        final roomId = entry.key as String?;
        if (roomId == null) continue;
        final roomData = entry.value;
        final List<dynamic> events;
        try {
          events = (roomData?.timeline?.events as List<dynamic>?) ?? <dynamic>[];
        } catch (_) {
          continue;
        }

        for (final event in events) {
          try {
            if (event.senderId == client.userID) {
              _processUserEvent(roomId, event);
            } else {
              _processOtherEvent(roomId, event);
            }
          } catch (_) {
            continue;
          }
        }
      }
    } catch (e) {
      debugLog('PointsTrackingService: Error processing sync: $e');
    }
  }

  void _processUserEvent(String roomId, dynamic event) {
    final userId = _clientManager.client?.userID;
    if (userId == null) return;

    final eventType = event.type as String?;
    PointsAction? action;
    int points = 0;

    switch (eventType) {
      case 'm.room.message':
        final msgtype = event.content?['msgtype'] as String?;
        if (msgtype == 'm.text') {
          action = PointsAction.sendMessage;
          points = 1;
        } else if (msgtype == 'm.image' ||
            msgtype == 'm.video' ||
            msgtype == 'm.audio') {
          action = PointsAction.sendMedia;
          points = 2;
        }
    }

    if (action != null && points > 0) {
      _tryAwardPoints(
        userId: userId,
        roomId: roomId,
        action: action,
        points: points,
      );
    }
  }

  void _processOtherEvent(String roomId, dynamic event) {
    // Reaction point awards require looking up the target message's author.
    // This cannot be done reliably in the sync listener without additional
    // API calls. Reaction awards should be handled server-side instead.
    // TODO: Move reaction tracking to backend /api/points/award
    //
    // Previously this method awarded points to the CURRENT user for any
    // reaction event, which was incorrect -- it should only award when
    // someone else reacts to the current user's message.
  }

  Future<void> _tryAwardPoints({
    required String userId,
    required String roomId,
    required PointsAction action,
    required int points,
  }) async {
    final settings = await _resolveRuleSettings(
      roomId: roomId,
      action: action,
      fallbackPoints: points,
      fallbackCooldown: const Duration(seconds: 5),
      fallbackDailyLimit: 50,
    );
    if (!settings.isEnabled || settings.points <= 0) {
      return;
    }

    // Cooldown check: prevent rapid-fire awards (5-second minimum gap)
    final key = '$userId:$roomId:${action.name}';
    final lastTime = _lastActionTimes[key];
    final cooldown = settings.cooldown;
    if (cooldown != null &&
        lastTime != null &&
        DateTime.now().difference(lastTime) < cooldown) {
      return;
    }
    _lastActionTimes[key] = DateTime.now();

    try {
      // Daily limit check: prevent excessive point farming
      final dailyCount = await _repository.getDailyEarnCount(
        userId,
        roomId,
        action.name,
      );
      final dailyLimit = settings.dailyLimit;
      if (dailyLimit != null && dailyCount >= dailyLimit) return;

      await _repository.awardPoints(
        userId: userId,
        roomId: roomId,
        amount: settings.points,
        actionType: action.name,
        description: '${action.name} reward',
      );
    } catch (e) {
      debugLog('PointsTrackingService: Failed to award points: $e');
    }
  }

  Future<_EffectiveRuleSettings> _resolveRuleSettings({
    required String roomId,
    required PointsAction action,
    required int fallbackPoints,
    Duration? fallbackCooldown,
    int? fallbackDailyLimit,
  }) async {
    try {
      final config = await _getConfig(roomId);
      if (config == null || !config.isEnabled) {
        return _EffectiveRuleSettings.disabled();
      }

      final rules = config.rules.where((candidate) => candidate.action == action);
      final rule = rules.isEmpty ? null : rules.first;
      if (rule == null) {
        return _EffectiveRuleSettings(
          points: fallbackPoints,
          cooldown: fallbackCooldown,
          dailyLimit: fallbackDailyLimit,
          isEnabled: true,
        );
      }

      return _EffectiveRuleSettings(
        points: rule.points,
        cooldown: rule.cooldown ?? fallbackCooldown,
        dailyLimit:
            rule.dailyLimit ?? config.dailyEarnLimit ?? fallbackDailyLimit,
        isEnabled: rule.isEnabled,
      );
    } catch (e) {
      debugLog('PointsTrackingService: Failed to resolve rule config: $e');
      return _EffectiveRuleSettings(
        points: fallbackPoints,
        cooldown: fallbackCooldown,
        dailyLimit: fallbackDailyLimit,
        isEnabled: true,
      );
    }
  }

  Future<PointsConfig?> _getConfig(String roomId) async {
    final cached = _configCache[roomId];
    final cachedAt = _configCacheTimestamps[roomId];
    if (cached != null &&
        cachedAt != null &&
        DateTime.now().difference(cachedAt) < _configCacheTtl) {
      return cached;
    }

    final config = await _repository.getConfig(roomId);
    _configCache[roomId] = config;
    _configCacheTimestamps[roomId] = DateTime.now();
    return config;
  }
}

class _EffectiveRuleSettings {
  final int points;
  final Duration? cooldown;
  final int? dailyLimit;
  final bool isEnabled;

  const _EffectiveRuleSettings({
    required this.points,
    this.cooldown,
    this.dailyLimit,
    required this.isEnabled,
  });

  factory _EffectiveRuleSettings.disabled() =>
      const _EffectiveRuleSettings(points: 0, isEnabled: false);
}
