// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/src/wallet/models/coin_model.dart';
import 'package:n42_wallet/src/wallet/pages/batch_transfer/batch_transfer_page.dart';
import 'package:n42_wallet/src/wallet/provider/batch_transfer_provider.dart';
import 'package:n42_wallet/src/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/src/widgets/app_bar_widget.dart';

/// 批量转账代币选择页面
class BatchTransferSelectPage extends ConsumerWidget {
  const BatchTransferSelectPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waProvider = ref.watch(wapBridgeProvider);
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_batch_title,
      ),
      body: Builder(builder: (context) {
          // 过滤出支持批量转账的代币（EVM 链）
          final supportedCoins = waProvider.coinList.where((coin) {
            final chainSymbol = coin.coin['symbol'] ?? '';
            // 只支持 EVM 兼容链
            return _isEvmChain(chainSymbol);
          }).toList();

          if (supportedCoins.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView(
            padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
            children: [
              // 说明卡片
              _buildInfoCard(context),
              SizedBox(height: ScreenUtil().setWidth(24)),
              // 代币列表
              Text(
                S.of(context).g_key_batch_select_token,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  fontWeight: FontWeight.bold,
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                ),
              ),
              SizedBox(height: ScreenUtil().setWidth(16)),
              ...supportedCoins.map((coin) => _buildCoinItem(context, coin)),
            ],
          );
        }),
    );
  }

  bool _isEvmChain(String chainSymbol) {
    const evmChains = [
      'ETH', 'BNB', 'MATIC', 'ARB', 'OP', 'AVAX', 'FTM', 'CRO', 'CELO'
    ];
    return evmChains.contains(chainSymbol.toUpperCase());
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(32)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.send_rounded,
              size: ScreenUtil().setWidth(80),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
            SizedBox(height: ScreenUtil().setWidth(16)),
            Text(
              S.of(context).g_key_batch_no_supported,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemSubtitleTextColor.name),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ScreenUtil().setWidth(8)),
            Text(
              S.of(context).g_key_batch_evm_only,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemSubtitleTextColor.name),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00BCD4).withAlpha(30),
            const Color(0xFF00BCD4).withAlpha(10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.send_rounded,
            size: ScreenUtil().setWidth(48),
            color: const Color(0xFF00BCD4),
          ),
          SizedBox(width: ScreenUtil().setWidth(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).g_key_batch_title,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    fontWeight: FontWeight.bold,
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(4)),
                Text(
                  S.of(context).g_key_batch_send_multiple,
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

  Widget _buildCoinItem(BuildContext context, CoinModel coin) {
    final chainSymbol = (coin.coin['symbol'] ?? '') as String;
    final name = (coin.coin['name'] ?? chainSymbol) as String;
    final balance = coin.balance;
    final decimals = (coin.coin['decimals'] ?? 18) as int;

    return GestureDetector(
      onTap: () => _navigateToBatchTransfer(context, coin),
      child: Container(
        margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
        padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        ),
        child: Row(
          children: [
            // 代币图标
            Container(
              width: ScreenUtil().setWidth(48),
              height: ScreenUtil().setWidth(48),
              decoration: BoxDecoration(
                color: _getChainColor(chainSymbol).withAlpha(30),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(24)),
              ),
              child: Center(
                child: Text(
                  chainSymbol.isNotEmpty ? chainSymbol[0] : '?',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    fontWeight: FontWeight.bold,
                    color: _getChainColor(chainSymbol),
                  ),
                ),
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(12)),
            // 代币信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(28),
                      fontWeight: FontWeight.w600,
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    chainSymbol,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(22),
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemSubtitleTextColor.name),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // 余额
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatBalance(balance, decimals),
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    fontWeight: FontWeight.w500,
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
                  ),
                ),
                Text(
                  chainSymbol,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(22),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemSubtitleTextColor.name),
                  ),
                ),
              ],
            ),
            SizedBox(width: ScreenUtil().setWidth(8)),
            Icon(
              Icons.chevron_right,
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
          ],
        ),
      ),
    );
  }

  String _formatBalance(BigInt balance, int decimals) {
    try {
      final divisor = BigInt.from(10).pow(decimals);
      final intPart = balance ~/ divisor;
      final fracPart = balance.remainder(divisor);
      final fracLen = decimals > 4 ? 4 : decimals;
      final fracStr = fracPart.toString().padLeft(decimals, '0').substring(0, fracLen);
      return '$intPart.$fracStr';
    } catch (e) {
      return '0.0000';
    }
  }

  void _navigateToBatchTransfer(BuildContext context, CoinModel coin) {
    final chainSymbol = (coin.coin['symbol'] ?? '') as String;
    final rpcUrl = _getRpcUrl(chainSymbol);
    final chainId = _getChainId(chainSymbol);
    final address = coin.address?.toString() ?? '';
    final decimals = (coin.coin['decimals'] ?? 18) as int;
    final balance = coin.balance;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BatchTransferPage(
          chainSymbol: chainSymbol,
          rpcUrl: rpcUrl,
          chainId: chainId,
          fromAddress: address,
          tokenSymbol: chainSymbol,
          decimals: decimals,
          balance: balance,
          batchTransferProvider: BatchTransferProvider(),
        ),
      ),
    );
  }

  Color _getChainColor(String chainSymbol) {
    const chainColors = {
      'ETH': Color(0xFF627EEA),
      'BNB': Color(0xFFF3BA2F),
      'MATIC': Color(0xFF8247E5),
      'ARB': Color(0xFF28A0F0),
      'OP': Color(0xFFFF0420),
      'AVAX': Color(0xFFE84142),
      'FTM': Color(0xFF1969FF),
      'CRO': Color(0xFF002D74),
      'CELO': Color(0xFF35D07F),
    };
    return chainColors[chainSymbol.toUpperCase()] ?? const Color(0xFF607D8B);
  }

  String _getRpcUrl(String chainSymbol) {
    final config = chainUrlMap[chainSymbol];
    if (config != null && config['baseInfo'] != null) {
      return config['baseInfo']['service'] ?? '';
    }
    return '';
  }

  int _getChainId(String chainSymbol) {
    final config = chainUrlMap[chainSymbol];
    if (config != null && config['baseInfo'] != null) {
      return config['baseInfo']['chainId'] ?? 1;
    }
    return 1;
  }
}
