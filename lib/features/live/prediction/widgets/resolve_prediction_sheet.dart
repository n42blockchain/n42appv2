import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/prediction_market.dart';
import '../providers/prediction_providers.dart';

/// 主播"开奖/管理"弹窗：停盘、选定赢家开奖、或取消市场。
class ResolvePredictionSheet extends ConsumerStatefulWidget {
  const ResolvePredictionSheet({super.key, required this.marketId});

  final String marketId;

  static Future<void> show(BuildContext context, {required String marketId}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1C22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ResolvePredictionSheet(marketId: marketId),
    );
  }

  @override
  ConsumerState<ResolvePredictionSheet> createState() =>
      _ResolvePredictionSheetState();
}

class _ResolvePredictionSheetState
    extends ConsumerState<ResolvePredictionSheet> {
  bool _busy = false;
  String? _error;

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final marketAsync = ref.watch(marketProvider(widget.marketId));
    final repo = ref.read(predictionRepositoryProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: marketAsync.when(
        loading: () => const SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) =>
            SizedBox(height: 120, child: Center(child: Text('$e'))),
        data: (market) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              market.question,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              market.isResolved ? '已开奖' : '选择获胜结果开奖（资金按结果结算）',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 12),
            if (!market.isResolved)
              ...market.outcomes.map(
                (o) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _busy
                          ? null
                          : () => _confirmResolve(context, market, o),
                      child: Text(
                        '${o.label}  获胜  (${(o.price * 100).toStringAsFixed(0)}%)',
                      ),
                    ),
                  ),
                ),
              )
            else
              Text(
                '结果：${market.outcomeById(market.resolvedOutcomeId ?? '')?.label ?? ''}',
                style: const TextStyle(color: Color(0xFF41C36B)),
              ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            ],
            const SizedBox(height: 8),
            if (!market.isResolved)
              Row(
                children: [
                  if (market.isOpen)
                    Expanded(
                      child: TextButton(
                        onPressed: _busy
                            ? null
                            : () => _run(() => repo.closeMarket(market.id)),
                        child: const Text('仅停盘'),
                      ),
                    ),
                  Expanded(
                    child: TextButton(
                      onPressed: _busy
                          ? null
                          : () => _run(() => repo.cancelMarket(market.id)),
                      child: const Text(
                        '取消并退款',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmResolve(
    BuildContext context,
    PredictionMarket market,
    MarketOutcome outcome,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认开奖'),
        content: Text('判定「${outcome.label}」获胜并结算？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('确认开奖'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final repo = ref.read(predictionRepositoryProvider);
    await _run(() async {
      if (market.isOpen) await repo.closeMarket(market.id);
      await repo.resolveMarket(market.id, outcome.id);
    });
  }
}
