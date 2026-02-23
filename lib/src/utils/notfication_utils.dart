import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:n42_wallet/generated/l10n.dart';

class Notification {
  final FlutterLocalNotificationsPlugin np = FlutterLocalNotificationsPlugin();

  /// main 初始化
  Future<void> init() async {
    const AndroidInitializationSettings android =  AndroidInitializationSettings("@mipmap/ic_launcher");
    // var ios = const IOSInitializationSettings();
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
      // 构建描述
      /**
       * 通知渠道 大部分厂家通知渠道归类通知类别
       * channelId 这个是一个标识  Android8.0+每个通知都要加这个channelId标识重要程度 是否弹窗 是否通知 是否发出声音
       * channelName 这个可以自己随意命名定义 安装后 到当前应用详情通知功能看到这个名字 创建多少个渠道就有多少条，
       *              用于手机查看每个通知渠道 这是用于用户可以单独设置每个通知渠道的显示程度
       * TIP: 同一种重要程度渠道可以创建多个，channelID 和channelName设置不同就行 这里我只写了官方重要级别到几种
       * */
      var androidDetails = AndroidNotificationDetails(
          'nftWallet_channelId', //id可以随意一点
          ///这个会显示在手机设置 通知管理 app 通知设置列表中 不要瞎写
          // '重要通知',
          S.of(AppGlobals.navigatorKey.currentContext!).importantNotice,

          ///通知的级别
          importance: Importance.max,
          priority: Priority.high,

          // icon: ''//可以单独设置每次发送通知的图标

          //显示进度条 3个参数必须同时设置
          // progress: 19,
          // maxProgress: 100,
          // showProgress: true

          //是否播放声音
          playSound: playSound
      );

      // ios的通知
      const String darwinNotificationCategoryPlain = 'plainCategory';
      DarwinNotificationDetails iosNotificationDetails =
      DarwinNotificationDetails(
          categoryIdentifier: darwinNotificationCategoryPlain,
          presentSound: playSound,
          presentAlert: true,
          presentBadge: true
      );


      var details = NotificationDetails(android: androidDetails, iOS: iosNotificationDetails);

      // 显示通知, 第一个参数是id,id如果一致则会覆盖之前的通知
      // String? payload, 点击时可以拿到的参数
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
    var androidDetails = AndroidNotificationDetails(
        'nftWallet_channelId', //id可以随意一点
        ///这个会显示在手机设置 通知管理 app 通知设置列表中 不要瞎写
        // '重要通知',
        S.of(AppGlobals.navigatorKey.currentContext!).importantNotice,

        ///通知的级别
        importance: Importance.high,
        priority: Priority.high,
        autoCancel: true,
        ongoing: true,
        // icon: ''//可以单独设置每次发送通知的图标

        //显示进度条 3个参数必须同时设置
        // progress: 19,
        // maxProgress: 100,
        // showProgress: true

        //是否播放声音
        playSound: playSound
    );
    var details = NotificationDetails(android: androidDetails,);

    // 显示通知, 第一个参数是id,id如果一致则会覆盖之前的通知
    // String? payload, 点击时可以拿到的参数
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