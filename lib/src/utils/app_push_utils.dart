// android通知的通道

import 'dart:convert';

import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/core/providers/core_providers.dart';
import 'package:n42appv2/main.dart' show globalProviderContainer;
import 'package:n42appv2/src/browser/pages/browser_page.dart';
import 'package:n42appv2/src/home/setting/about_app.dart';
import 'package:n42appv2/src/home/setting/personal_setting.dart';
import 'package:n42appv2/src/home/setting/setting_share.dart';
import 'package:n42appv2/src/login/api/user_info_api.dart';
import 'package:n42appv2/src/login/pages/login_page.dart';
import 'package:n42appv2/src/notification/pages/message_info.dart';
import 'package:n42appv2/core/utils/event_bus.dart';
import 'package:n42appv2/src/wallet/utils/browser_txhash.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_new_badger/flutter_new_badger.dart';
import 'package:intl/intl.dart';

late AndroidNotificationChannel channel;

//本地通知插件对象
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

class AppPushUtils {
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
        AndroidFlutterLocalNotificationsPlugin>()
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
    var ios =  const DarwinInitializationSettings(
      requestAlertPermission: true,
    );

    // FlutterLocalNotificationsPlugin().initialize(
    //     InitializationSettings(android: android, iOS: ios),
    //     onSelectNotification: _onSelectNotification);

    FlutterLocalNotificationsPlugin().initialize(
        InitializationSettings(android: android, iOS: ios),
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          String? payload = details.payload;
          _onSelectNotification(payload);
        }
    );


    ///ios , mac, web需要请求权限
    NotificationSettings settings =
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    //android上不需要考虑权限的问题
    debugPrint('User granted permission: ${settings.authorizationStatus}');
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      // 用户拒绝或者未接受许可
      // 在基于 Apple 的平台上，一旦用户处理了权限请求（授权或拒绝），就无法重新请求权限。用户必须改为通过设备设置 UI 更新权限：
      // 如果用户完全拒绝权限，他们必须完全启用应用权限。
      // 如果用户接受请求的权限（无声音），他们必须己专门启用声音选项。
      debugPrint('User declined or has not accepted permission');
      //首次安装应用 同意之后 也会执行这里的逻辑
    }

    ///前台消息
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('在前台收到消息！');

      try {
        final jsonStr = json.encode(message.data);
        // debugPrint("jsonStr: $jsonStr");
        if (message.notification != null) {
          _updateBadgeCount();
          //消息类型
          String nType = message.data['type'];
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
              FlutterLocalNotificationsPlugin().show(
                  notification.hashCode,
                  notification.title,
                  notification.body,
                  NotificationDetails(
                    android: AndroidNotificationDetails(
                        channel.id, channel.name,
                        channelDescription: channel.description,
                        color: Colors.black),
                  ),
                  payload: jsonStr);
            }
          }

          if (nType == "chat") {
            // Chat notifications are handled by n42_chat plugin
            debugPrint("Chat notification received - handled by n42_chat plugin");
          }
        }
      } catch (err) {
        debugPrint("解析失败：${err.toString()}");
      }
    });

    ///后台消息
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    ///点击后台消息打开App
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('从后台打开应用，自动清除通知');

      /// 打开对应的页面
      _handleMessage(message.data);
    });

    ///应用从终止状态打开
    var m = await FirebaseMessaging.instance.getInitialMessage();
    if (m != null) {
      debugPrint('应用从终止状态打开:${m.notification?.title}');
      //这种情况待测试
      _handleMessage(m.data);
    }

    //token更新监听
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      debugPrint("firebase messaging token updated: $newToken");
      bindUserPushToken(newToken);
    });
  }

  //绑定用户推送的token
  static Future<void> bindUserPushToken(dynamic newToken) async {
    try {
      // 绑定token
      debugPrint('new token : $newToken');
      if (newToken != null && AppGlobals.userInfo != null) {
        UserInfoApi loginApi=UserInfoApi();
        final data = await loginApi.bindPushUserToken(newToken);
        if (data != null && data["code"] == 200) {
          //success
          debugPrint("更新推送用户Token成功");
        } else {
          debugPrint("更新推送用户Token失败");
        }
      }
    } catch (err) {
      debugPrint("bindUserPushToken err: ${err.toString()}");
    }
  }

  ///前台通知点击
  static void _onSelectNotification(String? payload) {
    try {
      debugPrint('前台通知点击: $payload');

      /// 打开对应的页面
      if (payload != null) {
        //逻辑处理
        final map = json.decode(payload);
        debugPrint("map : $map");
        //建议参数中携带type，区分不同的通知类型，
        _handleMessage(map);
      }
    } catch (err) {
      debugPrint("点击前台通知消息err ：${err.toString()}");
    }
  }

  ///对消息统一处理
  static void _handleMessage(Map<String, dynamic> data) {
    // 未登录 统一去登录
    if (AppGlobals.userInfo==null) {
      Navigator.push(AppGlobals.navigatorKey.currentContext!,
          MaterialPageRoute(builder: (_) => LoginPage()));
      return;
    }
    if (data['type'] == 'chat') {
      // Chat notifications are handled by n42_chat plugin
      debugPrint("Chat notification tapped - handled by n42_chat plugin");
    }
    else if (data['type'] == 'transfer') {
      Map<String, dynamic> txContent = {};
      try {
        txContent = json.decode(data['data']);
      } catch (_) {
        // JSON 解析失败时使用空 map，安全忽略
      }
      String? isTestStr = txContent['network'];
      bool? isTest;
      if (isTestStr != null) {
        isTest = isTestStr == "test" ? true : false;
      }
      String bUri = getBrowserTxHash(
          txContent['coin'], txContent['hash'] ?? "",
          isTest: isTest);
      Navigator.push(AppGlobals.navigatorKey.currentContext!,
          MaterialPageRoute(builder: (_) => BrowserPage(bUri,
            //"Transaction"
          )));
    }
    else if (data['type'] == "normal_transaction_failed") {
      Map<String, dynamic> txContent = {};
      try {
        txContent = json.decode(data['data']);
      } catch (_) {
        // JSON 解析失败时使用空 map，安全忽略
      }
      String? isTestStr = txContent['network'];
      bool? isTest;
      if (isTestStr != null) {
        isTest = isTestStr == "test" ? true : false;
      }
      String bUri = getBrowserTxHash(
          txContent['coin'], txContent['hash'] ?? "",
          isTest: isTest);
      Navigator.push(AppGlobals.navigatorKey.currentContext!,
          MaterialPageRoute(builder: (_) => BrowserPage(bUri,
            //"Transaction"
          )));
    }
    else if (data['type'] == 'normal_price_changed') {
      Map<String, dynamic> txContent = {};
      try {
        txContent = json.decode(data['data']);
      } catch (_) {
        // JSON 解析失败时使用空 map，安全忽略
      }
      String chain = (txContent['chain'] ?? "").toUpperCase();
      double percentage = txContent['percentage'] ?? 0;
      String content =
          "Over $percentage% change in the price of $chain within 24 hours. ";
      //int created = (txContent['created']??0) as int;
      //String createTime=DateTime.fromMicrosecondsSinceEpoch(created*1000).toString();
      DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
      Map<String, dynamic> infoMap = {
        "title": data['body'],
        "content": content,
        "created": dateFormat.format(DateTime.now()),
      };
      Navigator.push(AppGlobals.navigatorKey.currentContext!,
          MaterialPageRoute(builder: (_) => MessageInfo(infoMap)));
    }
    /*
    else if (data['type'] == "normal_followed") {
      Map<String, dynamic> txContent = {};
      try {
        txContent = json.decode(data['data']);
      } catch (_) {
        // JSON 解析失败时使用空 map，安全忽略
      }
      Navigator.push(
          AppGlobals.navigatorKey.currentContext!,
          MaterialPageRoute(
              builder: (_) => NftUserHome(
                user_uuid: txContent['follow_uuid'] ?? "",
                getUserInfo: true,
              )));
    }
    else if (data['type'] == "normal_trending") {
      Navigator.push(
          AppGlobals.navigatorKey.currentContext!,
          MaterialPageRoute(
              builder: (_) => NftSearch(
                searchMap: {"specify_24h_like": true},
              )));
    }
    */
    else if (data['type'] == "tell_friends") {
      Navigator.push(
          AppGlobals.navigatorKey.currentContext!,
          MaterialPageRoute(
            builder: (_) => SettingShare(),
          ));
    }
    else if (data['type'] == "Tell Friends #1_normal" ||
        data['type'] == "Tell Friends #2_normal") {
      //跳转分享页
      Navigator.push(
          AppGlobals.navigatorKey.currentContext!,
          MaterialPageRoute(
            builder: (_) => SettingShare(),
          ));
    }
    /*
    else if (data['type'] == "NFTHome #1_normal" ||
        data['type'] == "NFTHome #2_normal") {
      //跳转NFT主页
      Navigator.of(AppGlobals.navigatorKey.currentContext!)
          .popUntil((route) => route.isFirst);
      ProviderUtil.publicProvider().setSelectIndex(2);
    } */
    else if (data['type'] == "ChatHome #1_normal" ||
        data['type'] == "ChatHome #2_normal") {
      //跳转聊天主页
      Navigator.of(AppGlobals.navigatorKey.currentContext!)
          .popUntil((route) => route.isFirst);
      // 使用 Riverpod - 通过 globalProviderContainer
      globalProviderContainer.read(mainTabSelectIndexProvider.notifier).state = 2;
    }
    else if (data['type'] == "News_normal") {
      //跳转新闻列表页面
      Navigator.of(AppGlobals.navigatorKey.currentContext!)
          .popUntil((route) => route.isFirst);
      globalProviderContainer.read(mainTabSelectIndexProvider.notifier).state = 0;
    }
    else if (data['type'] == "Login_normal") {
      //跳转创建钱包
      Navigator.of(AppGlobals.navigatorKey.currentContext!)
          .popUntil((route) => route.isFirst);
      globalProviderContainer.read(mainTabSelectIndexProvider.notifier).state = 0;
    }
    else if (data['type'] == "AboutSettings_normal") {
      //跳转关于我们页面
      Navigator.push(AppGlobals.navigatorKey.currentContext!,
          MaterialPageRoute(
            builder: (_) => AboutApp(),));
    }
    else if (data['type'] == "WalletHome #1_normal" ||
        data['type'] == "WalletHome #2_normal") {
      //跳转钱包页面
      Navigator.of(AppGlobals.navigatorKey.currentContext!)
          .popUntil((route) => route.isFirst);
      globalProviderContainer.read(mainTabSelectIndexProvider.notifier).state = 0;
    }
    else if (data['type'] == "SettingsProfile_normal") {
      //跳转设置个人信息页面
      if (AppGlobals.userInfo !=null) {
        Navigator.push(
            AppGlobals.navigatorKey.currentContext!,
            MaterialPageRoute(
              builder: (_) => PersonalSetting(),
            ));
      }
    }
    else if (data['type'] == "Homepage_normal") {
      //跳转主页
      Navigator.of(AppGlobals.navigatorKey.currentContext!)
          .popUntil((route) => route.isFirst);
      globalProviderContainer.read(mainTabSelectIndexProvider.notifier).state = 0;
    }
    else if (data['type'] == 110 || data['type'] == 100 || data['type'] == 101) {
      // Chat notifications are handled by n42_chat plugin
      // Navigate to chat interface
      flutterLocalNotificationsPlugin.cancel(data['type']);
      debugPrint("Chat notification tapped - handled by n42_chat plugin");
    }
    else {
      debugPrint("未知消息类型，无法处理");
    }
  }

  ///清除所有通知
  static void cleanNotification() {
    flutterLocalNotificationsPlugin.cancelAll();
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    _updateBadgeCount();
    debugPrint('收到后台消息： ${message.messageId}');
    // 这里可以处理一些业务逻辑 用户无感知
    // 不和用户交互
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
        playSound: true
    );

    // ios的通知
    const String darwinNotificationCategoryPlain = 'plainCategory';
    DarwinNotificationDetails iosNotificationDetails =
    DarwinNotificationDetails(
        categoryIdentifier: darwinNotificationCategoryPlain,
        presentSound: true,
        presentAlert: true,
        presentBadge: true
    );
    var notificationDetails = NotificationDetails(android: androidDetails,iOS: iosNotificationDetails);
    flutterLocalNotificationsPlugin.show(100, "测试推送", "你收到了一条消息", notificationDetails);
  }

}
