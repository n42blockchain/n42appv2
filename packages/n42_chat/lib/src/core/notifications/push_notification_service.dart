import 'package:flutter/material.dart';

import '../../domain/entities/user_profile_entity.dart'
    show NotificationPrivacyMode, NotificationSettings;

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

  /// 从持久化的 NotificationSettings 构造运行时配置。
  factory NotificationConfig.fromSettings(NotificationSettings settings) {
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
    if (value == null || value.trim().isEmpty) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

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

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'showPreview': showPreview,
      'playSound': playSound,
      'vibrate': vibrate,
      'doNotDisturb': doNotDisturb,
      'dndStartTime': dndStartTime != null
          ? '${dndStartTime!.hour.toString().padLeft(2, '0')}:${dndStartTime!.minute.toString().padLeft(2, '0')}'
          : null,
      'dndEndTime': dndEndTime != null
          ? '${dndEndTime!.hour.toString().padLeft(2, '0')}:${dndEndTime!.minute.toString().padLeft(2, '0')}'
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
