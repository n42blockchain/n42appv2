import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:n42_wallet/generated/l10n.dart';

class Notification {
  final FlutterLocalNotificationsPlugin np = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const android = AndroidInitializationSettings("@mipmap/ic_launcher");
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    // flutter_local_notifications 20.0.0 uses named parameters
    await np.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        switch (details.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            break;
          case NotificationResponseType.selectedNotificationAction:
            break;
        }
      },
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

  void send(String title, String body,
      {int? notificationId, String? params, bool playSound = true}) async {
    try {
      final androidDetails = _buildAndroidDetails(playSound: playSound);

      const String darwinNotificationCategoryPlain = 'plainCategory';
      final iosNotificationDetails = DarwinNotificationDetails(
        categoryIdentifier: darwinNotificationCategoryPlain,
        presentSound: playSound,
        presentAlert: true,
        presentBadge: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosNotificationDetails,
      );

      // flutter_local_notifications 20.0.0 uses named parameters
      await np.show(
        id: notificationId ?? DateTime.now().millisecondsSinceEpoch >> 10,
        title: title,
        body: body,
        notificationDetails: details,
        payload: params,
      );
    } catch (_) {
      // Silently ignore notification errors
    }
  }

  void sendAndroid(String title, String body,
      {int? notificationId, String? params, bool playSound = true}) {
    final androidDetails = _buildAndroidDetails(
      playSound: playSound,
      importance: Importance.high,
      autoCancel: true,
      ongoing: true,
    );
    final details = NotificationDetails(android: androidDetails);

    // flutter_local_notifications 20.0.0 uses named parameters
    np.show(
      id: notificationId ?? DateTime.now().millisecondsSinceEpoch >> 10,
      title: title,
      body: body,
      notificationDetails: details,
      payload: params,
    );
  }

  void cleanNotification() {
    np.cancelAll();
  }

  void cancelNotification(int id, {String? tag}) {
    // flutter_local_notifications 20.0.0 uses named parameters
    np.cancel(id: id, tag: tag);
  }
}

var notification = Notification();
