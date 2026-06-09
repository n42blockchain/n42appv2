import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet/api/market_api.dart';
import 'package:n42_wallet/features/wallet/pages/market/market_coin_info.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

/// 迷你市场数据预览卡片 — 嵌入币种详情页 WalletChainInfo
///
/// 显示 7 天 sparkline、24h 涨跌百分比、Market Cap 和 24h Volume。
/// 点击跳转完整的 MarketCoinInfo 页面。
class WalletCoinMarketPreview extends StatefulWidget {
  final String geckoId;
  final double priceChange24h;
  final Map<String, dynamic> marketInfo;

  const WalletCoinMarketPreview({
    super.key,
    required this.geckoId,
    required this.priceChange24h,
    required this.marketInfo,
  });

  @override
  State<WalletCoinMarketPreview> createState() =>
      _WalletCoinMarketPreviewState();
}

class _WalletCoinMarketPreviewState extends State<WalletCoinMarketPreview> {
  List<double> _prices = [];
  bool _loading = true;
  int _chartRequestId = 0;

  @override
  void initState() {
    super.initState();
    _fetchChart();
  }

  @override
  void didUpdateWidget(covariant WalletCoinMarketPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.geckoId != widget.geckoId) {
      _prices = [];
      _loading = true;
      _fetchChart();
    }
  }

  Future<void> _fetchChart() async {
    final requestId = ++_chartRequestId;
    final geckoId = widget.geckoId.trim();
    if (geckoId.isEmpty) {
      if (mounted && requestId == _chartRequestId) {
        setState(() {
          _prices = [];
          _loading = false;
        });
      }
      return;
    }
    try {
      final data = await MarketApi().getMarketChart(geckoId, days: 7);
      if (mounted && requestId == _chartRequestId) {
        setState(() {
          _prices = data['prices'] ?? [];
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted && requestId == _chartRequestId) {
        setState(() {
          _prices = [];
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _prices.length < 2) return const SizedBox.shrink();

    final su = ScreenUtil();
    final textColor = AppColorTokens.of(context).textPrimary;
    final subtitleColor = AppColorTokens.of(context).textSubtitle;
    final blueColor = AppColorTokens.of(context).brand;
    final isUp = widget.priceChange24h >= 0;
    final c = AppColorTokens.of(context);
    final trendColor = isUp ? c.success : c.danger;

    return GestureDetector(
      onTap: _navigateToMarketCoinInfo,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: su.setWidth(30),
          vertical: su.setWidth(16),
        ),
        padding: EdgeInsets.all(su.setWidth(20)),
        decoration: BoxDecoration(
          color: AppColorTokens.of(context).bgSurface,
          borderRadius: BorderRadius.circular(su.setWidth(16)),
          border: Border.all(color: trendColor.withAlpha(40), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Sparkline + 24h change badge
            Row(
              children: [
                Expanded(child: _buildSparkline(trendColor, su)),
                SizedBox(width: su.setWidth(16)),
                _buildChangeBadge(trendColor, su),
              ],
            ),
            SizedBox(height: su.setWidth(12)),
            // Row 2: Market Cap | 24h Volume
            _buildMetricsRow(subtitleColor, textColor, su),
            SizedBox(height: su.setWidth(8)),
            // Bottom: link
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'View Market Data \u2192',
                style: TextStyle(fontSize: su.setSp(22), color: blueColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSparkline(Color trendColor, ScreenUtil su) {
    final minY = _prices.reduce((a, b) => a < b ? a : b);
    final maxY = _prices.reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.1 + 0.001;

    return SizedBox(
      height: su.setWidth(60),
      child: LineChart(
        LineChartData(
          minY: minY - padding,
          maxY: maxY + padding,
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: _prices
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                  .toList(),
              isCurved: true,
              curveSmoothness: 0.3,
              color: trendColor,
              barWidth: 1.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: trendColor.withAlpha(20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChangeBadge(Color trendColor, ScreenUtil su) {
    final sign = widget.priceChange24h >= 0 ? '+' : '';
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: su.setWidth(12),
        vertical: su.setWidth(6),
      ),
      decoration: BoxDecoration(
        color: trendColor.withAlpha(20),
        borderRadius: BorderRadius.circular(su.setWidth(8)),
      ),
      child: Text(
        '$sign${widget.priceChange24h.toStringAsFixed(2)}%',
        style: TextStyle(
          fontSize: su.setSp(24),
          fontWeight: FontWeight.w600,
          color: trendColor,
        ),
      ),
    );
  }

  Widget _buildMetricsRow(Color subtitleColor, Color textColor, ScreenUtil su) {
    final marketCap = widget.marketInfo['market_cap'];
    final volume24h = widget.marketInfo['volume_24h'];

    return Row(
      children: [
        if (marketCap != null) ...[
          _buildMetric(
            'MCap',
            _formatLargeNumber(marketCap),
            subtitleColor,
            textColor,
            su,
          ),
          SizedBox(width: su.setWidth(24)),
        ],
        if (volume24h != null)
          _buildMetric(
            '24h Vol',
            _formatLargeNumber(volume24h),
            subtitleColor,
            textColor,
            su,
          ),
      ],
    );
  }

  Widget _buildMetric(
    String label,
    String value,
    Color labelColor,
    Color valueColor,
    ScreenUtil su,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: su.setSp(20), color: labelColor),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: su.setSp(22),
            fontWeight: FontWeight.w500,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  String _formatLargeNumber(dynamic value) {
    final num v;
    if (value is num) {
      v = value;
    } else if (value is String) {
      v = num.tryParse(value) ?? 0;
    } else {
      return '--';
    }
    if (v >= 1e12) return '\$${(v / 1e12).toStringAsFixed(2)}T';
    if (v >= 1e9) return '\$${(v / 1e9).toStringAsFixed(2)}B';
    if (v >= 1e6) return '\$${(v / 1e6).toStringAsFixed(2)}M';
    if (v >= 1e3) return '\$${(v / 1e3).toStringAsFixed(1)}K';
    return '\$${v.toStringAsFixed(2)}';
  }

  void _navigateToMarketCoinInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MarketCoinInfo(widget.marketInfo)),
    );
  }
}
