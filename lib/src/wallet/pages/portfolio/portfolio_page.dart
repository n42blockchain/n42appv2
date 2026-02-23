// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/src/wallet/models/coin_model.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/src/widgets/image_network.dart' show ImageNetWork;

// ─── Color palette for pie slices ────────────────────────────────────────────

const _sliceColors = [
  Color(0xFF1976F9), // blue
  Color(0xFF22C55E), // green
  Color(0xFFFF8C00), // orange
  Color(0xFF9333EA), // purple
  Color(0xFFEF4444), // red
  Color(0xFF06B6D4), // cyan
  Color(0xFFF59E0B), // amber
  Color(0xFFEC4899), // pink
  Color(0xFF10B981), // emerald
  Color(0xFF6366F1), // indigo
  Color(0xFF94A3B8), // slate (Others)
];

// ─── Entry point ─────────────────────────────────────────────────────────────

class PortfolioPage extends ConsumerStatefulWidget {
  const PortfolioPage({super.key});

  @override
  ConsumerState<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends ConsumerState<PortfolioPage> {
  int _touchedIndex = -1;

  static final _oCcy = NumberFormat('#,##0.00', 'en_US');
  static final _oCcyBig = NumberFormat('#,##0.0#', 'en_US');

  // ─── Data helpers ────────────────────────────────────────────────────────

  /// Extract a portable data record from any item in coinList.
  _CoinRecord? _record(dynamic item) {
    if (item is! CoinModel) return null;
    if (item.value <= 0) return null;
    final symbol =
        (item.coin['miniName'] ?? item.coin['coinType'] ?? '').toString();
    if (symbol.isEmpty) return null;
    return _CoinRecord(
      symbol: symbol,
      name: (item.coin['name'] ?? symbol).toString(),
      icon: (item.coin['icon'] ?? '').toString(),
      value: item.value,
      percentage: item.percentage,
    );
  }

  /// pnl24h ≈ value × pct / 100 (approximation; exact for small pct)
  double _pnl(double value, double pct) => value * pct / 100.0;

  String _fmtUsd(double v) {
    if (v.abs() >= 1e9) return '\$${(v / 1e9).toStringAsFixed(2)}B';
    if (v.abs() >= 1e6) return '\$${(v / 1e6).toStringAsFixed(2)}M';
    if (v.abs() >= 1000) return '\$${_oCcyBig.format(v)}';
    return '\$${_oCcy.format(v)}';
  }

  String _fmtPnl(double v) {
    final sign = v >= 0 ? '+' : '';
    if (v.abs() >= 1e6) return '$sign\$${(v / 1e6).toStringAsFixed(2)}M';
    if (v.abs() >= 1000) return '$sign\$${_oCcyBig.format(v)}';
    return '$sign\$${_oCcy.format(v)}';
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final waValue = ref.watch(wapBridgeProvider);
    final bgColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name);
    final itemBg =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name);
    final textColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
    final accentColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);

    // Build records
    final records = waValue.coinList
        .map(_record)
        .whereType<_CoinRecord>()
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalValue = records.fold(0.0, (s, r) => s + r.value);
    final total24hPnl = records.fold(0.0, (s, r) => s + _pnl(r.value, r.percentage));
    final previousTotal = totalValue - total24hPnl;
    final total24hPct = previousTotal > 0 ? total24hPnl / previousTotal * 100 : 0.0;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: itemBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: textColor, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          S.of(context).g_portfolio_title,
          style: TextStyle(
              color: textColor, fontSize: 18.sp, fontWeight: FontWeight.bold),
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
                      context, totalValue, total24hPnl, total24hPct,
                      itemBg, textColor, accentColor),
                  SizedBox(height: 16.h),
                  _buildPieSection(context, records, totalValue, itemBg,
                      textColor, accentColor),
                  SizedBox(height: 16.h),
                  _buildMoversSection(context, records, itemBg, textColor),
                  SizedBox(height: 16.h),
                  _buildHoldingsList(context, records, totalValue, itemBg,
                      textColor, accentColor),
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
          Icon(Icons.donut_large_outlined,
              size: 64.sp, color: textColor.withAlpha(80)),
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
          child: _SummaryCard(
            label: S.of(context).g_portfolio_total,
            value: _fmtUsd(totalValue),
            subValue: null,
            valueColor: accentColor,
            itemBg: itemBg,
            textColor: textColor,
            icon: Icons.account_balance_wallet_outlined,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _SummaryCard(
            label: S.of(context).g_portfolio_24h,
            value: _fmtPnl(pnl24h),
            subValue:
                '${pnlPct >= 0 ? '+' : ''}${pnlPct.toStringAsFixed(2)}%',
            valueColor:
                pnl24h >= 0 ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
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
    List<_CoinRecord> records,
    double totalValue,
    Color itemBg,
    Color textColor,
    Color accentColor,
  ) {
    const maxSlices = 8;
    final sliceRecords = records.take(maxSlices).toList();
    final othersValue = records.length > maxSlices
        ? records.skip(maxSlices).fold(0.0, (sum, r) => sum + r.value)
        : 0.0;

    final sections = <PieChartSectionData>[];
    for (var i = 0; i < sliceRecords.length; i++) {
      final r = sliceRecords[i];
      final pct = totalValue > 0 ? r.value / totalValue * 100 : 0.0;
      final isTouched = i == _touchedIndex;
      sections.add(PieChartSectionData(
        value: pct,
        color: _sliceColors[i % _sliceColors.length],
        radius: isTouched ? 70.r : 56.r,
        title: isTouched ? '${pct.toStringAsFixed(1)}%' : '',
        titleStyle: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: const [Shadow(blurRadius: 4, color: Colors.black26)]),
        titlePositionPercentageOffset: 0.6,
      ));
    }
    if (othersValue > 0) {
      final pct = totalValue > 0 ? othersValue / totalValue * 100 : 0.0;
      final idx = sliceRecords.length;
      final isTouched = idx == _touchedIndex;
      sections.add(PieChartSectionData(
        value: pct,
        color: _sliceColors.last,
        radius: isTouched ? 70.r : 56.r,
        title: isTouched ? '${pct.toStringAsFixed(1)}%' : '',
        titleStyle: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white),
        titlePositionPercentageOffset: 0.6,
      ));
    }

    // What's currently highlighted
    _CoinRecord? highlighted;
    if (_touchedIndex >= 0 && _touchedIndex < sliceRecords.length) {
      highlighted = sliceRecords[_touchedIndex];
    }

    return Container(
      decoration: BoxDecoration(
        color: itemBg,
        borderRadius: BorderRadius.circular(16.r),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_portfolio_allocation,
            style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: textColor),
          ),
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
                            touchCallback: (FlTouchEvent event,
                                PieTouchResponse? response) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    response == null ||
                                    response.touchedSection == null) {
                                  _touchedIndex = -1;
                                } else {
                                  _touchedIndex = response
                                      .touchedSection!.touchedSectionIndex;
                                }
                              });
                            },
                          ),
                        ),
                      ),
                      // Center label
                      if (highlighted != null)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              highlighted.symbol.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: textColor),
                            ),
                            Text(
                              _fmtUsd(highlighted.value),
                              style: TextStyle(
                                  fontSize: 11.sp,
                                  color: textColor.withAlpha(178)),
                            ),
                          ],
                        )
                      else
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              S.of(context).g_portfolio_pie_total,
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: textColor.withAlpha(153)),
                            ),
                            Text(
                              _fmtUsd(totalValue),
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: textColor),
                            ),
                          ],
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
                        _LegendItem(
                          color: _sliceColors[i % _sliceColors.length],
                          symbol: sliceRecords[i].symbol.toUpperCase(),
                          pct: totalValue > 0
                              ? sliceRecords[i].value / totalValue * 100
                              : 0,
                          isActive: i == _touchedIndex,
                          textColor: textColor,
                        ),
                      if (othersValue > 0)
                        _LegendItem(
                          color: _sliceColors.last,
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

  // ─── 24h Movers ────────────────────────────────────────────────────────────

  Widget _buildMoversSection(
    BuildContext context,
    List<_CoinRecord> records,
    Color itemBg,
    Color textColor,
  ) {
    if (records.isEmpty) return const SizedBox();

    // Sort by absolute 24h $ gain/loss
    final sorted = List<_CoinRecord>.from(records)
      ..sort((a, b) {
        final pa = _pnl(a.value, a.percentage);
        final pb = _pnl(b.value, b.percentage);
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

    return Container(
      decoration: BoxDecoration(
        color: itemBg,
        borderRadius: BorderRadius.circular(16.r),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_portfolio_movers,
            style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: textColor),
          ),
          SizedBox(height: 12.h),
          if (gainers.isNotEmpty) ...[
            _MoverRow(
              label: S.of(context).g_portfolio_gainers,
              records: gainers,
              pnlFn: _pnl,
              fmtUsd: _fmtUsd,
              textColor: textColor,
            ),
          ],
          if (losers.isNotEmpty) ...[
            SizedBox(height: 10.h),
            _MoverRow(
              label: S.of(context).g_portfolio_losers,
              records: losers,
              pnlFn: _pnl,
              fmtUsd: _fmtUsd,
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
    List<_CoinRecord> records,
    double totalValue,
    Color itemBg,
    Color textColor,
    Color accentColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: itemBg,
        borderRadius: BorderRadius.circular(16.r),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_portfolio_all_holdings,
            style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: textColor),
          ),
          SizedBox(height: 8.h),
          for (var i = 0; i < records.length; i++) ...[
            _HoldingRow(
              record: records[i],
              rank: i + 1,
              totalValue: totalValue,
              pnlFn: _pnl,
              fmtUsd: _fmtUsd,
              accentColor: accentColor,
              textColor: textColor,
              sliceColor: _sliceColors[i < _sliceColors.length - 1
                  ? i
                  : _sliceColors.length - 1],
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

// ─── Data model ──────────────────────────────────────────────────────────────

class _CoinRecord {
  final String symbol;
  final String name;
  final String icon;
  final double value;
  final double percentage;

  const _CoinRecord({
    required this.symbol,
    required this.name,
    required this.icon,
    required this.value,
    required this.percentage,
  });
}

// ─── Summary card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subValue;
  final Color valueColor;
  final Color itemBg;
  final Color textColor;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.subValue,
    required this.valueColor,
    required this.itemBg,
    required this.textColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: itemBg,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15.sp, color: valueColor),
              SizedBox(width: 5.w),
              Text(
                label,
                style: TextStyle(
                    fontSize: 12.sp, color: textColor.withAlpha(153)),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: valueColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subValue != null)
            Text(
              subValue!,
              style: TextStyle(fontSize: 12.sp, color: valueColor.withAlpha(200)),
            ),
        ],
      ),
    );
  }
}

// ─── Legend item ──────────────────────────────────────────────────────────────

class _LegendItem extends StatelessWidget {
  final Color color;
  final String symbol;
  final double pct;
  final bool isActive;
  final Color textColor;

  const _LegendItem({
    required this.color,
    required this.symbol,
    required this.pct,
    required this.isActive,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.h,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              symbol,
              style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight:
                      isActive ? FontWeight.bold : FontWeight.normal,
                  color:
                      isActive ? textColor : textColor.withAlpha(178)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${pct.toStringAsFixed(1)}%',
            style: TextStyle(
                fontSize: 11.sp,
                color: isActive ? textColor : textColor.withAlpha(128)),
          ),
        ],
      ),
    );
  }
}

// ─── Mover row ────────────────────────────────────────────────────────────────

class _MoverRow extends StatelessWidget {
  final String label;
  final List<_CoinRecord> records;
  final double Function(double, double) pnlFn;
  final String Function(double) fmtUsd;
  final Color textColor;

  const _MoverRow({
    required this.label,
    required this.records,
    required this.pnlFn,
    required this.fmtUsd,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isGainer = records.isNotEmpty && records.first.percentage >= 0;
    final labelColor =
        isGainer ? const Color(0xFF22C55E) : const Color(0xFFEF4444);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isGainer
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              size: 13.sp,
              color: labelColor,
            ),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: labelColor),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        for (final r in records)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: r.icon.isNotEmpty
                      ? ImageNetWork(
                          imageUrl: r.icon,
                          width: 24.w,
                          height: 24.w,
                        )
                      : Container(
                          width: 24.w,
                          height: 24.w,
                          color: textColor.withAlpha(30),
                          child: Icon(Icons.currency_bitcoin,
                              size: 14.sp, color: textColor.withAlpha(100)),
                        ),
                ),
                SizedBox(width: 8.w),
                Text(
                  r.symbol.toUpperCase(),
                  style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: textColor),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${r.percentage >= 0 ? '+' : ''}${r.percentage.toStringAsFixed(2)}%',
                      style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: labelColor),
                    ),
                    Text(
                      fmtUsd(pnlFn(r.value, r.percentage)),
                      style: TextStyle(
                          fontSize: 11.sp,
                          color: labelColor.withAlpha(200)),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ─── Holdings row ─────────────────────────────────────────────────────────────

class _HoldingRow extends StatelessWidget {
  final _CoinRecord record;
  final int rank;
  final double totalValue;
  final double Function(double, double) pnlFn;
  final String Function(double) fmtUsd;
  final Color accentColor;
  final Color textColor;
  final Color sliceColor;

  const _HoldingRow({
    required this.record,
    required this.rank,
    required this.totalValue,
    required this.pnlFn,
    required this.fmtUsd,
    required this.accentColor,
    required this.textColor,
    required this.sliceColor,
  });

  @override
  Widget build(BuildContext context) {
    final pct = totalValue > 0 ? record.value / totalValue * 100 : 0.0;
    final pnl = pnlFn(record.value, record.percentage);
    final isUp = record.percentage >= 0;
    final pctColor =
        isUp ? const Color(0xFF22C55E) : const Color(0xFFEF4444);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          // Rank dot with slice color
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: sliceColor.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: sliceColor),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // Icon
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: record.icon.isNotEmpty
                ? ImageNetWork(
                    imageUrl: record.icon,
                    width: 28.w,
                    height: 28.w,
                  )
                : Container(
                    width: 28.w,
                    height: 28.w,
                    color: textColor.withAlpha(20),
                  ),
          ),
          SizedBox(width: 8.w),
          // Name & allocation bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.symbol.toUpperCase(),
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: textColor),
                ),
                SizedBox(height: 3.h),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2.r),
                        child: LinearProgressIndicator(
                          value: (pct / 100).clamp(0.0, 1.0),
                          minHeight: 3.h,
                          backgroundColor: textColor.withAlpha(20),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(sliceColor),
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '${pct.toStringAsFixed(1)}%',
                      style: TextStyle(
                          fontSize: 10.sp,
                          color: textColor.withAlpha(128)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          // Value & 24h
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                fmtUsd(record.value),
                style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor),
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${isUp ? '+' : ''}${record.percentage.toStringAsFixed(2)}%',
                    style: TextStyle(fontSize: 11.sp, color: pctColor),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '(${pnl >= 0 ? '+' : ''}\$${pnl.abs() < 1 ? pnl.toStringAsFixed(4) : pnl.toStringAsFixed(2)})',
                    style: TextStyle(
                        fontSize: 10.sp, color: pctColor.withAlpha(180)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
