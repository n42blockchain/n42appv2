import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    // 仅在有截止时间的进行中市场需要每秒刷新倒计时/到点停盘。
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.insights, color: Color(0xFF8AB4FF), size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  market.question,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _StatusTag(market: market, tradable: _tradable),
            ],
          ),
          if (_tradable && market.closesAt != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: _CountdownText(closesAt: market.closesAt!),
            ),
          const SizedBox(height: 8),
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
              padding: const EdgeInsets.only(top: 8),
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
          const SizedBox(height: 4),
          Text(
            '成交量 ${market.totalVolume.toStringAsFixed(0)} $symbol',
            style: const TextStyle(color: Colors.white38, fontSize: 10),
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
        const Icon(Icons.timer_outlined, color: Colors.white54, size: 12),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: secs <= 10 && secs > 0
                ? const Color(0xFFFFB020)
                : Colors.white54,
            fontSize: 11,
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
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: tradable
            ? () => TradeSheet.show(
                context,
                marketId: market.id,
                outcomeId: outcome.id,
              )
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isWinner
                ? const Color(0x3341C36B)
                : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
            border: isWinner
                ? Border.all(color: const Color(0xFF41C36B))
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  outcome.label,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              if (heldShares > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    '持 ${heldShares.toStringAsFixed(1)}',
                    style: const TextStyle(
                      color: Color(0xFFFFD24D),
                      fontSize: 11,
                    ),
                  ),
                ),
              Text(
                '$pct%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (tradable)
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Icon(
                    Icons.add_circle_outline,
                    color: Colors.white54,
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
      color = const Color(0xFFFFB020);
    } else {
      switch (market.status) {
        case MarketStatus.open:
          text = '进行中';
          color = const Color(0xFF41C36B);
        case MarketStatus.closed:
          text = '待开奖';
          color = const Color(0xFFFFB020);
        case MarketStatus.resolved:
          final w = market.outcomeById(market.resolvedOutcomeId ?? '');
          text = '已开奖：${w?.label ?? ''}';
          color = const Color(0xFF8AB4FF);
        case MarketStatus.cancelled:
          text = '已取消';
          color = Colors.white38;
      }
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10)),
    );
  }
}
