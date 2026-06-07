// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

part of 'gas_tracker_page.dart';

extension _GasTrackerCardBuilders on _GasTrackerPageState {
  Widget buildHeader() {
    final blueColor = AppColorTokens.of(context).brand;
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [blueColor.withAlpha(30), blueColor.withAlpha(10)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.brMd,
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_gas_station_rounded,
            size: ScreenUtil().setWidth(48),
            color: blueColor,
          ),
          SizedBox(width: ScreenUtil().setWidth(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).g_key_gas_realtime_prices,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(30),
                    fontWeight: FontWeight.bold,
                    color: AppColorTokens.of(context).textPrimary,
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(4)),
                Text(
                  S.of(context).g_key_gas_auto_refresh('15'),
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    color: AppColorTokens.of(context).textSubtitle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNetworkCard(NetworkConfig network) {
    final data = _gasData[network.symbol];
    final history = _history[network.symbol] ?? [];
    final hasAlert = _alertConfigs[network.symbol]?.enabled ?? false;
    final subtitleColor = AppColorTokens.of(context).textSubtitle;

    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(16)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgSurface,
        borderRadius: AppRadius.brMd,
        border: Border.all(color: network.color.withAlpha(50), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _NetworkIcon(network: network, size: 44, iconSize: 24),
              SizedBox(width: ScreenUtil().setWidth(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      network.name,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(28),
                        fontWeight: FontWeight.w600,
                        color: AppColorTokens.of(context).textPrimary,
                      ),
                    ),
                    Text(
                      network.symbol,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(22),
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showAlertSheet(network),
                child: Icon(
                  hasAlert
                      ? Icons.notifications_active
                      : Icons.notifications_none,
                  size: ScreenUtil().setWidth(36),
                  color: hasAlert ? network.color : subtitleColor,
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(8)),
              buildNetworkStatus(data?.gasPrice),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          if (data != null) ...[
            buildGasRow(
              S.of(context).g_key_t_17,
              '${data.gasPrice.toStringAsFixed(2)} Gwei',
              network.color,
            ),
            if (data.baseFee != null)
              buildGasRow(
                S.of(context).g_key_gas_base_fee,
                '${data.baseFee!.toStringAsFixed(2)} Gwei',
                network.color.withAlpha(180),
              ),
            if (data.priorityFee != null)
              buildGasRow(
                S.of(context).g_key_gas_priority_fee,
                '${data.priorityFee!.toStringAsFixed(2)} Gwei',
                network.color.withAlpha(180),
              ),
          ] else
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: ScreenUtil().setWidth(8),
                ),
                child: Text(
                  S.of(context).g_key_106,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    color: subtitleColor,
                  ),
                ),
              ),
            ),
          if (history.length >= 3) ...[
            SizedBox(height: ScreenUtil().setWidth(12)),
            buildSparkline(history, network),
          ],
          buildMempoolIndicator(network.symbol),
        ],
      ),
    );
  }

  Widget buildSparkline(List<double> history, NetworkConfig network) {
    final minY = history.reduce((a, b) => a < b ? a : b);
    final maxY = history.reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.1 + 0.5;
    final subtitleColor = AppColorTokens.of(context).textSubtitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.show_chart,
              size: ScreenUtil().setWidth(28),
              color: subtitleColor,
            ),
            SizedBox(width: ScreenUtil().setWidth(6)),
            Flexible(
              child: Text(
                S.of(context).g_key_gas_price_trend,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(22),
                  color: subtitleColor,
                ),
              ),
            ),
            const Spacer(),
            Text(
              '${history.last.toStringAsFixed(1)} Gwei',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                fontWeight: FontWeight.w600,
                color: network.color,
              ),
            ),
          ],
        ),
        SizedBox(height: ScreenUtil().setWidth(8)),
        SizedBox(
          height: ScreenUtil().setWidth(80),
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
                  spots: history
                      .asMap()
                      .entries
                      .map((e) => FlSpot(e.key.toDouble(), e.value))
                      .toList(),
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: network.color,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: network.color.withAlpha(25),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildGasRow(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: AppColorTokens.of(context).textSubtitle,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(12),
              vertical: ScreenUtil().setWidth(4),
            ),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: AppRadius.brSm,
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNetworkStatus(double? gasPrice) {
    final (statusText, statusColor) = switch (gasPrice) {
      null => ('...', Colors.grey),
      < 20 => (S.of(context).g_key_gas_network_idle, Colors.green),
      < 50 => (S.of(context).g_key_gas_network_normal, Colors.orange),
      _ => (S.of(context).g_key_gas_network_busy, Colors.red),
    };

    return Container(
      constraints: BoxConstraints(maxWidth: ScreenUtil().setWidth(140)),
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(12),
        vertical: ScreenUtil().setWidth(6),
      ),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(20),
        borderRadius: AppRadius.brMd,
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(22),
          fontWeight: FontWeight.w600,
          color: statusColor,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }

  // ── Gas Prediction Card ──────────────────────────────────

  Widget buildGasPredictionCard() {
    final su = ScreenUtil();
    final textColor = AppColorTokens.of(context).textPrimary;

    return Container(
      padding: EdgeInsets.all(su.setWidth(20)),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgSurface,
        borderRadius: BorderRadius.circular(su.setWidth(16)),
        border: Border.all(color: Colors.orange.withAlpha(50), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_graph,
                size: su.setWidth(36),
                color: Colors.orange,
              ),
              SizedBox(width: su.setWidth(8)),
              Text(
                'Next Block Gas Prediction',
                style: TextStyle(
                  fontSize: su.setSp(28),
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          SizedBox(height: su.setWidth(12)),
          ..._gasPredictions.entries.map((entry) {
            final symbol = entry.key;
            final pred = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: su.setWidth(8)),
              child: Row(
                children: [
                  Text(
                    symbol,
                    style: TextStyle(
                      fontSize: su.setSp(24),
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  SizedBox(width: su.setWidth(12)),
                  if (pred.low != null)
                    _predBadge('Slow', pred.low!, Colors.green, su),
                  SizedBox(width: su.setWidth(8)),
                  if (pred.medium != null)
                    _predBadge('Avg', pred.medium!, Colors.orange, su),
                  SizedBox(width: su.setWidth(8)),
                  if (pred.high != null)
                    _predBadge('Fast', pred.high!, Colors.red, su),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _predBadge(String label, double value, Color color, ScreenUtil su) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: su.setWidth(10),
        vertical: su.setWidth(4),
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(su.setWidth(6)),
      ),
      child: Text(
        '$label: ${value.toStringAsFixed(1)}',
        style: TextStyle(
          fontSize: su.setSp(20),
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // ── Mempool Indicator ──────────────────────────────────

  Widget buildMempoolIndicator(String symbol) {
    final data = _mempoolData[symbol];
    if (data == null) return const SizedBox.shrink();

    final su = ScreenUtil();
    final subtitleColor = AppColorTokens.of(context).textSubtitle;

    return Padding(
      padding: EdgeInsets.only(top: su.setWidth(8)),
      child: Row(
        children: [
          Icon(
            Icons.pending_actions,
            size: su.setWidth(28),
            color: subtitleColor,
          ),
          SizedBox(width: su.setWidth(6)),
          Text(
            'Mempool',
            style: TextStyle(fontSize: su.setSp(22), color: subtitleColor),
          ),
          SizedBox(width: su.setWidth(8)),
          if (data.pendingCount != null)
            Text(
              '${_formatCount(data.pendingCount!)} pending',
              style: TextStyle(
                fontSize: su.setSp(22),
                color: data.congestionColor,
              ),
            ),
          const Spacer(),
          Container(
            width: su.setWidth(60),
            height: su.setWidth(8),
            decoration: BoxDecoration(
              color: data.congestionColor.withAlpha(40),
              borderRadius: BorderRadius.circular(su.setWidth(4)),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _congestionFraction(data.congestionLevel),
              child: Container(
                decoration: BoxDecoration(
                  color: data.congestionColor,
                  borderRadius: BorderRadius.circular(su.setWidth(4)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  double _congestionFraction(String? level) => switch (level) {
    'low' => 0.3,
    'medium' => 0.6,
    'high' => 1.0,
    _ => 0.1,
  };

  Widget buildFooter() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(8)),
      child: Text(
        S.of(context).g_key_gas_footer,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(22),
          color: AppColorTokens.of(context).textSubtitle,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
