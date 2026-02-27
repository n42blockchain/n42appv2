// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 单个 ENS 域名的到期提醒配置
class EnsExpiryReminderConfig {
  /// 域名（含后缀，如 alice.eth / alice.n42）
  final String domainName;

  /// 到期时间（Unix 毫秒时间戳）
  final int expiresAtMs;

  /// 是否启用
  final bool enabled;

  /// 提醒间隔列表（距到期多少天时提醒，降序，如 [30, 7, 1]）
  final List<int> notifyDays;

  /// 已发送过通知的间隔（避免重复），-1 代表"已过期"通知
  final List<int> notifiedDays;

  const EnsExpiryReminderConfig({
    required this.domainName,
    required this.expiresAtMs,
    required this.enabled,
    this.notifyDays = const [30, 7, 1],
    this.notifiedDays = const [],
  });

  EnsExpiryReminderConfig copyWith({
    bool? enabled,
    int? expiresAtMs,
    List<int>? notifyDays,
    List<int>? notifiedDays,
  }) {
    return EnsExpiryReminderConfig(
      domainName: domainName,
      expiresAtMs: expiresAtMs ?? this.expiresAtMs,
      enabled: enabled ?? this.enabled,
      notifyDays: notifyDays ?? this.notifyDays,
      notifiedDays: notifiedDays ?? this.notifiedDays,
    );
  }

  factory EnsExpiryReminderConfig.fromJson(Map<String, dynamic> json) {
    return EnsExpiryReminderConfig(
      domainName: json['domainName'] as String,
      expiresAtMs: json['expiresAtMs'] as int,
      enabled: json['enabled'] as bool? ?? true,
      notifyDays:
          (json['notifyDays'] as List<dynamic>?)?.map((e) => e as int).toList() ??
              [30, 7, 1],
      notifiedDays:
          (json['notifiedDays'] as List<dynamic>?)?.map((e) => e as int).toList() ??
              [],
    );
  }

  Map<String, dynamic> toJson() => {
        'domainName': domainName,
        'expiresAtMs': expiresAtMs,
        'enabled': enabled,
        'notifyDays': notifyDays,
        'notifiedDays': notifiedDays,
      };

  /// 到期时间（DateTime 形式）
  DateTime get expiresAt => DateTime.fromMillisecondsSinceEpoch(expiresAtMs);

  /// 距到期天数（负数 = 已过期）
  int get daysUntilExpiry =>
      expiresAt.difference(DateTime.now()).inDays;
}

/// ENS 域名到期提醒服务
///
/// 在域名到期前 30 天、7 天、1 天触发本地推送通知；
/// 域名过期后再通知一次"已过期"。
///
/// **持久化**：SharedPreferences key = `ensExpiryReminders`
/// （Map[domainName → EnsExpiryReminderConfig] JSON）
///
/// **调用时机**：
/// - [EnsHomePage.initState] — 每次进入 ENS 首页时检查
/// - 续费成功后 — 调用 [setReminder] 更新到期时间并重置通知记录
/// - 管理页开关 — 调用 [disableReminder] / [setReminder] 切换
class EnsExpiryReminderService {
  static const _prefKey = 'ensExpiryReminders';

  // ── 持久化 ──────────────────────────────────────────

  /// 读取所有域名的提醒配置
  static Future<Map<String, EnsExpiryReminderConfig>> loadAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      if (raw == null || raw.isEmpty) return {};
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map.map(
        (k, v) =>
            MapEntry(k, EnsExpiryReminderConfig.fromJson(v as Map<String, dynamic>)),
      );
    } catch (e) {
      debugPrint('[EnsExpiryReminderService] loadAll error: $e');
      return {};
    }
  }

  /// 持久化所有域名的提醒配置
  static Future<void> saveAll(
      Map<String, EnsExpiryReminderConfig> configs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final map = configs.map((k, v) => MapEntry(k, v.toJson()));
      await prefs.setString(_prefKey, jsonEncode(map));
    } catch (e) {
      debugPrint('[EnsExpiryReminderService] saveAll error: $e');
    }
  }

  /// 设置或更新域名的到期提醒
  ///
  /// [domainName] — 域名（含后缀，如 alice.eth）
  /// [expiresAt]  — 最新到期时间
  /// [notifyDays] — 提醒间隔（默认 [30, 7, 1]）
  ///
  /// 更新到期时间时会重置 [notifiedDays]，确保新时间窗口内重新触发通知。
  static Future<void> setReminder(
    String domainName,
    DateTime expiresAt, {
    List<int> notifyDays = const [30, 7, 1],
  }) async {
    final all = await loadAll();
    all[domainName] = EnsExpiryReminderConfig(
      domainName: domainName,
      expiresAtMs: expiresAt.millisecondsSinceEpoch,
      enabled: true,
      notifyDays: notifyDays,
      notifiedDays: const [], // 重置，以便新时间窗口内重新通知
    );
    await saveAll(all);
  }

  /// 停用域名提醒（保留配置，仅将 enabled 置为 false）
  static Future<void> disableReminder(String domainName) async {
    final all = await loadAll();
    if (all.containsKey(domainName)) {
      all[domainName] = all[domainName]!.copyWith(enabled: false);
      await saveAll(all);
    }
  }

  /// 彻底删除域名提醒配置
  static Future<void> removeReminder(String domainName) async {
    final all = await loadAll();
    all.remove(domainName);
    await saveAll(all);
  }

  /// 读取单个域名的提醒配置（不存在时返回 null）
  static Future<EnsExpiryReminderConfig?> getReminder(String domainName) async {
    final all = await loadAll();
    return all[domainName];
  }

  // ── 检查与通知 ──────────────────────────────────────

  /// 遍历所有已保存的提醒，按需发送本地通知。
  ///
  /// 每个提醒间隔（30d / 7d / 1d / expired）只通知一次，
  /// 续费后调用 [setReminder] 会重置记录，确保新周期内再次通知。
  ///
  /// 建议在 [EnsHomePage.initState] 调用，以覆盖每次进入 ENS 功能的场景。
  static Future<void> checkAndNotify() async {
    try {
      final configs = await loadAll();
      if (configs.isEmpty) return;

      bool changed = false;

      for (final entry in configs.entries) {
        final key = entry.key;
        var config = entry.value;
        if (!config.enabled) continue;

        final daysLeft = config.daysUntilExpiry;

        // 检查各提醒间隔（notifyDays 应降序，如 [30, 7, 1]）
        for (final threshold in config.notifyDays) {
          if (daysLeft <= threshold && !config.notifiedDays.contains(threshold)) {
            // 触发该阈值的提醒
            await _sendExpiryNotification(config.domainName, daysLeft);
            config = config.copyWith(
              notifiedDays: [...config.notifiedDays, threshold],
            );
            configs[key] = config;
            changed = true;
            break; // 一次最多发一条，避免连续轰炸
          }
        }

        // 已过期（daysLeft < 0）且尚未发过"已过期"通知（用 -1 标记）
        if (daysLeft < 0 && !config.notifiedDays.contains(-1)) {
          await _sendExpiredNotification(config.domainName);
          config = config.copyWith(
            notifiedDays: [...config.notifiedDays, -1],
          );
          configs[key] = config;
          changed = true;
        }
      }

      if (changed) {
        await saveAll(configs);
      }
    } catch (e) {
      debugPrint('[EnsExpiryReminderService] checkAndNotify error: $e');
    }
  }

  // ── 内部：发送本地通知 ────────────────────────────────

  static const _androidDetails = AndroidNotificationDetails(
    'high_importance_channel',
    'High Importance Notifications',
    channelDescription: 'This channel is used for important notifications.',
    importance: Importance.high,
    priority: Priority.high,
  );

  static const _iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  static const _notificationDetails = NotificationDetails(
    android: _androidDetails,
    iOS: _iosDetails,
  );

  static Future<void> _sendExpiryNotification(
      String domainName, int daysLeft) async {
    try {
      final String body;
      if (daysLeft <= 0) {
        body = '$domainName expires today! Renew now to keep your domain.';
      } else if (daysLeft == 1) {
        body = '$domainName expires tomorrow. Renew now to avoid losing it.';
      } else {
        body = '$domainName expires in $daysLeft days. Tap to renew.';
      }

      await FlutterLocalNotificationsPlugin().show(
        id: _notificationId(domainName, daysLeft),
        title: 'ENS Domain Expiring Soon',
        body: body,
        notificationDetails: _notificationDetails,
      );
    } catch (e) {
      debugPrint('[EnsExpiryReminderService] _sendExpiryNotification error: $e');
    }
  }

  static Future<void> _sendExpiredNotification(String domainName) async {
    try {
      await FlutterLocalNotificationsPlugin().show(
        id: _notificationId(domainName, -1),
        title: 'ENS Domain Expired',
        body: '$domainName has expired. Renew now to reclaim your domain.',
        notificationDetails: _notificationDetails,
      );
    } catch (e) {
      debugPrint('[EnsExpiryReminderService] _sendExpiredNotification error: $e');
    }
  }

  /// 生成稳定、正值的通知 ID（域名 × 提醒阈值）
  static int _notificationId(String domainName, int daysLeft) {
    // 将 daysLeft 归入最近触发的阈值桶以保持 ID 稳定
    final int bucket;
    if (daysLeft >= 30) {
      bucket = 30;
    } else if (daysLeft >= 7) {
      bucket = 7;
    } else if (daysLeft >= 1) {
      bucket = 1;
    } else {
      bucket = 0; // 0 = expired / today
    }
    return (domainName.hashCode ^ bucket.hashCode) & 0x7FFFFFFF;
  }
}
