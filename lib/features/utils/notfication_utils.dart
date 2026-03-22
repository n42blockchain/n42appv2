import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:n42_wallet/generated/l10n.dart';

class Notification {
  final FlutterLocalNotificationsPlugin np = FlutterLocalNotificationsPlugin();

  /// main 初始化
  Future<void> init() async {
    const AndroidInitializationSettings android =  AndroidInitializationSettings("@mipmap/ic_launcher");
    DarwinInitializationSettings ios = const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    InitializationSettings initializationSettings =
    InitializationSettings(
        android: android,
        iOS: ios);
    // flutter_local_notifications 20.0.0 使用命名参数
    await np.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse:(NotificationResponse details) {
          switch (details.notificationResponseType) {
            case NotificationResponseType.selectedNotification:
              break;
            case NotificationResponseType.selectedNotificationAction:
              break;
          }
        }
    );
  }

  /// 构建 Android 通知详情
  AndroidNotificationDetails _buildAndroidDetails({
    bool playSound = true,
    Importance importance = Importance.max,
    bool autoCancel = false,
    bool ongoing = false,
  }) {
    return AndroidNotificationDetails(
        'nftWallet_channelId',
        S.of(AppGlobals.navigatorKey.currentContext!).importantNotice,
        importance: importance,
        priority: Priority.high,
        autoCancel: autoCancel,
        ongoing: ongoing,
        playSound: playSound,
    );
  }

  ///params点击通知时，可以拿到的参数，title和body仅仅是展示作用
  ///     Map params = {};
  ///     params['type'] = "100";
  ///     params['id'] = "10086";
  ///     params['content'] = "content";
  ///     notification.send("title", "content",params: json.encode(params));
  ///
  /// notificationId指定时，不在根据时间生成
  void send(String title, String body, {int? notificationId, String? params,bool playSound = true}) async{
    try {
      var androidDetails = _buildAndroidDetails(playSound: playSound);

      const String darwinNotificationCategoryPlain = 'plainCategory';
      DarwinNotificationDetails iosNotificationDetails =
      DarwinNotificationDetails(
          categoryIdentifier: darwinNotificationCategoryPlain,
          presentSound: playSound,
          presentAlert: true,
          presentBadge: true
      );

      var details = NotificationDetails(android: androidDetails, iOS: iosNotificationDetails);

      // flutter_local_notifications 20.0.0 使用命名参数
      await np.show(
          id: notificationId ?? DateTime.now().millisecondsSinceEpoch >> 10,
          title: title,
          body: body,
          notificationDetails: details,
          payload: params);
    } catch (_) {
      // 错误安全忽略
    }
  }

  void sendAndroid(String title ,String body ,{int? notificationId, String? params,bool playSound = true}){
    var androidDetails = _buildAndroidDetails(
      playSound: playSound,
      importance: Importance.high,
      autoCancel: true,
      ongoing: true,
    );
    var details = NotificationDetails(android: androidDetails);

    // flutter_local_notifications 20.0.0 使用命名参数
    np.show(
        id: notificationId ?? DateTime.now().millisecondsSinceEpoch >> 10,
        title: title,
        body: body,
        notificationDetails: details,
        payload: params);
  }
  ///清除所有通知
  void cleanNotification() {
    np.cancelAll();
  }

  ///清除指定id的通知
  /// `tag`参数指定Android标签。 如果提供，
  /// 那么同时匹配 id 和 tag 的通知将会
  /// 被取消。 `tag` 对其他平台没有影响。
  void cancelNotification(int id, {String? tag}) {
    // flutter_local_notifications 20.0.0 使用命名参数
    np.cancel(id: id, tag: tag);
  }
}

var notification = Notification();
