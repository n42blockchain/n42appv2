import 'dart:convert';

import '../../data/datasources/local/preferences_datasource.dart';
import '../../domain/entities/subscription_entity.dart';
import '../utils/debug_log.dart';

/// 订阅服务
///
/// 管理创作者订阅计划与用户订阅记录（本地偏好存储）。
/// 支付为可选：当前为**记录态**（订阅写本地账本）；接入钱包桥后可在 subscribe
/// 时发起链上转账并回填 txHash（见 N42WalletBridge.requestTransfer）。
class SubscriptionService {
  final PreferencesDataSource _prefs;

  SubscriptionService(this._prefs);

  // ============================================
  // 计划（创作者侧）
  // ============================================

  Future<List<SubscriptionPlan>> getPlans({String? creatorId}) async {
    final raw = await _prefs.getSubscriptionPlans();
    final all = _decodePlans(raw);
    if (creatorId == null) return all;
    return all.where((p) => p.creatorId == creatorId).toList();
  }

  Future<void> upsertPlan(SubscriptionPlan plan) async {
    final all = _decodePlans(await _prefs.getSubscriptionPlans());
    all.removeWhere((p) => p.id == plan.id);
    all.add(plan);
    await _prefs.saveSubscriptionPlans(
      jsonEncode(all.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> removePlan(String planId) async {
    final all = _decodePlans(await _prefs.getSubscriptionPlans());
    all.removeWhere((p) => p.id == planId);
    await _prefs.saveSubscriptionPlans(
      jsonEncode(all.map((e) => e.toJson()).toList()),
    );
  }

  // ============================================
  // 订阅（用户侧）
  // ============================================

  Future<List<UserSubscription>> getMySubscriptions() async {
    final list = _decodeSubs(await _prefs.getUserSubscriptions());
    // 活跃在前，按到期时间降序
    list.sort((a, b) {
      if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
      return b.expiresAt.compareTo(a.expiresAt);
    });
    return list;
  }

  /// 是否已订阅某计划且仍活跃
  Future<bool> isSubscribed(String planId) async {
    final list = await getMySubscriptions();
    return list.any((s) => s.plan.id == planId && s.isActive);
  }

  /// 订阅一个计划（记录态；[txHash] 为经钱包桥支付后回填）
  Future<UserSubscription> subscribe(
    SubscriptionPlan plan, {
    bool autoRenew = false,
    String? txHash,
  }) async {
    final now = DateTime.now();
    final sub = UserSubscription(
      id: 'sub_${now.microsecondsSinceEpoch}',
      plan: plan,
      subscribedAt: now,
      expiresAt: now.add(plan.period.duration),
      autoRenew: autoRenew,
      txHash: txHash,
    );
    final list = _decodeSubs(await _prefs.getUserSubscriptions());
    // 同计划已有活跃订阅则续期而非重复
    final existingIdx =
        list.indexWhere((s) => s.plan.id == plan.id && s.isActive);
    if (existingIdx != -1) {
      final ext = list[existingIdx];
      list[existingIdx] = ext.copyWith(
        expiresAt: ext.expiresAt.add(plan.period.duration),
        cancelled: false,
      );
    } else {
      list.add(sub);
    }
    await _save(list);
    return sub;
  }

  /// 取消（到期不续；保留至 expiresAt）
  Future<void> cancel(String subscriptionId) async {
    final list = _decodeSubs(await _prefs.getUserSubscriptions());
    final i = list.indexWhere((s) => s.id == subscriptionId);
    if (i == -1) return;
    list[i] = list[i].copyWith(cancelled: true, autoRenew: false);
    await _save(list);
  }

  /// 切换自动续订
  Future<void> toggleAutoRenew(String subscriptionId) async {
    final list = _decodeSubs(await _prefs.getUserSubscriptions());
    final i = list.indexWhere((s) => s.id == subscriptionId);
    if (i == -1) return;
    list[i] = list[i].copyWith(autoRenew: !list[i].autoRenew);
    await _save(list);
  }

  // ============================================
  // helpers
  // ============================================

  Future<void> _save(List<UserSubscription> list) async {
    await _prefs.saveUserSubscriptions(
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  List<SubscriptionPlan> _decodePlans(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(SubscriptionPlan.fromJson)
          .toList();
    } catch (e) {
      debugLog('SubscriptionService: decode plans failed: $e');
      return [];
    }
  }

  List<UserSubscription> _decodeSubs(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(UserSubscription.fromJson)
          .toList();
    } catch (e) {
      debugLog('SubscriptionService: decode subs failed: $e');
      return [];
    }
  }
}
