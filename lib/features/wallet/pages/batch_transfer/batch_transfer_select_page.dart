// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/batch_transfer/batch_transfer_page.dart';
import 'package:n42_wallet/features/wallet/provider/batch_transfer_provider.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';

/// Batch transfer token selection page.
class BatchTransferSelectPage extends ConsumerWidget {
  const BatchTransferSelectPage({super.key});

  static const _evmChains = {
    'ETH',
    'BNB',
    'MATIC',
    'ARB',
    'OP',
    'AVAX',
    'FTM',
    'CRO',
    'CELO',
  };

  static const _chainColors = {
    'ETH': Color(0xFF627EEA),
    'BNB': Color(0xFFF3BA2F),
    'MATIC': Color(0xFF8247E5),
    'ARB': Color(0xFF28A0F0),
    'OP': Color(0xFFFF0420),
    'AVAX': Color(0xFFEF4444),
    'FTM': Color(0xFF1E5EFF),
    'CRO': Color(0xFF002D74),
    'CELO': Color(0xFF35D07F),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waProvider = ref.watch(wapBridgeProvider);
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_batch_title),
      body: _buildBody(context, waProvider),
    );
  }

  Widget _buildBody(BuildContext context, dynamic waProvider) {
    final supportedCoins = waProvider.coinList.where((coin) {
      final chainSymbol = coin.coin['symbol'] ?? '';
      return _evmChains.contains((chainSymbol as String).toUpperCase());
    }).toList();

    if (supportedCoins.isEmpty) return _buildEmptyState(context);

    return ListView(
      padding: EdgeInsets.all(AppSpacing.space6),
      children: [
        _buildInfoCard(context),
        SizedBox(height: AppSpacing.space6),
        Text(
          S.of(context).g_key_batch_select_token,
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColorTokens.of(context).textPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.space4),
        ...supportedCoins.map((coin) => _buildCoinItem(context, coin)),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final subtitleText = AppColorTokens.of(context).textSubtitle;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.space8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.send_rounded,
              size: ScreenUtil().setWidth(80),
              color: subtitleText,
            ),
            SizedBox(height: AppSpacing.space4),
            Text(
              S.of(context).g_key_batch_no_supported,
              style: AppTypography.body.copyWith(color: subtitleText),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.space2),
            Text(
              S.of(context).g_key_batch_evm_only,
              style: AppTypography.caption.copyWith(color: subtitleText),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00BCD4).withAlpha(30),
            const Color(0xFF00BCD4).withAlpha(10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.brMd,
      ),
      child: Row(
        children: [
          Icon(
            Icons.send_rounded,
            size: ScreenUtil().setWidth(48),
            color: const Color(0xFF00BCD4),
          ),
          SizedBox(width: AppSpacing.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).g_key_batch_title,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColorTokens.of(context).textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.space2),
                Text(
                  S.of(context).g_key_batch_send_multiple,
                  style: AppTypography.caption.copyWith(
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

  Widget _buildCoinItem(BuildContext context, CoinModel coin) {
    final chainSymbol = (coin.coin['symbol'] ?? '') as String;
    final name = (coin.coin['name'] ?? chainSymbol) as String;
    final decimals = (coin.coin['decimals'] ?? 18) as int;
    final chainColor =
        _chainColors[chainSymbol.toUpperCase()] ?? const Color(0xFF6B7280);
    final mainText = AppColorTokens.of(context).textPrimary;
    final subtitleText = AppColorTokens.of(context).textSubtitle;

    return GestureDetector(
      onTap: () => _navigateToBatchTransfer(context, coin),
      child: Container(
        margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
        padding: EdgeInsets.all(AppSpacing.space4),
        decoration: BoxDecoration(
          color: AppColorTokens.of(context).bgSurface,
          borderRadius: AppRadius.brMd,
        ),
        child: Row(
          children: [
            Container(
              width: ScreenUtil().setWidth(48),
              height: ScreenUtil().setWidth(48),
              decoration: BoxDecoration(
                color: chainColor.withAlpha(30),
                borderRadius: AppRadius.brLg,
              ),
              child: Center(
                child: Text(
                  chainSymbol.isNotEmpty ? chainSymbol[0] : '?',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: chainColor,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.space4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: mainText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    chainSymbol,
                    style: AppTypography.caption.copyWith(color: subtitleText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatBalance(coin.balance, decimals),
                  style: AppTypography.bodySm.copyWith(
                    fontWeight: FontWeight.w500,
                    color: mainText,
                  ),
                ),
                Text(
                  chainSymbol,
                  style: AppTypography.caption.copyWith(color: subtitleText),
                ),
              ],
            ),
            SizedBox(width: AppSpacing.space2),
            Icon(Icons.chevron_right, color: subtitleText),
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
      final fracStr = fracPart
          .toString()
          .padLeft(decimals, '0')
          .substring(0, fracLen);
      return '$intPart.$fracStr';
    } catch (_) {
      return '0.0000';
    }
  }

  void _navigateToBatchTransfer(BuildContext context, CoinModel coin) {
    final chainSymbol = (coin.coin['symbol'] ?? '') as String;
    final config = chainUrlMap[chainSymbol];
    final baseInfo = (config?['baseInfo'] as Map<String, dynamic>?) ?? {};
    final address = coin.address?.toString() ?? '';
    final decimals = (coin.coin['decimals'] ?? 18) as int;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BatchTransferPage(
          chainSymbol: chainSymbol,
          rpcUrl: baseInfo['service'] as String? ?? '',
          chainId: baseInfo['chainId'] as int? ?? 1,
          fromAddress: address,
          tokenSymbol: chainSymbol,
          decimals: decimals,
          balance: coin.balance,
          batchTransferProvider: BatchTransferProvider(),
        ),
      ),
    );
  }
}
