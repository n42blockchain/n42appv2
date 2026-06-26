part of '../../n42_chat.dart';

/// N42Chat 推送通知服务管理器
///
/// 从 N42Chat 主类中提取的推送通知相关字段和方法。
/// 作为 part file 存在，所有成员对 N42Chat 可见。
class _N42PushManager {
  _N42PushManager._();

  static FirebasePushService? _pushService;
  static Completer<void>? _pushInitCompleter;

  /// 是否已分配运行时资源（dispose 短路检查使用）
  static bool get hasResources => _pushService != null;

  /// 应用最新的通知配置（无服务时静默 no-op）
  static void applyNotificationConfig(NotificationConfig config) {
    _pushService?.setNotificationConfig(config);
  }

  /// 初始化推送服务
  ///
  /// 使用 Completer 防止并发初始化（auth 恢复可能与初始化并行执行）
  static Future<void> initializePushService(N42ChatConfig config) async {
    if (_pushInitCompleter != null && !_pushInitCompleter!.isCompleted) {
      debugLog('N42Chat: Push service init in progress, waiting...');
      await _pushInitCompleter!.future;
      if (_pushService != null) return;
    }
    if (_pushService != null) return;

    _pushInitCompleter = Completer<void>();
    try {
      final client = getIt<MatrixClientManager>().client;
      if (client == null) {
        pushLog(
          'INIT',
          'Matrix client not initialized; push will register after login',
        );
        return;
      }

      pushLog(
        'INIT',
        'Creating push service (gateway=${config.pushGatewayUrl}, appId=${config.pushAppId})',
      );

      _pushService = FirebasePushService(
        client,
        pushGatewayUrl: config.pushGatewayUrl,
        appId: config.pushAppId,
        onNotificationTap: (roomId, eventId) {
          pushLog('TAP', 'roomId=$roomId, eventId=$eventId');
          N42Chat.handleNotificationTap(roomId: roomId, eventId: eventId);
        },
      );

      // FCM init 与读取持久化通知配置彼此独立，并行执行省一次 round-trip。
      final results = await Future.wait([
        _pushService!.initialize(),
        N42Chat.getSavedNotificationSettings(),
      ]);
      final savedNotificationSettings = results[1] as NotificationSettings;
      _pushService!.setNotificationConfig(
        NotificationConfig.fromSettings(savedNotificationSettings),
      );
      pushLog(
        'INIT',
        'Push service initialized, isLogged=${client.isLogged()}',
      );

      if (client.isLogged()) {
        await _pushService!.registerForPush();
      }
      pushLog(
        'INIT_OK',
        'Push service ready (verified=${_pushService?.isPusherVerified})',
      );
    } catch (e) {
      pushLog('INIT_FAIL', 'Failed to initialize push service: $e');
      // 清除 _pushService 以允许后续重试。
      _pushService = null;
    } finally {
      if (_pushInitCompleter != null && !_pushInitCompleter!.isCompleted) {
        _pushInitCompleter!.complete();
      }
    }
  }

  /// 注册推送通知
  ///
  /// 登录成功后调用此方法注册推送。
  /// 如果推送服务正在初始化中（竞态），会等待初始化完成后再注册。
  static Future<void> registerPushNotifications() async {
    pushLog('CHAIN', 'registerPushNotifications called');

    if (_pushInitCompleter != null && !_pushInitCompleter!.isCompleted) {
      pushLog('CHAIN', 'Waiting for push service initialization to complete');
      await _pushInitCompleter!.future;
    }

    // 之前若因 client==null 跳过 init，这里在登录成功后会再尝试。
    final config = N42Chat._config;
    if (_pushService == null &&
        config != null &&
        config.enablePushNotifications) {
      pushLog('CHAIN', 'Push service is null, attempting initialization');
      await initializePushService(config);
    }

    if (_pushService != null) {
      pushLog('CHAIN', 'Calling registerForPush');
      await _pushService!.registerForPush();
      pushLog(
        'CHAIN',
        'registerForPush completed (verified=${_pushService!.isPusherVerified})',
      );
    } else {
      pushLog(
        'CHAIN_FAIL',
        'Cannot register push - service null '
        '(config=${config != null}, enabled=${config?.enablePushNotifications})',
      );
    }
  }

  /// 取消注册推送通知
  static Future<void> unregisterPushNotifications() async {
    if (_pushService != null) {
      await _pushService!.unregisterPush();
    }
  }

  /// 清除所有通知
  static Future<void> clearAllNotifications() async {
    if (_pushService != null) {
      await _pushService!.clearAllNotifications();
    }
  }

  /// 清除指定房间的通知
  static Future<void> clearNotificationsForRoom(String roomId) async {
    if (_pushService != null) {
      await _pushService!.clearNotificationsForRoom(roomId);
    }
  }

  /// 获取推送诊断信息
  static Map<String, dynamic> getPushDiagnostics() {
    if (_pushService == null) {
      return {
        'status': 'not_initialized',
        'config_exists': N42Chat._config != null,
        'push_enabled': N42Chat._config?.enablePushNotifications ?? false,
      };
    }
    return _pushService!.getDiagnosticInfo();
  }

  /// 强制重新注册推送
  static Future<void> forceReRegisterPush() async {
    pushLog('FORCE', 'Force re-register push requested');
    if (_pushService != null) {
      await _pushService!.forceReRegister();
      return;
    }
    pushLog('FORCE', 'Push service is null, attempting full initialization');
    final config = N42Chat._config;
    if (config != null && config.enablePushNotifications) {
      await initializePushService(config);
    }
  }

  /// 释放推送服务资源
  static Future<void> dispose() async {
    try {
      await _pushService?.dispose();
    } catch (_) {}
    _pushService = null;
    _pushInitCompleter = null;
  }
}
