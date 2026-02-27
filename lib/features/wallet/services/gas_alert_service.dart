// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 单个网络的 Gas 价格提醒配置
class GasAlertConfig {
  final String symbol;

  /// 提醒阈值（Gwei）
  final double threshold;

  /// true = 低于阈值时提醒；false = 高于阈值时提醒
  final bool alertBelow;

  /// 是否启用
  final bool enabled;

  /// 上次触发通知的时间戳（ms），用于冷却判断
  final int? lastNotifiedMs;

  const GasAlertConfig({
    required this.symbol,
    required this.threshold,
    required this.alertBelow,
    required this.enabled,
    this.lastNotifiedMs,
  });

  GasAlertConfig copyWith({
    double? threshold,
    bool? alertBelow,
    bool? enabled,
    int? lastNotifiedMs,
  }) {
    return GasAlertConfig(
      symbol: symbol,
      threshold: threshold ?? this.threshold,
      alertBelow: alertBelow ?? this.alertBelow,
      enabled: enabled ?? this.enabled,
      lastNotifiedMs: lastNotifiedMs ?? this.lastNotifiedMs,
    );
  }

  factory GasAlertConfig.fromJson(Map<String, dynamic> json) {
    return GasAlertConfig(
      symbol: json['symbol'] as String,
      threshold: (json['threshold'] as num).toDouble(),
      alertBelow: json['alertBelow'] as bool,
      enabled: json['enabled'] as bool,
      lastNotifiedMs: json['lastNotifiedMs'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'threshold': threshold,
        'alertBelow': alertBelow,
        'enabled': enabled,
        'lastNotifiedMs': lastNotifiedMs,
      };
}

/// Gas 价格提醒服务
///
/// 管理每个 EVM 网络的阈值提醒配置，在 Gas 价格穿越阈值时触发本地通知。
///
/// - 数据持久化：SharedPreferences key = `gasAlertSettings`
/// - 通知冷却：同一网络 10 分钟内不重复触发
/// - 通知渠道：复用 `high_importance_channel`（由 AppPushUtils 创建）
class GasAlertService {
  static const _prefKey = 'gasAlertSettings';

  /// 触发同一网络提醒的最小间隔（毫秒）
  static const _cooldownMs = 10 * 60 * 1000;

  // ── 持久化 ──────────────────────────────────────────

  /// 读取所有网络的提醒配置
  static Future<Map<String, GasAlertConfig>> loadAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      if (raw == null || raw.isEmpty) return {};
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map.map(
        (k, v) => MapEntry(k, GasAlertConfig.fromJson(v as Map<String, dynamic>)),
      );
    } catch (e) {
      debugPrint('[GasAlertService] loadAll error: $e');
      return {};
    }
  }

  /// 保存所有网络的提醒配置
  static Future<void> saveAll(Map<String, GasAlertConfig> configs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final map = configs.map((k, v) => MapEntry(k, v.toJson()));
      await prefs.setString(_prefKey, jsonEncode(map));
    } catch (e) {
      debugPrint('[GasAlertService] saveAll error: $e');
    }
  }

  /// 保存单个网络的提醒配置
  static Future<void> save(GasAlertConfig config) async {
    final all = await loadAll();
    all[config.symbol] = config;
    await saveAll(all);
  }

  /// 删除单个网络的提醒配置
  static Future<void> remove(String symbol) async {
    final all = await loadAll();
    all.remove(symbol);
    await saveAll(all);
  }

  // ── 检查与通知 ──────────────────────────────────────

  /// 检查当前 Gas 价格是否触发提醒阈值，若触发则发送本地通知。
  ///
  /// [currentPrices]  各网络当前 Gas 价格（Gwei）
  /// [networkNames]   symbol → 显示名称（如 "Ethereum"）
  static Future<void> checkAndNotify(
    Map<String, double> currentPrices,
    Map<String, String> networkNames,
  ) async {
    try {
      final configs = await loadAll();
      bool changed = false;
      final now = DateTime.now().millisecondsSinceEpoch;

      for (final entry in configs.entries) {
        final symbol = entry.key;
        final config = entry.value;
        if (!config.enabled) continue;

        final price = currentPrices[symbol];
        if (price == null) continue;

        // 冷却检查
        if (config.lastNotifiedMs != null &&
            now - config.lastNotifiedMs! < _cooldownMs) {
          continue;
        }

        // 阈值触发检查
        final triggered =
            config.alertBelow ? price < config.threshold : price > config.threshold;
        if (!triggered) continue;

        final networkName = networkNames[symbol] ?? symbol;
        await _sendNotification(symbol, networkName, price, config);

        configs[symbol] = config.copyWith(lastNotifiedMs: now);
        changed = true;
      }

      if (changed) {
        await saveAll(configs);
      }
    } catch (e) {
      debugPrint('[GasAlertService] checkAndNotify error: $e');
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

  static Future<void> _sendNotification(
    String symbol,
    String networkName,
    double price,
    GasAlertConfig config,
  ) async {
    try {
      final direction = config.alertBelow ? 'below' : 'above';
      final body =
          '$networkName gas is ${price.toStringAsFixed(2)} Gwei '
          '($direction ${config.threshold.toStringAsFixed(0)} Gwei threshold)';

      await FlutterLocalNotificationsPlugin().show(
        id: symbol.hashCode & 0x7FFFFFFF, // ensure positive
        title: 'Gas Alert: $networkName',
        body: body,
        notificationDetails: _notificationDetails,
      );
    } catch (e) {
      debugPrint('[GasAlertService] _sendNotification error: $e');
    }
  }
}
