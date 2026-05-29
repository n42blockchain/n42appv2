import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/prediction_market.dart';
import '../providers/prediction_providers.dart';

/// 观众下注/卖出弹窗（Polymarket 式份额交易）。
class TradeSheet extends ConsumerStatefulWidget {
  const TradeSheet({
    super.key,
    required this.marketId,
    required this.outcomeId,
  });

  final String marketId;
  final String outcomeId;

  static Future<void> show(
    BuildContext context, {
    required String marketId,
    required String outcomeId,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1C22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => TradeSheet(marketId: marketId, outcomeId: outcomeId),
    );
  }

  @override
  ConsumerState<TradeSheet> createState() => _TradeSheetState();
}

class _TradeSheetState extends ConsumerState<TradeSheet> {
  final TextEditingController _amount = TextEditingController(text: '10');
  late String _outcomeId = widget.outcomeId;
  TradeQuote? _quote;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _amount.addListener(_refreshQuote);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshQuote());
  }

  @override
  void dispose() {
    _amount.removeListener(_refreshQuote);
    _amount.dispose();
    super.dispose();
  }

  Future<void> _refreshQuote() async {
    final amount = double.tryParse(_amount.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _quote = null);
      return;
    }
    try {
      final q = await ref
          .read(predictionRepositoryProvider)
          .quoteBuy(
            marketId: widget.marketId,
            outcomeId: _outcomeId,
            collateralIn: amount,
          );
      if (mounted) setState(() => _quote = q);
    } catch (_) {
      if (mounted) setState(() => _quote = null);
    }
  }

  Future<void> _buy() async {
    final amount = double.tryParse(_amount.text.trim());
    if (amount == null || amount <= 0) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final q = _quote;
      await ref
          .read(predictionRepositoryProvider)
          .buy(
            marketId: widget.marketId,
            outcomeId: _outcomeId,
            collateralIn: amount,
            // 1% 滑点保护
            minShares: q == null ? null : q.shares * 0.99,
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sell(double shares) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(predictionRepositoryProvider)
          .sell(
            marketId: widget.marketId,
            outcomeId: _outcomeId,
            shares: shares,
          );
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
    final balance = ref.watch(predictionBalanceProvider).asData?.value ?? 0;
    final position = ref.watch(positionProvider(widget.marketId)).asData?.value;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: marketAsync.when(
        loading: () => const SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) =>
            SizedBox(height: 120, child: Center(child: Text('$e'))),
        data: (market) => _buildBody(market, balance, position),
      ),
    );
  }

  Widget _buildBody(
    PredictionMarket market,
    double balance,
    UserPosition? position,
  ) {
    final symbol = market.collateral.symbol;
    final tradable = market.isOpen;
    final held = position?.sharesOf(_outcomeId) ?? 0;

    return Column(
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
        const SizedBox(height: 12),
        // 结果选择
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final o in market.outcomes)
              ChoiceChip(
                label: Text(
                  '${o.label}  ${(o.price * 100).toStringAsFixed(0)}%',
                ),
                selected: o.id == _outcomeId,
                onSelected: tradable
                    ? (_) {
                        setState(() => _outcomeId = o.id);
                        _refreshQuote();
                      }
                    : null,
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '余额：${balance.toStringAsFixed(2)} $symbol',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 8),
        if (tradable) ...[
          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: '投入金额 ($symbol)',
              labelStyle: const TextStyle(color: Colors.white54),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white54),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_quote != null)
            Text(
              '预计获得 ${_quote!.shares.toStringAsFixed(2)} 份额'
              ' · 均价 ${(_quote!.avgPrice * 100).toStringAsFixed(1)}%'
              ' · 成交后 ${(_quote!.priceAfter * 100).toStringAsFixed(0)}%',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          if (_error != null) ...[
            const SizedBox(height: 6),
            Text(_error!, style: const TextStyle(color: Colors.redAccent)),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _busy ? null : _buy,
                  child: Text(_busy ? '处理中…' : '买入'),
                ),
              ),
              if (held > 0) ...[
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _busy ? null : () => _sell(held),
                  child: Text('卖出 ${held.toStringAsFixed(1)}'),
                ),
              ],
            ],
          ),
        ] else
          const Text('已停盘，等待开奖', style: TextStyle(color: Colors.white54)),
      ],
    );
  }
}
