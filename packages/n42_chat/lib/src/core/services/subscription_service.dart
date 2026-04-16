import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/subscription_entity.dart';
import '../utils/debug_log.dart';

/// 订阅管理服务
///
/// 管理创建者发布的订阅计划 + 用户的订阅记录。
/// 链上流式付款（Superfluid/Sablier）的实际合约交互由
/// 宿主通过 `IWalletBridge` 执行，本服务仅管理元数据。
class SubscriptionService {
  static const _plansKey = 'n42_subscription_plans';
  static const _subsKey = 'n42_user_subscriptions';

  /// 创建/更新一个订阅计划。
  Future<void> savePlan(SubscriptionPlan plan) async {
    final prefs = await SharedPreferences.getInstance();
    final plans = await getPlans();
    plans.removeWhere((p) => p.id == plan.id);
    plans.add(plan);
    await prefs.setString(
      _plansKey,
      jsonEncode(plans.map((p) => p.toJson()).toList()),
    );
  }

  /// 获取所有订阅计划。
  Future<List<SubscriptionPlan>> getPlans({String? roomId}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_plansKey);
    if (raw == null) return [];
    try {
      final list = (jsonDecode(raw) as List)
          .whereType<Map<String, dynamic>>()
          .map(SubscriptionPlan.fromJson)
          .toList();
      if (roomId != null) {
        return list.where((p) => p.roomId == roomId).toList();
      }
      return list;
    } catch (e) {
      debugLog('SubscriptionService: parse plans failed - $e');
      return [];
    }
  }

  /// 删除订阅计划。
  Future<void> removePlan(String planId) async {
    final prefs = await SharedPreferences.getInstance();
    final plans = await getPlans();
    plans.removeWhere((p) => p.id == planId);
    await prefs.setString(
      _plansKey,
      jsonEncode(plans.map((p) => p.toJson()).toList()),
    );
  }

  /// 记录一条用户订阅。
  Future<void> saveSubscription(UserSubscription sub) async {
    final prefs = await SharedPreferences.getInstance();
    final subs = await getSubscriptions();
    subs.removeWhere((s) => s.id == sub.id);
    subs.add(sub);
    await prefs.setString(
      _subsKey,
      jsonEncode(subs.map((s) => s.toJson()).toList()),
    );
  }

  /// 获取当前用户的所有订阅。
  Future<List<UserSubscription>> getSubscriptions({
    SubscriptionStatus? status,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_subsKey);
    if (raw == null) return [];
    try {
      var list = (jsonDecode(raw) as List)
          .whereType<Map<String, dynamic>>()
          .map(UserSubscription.fromJson)
          .toList();
      if (status != null) {
        list = list.where((s) => s.status == status).toList();
      }
      return list;
    } catch (e) {
      debugLog('SubscriptionService: parse subs failed - $e');
      return [];
    }
  }

  /// 取消订阅（标记状态，链上取消由宿主处理）。
  Future<void> cancelSubscription(String subscriptionId) async {
    final prefs = await SharedPreferences.getInstance();
    final subs = await getSubscriptions();
    final idx = subs.indexWhere((s) => s.id == subscriptionId);
    if (idx < 0) return;
    final updated = UserSubscription(
      id: subs[idx].id,
      planId: subs[idx].planId,
      subscriberId: subs[idx].subscriberId,
      status: SubscriptionStatus.cancelled,
      startedAt: subs[idx].startedAt,
      expiresAt: subs[idx].expiresAt,
      streamContractAddress: subs[idx].streamContractAddress,
      cancelledAt: DateTime.now(),
      txHash: subs[idx].txHash,
    );
    subs[idx] = updated;
    await prefs.setString(
      _subsKey,
      jsonEncode(subs.map((s) => s.toJson()).toList()),
    );
  }

  /// 检查过期订阅并批量标记。
  Future<int> expireOverdue() async {
    final prefs = await SharedPreferences.getInstance();
    final allSubs = await getSubscriptions();
    int count = 0;
    bool changed = false;
    for (int i = 0; i < allSubs.length; i++) {
      final sub = allSubs[i];
      if (sub.status == SubscriptionStatus.active && sub.isExpired) {
        allSubs[i] = UserSubscription(
          id: sub.id,
          planId: sub.planId,
          subscriberId: sub.subscriberId,
          status: SubscriptionStatus.expired,
          startedAt: sub.startedAt,
          expiresAt: sub.expiresAt,
          streamContractAddress: sub.streamContractAddress,
          txHash: sub.txHash,
        );
        count++;
        changed = true;
      }
    }
    if (changed) {
      await prefs.setString(
        _subsKey,
        jsonEncode(allSubs.map((s) => s.toJson()).toList()),
      );
    }
    return count;
  }
}
