// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet/pages/portfolio/portfolio_holdings.dart';
import 'package:n42_wallet/features/wallet/pages/portfolio/portfolio_models.dart';
import 'package:n42_wallet/features/wallet/pages/portfolio/portfolio_movers.dart';
import 'package:n42_wallet/features/wallet/pages/portfolio/portfolio_record_utils.dart';
import 'package:n42_wallet/features/wallet/pages/portfolio/portfolio_widgets.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

// ─── Entry point ─────────────────────────────────────────────────────────────

class PortfolioPage extends ConsumerStatefulWidget {
  const PortfolioPage({super.key});

  @override
  ConsumerState<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends ConsumerState<PortfolioPage> {
  int _touchedIndex = -1;

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final waValue = ref.watch(wapBridgeProvider);
    final bgColor = AppColorTokens.of(context).bgBase;
    final itemBg = AppColorTokens.of(context).bgSurface;
    final textColor = AppColorTokens.of(context).textPrimary;
    final accentColor = AppColorTokens.of(context).brand;

    final records = sortPortfolioRecordsByValue(
      waValue.coinList
          .whereType<CoinModel>()
          .map(portfolioRecordFromCoinModel)
          .whereType<CoinRecord>(),
    );
    final valuedRecords = records.where((record) => record.value > 0).toList();

    final totalValue = valuedRecords.fold(0.0, (s, r) => s + r.value);
    final total24hPnl = valuedRecords.fold(
      0.0,
      (s, r) => s + calcPnl(r.value, r.percentage),
    );
    final previousTotal = totalValue - total24hPnl;
    final total24hPct = previousTotal > 0
        ? total24hPnl / previousTotal * 100
        : 0.0;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: itemBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: textColor,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          S.of(context).g_portfolio_title,
          style: TextStyle(
            color: textColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: records.isEmpty
          ? _buildEmpty(context, textColor)
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(
                    context,
                    totalValue,
                    total24hPnl,
                    total24hPct,
                    itemBg,
                    textColor,
                    accentColor,
                  ),
                  SizedBox(height: 16.h),
                  _buildPieSection(
                    context,
                    valuedRecords,
                    totalValue,
                    itemBg,
                    textColor,
                    accentColor,
                  ),
                  SizedBox(height: 16.h),
                  _buildMoversSection(
                    context,
                    valuedRecords,
                    itemBg,
                    textColor,
                  ),
                  SizedBox(height: 16.h),
                  _buildHoldingsList(
                    context,
                    records,
                    totalValue,
                    itemBg,
                    textColor,
                    accentColor,
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
    );
  }

  Widget _buildEmpty(BuildContext context, Color textColor) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.donut_large_outlined,
            size: 64.sp,
            color: textColor.withAlpha(80),
          ),
          SizedBox(height: 12.h),
          Text(
            S.of(context).g_portfolio_no_assets,
            style: TextStyle(fontSize: 15.sp, color: textColor.withAlpha(128)),
          ),
        ],
      ),
    );
  }

  // ─── Summary cards ────────────────────────────────────────────────────────

  Widget _buildSummaryCards(
    BuildContext context,
    double totalValue,
    double pnl24h,
    double pnlPct,
    Color itemBg,
    Color textColor,
    Color accentColor,
  ) {
    return Row(
      children: [
        Expanded(
          child: SummaryCard(
            label: S.of(context).g_portfolio_total,
            value: fmtUsd(totalValue),
            subValue: null,
            valueColor: accentColor,
            itemBg: itemBg,
            textColor: textColor,
            icon: Icons.account_balance_wallet_outlined,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: SummaryCard(
            label: S.of(context).g_portfolio_24h,
            value: fmtPnl(pnl24h),
            subValue: '${pnlPct >= 0 ? '+' : ''}${pnlPct.toStringAsFixed(2)}%',
            valueColor: pnl24h >= 0
                ? const Color(0xFF22C55E)
                : const Color(0xFFEF4444),
            itemBg: itemBg,
            textColor: textColor,
            icon: pnl24h >= 0
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
          ),
        ),
      ],
    );
  }

  // ─── Pie chart section ────────────────────────────────────────────────────

  Widget _buildPieSection(
    BuildContext context,
    List<CoinRecord> records,
    double totalValue,
    Color itemBg,
    Color textColor,
    Color accentColor,
  ) {
    if (records.isEmpty) {
      return _sectionContainer(
        itemBg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(S.of(context).g_portfolio_allocation, textColor),
            SizedBox(height: 16.h),
            Text(
              S.of(context).g_portfolio_no_assets,
              style: TextStyle(
                fontSize: 13.sp,
                color: textColor.withAlpha(160),
              ),
            ),
          ],
        ),
      );
    }

    const maxSlices = 8;
    final sliceRecords = records.take(maxSlices).toList();
    final othersValue = records.length > maxSlices
        ? records.skip(maxSlices).fold(0.0, (sum, r) => sum + r.value)
        : 0.0;

    PieChartSectionData buildSlice(int index, double pct, Color color) {
      final isTouched = index == _touchedIndex;
      return PieChartSectionData(
        value: pct,
        color: color,
        radius: isTouched ? 70.r : 56.r,
        title: isTouched ? '${pct.toStringAsFixed(1)}%' : '',
        titleStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          shadows: const [Shadow(blurRadius: 4, color: Colors.black26)],
        ),
        titlePositionPercentageOffset: 0.6,
      );
    }

    final sections = <PieChartSectionData>[
      for (var i = 0; i < sliceRecords.length; i++)
        buildSlice(
          i,
          totalValue > 0 ? sliceRecords[i].value / totalValue * 100 : 0.0,
          portfolioSliceColors[i % portfolioSliceColors.length],
        ),
      if (othersValue > 0)
        buildSlice(
          sliceRecords.length,
          totalValue > 0 ? othersValue / totalValue * 100 : 0.0,
          portfolioSliceColors.last,
        ),
    ];

    // What's currently highlighted
    CoinRecord? highlighted;
    if (_touchedIndex >= 0 && _touchedIndex < sliceRecords.length) {
      highlighted = sliceRecords[_touchedIndex];
    }

    return _sectionContainer(
      itemBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(S.of(context).g_portfolio_allocation, textColor),
          SizedBox(height: 16.h),
          SizedBox(
            height: 220.h,
            child: Row(
              children: [
                // Donut chart
                Expanded(
                  flex: 5,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sections: sections,
                          centerSpaceRadius: 52.r,
                          sectionsSpace: 2,
                          pieTouchData: PieTouchData(
                            touchCallback:
                                (
                                  FlTouchEvent event,
                                  PieTouchResponse? response,
                                ) {
                                  setState(() {
                                    if (!event.isInterestedForInteractions ||
                                        response == null ||
                                        response.touchedSection == null) {
                                      _touchedIndex = -1;
                                    } else {
                                      _touchedIndex = response
                                          .touchedSection!
                                          .touchedSectionIndex;
                                    }
                                  });
                                },
                          ),
                        ),
                      ),
                      // Center label
                      _buildCenterLabel(
                        context,
                        highlighted: highlighted,
                        totalValue: totalValue,
                        textColor: textColor,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                // Legend
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < sliceRecords.length; i++)
                        LegendItem(
                          color:
                              portfolioSliceColors[i %
                                  portfolioSliceColors.length],
                          symbol: sliceRecords[i].symbol.toUpperCase(),
                          pct: totalValue > 0
                              ? sliceRecords[i].value / totalValue * 100
                              : 0,
                          isActive: i == _touchedIndex,
                          textColor: textColor,
                        ),
                      if (othersValue > 0)
                        LegendItem(
                          color: portfolioSliceColors.last,
                          symbol: S.of(context).g_portfolio_others,
                          pct: totalValue > 0
                              ? othersValue / totalValue * 100
                              : 0,
                          isActive: sliceRecords.length == _touchedIndex,
                          textColor: textColor,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Center label for the donut chart – shows the highlighted coin or the total.
  Widget _buildCenterLabel(
    BuildContext context, {
    required CoinRecord? highlighted,
    required double totalValue,
    required Color textColor,
  }) {
    if (highlighted != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            highlighted.symbol.toUpperCase(),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          Text(
            fmtUsd(highlighted.value),
            style: TextStyle(fontSize: 11.sp, color: textColor.withAlpha(178)),
          ),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          S.of(context).g_portfolio_pie_total,
          style: TextStyle(fontSize: 12.sp, color: textColor.withAlpha(153)),
        ),
        Text(
          fmtUsd(totalValue),
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }

  // ─── Shared section helpers ─────────────────────────────────────────────

  /// Wraps [child] in a rounded container with the standard section decoration.
  Widget _sectionContainer(Color itemBg, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: itemBg,
        borderRadius: BorderRadius.circular(16.r),
      ),
      padding: EdgeInsets.all(16.w),
      child: child,
    );
  }

  /// Standard section heading used by pie, movers, and holdings sections.
  Widget _sectionTitle(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }

  // ─── 24h Movers ────────────────────────────────────────────────────────────

  Widget _buildMoversSection(
    BuildContext context,
    List<CoinRecord> records,
    Color itemBg,
    Color textColor,
  ) {
    if (records.isEmpty) return const SizedBox();

    // Sort by absolute 24h $ gain/loss
    final sorted = List<CoinRecord>.from(records)
      ..sort((a, b) {
        final pa = calcPnl(a.value, a.percentage);
        final pb = calcPnl(b.value, b.percentage);
        return pb.compareTo(pa); // descending by gain
      });

    final gainers = sorted.where((r) => r.percentage >= 0).take(3).toList();
    // 从 sorted（gain 降序）中取亏损项，reversed 使亏损最大的在前，
    // take(3) 取前三，再 reversed 恢复为亏损从小到大。
    final losers = sorted.reversed
        .where((r) => r.percentage < 0)
        .take(3)
        .toList()
        .reversed
        .toList();

    if (gainers.isEmpty && losers.isEmpty) return const SizedBox();

    return _sectionContainer(
      itemBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(S.of(context).g_portfolio_movers, textColor),
          SizedBox(height: 12.h),
          if (gainers.isNotEmpty)
            MoverRow(
              label: S.of(context).g_portfolio_gainers,
              records: gainers,
              pnlFn: calcPnl,
              fmtUsd: fmtUsd,
              textColor: textColor,
            ),
          if (losers.isNotEmpty) ...[
            SizedBox(height: 10.h),
            MoverRow(
              label: S.of(context).g_portfolio_losers,
              records: losers,
              pnlFn: calcPnl,
              fmtUsd: fmtUsd,
              textColor: textColor,
            ),
          ],
        ],
      ),
    );
  }

  // ─── Holdings list ────────────────────────────────────────────────────────

  Widget _buildHoldingsList(
    BuildContext context,
    List<CoinRecord> records,
    double totalValue,
    Color itemBg,
    Color textColor,
    Color accentColor,
  ) {
    return _sectionContainer(
      itemBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(S.of(context).g_portfolio_all_holdings, textColor),
          SizedBox(height: 8.h),
          for (var i = 0; i < records.length; i++) ...[
            HoldingRow(
              record: records[i],
              rank: i + 1,
              totalValue: totalValue,
              pnlFn: calcPnl,
              fmtUsd: fmtUsd,
              accentColor: accentColor,
              textColor: textColor,
              sliceColor:
                  portfolioSliceColors[i.clamp(
                    0,
                    portfolioSliceColors.length - 1,
                  )],
            ),
            if (i < records.length - 1)
              Divider(
                height: 1,
                thickness: 0.5,
                color: textColor.withAlpha(20),
                indent: 48.w,
              ),
          ],
        ],
      ),
    );
  }
}
