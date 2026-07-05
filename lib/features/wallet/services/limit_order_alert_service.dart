// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/features/wallet/api/dex_swap_api.dart';
import 'package:n42_wallet/features/wallet/models/dex/dex_limit_order_model.dart';

/// 限价单到价提醒。
///
/// 后端价格监控到价后只把订单标记为 triggered、并不执行成交（非托管钱包无法
/// 由服务端代签）；执行需要用户回到 App 内确认。本服务在前台周期轮询用户的
/// 限价单，发现新进入 triggered 状态的订单时发一条本地通知，引导用户回到
/// Swap 页手动执行——这是"到价标记 + 客户端执行"设计里缺失的客户端一半。
///
/// - 已通知的订单 ID 持久化在 SharedPreferences（key `limitOrderNotifiedIds`），
///   避免每轮重复轰炸；
/// - 未登录 / 无订单时零网络请求之外的开销（查询本身即列表接口）。
class LimitOrderAlertService {
  static const _notifiedKey = 'limitOrderNotifiedIds';

  /// 保留的已通知 ID 上限，防止无限增长。
  static const _maxNotifiedIds = 200;

  /// 前台周期检查入口（由 main.dart 的定时器调用）。
  static Future<void> checkAllNow() async {
    try {
      final uuid = AppGlobals.userInfo?.uuid;
      if (uuid == null || uuid.isEmpty) return;

      final result = await DexSwapApi().getLimitOrders(uuid, size: 50);
      if (result.error || result.data is! List) return;

      final orders = (result.data as List)
          .whereType<Map<String, dynamic>>()
          .map(DexLimitOrderModel.fromJson)
          .where((o) => o.isTriggered)
          .toList();
      if (orders.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      final notified = (prefs.getStringList(_notifiedKey) ?? []).toSet();

      var changed = false;
      for (final order in orders) {
        if (order.orderId.isEmpty || notified.contains(order.orderId)) {
          continue;
        }
        await _sendNotification(order);
        notified.add(order.orderId);
        changed = true;
      }

      if (changed) {
        final list = notified.toList();
        if (list.length > _maxNotifiedIds) {
          list.removeRange(0, list.length - _maxNotifiedIds);
        }
        await prefs.setStringList(_notifiedKey, list);
      }
    } catch (e) {
      AppLogger.w('LimitOrderAlert', 'checkAllNow error: $e');
    }
  }

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

  static Future<void> _sendNotification(DexLimitOrderModel order) async {
    try {
      final notificationId = ('limit_${order.orderId}'.hashCode) & 0x7FFFFFFF;
      await FlutterLocalNotificationsPlugin().show(
        id: notificationId,
        title: '🎯 Limit Order Triggered',
        // 诚实文案:非托管钱包后端无私钥不能代签、无自动成交引擎,到价后需
        // 用户在 App 内手动兑换(接线复审第二轮 P1:此前承诺"execute"但无一键
        // 执行入口)。限价单页 triggered 项提供 "Go to Swap" 跳转。
        body:
            '${order.symbolIn} → ${order.symbolOut} hit your limit price '
            '${order.limitPrice}. Open the app to swap manually.',
        notificationDetails: _notificationDetails,
      );
    } catch (e) {
      AppLogger.w('LimitOrderAlert', '_sendNotification error: $e');
    }
  }
}
