import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

import '../domain/prediction_market.dart';
import '../providers/prediction_providers.dart';
import 'trade_sheet.dart';

/// 直播间内的预测市场卡片（观众端）。展示当前市场的问题、各结果价格（=概率）、
/// 倒计时、我的持仓与赎回。点结果打开下注弹窗。无市场则不显示。
class PredictionCard extends ConsumerWidget {
  const PredictionCard({super.key, required this.roomId});

  final String roomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final markets = ref.watch(roomMarketsProvider(roomId)).asData?.value;
    if (markets == null || markets.isEmpty) return const SizedBox.shrink();
    return _Card(market: markets.first); // 最近一个
  }
}

class _Card extends ConsumerStatefulWidget {
  const _Card({required this.market});

  final PredictionMarket market;

  @override
  ConsumerState<_Card> createState() => _CardState();
}

class _CardState extends ConsumerState<_Card> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _maybeStartTicker();
  }

  @override
  void didUpdateWidget(covariant _Card oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 市场状态可能变化（新市场/开奖），重新评估是否需要倒计时表。
    _maybeStartTicker();
  }

  /// 仅"进行中 + 有截止 + 未到点"才需要每秒刷新倒计时；到点后自停，
  /// 避免对已开奖/无截止的卡片常驻 setState。
  void _maybeStartTicker() {
    final m = widget.market;
    final need =
        m.isOpen && m.closesAt != null && DateTime.now().isBefore(m.closesAt!);
    if (need && _ticker == null) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {});
        final mm = widget.market;
        final stillNeed =
            mm.isOpen &&
            mm.closesAt != null &&
            DateTime.now().isBefore(mm.closesAt!);
        if (!stillNeed) {
          _ticker?.cancel();
          _ticker = null;
        }
      });
    } else if (!need && _ticker != null) {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  /// 本地推算是否已过截止（不依赖后端再次推送）。
  bool get _expired =>
      widget.market.closesAt != null &&
      DateTime.now().isAfter(widget.market.closesAt!);

  bool get _tradable => widget.market.isOpen && !_expired;

  @override
  Widget build(BuildContext context) {
    final market = widget.market;
    final position = ref.watch(positionProvider(market.id)).asData?.value;
    final symbol = market.collateral.symbol;

    return Container(
      padding: AppSpacing.cardInset,
      decoration: BoxDecoration(
        color: AppColorTokens.overlay,
        borderRadius: AppRadius.brLg,
        border: Border.all(color: AppColorTokens.onOverlayBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.insights,
                color: AppColorTokens.brandOnOverlay,
                size: 16,
              ),
              SizedBox(width: AppSpacing.space2),
              Expanded(
                child: Text(
                  market.question,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyStrong.copyWith(
                    color: AppColorTokens.onOverlayPrimary,
                  ),
                ),
              ),
              _StatusTag(market: market, tradable: _tradable),
            ],
          ),
          if (_tradable && market.closesAt != null)
            Padding(
              padding: EdgeInsets.only(top: AppSpacing.space2),
              child: _CountdownText(closesAt: market.closesAt!),
            ),
          SizedBox(height: AppSpacing.space4),
          ...market.outcomes.map(
            (o) => _OutcomeRow(
              market: market,
              outcome: o,
              tradable: _tradable,
              heldShares: position?.sharesOf(o.id) ?? 0,
              isWinner: market.isResolved && market.resolvedOutcomeId == o.id,
            ),
          ),
          if (market.isResolved && position != null && !position.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: AppSpacing.space4),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: position.claimed
                      ? null
                      : () => _redeem(context, ref),
                  child: Text(position.claimed ? '已赎回' : '赎回奖金'),
                ),
              ),
            ),
          SizedBox(height: AppSpacing.space2),
          Text(
            '成交量 ${market.totalVolume.toStringAsFixed(0)} $symbol',
            style: AppTypography.captionSm.copyWith(
              color: AppColorTokens.onOverlayTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _redeem(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(predictionRepositoryProvider).redeem(widget.market.id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('赎回失败：$e')));
      }
    }
  }
}

class _CountdownText extends StatelessWidget {
  const _CountdownText({required this.closesAt});

  final DateTime closesAt;

  @override
  Widget build(BuildContext context) {
    final remain = closesAt.difference(DateTime.now());
    final secs = remain.inSeconds;
    final text = secs <= 0
        ? '已截止'
        : '${(secs ~/ 60).toString().padLeft(2, '0')}:'
              '${(secs % 60).toString().padLeft(2, '0')} 后截止';
    return Row(
      children: [
        const Icon(
          Icons.timer_outlined,
          color: AppColorTokens.onOverlaySecondary,
          size: 12,
        ),
        SizedBox(width: AppSpacing.space2),
        Text(
          text,
          style: AppTypography.captionSm.copyWith(
            color: secs <= 10 && secs > 0
                ? AppColorTokens.warningOnOverlay
                : AppColorTokens.onOverlaySecondary,
          ),
        ),
      ],
    );
  }
}

class _OutcomeRow extends StatelessWidget {
  const _OutcomeRow({
    required this.market,
    required this.outcome,
    required this.tradable,
    required this.heldShares,
    required this.isWinner,
  });

  final PredictionMarket market;
  final MarketOutcome outcome;
  final bool tradable;
  final double heldShares;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    final pct = (outcome.price * 100).toStringAsFixed(0);
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.space2),
      child: InkWell(
        onTap: tradable
            ? () => TradeSheet.show(
                context,
                marketId: market.id,
                outcomeId: outcome.id,
              )
            : null,
        borderRadius: AppRadius.brMd,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space4,
          ),
          decoration: BoxDecoration(
            color: isWinner
                ? AppColorTokens.successOnOverlay.withValues(alpha: 0.2)
                : AppColorTokens.onOverlayBorder,
            borderRadius: AppRadius.brMd,
            border: isWinner
                ? Border.all(color: AppColorTokens.successOnOverlay)
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  outcome.label,
                  style: AppTypography.body.copyWith(
                    color: AppColorTokens.onOverlayPrimary,
                  ),
                ),
              ),
              if (heldShares > 0)
                Padding(
                  padding: EdgeInsets.only(right: AppSpacing.space4),
                  child: Text(
                    '持 ${heldShares.toStringAsFixed(1)}',
                    style: AppTypography.captionSm.copyWith(
                      color: AppColorTokens.highlight,
                    ),
                  ),
                ),
              Text(
                '$pct%',
                style: AppTypography.bodyStrong.copyWith(
                  color: AppColorTokens.onOverlayPrimary,
                ),
              ),
              if (tradable)
                Padding(
                  padding: EdgeInsets.only(left: AppSpacing.space2),
                  child: const Icon(
                    Icons.add_circle_outline,
                    color: AppColorTokens.onOverlaySecondary,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.market, required this.tradable});
  final PredictionMarket market;
  final bool tradable;

  @override
  Widget build(BuildContext context) {
    late final String text;
    late final Color color;
    // 本地到点优先显示"待开奖"，即便后端尚未推送停盘。
    if (market.isOpen && !tradable) {
      text = '待开奖';
      color = AppColorTokens.warningOnOverlay;
    } else {
      switch (market.status) {
        case MarketStatus.open:
          text = '进行中';
          color = AppColorTokens.successOnOverlay;
        case MarketStatus.closed:
          text = '待开奖';
          color = AppColorTokens.warningOnOverlay;
        case MarketStatus.resolved:
          final w = market.outcomeById(market.resolvedOutcomeId ?? '');
          text = '已开奖：${w?.label ?? ''}';
          color = AppColorTokens.brandOnOverlay;
        case MarketStatus.cancelled:
          text = '已取消';
          color = AppColorTokens.onOverlayTertiary;
      }
    }
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space2,
        vertical: AppSpacing.space2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: AppRadius.brSm,
      ),
      child: Text(text, style: AppTypography.captionSm.copyWith(color: color)),
    );
  }
}
