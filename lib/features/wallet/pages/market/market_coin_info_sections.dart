import 'package:flutter/material.dart';
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

// ─── header ────────────────────────────────────────────────────────────────

Widget buildCoinInfoHeader(
  BuildContext context, {
  required Map<String, dynamic> coin,
  required CoinPriceAlertConfig? alertConfig,
  required VoidCallback onBack,
  required VoidCallback onAlertTap,
}) {
  final alertActive = alertConfig != null && alertConfig.enabled;
  return SizedBox(
    height: ScreenUtil().setWidth(100),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
            child: SizedBox(
              width: ScreenUtil().setWidth(80),
              height: ScreenUtil().setWidth(80),
              child: Icon(
                Icons.arrow_back_ios,
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                size: ScreenUtil().setWidth(44),
              ),
            ),
          ),
          SizedBox(
            width: ScreenUtil().setWidth(80),
            height: ScreenUtil().setWidth(80),
            child: Padding(
              padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
              child: ImageNetWork(
                imageUrl: coin['image']?.toString() ?? '',
                placeholder: 'assets/img/list.default.png',
              ),
            ),
          ),
          Text(
            (coin['coin'] ?? '').toString().toUpperCase(),
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(36),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(8)),
          Expanded(
            child: Text(
              '(${coin['name'] ?? ''})',
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemSubtitleTextColor.name),
                fontSize: ScreenUtil().setSp(20),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Price alert bell
          InkWell(
            onTap: onAlertTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: EdgeInsets.all(ScreenUtil().setWidth(12)),
              child: Icon(
                alertActive
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_none_rounded,
                color: alertActive
                    ? AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainBlueColor.name)
                    : AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
                size: ScreenUtil().setWidth(44),
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
  final isUp   = priceChange24h >= 0;
  final price  = toDouble(coin['price']);
  final pctKey = isUp
      ? AppThemeKeys.rightTextColor.name
      : AppThemeKeys.errorTextColor.name;

  return Padding(
    padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
    child: Row(
      children: [
        Expanded(
          child: Text(
            '\$${fmtPrice(price)}',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(44),
              fontWeight: FontWeight.w700,
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
            ),
            maxLines: 2,
          ),
        ),
        SizedBox(width: ScreenUtil().setWidth(16)),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(16),
            vertical: ScreenUtil().setWidth(6),
          ),
          decoration: BoxDecoration(
            color: AppThemeUtils.getColorByKey(context, pctKey)
                .withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
          ),
          child: Text(
            '${isUp ? '+' : ''}${regular.formartNum(priceChange24h, 2, isCrop: true)}%',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              fontWeight: FontWeight.w600,
              color: AppThemeUtils.getColorByKey(context, pctKey),
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
  final textColor   = AppThemeUtils.getColorByKey(
      context, AppThemeKeys.mainTextColor.name);
  final subColor    = textColor.withAlpha(153);
  final cardBg      = AppThemeUtils.getColorByKey(
      context, AppThemeKeys.itemBgColor.name);
  final accentColor = AppThemeUtils.getColorByKey(
      context, AppThemeKeys.mainBlueColor.name);
  final s = S.of(context);

  final summary      = CoinPnlSummary(trades);
  final currentPrice = toDouble(coin['price']);
  final pnlUsd       = summary.pnlUsd(currentPrice);
  final pnlPct       = summary.pnlPct(currentPrice);
  final isProfit     = pnlUsd >= 0;
  final pnlColor     = isProfit
      ? const Color(0xFF22C55E)
      : const Color(0xFFEF4444);

  return Padding(
    padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30),
        vertical: ScreenUtil().setWidth(8)),
    child: Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                s.g_pnl_cost_basis,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onAddTrade,
                child: Icon(Icons.add_circle_outline,
                    color: accentColor, size: ScreenUtil().setSp(30)),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          Row(
            children: [
              pnlStat(s.g_pnl_avg_cost,
                  '\$${fmtPrice(summary.avgCost)}', textColor, subColor),
              SizedBox(width: ScreenUtil().setWidth(20)),
              pnlStat(s.g_pnl_quantity,
                  fmtQty(summary.totalQty), textColor, subColor),
              SizedBox(width: ScreenUtil().setWidth(20)),
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
      horizontal: ScreenUtil().setWidth(30),
      vertical: ScreenUtil().setWidth(16),
    ),
    child: Row(
      children: List.generate(periodLabels.length, (i) {
        final selected = selectedIndex == i;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(i),
            child: Container(
              margin: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(4)),
              padding: EdgeInsets.symmetric(
                  vertical: ScreenUtil().setWidth(12)),
              decoration: BoxDecoration(
                color: AppThemeUtils.getColorByKey(
                  context,
                  selected
                      ? AppThemeKeys.mainButtonBgColor.name
                      : AppThemeKeys.itemBgColor.name,
                ),
                borderRadius:
                    BorderRadius.circular(ScreenUtil().setWidth(8)),
              ),
              child: Text(
                periodLabels[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected
                      ? Colors.white
                      : AppThemeUtils.getColorByKey(context,
                          AppThemeKeys.itemSubtitleTextColor.name),
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
  final symbol    = (coin['coin'] ?? '').toString().toUpperCase();
  final marketCap = toDouble(coin['market_cap']);
  final volume24h = toDouble(coin['volume_24h']);
  final totalSup  = toDouble(coin['total_supply']);
  final circSup   = toDouble(coin['circulating_supply']);

  return coinInfoCard(
    context,
    child: Column(
      children: withDividers(context, [
        coinInfoStatRow(context, S.of(context).g_key_m_2,
            '\$${regular.getMoneyAbbreviation(marketCap)}'),
        coinInfoStatRow(context, S.of(context).g_key_m_3,
            '\$${regular.getMoneyAbbreviation(volume24h)}'),
        coinInfoStatRow(context, S.of(context).g_key_m_4,
            '${regular.getMoneyAbbreviation(totalSup)} $symbol'),
        coinInfoStatRow(context, S.of(context).g_key_m_5,
            '${regular.getMoneyAbbreviation(circSup)} $symbol'),
        if (high24h > 0)
          coinInfoStatRow(context, 'High 24H', // TODO: i18n
              '\$${regular.formartNum(high24h, 6, isCrop: true)}'),
        if (low24h > 0)
          coinInfoStatRow(context, 'Low 24H', // TODO: i18n
              '\$${regular.formartNum(low24h, 6, isCrop: true)}'),
        if (fdv > 0)
          coinInfoStatRow(context, 'FDV', // TODO: i18n
              '\$${regular.getMoneyAbbreviation(fdv)}'),
        if (rank > 0)
          coinInfoStatRow(context, 'Rank', '#$rank'), // TODO: i18n
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
  final rows = <Widget>[
    if (ath > 0)
      coinInfoStatRow(context, 'ATH', // TODO: i18n
          '\$${regular.formartNum(ath, 6, isCrop: true)}'),
    if (atl > 0)
      coinInfoStatRow(context, 'ATL', // TODO: i18n
          '\$${regular.formartNum(atl, 6, isCrop: true)}'),
    if (liquidityScore > 0)
      coinInfoStatRow(context, 'Liquidity Score', // TODO: i18n
          liquidityScore.toStringAsFixed(1)),
    if (pct7d != 0)
      coinInfoStatRowColored(context, '7D Change', pct7d), // TODO: i18n
    if (pct30d != 0)
      coinInfoStatRowColored(context, '30D Change', pct30d), // TODO: i18n
  ];

  if (rows.isEmpty) return const SizedBox.shrink();

  return coinInfoCard(
    context,
    title: 'Market Depth', // TODO: i18n
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
  final desc    = (descMap is Map ? descMap[lang]?.toString() : null) ?? '';
  if (desc.isEmpty) return const SizedBox.shrink();

  return Container(
    margin: EdgeInsets.only(
      top: ScreenUtil().setWidth(24),
      left: ScreenUtil().setWidth(30),
      right: ScreenUtil().setWidth(30),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        coinInfoSectionTitle(context, S.of(context).g_key_m_6),
        SizedBox(height: ScreenUtil().setWidth(16)),
        Container(
          padding: EdgeInsets.only(
            left: ScreenUtil().setWidth(30),
            right: ScreenUtil().setWidth(30),
            top: ScreenUtil().setWidth(24),
          ),
          decoration: BoxDecoration(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemBgColor.name),
            borderRadius:
                BorderRadius.circular(ScreenUtil().setWidth(16)),
          ),
          child: Column(
            children: [
              Text(
                desc,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemSubtitleTextColor.name),
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 6,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () => aboutShowDialog(
                      context, desc, S.of(context).g_key_m_6),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: ScreenUtil().setWidth(15),
                      horizontal: ScreenUtil().setWidth(30),
                    ),
                    margin: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setWidth(10)),
                    child: Text(
                      S.of(context).g_key_m_7,
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(context,
                            AppThemeKeys.mainButtonBgColor.name),
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
