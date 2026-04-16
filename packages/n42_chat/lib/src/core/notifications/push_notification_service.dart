import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart' as matrix;

import '../../domain/entities/user_profile_entity.dart'
    show NotificationPrivacyMode;
import '../utils/debug_log.dart';

/// 推送通知服务
///
/// 管理推送通知的注册、处理和显示
abstract class IPushNotificationService {
  /// 初始化推送服务
  Future<void> initialize();

  /// 注册推送通知
  Future<void> registerForPush();

  /// 取消注册推送通知
  Future<void> unregisterPush();

  /// 处理收到的推送通知
  Future<void> handleNotification(Map<String, dynamic> message);

  /// 显示本地通知
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? roomId,
    String? eventId,
    String? imageUrl,
  });

  /// 清除指定房间的通知
  Future<void> clearNotificationsForRoom(String roomId);

  /// 清除所有通知
  Future<void> clearAllNotifications();

  /// 获取通知权限状态
  Future<NotificationPermissionStatus> getPermissionStatus();

  /// 请求通知权限
  Future<bool> requestPermission();
}

/// 推送通知服务实现
class PushNotificationService implements IPushNotificationService {
  final matrix.Client _client;

  /// 推送网关URL（用于注册推送）
  final String? pushGatewayUrl;

  /// 应用标识符
  final String appId;

  /// 推送器类型
  final String pushkeyType;

  /// 通知点击回调
  final void Function(String? roomId, String? eventId)? onNotificationTap;

  PushNotificationService(
    this._client, {
    this.pushGatewayUrl,
    this.appId = 'com.n42.chat',
    this.pushkeyType = 'http',
    this.onNotificationTap,
  });

  String? _pushToken;
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    // 初始化本地通知
    await _initializeLocalNotifications();

    // 监听消息更新，发送本地通知
    _client.onSync.stream.listen(_handleSyncUpdate);

    _isInitialized = true;
  }

  Future<void> _initializeLocalNotifications() async {
    // 注：实际实现需要使用 flutter_local_notifications 包
    // 这里只提供接口定义
  }

  void _handleSyncUpdate(matrix.SyncUpdate syncUpdate) {
    // 处理新消息，如果需要则显示本地通知
    final joinedRooms = syncUpdate.rooms?.join;
    if (joinedRooms == null) return;

    for (final entry in joinedRooms.entries) {
      final roomId = entry.key;
      final roomUpdate = entry.value;
      final events = roomUpdate.timeline?.events ?? [];

      for (final event in events) {
        if (_shouldShowNotification(event)) {
          _showNotificationForEvent(roomId, event);
        }
      }
    }
  }

  bool _shouldShowNotification(matrix.MatrixEvent event) {
    // 只显示消息类型的通知
    if (event.type != matrix.EventTypes.Message) return false;

    // 不显示自己发送的消息
    if (event.senderId == _client.userID) return false;

    // 可以添加更多过滤条件
    return true;
  }

  void _showNotificationForEvent(String roomId, matrix.MatrixEvent event) {
    final room = _client.getRoomById(roomId);
    if (room == null) return;

    // 检查房间是否静音
    if (room.pushRuleState == matrix.PushRuleState.dontNotify) return;

    final senderName = room
        .unsafeGetUserFromMemoryOrFallback(event.senderId)
        .calcDisplayname();
    final roomName = room.getLocalizedDisplayname();
    final body = _getNotificationBody(event);

    showLocalNotification(
      title: room.isDirectChat ? senderName : '$senderName @ $roomName',
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
        return '[Voice]';
      case 'm.file':
        return '[File]';
      case 'm.location':
        return '[Location]';
      default:
        return '[Message]';
    }
  }

  @override
  Future<void> registerForPush() async {
    if (_pushToken == null) {
      throw PushNotificationException('Push token not available');
    }

    if (pushGatewayUrl == null) {
      throw PushNotificationException('Push gateway URL not configured');
    }

    try {
      await _client.postPusher(
        matrix.Pusher(
          pushkey: _pushToken!,
          kind: pushkeyType,
          appId: appId,
          appDisplayName: 'N42 Chat',
          deviceDisplayName: _client.deviceName ?? 'Unknown Device',
          lang: 'zh-TW',
          data: matrix.PusherData(
            url: Uri.parse(pushGatewayUrl!),
            format: 'event_id_only',
          ),
        ),
        append: false,
      );
    } catch (e) {
      throw PushNotificationException('Failed to register push: $e');
    }
  }

  @override
  Future<void> unregisterPush() async {
    if (_pushToken == null) return;

    try {
      await _client.deletePusher(
        matrix.Pusher(
          pushkey: _pushToken!,
          kind: '',
          appId: appId,
          appDisplayName: 'N42 Chat',
          deviceDisplayName: _client.deviceName ?? 'Unknown Device',
          lang: 'zh-TW',
          data: matrix.PusherData(),
        ),
      );
    } catch (e) {
      throw PushNotificationException('Failed to unregister push: $e');
    }
  }

  @override
  Future<void> handleNotification(Map<String, dynamic> message) async {
    // 解析推送消息
    final roomId = message['room_id'] as String?;
    final eventId = message['event_id'] as String?;

    if (roomId != null) {
      // 触发回调，让应用导航到对应房间
      onNotificationTap?.call(roomId, eventId);
    }
  }

  @override
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? roomId,
    String? eventId,
    String? imageUrl,
  }) async {
    // 注：实际实现需要使用 flutter_local_notifications 包
    // 这里只提供接口定义

    debugLog('Showing notification: $title - $body');
  }

  @override
  Future<void> clearNotificationsForRoom(String roomId) async {
    // 清除指定房间的通知
    // 注：需要使用 flutter_local_notifications 的 cancel 方法
  }

  @override
  Future<void> clearAllNotifications() async {
    // 清除所有通知
    // 注：需要使用 flutter_local_notifications 的 cancelAll 方法
  }

  @override
  Future<NotificationPermissionStatus> getPermissionStatus() async {
    // 返回通知权限状态
    // 注：实际实现需要检查系统权限
    return NotificationPermissionStatus.granted;
  }

  @override
  Future<bool> requestPermission() async {
    // 请求通知权限
    // 注：实际实现需要使用 permission_handler 包
    return true;
  }

  /// 设置推送Token（由Firebase/APNs提供）
  void setPushToken(String token) {
    _pushToken = token;
  }
}

/// 通知权限状态
enum NotificationPermissionStatus {
  /// 已授权
  granted,

  /// 已拒绝
  denied,

  /// 未确定
  notDetermined,

  /// 受限
  restricted,
}

/// 推送通知异常
class PushNotificationException implements Exception {
  final String message;

  PushNotificationException(this.message);

  @override
  String toString() => 'PushNotificationException: $message';
}

/// 通知设置
class NotificationConfig {
  /// 是否启用推送通知
  final bool enabled;

  /// 是否显示消息预览
  final bool showPreview;

  /// 是否播放声音
  final bool playSound;

  /// 是否振动
  final bool vibrate;

  /// 免打扰模式
  final bool doNotDisturb;

  /// 免打扰开始时间
  final TimeOfDay? dndStartTime;

  /// 免打扰结束时间
  final TimeOfDay? dndEndTime;

  /// 通知隐私模式
  final NotificationPrivacyMode privacyMode;

  const NotificationConfig({
    this.enabled = true,
    this.showPreview = true,
    this.playSound = true,
    this.vibrate = true,
    this.doNotDisturb = false,
    this.dndStartTime,
    this.dndEndTime,
    this.privacyMode = NotificationPrivacyMode.full,
  });

  /// 检查当前是否在免打扰时间内
  bool isInDoNotDisturbPeriod() {
    if (!doNotDisturb || dndStartTime == null || dndEndTime == null) {
      return false;
    }

    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = dndStartTime!.hour * 60 + dndStartTime!.minute;
    final endMinutes = dndEndTime!.hour * 60 + dndEndTime!.minute;

    if (startMinutes <= endMinutes) {
      // 同一天内的时间段
      return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
    } else {
      // 跨天的时间段（如22:00 - 07:00）
      return nowMinutes >= startMinutes || nowMinutes <= endMinutes;
    }
  }

  NotificationConfig copyWith({
    bool? enabled,
    bool? showPreview,
    bool? playSound,
    bool? vibrate,
    bool? doNotDisturb,
    TimeOfDay? dndStartTime,
    TimeOfDay? dndEndTime,
    NotificationPrivacyMode? privacyMode,
  }) {
    return NotificationConfig(
      enabled: enabled ?? this.enabled,
      showPreview: showPreview ?? this.showPreview,
      playSound: playSound ?? this.playSound,
      vibrate: vibrate ?? this.vibrate,
      doNotDisturb: doNotDisturb ?? this.doNotDisturb,
      dndStartTime: dndStartTime ?? this.dndStartTime,
      dndEndTime: dndEndTime ?? this.dndEndTime,
      privacyMode: privacyMode ?? this.privacyMode,
    );
  }

  NotificationPresentation presentMessage({
    required String title,
    required String body,
    String genericTitle = 'N42 Chat',
    String genericBody = 'You have a new message',
  }) {
    final normalizedTitle = title.trim().isEmpty ? genericTitle : title;
    final normalizedBody = body.trim().isEmpty ? genericBody : body;

    switch (privacyMode) {
      case NotificationPrivacyMode.full:
        return NotificationPresentation(
          title: normalizedTitle,
          body: showPreview ? normalizedBody : genericBody,
        );
      case NotificationPrivacyMode.senderOnly:
        return NotificationPresentation(
          title: normalizedTitle,
          body: genericBody,
        );
      case NotificationPrivacyMode.hidden:
        return NotificationPresentation(title: genericTitle, body: genericBody);
    }
  }

  bool get allowsNativeForegroundPreview =>
      enabled &&
      privacyMode == NotificationPrivacyMode.full &&
      showPreview;

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'showPreview': showPreview,
      'playSound': playSound,
      'vibrate': vibrate,
      'doNotDisturb': doNotDisturb,
      'dndStartTime': dndStartTime != null
          ? '${dndStartTime!.hour}:${dndStartTime!.minute}'
          : null,
      'dndEndTime': dndEndTime != null
          ? '${dndEndTime!.hour}:${dndEndTime!.minute}'
          : null,
      'privacyMode': privacyMode.name,
    };
  }

  factory NotificationConfig.fromJson(Map<String, dynamic> json) {
    return NotificationConfig(
      enabled: json['enabled'] as bool? ?? true,
      showPreview: json['showPreview'] as bool? ?? true,
      playSound: json['playSound'] as bool? ?? true,
      vibrate: json['vibrate'] as bool? ?? true,
      doNotDisturb: json['doNotDisturb'] as bool? ?? false,
      dndStartTime: _parseTimeOfDay(json['dndStartTime'] as String?),
      dndEndTime: _parseTimeOfDay(json['dndEndTime'] as String?),
      privacyMode: _parsePrivacyMode(json['privacyMode'] as String?),
    );
  }

  static TimeOfDay? _parseTimeOfDay(String? value) {
    if (value == null) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  static NotificationPrivacyMode _parsePrivacyMode(String? value) {
    return NotificationPrivacyMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => NotificationPrivacyMode.full,
    );
  }
}

class NotificationPresentation {
  final String title;
  final String body;

  const NotificationPresentation({required this.title, required this.body});
}
