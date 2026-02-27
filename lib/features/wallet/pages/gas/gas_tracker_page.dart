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
import 'package:n42_wallet/features/wallet/services/gas_alert_service.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

part 'gas_tracker_models.dart';
part 'gas_tracker_card.dart';
part 'gas_tracker_widgets.dart';

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
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _fetchAllGasData(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAlertConfigs() async {
    final configs = await GasAlertService.loadAll();
    if (mounted) setState(() => _alertConfigs = configs);
  }

  Future<void> _fetchAllGasData() async {
    await Future.wait(_networks.map(_fetchGasForNetwork));
    if (mounted) setState(() => _isLoading = false);
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
              body: jsonEncode(
                  {'jsonrpc': '2.0', 'method': 'eth_gasPrice', 'params': [], 'id': 1}),
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
            final result = jsonDecode(feeHistoryResponse.body)['result'];
            if (result != null) {
              final baseFeeList = result['baseFeePerGas'] as List?;
              if (baseFeeList != null && baseFeeList.isNotEmpty) {
                baseFee = BigInt.parse(
                    (baseFeeList.last as String).substring(2),
                    radix: 16);
              }
              final rewardList = result['reward'] as List?;
              if (rewardList != null && rewardList.isNotEmpty) {
                final rewards = rewardList.first as List;
                if (rewards.isNotEmpty) {
                  priorityFee = BigInt.parse(
                      (rewards[1] as String).substring(2),
                      radix: 16);
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
            onPressed: _showAlertsOverview,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchAllGasData,
        child: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      children: [
        buildHeader(),
        SizedBox(height: ScreenUtil().setWidth(24)),
        ..._networks.map(buildNetworkCard),
        SizedBox(height: ScreenUtil().setWidth(16)),
        buildFooter(),
      ],
    );
  }
}
