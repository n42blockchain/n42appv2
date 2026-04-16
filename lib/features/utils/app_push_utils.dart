// android通知的通道

import 'dart:convert';

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/main.dart' show globalProviderContainer;
import 'package:n42_wallet/features/browser/pages/browser_page.dart';
import 'package:n42_wallet/features/home/setting/about_app.dart';
import 'package:n42_wallet/features/wallet/pages/payment_code/payment_history.dart';
import 'package:n42_wallet/features/home/setting/personal_setting.dart';
import 'package:n42_wallet/features/home/setting/setting_share.dart';
import 'package:n42_wallet/features/login/api/user_info_api.dart';
import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/data/models/device_login_info.dart';
import 'package:n42_wallet/features/utils/device_info_util.dart';
import 'package:n42_wallet/features/login/pages/login_page.dart';
import 'package:n42_wallet/features/notification/pages/message_info.dart';
import 'package:n42_wallet/features/wallet/utils/browser/browser_txhash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:n42_chat/n42_chat.dart' show FirebasePushService, N42Chat;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_new_badger/flutter_new_badger.dart';
import 'package:intl/intl.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:permission_handler/permission_handler.dart';

part 'app_push_navigation.dart';

late AndroidNotificationChannel channel;

//本地通知插件对象
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

class AppPushUtils {
  static const Duration _chatTapDedupWindow = Duration(seconds: 8);
  static String? _pendingChatRoomId;
  static String? _pendingChatEventId;
  static String? _lastHandledChatRoomId;
  static String? _lastHandledChatEventId;
  static DateTime? _lastHandledChatTapAt;

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

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

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
    if (kDebugMode) {
      debugPrint('User granted permission: ${settings.authorizationStatus}');
    }
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode) debugPrint('User granted provisional permission');
    } else {
      // 用户拒绝或者未接受许可
      // 在基于 Apple 的平台上，一旦用户处理了权限请求（授权或拒绝），就无法重新请求权限。用户必须改为通过设备设置 UI 更新权限：
      // 如果用户完全拒绝权限，他们必须完全启用应用权限。
      // 如果用户接受请求的权限（无声音），他们必须己专门启用声音选项。
      if (kDebugMode) {
        debugPrint('User declined or has not accepted permission');
      }
      //首次安装应用 同意之后 也会执行这里的逻辑
    }

    ///前台消息
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (kDebugMode) {
        debugPrint('在前台收到消息！');
        debugPrint('[PushData][Foreground] messageId=${message.messageId}');
        debugPrint('[PushData][Foreground] messageType=${message.messageType}');
        debugPrint('[PushData][Foreground] senderId=${message.senderId}');
        debugPrint('[PushData][Foreground] from=${message.from}');
        debugPrint('[PushData][Foreground] collapseKey=${message.collapseKey}');
        debugPrint('[PushData][Foreground] ttl=${message.ttl}');
        debugPrint('[PushData][Foreground] sentTime=${message.sentTime}');
        debugPrint('[PushData][Foreground] category=${message.category}');
        debugPrint('[PushData][Foreground] notification=${message.notification?.toMap()}');
        debugPrint('[PushData][Foreground] data=${message.data}');
      }

      try {
        // Matrix chat 推送（含 room_id 或 type 为 m.call.*）由 n42_chat 插件处理
        final dataType = message.data['type'] as String?;
        final roomId = message.data['room_id'] as String?;
        if (roomId != null ||
            (dataType != null && dataType.startsWith('m.call.'))) {
          if (kDebugMode) {
            debugPrint('Chat/Matrix notification - handled by n42_chat plugin');
          }
          return;
        }

        // 新设备登录通知 — 前台直接通过 EventBus 弹窗，不走通知栏
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

            ///显示通知
            if (notification != null && notification.android != null) {
              // flutter_local_notifications 20.0.0 使用命名参数
              FlutterLocalNotificationsPlugin().show(
                id: notification.hashCode,
                title: notification.title,
                body: notification.body,
                notificationDetails: NotificationDetails(
                  android: AndroidNotificationDetails(
                    channel.id,
                    channel.name,
                    channelDescription: channel.description,
                    color: Colors.black,
                  ),
                ),
                payload: jsonStr,
              );
            }
          }
        }
      } catch (err) {
        if (kDebugMode) debugPrint("解析失败：${err.toString()}");
      }
    });

    ///后台消息
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    ///点击后台消息打开App
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('从后台打开应用，自动清除通知');
        debugPrint('[PushData][Background] notification=${message.notification?.toMap()}');
        debugPrint('[PushData][Background] data=${message.data}');
      }

      final dataType = message.data['type'] as String?;
      final roomId = message.data['room_id'] as String?;
      final isCallEvent = dataType != null && dataType.startsWith('m.call.');
      if (isCallEvent) {
        if (kDebugMode) {
          debugPrint(
            'Call notification tap - letting CallKit/sync handle the call flow',
          );
        }
        return;
      }
      if (roomId != null) {
        if (kDebugMode) {
          debugPrint('Chat/Matrix notification tap - delegating to n42_chat');
        }
        _queuePendingChatNotification(
          roomId: roomId,
          eventId: message.data['event_id'] as String?,
        );
        // 若 N42Chat 已初始化则立即跳转；否则等 initN42Chat 完成后会调用 flushPendingChatNotification
        if (N42Chat.isInitialized) {
          // ignore: discarded_futures
          flushPendingChatNotification();
        }
        return;
      }

      /// 打开对应的页面
      _PushNavigation.handleMessage(message.data);
    });

    ///应用从终止状态打开
    var m = await FirebaseMessaging.instance.getInitialMessage();
    if (m != null) {
      if (kDebugMode) {
        debugPrint('应用从终止状态打开:${m.notification?.title}');
        debugPrint('[PushData][ColdStart] notification=${m.notification?.toMap()}');
        debugPrint('[PushData][ColdStart] data=${m.data}');
      }
      final dataType = m.data['type'] as String?;
      final roomId = m.data['room_id'] as String?;
      final isCallEvent = dataType != null && dataType.startsWith('m.call.');
      if (isCallEvent) {
        if (kDebugMode) {
          debugPrint(
            'Cold-start call notification - letting CallKit/sync handle the call flow',
          );
        }
        return;
      }
      if (roomId != null) {
        if (kDebugMode) {
          debugPrint('Cold-start chat notification - delegating to n42_chat');
        }
        if (roomId.isNotEmpty) {
          _queuePendingChatNotification(
            roomId: roomId,
            eventId: m.data['event_id'] as String?,
          );
        }
        return;
      }
      _PushNavigation.handleMessage(m.data);
    }

    //token更新监听
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      if (kDebugMode) debugPrint("firebase messaging token updated: $newToken");
      bindUserPushToken(newToken);
      // Matrix Pusher 的 token 轮换由 n42_chat 插件内部的
      // FirebaseMessaging.onTokenRefresh 监听统一处理，宿主侧不重复注册。
    });

  }

  //绑定用户推送的token
  static Future<void> bindUserPushToken(dynamic newToken) async {
    try {
      // 绑定token
      if (kDebugMode) debugPrint('new token : $newToken');
      if (newToken != null && AppGlobals.userInfo != null) {
        UserInfoApi loginApi = UserInfoApi();
        final deviceId = await DeviceInfoUtil().getOrCreateDeviceId();
        final data = await loginApi.bindPushUserToken(
          newToken,
          deviceId: deviceId,
        );
        if (data != null && data["code"] == 200) {
          //success
          if (kDebugMode) debugPrint("更新推送用户Token成功");
        } else {
          if (kDebugMode) debugPrint("更新推送用户Token失败");
        }
      }
    } catch (err) {
      if (kDebugMode) debugPrint("bindUserPushToken err: ${err.toString()}");
    }
  }

  ///前台通知点击
  static void _onSelectNotification(String? payload) {
    try {
      if (kDebugMode) debugPrint('前台通知点击: $payload');

      /// 打开对应的页面
      if (payload != null) {
        //逻辑处理
        final map = json.decode(payload);
        if (kDebugMode) debugPrint("map : $map");
        //建议参数中携带type，区分不同的通知类型，
        _PushNavigation.handleMessage(map);
      }
    } catch (err) {
      if (kDebugMode) debugPrint("点击前台通知消息err ：${err.toString()}");
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
        if (kDebugMode) {
          debugPrint('Device login notification from self, ignoring');
        }
        return;
      }
      final info = DeviceLoginInfo.fromJson(data);
      eventBus.fire(
        EventPublic(EventPublicType.deviceLoginDetected, param: info),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Handle device login notification error: $e');
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

    if (kDebugMode) {
      debugPrint('[PushData][BackgroundIsolate] notification=${message.notification?.toMap()}');
      debugPrint('[PushData][BackgroundIsolate] data=${message.data}');
    }

    // Matrix/Chat 消息（含 room_id 或 type 为 m.call.*）委托给 n42_chat 插件处理
    // 包括后台来电 CallKit 触发、消息本地通知等
    final dataType = message.data['type'] as String?;
    final roomId = message.data['room_id'] as String?;
    if (roomId != null ||
        (dataType != null && dataType.startsWith('m.call.'))) {
      if (kDebugMode) {
        debugPrint(
          'Background: Matrix/Chat message - delegating to FirebasePushService',
        );
      }
      await FirebasePushService.handleBackgroundMessage(message);
      return;
    }

    // 新设备登录通知 — 后台显示系统本地通知
    if (dataType == 'device_login') {
      final brand = message.data['device_brand'] ?? '';
      final os = message.data['device_os'] ?? '';
      final deviceName = os.isNotEmpty ? '$brand $os' : brand;
      // flutter_local_notifications 20.0.0 使用命名参数
      FlutterLocalNotificationsPlugin().show(
        id: 'device_login'.hashCode,
        title: 'New Device Login',
        body: 'Your account was logged in on $deviceName',
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            color: Colors.black,
          ),
        ),
        payload: json.encode(message.data),
      );
      return;
    }

    _updateBadgeCount();
    if (kDebugMode) debugPrint('Background: app message ${message.messageId}');
  }

  //更新未读消息数
  static void _updateBadgeCount() {
    FlutterNewBadger.incrementBadgeCount();
    // 使用 Riverpod 增加未读消息数
    globalProviderContainer.read(unreadCountProvider.notifier).increment();
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
    final eventId = _pendingChatEventId;

    if (_wasChatNotificationHandledRecently(roomId: roomId, eventId: eventId)) {
      _clearPendingChatNotification();
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
        return;
      }
    }

    if (_wasChatNotificationHandledRecently(roomId: roomId, eventId: eventId)) {
      _clearPendingChatNotification();
      return;
    }

    if (kDebugMode) {
      debugPrint(
        'Flushing pending chat notification: roomId=$roomId, eventId=$eventId',
      );
    }
    try {
      await N42Chat.openConversation(roomId);
      recordHandledChatNotificationTap(roomId: roomId, eventId: eventId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('flushPendingChatNotification openConversation error: $e');
      }
    } finally {
      _clearPendingChatNotification();
    }
  }

  static bool _wasChatNotificationHandledRecently({
    required String roomId,
    String? eventId,
  }) {
    final handledAt = _lastHandledChatTapAt;
    if (handledAt == null ||
        _lastHandledChatRoomId == null ||
        DateTime.now().difference(handledAt) > _chatTapDedupWindow) {
      return false;
    }

    return _matchesChatTap(
      roomId: roomId,
      eventId: eventId,
      otherRoomId: _lastHandledChatRoomId,
      otherEventId: _lastHandledChatEventId,
    );
  }

  static bool _matchesChatTap({
    required String roomId,
    String? eventId,
    required String? otherRoomId,
    String? otherEventId,
  }) {
    if (otherRoomId == null || roomId != otherRoomId) {
      return false;
    }

    final normalizedEventId = eventId?.trim() ?? '';
    final normalizedOtherEventId = otherEventId?.trim() ?? '';
    if (normalizedEventId.isEmpty || normalizedOtherEventId.isEmpty) {
      return true;
    }

    return normalizedEventId == normalizedOtherEventId;
  }

  static void _clearPendingChatNotification() {
    _pendingChatRoomId = null;
    _pendingChatEventId = null;
  }

  /// 登录成功后检查推送权限，若未授权且用户未选择"不再提醒"则弹窗引导。
  ///
  /// 通过全局 navigatorKey 获取 context，不依赖调用方 Widget 的 mounted 状态。
  /// 适用平台：
  ///   - iOS / Android 13+：用户拒绝后 authorizationStatus == denied
  ///   - Android < 13：无需显式权限，getNotificationSettings 返回 authorized，
  ///     说明通知确实可用，不需要提醒。
  static Future<void> checkAndPromptPermission() async {
    debugPrint('[PushCheck] ① checkAndPromptPermission called');
    try {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      debugPrint('[PushCheck] ② after 800ms delay');

      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      debugPrint('[PushCheck] ③ authorizationStatus = ${settings.authorizationStatus}');

      final enabled =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      if (enabled) {
        debugPrint('[PushCheck] ④ notifications enabled, skip');
        return;
      }

      final dismissed = await SPUtil().getPushPermissionDismissed();
      debugPrint('[PushCheck] ⑤ dismissed = $dismissed');
      if (dismissed) return;

      final ctx = AppGlobals.navigatorKey.currentContext;
      debugPrint('[PushCheck] ⑥ ctx = $ctx, mounted = ${ctx?.mounted}');
      if (ctx == null || !ctx.mounted) return;

      debugPrint('[PushCheck] ⑦ showing dialog');
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
      debugPrint('[PushCheck] ⑧ dialog closed');
    } catch (e, st) {
      debugPrint('[PushCheck] ❌ exception: $e\n$st');
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
