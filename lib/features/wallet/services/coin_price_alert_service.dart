// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/features/wallet/api/market_api.dart';
import 'package:n42_wallet/features/wallet/api/market_api_payload_utils.dart';

/// 单个币种的价格到达提醒配置
class CoinPriceAlertConfig {
  /// CoinGecko ID（如 "bitcoin"），作为持久化 key
  final String coinId;

  /// 币种 symbol（小写，如 "btc"），用于向 N42 API 查询当前价格
  final String symbol;

  /// 显示名称（如 "Bitcoin"），用于通知标题
  final String name;

  /// 目标价格（USD）
  final double targetPrice;

  /// true = 价格 **高于** targetPrice 时触发；false = 价格 **低于** 时触发
  final bool alertAbove;

  /// 是否启用
  final bool enabled;

  /// 上次触发通知的时间戳（ms），用于冷却判断
  final int? lastNotifiedMs;

  const CoinPriceAlertConfig({
    required this.coinId,
    required this.symbol,
    required this.name,
    required this.targetPrice,
    required this.alertAbove,
    required this.enabled,
    this.lastNotifiedMs,
  });

  CoinPriceAlertConfig copyWith({
    double? targetPrice,
    bool? alertAbove,
    bool? enabled,
    int? lastNotifiedMs,
  }) => CoinPriceAlertConfig(
    coinId: coinId,
    symbol: symbol,
    name: name,
    targetPrice: targetPrice ?? this.targetPrice,
    alertAbove: alertAbove ?? this.alertAbove,
    enabled: enabled ?? this.enabled,
    lastNotifiedMs: lastNotifiedMs ?? this.lastNotifiedMs,
  );

  factory CoinPriceAlertConfig.fromJson(Map<String, dynamic> json) =>
      CoinPriceAlertConfig(
        coinId: json['coinId'] as String,
        symbol: json['symbol'] as String,
        name: json['name'] as String,
        targetPrice: (json['targetPrice'] as num).toDouble(),
        alertAbove: json['alertAbove'] as bool,
        enabled: json['enabled'] as bool,
        lastNotifiedMs: json['lastNotifiedMs'] as int?,
      );

  Map<String, dynamic> toJson() => {
    'coinId': coinId,
    'symbol': symbol,
    'name': name,
    'targetPrice': targetPrice,
    'alertAbove': alertAbove,
    'enabled': enabled,
    'lastNotifiedMs': lastNotifiedMs,
  };
}

/// 币价到达提醒服务
///
/// 管理各币种的价格阈值提醒配置，当价格穿越阈值时发送本地通知。
///
/// - 数据持久化：SharedPreferences key = `coinPriceAlerts`
/// - 通知冷却：同一币种 60 分钟内不重复触发
/// - 通知渠道：复用 `high_importance_channel`（由 AppPushUtils 创建）
class CoinPriceAlertService {
  static const _prefKey = 'coinPriceAlerts';

  /// 触发同一币种提醒的最小间隔（毫秒）：60 分钟
  static const _cooldownMs = 60 * 60 * 1000;

  // ── 持久化 ──────────────────────────────────────────────────────────────────

  /// 读取所有币种的提醒配置（key = coinId）
  static Future<Map<String, CoinPriceAlertConfig>> loadAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      if (raw == null || raw.isEmpty) return {};
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map.map(
        (k, v) => MapEntry(
          k,
          CoinPriceAlertConfig.fromJson(v as Map<String, dynamic>),
        ),
      );
    } catch (e) {
      AppLogger.w('CoinPriceAlert', 'loadAll error: $e');
      return {};
    }
  }

  /// 保存所有配置（覆盖写）
  static Future<void> saveAll(Map<String, CoinPriceAlertConfig> configs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final map = configs.map((k, v) => MapEntry(k, v.toJson()));
      await prefs.setString(_prefKey, jsonEncode(map));
    } catch (e) {
      AppLogger.w('CoinPriceAlert', 'saveAll error: $e');
    }
  }

  /// 保存/更新单个币种配置
  static Future<void> save(CoinPriceAlertConfig config) async {
    final all = await loadAll();
    all[config.coinId] = config;
    await saveAll(all);
  }

  /// 删除单个币种配置
  static Future<void> remove(String coinId) async {
    final all = await loadAll();
    all.remove(coinId);
    await saveAll(all);
  }

  // ── 检查与通知 ─────────────────────────────────────────────────────────────

  /// 自包含的全量检查：加载已启用的提醒配置 → 向行情 API 查询当前价格 →
  /// 触发 [checkAndNotify]。供启动后的前台周期定时器调用（App 在前台期间
  /// 生效；无系统级后台推送）。无已启用提醒时不产生任何网络请求。
  static Future<void> checkAllNow() async {
    try {
      final configs = await loadAll();
      final enabledSymbols = configs.values
          .where((c) => c.enabled)
          .map((c) => c.symbol.toLowerCase())
          .toSet();
      if (enabledSymbols.isEmpty) return;

      final resp = await MarketApi().getWalletCoinsInfo(
        enabledSymbols.join(','),
      );
      if (resp['error'] != false) return;

      final coins = extractMarketCoinItems(resp['data']);
      if (coins.isEmpty) return;

      final prices = <String, double>{};
      for (final c in coins) {
        final sym = c['coin']?.toString().toLowerCase() ?? '';
        final raw = c['price'];
        final price = (raw is num)
            ? raw.toDouble()
            : double.tryParse(raw?.toString() ?? '') ?? 0.0;
        if (sym.isNotEmpty && price > 0) prices[sym] = price;
      }

      await checkAndNotify(prices);
    } catch (e) {
      AppLogger.w('CoinPriceAlert', 'checkAllNow error: $e');
    }
  }

  /// 检查当前价格是否触发提醒阈值，若触发则发送本地通知。
  ///
  /// [currentPrices] – key 为小写 symbol，value 为 USD 价格
  static Future<void> checkAndNotify(Map<String, double> currentPrices) async {
    try {
      final configs = await loadAll();
      if (configs.isEmpty) return;

      bool changed = false;
      final now = DateTime.now().millisecondsSinceEpoch;

      for (final entry in configs.entries) {
        final config = entry.value;
        if (!config.enabled) continue;

        final price = currentPrices[config.symbol.toLowerCase()];
        if (price == null || price <= 0) continue;

        // 冷却检查
        if (config.lastNotifiedMs != null &&
            now - config.lastNotifiedMs! < _cooldownMs) {
          continue;
        }

        // 阈值触发
        final triggered = config.alertAbove
            ? price >= config.targetPrice
            : price <= config.targetPrice;
        if (!triggered) continue;

        await _sendNotification(price, config);
        configs[entry.key] = config.copyWith(lastNotifiedMs: now);
        changed = true;
      }

      if (changed) await saveAll(configs);
    } catch (e) {
      AppLogger.w('CoinPriceAlert', 'checkAndNotify error: $e');
    }
  }

  // ── 内部：发送本地通知 ─────────────────────────────────────────────────────

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
    double currentPrice,
    CoinPriceAlertConfig config,
  ) async {
    try {
      final direction = config.alertAbove ? 'reached' : 'dropped to';
      final body =
          '${config.name} (${config.symbol.toUpperCase()}) has $direction '
          '\$${_fmtPrice(currentPrice)}. '
          'Your target: \$${_fmtPrice(config.targetPrice)}.';
      final notificationId = ('price_${config.coinId}'.hashCode) & 0x7FFFFFFF;

      await FlutterLocalNotificationsPlugin().show(
        id: notificationId,
        title: '${config.alertAbove ? '🚀' : '📉'} Price Alert: ${config.name}',
        body: body,
        notificationDetails: _notificationDetails,
      );
    } catch (e) {
      AppLogger.w('CoinPriceAlert', '_sendNotification error: $e');
    }
  }

  static String _fmtPrice(double price) {
    if (price >= 1000) return price.toStringAsFixed(2);
    if (price >= 1) return price.toStringAsFixed(4);
    return price
        .toStringAsPrecision(4)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }
}
