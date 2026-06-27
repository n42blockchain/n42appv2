import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../utils/debug_log.dart';

/// 系统级集成服务
///
/// 经 MethodChannel `n42.chat/system_integration` 桥接各平台系统能力，并在
/// **无原生 handler 时用 [flutter_local_notifications] 真实兜底**通知类能力：
///
/// - **进行中活动**（[updateLiveActivity]/[endLiveActivity]）：Android 落为
///   **常驻静默通知**（ongoing，通话/上传等进行中事件）——真实生效。iOS 真正的
///   Live Activity（ActivityKit）仍需原生，原生未接时回退为普通通知。
/// - **会话气泡**（[showConversationBubble]）：Android 落为 **MessagingStyle
///   会话式通知**（系统升级为 Bubble 的前置形态）——真实生效。
/// - **托盘角标 / 窗口闪烁 / 动态快捷方式**（[setTrayBadge]/[flashWindow]/
///   [setDynamicShortcuts]）：桌面/平台原生专属，**无通知兜底**，原生未接时优雅
///   no-op（需 window_manager/quick_actions 等后续接线）。
///
/// 设计原则：原生 handler 返回 `true` 表示已处理则不再兜底；返回 null（未实现）
/// 时通知类能力走本地通知兜底，平台专属能力 no-op。**不抛错、不误导为可用。**
class SystemIntegrationService {
  static const MethodChannel _channel =
      MethodChannel('n42.chat/system_integration');

  /// 本地通知兜底插件（独立实例；底层与推送共用同一原生插件，安全）
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _notifReady = false;

  /// 进行中活动通知渠道（低优先级、静默、常驻）
  static const String _activityChannelId = 'n42.chat.activity';
  static const String _activityChannelName = 'Ongoing activity';
  static const String _activityChannelDesc =
      'Calls, uploads and other in-progress activity';

  /// 会话式通知渠道（高优先级，MessagingStyle / Bubble 前置）
  static const String _conversationChannelId = 'n42.chat.conversation';
  static const String _conversationChannelName = 'Conversations';
  static const String _conversationChannelDesc =
      'Conversation-style message notifications';

  Future<T?> _tryNative<T>(String method, [Object? args]) async {
    if (kIsWeb) return null;
    try {
      return await _channel.invokeMethod<T>(method, args);
    } on MissingPluginException {
      return null; // 原生 handler 未实现
    } catch (e) {
      debugLog('SystemIntegrationService.$method (native) failed: $e');
      return null;
    }
  }

  /// 懒初始化本地通知兜底（仅移动端有效）
  Future<bool> _ensureNotifications() async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return false;
    if (_notifReady) return true;
    try {
      const init = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );
      await _notifications.initialize(settings: init);

      if (Platform.isAndroid) {
        final android =
            _notifications.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        await android?.createNotificationChannel(
          const AndroidNotificationChannel(
            _activityChannelId,
            _activityChannelName,
            description: _activityChannelDesc,
            importance: Importance.low,
            playSound: false,
            enableVibration: false,
          ),
        );
        await android?.createNotificationChannel(
          const AndroidNotificationChannel(
            _conversationChannelId,
            _conversationChannelName,
            description: _conversationChannelDesc,
            importance: Importance.high,
          ),
        );
      }
      _notifReady = true;
      return true;
    } catch (e) {
      debugLog('SystemIntegrationService: notification init failed: $e');
      return false;
    }
  }

  /// 把字符串 id 稳定映射为正整数通知 id（同 id 复用→更新同一条通知）
  int _stableId(String s) {
    var h = 0;
    for (final c in s.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return h == 0 ? 1 : h;
  }

  /// 更新进行中活动（iOS Live Activity / Android 常驻通知）——通话、上传等。
  ///
  /// 原生未接时：Android 落为常驻静默通知（真实），iOS 落为普通通知。
  Future<void> updateLiveActivity({
    required String id,
    required String title,
    String? body,
    Map<String, dynamic>? data,
  }) async {
    final handled = await _tryNative<bool>('updateLiveActivity', {
      'id': id,
      'title': title,
      'body': body,
      'data': data,
    });
    if (handled == true) return;

    if (!await _ensureNotifications()) return;
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _activityChannelId,
        _activityChannelName,
        channelDescription: _activityChannelDesc,
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        onlyAlertOnce: true,
        showWhen: false,
        category: AndroidNotificationCategory.progress,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: false,
      ),
    );
    await _notifications.show(
      id: _stableId(id),
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  /// 结束进行中活动
  Future<void> endLiveActivity(String id) async {
    final handled = await _tryNative<bool>('endLiveActivity', {'id': id});
    if (handled == true) return;
    if (!await _ensureNotifications()) return;
    await _notifications.cancel(id: _stableId(id));
  }

  /// 以会话气泡弹出（Android Conversation Bubble / MessagingStyle）。
  ///
  /// [message] 为可选的最新消息文本（无则显示通用提示）。
  Future<void> showConversationBubble({
    required String roomId,
    required String title,
    String? avatarUrl,
    String? message,
  }) async {
    final handled = await _tryNative<bool>('showConversationBubble', {
      'roomId': roomId,
      'title': title,
      'avatarUrl': avatarUrl,
      'message': message,
    });
    if (handled == true) return;

    if (!await _ensureNotifications()) return;
    final text = (message == null || message.isEmpty) ? 'New message' : message;
    final sender = Person(key: roomId, name: title, important: true);
    final messaging = MessagingStyleInformation(
      const Person(name: 'You'),
      conversationTitle: title,
      groupConversation: false,
      messages: [Message(text, DateTime.now(), sender)],
    );
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _conversationChannelId,
        _conversationChannelName,
        channelDescription: _conversationChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.message,
        styleInformation: messaging,
      ),
      iOS: const DarwinNotificationDetails(),
    );
    await _notifications.show(
      id: _stableId('conv:$roomId'),
      title: title,
      body: text,
      notificationDetails: details,
    );
  }

  /// 设置 App 动态快捷方式（Android Shortcuts / iOS Quick Actions）。
  ///
  /// 平台原生专属，无通知兜底；原生未接时 no-op（需 quick_actions 等后续接线）。
  Future<void> setDynamicShortcuts(List<Map<String, dynamic>> shortcuts) =>
      _tryNative<void>('setDynamicShortcuts', {'shortcuts': shortcuts});

  /// 桌面系统托盘未读角标（平台原生专属，无兜底；需 tray_manager 后续接线）
  Future<void> setTrayBadge(int count) =>
      _tryNative<void>('setTrayBadge', {'count': count});

  /// 桌面窗口闪烁提示（平台原生专属，无兜底；需 window_manager 后续接线）
  Future<void> flashWindow() => _tryNative<void>('flashWindow');

  /// 查询某能力是否被当前平台真实支持。
  ///
  /// 通知类能力（liveActivity/conversation）在移动端经本地通知兜底即视为支持；
  /// 平台专属能力（tray/flash/shortcuts）取决于原生 handler。
  Future<bool> isSupported(String capability) async {
    final native = await _tryNative<bool>('isSupported', {
      'capability': capability,
    });
    if (native == true) return true;
    switch (capability) {
      case 'liveActivity':
      case 'conversation':
        return !kIsWeb && (Platform.isAndroid || Platform.isIOS);
      default:
        return false;
    }
  }
}
