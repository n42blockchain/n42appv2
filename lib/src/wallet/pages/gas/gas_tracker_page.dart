// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:n42appv2/core/config/rpc_config.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';

/// Gas 追踪器页面
///
/// 显示主流网络的当前 Gas 费用状态
class GasTrackerPage extends StatefulWidget {
  const GasTrackerPage({super.key});

  @override
  State<GasTrackerPage> createState() => _GasTrackerPageState();
}

class _GasTrackerPageState extends State<GasTrackerPage> {
  final Map<String, NetworkGasData> _gasData = {};
  bool _isLoading = true;
  Timer? _refreshTimer;

  // 支持的网络列表
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
    _fetchAllGasData();
    // 每 15 秒刷新一次
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _fetchAllGasData();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchAllGasData() async {
    final futures = <Future<void>>[];
    for (final network in _networks) {
      futures.add(_fetchGasForNetwork(network));
    }
    await Future.wait(futures);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchGasForNetwork(NetworkConfig network) async {
    try {
      final rpcUrl = _getRpcUrl(network.symbol);
      if (rpcUrl.isEmpty) return;

      final client = http.Client();
      try {
        // 获取 gas price
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

        // 尝试获取 EIP-1559 费用
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
                  final priorityFeeHex = rewards[1] as String; // 50th percentile
                  priorityFee =
                      BigInt.parse(priorityFeeHex.substring(2), radix: 16);
                }
              }
            }
          }
        } catch (_) {
          // EIP-1559 not supported
        }

        if (mounted) {
          setState(() {
            _gasData[network.symbol] = NetworkGasData(
              gasPrice: gasPriceGwei,
              baseFee: baseFee != null ? baseFee.toDouble() / 1e9 : null,
              priorityFee:
                  priorityFee != null ? priorityFee.toDouble() / 1e9 : null,
              lastUpdated: DateTime.now(),
            );
          });
        }
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('Failed to fetch gas for ${network.symbol}: $e');
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_gas_settings,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchAllGasData,
        child: _isLoading ? _buildLoading() : _buildContent(),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      children: [
        // 标题说明
        _buildHeader(),
        SizedBox(height: ScreenUtil().setWidth(24)),
        // 网络列表
        ..._networks.map((network) => _buildNetworkCard(network)),
        SizedBox(height: ScreenUtil().setWidth(16)),
        // 说明文字
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
            AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
                .withAlpha(30),
            AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
                .withAlpha(10),
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
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainBlueColor.name),
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

  Widget _buildNetworkCard(NetworkConfig network) {
    final data = _gasData[network.symbol];

    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(16)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color:
            AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        border: Border.all(
          color: network.color.withAlpha(50),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 网络信息
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
                  child: Text(
                    network.icon,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(24),
                    ),
                  ),
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
              // 网络状态指示
              _buildNetworkStatus(data?.gasPrice),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          // Gas 费用详情
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
                  S.of(context).g_key_106, // Loading
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemSubtitleTextColor.name),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGasRow(
      BuildContext context, String label, String value, Color color) {
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

/// 网络配置
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

/// 网络 Gas 数据
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
