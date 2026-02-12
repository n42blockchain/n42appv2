// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/bridge/models/bridge_models.dart';
import 'package:n42appv2/src/bridge/provider/bridge_provider.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

/// 跨链桥历史记录页面
class BridgeHistoryPage extends StatelessWidget {
  const BridgeHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: 'Bridge History', // S.of(context).g_key_bridge_history
      ),
      body: Consumer<BridgeProvider>(
        builder: (context, provider, _) {
          final transactions = provider.transactions;

          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: ScreenUtil().setWidth(80),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                  ),
                  SizedBox(height: ScreenUtil().setWidth(20)),
                  Text(
                    S.of(context).g_key_132, // No data
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(30),
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final tx = transactions[index];
              return _buildTransactionCard(context, provider, tx);
            },
          );
        },
      ),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    BridgeProvider provider,
    BridgeTransaction tx,
  ) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 状态和时间
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusBadge(context, tx.status),
              Text(
                dateFormat.format(tx.createdAt),
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                ),
              ),
            ],
          ),

          SizedBox(height: ScreenUtil().setWidth(16)),

          // 转账信息
          Row(
            children: [
              // 源链
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      BridgeChainIds.getChainName(tx.fromChainId),
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(24),
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(4)),
                    Text(
                      '${tx.fromAmount} ${tx.fromToken.symbol}',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(28),
                        fontWeight: FontWeight.bold,
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                      ),
                    ),
                  ],
                ),
              ),

              // 箭头
              Padding(
                padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16)),
                child: Icon(
                  Icons.arrow_forward,
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                  size: ScreenUtil().setWidth(32),
                ),
              ),

              // 目标链
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      BridgeChainIds.getChainName(tx.toChainId),
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(24),
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(4)),
                    Text(
                      '${tx.toAmount} ${tx.toToken.symbol}',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(28),
                        fontWeight: FontWeight.bold,
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: ScreenUtil().setWidth(16)),

          // 交易哈希
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tx: ${_shortenHash(tx.txHash)}',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                  ),
                ),
              ),
              if (tx.status == BridgeTransactionStatus.pending ||
                  tx.status == BridgeTransactionStatus.inProgress)
                InkWell(
                  onTap: () => provider.checkTransactionStatus(tx),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(16),
                      vertical: ScreenUtil().setWidth(8),
                    ),
                    decoration: BoxDecoration(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                    ),
                    child: Text(
                      'Refresh', // S.of(context).g_key_bridge_refresh
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(22),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // 目标链交易哈希
          if (tx.destinationTxHash != null && tx.destinationTxHash!.isNotEmpty) ...[
            SizedBox(height: ScreenUtil().setWidth(8)),
            Text(
              'Dest Tx: ${_shortenHash(tx.destinationTxHash!)}',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, BridgeTransactionStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case BridgeTransactionStatus.pending:
        color = Colors.orange;
        text = 'Pending';
        icon = Icons.hourglass_empty;
        break;
      case BridgeTransactionStatus.inProgress:
        color = Colors.blue;
        text = 'In Progress';
        icon = Icons.sync;
        break;
      case BridgeTransactionStatus.completed:
        color = Colors.green;
        text = 'Completed';
        icon = Icons.check_circle;
        break;
      case BridgeTransactionStatus.failed:
        color = Colors.red;
        text = 'Failed';
        icon = Icons.error;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(12),
        vertical: ScreenUtil().setWidth(6),
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: ScreenUtil().setWidth(24)),
          SizedBox(width: ScreenUtil().setWidth(6)),
          Text(
            text,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _shortenHash(String hash) {
    if (hash.length <= 16) return hash;
    return '${hash.substring(0, 8)}...${hash.substring(hash.length - 6)}';
  }
}
