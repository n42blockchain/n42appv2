import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

import '../domain/prediction_market.dart';
import '../providers/prediction_providers.dart';

/// 主播"开奖/管理"弹窗：停盘、选定赢家开奖、或取消市场。
class ResolvePredictionSheet extends ConsumerStatefulWidget {
  const ResolvePredictionSheet({super.key, required this.marketId});

  final String marketId;

  static Future<void> show(BuildContext context, {required String marketId}) {
    return showAppSheet<void>(
      context,
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
    final c = AppColorTokens.of(context);
    final marketAsync = ref.watch(marketProvider(widget.marketId));
    final repo = ref.read(predictionRepositoryProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.space8,
        AppSpacing.space8,
        AppSpacing.space8,
        AppSpacing.space12,
      ),
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
              style: AppTypography.title.copyWith(color: c.textPrimary),
            ),
            SizedBox(height: AppSpacing.space2),
            Text(
              market.isResolved ? '已开奖' : '选择获胜结果开奖（资金按结果结算）',
              style: AppTypography.caption.copyWith(color: c.textSecondary),
            ),
            SizedBox(height: AppSpacing.space6),
            if (!market.isResolved)
              ...market.outcomes.map(
                (o) => Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.space4),
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
                style: AppTypography.body.copyWith(color: c.success),
              ),
            if (_error != null) ...[
              SizedBox(height: AppSpacing.space4),
              Text(
                _error!,
                style: AppTypography.bodySm.copyWith(color: c.danger),
              ),
            ],
            SizedBox(height: AppSpacing.space4),
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
                      child: Text('取消并退款', style: TextStyle(color: c.danger)),
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
    final ok = await AppDialog.confirm(
      context,
      title: '确认开奖',
      message: '判定「${outcome.label}」获胜并结算？此操作不可撤销。',
      confirmText: '确认开奖',
    );
    if (!ok) return;
    final repo = ref.read(predictionRepositoryProvider);
    await _run(() async {
      if (market.isOpen) await repo.closeMarket(market.id);
      await repo.resolveMarket(market.id, outcome.id);
    });
  }
}
