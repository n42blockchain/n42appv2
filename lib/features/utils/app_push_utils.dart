// android通知的通道

import 'dart:async';
import 'dart:convert';

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/features/utils/chat_push_routing.dart';
import 'package:n42_wallet/features/utils/chat_tap_dedup.dart';
import 'package:n42_wallet/main.dart' show globalProviderContainer;
import 'package:n42_wallet/features/browser/pages/browser_page.dart';
import 'package:n42_wallet/features/home/setting/about_app.dart';
import 'package:n42_wallet/features/home/setting/personal_setting.dart';
import 'package:n42_wallet/features/home/setting/setting_share.dart';
import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/features/auth/data/models/device_login_info.dart';
import 'package:n42_wallet/features/utils/device_info_util.dart';
import 'package:n42_wallet/features/wallet/utils/browser/browser_txhash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:n42_chat/n42_chat.dart'
    show FirebasePushService, N42Chat, PushDedupStore;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_new_badger/flutter_new_badger.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:permission_handler/permission_handler.dart';

part 'app_push_navigation.dart';

late AndroidNotificationChannel channel;

//本地通知插件对象
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

class AppPushUtils {
  static FlutterLocalNotificationsPlugin? _bgLocalNotifications;

  static Future<FlutterLocalNotificationsPlugin>
  _initBgLocalNotifications() async {
    final plugin = FlutterLocalNotificationsPlugin();
    const android = AndroidInitializationSettings('push_small_icon');
    const ios = DarwinInitializationSettings();
    await plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );
    return plugin;
  }

  static const Duration _chatTapDedupWindow = Duration(seconds: 8);
  static String? _pendingChatRoomId;
  static String? _pendingChatEventId;
  static String? _lastHandledChatRoomId;
  static String? _lastHandledChatEventId;
  static DateTime? _lastHandledChatTapAt;
  static bool _isFlushing = false;

  /// 返回设备的令牌Token
  /// Returns the default FCM token for this device.
  static Future<String?> getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    return token;
  }

  static Future<String?> getAPNsToken() async {
    String? token = await FirebaseMessaging.instance.getAPNSToken();
    return token;
  }

  /// 初始化
  static Future<void> init() async {
    ///订阅主题 服务器可以向订阅主题的一部分人发送通知
    // await FirebaseMessaging.instance.subscribeToTopic('主题');

    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      // description
      importance: Importance.max,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    /// iOS 前台统一策略：系统级前台展示（alert/sound）关闭，所有前台
    /// 通知一律由 onMessage 监听手动弹本地通知。开启 alert 会导致同一条
    /// APNs 推送「系统横幅 + 本地通知」双显。n42_chat FirebasePushService
    /// 初始化时会按相同策略覆盖此选项（同样 alert: false）。
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: false,
          badge: true,
          sound: false,
        );

    /// 宿主与 n42_chat 共享同一个 FlutterLocalNotificationsPlugin 单例，
    /// n42_chat 后初始化会覆盖这里注册的点击回调。注册回退处理器后，
    /// 非聊天 payload（无 room_id）的本地通知点击会被 n42_chat 转交回来，
    /// 宿主通知（交易、设备登录）的点击跳转才能保持有效。
    FirebasePushService.hostFallbackNotificationTapHandler =
        _onSelectNotification;

    // Pixel 6手机上小 图标显示白色小方块
    // 解决方案参考： https://blog.csdn.net/SImple_a/article/details/103594842
    // 判断手机 设置不同的图片  version 》 android 8.0 透明
    // 国内手机厂商修改了系统 不存在这个问题 考虑到应用发布到国外，这里需要处理
    var android =
        // const AndroidInitializationSettings('@mipmap/ic_launcher');
        const AndroidInitializationSettings('push_small_icon');
    // var ios = const IOSInitializationSettings();
    var ios = const DarwinInitializationSettings(requestAlertPermission: true);

    // flutter_local_notifications 20.0.0 使用命名参数
    FlutterLocalNotificationsPlugin().initialize(
      settings: InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        String? payload = details.payload;
        _onSelectNotification(payload);
      },
    );

    ///ios , mac, web需要请求权限
    NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
    //android上不需要考虑权限的问题
    AppLogger.d(
      'AppPush',
      'permission status: ${settings.authorizationStatus}',
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      AppLogger.d('AppPush', 'user granted provisional permission');
    } else {
      // 用户拒绝或者未接受许可
      // 在基于 Apple 的平台上，一旦用户处理了权限请求（授权或拒绝），就无法重新请求权限。用户必须改为通过设备设置 UI 更新权限：
      // 如果用户完全拒绝权限，他们必须完全启用应用权限。
      // 如果用户接受请求的权限（无声音），他们必须己专门启用声音选项。
      AppLogger.d('AppPush', 'user declined or has not accepted permission');
      //首次安装应用 同意之后 也会执行这里的逻辑
    }

    ///前台消息
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      AppLogger.d(
        'AppPush',
        'foreground message: id=${message.messageId} type=${message.messageType} '
            'senderId=${message.senderId} from=${message.from} '
            'collapseKey=${message.collapseKey} ttl=${message.ttl} '
            'sentTime=${message.sentTime} category=${message.category} '
            'notification=${message.notification?.toMap()} data=${message.data}',
      );

      try {
        // Matrix chat 推送（含 room_id 或 type 为 m.call.*）由 n42_chat 插件处理
        if (isChatPushPayload(message.data)) {
          AppLogger.d(
            'AppPush',
            'chat/Matrix notification — handled by n42_chat plugin',
          );
          return;
        }

        // 新设备登录通知 — 前台直接通过 EventBus 弹窗，不走通知栏
        final dataType = message.data['type'];
        if (dataType == 'device_login') {
          await _handleDeviceLoginNotification(message.data);
          return;
        }

        final jsonStr = json.encode(message.data);
        if (message.notification != null) {
          _updateBadgeCount();
          //消息类型
          String nType = message.data['type'] ?? '';
          //不弹窗 normal_followed关注,normal_transaction_failed交易失败
          if (nType == "normal_followed" ||
              nType == "normal_transaction_failed" ||
              nType == "market_nft_sell_to_consumer" ||
              nType == "auction_nft_sell_to_consumer" ||
              nType == "auction_nft_bid_to_consumer" ||
              nType == "normal_trending") {
          } else {
            RemoteNotification? notification = message.notification;

            if (notification != null) {
              // FCM at-least-once 投递可能重复送达同一条消息，
              // 按 messageId 去重；通知 ID 取稳定哈希，重复展示时
              // 原地覆盖而非在通知栏叠加。
              final dedupKey = message.messageId;
              if (dedupKey != null &&
                  !await PushDedupStore.instance.tryMarkNotified(dedupKey)) {
                AppLogger.d(
                  'AppPush',
                  'skipping duplicate foreground notification ($dedupKey)',
                );
                return;
              }
              flutterLocalNotificationsPlugin.show(
                id: dedupKey != null
                    ? PushDedupStore.notificationIdForKey(dedupKey)
                    : notification.hashCode,
                title: notification.title,
                body: notification.body,
                notificationDetails: NotificationDetails(
                  android: AndroidNotificationDetails(
                    channel.id,
                    channel.name,
                    channelDescription: channel.description,
                    color: Colors.black,
                  ),
                  iOS: const DarwinNotificationDetails(
                    presentAlert: true,
                    presentBadge: true,
                    presentSound: true,
                  ),
                ),
                payload: jsonStr,
              );
            }
          }
        }
      } catch (err) {
        AppLogger.w('AppPush', 'foreground message parse failed: $err');
      }
    });

    ///后台消息
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    ///点击后台消息打开App
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.d(
        'AppPush',
        'opened from background: notification=${message.notification?.toMap()} '
            'data=${message.data}',
      );

      if (isMatrixCallPayload(message.data)) {
        AppLogger.d(
          'AppPush',
          'call notification tap — letting CallKit/sync handle the call flow',
        );
        return;
      }
      final roomId = extractChatRoomId(message.data);
      if (roomId != null) {
        AppLogger.d(
          'AppPush',
          'chat/Matrix notification tap — delegating to n42_chat',
        );
        _queuePendingChatNotification(
          roomId: roomId,
          eventId: extractChatEventId(message.data),
        );
        // 若 N42Chat 已初始化则立即跳转；否则等 initN42Chat 完成后会调用 flushPendingChatNotification
        if (N42Chat.isInitialized) {
          unawaited(flushPendingChatNotification());
        }
        return;
      }

      /// 打开对应的页面
      _PushNavigation.handleMessage(message.data);
    });

    ///应用从终止状态打开
    var m = await FirebaseMessaging.instance.getInitialMessage();
    if (m != null) {
      AppLogger.d(
        'AppPush',
        'cold-start from notification: title=${m.notification?.title} '
            'notification=${m.notification?.toMap()} data=${m.data}',
      );
      if (isMatrixCallPayload(m.data)) {
        AppLogger.d(
          'AppPush',
          'cold-start call notification — letting CallKit/sync handle the call flow',
        );
        return;
      }
      final roomId = extractChatRoomId(m.data);
      if (roomId != null) {
        AppLogger.d(
          'AppPush',
          'cold-start chat notification — delegating to n42_chat',
        );
        _queuePendingChatNotification(
          roomId: roomId,
          eventId: extractChatEventId(m.data),
        );
        return;
      }
      _PushNavigation.handleMessage(m.data);
    }

    //token更新监听
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      AppLogger.d('AppPush', 'firebase messaging token updated: $newToken');
      bindUserPushToken(newToken);
      // Matrix Pusher 的 token 轮换由 n42_chat 插件内部的
      // FirebaseMessaging.onTokenRefresh 监听统一处理，宿主侧不重复注册。
    });
  }

  //绑定用户推送的token
  static Future<void> bindUserPushToken(dynamic newToken) async {}

  ///前台通知点击
  static void _onSelectNotification(String? payload) {
    try {
      AppLogger.d('AppPush', 'foreground notification tap: $payload');

      /// 打开对应的页面
      if (payload != null) {
        // chat 本地通知兜底：n42_chat 完成初始化前（其点击回调尚未覆盖
        // 本回调）用户点击了聊天通知时，走与 FCM 通知点击相同的
        // 排队/flush 流程，而不是落进宿主导航。
        final chatRoute = tryExtractChatRouteFromPayload(payload);
        if (chatRoute != null) {
          _queuePendingChatNotification(
            roomId: chatRoute.roomId,
            eventId: chatRoute.eventId,
          );
          if (N42Chat.isInitialized) {
            unawaited(flushPendingChatNotification());
          }
          return;
        }
        //逻辑处理
        final map = json.decode(payload);
        AppLogger.d('AppPush', 'parsed payload map: $map');
        //建议参数中携带type，区分不同的通知类型，
        _PushNavigation.handleMessage(map);
      }
    } catch (err) {
      AppLogger.w('AppPush', 'foreground tap handler error: $err');
    }
  }

  /// 处理新设备登录推送通知
  /// 校验非自身设备后触发 EventBus 弹窗
  static Future<void> _handleDeviceLoginNotification(
    Map<String, dynamic> data,
  ) async {
    try {
      final currentDeviceId = await DeviceInfoUtil().getOrCreateDeviceId();
      final notifyDeviceId = data['device_id'] as String? ?? '';
      // 如果是自己设备的通知，静默忽略
      if (notifyDeviceId.isNotEmpty && notifyDeviceId == currentDeviceId) {
        AppLogger.d('AppPush', 'device login notification from self, ignoring');
        return;
      }
      final info = DeviceLoginInfo.fromJson(data);
      eventBus.fire(
        EventPublic(EventPublicType.deviceLoginDetected, param: info),
      );
    } catch (e) {
      AppLogger.w('AppPush', 'handle device login notification error: $e');
    }
  }

  ///清除所有通知
  static void cleanNotification() {
    flutterLocalNotificationsPlugin.cancelAll();
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    // 后台 isolate 需要确保 Firebase 已初始化
    await Firebase.initializeApp();

    AppLogger.d(
      'AppPush',
      'background isolate: notification=${message.notification?.toMap()} '
          'data=${message.data}',
    );

    // Matrix/Chat 消息（含 room_id 或 type 为 m.call.*）委托给 n42_chat 插件处理
    // 包括后台来电 CallKit 触发、消息本地通知等
    if (isChatPushPayload(message.data)) {
      AppLogger.d(
        'AppPush',
        'background: Matrix/Chat message — delegating to FirebasePushService',
      );
      await FirebasePushService.handleBackgroundMessage(message);
      return;
    }

    // 新设备登录通知 — 后台显示系统本地通知
    final dataType = message.data['type'];
    if (dataType == 'device_login') {
      // FCM 进程重启场景可能重发同一条消息，按 messageId 去重；
      // 通知 ID 同样由 messageId 派生，不同登录事件各占一条
      // （旧实现固定用 'device_login'.hashCode，多次登录互相覆盖）。
      final dedupKey = message.messageId;
      if (dedupKey != null &&
          !await PushDedupStore.instance.tryMarkNotified(dedupKey)) {
        AppLogger.d(
          'AppPush',
          'background: duplicate device_login push skipped ($dedupKey)',
        );
        return;
      }

      final brand = message.data['device_brand'] ?? '';
      final os = message.data['device_os'] ?? '';
      final deviceName = os.isNotEmpty ? '$brand $os' : brand;

      // 后台 isolate 中 top-level channel/plugin 未初始化，使用静态缓存避免重复初始化
      _bgLocalNotifications ??= await _initBgLocalNotifications();

      const bgChannelId = 'high_importance_channel';
      const bgChannelName = 'High Importance Notifications';

      await _bgLocalNotifications!.show(
        id: dedupKey != null
            ? PushDedupStore.notificationIdForKey(dedupKey)
            : 'device_login'.hashCode,
        title: 'New Device Login',
        body: 'Your account was logged in on $deviceName',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            bgChannelId,
            bgChannelName,
            channelDescription:
                'This channel is used for important notifications.',
            color: Colors.black,
          ),
        ),
        payload: json.encode(message.data),
      );
      return;
    }

    _updateBadgeCountBackground();
    AppLogger.d('AppPush', 'background: app message ${message.messageId}');
  }

  //更新未读消息数（主 isolate 调用，可访问 Riverpod）
  static void _updateBadgeCount() {
    FlutterNewBadger.incrementBadgeCount();
    globalProviderContainer.read(unreadCountProvider.notifier).increment();
  }

  // 后台 isolate 专用：仅更新角标，不访问 Riverpod（globalProviderContainer 在后台 isolate 中未初始化）
  static void _updateBadgeCountBackground() {
    FlutterNewBadger.incrementBadgeCount();
  }

  //清理未读消息数
  static void removeBadgeCount() {
    FlutterNewBadger.removeBadge();
    cleanNotification();
  }

  // 只清理角标，不影响已投递的通知列表。
  static void clearBadgeOnly() {
    FlutterNewBadger.removeBadge();
  }

  static void recordHandledChatNotificationTap({
    String? roomId,
    String? eventId,
  }) {
    if (roomId == null || roomId.isEmpty) {
      return;
    }

    _lastHandledChatRoomId = roomId;
    _lastHandledChatEventId = eventId;
    _lastHandledChatTapAt = DateTime.now();

    if (_matchesChatTap(
      roomId: roomId,
      eventId: eventId,
      otherRoomId: _pendingChatRoomId,
      otherEventId: _pendingChatEventId,
    )) {
      _clearPendingChatNotification();
    }
  }

  static void _queuePendingChatNotification({
    required String roomId,
    String? eventId,
  }) {
    if (_wasChatNotificationHandledRecently(roomId: roomId, eventId: eventId)) {
      return;
    }
    _pendingChatRoomId = roomId;
    _pendingChatEventId = eventId;
  }

  static Future<void> flushPendingChatNotification() async {
    final roomId = _pendingChatRoomId;
    if (roomId == null || !N42Chat.isInitialized) {
      return;
    }
    // 防止并发重入（可从 onMessageOpenedApp、chatUserStream、initN42Chat 同时触发）
    if (_isFlushing) return;
    _isFlushing = true;
    final eventId = _pendingChatEventId;

    if (_wasChatNotificationHandledRecently(roomId: roomId, eventId: eventId)) {
      _clearPendingChatNotification();
      _isFlushing = false;
      return;
    }

    if (!N42Chat.isLoggedIn) {
      for (var i = 0; i < 20; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        if (N42Chat.isLoggedIn) {
          break;
        }
      }
      if (!N42Chat.isLoggedIn) {
        _isFlushing = false;
        return;
      }
    }

    if (_wasChatNotificationHandledRecently(roomId: roomId, eventId: eventId)) {
      _clearPendingChatNotification();
      _isFlushing = false;
      return;
    }

    AppLogger.d(
      'AppPush',
      'flushing pending chat notification: roomId=$roomId, eventId=$eventId',
    );
    try {
      await N42Chat.openConversation(roomId);
      recordHandledChatNotificationTap(roomId: roomId, eventId: eventId);
    } catch (e) {
      AppLogger.w(
        'AppPush',
        'flushPendingChatNotification openConversation error: $e',
      );
    } finally {
      _clearPendingChatNotification();
      _isFlushing = false;
    }
  }

  static bool _wasChatNotificationHandledRecently({
    required String roomId,
    String? eventId,
  }) {
    return wasChatNotificationHandledRecently(
      roomId: roomId,
      eventId: eventId,
      handledRoomId: _lastHandledChatRoomId,
      handledEventId: _lastHandledChatEventId,
      handledAt: _lastHandledChatTapAt,
      now: DateTime.now(),
      dedupWindow: _chatTapDedupWindow,
    );
  }

  static bool _matchesChatTap({
    required String roomId,
    String? eventId,
    required String? otherRoomId,
    String? otherEventId,
  }) {
    return chatTapMatches(
      roomId: roomId,
      eventId: eventId,
      otherRoomId: otherRoomId,
      otherEventId: otherEventId,
    );
  }

  static void _clearPendingChatNotification() {
    _pendingChatRoomId = null;
    _pendingChatEventId = null;
  }

  /// 登录成功后检查推送权限，若未授权则先尝试系统弹窗请求，
  /// 仍被拒绝且用户未选择"不再提醒"时弹对话框引导去设置。
  ///
  /// 适用平台：
  ///   - Android 13+：需要 POST_NOTIFICATIONS 运行时权限
  ///   - iOS：首次通过 FirebaseMessaging 请求，拒绝后只能引导去设置
  ///   - Android < 13：getNotificationSettings 返回 authorized，无需处理
  static Future<void> checkAndPromptPermission() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 800));

      // 先检查当前状态
      var settings = await FirebaseMessaging.instance.getNotificationSettings();

      var enabled =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      if (enabled) return;

      // Android 13+: 尝试通过 permission_handler 触发系统权限弹窗
      // （FirebaseMessaging.requestPermission 在 Android 上不触发系统弹窗）
      if (defaultTargetPlatform == TargetPlatform.android) {
        final status = await Permission.notification.request();
        if (status.isGranted || status.isProvisional) return;
      }

      // iOS: 尝试通过 Firebase 请求权限（首次会弹系统弹窗）
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        settings = await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        enabled =
            settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;
        if (enabled) return;
      }

      // 系统弹窗被拒绝，检查用户是否已选择"不再提醒"
      final dismissed = await SPUtil().getPushPermissionDismissed();
      if (dismissed) return;

      final ctx = AppGlobals.navigatorKey.currentContext;
      if (ctx == null || !ctx.mounted) return;

      final s = S.of(ctx);
      // ignore: use_build_context_synchronously
      await showDialog<void>(
        context: ctx,
        barrierDismissible: false,
        builder: (dialogCtx) => AlertDialog(
          title: Text(s.push_permission_dialog_title),
          content: Text(s.push_permission_dialog_content),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () async {
                await SPUtil().setPushPermissionDismissed(true);
                if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
              },
              child: Text(s.push_permission_btn_dismiss),
            ),
            TextButton(
              onPressed: () {
                if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
              },
              child: Text(s.push_permission_btn_later),
            ),
            TextButton(
              onPressed: () async {
                if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
                await openAppSettings();
              },
              child: Text(s.push_permission_btn_settings),
            ),
          ],
        ),
      );
    } catch (e) {
      AppLogger.w('AppPush', 'checkAndPromptPermission error: $e');
    }
  }

  //显示本地通知 test
  static Future<void> showLocalNotifications() async {
    var androidDetails = AndroidNotificationDetails(
      'nftWallet_channelId', //id可以随意一点
      ///这个会显示在手机设置 通知管理 app 通知设置列表中 不要瞎写
      // '重要通知',
      "channelName",

      ///通知的级别
      importance: Importance.max,
      priority: Priority.high,

      // icon: ''//可以单独设置每次发送通知的图标

      //显示进度条 3个参数必须同时设置
      // progress: 19,
      // maxProgress: 100,
      // showProgress: true

      //是否播放声音
      playSound: true,
    );

    // ios的通知
    const String darwinNotificationCategoryPlain = 'plainCategory';
    DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
          categoryIdentifier: darwinNotificationCategoryPlain,
          presentSound: true,
          presentAlert: true,
          presentBadge: true,
        );
    var notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosNotificationDetails,
    );
    // flutter_local_notifications 20.0.0 使用命名参数
    flutterLocalNotificationsPlugin.show(
      id: 100,
      title: "测试推送",
      body: "你收到了一条消息",
      notificationDetails: notificationDetails,
    );
  }
}
