import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet/models/dex/dex_quote_model.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

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

  Color _impactColor(BuildContext context) {
    final num = quote.priceImpactNum;
    if (num >= 3.0) return const Color(0xFFF44336);
    if (num >= 1.0) return const Color(0xFFFF9800);
    return AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final impactColor = _impactColor(context);

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
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
          _row(context, s.g_key_dex_gas_estimate, quote.gasEstimate),
          _row(context, s.g_key_dex_min_received,
              '${quote.minAmountOut} ${quote.tokenOutSymbol}'),
          if (quote.priceImpactNum >= 3.0) ...[
            SizedBox(height: ScreenUtil().setWidth(8)),
            _highImpactBanner(context, s),
          ],
          if (needsApproval) ...[
            SizedBox(height: ScreenUtil().setWidth(8)),
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
      style: TextStyle(
        color: secsLeft <= 10
            ? const Color(0xFFF44336)
            : AppThemeUtils.getColorByKey(
                context, AppThemeKeys.ff888888.name),
        fontSize: ScreenUtil().setSp(22),
      ),
    );
  }

  Widget _highImpactBanner(BuildContext context, S s) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(12),
        vertical: ScreenUtil().setWidth(8),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF44336).withAlpha(20),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: const Color(0xFFF44336),
              size: ScreenUtil().setWidth(28)),
          SizedBox(width: ScreenUtil().setWidth(8)),
          Expanded(
            child: Text(
              s.g_key_dex_price_impact_high(quote.priceImpact),
              style: TextStyle(
                color: const Color(0xFFF44336),
                fontSize: ScreenUtil().setSp(22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _approvalBanner(BuildContext context, S s) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(12),
        vertical: ScreenUtil().setWidth(10),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9800).withAlpha(20),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_outline,
                  color: const Color(0xFFFF9800),
                  size: ScreenUtil().setWidth(28)),
              SizedBox(width: ScreenUtil().setWidth(8)),
              Expanded(
                child: Text(
                  s.g_key_dex_approve_required(tokenInSymbol),
                  style: TextStyle(
                    color: const Color(0xFFFF9800),
                    fontSize: ScreenUtil().setSp(22),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(10)),
          Row(
            children: [
              _approveChip(
                context,
                label: s.g_key_dex_approve_unlimited,
                selected: !exactApprove,
                onTap: () => onExactApproveChanged(false),
              ),
              SizedBox(width: ScreenUtil().setWidth(8)),
              _approveChip(
                context,
                label: s.g_key_dex_approve_exact,
                selected: exactApprove,
                onTap: () => onExactApproveChanged(true),
              ),
            ],
          ),
          if (!exactApprove) ...[
            SizedBox(height: ScreenUtil().setWidth(8)),
            Text(
              s.g_key_dex_approve_unlimited_info,
              style: TextStyle(
                color: const Color(0xFFFF9800).withValues(alpha: 0.75),
                fontSize: ScreenUtil().setSp(20),
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
    final mainText =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(16),
          vertical: ScreenUtil().setWidth(6),
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFF9800).withValues(alpha: 0.2)
              : Colors.transparent,
          border: Border.all(
            color: selected
                ? const Color(0xFFFF9800)
                : mainText.withValues(alpha: 0.25),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFFFF9800) : mainText,
            fontSize: ScreenUtil().setSp(22),
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // ── Row helpers ─────────────────────────────────────────────────────────

  Widget _rowWidget(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
    Widget? trailing,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10)),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
              fontSize: ScreenUtil().setSp(26),
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: ScreenUtil().setWidth(8)),
            trailing,
          ],
          const Expanded(child: SizedBox()),
          Text(
            value,
            style: TextStyle(
              color: valueColor ??
                  AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(26),
              fontWeight:
                  valueColor != null ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value,
          {Color? valueColor}) =>
      _rowWidget(context, label, value, valueColor: valueColor);
}
