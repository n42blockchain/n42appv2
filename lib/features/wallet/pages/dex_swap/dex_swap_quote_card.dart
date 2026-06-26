import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet/models/dex/dex_quote_model.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

/// Displays a fetched DEX quote with route, price-impact, gas, min-received,
/// a countdown until the quote expires, optional high-impact warning, and an
/// ERC-20 approval notice with unlimited/exact toggle.
class DexQuoteCard extends StatelessWidget {
  const DexQuoteCard({
    super.key,
    required this.quote,
    required this.secsLeft,
    required this.needsApproval,
    required this.exactApprove,
    required this.tokenInSymbol,
    required this.onExactApproveChanged,
  });

  final DexQuoteModel quote;

  /// Seconds remaining before the quote is stale (0 = refresh in progress).
  final int secsLeft;

  /// Whether the token-in requires ERC-20 approval before swapping.
  final bool needsApproval;

  /// Whether exact-amount approval (vs. unlimited) is selected.
  final bool exactApprove;

  final String tokenInSymbol;

  /// Called when the user toggles between exact / unlimited approval.
  final ValueChanged<bool> onExactApproveChanged;

  // ── Derived values ──────────────────────────────────────────────────────

  Color _impactColor(BuildContext context) => switch (quote.priceImpactNum) {
    >= 3.0 => AppColorTokens.of(context).danger,
    >= 1.0 => AppColorTokens.of(context).warning,
    _ => AppColorTokens.of(context).textPrimary,
  };

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final impactColor = _impactColor(context);

    return Container(
      padding: EdgeInsets.all(AppSpacing.space6),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgSurface,
        borderRadius: AppRadius.brMd,
      ),
      child: Column(
        children: [
          _rowWidget(
            context,
            s.g_key_dex_best_route,
            quote.source,
            trailing: secsLeft > 0 ? _countdownText(context, s) : null,
          ),
          _rowWidget(
            context,
            s.g_key_dex_price_impact,
            quote.priceImpact,
            valueColor: impactColor,
          ),
          _rowWidget(context, s.g_key_dex_gas_estimate, quote.gasEstimate),
          _rowWidget(
            context,
            s.g_key_dex_min_received,
            '${quote.minAmountOut} ${quote.tokenOutSymbol}',
          ),
          if (quote.priceImpactNum >= 3.0) ...[
            SizedBox(height: AppSpacing.space2),
            _highImpactBanner(context, s),
          ],
          if (needsApproval) ...[
            SizedBox(height: AppSpacing.space2),
            _approvalBanner(context, s),
          ],
        ],
      ),
    );
  }

  // ── Sub-widgets ─────────────────────────────────────────────────────────

  Widget _countdownText(BuildContext context, S s) {
    return Text(
      s.g_key_dex_quote_expires(secsLeft.toString()),
      style: AppTypography.caption.copyWith(
        color: secsLeft <= 10
            ? AppColorTokens.of(context).danger
            : AppThemeUtils.getColorByKey(context, AppThemeKeys.ff888888.name),
      ),
    );
  }

  Widget _highImpactBanner(BuildContext context, S s) {
    final dangerColor = AppColorTokens.of(context).danger;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space2,
      ),
      decoration: BoxDecoration(
        color: dangerColor.withAlpha(20),
        borderRadius: AppRadius.brSm,
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: dangerColor,
            size: ScreenUtil().setWidth(28),
          ),
          SizedBox(width: AppSpacing.space2),
          Expanded(
            child: Text(
              s.g_key_dex_price_impact_high(quote.priceImpact),
              style: AppTypography.caption.copyWith(color: dangerColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _approvalBanner(BuildContext context, S s) {
    final warningColor = AppColorTokens.of(context).warning;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space2,
      ),
      decoration: BoxDecoration(
        color: warningColor.withAlpha(20),
        borderRadius: AppRadius.brSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lock_outline,
                color: warningColor,
                size: ScreenUtil().setWidth(28),
              ),
              SizedBox(width: AppSpacing.space2),
              Expanded(
                child: Text(
                  s.g_key_dex_approve_required(tokenInSymbol),
                  style: AppTypography.caption.copyWith(color: warningColor),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.space2),
          Row(
            children: [
              _approveChip(
                context,
                label: s.g_key_dex_approve_unlimited,
                selected: !exactApprove,
                onTap: () => onExactApproveChanged(false),
              ),
              SizedBox(width: AppSpacing.space2),
              _approveChip(
                context,
                label: s.g_key_dex_approve_exact,
                selected: exactApprove,
                onTap: () => onExactApproveChanged(true),
              ),
            ],
          ),
          if (!exactApprove) ...[
            SizedBox(height: AppSpacing.space2),
            Text(
              s.g_key_dex_approve_unlimited_info,
              style: AppTypography.captionSm.copyWith(
                color: warningColor.withValues(alpha: 0.75),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _approveChip(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final mainText = AppColorTokens.of(context).textPrimary;
    final warningColor = AppColorTokens.of(context).warning;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space2,
        ),
        decoration: BoxDecoration(
          color: selected
              ? warningColor.withValues(alpha: 0.2)
              : Colors.transparent,
          border: Border.all(
            color: selected ? warningColor : mainText.withValues(alpha: 0.25),
            width: 1.0,
          ),
          borderRadius: AppRadius.brMd,
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: selected ? warningColor : mainText,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _rowWidget(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
    Widget? trailing,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.space2),
      child: Row(
        children: [
          Text(
            label,
            style: AppTypography.bodySm.copyWith(
              color: AppColorTokens.of(context).textSubtitle,
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: AppSpacing.space2),
            trailing,
          ],
          const Spacer(),
          Text(
            value,
            style: AppTypography.bodySm.copyWith(
              color: valueColor ?? AppColorTokens.of(context).textPrimary,
              fontWeight: valueColor != null
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
