// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/bridge/models/bridge_models.dart';
import 'package:n42_wallet/features/bridge/provider/bridge_provider.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// 跨链桥历史记录页面
///
/// 功能：
/// - 下拉刷新轮询 pending/inProgress 交易
/// - 点击交易哈希跳转区块链浏览器
/// - 状态 badge 带动画旋转（进行中）
class BridgeHistoryPage extends StatefulWidget {
  final BridgeProvider provider;
  const BridgeHistoryPage({super.key, required this.provider});

  @override
  State<BridgeHistoryPage> createState() => _BridgeHistoryPageState();
}

class _BridgeHistoryPageState extends State<BridgeHistoryPage> {
  bool _refreshing = false;

  Future<void> _onRefresh() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    await widget.provider.refreshPendingTransactions();
    if (mounted) setState(() => _refreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_bridge_history,
      ),
      body: ListenableBuilder(
        listenable: widget.provider,
        builder: (context, _) {
          final transactions = widget.provider.transactions;

          if (transactions.isEmpty) {
            return _buildEmpty(context);
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                return _buildTransactionCard(context, transactions[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: ScreenUtil().setWidth(80),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemSubtitleTextColor.name),
                ),
                SizedBox(height: ScreenUtil().setWidth(20)),
                Text(
                  S.of(context).g_key_132,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(30),
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

  Widget _buildTransactionCard(
    BuildContext context,
    BridgeTransaction tx,
  ) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 状态 + 时间
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusBadge(context, tx.status),
              Text(
                dateFormat.format(tx.createdAt),
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemSubtitleTextColor.name),
                ),
              ),
            ],
          ),

          SizedBox(height: ScreenUtil().setWidth(16)),

          // 源 → 目标
          _buildTransferRow(context, tx),

          SizedBox(height: ScreenUtil().setWidth(16)),

          // 桥接协议
          if (tx.bridgeTool != null && tx.bridgeTool!.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.link,
                  size: ScreenUtil().setWidth(28),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemSubtitleTextColor.name),
                ),
                SizedBox(width: ScreenUtil().setWidth(6)),
                Text(
                  tx.bridgeTool!,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemSubtitleTextColor.name),
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenUtil().setWidth(10)),
          ],

          // 源链 tx hash（可点击跳转浏览器）
          _buildTxHashRow(
            context,
            label: 'Tx',
            hash: tx.txHash,
            chainId: tx.fromChainId,
          ),

          // 目标链 tx hash（完成后才有）
          if (tx.destinationTxHash != null &&
              tx.destinationTxHash!.isNotEmpty) ...[
            SizedBox(height: ScreenUtil().setWidth(8)),
            _buildTxHashRow(
              context,
              label: 'Dest',
              hash: tx.destinationTxHash!,
              chainId: tx.toChainId,
            ),
          ],

          // 进行中时显示手动刷新按钮
          if (tx.status == BridgeTransactionStatus.pending ||
              tx.status == BridgeTransactionStatus.inProgress) ...[
            SizedBox(height: ScreenUtil().setWidth(12)),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () => widget.provider.checkTransactionStatus(tx),
                borderRadius:
                    BorderRadius.circular(ScreenUtil().setWidth(8)),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(16),
                    vertical: ScreenUtil().setWidth(8),
                  ),
                  decoration: BoxDecoration(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainBlueColor.name),
                    borderRadius:
                        BorderRadius.circular(ScreenUtil().setWidth(8)),
                  ),
                  child: Text(
                    S.of(context).g_key_bridge_refresh,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(22),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransferRow(BuildContext context, BridgeTransaction tx) {
    return Row(
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
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemSubtitleTextColor.name),
                ),
              ),
              SizedBox(height: ScreenUtil().setWidth(4)),
              Text(
                '${tx.fromAmount} ${tx.fromToken.symbol}',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  fontWeight: FontWeight.bold,
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                ),
              ),
            ],
          ),
        ),

        // 箭头
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16)),
          child: Icon(
            Icons.arrow_forward,
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainBlueColor.name),
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
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemSubtitleTextColor.name),
                ),
              ),
              SizedBox(height: ScreenUtil().setWidth(4)),
              Text(
                '${tx.toAmount} ${tx.toToken.symbol}',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  fontWeight: FontWeight.bold,
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 可点击的交易哈希行，点击跳转区块链浏览器
  Widget _buildTxHashRow(
    BuildContext context, {
    required String label,
    required String hash,
    required int chainId,
  }) {
    return GestureDetector(
      onTap: () => _openExplorer(chainId, hash),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
          ),
          Expanded(
            child: Text(
              _shortenHash(hash),
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
                decoration: TextDecoration.underline,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(
            Icons.open_in_new,
            size: ScreenUtil().setWidth(26),
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainBlueColor.name),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(
      BuildContext context, BridgeTransactionStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case BridgeTransactionStatus.pending:
        color = Colors.orange;
        text = S.of(context).g_key_bridge_status_pending;
        icon = Icons.hourglass_empty;
      case BridgeTransactionStatus.inProgress:
        color = Colors.blue;
        text = S.of(context).g_key_bridge_status_in_progress;
        icon = Icons.sync;
      case BridgeTransactionStatus.completed:
        color = Colors.green;
        text = S.of(context).g_key_bridge_status_completed;
        icon = Icons.check_circle;
      case BridgeTransactionStatus.failed:
        color = Colors.red;
        text = S.of(context).g_key_bridge_status_failed;
        icon = Icons.error;
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
          // 进行中时旋转 icon
          status == BridgeTransactionStatus.inProgress
              ? _SpinningIcon(icon: icon, color: color,
                  size: ScreenUtil().setWidth(24))
              : Icon(icon, color: color, size: ScreenUtil().setWidth(24)),
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

  // ─── 工具方法 ─────────────────────────────────────────────────────────────

  String _shortenHash(String hash) {
    if (hash.length <= 16) return hash;
    return '${hash.substring(0, 8)}...${hash.substring(hash.length - 6)}';
  }

  /// 根据 chainId 返回区块链浏览器 URL
  String _explorerUrl(int chainId, String txHash) {
    final base = switch (chainId) {
      BridgeChainIds.ethereum =>
        'https://etherscan.io/tx',
      BridgeChainIds.bsc =>
        'https://bscscan.com/tx',
      BridgeChainIds.polygon =>
        'https://polygonscan.com/tx',
      BridgeChainIds.arbitrum =>
        'https://arbiscan.io/tx',
      BridgeChainIds.optimism =>
        'https://optimistic.etherscan.io/tx',
      BridgeChainIds.avalanche =>
        'https://snowtrace.io/tx',
      BridgeChainIds.base =>
        'https://basescan.org/tx',
      BridgeChainIds.linea =>
        'https://lineascan.build/tx',
      BridgeChainIds.scroll =>
        'https://scrollscan.com/tx',
      BridgeChainIds.zksync =>
        'https://explorer.zksync.io/tx',
      _ => 'https://etherscan.io/tx',
    };
    return '$base/$txHash';
  }

  Future<void> _openExplorer(int chainId, String txHash) async {
    if (txHash.isEmpty) return;
    final uri = Uri.parse(_explorerUrl(chainId, txHash));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// ─── 旋转 Icon（进行中状态）──────────────────────────────────────────────────

class _SpinningIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  const _SpinningIcon(
      {required this.icon, required this.color, required this.size});

  @override
  State<_SpinningIcon> createState() => _SpinningIconState();
}

class _SpinningIconState extends State<_SpinningIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _ctrl,
      child: Icon(widget.icon, color: widget.color, size: widget.size),
    );
  }
}
