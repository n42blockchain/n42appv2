import 'package:flutter/material.dart';

import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/services/subscription_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/subscription_entity.dart';

/// 订阅页：我的订阅 + 可用计划 + 创建计划
class SubscriptionPage extends StatefulWidget {
  /// 限定某创作者（房间/用户）；为空显示全部计划
  final String? creatorId;
  final String? creatorName;

  const SubscriptionPage({super.key, this.creatorId, this.creatorName});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final SubscriptionService _service = getIt<SubscriptionService>();
  List<UserSubscription> _mySubs = const [];
  List<SubscriptionPlan> _plans = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final subs = await _service.getMySubscriptions();
    final plans = await _service.getPlans(creatorId: widget.creatorId);
    if (!mounted) return;
    setState(() {
      _mySubs = subs;
      _plans = plans;
      _loading = false;
    });
  }

  Future<void> _subscribe(SubscriptionPlan plan) async {
    await _service.subscribe(plan);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Subscribed to ${plan.name}'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _cancel(UserSubscription sub) async {
    await _service.cancel(sub.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: AppBar(
        title: Text(widget.creatorName == null
            ? 'Subscriptions'
            : '${widget.creatorName} · Plans'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createPlan,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New plan', style: TextStyle(color: Colors.white)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                children: [
                  if (_mySubs.isNotEmpty) ...[
                    _sectionTitle('My subscriptions'),
                    ..._mySubs.map(_buildMySubCard),
                    const SizedBox(height: 20),
                  ],
                  _sectionTitle('Available plans'),
                  if (_plans.isEmpty)
                    _emptyPlans()
                  else
                    ..._plans.map(_buildPlanCard),
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text(
          t,
          style: TextStyle(
            color: context.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  Widget _emptyPlans() => Container(
        padding: const EdgeInsets.symmetric(vertical: 28),
        alignment: Alignment.center,
        child: Text('No plans yet · tap “New plan” to create one',
            style: TextStyle(color: context.textTertiary)),
      );

  Widget _buildMySubCard(UserSubscription sub) {
    final active = sub.isActive;
    final statusColor = active
        ? AppColors.success
        : (sub.status == SubscriptionStatus.cancelled
            ? AppColors.warning
            : context.textTertiary);
    return Card(
      color: context.surfaceColor,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(sub.plan.name,
                      style: TextStyle(
                          color: context.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    active
                        ? '${sub.daysLeft}d left'
                        : sub.status.name,
                    style: TextStyle(color: statusColor, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('${sub.plan.creatorName} · ${sub.plan.priceLabel}',
                style: TextStyle(color: context.textSecondary, fontSize: 12)),
            if (active) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _service
                        .toggleAutoRenew(sub.id)
                        .then((_) => _load()),
                    child: Text(
                        sub.autoRenew ? 'Auto-renew: on' : 'Auto-renew: off'),
                  ),
                  TextButton(
                    onPressed: () => _cancel(sub),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.error),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    return Card(
      color: context.surfaceColor,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan.name,
                style: TextStyle(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16)),
            if (plan.description != null && plan.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(plan.description!,
                  style:
                      TextStyle(color: context.textSecondary, fontSize: 13)),
            ],
            const SizedBox(height: 8),
            ...plan.benefits.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline,
                          size: 15, color: AppColors.success),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(b,
                            style: TextStyle(
                                color: context.textSecondary, fontSize: 12.5)),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(plan.priceLabel,
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => _subscribe(plan),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Subscribe'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // 创建计划
  // ============================================

  Future<void> _createPlan() async {
    final nameC = TextEditingController();
    final priceC = TextEditingController();
    final descC = TextEditingController();
    final benefitsC = TextEditingController();
    var period = SubscriptionPeriod.monthly;

    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: context.surfaceColor,
          title: const Text('New plan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameC,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: priceC,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Price (e.g. 9.9 USDT)'),
                ),
                TextField(
                  controller: descC,
                  decoration:
                      const InputDecoration(labelText: 'Description (optional)'),
                ),
                TextField(
                  controller: benefitsC,
                  decoration: const InputDecoration(
                      labelText: 'Benefits (comma separated)'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Period:'),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: const Text('Monthly'),
                      selected: period == SubscriptionPeriod.monthly,
                      onSelected: (_) => setLocal(
                          () => period = SubscriptionPeriod.monthly),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Yearly'),
                      selected: period == SubscriptionPeriod.yearly,
                      onSelected: (_) => setLocal(
                          () => period = SubscriptionPeriod.yearly),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Create')),
          ],
        ),
      ),
    );

    if (created == true &&
        mounted &&
        nameC.text.trim().isNotEmpty &&
        priceC.text.trim().isNotEmpty) {
      final plan = SubscriptionPlan(
        id: 'plan_${DateTime.now().microsecondsSinceEpoch}',
        name: nameC.text.trim(),
        description: descC.text.trim().isEmpty ? null : descC.text.trim(),
        price: priceC.text.trim(),
        period: period,
        creatorId: widget.creatorId ?? 'me',
        creatorName: widget.creatorName ?? 'Me',
        benefits: benefitsC.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
      );
      await _service.upsertPlan(plan);
      await _load();
    }
    nameC.dispose();
    priceC.dispose();
    descC.dispose();
    benefitsC.dispose();
  }
}
