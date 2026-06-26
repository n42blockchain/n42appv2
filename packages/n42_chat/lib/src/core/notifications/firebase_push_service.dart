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

import '../../domain/entities/user_profile_entity.dart'
    show NotificationPrivacyMode;
import '../../services/voip/call_manager.dart';
import '../../services/voip/incoming_call_ringtone_preference.dart';
import '../../data/datasources/local/preferences_datasource.dart';
import '../utils/conversation_notification_utils.dart';
import 'push_dedup_store.dart';
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

/// 判断一个 sync timeline 事件是否属于「resume catch-up」——
/// app 在后台/锁屏期间产生、回到前台后才由 sync 补拉回来的消息。
///
/// 这类消息在后台期间已经由 FCM 后台 isolate（Android）或 APNs 系统
/// 通知（iOS）展示过；iOS 场景下 Dart 侧完全没被唤醒、去重存储里没有
/// 标记，所以必须用时间闸门兜底，否则解锁瞬间会收到一整波重复通知。
///
/// [tolerance] 吸收服务器与设备的时钟偏差：真正的前台实时消息即使
/// 服务器时钟略慢也不会被误杀（且 FCM 前台路径仍是第一道展示渠道）。
bool isResumeCatchUpEvent({
  required DateTime originServerTs,
  required DateTime lastResumedAt,
  Duration tolerance = const Duration(seconds: 30),
}) {
  return originServerTs.isBefore(lastResumedAt.subtract(tolerance));
}

/// 把 AppLifecycle 回调转发给 [FirebasePushService] 的轻量观察者。
class _PushLifecycleObserver with WidgetsBindingObserver {
  _PushLifecycleObserver(this._onStateChanged);

  final void Function(AppLifecycleState state) _onStateChanged;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _onStateChanged(state);
  }
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

  /// 宿主 app 注册的非聊天本地通知点击回退处理器。
  ///
  /// 宿主与本插件共享同一个 `FlutterLocalNotificationsPlugin` 单例，
  /// 后初始化的一方会覆盖先注册的点击回调（本插件通常后初始化）。
  /// 没有这个回退时，宿主弹的本地通知（交易、设备登录等，payload
  /// 不含 `room_id`）点击后会被本插件吞掉、不再跳转。
  /// 宿主在自己的推送初始化里赋值即可，参数为通知原始 payload。
  static void Function(String payload)? hostFallbackNotificationTapHandler;

  /// 本地通知插件
  static FlutterLocalNotificationsPlugin? _localNotifications;

  /// 冷启动本地通知点击是否已 replay（进程生命周期内仅一次）
  static bool _coldStartTapReplayed = false;

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

  /// 房间 ID → 最后一条通知 ID 的映射（用于 clearNotificationsForRoom）
  final Map<String, int> _roomNotificationIds = {};

  /// 当前活跃的房间 ID（用户正在查看的房间不弹通知）
  String? _activeRoomId;

  /// 是否正在通话中（通话期间禁用所有消息通知）
  bool _isInCall = false;

  /// 上次同步时间（用于过滤旧消息）
  DateTime? _lastSyncTime;

  /// 最近一次回到前台的时刻。构造时即视为前台（app 启动）。
  /// sync 补拉的后台期间消息以此为闸门跳过通知（见 [isResumeCatchUpEvent]）。
  DateTime _lastResumedAt = DateTime.now();

  /// app 是否在前台。activeRoom「正在查看」抑制仅在前台成立。
  /// 真机 T2 #6：Android 进程后台存活时 Matrix sync 仍会投递消息，
  /// 而按 Home 键不会 dispose chat page / 触发 setActiveRoom(null)，
  /// 残留的 activeRoom 会把后台 sync 投递的消息全部静默。后台时
  /// 用户并未「正在查看」，故此抑制必须以前台为前提。
  bool _appInForeground = true;

  /// 生命周期观察者（initialize 注册，dispose 移除）。
  _PushLifecycleObserver? _lifecycleObserver;

  FirebasePushService(
    this._client, {
    this.pushGatewayUrl,
    this.appId = 'com.n42.chat',
    this.pushkeyType = 'http',
    this.onNotificationTap,
  });

  static Future<NotificationConfig> _loadPersistedNotificationConfig() async {
    final settings = await PreferencesDataSource()
        .getNotificationSettingsModel();
    return NotificationConfig.fromSettings(settings);
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
      // 锁屏可见性跟随隐私模式：完整预览 → 锁屏直接显示内容；
      // 否则锁屏只显示应用名（系统默认 private 行为），保证灭屏/
      // 屏保状态下通知依然可见而不泄露内容。
      visibility:
          config.privacyMode == NotificationPrivacyMode.full &&
              config.showPreview
          ? NotificationVisibility.public
          : NotificationVisibility.private,
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
  static Future<NotificationConfig> loadPersistedNotificationConfigForTest() =>
      _loadPersistedNotificationConfig();

  void _applyIOSForegroundPresentationOptions(NotificationConfig config) {
    if (!Platform.isIOS) {
      return;
    }
    // iOS 前台一律由 [_handleForegroundMessage] 手动弹本地通知
    //（带隐私设置与去重），因此必须关闭系统级前台 alert/sound 展示，
    // 否则同一条 APNs 推送会出现「系统横幅 + 本地通知」双显。
    // badge 仍交给系统按 payload 维护。
    unawaited(
      FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: false,
        badge: config.enabled,
        sound: false,
      ),
    );
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
      // 安全机制：10 分钟后自动重置，防止状态泄漏
      // （正常通话会由 CallManager 主动调用 setInCall(false)）
      _callStateResetTimer = Timer(const Duration(minutes: 10), () {
        if (_isInCall) {
          _isInCall = false;
          debugLog(
            'FirebasePushService: Auto-reset _isInCall after 10min safety timeout',
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

      // 监听 app 前后台切换：回到前台的时刻是 sync catch-up 通知
      // 抑制的闸门（后台期间的消息已由 FCM/APNs 通知过）。
      _lifecycleObserver = _PushLifecycleObserver(_onAppLifecycleChanged);
      WidgetsBinding.instance.addObserver(_lifecycleObserver!);

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

    // 冷启动点击补偿：data-only 推送在后台 isolate 弹的是
    // flutter_local_notifications 本地通知，点击它冷启动 app 时
    // FirebaseMessaging.getInitialMessage 拿不到（那个 API 只覆盖 FCM
    // 系统通知），必须从本地通知插件的启动详情里补回点击事件，
    // 否则用户点了聊天通知却停在首页。
    // 进程生命周期内只 replay 一次：dispose 后重新 initialize（如登出
    // 再登录）时 launch details 仍是旧值，二次 replay 会把用户莫名
    // 跳转回旧会话。
    if (!_coldStartTapReplayed) {
      _coldStartTapReplayed = true;
      try {
        final launchDetails = await _localNotifications!
            .getNotificationAppLaunchDetails();
        final response = launchDetails?.notificationResponse;
        if (launchDetails?.didNotificationLaunchApp == true &&
            response != null) {
          debugLog(
            'FirebasePushService: App launched from local notification, '
            'replaying tap',
          );
          _onNotificationResponse(response);
        }
      } catch (e) {
        debugLog(
          'FirebasePushService: getNotificationAppLaunchDetails failed: $e',
        );
      }
    }
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
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
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
        unawaited(_showBackgroundCallKit(message).catchError((Object e) {
          debugLog(
            'FirebasePushService: Failed to show foreground CallKit fallback: $e',
          );
        }));
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

    // 非聊天推送（无 room_id 且非 m.call.*，上面已过滤 call）不属于
    // 本插件：宿主 app 自己也监听 onMessage 并负责展示。这里若继续
    // 处理，既会弹误导性的「You have a new message」，也会用
    // messageId 抢占去重标记、按监听器注册顺序与宿主竞态。
    if (roomId == null || roomId.isEmpty) {
      debugLog(
        'FirebasePushService: Ignoring non-chat foreground message '
        '(${message.messageId})',
      );
      return;
    }

    // 用户正在查看的房间不弹通知（与 sync 路径的 activeRoom 检查对称）。
    // 不消耗去重标记：sync 路径对活跃房间同样跳过，不会造成重复。
    if (roomId == _activeRoomId) {
      debugLog(
        'FirebasePushService: Skipping foreground notification for active '
        'room $roomId',
      );
      return;
    }

    // 跨通道去重：同一事件可能已经由 Matrix sync 监听（主 isolate）
    // 或 FCM 后台 isolate 弹过通知。
    final dedupKey = PushDedupStore.dedupKeyFor(
      eventId: eventId,
      messageId: message.messageId,
    );
    if (dedupKey != null &&
        !await PushDedupStore.instance.tryMarkNotified(dedupKey)) {
      debugLog(
        'FirebasePushService: Skipping duplicate foreground notification '
        '($dedupKey)',
      );
      return;
    }

    final room = _client.getRoomById(roomId);
    if (room != null) {
      // 检查房间是否静音
      if (room.pushRuleState == matrix.PushRuleState.dontNotify) {
        return;
      }

      // 从房间获取信息显示通知
      final roomName = room.getLocalizedDisplayname();
      await showLocalNotification(
        title: roomName,
        body: 'You have a new message',
        roomId: roomId,
        eventId: eventId,
      );
      return;
    }

    // 房间尚未同步到本地（如刚被拉入的新房间）：退回 notification
    // payload 或通用文案。
    final notification = message.notification;
    if (notification != null) {
      await showLocalNotification(
        title: notification.title ?? 'New Message',
        body: notification.body ?? '',
        roomId: roomId,
        eventId: eventId,
        imageUrl:
            notification.android?.imageUrl ?? notification.apple?.imageUrl,
      );
    } else {
      await showLocalNotification(
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

      await _localNotifications!.initialize(settings: initSettings);

      await _ensureAndroidMessageChannels();
    }

    // 如果没有 notification payload，手动显示通知
    if (message.notification == null) {
      final config = await _loadPersistedNotificationConfig();
      if (!config.enabled || config.isInDoNotDisturbPeriod()) {
        debugLog(
          'FirebasePushService: Skipping background local notification due to saved config',
        );
        return;
      }
      final roomId = message.data['room_id'] as String?;
      final eventId = message.data['event_id'] as String?;

      // 非聊天 data-only 推送不属于本插件（集成模式下宿主已按
      // room_id 过滤后才委托到这里；独立使用模式下也不应为非
      // Matrix 推送弹「You have a new message」误导用户）。
      if (roomId == null || roomId.isEmpty) {
        debugLog(
          'FirebasePushService: Ignoring non-chat background message '
          '(${message.messageId})',
        );
        return;
      }

      // 跨 isolate 去重：app 刚切后台/灭屏时主 isolate 的 sync 监听
      // 往往还活跃，同一事件会同时走 sync 路径和这里的后台 isolate
      // 路径；FCM 自身也可能重发同一条消息（进程重启场景）。
      final dedupKey = PushDedupStore.dedupKeyFor(
        eventId: eventId,
        messageId: message.messageId,
      );
      if (dedupKey != null &&
          !await PushDedupStore.instance.tryMarkNotified(dedupKey)) {
        debugLog(
          'FirebasePushService: Skipping duplicate background notification '
          '($dedupKey)',
        );
        return;
      }

      // 构建 payload
      final payload = json.encode({'room_id': roomId, 'event_id': eventId});

      // 通知 ID 取事件键的稳定哈希：后台 isolate 的内存计数器每次进程
      // 重启都从 0 开始，会把通知栏里的旧通知逐条覆盖掉（用户表现为
      // 「多条消息只剩一条」）；稳定哈希保证不同事件各占一条、同一
      // 事件幂等覆盖。
      final notificationId = dedupKey != null
          ? PushDedupStore.notificationIdForKey(dedupKey)
          : _nextNotificationId();

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
    final payload = response.payload;
    if (payload == null) return;
    try {
      final data = json.decode(payload);
      final roomId = data is Map ? data['room_id'] as String? : null;
      final eventId = data is Map ? data['event_id'] as String? : null;
      if ((roomId == null || roomId.isEmpty) &&
          hostFallbackNotificationTapHandler != null) {
        // 非聊天 payload：这是宿主 app 弹的本地通知（交易、设备登录等）。
        // 因为本插件后初始化、覆盖了共享单例的点击回调，必须转交回
        // 宿主处理，否则宿主通知点击后无任何跳转。
        hostFallbackNotificationTapHandler!(payload);
        return;
      }
      onNotificationTap?.call(roomId, eventId);
    } catch (e) {
      // 忽略解析错误
      debugLog('Error: $e');
    }
  }

  /// 后台通知点击响应
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationResponse(NotificationResponse response) {
    // 后台点击会通过 FirebaseMessaging.onMessageOpenedApp 处理
  }

  /// 处理 Matrix 同步更新（用于本地通知）
  void _handleSyncUpdate(matrix.SyncUpdate syncUpdate) {
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
          unawaited(_showNotificationForEvent(roomId, event));
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

    // 不显示当前正在查看的房间的消息（仅前台成立；后台 sync 投递的
    // 消息即使 activeRoom 残留也应照常通知——见 _appInForeground 注释）
    if (_appInForeground && _activeRoomId == roomId) {
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

    // resume catch-up 抑制：回到前台后 sync 补拉的后台期间消息，
    // 已经由 FCM（Android 后台 isolate）或 APNs 系统通知（iOS，Dart
    // 完全未被唤醒、去重存储无标记）展示过，这里再弹就是解锁瞬间的
    // 重复通知风暴。
    if (isResumeCatchUpEvent(
      originServerTs: originServerTs,
      lastResumedAt: _lastResumedAt,
    )) {
      debugLog(
        'FirebasePushService: Skipping resume catch-up notification '
        '(${originServerTs.toIso8601String()} < resume $_lastResumedAt)',
      );
      return false;
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

    return true;
  }

  Future<void> _showNotificationForEvent(
    String roomId,
    matrix.MatrixEvent event,
  ) async {
    // room 判空必须先于去重标记：若先标记再因 room == null 返回，
    // 标记已被消耗但通知没弹，随后 FCM 路径的同一事件会被去重
    // 跳过，造成通知永久丢失。
    final room = _client.getRoomById(roomId);
    if (room == null) return;

    // 跨通道去重：同一事件可能已由 FCM 前台/后台路径弹过。
    if (!await PushDedupStore.instance.tryMarkNotified(event.eventId)) {
      debugLog(
        'FirebasePushService: Skipping duplicate sync notification '
        '(${event.eventId})',
      );
      return;
    }

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

    await showLocalNotification(
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
      pushLog('REG', 'Push registration already in progress, waiting');
      await _registrationCompleter?.future;
      return;
    }
    _isRegistering = true;
    _registrationCompleter = Completer<void>();
    pushLog('REG', 'Starting push registration');
    try {
      await _registerForPushImpl();
    } finally {
      _isRegistering = false;
      _registrationCompleter?.complete();
      _registrationCompleter = null;
      pushLog(
        'REG',
        'Push registration flow completed (verified=$_isPusherVerified)',
      );
    }
  }

  Future<void> _registerForPushImpl() async {
    // 如果 FCM Token 还没有获取到，尝试获取
    if (_fcmToken == null) {
      pushLog('REG', 'FCM token is null, attempting to get token');
      _fcmToken = await _getFCMTokenWithRetry(maxRetries: 2);
    }

    if (_fcmToken == null) {
      pushLog('REG_FAIL', 'Cannot register push - FCM token is null');
      return;
    }
    if (pushGatewayUrl == null) {
      pushLog('REG_FAIL', 'Cannot register push - pushGatewayUrl is null');
      return;
    }

    // iOS: 优先使用 APNs token 作为 pushkey
    // Sygnal 服务器为 iOS (appId=*.ios) 通常配置 type: apns，需要 APNs device token
    // Android: 使用 FCM token
    final String pushkey;
    if (Platform.isIOS && _apnsToken != null) {
      pushkey = _apnsToken!;
      pushLog('REG', 'iOS using APNs token as pushkey');
    } else {
      pushkey = _fcmToken!;
      pushLog('REG', 'Using FCM token as pushkey');
    }

    final previousPushkey = await _getStoredPushkey();
    if (previousPushkey != null && previousPushkey != pushkey) {
      await _deletePusherByKey(previousPushkey);
    }

    // 指数退避重试：最多 3 次（初始 + 2 次重试），间隔 4s、8s
    const maxAttempts = 3;
    pushLog(
      'REG',
      'Config: appId=$appId, type=$pushkeyType, '
      'gateway=$pushGatewayUrl, pushkey=${_truncateToken(pushkey)}',
    );

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      // 每次重试前检查登录状态
      if (!_client.isLogged()) {
        pushLog('REG_FAIL', 'Client not logged in, aborting push registration');
        return;
      }

      try {
        pushLog('REG', 'Registering pusher (attempt $attempt/$maxAttempts)');

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
        pushLog('REG_OK', 'Pusher registered successfully on attempt $attempt');

        // 注册成功后验证 Pusher 是否确实存在于服务器
        await _verifyPusherRegistration(pushkey);
        _lastRegisteredPushkey = pushkey;
        await _storePushkey(pushkey);
        return; // 成功，退出重试循环
      } catch (e) {
        pushLog('REG_FAIL', 'Attempt $attempt/$maxAttempts failed: $e');
        if (attempt < maxAttempts) {
          final delay = Duration(seconds: 4 * attempt); // 4s, 8s
          pushLog('REG', 'Retrying in ${delay.inSeconds}s');
          await Future<void>.delayed(delay);
        } else {
          pushLog(
            'REG_FAIL',
            'All $maxAttempts attempts exhausted, push registration failed',
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
        pushLog('VERIFY_WARN', 'getPushers() returned null');
        _isPusherVerified = false;
        return;
      }

      final found = pushers.any(
        (p) => p.pushkey == pushkey && p.appId == appId,
      );

      _isPusherVerified = found;
      if (found) {
        pushLog('VERIFY_OK', 'Pusher verified on server (appId=$appId)');
      } else {
        pushLog(
          'VERIFY_FAIL',
          'Pusher NOT found on server after registration! '
          'Registered ${pushers.length} pushers, none match appId=$appId',
        );
      }
    } catch (e) {
      pushLog('VERIFY_FAIL', 'Verification failed: $e');
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
    pushLog('REG', 'Force re-register requested');
    _isPusherVerified = false;

    // 如果正在注册中，等待其完成后再触发（Completer 替代 busy-wait）
    if (_isRegistering) {
      pushLog(
        'REG',
        'Waiting for current registration to complete before force re-register',
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
    if (pushkeys.isEmpty) return;

    for (final pushkey in pushkeys) {
      await _deletePusherByKey(pushkey);
    }
    _lastRegisteredPushkey = null;
    await _clearStoredPushkey();
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

      // 通知 ID：有 event_id 时取稳定哈希——同一事件无论从哪条路径
      // （FCM 前台 / sync / 后台 isolate）弹出都映射到同一 ID，去重
      // 竞态下也只会原地覆盖而不会在通知栏叠加第二条；无 event_id
      // 时退回进程内计数器。
      final notificationId = (eventId != null && eventId.isNotEmpty)
          ? PushDedupStore.notificationIdForKey(eventId)
          : _nextNotificationId();
      // 记录 roomId → notificationId 映射，供 clearNotificationsForRoom 使用
      if (roomId != null) {
        _roomNotificationIds[roomId] = notificationId;
      }

      // Android 通知详情
      final androidDetails = _androidMessageDetails(
        _notificationConfig,
        groupKey: 'n42_chat_messages',
        category: AndroidNotificationCategory.message,
        fullScreenIntent: true,
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
    final notificationId = _roomNotificationIds.remove(roomId);
    if (notificationId != null) {
      await _localNotifications!.cancel(id: notificationId);
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

  void _onAppLifecycleChanged(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _appInForeground = true;
      _lastResumedAt = DateTime.now();
      debugLog('FirebasePushService: App resumed at $_lastResumedAt');
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _appInForeground = false;
      debugLog('FirebasePushService: App backgrounded ($state)');
    }
  }

  /// 测试入口：覆写最近一次回前台时间
  @visibleForTesting
  void setLastResumedAtForTest(DateTime time) {
    _lastResumedAt = time;
  }

  /// 测试入口：覆写前台状态
  @visibleForTesting
  void setAppInForegroundForTest({required bool value}) {
    _appInForeground = value;
  }

  /// 测试入口：暴露通知判定（active-room / resume 闸门等分支）
  @visibleForTesting
  bool shouldShowNotificationForTest(matrix.MatrixEvent event, String roomId) =>
      _shouldShowNotification(event, roomId);

  /// 测试入口：直接驱动 sync 更新处理
  @visibleForTesting
  void handleSyncUpdateForTest(matrix.SyncUpdate syncUpdate) =>
      _handleSyncUpdate(syncUpdate);

  /// 测试入口：直接驱动本地通知点击响应
  @visibleForTesting
  void handleNotificationResponseForTest(NotificationResponse response) =>
      _onNotificationResponse(response);

  /// 测试入口：直接驱动前台消息处理
  @visibleForTesting
  Future<void> handleForegroundMessageForTest(RemoteMessage message) =>
      _handleForegroundMessage(message);

  /// 测试入口：重置冷启动 replay 守卫
  @visibleForTesting
  static void resetColdStartTapReplayForTest() {
    _coldStartTapReplayed = false;
  }

  /// 释放资源
  Future<void> dispose() async {
    await _foregroundSubscription?.cancel();
    await _messageOpenedSubscription?.cancel();
    await _tokenRefreshSubscription?.cancel();
    await _syncSubscription?.cancel();
    _callStateResetTimer?.cancel();
    if (_lifecycleObserver != null) {
      WidgetsBinding.instance.removeObserver(_lifecycleObserver!);
      _lifecycleObserver = null;
    }
    _roomNotificationIds.clear();
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
