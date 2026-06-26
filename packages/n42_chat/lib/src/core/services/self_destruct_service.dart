import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';
import '../utils/debug_log.dart';

/// 阅后即焚消息管理服务
///
/// 负责追踪和管理所有阅后即焚消息的生命周期
///
/// 时间同步说明：
/// - 支持设置服务器时间偏移以确保准确的倒计时
/// - 使用 DateTime.now().millisecondsSinceEpoch 进行精确计时
class SelfDestructService extends ChangeNotifier {
  /// 单例实例
  static SelfDestructService? _instance;

  /// 获取单例实例
  static SelfDestructService get instance {
    _instance ??= SelfDestructService._();
    return _instance!;
  }

  SelfDestructService._();

  /// 用于测试的工厂构造函数
  @visibleForTesting
  factory SelfDestructService.forTest() => SelfDestructService._();

  /// 服务器时间与本地时间的偏移（毫秒）
  /// 正值表示服务器时间比本地时间快
  int _serverTimeOffsetMs = 0;

  /// 设置服务器时间偏移
  ///
  /// [serverTime] 服务器当前时间
  void setServerTime(DateTime serverTime) {
    final localTime = DateTime.now();
    _serverTimeOffsetMs = serverTime.millisecondsSinceEpoch -
                          localTime.millisecondsSinceEpoch;
    debugLog('SelfDestructService: Server time offset set to ${_serverTimeOffsetMs}ms');
  }

  /// 获取同步后的当前时间
  DateTime get syncedNow {
    return DateTime.fromMillisecondsSinceEpoch(
      DateTime.now().millisecondsSinceEpoch + _serverTimeOffsetMs,
    );
  }

  /// 活跃的消息定时器 {messageId: Timer}
  final Map<String, Timer> _timers = {};

  /// 正在追踪的消息 {messageId: MessageEntity}
  final Map<String, MessageEntity> _trackedMessages = {};

  /// 消息销毁回调
  final List<void Function(String messageId, String roomId)> _destructionCallbacks = [];

  /// 消息倒计时更新回调
  final List<void Function(String messageId, int remainingSeconds)> _countdownCallbacks = [];

  /// 获取所有正在追踪的消息
  List<MessageEntity> get trackedMessages => _trackedMessages.values.toList();

  /// 获取指定房间的追踪消息
  List<MessageEntity> getTrackedMessagesForRoom(String roomId) {
    return _trackedMessages.values
        .where((m) => m.roomId == roomId)
        .toList();
  }

  /// 注册消息销毁回调
  void onMessageDestroyed(void Function(String messageId, String roomId) callback) {
    _destructionCallbacks.add(callback);
  }

  /// 移除消息销毁回调
  void removeDestructionCallback(void Function(String messageId, String roomId) callback) {
    _destructionCallbacks.remove(callback);
  }

  /// 注册倒计时更新回调
  void onCountdownUpdate(void Function(String messageId, int remainingSeconds) callback) {
    _countdownCallbacks.add(callback);
  }

  /// 移除倒计时更新回调
  void removeCountdownCallback(void Function(String messageId, int remainingSeconds) callback) {
    _countdownCallbacks.remove(callback);
  }

  /// 开始追踪阅后即焚消息
  ///
  /// 当消息被阅读时调用此方法开始倒计时
  MessageEntity startTracking(MessageEntity message) {
    if (!message.isSelfDestructing) {
      debugLog('SelfDestructService: Message ${message.id} is not self-destructing');
      return message;
    }

    // 如果已经在追踪，返回当前状态
    if (_trackedMessages.containsKey(message.id)) {
      return _trackedMessages[message.id]!;
    }

    // 开始销毁倒计时
    final trackedMessage = message.isDestructionStarted
        ? message
        : message.startDestruction();

    _trackedMessages[message.id] = trackedMessage;

    // 计算剩余时间
    final remainingSeconds = trackedMessage.remainingDestructionSeconds ?? 0;

    if (remainingSeconds <= 0) {
      // 已过期，立即触发销毁
      _triggerDestruction(trackedMessage);
    } else {
      // 设置定时器
      _setupTimer(trackedMessage, remainingSeconds);
    }

    notifyListeners();
    return trackedMessage;
  }

  /// 设置消息销毁定时器
  ///
  /// 使用精确的时间计算来避免 Timer 漂移问题
  void _setupTimer(MessageEntity message, int remainingSeconds) {
    // 取消现有定时器
    _timers[message.id]?.cancel();

    // 记录销毁的目标时间戳
    final destructionTimeMs = syncedNow.millisecondsSinceEpoch +
                              (remainingSeconds * 1000);

    // 创建倒计时定时器（每秒更新）
    _timers[message.id] = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        // 基于时间戳计算剩余秒数，避免累积误差
        final nowMs = syncedNow.millisecondsSinceEpoch;
        final remainingMs = destructionTimeMs - nowMs;
        final countdown = (remainingMs / 1000).ceil();

        // 通知倒计时更新（复制列表以防止迭代时修改）
        for (final callback in List<void Function(String, int)>.from(_countdownCallbacks)) {
          try {
            callback(message.id, countdown);
          } catch (e) {
            debugLog('SelfDestructService: Countdown callback error: $e');
          }
        }

        if (countdown <= 0) {
          timer.cancel();
          _triggerDestruction(message);
        }
      },
    );

    debugLog('SelfDestructService: Started timer for ${message.id}, '
        '$remainingSeconds seconds remaining');
  }

  /// 触发消息销毁
  void _triggerDestruction(MessageEntity message) {
    debugLog('SelfDestructService: Destroying message ${message.id}');

    // 清理追踪数据
    _timers[message.id]?.cancel();
    _timers.remove(message.id);
    _trackedMessages.remove(message.id);

    // 通知销毁回调（复制列表以防止迭代时修改）
    for (final callback in List<void Function(String, String)>.from(_destructionCallbacks)) {
      try {
        callback(message.id, message.roomId);
      } catch (e) {
        debugLog('SelfDestructService: Destruction callback error: $e');
      }
    }

    notifyListeners();
  }

  /// 停止追踪消息
  void stopTracking(String messageId) {
    _timers[messageId]?.cancel();
    _timers.remove(messageId);
    _trackedMessages.remove(messageId);
    notifyListeners();
  }

  /// 停止追踪房间内所有消息
  void stopTrackingRoom(String roomId) {
    final messageIds = _trackedMessages.entries
        .where((e) => e.value.roomId == roomId)
        .map((e) => e.key)
        .toList();

    for (final id in messageIds) {
      stopTracking(id);
    }
  }

  /// 获取消息剩余销毁时间
  int? getRemainingSeconds(String messageId) {
    final message = _trackedMessages[messageId];
    return message?.remainingDestructionSeconds;
  }

  /// 检查消息是否正在被追踪
  bool isTracking(String messageId) {
    return _trackedMessages.containsKey(messageId);
  }

  /// 获取格式化的剩余时间
  String? getFormattedRemainingTime(String messageId) {
    final seconds = getRemainingSeconds(messageId);
    if (seconds == null) return null;
    return formatDuration(seconds);
  }

  /// 格式化时长
  static String formatDuration(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    } else if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      final secs = seconds % 60;
      return secs > 0 ? '${minutes}m ${secs}s' : '${minutes}m';
    } else if (seconds < 86400) {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    } else {
      final days = seconds ~/ 86400;
      final hours = (seconds % 86400) ~/ 3600;
      return hours > 0 ? '${days}d ${hours}h' : '${days}d';
    }
  }

  /// 清理所有追踪
  void clear() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _trackedMessages.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    clear();
    _destructionCallbacks.clear();
    _countdownCallbacks.clear();
    _instance = null;
    super.dispose();
  }
}

/// 阅后即焚定时器预设
class SelfDestructTimer {
  /// 定时器名称
  final String name;

  /// 秒数
  final int seconds;

  const SelfDestructTimer({
    required this.name,
    required this.seconds,
  });

  /// 预设定时器列表
  static const List<SelfDestructTimer> presets = [
    SelfDestructTimer(name: '5 秒', seconds: 5),
    SelfDestructTimer(name: '10 秒', seconds: 10),
    SelfDestructTimer(name: '30 秒', seconds: 30),
    SelfDestructTimer(name: '1 分钟', seconds: 60),
    SelfDestructTimer(name: '5 分钟', seconds: 300),
    SelfDestructTimer(name: '1 小时', seconds: 3600),
    SelfDestructTimer(name: '24 小时', seconds: 86400),
    SelfDestructTimer(name: '1 周', seconds: 604800),
  ];

  /// 根据秒数获取预设
  static SelfDestructTimer? fromSeconds(int seconds) {
    for (final p in presets) {
      if (p.seconds == seconds) return p;
    }
    return null;
  }

  /// 获取预设名称，如果不是预设则返回格式化时间
  static String getDisplayName(int seconds) {
    final preset = fromSeconds(seconds);
    if (preset != null) return preset.name;
    return SelfDestructService.formatDuration(seconds);
  }
}
