// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:n42_wallet/core/config/rpc_config.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/src/wallet/services/gas_alert_service.dart';
import 'package:n42_wallet/src/widgets/app_bar_widget.dart';

/// Gas 追踪器页面
///
/// 功能：
/// - 实时显示主流 EVM 网络 Gas 费用（15 秒自动刷新）
/// - 每张网络卡片内嵌近 15 分钟价格走势 sparkline
/// - 每个网络可独立配置价格提醒（低于/高于阈值触发本地通知）
class GasTrackerPage extends StatefulWidget {
  const GasTrackerPage({super.key});

  @override
  State<GasTrackerPage> createState() => _GasTrackerPageState();
}

class _GasTrackerPageState extends State<GasTrackerPage> {
  final Map<String, NetworkGasData> _gasData = {};

  /// 内存中的历史价格（Gwei），每个网络最多保留 60 个采样点（≈15 分钟）
  final Map<String, List<double>> _history = {};

  Map<String, GasAlertConfig> _alertConfigs = {};
  bool _isLoading = true;
  Timer? _refreshTimer;

  static const List<NetworkConfig> _networks = [
    NetworkConfig(symbol: 'ETH', name: 'Ethereum', icon: '⟠', color: Color(0xFF627EEA)),
    NetworkConfig(symbol: 'BNB', name: 'BNB Chain', icon: '◈', color: Color(0xFFF3BA2F)),
    NetworkConfig(symbol: 'MATIC', name: 'Polygon', icon: '⬡', color: Color(0xFF8247E5)),
    NetworkConfig(symbol: 'ARB', name: 'Arbitrum', icon: '◇', color: Color(0xFF28A0F0)),
    NetworkConfig(symbol: 'OP', name: 'Optimism', icon: '◎', color: Color(0xFFFF0420)),
    NetworkConfig(symbol: 'AVAX', name: 'Avalanche', icon: '▲', color: Color(0xFFE84142)),
  ];

  @override
  void initState() {
    super.initState();
    _loadAlertConfigs();
    _fetchAllGasData();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _fetchAllGasData();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAlertConfigs() async {
    final configs = await GasAlertService.loadAll();
    if (mounted) {
      setState(() => _alertConfigs = configs);
    }
  }

  Future<void> _fetchAllGasData() async {
    await Future.wait(_networks.map(_fetchGasForNetwork));
    if (mounted) {
      setState(() => _isLoading = false);
    }
    // 每次刷新后检查提醒阈值
    _checkAlerts();
  }

  Future<void> _fetchGasForNetwork(NetworkConfig network) async {
    try {
      final rpcUrl = _getRpcUrl(network.symbol);
      if (rpcUrl.isEmpty) return;

      final client = http.Client();
      try {
        final gasPriceResponse = await client
            .post(
              Uri.parse(rpcUrl),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'jsonrpc': '2.0',
                'method': 'eth_gasPrice',
                'params': [],
                'id': 1,
              }),
            )
            .timeout(const Duration(seconds: 10));

        if (gasPriceResponse.statusCode != 200) return;

        final gasPriceJson = jsonDecode(gasPriceResponse.body);
        final gasPriceHex = gasPriceJson['result'] as String?;
        if (gasPriceHex == null) return;

        final gasPrice = BigInt.parse(gasPriceHex.substring(2), radix: 16);
        final gasPriceGwei = gasPrice.toDouble() / 1e9;

        BigInt? baseFee;
        BigInt? priorityFee;

        try {
          final feeHistoryResponse = await client
              .post(
                Uri.parse(rpcUrl),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'jsonrpc': '2.0',
                  'method': 'eth_feeHistory',
                  'params': [1, 'latest', [25, 50, 75]],
                  'id': 2,
                }),
              )
              .timeout(const Duration(seconds: 10));

          if (feeHistoryResponse.statusCode == 200) {
            final feeHistoryJson = jsonDecode(feeHistoryResponse.body);
            final result = feeHistoryJson['result'];
            if (result != null) {
              final baseFeeList = result['baseFeePerGas'] as List?;
              if (baseFeeList != null && baseFeeList.isNotEmpty) {
                final baseFeeHex = baseFeeList.last as String;
                baseFee = BigInt.parse(baseFeeHex.substring(2), radix: 16);
              }
              final rewardList = result['reward'] as List?;
              if (rewardList != null && rewardList.isNotEmpty) {
                final rewards = rewardList.first as List;
                if (rewards.isNotEmpty) {
                  final priorityFeeHex = rewards[1] as String;
                  priorityFee = BigInt.parse(priorityFeeHex.substring(2), radix: 16);
                }
              }
            }
          }
        } catch (_) {
          // EIP-1559 not supported on this network
        }

        if (mounted) {
          setState(() {
            _gasData[network.symbol] = NetworkGasData(
              gasPrice: gasPriceGwei,
              baseFee: baseFee != null ? baseFee.toDouble() / 1e9 : null,
              priorityFee: priorityFee != null ? priorityFee.toDouble() / 1e9 : null,
              lastUpdated: DateTime.now(),
            );
            // 追加到历史，保持最多 60 条
            final hist = _history.putIfAbsent(network.symbol, () => []);
            hist.add(gasPriceGwei);
            if (hist.length > 60) hist.removeAt(0);
          });
        }
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('Failed to fetch gas for ${network.symbol}: $e');
    }
  }

  void _checkAlerts() {
    final prices = <String, double>{};
    final names = <String, String>{};
    for (final n in _networks) {
      final d = _gasData[n.symbol];
      if (d != null) prices[n.symbol] = d.gasPrice;
      names[n.symbol] = n.name;
    }
    GasAlertService.checkAndNotify(prices, names);
  }

  String _getRpcUrl(String symbol) {
    switch (symbol) {
      case 'ETH':
        return RpcConfig.ethMainnetRpc;
      case 'BNB':
        return RpcConfig.bscMainnetRpc;
      case 'MATIC':
        return RpcConfig.polygonMainnetRpc;
      case 'ARB':
        return RpcConfig.arbitrumMainnetRpc;
      case 'OP':
        return RpcConfig.optimismMainnetRpc;
      case 'AVAX':
        return RpcConfig.avalancheMainnetRpc;
      default:
        return '';
    }
  }

  // ── 提醒配置底部弹窗 ─────────────────────────────────────

  void _showAlertSheet(NetworkConfig network) {
    final existing = _alertConfigs[network.symbol];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AlertConfigSheet(
        network: network,
        existing: existing,
        onSaved: (config) async {
          await GasAlertService.save(config);
          await _loadAlertConfigs();
        },
        onRemoved: () async {
          await GasAlertService.remove(network.symbol);
          await _loadAlertConfigs();
        },
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_gas_tracker,
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              size: ScreenUtil().setWidth(44),
            ),
            tooltip: S.of(context).g_key_gas_alert,
            onPressed: () => _showAlertsOverview(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchAllGasData,
        child: _isLoading ? _buildLoading() : _buildContent(),
      ),
    );
  }

  /// 点击铃铛 → 展示所有网络的提醒列表
  void _showAlertsOverview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AlertsOverviewSheet(
        networks: _networks,
        alertConfigs: _alertConfigs,
        onNetworkTap: (network) {
          Navigator.pop(context);
          _showAlertSheet(network);
        },
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildContent() {
    return ListView(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      children: [
        _buildHeader(),
        SizedBox(height: ScreenUtil().setWidth(24)),
        ..._networks.map((n) => _buildNetworkCard(n)),
        SizedBox(height: ScreenUtil().setWidth(16)),
        _buildFooter(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withAlpha(30),
            AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withAlpha(10),
          ],
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
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
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
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
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

  Widget _buildNetworkCard(NetworkConfig network) {
    final data = _gasData[network.symbol];
    final history = _history[network.symbol] ?? [];
    final hasAlert = _alertConfigs.containsKey(network.symbol) &&
        (_alertConfigs[network.symbol]?.enabled ?? false);

    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(16)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        border: Border.all(
          color: network.color.withAlpha(50),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 网络标题行 ───────────────────────────────
          Row(
            children: [
              Container(
                width: ScreenUtil().setWidth(44),
                height: ScreenUtil().setWidth(44),
                decoration: BoxDecoration(
                  color: network.color.withAlpha(30),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                ),
                child: Center(
                  child: Text(network.icon, style: TextStyle(fontSize: ScreenUtil().setSp(24))),
                ),
              ),
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
                        fontSize: ScreenUtil().setSp(22),
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.itemSubtitleTextColor.name),
                      ),
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
                  color: hasAlert
                      ? network.color
                      : AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemSubtitleTextColor.name),
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(8)),
              _buildNetworkStatus(data?.gasPrice),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),

          // ── Gas 费用数据行 ───────────────────────────
          if (data != null) ...[
            _buildGasRow(
              context,
              S.of(context).g_key_t_17, // Gas Price
              '${data.gasPrice.toStringAsFixed(2)} Gwei',
              network.color,
            ),
            if (data.baseFee != null)
              _buildGasRow(
                context,
                S.of(context).g_key_gas_base_fee,
                '${data.baseFee!.toStringAsFixed(2)} Gwei',
                network.color.withAlpha(180),
              ),
            if (data.priorityFee != null)
              _buildGasRow(
                context,
                S.of(context).g_key_gas_priority_fee,
                '${data.priorityFee!.toStringAsFixed(2)} Gwei',
                network.color.withAlpha(180),
              ),
          ] else
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(8)),
                child: Text(
                  S.of(context).g_key_106,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemSubtitleTextColor.name),
                  ),
                ),
              ),
            ),

          // ── 价格走势 sparkline ───────────────────────
          if (history.length >= 3) ...[
            SizedBox(height: ScreenUtil().setWidth(12)),
            _buildSparkline(history, network),
          ],
        ],
      ),
    );
  }

  Widget _buildSparkline(List<double> history, NetworkConfig network) {
    final minY = history.reduce((a, b) => a < b ? a : b);
    final maxY = history.reduce((a, b) => a > b ? a : b);
    // 添加小边距防止线条被裁剪
    final padding = (maxY - minY) * 0.1 + 0.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.show_chart,
              size: ScreenUtil().setWidth(28),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
            SizedBox(width: ScreenUtil().setWidth(6)),
            Text(
              S.of(context).g_key_gas_price_trend,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemSubtitleTextColor.name),
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

  Widget _buildGasRow(BuildContext context, String label, String value, Color color) {
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

  Widget _buildNetworkStatus(double? gasPrice) {
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

  Widget _buildFooter() {
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

// ══════════════════════════════════════════════════════════
// 提醒概览底部弹窗 — 展示所有网络提醒状态
// ══════════════════════════════════════════════════════════

class _AlertsOverviewSheet extends StatelessWidget {
  final List<NetworkConfig> networks;
  final Map<String, GasAlertConfig> alertConfigs;
  final void Function(NetworkConfig) onNetworkTap;

  const _AlertsOverviewSheet({
    required this.networks,
    required this.alertConfigs,
    required this.onNetworkTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name);
    final mainText =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
    final subtitleText =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(ScreenUtil().setWidth(24))),
      ),
      padding: EdgeInsets.only(
        left: ScreenUtil().setWidth(30),
        right: ScreenUtil().setWidth(30),
        top: ScreenUtil().setWidth(24),
        bottom: ScreenUtil().setWidth(40) +
            MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 拖拽指示条
          Center(
            child: Container(
              width: ScreenUtil().setWidth(80),
              height: ScreenUtil().setWidth(6),
              decoration: BoxDecoration(
                color: subtitleText.withAlpha(60),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(3)),
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(20)),
          Text(
            S.of(context).g_key_gas_alert,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(32),
              fontWeight: FontWeight.bold,
              color: mainText,
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          ...networks.map((n) {
            final config = alertConfigs[n.symbol];
            final hasAlert = config != null && config.enabled;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: ScreenUtil().setWidth(40),
                height: ScreenUtil().setWidth(40),
                decoration: BoxDecoration(
                  color: n.color.withAlpha(30),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
                ),
                child: Center(
                  child: Text(n.icon, style: TextStyle(fontSize: ScreenUtil().setSp(22))),
                ),
              ),
              title: Text(
                n.name,
                style: TextStyle(fontSize: ScreenUtil().setSp(28), color: mainText),
              ),
              subtitle: hasAlert
                  ? Text(
                      '${config.alertBelow ? S.of(context).g_key_gas_alert_below : S.of(context).g_key_gas_alert_above} ${config.threshold.toStringAsFixed(0)} Gwei',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(22),
                        color: n.color,
                      ),
                    )
                  : Text(
                      '—',
                      style: TextStyle(fontSize: ScreenUtil().setSp(22), color: subtitleText),
                    ),
              trailing: Icon(
                hasAlert ? Icons.notifications_active : Icons.notifications_none,
                color: hasAlert ? n.color : subtitleText,
                size: ScreenUtil().setWidth(36),
              ),
              onTap: () => onNetworkTap(n),
            );
          }),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// 单网络提醒配置底部弹窗
// ══════════════════════════════════════════════════════════

class _AlertConfigSheet extends StatefulWidget {
  final NetworkConfig network;
  final GasAlertConfig? existing;
  final Future<void> Function(GasAlertConfig) onSaved;
  final Future<void> Function() onRemoved;

  const _AlertConfigSheet({
    required this.network,
    required this.existing,
    required this.onSaved,
    required this.onRemoved,
  });

  @override
  State<_AlertConfigSheet> createState() => _AlertConfigSheetState();
}

class _AlertConfigSheetState extends State<_AlertConfigSheet> {
  late bool _alertBelow;
  late bool _enabled;
  late TextEditingController _thresholdCtrl;
  String _error = '';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _alertBelow = existing?.alertBelow ?? true;
    _enabled = existing?.enabled ?? true;
    _thresholdCtrl = TextEditingController(
      text: existing?.threshold != null
          ? existing!.threshold.toStringAsFixed(0)
          : '',
    );
  }

  @override
  void dispose() {
    _thresholdCtrl.dispose();
    super.dispose();
  }

  void _validate(String v) {
    final d = double.tryParse(v);
    setState(() {
      if (v.isEmpty || d == null || d <= 0) {
        _error = S.of(context).g_key_t_43; // "Enter a whole number greater than 0."
      } else {
        _error = '';
      }
    });
  }

  Future<void> _save() async {
    _validate(_thresholdCtrl.text);
    if (_error.isNotEmpty) return;
    final threshold = double.parse(_thresholdCtrl.text);
    setState(() => _saving = true);
    final config = GasAlertConfig(
      symbol: widget.network.symbol,
      threshold: threshold,
      alertBelow: _alertBelow,
      enabled: _enabled,
      lastNotifiedMs: widget.existing?.lastNotifiedMs,
    );
    await widget.onSaved(config);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _remove() async {
    setState(() => _saving = true);
    await widget.onRemoved();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name);
    final itemBg =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name);
    final mainText =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
    final subtitleText =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name);
    final blueColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);
    final networkColor = widget.network.color;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(ScreenUtil().setWidth(24))),
      ),
      padding: EdgeInsets.only(
        left: ScreenUtil().setWidth(30),
        right: ScreenUtil().setWidth(30),
        top: ScreenUtil().setWidth(24),
        bottom: ScreenUtil().setWidth(40) +
            MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 拖拽条
            Center(
              child: Container(
                width: ScreenUtil().setWidth(80),
                height: ScreenUtil().setWidth(6),
                decoration: BoxDecoration(
                  color: subtitleText.withAlpha(60),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(3)),
                ),
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(20)),

            // 标题行
            Row(
              children: [
                Container(
                  width: ScreenUtil().setWidth(44),
                  height: ScreenUtil().setWidth(44),
                  decoration: BoxDecoration(
                    color: networkColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                  ),
                  child: Center(
                    child: Text(
                      widget.network.icon,
                      style: TextStyle(fontSize: ScreenUtil().setSp(24)),
                    ),
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(12)),
                Expanded(
                  child: Text(
                    '${widget.network.name} — ${S.of(context).g_key_gas_alert}',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(30),
                      fontWeight: FontWeight.bold,
                      color: mainText,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenUtil().setWidth(24)),

            // 启用开关
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(20),
                vertical: ScreenUtil().setWidth(12),
              ),
              decoration: BoxDecoration(
                color: itemBg,
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(14)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    S.of(context).g_key_gas_alert,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(28),
                      color: mainText,
                    ),
                  ),
                  Switch(
                    value: _enabled,
                    onChanged: (v) => setState(() => _enabled = v),
                    activeThumbColor: blueColor,
                  ),
                ],
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(16)),

            // 方向选择：低于 / 高于
            Container(
              padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
              decoration: BoxDecoration(
                color: itemBg,
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(14)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).g_key_gas_alert_threshold,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(24),
                      color: subtitleText,
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setWidth(12)),
                  Row(
                    children: [
                      Expanded(
                        child: _DirectionButton(
                          label: S.of(context).g_key_gas_alert_below,
                          icon: Icons.arrow_downward,
                          selected: _alertBelow,
                          color: Colors.green,
                          onTap: () => setState(() => _alertBelow = true),
                        ),
                      ),
                      SizedBox(width: ScreenUtil().setWidth(12)),
                      Expanded(
                        child: _DirectionButton(
                          label: S.of(context).g_key_gas_alert_above,
                          icon: Icons.arrow_upward,
                          selected: !_alertBelow,
                          color: Colors.red,
                          onTap: () => setState(() => _alertBelow = false),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ScreenUtil().setWidth(16)),
                  // 阈值输入框
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(16),
                      vertical: ScreenUtil().setWidth(10),
                    ),
                    decoration: BoxDecoration(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.backGroundColor.name),
                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
                      border: Border.all(
                        color: _error.isNotEmpty
                            ? AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.errorTextColor.name)
                            : AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.dividerColor.name),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _thresholdCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(28),
                              color: mainText,
                            ),
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: TextStyle(
                                fontSize: ScreenUtil().setSp(28),
                                color: subtitleText,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: _validate,
                          ),
                        ),
                        Text(
                          'Gwei',
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(24),
                            color: subtitleText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_error.isNotEmpty) ...[
                    SizedBox(height: ScreenUtil().setWidth(6)),
                    Text(
                      _error,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(22),
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.errorTextColor.name),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(24)),

            // 保存按钮
            SizedBox(
              width: double.infinity,
              height: ScreenUtil().setWidth(88),
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: blueColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
                  ),
                  disabledBackgroundColor: blueColor.withAlpha(120),
                ),
                child: _saving
                    ? SizedBox(
                        width: ScreenUtil().setWidth(36),
                        height: ScreenUtil().setWidth(36),
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        S.of(context).g_key_gas_alert_save,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(30),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            // 删除提醒（已存在时显示）
            if (widget.existing != null) ...[
              SizedBox(height: ScreenUtil().setWidth(12)),
              SizedBox(
                width: double.infinity,
                height: ScreenUtil().setWidth(76),
                child: TextButton(
                  onPressed: _saving ? null : _remove,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
                    ),
                  ),
                  child: Text(
                    S.of(context).g_key_113, // "Delete"
                    style: TextStyle(fontSize: ScreenUtil().setSp(28)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── 方向选择按钮 ─────────────────────────────────────────────

class _DirectionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _DirectionButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(14)),
        decoration: BoxDecoration(
          color: selected ? color.withAlpha(30) : Colors.transparent,
          border: Border.all(
            color: selected ? color : AppThemeUtils.getColorByKey(
                context, AppThemeKeys.dividerColor.name),
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: ScreenUtil().setWidth(28),
              color: selected
                  ? color
                  : AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
            SizedBox(width: ScreenUtil().setWidth(6)),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected
                      ? color
                      : AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemSubtitleTextColor.name),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// 数据模型
// ══════════════════════════════════════════════════════════

/// 网络配置（静态常量，页面内使用）
class NetworkConfig {
  final String symbol;
  final String name;
  final String icon;
  final Color color;

  const NetworkConfig({
    required this.symbol,
    required this.name,
    required this.icon,
    required this.color,
  });
}

/// 单次采样的网络 Gas 数据
class NetworkGasData {
  final double gasPrice;
  final double? baseFee;
  final double? priorityFee;
  final DateTime lastUpdated;

  NetworkGasData({
    required this.gasPrice,
    this.baseFee,
    this.priorityFee,
    required this.lastUpdated,
  });
}
