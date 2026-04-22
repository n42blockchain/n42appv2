import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../services/voip/call_manager.dart';
import '../../services/voip/incoming_call_ringtone_preference.dart';
import '../../data/datasources/local/preferences_datasource.dart';
import '../../domain/entities/user_profile_entity.dart' as profile_entity;
import '../utils/conversation_notification_utils.dart';
import 'push_notification_service.dart';
import '../utils/debug_log.dart';

/// 后台消息处理器 - 顶级函数，供独立使用 n42_chat 插件时注册。
///
/// 在集成到主 app (n42appv2) 时，不应直接注册此函数。
/// 主 app 应使用 [FirebasePushService.handleBackgroundMessage] 在其统一的
/// 后台消息处理器中委托 Matrix/Chat 消息。
/// （全局只允许一个 `FirebaseMessaging.onBackgroundMessage` 处理器）
@pragma('vm:entry-point')
Future<void> firebasePushBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await FirebasePushService.handleBackgroundMessage(message);
}

/// Firebase 推送通知服务实现
///
/// 实现功能：
/// - Android/iOS 后台推送支持
/// - 本地通知显示
/// - 推送 Token 注册到 Matrix 服务器
/// - 点击通知跳转到对应聊天
class FirebasePushService implements IPushNotificationService {
  final matrix.Client _client;

  /// 推送网关 URL（Matrix Sygnal 服务器）
  final String? pushGatewayUrl;

  /// 应用标识符
  final String appId;

  /// 推送类型 (fcm / http)
  final String pushkeyType;

  /// 通知点击回调
  final void Function(String? roomId, String? eventId)? onNotificationTap;

  /// 本地通知插件
  static FlutterLocalNotificationsPlugin? _localNotifications;

  /// Android 通知渠道基础定义
  static const String _messageChannelBaseId = 'n42_chat_messages';
  static const String _messageChannelName = 'N42 Chat Messages';
  static const String _messageChannelDescription =
      'N42 Chat message notifications';

  String? _fcmToken;
  String? _apnsToken;
  String? _lastRegisteredPushkey;
  bool _isInitialized = false;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<matrix.SyncUpdate>? _syncSubscription;

  /// 通话状态自动重置定时器（防止 _isInCall 泄漏）
  Timer? _callStateResetTimer;

  /// 推送注册锁（防止并发注册）
  bool _isRegistering = false;

  /// 当前注册完成通知器（供 forceReRegister 等待）
  Completer<void>? _registrationCompleter;

  /// Pusher 是否已通过服务端验证
  bool _isPusherVerified = false;

  /// 通知配置
  NotificationConfig _notificationConfig = const NotificationConfig();

  /// 通知 ID 计数器（避免时间戳碰撞）
  static int _notificationIdCounter = 0;
  static int _nextNotificationId() => (_notificationIdCounter++ & 0x7FFFFFFF);

  /// 房间 ID → 该房间所有通知 ID 列表（用于 clearNotificationsForRoom）
  final Map<String, List<int>> _roomNotificationIds = {};

  /// 当前活跃的房间 ID（用户正在查看的房间不弹通知）
  String? _activeRoomId;

  /// 是否正在通话中（通话期间禁用所有消息通知）
  bool _isInCall = false;

  /// 上次同步时间（用于过滤旧消息）
  DateTime? _lastSyncTime;

  /// 最近已显示通知的 eventId 集合（用于 FCM/Sync 双通道去重）
  /// 使用 Queue-like 机制限制大小，避免无界增长
  final Set<String> _recentlyNotifiedEventIds = {};
  static const int _maxRecentEventIds = 200;

  FirebasePushService(
    this._client, {
    this.pushGatewayUrl,
    this.appId = 'com.n42.chat',
    this.pushkeyType = 'http',
    this.onNotificationTap,
  });

  static NotificationConfig _notificationConfigFromSettings(
    profile_entity.NotificationSettings settings,
  ) {
    return NotificationConfig(
      enabled: settings.enabled,
      showPreview: settings.showPreview,
      playSound: settings.playSound,
      vibrate: settings.vibrate,
      doNotDisturb: settings.doNotDisturb,
      dndStartTime: _parseStoredTimeOfDay(settings.doNotDisturbStart),
      dndEndTime: _parseStoredTimeOfDay(settings.doNotDisturbEnd),
      privacyMode: settings.privacyMode,
    );
  }

  static TimeOfDay? _parseStoredTimeOfDay(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final parts = value.split(':');
    if (parts.length != 2) {
      return null;
    }
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return null;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  static Future<NotificationConfig> _loadPersistedNotificationConfig() async {
    final settings = await PreferencesDataSource()
        .getNotificationSettingsModel();
    return _notificationConfigFromSettings(settings);
  }

  static AndroidNotificationChannel _androidMessageChannelForConfig(
    NotificationConfig config,
  ) {
    final suffix = switch ((config.playSound, config.vibrate)) {
      (true, true) => 'default',
      (true, false) => 'sound_only',
      (false, true) => 'vibrate_only',
      (false, false) => 'silent',
    };
    return AndroidNotificationChannel(
      '$_messageChannelBaseId.$suffix',
      _messageChannelName,
      description: _messageChannelDescription,
      importance: Importance.high,
      playSound: config.playSound,
      enableVibration: config.vibrate,
    );
  }

  static AndroidNotificationDetails _androidMessageDetails(
    NotificationConfig config, {
    Importance importance = Importance.max,
    Priority priority = Priority.max,
    String? groupKey,
    AndroidNotificationCategory? category,
    bool fullScreenIntent = false,
  }) {
    final channel = _androidMessageChannelForConfig(config);
    return AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: importance,
      priority: priority,
      playSound: config.playSound,
      enableVibration: config.vibrate,
      groupKey: groupKey,
      category: category,
      fullScreenIntent: fullScreenIntent,
    );
  }

  static DarwinNotificationDetails _iosMessageDetails(
    NotificationConfig config,
  ) {
    return DarwinNotificationDetails(
      presentAlert: config.enabled,
      presentBadge: config.enabled,
      presentSound: config.enabled && config.playSound,
    );
  }

  static Future<void> _ensureAndroidMessageChannels() async {
    if (!Platform.isAndroid || _localNotifications == null) {
      return;
    }
    final plugin = _localNotifications!
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (plugin == null) {
      return;
    }
    for (final channel in <AndroidNotificationChannel>[
      _androidMessageChannelForConfig(const NotificationConfig()),
      _androidMessageChannelForConfig(const NotificationConfig(vibrate: false)),
      _androidMessageChannelForConfig(
        const NotificationConfig(playSound: false),
      ),
      _androidMessageChannelForConfig(
        const NotificationConfig(playSound: false, vibrate: false),
      ),
    ]) {
      await plugin.createNotificationChannel(channel);
    }
  }

  @visibleForTesting
  static String androidMessageChannelIdForTest(NotificationConfig config) =>
      _androidMessageChannelForConfig(config).id;

  @visibleForTesting
  bool markEventAsNotifiedForTest(String eventId) =>
      _markEventAsNotified(eventId);

  @visibleForTesting
  int get recentlyNotifiedEventCountForTest =>
      _recentlyNotifiedEventIds.length;

  @visibleForTesting
  static Future<NotificationConfig> loadPersistedNotificationConfigForTest() =>
      _loadPersistedNotificationConfig();

  void _applyIOSForegroundPresentationOptions(NotificationConfig config) {
    if (!Platform.isIOS) {
      return;
    }
    final allowNativePreview = config.allowsNativeForegroundPreview;
    unawaited(
      FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: allowNativePreview,
        badge: config.enabled,
        sound: allowNativePreview && config.playSound,
      ),
    );
  }

  /// 尝试将 eventId 标记为已通知。返回 true 表示首次标记（应显示通知），
  /// 返回 false 表示已存在（应跳过，避免重复通知）。
  bool _markEventAsNotified(String eventId) {
    if (_recentlyNotifiedEventIds.contains(eventId)) {
      return false;
    }
    _recentlyNotifiedEventIds.add(eventId);
    if (_recentlyNotifiedEventIds.length > _maxRecentEventIds) {
      _recentlyNotifiedEventIds.remove(_recentlyNotifiedEventIds.first);
    }
    return true;
  }

  /// 设置通知配置
  void setNotificationConfig(NotificationConfig config) {
    _notificationConfig = config;
    _applyIOSForegroundPresentationOptions(config);
  }

  /// 设置当前活跃房间（正在查看的房间不弹通知）
  void setActiveRoom(String? roomId) {
    _activeRoomId = roomId;
    debugLog('FirebasePushService: Active room set to $roomId');
  }

  /// 获取当前活跃房间
  String? get activeRoomId => _activeRoomId;

  /// 设置通话状态（通话期间禁用所有消息通知）
  void setInCall(bool inCall) {
    // 先取消旧 timer，再修改状态，避免 timer 回调读到新状态后立即重置
    _callStateResetTimer?.cancel();
    _callStateResetTimer = null;
    _isInCall = inCall;
    if (inCall) {
      // 安全机制：60 分钟后自动重置，防止状态泄漏
      // （正常通话会由 CallManager 主动调用 setInCall(false)）。
      // 设为 60 分钟避免打断长时间会议/群通话。
      _callStateResetTimer = Timer(const Duration(minutes: 60), () {
        if (_isInCall) {
          _isInCall = false;
          debugLog(
            'FirebasePushService: Auto-reset _isInCall after 60min safety timeout',
          );
        }
      });
    }
    debugLog('FirebasePushService: In call set to $inCall');
  }

  /// 获取是否正在通话
  bool get isInCall => _isInCall;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 初始化本地通知
      await _initializeLocalNotifications();

      // 注意：后台消息处理器由主 app 统一注册（全局只允许一个）。
      // 主 app 的处理器会将 Matrix/Chat 消息委托给
      // FirebasePushService.handleBackgroundMessage()。

      // 尽早加载持久化配置，避免 iOS 前台横幅先按默认值泄露通知内容。
      _notificationConfig = await _loadPersistedNotificationConfig();
      _applyIOSForegroundPresentationOptions(_notificationConfig);

      // 监听前台消息
      _foregroundSubscription = FirebaseMessaging.onMessage.listen(
        _handleForegroundMessage,
      );

      // 监听通知点击（从后台打开）
      _messageOpenedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
        _handleNotificationTap,
      );

      // 检查是否通过通知启动应用
      final initialMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      // 处理本地通知的冷启动/后台点击（flutter_local_notifications 的本地通知
      // 点击不会触发 FirebaseMessaging.onMessageOpenedApp）。
      await consumePendingLocalNotificationTap();

      // 获取 FCM Token
      await _initializeToken();

      // 监听 Token 刷新
      _tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh
          .listen((token) {
            _fcmToken = token;
            // 重新注册推送
            if (_client.isLogged()) {
              registerForPush();
            }
          });

      // 监听新消息（用于本地通知）
      _syncSubscription = _client.onSync.stream.listen(_handleSyncUpdate);

      _isInitialized = true;
    } catch (e) {
      debugLog('N42Chat: Failed to initialize push service: $e');
      // 清理已创建的订阅，防止资源泄漏
      await _foregroundSubscription?.cancel();
      _foregroundSubscription = null;
      await _messageOpenedSubscription?.cancel();
      _messageOpenedSubscription = null;
      await _tokenRefreshSubscription?.cancel();
      _tokenRefreshSubscription = null;
      await _syncSubscription?.cancel();
      _syncSubscription = null;
    }
  }

  Future<void> _initializeLocalNotifications() async {
    _localNotifications = FlutterLocalNotificationsPlugin();

    // Android 初始化设置
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS 初始化设置
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications!.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundNotificationResponse,
    );

    await _ensureAndroidMessageChannels();
  }

  Future<void> _initializeToken() async {
    // 请求通知权限
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugLog(
      'FirebasePushService: Permission status: ${settings.authorizationStatus}',
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugLog('FirebasePushService: Permission granted, getting tokens...');

      // iOS 需要先等待 APNs Token，FCM Token 依赖它
      if (Platform.isIOS) {
        _apnsToken = await _getAPNsTokenWithRetry();
        debugLog(
          'FirebasePushService: APNs token: ${_apnsToken != null ? '${_truncateToken(_apnsToken!)}...' : 'null'}',
        );
        if (_apnsToken == null) {
          debugLog(
            'FirebasePushService: WARNING - APNs token is null, iOS push may not work!',
          );
        }
      }

      // 获取 FCM Token（带重试）
      _fcmToken = await _getFCMTokenWithRetry();
      debugLog(
        'FirebasePushService: FCM token: ${_fcmToken != null ? '${_truncateToken(_fcmToken!)}...' : 'null'}',
      );

      if (_fcmToken == null) {
        debugLog(
          'FirebasePushService: WARNING - FCM token is null after retries!',
        );
      }
    } else {
      debugLog(
        'FirebasePushService: Notification permission DENIED (${settings.authorizationStatus}). '
        'Push notifications will NOT work. User must enable in Settings.',
      );
      // 尝试获取 token（某些 Android 设备即使未授权也能获取 token）
      if (Platform.isAndroid) {
        _fcmToken = await _getFCMTokenWithRetry(maxRetries: 1);
        if (_fcmToken != null) {
          debugLog(
            'FirebasePushService: Got FCM token despite permission denied (Android)',
          );
        }
      }
    }
  }

  /// 带重试的 APNs Token 获取（iOS）
  Future<String?> _getAPNsTokenWithRetry({int maxRetries = 5}) async {
    for (var i = 0; i < maxRetries; i++) {
      try {
        final token = await FirebaseMessaging.instance.getAPNSToken();
        if (token != null) return token;
      } catch (e) {
        debugLog('FirebasePushService: APNs token attempt ${i + 1} failed: $e');
      }
      if (i < maxRetries - 1) {
        // APNs 注册可能需要时间，逐渐增加等待
        await Future<void>.delayed(Duration(seconds: (i + 1) * 2));
      }
    }
    debugLog(
      'FirebasePushService: Failed to get APNs token after $maxRetries attempts',
    );
    return null;
  }

  /// 带重试的 FCM Token 获取
  Future<String?> _getFCMTokenWithRetry({int maxRetries = 3}) async {
    for (var i = 0; i < maxRetries; i++) {
      try {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) return token;
      } catch (e) {
        debugLog('FirebasePushService: FCM token attempt ${i + 1} failed: $e');
      }
      if (i < maxRetries - 1) {
        await Future<void>.delayed(Duration(seconds: (i + 1) * 2));
      }
    }
    debugLog(
      'FirebasePushService: Failed to get FCM token after $maxRetries attempts',
    );
    return null;
  }

  /// 处理前台消息
  void _handleForegroundMessage(RemoteMessage message) {
    try {
      _handleForegroundMessageImpl(message);
    } catch (e, st) {
      // StreamSubscription 异常会中断后续消息，必须吞掉并记录
      debugLog(
        'FirebasePushService: _handleForegroundMessage error: $e\n$st',
      );
    }
  }

  void _handleForegroundMessageImpl(RemoteMessage message) {
    // 检查通知配置
    if (!_notificationConfig.enabled) return;
    if (_notificationConfig.isInDoNotDisturbPeriod()) return;

    // 通话期间禁用所有消息通知
    if (_isInCall) {
      debugLog(
        'FirebasePushService: Skipping foreground notification during call',
      );
      return;
    }

    // 过滤通话相关的推送
    final eventType = message.data['type'] as String?;
    if (eventType == 'm.call.invite') {
      setInCall(true);
      debugLog('FirebasePushService: Set isInCall=true for incoming call');
      // 前台保护：如果 CallManager 尚未初始化或尚未处理此来电，
      // 主动触发 CallKit 作为 fallback（避免 sync 未建立时来电丢失）
      final callManager = CallManager();
      if (!callManager.isInitialized || !callManager.isInCall) {
        debugLog(
          'FirebasePushService: CallManager not handling call, showing CallKit as fallback',
        );
        _showBackgroundCallKit(message).catchError((Object e) {
          debugLog(
            'FirebasePushService: Failed to show foreground CallKit fallback: $e',
          );
        });
      }
      return;
    }
    if (eventType == 'm.call.hangup' || eventType == 'm.call.reject') {
      // 对方挂断或拒接 → 清除通话状态，恢复消息通知
      if (_isInCall) {
        setInCall(false);
        debugLog('FirebasePushService: Cleared _isInCall on $eventType');
      }
      return;
    }
    if (eventType != null && eventType.startsWith('m.call.')) {
      debugLog(
        'FirebasePushService: Skipping foreground notification for call event: $eventType',
      );
      return;
    }

    // 解析 Matrix 推送数据
    final roomId = message.data['room_id'] as String?;
    final eventId = message.data['event_id'] as String?;

    // 不显示用户正在查看的房间的通知
    if (roomId != null && _activeRoomId == roomId) {
      debugLog(
        'FirebasePushService: Skipping foreground FCM notification for active room $roomId',
      );
      return;
    }

    // 前台时 Matrix Sync 通道正在运行，带有完整事件内容、mentions 模式判断的通知
    // 由 _handleSyncUpdate 负责。若此处再显示 FCM 的占位通知（通常是
    // event_id_only，body 为 "You have a new message"），会抢先 mark eventId，
    // 导致后续 Sync 的详细通知被去重 —— 结果用户始终看到粗糙通知。
    // 因此 room 已在内存中（Sync 能处理）时直接让位给 Sync。
    if (roomId != null && _client.getRoomById(roomId) != null) {
      debugLog(
        'FirebasePushService: Foreground FCM for known room $roomId '
        '— deferring to Matrix sync for full-content notification',
      );
      return;
    }

    // FCM/Sync 双通道去重：如果此 eventId 已经显示过通知，跳过
    if (eventId != null && !_markEventAsNotified(eventId)) {
      debugLog(
        'FirebasePushService: Skipping duplicate foreground notification for event $eventId',
      );
      return;
    }

    // Fallback：room 未加载（例如 Sync 尚未完成）或非 Matrix 聊天路径
    final notification = message.notification;
    if (notification != null) {
      showLocalNotification(
        title: notification.title ?? 'New Message',
        body: notification.body ?? '',
        roomId: roomId,
        eventId: eventId,
        imageUrl:
            notification.android?.imageUrl ?? notification.apple?.imageUrl,
      );
    } else {
      showLocalNotification(
        title: 'N42 Chat',
        body: 'You have a new message',
        roomId: roomId,
        eventId: eventId,
      );
    }
  }

  /// 处理后台推送消息的公开入口
  ///
  /// 供主 app 的统一后台消息处理器调用。
  /// 由于 `FirebaseMessaging.onBackgroundMessage` 全局只能注册一个处理器，
  /// 主 app 应在其统一处理器中判断消息类型，将 Matrix/Chat 消息委托给此方法。
  static Future<void> handleBackgroundMessage(RemoteMessage message) =>
      _handleBackgroundMessage(message);

  /// 测试入口：显示后台 CallKit
  @visibleForTesting
  static Future<void> showBackgroundCallKitForTest(RemoteMessage message) =>
      _showBackgroundCallKit(message);

  /// 测试入口：处理后台消息（handleBackgroundMessage 的别名）
  @visibleForTesting
  static Future<void> handleBackgroundMessageForTest(RemoteMessage message) =>
      _handleBackgroundMessage(message);

  /// 处理后台消息（静态方法）
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    final eventType = message.data['type'] as String?;

    // m.call.invite: 后台来电，直接触发 CallKit 显示来电界面
    if (eventType == 'm.call.invite') {
      debugLog(
        'FirebasePushService: Background call invite received, showing CallKit',
      );
      try {
        await _showBackgroundCallKit(message);
      } catch (e) {
        debugLog('FirebasePushService: Failed to show background CallKit: $e');
      }
      return;
    }

    // m.call.hangup/reject: 对方取消或拒接 → 结束后台 CallKit 来电界面
    if (eventType == 'm.call.hangup' || eventType == 'm.call.reject') {
      debugLog(
        'FirebasePushService: Background $eventType received, ending CallKit',
      );
      try {
        await FlutterCallkitIncoming.endAllCalls();
      } catch (e) {
        debugLog(
          'FirebasePushService: Failed to end CallKit on $eventType: $e',
        );
      }
      return;
    }

    // 其他 m.call.* 事件（如 m.call.candidates, m.call.answer）跳过
    if (eventType != null && eventType.startsWith('m.call.')) {
      debugLog(
        'FirebasePushService: Skipping background notification for call event: $eventType',
      );
      return;
    }

    // 如果有 notification payload，Firebase 会自动显示通知，无需手动处理
    if (message.notification != null) {
      return;
    }

    // 先加载配置检查是否应该显示通知（避免在 DND/禁用时浪费资源初始化插件）
    final config = await _loadPersistedNotificationConfig();
    if (!config.enabled || config.isInDoNotDisturbPeriod()) {
      debugLog(
        'FirebasePushService: Skipping background local notification due to saved config',
      );
      return;
    }

    // 后台消息在单独的 isolate 中运行，需要初始化本地通知
    if (_localNotifications == null) {
      _localNotifications = FlutterLocalNotificationsPlugin();

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings();
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // 必须绑定后台点击响应，否则用户点击后台 isolate 弹出的通知后
      // payload 会丢失，主 app 启动后无从跳转到对应房间。
      await _localNotifications!.initialize(
        settings: initSettings,
        onDidReceiveBackgroundNotificationResponse:
            _onBackgroundNotificationResponse,
      );

      await _ensureAndroidMessageChannels();
    }

    final roomId = message.data['room_id'] as String?;
    final eventId = message.data['event_id'] as String?;
    final payload = json.encode({'room_id': roomId, 'event_id': eventId});
    final notificationId = _nextNotificationId();

    final androidDetails = _androidMessageDetails(
      config,
      importance: Importance.high,
      priority: Priority.high,
    );

    final iosDetails = _iosMessageDetails(config);

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final presentation = config.presentMessage(
      title: 'N42 Chat',
      body: 'You have a new message',
    );

    await _localNotifications!.show(
      id: notificationId,
      title: presentation.title,
      body: presentation.body,
      notificationDetails: details,
      payload: payload,
    );
  }

  /// 后台推送触发 CallKit 来电界面（静态方法，可在后台 isolate 中调用）
  static Future<void> _showBackgroundCallKit(RemoteMessage message) async {
    final roomId = message.data['room_id'] as String?;
    final senderId = message.data['sender'] as String?;
    final senderName =
        message.data['sender_display_name'] as String? ??
        message.notification?.title ??
        senderId ??
        'Unknown';
    final ringtonePreference = await IncomingCallRingtonePreference.load();

    final callId = const Uuid().v4();

    final params = CallKitParams(
      id: callId,
      nameCaller: senderName,
      appName: 'N42 Chat',
      handle: senderId ?? '',
      type: 0, // 默认语音（后台推送无法确定通话类型）
      duration: 60000,
      extra: <String, dynamic>{'callerId': senderId, 'roomId': roomId},
      android: buildIncomingCallAndroidParams(
        ringtonePreference: ringtonePreference,
      ),
      ios: buildIncomingCallIOSParams(ringtonePreference: ringtonePreference),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);
    debugLog(
      'FirebasePushService: Background CallKit shown for call $callId from $senderName',
    );
  }

  /// 处理通知点击
  void _handleNotificationTap(RemoteMessage message) {
    try {
      final roomId = message.data['room_id'] as String?;
      final eventId = message.data['event_id'] as String?;
      onNotificationTap?.call(roomId, eventId);
    } catch (e) {
      debugLog('FirebasePushService: Error in notification tap handler: $e');
    }
  }

  /// 本地通知点击响应
  void _onNotificationResponse(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = json.decode(response.payload!);
        final roomId = data['room_id'] as String?;
        final eventId = data['event_id'] as String?;
        onNotificationTap?.call(roomId, eventId);
      } catch (e) {
        // 忽略解析错误
        debugLog('Error: $e');
      }
    }
  }

  /// 后台通知点击响应
  ///
  /// flutter_local_notifications 的本地通知点击 **不会** 触发
  /// FirebaseMessaging.onMessageOpenedApp（那是 FCM 推送的路由）。
  /// 当 app 被杀/在后台时点击本地通知，此函数会在后台 isolate 被调用 —
  /// 我们在这里解析 payload 并转交给冷启动处理逻辑。
  ///
  /// 注意：此函数运行在独立 isolate，无法访问主 isolate 的 onNotificationTap
  /// 回调，所以通过 SharedPreferences 缓存 payload，由主 app 启动后消费。
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    // 缓存到 SharedPreferences，主 isolate 启动时通过
    // consumePendingLocalNotificationTap 消费
    // ignore: discarded_futures
    _persistPendingLocalNotificationTap(payload);
  }

  static const String _pendingLocalNotificationKey =
      'n42_chat.pending_local_notification_tap';

  static Future<void> _persistPendingLocalNotificationTap(
    String payload,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_pendingLocalNotificationKey, payload);
    } catch (e) {
      debugLog(
        'FirebasePushService: Failed to persist pending local notification: $e',
      );
    }
  }

  /// 启动时消费 `_onBackgroundNotificationResponse` 缓存的点击 payload
  /// 以及冷启动时通过 `getNotificationAppLaunchDetails` 获取到的 payload。
  /// 应在 initialize() 完成后调用。
  Future<void> consumePendingLocalNotificationTap() async {
    try {
      // 1) 冷启动时通过 getNotificationAppLaunchDetails 获取（从杀死态启动）
      final plugin = _localNotifications;
      if (plugin != null) {
        final details = await plugin.getNotificationAppLaunchDetails();
        if (details != null &&
            details.didNotificationLaunchApp &&
            details.notificationResponse?.payload != null) {
          _dispatchLocalNotificationPayload(
            details.notificationResponse!.payload!,
          );
        }
      }
      // 2) 后台点击 isolate 缓存（进程仍在时通常直接走 onDidReceiveNotificationResponse）
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_pendingLocalNotificationKey);
      if (cached != null && cached.isNotEmpty) {
        await prefs.remove(_pendingLocalNotificationKey);
        _dispatchLocalNotificationPayload(cached);
      }
    } catch (e) {
      debugLog(
        'FirebasePushService: Failed to consume pending local notification tap: $e',
      );
    }
  }

  void _dispatchLocalNotificationPayload(String payload) {
    try {
      final data = json.decode(payload);
      if (data is! Map) return;
      final roomId = data['room_id'] as String?;
      final eventId = data['event_id'] as String?;
      onNotificationTap?.call(roomId, eventId);
    } catch (e) {
      debugLog(
        'FirebasePushService: Failed to dispatch local notification payload: $e',
      );
    }
  }

  /// 处理 Matrix 同步更新（用于本地通知）
  void _handleSyncUpdate(matrix.SyncUpdate syncUpdate) {
    try {
      _handleSyncUpdateImpl(syncUpdate);
    } catch (e, st) {
      // StreamSubscription 异常会中断后续 sync，必须吞掉并记录
      debugLog('FirebasePushService: _handleSyncUpdate error: $e\n$st');
    }
  }

  void _handleSyncUpdateImpl(matrix.SyncUpdate syncUpdate) {
    if (!_notificationConfig.enabled) return;

    final joinedRooms = syncUpdate.rooms?.join;
    if (joinedRooms == null) return;

    // 记录当前同步时间
    final syncTime = DateTime.now();

    // 首次同步时，只记录时间，不弹通知（避免历史消息弹通知）
    if (_lastSyncTime == null) {
      _lastSyncTime = syncTime;
      debugLog(
        'FirebasePushService: First sync, skipping notifications for historical messages',
      );
      return;
    }

    for (final entry in joinedRooms.entries) {
      final roomId = entry.key;
      final roomUpdate = entry.value;
      final events = roomUpdate.timeline?.events ?? [];

      for (final event in events) {
        if (_shouldShowNotification(event, roomId)) {
          _showNotificationForEvent(roomId, event);
        }
      }
    }

    _lastSyncTime = syncTime;
  }

  bool _shouldShowNotification(matrix.MatrixEvent event, String roomId) {
    // 通话期间禁用所有消息通知
    if (_isInCall) {
      debugLog('FirebasePushService: Skipping notification during call');
      return false;
    }

    // 过滤通话相关事件（m.call.*）- 这些由 CallKit 通知处理
    final eventType = event.type;
    if (eventType.startsWith('m.call.')) {
      // 收到来电事件时，立即设置通话状态，防止后续消息通知
      if (eventType == 'm.call.invite' && event.senderId != _client.userID) {
        setInCall(true);
        debugLog(
          'FirebasePushService: Set isInCall=true for incoming call event',
        );
      }
      // 对方挂断或拒接 → 清除通话状态
      if (eventType == 'm.call.hangup' || eventType == 'm.call.reject') {
        if (_isInCall) {
          setInCall(false);
          debugLog('FirebasePushService: Cleared _isInCall on sync $eventType');
        }
      }
      debugLog(
        'FirebasePushService: Skipping notification for call event: $eventType',
      );
      return false;
    }

    // 只显示消息类型的通知
    if (eventType != matrix.EventTypes.Message) return false;

    // 不显示自己发送的消息
    if (event.senderId == _client.userID) return false;

    // 不显示当前正在查看的房间的消息
    if (_activeRoomId == roomId) {
      debugLog(
        'FirebasePushService: Skipping notification for active room $roomId',
      );
      return false;
    }

    // 检查消息时间戳，只显示新消息的通知
    final originServerTs = event.originServerTs;
    if (_lastSyncTime != null) {
      // 只显示在上次同步之后产生的消息
      // 给 5 秒的容差，避免网络延迟导致的问题
      final threshold = _lastSyncTime!.subtract(const Duration(seconds: 5));
      if (originServerTs.isBefore(threshold)) {
        debugLog(
          'FirebasePushService: Skipping notification for old message (${originServerTs.toIso8601String()})',
        );
        return false;
      }
    }

    // 检查房间是否静音
    final room = _client.getRoomById(roomId);
    if (room == null) {
      return !_notificationConfig.isInDoNotDisturbPeriod();
    }

    final notificationMode = conversationNotificationModeFromPushRuleState(
      room.pushRuleState,
    );
    if (!shouldNotifyForConversationMode(
      mode: notificationMode,
      event: event,
      currentUserId: _client.userID,
      client: _client,
      room: room,
    )) {
      return false;
    }

    // 检查免打扰
    if (_notificationConfig.isInDoNotDisturbPeriod()) {
      return false;
    }

    // FCM/Sync 双通道去重：如果此 eventId 已经通过 FCM 前台通知显示过，跳过
    if (!_markEventAsNotified(event.eventId)) {
      debugLog(
        'FirebasePushService: Skipping duplicate sync notification for event ${event.eventId}',
      );
      return false;
    }

    return true;
  }

  void _showNotificationForEvent(String roomId, matrix.MatrixEvent event) {
    final room = _client.getRoomById(roomId);
    if (room == null) return;

    final senderName = room
        .unsafeGetUserFromMemoryOrFallback(event.senderId)
        .calcDisplayname();
    final roomName = room.getLocalizedDisplayname();
    final body = _getNotificationBody(event);

    String title;
    if (room.isDirectChat) {
      title = senderName;
    } else {
      title = roomName;
    }

    showLocalNotification(
      title: title,
      body: body,
      roomId: roomId,
      eventId: event.eventId,
    );
  }

  String _getNotificationBody(matrix.MatrixEvent event) {
    final content = event.content;
    final msgType = content['msgtype'] as String?;

    switch (msgType) {
      case 'm.text':
        return content['body'] as String? ?? '';
      case 'm.image':
        return '[Image]';
      case 'm.video':
        return '[Video]';
      case 'm.audio':
        return '[Voice Message]';
      case 'm.file':
        return '[File]';
      case 'm.location':
        return '[Location]';
      case 'm.sticker':
        return '[Sticker]';
      default:
        return '[Message]';
    }
  }

  @override
  Future<void> registerForPush() async {
    if (_isRegistering) {
      debugLog('[PUSH_REG] Push registration already in progress, waiting...');
      await _registrationCompleter?.future;
      return;
    }
    _isRegistering = true;
    _registrationCompleter = Completer<void>();
    debugLog('[PUSH_REG] Starting push registration...');
    try {
      await _registerForPushImpl();
    } finally {
      _isRegistering = false;
      _registrationCompleter?.complete();
      _registrationCompleter = null;
      debugLog(
        '[PUSH_REG] Push registration flow completed (verified=$_isPusherVerified)',
      );
    }
  }

  Future<void> _registerForPushImpl() async {
    // 如果 FCM Token 还没有获取到，尝试获取
    if (_fcmToken == null) {
      debugLog('[PUSH_REG] FCM token is null, attempting to get token...');
      _fcmToken = await _getFCMTokenWithRetry(maxRetries: 2);
    }

    if (_fcmToken == null) {
      debugLog('[PUSH_REG_FAIL] Cannot register push - FCM token is null');
      return;
    }
    if (pushGatewayUrl == null) {
      debugLog('[PUSH_REG_FAIL] Cannot register push - pushGatewayUrl is null');
      return;
    }

    // iOS: 优先使用 APNs token 作为 pushkey
    // Sygnal 服务器为 iOS (appId=*.ios) 通常配置 type: apns，需要 APNs device token
    // Android: 使用 FCM token
    final String pushkey;
    if (Platform.isIOS && _apnsToken != null) {
      pushkey = _apnsToken!;
      debugLog('[PUSH_REG] iOS using APNs token as pushkey');
    } else {
      pushkey = _fcmToken!;
      debugLog('[PUSH_REG] Using FCM token as pushkey');
    }

    final previousPushkey = await _getStoredPushkey();
    if (previousPushkey != null && previousPushkey != pushkey) {
      await _deletePusherByKey(previousPushkey);
    }

    // 指数退避重试：最多 3 次（初始 + 2 次重试），间隔 4s、8s
    const maxAttempts = 3;
    debugLog(
      '[PUSH_REG] Config: appId=$appId, type=$pushkeyType, '
      'gateway=$pushGatewayUrl, pushkey=${_truncateToken(pushkey)}...',
    );

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      // 每次重试前检查登录状态
      if (!_client.isLogged()) {
        debugLog(
          '[PUSH_REG_FAIL] Client not logged in, aborting push registration',
        );
        return;
      }

      try {
        debugLog(
          '[PUSH_REG] Registering pusher (attempt $attempt/$maxAttempts)...',
        );

        // 注册 Pusher 到 Matrix 服务器
        await _client.postPusher(
          matrix.Pusher(
            pushkey: pushkey,
            kind: pushkeyType,
            appId: appId,
            appDisplayName: 'N42 Chat',
            deviceDisplayName: _client.deviceName ?? 'Unknown Device',
            lang: 'en',
            data: matrix.PusherData(
              url: Uri.parse(pushGatewayUrl!),
              // iOS (APNs): 不使用 event_id_only，让 Sygnal 发送完整通知内容
              // (包含 alert/sound/badge)，否则 APNs 只收到静默推送不会显示给用户。
              // Android (FCM): 使用 event_id_only，由 Firebase onBackgroundMessage 处理。
              format: Platform.isIOS ? null : 'event_id_only',
            ),
          ),
          append: false,
        );
        debugLog(
          '[PUSH_REG_OK] Pusher registered successfully on attempt $attempt',
        );

        // 注册成功后验证 Pusher 是否确实存在于服务器
        await _verifyPusherRegistration(pushkey);
        _lastRegisteredPushkey = pushkey;
        await _storePushkey(pushkey);
        return; // 成功，退出重试循环
      } catch (e) {
        debugLog('[PUSH_REG_FAIL] Attempt $attempt/$maxAttempts failed: $e');
        if (attempt < maxAttempts) {
          final delay = Duration(seconds: 4 * attempt); // 4s, 8s
          debugLog('[PUSH_REG] Retrying in ${delay.inSeconds}s...');
          await Future<void>.delayed(delay);
        } else {
          debugLog(
            '[PUSH_REG_FAIL] All $maxAttempts attempts exhausted, push registration failed',
          );
        }
      }
    }
  }

  /// 验证 Pusher 注册是否成功
  ///
  /// 调用 getPushers() 确认当前 pushkey 的 Pusher 已存在于服务器
  Future<void> _verifyPusherRegistration(String pushkey) async {
    try {
      final pushers = await _client.getPushers();
      if (pushers == null) {
        debugLog('[PUSH_VERIFY_WARN] getPushers() returned null');
        _isPusherVerified = false;
        return;
      }

      final found = pushers.any(
        (p) => p.pushkey == pushkey && p.appId == appId,
      );

      _isPusherVerified = found;
      if (found) {
        debugLog('[PUSH_VERIFY_OK] Pusher verified on server (appId=$appId)');
      } else {
        debugLog(
          '[PUSH_VERIFY_FAIL] Pusher NOT found on server after registration! '
          'Registered ${pushers.length} pushers, none match appId=$appId',
        );
      }
    } catch (e) {
      debugLog('[PUSH_VERIFY_FAIL] Verification failed: $e');
      _isPusherVerified = false;
    }
  }

  /// Pusher 是否已通过服务端验证
  bool get isPusherVerified => _isPusherVerified;

  /// 获取推送诊断信息
  ///
  /// 返回当前推送状态的详细信息，用于调试
  Map<String, dynamic> getDiagnosticInfo() {
    final String status;
    if (!_isInitialized) {
      status = 'not_initialized';
    } else if (_isPusherVerified) {
      status = 'registered_verified';
    } else if (_isRegistering) {
      status = 'registering';
    } else {
      status = 'initialized';
    }

    return {
      'status': status,
      'isInitialized': _isInitialized,
      'fcmToken': _fcmToken != null ? '${_truncateToken(_fcmToken!)}...' : null,
      'apnsToken': _apnsToken != null
          ? '${_truncateToken(_apnsToken!)}...'
          : null,
      'pushGatewayUrl': pushGatewayUrl,
      'appId': appId,
      'pushkeyType': pushkeyType,
      'isPusherVerified': _isPusherVerified,
      'isRegistering': _isRegistering,
      'clientIsLogged': _client.isLogged(),
      'platform': Platform.isIOS ? 'iOS' : 'Android',
    };
  }

  /// 安全截取 token 前缀用于日志（避免 RangeError）
  static String _truncateToken(String token, [int length = 10]) {
    return token.length > length ? token.substring(0, length) : token;
  }

  /// 强制重新注册推送
  ///
  /// 清除验证状态并重新执行注册流程。
  /// 如果当前有注册正在进行，等待其完成后再触发新的注册。
  Future<void> forceReRegister() async {
    debugLog('[PUSH_REG] Force re-register requested');
    _isPusherVerified = false;

    // 如果正在注册中，等待其完成后再触发（Completer 替代 busy-wait）
    if (_isRegistering) {
      debugLog(
        '[PUSH_REG] Waiting for current registration to complete before force re-register...',
      );
      await _registrationCompleter?.future;
    }

    await registerForPush();
  }

  @override
  Future<void> unregisterPush() async {
    final pushkeys = <String>{};
    if (Platform.isIOS && _apnsToken != null) {
      pushkeys.add(_apnsToken!);
    } else {
      if (_fcmToken != null) {
        pushkeys.add(_fcmToken!);
      }
    }
    final storedPushkey = await _getStoredPushkey();
    if (storedPushkey != null) {
      pushkeys.add(storedPushkey);
    }
    if (_lastRegisteredPushkey != null) {
      pushkeys.add(_lastRegisteredPushkey!);
    }
    for (final pushkey in pushkeys) {
      await _deletePusherByKey(pushkey);
    }
    _lastRegisteredPushkey = null;
    _isPusherVerified = false;
    // 登出时清理通知相关的内存状态（即使没有 pushkey 可删除也要执行），
    // 避免新账号复用旧 eventId 被误去重，或 clearNotificationsForRoom 时
    // 取消到旧账号遗留的通知 ID。
    _recentlyNotifiedEventIds.clear();
    _roomNotificationIds.clear();
    _lastSyncTime = null;
    await _clearStoredPushkey();
    // 清理系统通知栏中的旧账号残留通知
    if (_localNotifications != null) {
      try {
        await _localNotifications!.cancelAll();
      } catch (e) {
        debugLog(
          'FirebasePushService: Failed to cancel notifications on unregister: $e',
        );
      }
    }
  }

  Future<void> _deletePusherByKey(String pushkey) async {
    try {
      await _client.deletePusher(
        matrix.Pusher(
          pushkey: pushkey,
          kind: '',
          appId: appId,
          appDisplayName: 'N42 Chat',
          deviceDisplayName: _client.deviceName ?? 'Unknown Device',
          lang: 'en',
          data: matrix.PusherData(),
        ),
      );
    } catch (e) {
      debugLog('FirebasePushService: Failed to delete pusher $pushkey: $e');
    }
  }

  String _pushkeyStorageKey() {
    final userId = _client.userID ?? 'unknown_user';
    final deviceId = _client.deviceID ?? 'unknown_device';
    return 'n42_chat.last_pushkey.$appId.$userId.$deviceId';
  }

  Future<String?> _getStoredPushkey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pushkeyStorageKey());
  }

  Future<void> _storePushkey(String pushkey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pushkeyStorageKey(), pushkey);
  }

  Future<void> _clearStoredPushkey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pushkeyStorageKey());
  }

  @override
  Future<void> handleNotification(Map<String, dynamic> message) async {
    final roomId = message['room_id'] as String?;
    final eventId = message['event_id'] as String?;
    onNotificationTap?.call(roomId, eventId);
  }

  @override
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? roomId,
    String? eventId,
    String? imageUrl,
  }) async {
    if (_localNotifications == null) return;

    try {
      // 构建 payload
      final payload = json.encode({'room_id': roomId, 'event_id': eventId});

      // 使用原子计数器生成唯一通知 ID（避免时间戳在同一毫秒内碰撞）
      final notificationId = _nextNotificationId();
      if (roomId != null) {
        final ids = _roomNotificationIds[roomId] ??= [];
        ids.add(notificationId);
        // 限制每个房间最多保留 50 个通知 ID，超出时丢弃最旧的
        if (ids.length > 50) {
          ids.removeRange(0, ids.length - 50);
        }
      }

      // Android 通知详情
      // fullScreenIntent 仅用于来电/闹钟等必须立即响应的通知；
      // 普通消息通知启用会打断用户当前操作，不可使用。
      final androidDetails = _androidMessageDetails(
        _notificationConfig,
        groupKey: 'n42_chat_messages',
        category: AndroidNotificationCategory.message,
      );

      // iOS 通知详情
      final iosDetails = _iosMessageDetails(_notificationConfig);

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final presentation = _notificationConfig.presentMessage(
        title: title,
        body: body,
      );

      await _localNotifications!.show(
        id: notificationId,
        title: presentation.title,
        body: presentation.body,
        notificationDetails: details,
        payload: payload,
      );
    } catch (e) {
      // 忽略通知显示错误
      debugLog('Error: $e');
    }
  }

  @override
  Future<void> clearNotificationsForRoom(String roomId) async {
    if (_localNotifications == null) return;
    final ids = _roomNotificationIds.remove(roomId);
    if (ids != null && ids.isNotEmpty) {
      await Future.wait(ids.map((id) => _localNotifications!.cancel(id: id)));
    }
  }

  @override
  Future<void> clearAllNotifications() async {
    if (_localNotifications == null) return;
    await _localNotifications!.cancelAll();
  }

  @override
  Future<NotificationPermissionStatus> getPermissionStatus() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();

    switch (settings.authorizationStatus) {
      case AuthorizationStatus.authorized:
        return NotificationPermissionStatus.granted;
      case AuthorizationStatus.denied:
        return NotificationPermissionStatus.denied;
      case AuthorizationStatus.notDetermined:
        return NotificationPermissionStatus.notDetermined;
      case AuthorizationStatus.provisional:
        return NotificationPermissionStatus.granted;
    }
  }

  @override
  Future<bool> requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// 获取当前 FCM Token
  String? get fcmToken => _fcmToken;

  /// 获取当前 APNs Token (iOS only)
  String? get apnsToken => _apnsToken;

  /// 释放资源
  Future<void> dispose() async {
    await _foregroundSubscription?.cancel();
    await _messageOpenedSubscription?.cancel();
    await _tokenRefreshSubscription?.cancel();
    await _syncSubscription?.cancel();
    _callStateResetTimer?.cancel();
    _roomNotificationIds.clear();
    _recentlyNotifiedEventIds.clear();
    _isInitialized = false;
  }
}

/// Firebase 推送服务构建器
class FirebasePushServiceBuilder {
  matrix.Client? _client;
  String? _pushGatewayUrl;
  String _appId = 'com.n42.chat';
  String _pushkeyType = 'http';
  void Function(String?, String?)? _onNotificationTap;

  FirebasePushServiceBuilder();

  FirebasePushServiceBuilder withClient(matrix.Client client) {
    _client = client;
    return this;
  }

  FirebasePushServiceBuilder withPushGatewayUrl(String url) {
    _pushGatewayUrl = url;
    return this;
  }

  FirebasePushServiceBuilder withAppId(String appId) {
    _appId = appId;
    return this;
  }

  FirebasePushServiceBuilder withPushkeyType(String type) {
    _pushkeyType = type;
    return this;
  }

  FirebasePushServiceBuilder withNotificationTapHandler(
    void Function(String? roomId, String? eventId) handler,
  ) {
    _onNotificationTap = handler;
    return this;
  }

  FirebasePushService build() {
    if (_client == null) {
      throw StateError('Matrix client is required');
    }

    return FirebasePushService(
      _client!,
      pushGatewayUrl: _pushGatewayUrl,
      appId: _appId,
      pushkeyType: _pushkeyType,
      onNotificationTap: _onNotificationTap,
    );
  }
}
