import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../domain/prediction_market.dart';
import '../providers/prediction_providers.dart';
import 'prediction_error_text.dart';

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
    return showAppSheet<void>(
      context,
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
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _amount.addListener(_onAmountChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshQuote());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _amount.removeListener(_onAmountChanged);
    _amount.dispose();
    super.dispose();
  }

  /// 输入防抖：停止输入 250ms 后再请求报价，避免逐字符刷报价。
  void _onAmountChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), _refreshQuote);
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
      final repo = ref.read(predictionRepositoryProvider);
      // 买入前用最新报价，避免输入后立即下单时沿用过期 quote 的滑点保护。
      final fresh = await repo.quoteBuy(
        marketId: widget.marketId,
        outcomeId: _outcomeId,
        collateralIn: amount,
      );
      await repo.buy(
        marketId: widget.marketId,
        outcomeId: _outcomeId,
        collateralIn: amount,
        minShares: fresh.shares * 0.99, // 1% 滑点保护
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => _error = predictionErrorText(context, e));
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
      if (mounted) setState(() => _error = predictionErrorText(context, e));
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
        left: AppSpacing.space8,
        right: AppSpacing.space8,
        top: AppSpacing.space8,
        bottom: AppSpacing.space8 + MediaQuery.of(context).viewInsets.bottom,
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
    final c = AppColorTokens.of(context);
    final symbol = market.collateral.symbol;
    final tradable =
        market.isOpen &&
        (market.closesAt == null || DateTime.now().isBefore(market.closesAt!));
    final held = position?.sharesOf(_outcomeId) ?? 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          market.question,
          style: AppTypography.title.copyWith(color: c.textPrimary),
        ),
        SizedBox(height: AppSpacing.space6),
        // 结果选择
        Wrap(
          spacing: AppSpacing.space4,
          runSpacing: AppSpacing.space4,
          children: [
            for (final o in market.outcomes)
              ChoiceChip(
                label: Text(
                  '${o.label}  ${(o.price * 100).toStringAsFixed(0)}%',
                ),
                selected: o.id == _outcomeId,
                selectedColor: c.brandSubtle,
                onSelected: tradable
                    ? (_) {
                        setState(() => _outcomeId = o.id);
                        _refreshQuote();
                      }
                    : null,
              ),
          ],
        ),
        SizedBox(height: AppSpacing.space6),
        Text(
          S.of(context).g_pred_balance(balance.toStringAsFixed(2), symbol),
          style: AppTypography.caption.copyWith(color: c.textSecondary),
        ),
        SizedBox(height: AppSpacing.space4),
        if (tradable) ...[
          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            style: AppTypography.body.copyWith(color: c.textPrimary),
            decoration: InputDecoration(
              labelText: S.of(context).g_pred_amount_input(symbol),
              labelStyle: TextStyle(color: c.textSecondary),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: c.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: c.brand),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.space4),
          if (_quote != null)
            Text(
              S
                  .of(context)
                  .g_pred_quote_info(
                    _quote!.shares.toStringAsFixed(2),
                    (_quote!.avgPrice * 100).toStringAsFixed(1),
                    (_quote!.priceAfter * 100).toStringAsFixed(0),
                  ),
              style: AppTypography.caption.copyWith(color: c.textSecondary),
            ),
          if (_error != null) ...[
            SizedBox(height: AppSpacing.space2),
            Text(_error!, style: TextStyle(color: c.danger)),
          ],
          SizedBox(height: AppSpacing.space6),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _busy ? null : _buy,
                  child: Text(
                    _busy
                        ? S.of(context).g_pred_processing
                        : S.of(context).g_pred_buy,
                  ),
                ),
              ),
              if (held > 0) ...[
                SizedBox(width: AppSpacing.space4),
                OutlinedButton(
                  onPressed: _busy ? null : () => _sell(held),
                  child: Text(
                    S.of(context).g_pred_sell_n(held.toStringAsFixed(1)),
                  ),
                ),
              ],
            ],
          ),
        ] else
          Text(
            S.of(context).g_pred_closed_waiting,
            style: AppTypography.body.copyWith(color: c.textSecondary),
          ),
      ],
    );
  }
}
