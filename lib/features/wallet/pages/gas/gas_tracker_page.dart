// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:n42_wallet/core/config/rpc_config.dart';
import 'package:n42_wallet/features/wallet/pages/gas/gas_alert_sheet_utils.dart';
import 'package:n42_wallet/features/wallet/api/tokenview_enhanced_api.dart';
import 'package:n42_wallet/features/wallet/services/gas_alert_service.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

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

  /// TokenView Gas 预测（下一区块）
  final Map<String, GasNextBlockPrediction> _gasPredictions = {};

  /// TokenView Mempool 拥塞统计
  final Map<String, MempoolCongestion> _mempoolData = {};

  Map<String, GasAlertConfig> _alertConfigs = {};
  bool _isLoading = true;
  Timer? _refreshTimer;
  int _refreshGeneration = 0;

  static const _tokenViewApi = TokenViewEnhancedApi();

  static const List<NetworkConfig> _networks = [
    NetworkConfig(
      symbol: 'ETH',
      name: 'Ethereum',
      icon: '⟠',
      color: Color(0xFF627EEA),
    ),
    NetworkConfig(
      symbol: 'BNB',
      name: 'BNB Chain',
      icon: '◈',
      color: Color(0xFFF3BA2F),
    ),
    NetworkConfig(
      symbol: 'MATIC',
      name: 'Polygon',
      icon: '⬡',
      color: Color(0xFF8247E5),
    ),
    NetworkConfig(
      symbol: 'ARB',
      name: 'Arbitrum',
      icon: '◇',
      color: Color(0xFF28A0F0),
    ),
    NetworkConfig(
      symbol: 'OP',
      name: 'Optimism',
      icon: '◎',
      color: Color(0xFFFF0420),
    ),
    NetworkConfig(
      symbol: 'AVAX',
      name: 'Avalanche',
      icon: '▲',
      color: Color(0xFFE84142),
    ),
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
    try {
      final configs = await GasAlertService.loadAll();
      if (mounted) setState(() => _alertConfigs = configs);
    } catch (e) {
      AppLogger.w('GasTracker', 'failed to load gas alert configs: $e');
    }
  }

  Future<void> _fetchAllGasData() async {
    final generation = ++_refreshGeneration;
    await Future.wait([
      ..._networks.map((network) => _fetchGasForNetwork(network, generation)),
      _fetchTokenViewData('eth', generation),
      _fetchTokenViewData('bnb', generation),
    ]);
    if (!mounted || generation != _refreshGeneration) return;
    setState(() => _isLoading = false);
    // 每次刷新后检查提醒阈值
    _checkAlerts();
  }

  Future<void> _fetchTokenViewData(String chain, int generation) async {
    try {
      final results = await Future.wait([
        _tokenViewApi.getGasNextBlock(chain),
        _tokenViewApi.getPendingStat(chain),
      ]);
      if (!mounted || generation != _refreshGeneration) return;
      setState(() {
        final symbol = _chainToSymbol(chain);
        if (results[0] != null) {
          _gasPredictions[symbol] = results[0] as GasNextBlockPrediction;
        }
        if (results[1] != null) {
          _mempoolData[symbol] = results[1] as MempoolCongestion;
        }
      });
    } catch (e) {
      AppLogger.w(
        'GasTracker',
        'failed to fetch TokenView data for $chain: $e',
      );
    }
  }

  static String _chainToSymbol(String chain) => switch (chain) {
    'eth' => 'ETH',
    'bnb' => 'BNB',
    _ => chain.toUpperCase(),
  };

  Future<void> _fetchGasForNetwork(
    NetworkConfig network,
    int generation,
  ) async {
    try {
      final rpcUrl = _getRpcUrl(network.symbol);
      if (rpcUrl.isEmpty) return;

      final client = http.Client();
      try {
        final gasPriceHex = await _rpcCall(
          client,
          rpcUrl,
          'eth_gasPrice',
          [],
          1,
        );
        if (gasPriceHex == null) return;

        final gasPrice = BigInt.parse(gasPriceHex.substring(2), radix: 16);
        final gasPriceGwei = gasPrice.toDouble() / 1e9;

        final eip1559 = await _fetchEip1559(client, rpcUrl);

        if (mounted && generation == _refreshGeneration) {
          setState(() {
            _gasData[network.symbol] = NetworkGasData(
              gasPrice: gasPriceGwei,
              baseFee: eip1559.$1 != null ? eip1559.$1!.toDouble() / 1e9 : null,
              priorityFee: eip1559.$2 != null
                  ? eip1559.$2!.toDouble() / 1e9
                  : null,
              lastUpdated: DateTime.now(),
            );
            final hist = _history.putIfAbsent(network.symbol, () => []);
            hist.add(gasPriceGwei);
            if (hist.length > 60) hist.removeAt(0);
          });
        }
      } finally {
        client.close();
      }
    } catch (e) {
      AppLogger.w(
        'GasTracker',
        'failed to fetch gas for ${network.symbol}: $e',
      );
    }
  }

  /// Makes a JSON-RPC call and returns the 'result' string, or null on failure.
  Future<String?> _rpcCall(
    http.Client client,
    String url,
    String method,
    List<dynamic> params,
    int id,
  ) async {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'jsonrpc': '2.0',
            'method': method,
            'params': params,
            'id': id,
          }),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) return null;
    return jsonDecode(response.body)['result'] as String?;
  }

  /// Fetches EIP-1559 base fee and priority fee; returns (null, null) if unsupported.
  Future<(BigInt?, BigInt?)> _fetchEip1559(
    http.Client client,
    String rpcUrl,
  ) async {
    try {
      final response = await client
          .post(
            Uri.parse(rpcUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'jsonrpc': '2.0',
              'method': 'eth_feeHistory',
              'params': [
                1,
                'latest',
                [25, 50, 75],
              ],
              'id': 2,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return (null, null);

      final result = jsonDecode(response.body)['result'];
      if (result == null) return (null, null);

      BigInt? baseFee;
      final baseFeeList = result['baseFeePerGas'] as List?;
      if (baseFeeList != null && baseFeeList.isNotEmpty) {
        baseFee = BigInt.parse(
          (baseFeeList.last as String).substring(2),
          radix: 16,
        );
      }

      BigInt? priorityFee;
      final rewardList = result['reward'] as List?;
      if (rewardList != null && rewardList.isNotEmpty) {
        final rewards = rewardList.first as List;
        if (rewards.length > 1) {
          priorityFee = BigInt.parse(
            (rewards[1] as String).substring(2),
            radix: 16,
          );
        }
      }

      return (baseFee, priorityFee);
    } catch (_) {
      return (null, null);
    }
  }

  void _checkAlerts() {
    final prices = {
      for (final n in _networks)
        if (_gasData[n.symbol] != null) n.symbol: _gasData[n.symbol]!.gasPrice,
    };
    final names = {for (final n in _networks) n.symbol: n.name};
    GasAlertService.checkAndNotify(prices, names);
  }

  String _getRpcUrl(String symbol) => switch (symbol) {
    'ETH' => RpcConfig.ethMainnetRpc,
    'BNB' => RpcConfig.bscMainnetRpc,
    'MATIC' => RpcConfig.polygonMainnetRpc,
    'ARB' => RpcConfig.arbitrumMainnetRpc,
    'OP' => RpcConfig.optimismMainnetRpc,
    'AVAX' => RpcConfig.avalancheMainnetRpc,
    _ => '',
  };

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
              color: AppColorTokens.of(context).textPrimary,
              size: ScreenUtil().setWidth(44),
            ),
            tooltip: S.of(context).g_key_gas_alert,
            onPressed: _showAlertsOverview,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchAllGasData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final spacing = ScreenUtil().setWidth(24);
    return ListView(
      padding: EdgeInsets.all(spacing),
      children: [
        buildHeader(),
        SizedBox(height: spacing),
        if (_gasPredictions.isNotEmpty) ...[
          buildGasPredictionCard(),
          SizedBox(height: spacing),
        ],
        ..._networks.map(buildNetworkCard),
        SizedBox(height: AppSpacing.space4),
        buildFooter(),
      ],
    );
  }
}
