import 'package:n42_wallet/features/wallet/models/dex/dex_quote_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_security_verification.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';

class DexSwapConfirm extends StatefulWidget {
  final DexQuoteModel quote;
  const DexSwapConfirm({required this.quote, super.key});

  @override
  State<DexSwapConfirm> createState() => _DexSwapConfirmState();
}

class _DexSwapConfirmState extends State<DexSwapConfirm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_dex_confirm_title),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.space6),
          child: _summaryCard(),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.all(AppSpacing.space6),
        child: _actionRow(),
      ),
    );
  }

  Widget _summaryCard() {
    final q = widget.quote;
    return Container(
      padding: EdgeInsets.all(AppSpacing.space8),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgSurface,
        borderRadius: AppRadius.brMd,
      ),
      child: Column(
        children: [
          _row(
            S.of(context).g_key_dex_you_pay,
            '${q.amountIn} ${q.tokenInSymbol}',
          ),
          _row(
            S.of(context).g_key_dex_you_receive,
            '${q.amountOut} ${q.tokenOutSymbol}',
          ),
          _row(
            S.of(context).g_key_dex_min_received,
            '${q.minAmountOut} ${q.tokenOutSymbol}',
          ),
          _priceImpactRow(q),
          _row(S.of(context).g_key_dex_gas_estimate, q.gasEstimate),
          _row(S.of(context).g_key_dex_best_source, q.source),
          _row(S.of(context).g_key_dex_chain, q.chain),
          if (q.accountAddress.isNotEmpty)
            _row(S.of(context).g_dex_spending_account, q.accountAddress),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.space4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.body.copyWith(
                color: AppColorTokens.of(context).textSubtitle,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.space4),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTypography.body.copyWith(
                color: AppColorTokens.of(context).textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceImpactRow(DexQuoteModel q) {
    final impact = q.priceImpactNum;
    final c = AppColorTokens.of(context);
    final valueColor = switch (impact) {
      >= 3.0 => c.danger,
      >= 1.0 => c.warning,
      _ => c.textPrimary,
    };
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.space4),
      child: Row(
        children: [
          Flexible(
            child: Text(
              S.of(context).g_key_dex_price_impact,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body.copyWith(
                color: AppColorTokens.of(context).textSubtitle,
              ),
            ),
          ),
          const Spacer(),
          Text(
            q.priceImpact.isEmpty ? '—' : q.priceImpact,
            style: AppTypography.body.copyWith(
              color: valueColor,
              fontWeight: impact >= 1.0 ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionRow() {
    return SizedBox(
      height: ScreenUtil().setWidth(88),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              label: S.of(context).g_key_79,
              variant: AppButtonVariant.secondary,
              onPressed: () => Navigator.pop(context, null),
            ),
          ),
          SizedBox(width: AppSpacing.space8),
          Expanded(
            child: AppButton(
              label: S.of(context).g_key_78,
              onPressed: () async {
                final nav = Navigator.of(context);
                final bool? verified = await nav.push(
                  MaterialPageRoute(
                    builder: (_) => WalletSecurityVerification(),
                  ),
                );
                if (verified == true) {
                  nav.pop(true);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
