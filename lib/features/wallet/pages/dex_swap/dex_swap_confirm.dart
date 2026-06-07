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
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          ScreenUtil().setWidth(30),
          ScreenUtil().setWidth(30),
          ScreenUtil().setWidth(30),
          0,
        ),
        child: Column(
          children: [
            _summaryCard(),
            const Spacer(),
            _actionRow(),
            SizedBox(height: ScreenUtil().setWidth(36)),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard() {
    final q = widget.quote;
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
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
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(14)),
      child: Row(
        children: [
          Text(
            label,
            style: AppTypography.body.copyWith(
              color: AppColorTokens.of(context).textSubtitle,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTypography.body.copyWith(
              color: AppColorTokens.of(context).textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceImpactRow(DexQuoteModel q) {
    final impact = q.priceImpactNum;
    final valueColor = switch (impact) {
      >= 3.0 => Colors.red,
      >= 1.0 => Colors.orange,
      _ => AppColorTokens.of(context).textPrimary,
    };
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(14)),
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
            q.priceImpact,
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
          SizedBox(width: ScreenUtil().setWidth(30)),
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
