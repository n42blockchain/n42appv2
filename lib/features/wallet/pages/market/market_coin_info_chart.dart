import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/widgets/candlestick_chart.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

import 'market_coin_info_helpers.dart';

// ─── chart section ─────────────────────────────────────────────────────────

Widget buildChartSection(
  BuildContext context, {
  required bool chartLoading,
  required List<OhlcPoint> ohlcvData,
  required List<double> volumeData,
  required Map<String, dynamic> coin,
}) {
  final chartH = ScreenUtil().setWidth(360);
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
    child: Container(
      height: chartH,
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgSurface,
        borderRadius: AppRadius.brMd,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.brMd,
        child: _resolveChartChild(
          context,
          chartLoading: chartLoading,
          ohlcvData: ohlcvData,
          volumeData: volumeData,
          coin: coin,
          chartH: chartH,
        ),
      ),
    ),
  );
}

Widget _resolveChartChild(
  BuildContext context, {
  required bool chartLoading,
  required List<OhlcPoint> ohlcvData,
  required List<double> volumeData,
  required Map<String, dynamic> coin,
  required double chartH,
}) {
  if (chartLoading) {
    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
  }
  if (ohlcvData.isNotEmpty) {
    return CandlestickChart(
      ohlcData: ohlcvData,
      volumeData: volumeData,
      height: chartH,
      volumeHeightRatio: 0.22,
    );
  }
  return _buildFallbackChart(context, coin, chartH);
}

Widget _buildFallbackChart(
  BuildContext context,
  Map<String, dynamic> coin,
  double height,
) {
  final prices = _fallbackPrices(coin);
  if (prices.isEmpty) return _noChartData(context);

  const buckets = 40;
  final step = max(1, prices.length ~/ buckets);
  final ohlc = <OhlcPoint>[];
  for (int i = 0; i + step <= prices.length; i += step) {
    final slice = prices.sublist(i, i + step);
    final point = OhlcPoint(
      open: slice.first,
      close: slice.last,
      high: slice.reduce(max),
      low: slice.reduce(min),
    );
    if (point.isValid) ohlc.add(point);
  }
  if (ohlc.isEmpty) return _noChartData(context);

  return CandlestickChart(ohlcData: ohlc, height: height, volumeHeightRatio: 0);
}

List<double> _fallbackPrices(Map<String, dynamic> coin) {
  final raw = coin['kline_default'];
  if (raw is! List) return const [];
  return raw.map((v) => toDouble(v)).where((v) => v.isFinite && v > 0).toList();
}

Widget _noChartData(BuildContext context) => Center(
  child: Text(
    S.of(context).g_market_no_chart,
    style: TextStyle(
      color: AppColorTokens.of(context).textSubtitle,
      fontSize: ScreenUtil().setSp(24),
    ),
  ),
);
