// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

part of 'gas_tracker_page.dart';

// ══════════════════════════════════════════════════════════
// 页面局部构建方法（网络卡片、sparkline、Gas 行、状态标签等）
// ══════════════════════════════════════════════════════════

extension _GasTrackerCardBuilders on _GasTrackerPageState {
  Widget buildHeader() {
    final blueColor = AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [blueColor.withAlpha(30), blueColor.withAlpha(10)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
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
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(4)),
                Text(
                  S.of(context).g_key_gas_auto_refresh('15'),
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemSubtitleTextColor.name),
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
    final subtitleColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name);

    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(16)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        border: Border.all(color: network.color.withAlpha(50), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 网络标题行 ───────────────────────────────
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
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainTextColor.name),
                      ),
                    ),
                    Text(
                      network.symbol,
                      style: TextStyle(
                          fontSize: ScreenUtil().setSp(22), color: subtitleColor),
                    ),
                  ],
                ),
              ),
              // 提醒铃铛（已配置则高亮）
              GestureDetector(
                onTap: () => _showAlertSheet(network),
                child: Icon(
                  hasAlert ? Icons.notifications_active : Icons.notifications_none,
                  size: ScreenUtil().setWidth(36),
                  color: hasAlert ? network.color : subtitleColor,
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(8)),
              buildNetworkStatus(data?.gasPrice),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),

          // ── Gas 费用数据行 ───────────────────────────
          if (data != null) ...[
            buildGasRow(S.of(context).g_key_t_17, // Gas Price
                '${data.gasPrice.toStringAsFixed(2)} Gwei', network.color),
            if (data.baseFee != null)
              buildGasRow(S.of(context).g_key_gas_base_fee,
                  '${data.baseFee!.toStringAsFixed(2)} Gwei', network.color.withAlpha(180)),
            if (data.priorityFee != null)
              buildGasRow(
                  S.of(context).g_key_gas_priority_fee,
                  '${data.priorityFee!.toStringAsFixed(2)} Gwei',
                  network.color.withAlpha(180)),
          ] else
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(8)),
                child: Text(
                  S.of(context).g_key_106,
                  style: TextStyle(fontSize: ScreenUtil().setSp(24), color: subtitleColor),
                ),
              ),
            ),

          // ── 价格走势 sparkline ───────────────────────
          if (history.length >= 3) ...[
            SizedBox(height: ScreenUtil().setWidth(12)),
            buildSparkline(history, network),
          ],
        ],
      ),
    );
  }

  Widget buildSparkline(List<double> history, NetworkConfig network) {
    final minY = history.reduce((a, b) => a < b ? a : b);
    final maxY = history.reduce((a, b) => a > b ? a : b);
    // 添加小边距防止线条被裁剪
    final padding = (maxY - minY) * 0.1 + 0.5;
    final subtitleColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name);

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
            Text(
              S.of(context).g_key_gas_price_trend,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                color: subtitleColor,
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
                  belowBarData: BarAreaData(show: true, color: network.color.withAlpha(25)),
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
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(12),
              vertical: ScreenUtil().setWidth(4),
            ),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
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
    String statusText;
    Color statusColor;

    if (gasPrice == null) {
      statusText = '...';
      statusColor = Colors.grey;
    } else if (gasPrice < 20) {
      statusText = S.of(context).g_key_gas_network_idle;
      statusColor = Colors.green;
    } else if (gasPrice < 50) {
      statusText = S.of(context).g_key_gas_network_normal;
      statusColor = Colors.orange;
    } else {
      statusText = S.of(context).g_key_gas_network_busy;
      statusColor = Colors.red;
    }

    return Container(
      constraints: BoxConstraints(maxWidth: ScreenUtil().setWidth(140)),
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(12),
        vertical: ScreenUtil().setWidth(6),
      ),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(20),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
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

  Widget buildFooter() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(8)),
      child: Text(
        S.of(context).g_key_gas_footer,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(22),
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemSubtitleTextColor.name),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
