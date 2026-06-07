import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/features/wallet/models/portfolio_trade.dart';
import 'package:n42_wallet/features/wallet/services/coin_price_alert_service.dart';
import 'package:n42_wallet/features/widgets/image_network.dart';
import 'package:n42_wallet/features/wallet/widgets/about_show_dialog.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

import 'market_coin_info_helpers.dart';
import 'market_coin_info_widgets.dart';

/// Shorthand for theme color lookup used across all section builders.
Color _tc(BuildContext context, String key) =>
    AppThemeUtils.getColorByKey(context, key);

Widget buildCoinInfoHeader(
  BuildContext context, {
  required Map<String, dynamic> coin,
  required CoinPriceAlertConfig? alertConfig,
  required VoidCallback onBack,
  required VoidCallback onAlertTap,
}) {
  final alertActive = alertConfig != null && alertConfig.enabled;
  final textColor = _tc(context, AppThemeKeys.mainTextColor.name);
  final iconSize = ScreenUtil().setWidth(44);
  final touchSize = ScreenUtil().setWidth(80);

  return SizedBox(
    height: ScreenUtil().setWidth(100),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.space8),
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
            child: SizedBox(
              width: touchSize,
              height: touchSize,
              child: Icon(
                Icons.arrow_back_ios,
                color: textColor,
                size: iconSize,
              ),
            ),
          ),
          SizedBox(
            width: touchSize,
            height: touchSize,
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.space2),
              child: ImageNetWork(
                imageUrl: coin['image']?.toString() ?? '',
                placeholder: 'assets/img/list.default.png',
              ),
            ),
          ),
          Text(
            (coin['coin'] ?? '').toString().toUpperCase(),
            style: AppTypography.title.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: AppSpacing.space2),
          Expanded(
            child: Text(
              '(${coin['name'] ?? ''})',
              style: AppTypography.captionSm.copyWith(
                color: _tc(context, AppThemeKeys.itemSubtitleTextColor.name),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          InkWell(
            onTap: onAlertTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.space4),
              child: Icon(
                alertActive
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_none_rounded,
                color: alertActive
                    ? _tc(context, AppThemeKeys.mainBlueColor.name)
                    : textColor,
                size: iconSize,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ─── price section ─────────────────────────────────────────────────────────

Widget buildCoinPriceSection(
  BuildContext context, {
  required Map<String, dynamic> coin,
  required double priceChange24h,
  required Regular regular,
}) {
  final isUp = priceChange24h >= 0;
  final price = toDouble(coin['price']);
  final pctKey = isUp
      ? AppThemeKeys.rightTextColor.name
      : AppThemeKeys.errorTextColor.name;
  final pctColor = _tc(context, pctKey);

  return Padding(
    padding: EdgeInsets.symmetric(horizontal: AppSpacing.space8),
    child: Row(
      children: [
        Expanded(
          child: Text(
            '\$${fmtPrice(price)}',
            style: AppTypography.displayLg.copyWith(
              fontWeight: FontWeight.w600,
              color: _tc(context, AppThemeKeys.mainTextColor.name),
            ),
            maxLines: 2,
          ),
        ),
        SizedBox(width: AppSpacing.space4),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space2,
          ),
          decoration: BoxDecoration(
            color: pctColor.withValues(alpha: 0.12),
            borderRadius: AppRadius.brSm,
          ),
          child: Text(
            '${isUp ? '+' : ''}${regular.formartNum(priceChange24h, 2, isCrop: true)}%',
            style: AppTypography.bodySm.copyWith(
              fontWeight: FontWeight.w600,
              color: pctColor,
            ),
          ),
        ),
      ],
    ),
  );
}

// ─── portfolio P&L card ────────────────────────────────────────────────────

Widget buildPnlCard(
  BuildContext context, {
  required List<PortfolioTrade> trades,
  required Map<String, dynamic> coin,
  required VoidCallback onAddTrade,
}) {
  final textColor = _tc(context, AppThemeKeys.mainTextColor.name);
  final subColor = textColor.withAlpha(153);
  final cardBg = _tc(context, AppThemeKeys.itemBgColor.name);
  final accentColor = _tc(context, AppThemeKeys.mainBlueColor.name);
  final s = S.of(context);

  final summary = CoinPnlSummary(trades);
  final currentPrice = toDouble(coin['price']);
  final pnlUsd = summary.pnlUsd(currentPrice);
  final pnlPct = summary.pnlPct(currentPrice);
  final isProfit = pnlUsd >= 0;
  final pnlColor = isProfit ? const Color(0xFF22C55E) : const Color(0xFFEF4444);

  return Padding(
    padding: EdgeInsets.symmetric(
      horizontal: AppSpacing.space8,
      vertical: AppSpacing.space2,
    ),
    child: Container(
      padding: EdgeInsets.all(AppSpacing.space6),
      decoration: BoxDecoration(color: cardBg, borderRadius: AppRadius.brMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                s.g_pnl_cost_basis,
                style: AppTypography.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onAddTrade,
                child: Icon(
                  Icons.add_circle_outline,
                  color: accentColor,
                  size: ScreenUtil().setSp(30),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.space4),
          Row(
            children: [
              pnlStat(
                s.g_pnl_avg_cost,
                '\$${fmtPrice(summary.avgCost)}',
                textColor,
                subColor,
              ),
              SizedBox(width: AppSpacing.space4),
              pnlStat(
                s.g_pnl_quantity,
                fmtQty(summary.totalQty),
                textColor,
                subColor,
              ),
              SizedBox(width: AppSpacing.space4),
              pnlStat(
                s.g_pnl_unrealized,
                '${isProfit ? '+' : ''}\$${fmtPrice(pnlUsd.abs())}  '
                '${isProfit ? '+' : ''}${pnlPct.toStringAsFixed(2)}%',
                pnlColor,
                subColor,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

// ─── period selector ───────────────────────────────────────────────────────

Widget buildPeriodSelector(
  BuildContext context, {
  required int selectedIndex,
  required ValueChanged<int> onChanged,
}) {
  return Padding(
    padding: EdgeInsets.symmetric(
      horizontal: AppSpacing.space8,
      vertical: AppSpacing.space4,
    ),
    child: Row(
      children: List.generate(periodLabels.length, (i) {
        final selected = selectedIndex == i;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(i),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: AppSpacing.space2),
              padding: EdgeInsets.symmetric(vertical: AppSpacing.space4),
              decoration: BoxDecoration(
                color: _tc(
                  context,
                  selected
                      ? AppThemeKeys.mainButtonBgColor.name
                      : AppThemeKeys.itemBgColor.name,
                ),
                borderRadius: AppRadius.brSm,
              ),
              child: Text(
                periodLabels[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected
                      ? Colors.white
                      : _tc(context, AppThemeKeys.itemSubtitleTextColor.name),
                ),
              ),
            ),
          ),
        );
      }),
    ),
  );
}

// ─── market stats card ─────────────────────────────────────────────────────

Widget buildMarketStatsCard(
  BuildContext context, {
  required Map<String, dynamic> coin,
  required double high24h,
  required double low24h,
  required double fdv,
  required int rank,
  required Regular regular,
}) {
  final symbol = (coin['coin'] ?? '').toString().toUpperCase();
  final marketCap = toDouble(coin['market_cap']);
  final volume24h = toDouble(coin['volume_24h']);
  final totalSup = toDouble(coin['total_supply']);
  final circSup = toDouble(coin['circulating_supply']);

  return coinInfoCard(
    context,
    child: Column(
      children: withDividers(context, [
        coinInfoStatRow(
          context,
          S.of(context).g_key_m_2,
          '\$${regular.getMoneyAbbreviation(marketCap)}',
        ),
        coinInfoStatRow(
          context,
          S.of(context).g_key_m_3,
          '\$${regular.getMoneyAbbreviation(volume24h)}',
        ),
        coinInfoStatRow(
          context,
          S.of(context).g_key_m_4,
          '${regular.getMoneyAbbreviation(totalSup)} $symbol',
        ),
        coinInfoStatRow(
          context,
          S.of(context).g_key_m_5,
          '${regular.getMoneyAbbreviation(circSup)} $symbol',
        ),
        if (high24h > 0)
          coinInfoStatRow(
            context,
            S.of(context).g_market_high_24h,
            '\$${regular.formartNum(high24h, 6, isCrop: true)}',
          ),
        if (low24h > 0)
          coinInfoStatRow(
            context,
            S.of(context).g_market_low_24h,
            '\$${regular.formartNum(low24h, 6, isCrop: true)}',
          ),
        if (fdv > 0)
          coinInfoStatRow(
            context,
            S.of(context).g_market_fdv,
            '\$${regular.getMoneyAbbreviation(fdv)}',
          ),
        if (rank > 0)
          coinInfoStatRow(context, S.of(context).g_market_rank, '#$rank'),
      ]),
    ),
  );
}

// ─── depth / liquidity card ────────────────────────────────────────────────

Widget buildDepthDataCard(
  BuildContext context, {
  required double ath,
  required double atl,
  required double liquidityScore,
  required double pct7d,
  required double pct30d,
  required Regular regular,
}) {
  final s = S.of(context);
  final rows = <Widget>[
    if (ath > 0)
      coinInfoStatRow(
        context,
        s.g_market_ath,
        '\$${regular.formartNum(ath, 6, isCrop: true)}',
      ),
    if (atl > 0)
      coinInfoStatRow(
        context,
        s.g_market_atl,
        '\$${regular.formartNum(atl, 6, isCrop: true)}',
      ),
    if (liquidityScore > 0)
      coinInfoStatRow(
        context,
        s.g_market_liquidity_score,
        liquidityScore.toStringAsFixed(1),
      ),
    if (pct7d != 0)
      coinInfoStatRowColored(context, s.g_market_7d_change, pct7d),
    if (pct30d != 0)
      coinInfoStatRowColored(context, s.g_market_30d_change, pct30d),
  ];

  if (rows.isEmpty) return const SizedBox.shrink();

  return coinInfoCard(
    context,
    title: s.g_market_depth,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: withDividers(context, rows),
    ),
  );
}

// ─── about section ─────────────────────────────────────────────────────────

Widget buildAboutSection(
  BuildContext context, {
  required Map<String, dynamic>? coinInfo,
  required String lang,
}) {
  final descMap = coinInfo?['description'];
  final desc = (descMap is Map ? descMap[lang]?.toString() : null) ?? '';
  if (desc.isEmpty) return const SizedBox.shrink();

  final s = S.of(context);
  final hPad = ScreenUtil().setWidth(30);
  final radius = ScreenUtil().setWidth(16);

  return Container(
    margin: EdgeInsets.only(
      top: ScreenUtil().setWidth(24),
      left: hPad,
      right: hPad,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        coinInfoSectionTitle(context, s.g_key_m_6),
        SizedBox(height: AppSpacing.space4),
        Container(
          padding: EdgeInsets.only(
            left: hPad,
            right: hPad,
            top: ScreenUtil().setWidth(24),
          ),
          decoration: BoxDecoration(
            color: _tc(context, AppThemeKeys.itemBgColor.name),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Column(
            children: [
              Text(
                desc,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  color: _tc(context, AppThemeKeys.itemSubtitleTextColor.name),
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 6,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () => aboutShowDialog(context, desc, s.g_key_m_6),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: ScreenUtil().setWidth(15),
                      horizontal: hPad,
                    ),
                    margin: EdgeInsets.symmetric(vertical: AppSpacing.space2),
                    child: Text(
                      s.g_key_m_7,
                      style: TextStyle(
                        color: _tc(
                          context,
                          AppThemeKeys.mainButtonBgColor.name,
                        ),
                        fontSize: ScreenUtil().setSp(28),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
