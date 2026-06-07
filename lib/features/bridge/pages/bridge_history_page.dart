// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/bridge/models/bridge_models.dart';
import 'package:n42_wallet/features/bridge/provider/bridge_provider.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
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
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm');
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
      appBar: AppBarWidget(text: S.of(context).g_key_bridge_history),
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
    final subtitleColor = AppColorTokens.of(context).textSubtitle;
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
                  color: subtitleColor,
                ),
                SizedBox(height: ScreenUtil().setWidth(20)),
                Text(
                  S.of(context).g_key_132,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(30),
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, BridgeTransaction tx) {
    final subtitleColor = AppColorTokens.of(context).textSubtitle;
    final blueColor = AppColorTokens.of(context).brand;
    final hasBridgeTool = tx.bridgeTool?.isNotEmpty == true;
    final hasDestTx = tx.destinationTxHash?.isNotEmpty == true;
    final isPending =
        tx.status == BridgeTransactionStatus.pending ||
        tx.status == BridgeTransactionStatus.inProgress;

    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(20)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgSurface,
        borderRadius: AppRadius.brMd,
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
                _dateFormat.format(tx.createdAt),
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  color: subtitleColor,
                ),
              ),
            ],
          ),

          SizedBox(height: ScreenUtil().setWidth(16)),

          // 源 → 目标
          _buildTransferRow(context, tx),

          SizedBox(height: ScreenUtil().setWidth(16)),

          // 桥接协议
          if (hasBridgeTool) ...[
            Row(
              children: [
                Icon(
                  Icons.link,
                  size: ScreenUtil().setWidth(28),
                  color: subtitleColor,
                ),
                SizedBox(width: ScreenUtil().setWidth(6)),
                Text(
                  tx.bridgeTool!,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    color: subtitleColor,
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
          if (hasDestTx) ...[
            SizedBox(height: ScreenUtil().setWidth(8)),
            _buildTxHashRow(
              context,
              label: 'Dest',
              hash: tx.destinationTxHash!,
              chainId: tx.toChainId,
            ),
          ],

          // 进行中时显示手动刷新按钮
          if (isPending) ...[
            SizedBox(height: ScreenUtil().setWidth(12)),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () => widget.provider.checkTransactionStatus(tx),
                borderRadius: AppRadius.brSm,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(16),
                    vertical: ScreenUtil().setWidth(8),
                  ),
                  decoration: BoxDecoration(
                    color: blueColor,
                    borderRadius: AppRadius.brSm,
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
          child: _buildChainColumn(
            context,
            chainName: BridgeChainIds.getChainName(tx.fromChainId),
            amountText: '${tx.fromAmount} ${tx.fromToken.symbol}',
            alignment: CrossAxisAlignment.start,
          ),
        ),

        // 箭头
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16)),
          child: Icon(
            Icons.arrow_forward,
            color: AppColorTokens.of(context).brand,
            size: ScreenUtil().setWidth(32),
          ),
        ),

        // 目标链
        Expanded(
          child: _buildChainColumn(
            context,
            chainName: BridgeChainIds.getChainName(tx.toChainId),
            amountText: '${tx.toAmount} ${tx.toToken.symbol}',
            alignment: CrossAxisAlignment.end,
          ),
        ),
      ],
    );
  }

  /// 链信息列（链名 + 金额），源链/目标链共用
  Widget _buildChainColumn(
    BuildContext context, {
    required String chainName,
    required String amountText,
    required CrossAxisAlignment alignment,
  }) {
    final subtitleColor = AppColorTokens.of(context).textSubtitle;
    final mainColor = AppColorTokens.of(context).textPrimary;
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          chainName,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(24),
            color: subtitleColor,
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(4)),
        Text(
          amountText,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(28),
            fontWeight: FontWeight.bold,
            color: mainColor,
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
    final subtitleColor = AppColorTokens.of(context).textSubtitle;
    final blueColor = AppColorTokens.of(context).brand;
    return GestureDetector(
      onTap: () => _openExplorer(chainId, hash),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: subtitleColor,
            ),
          ),
          Expanded(
            child: Text(
              _shortenHash(hash),
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                color: blueColor,
                decoration: TextDecoration.underline,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(
            Icons.open_in_new,
            size: ScreenUtil().setWidth(26),
            color: blueColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(
    BuildContext context,
    BridgeTransactionStatus status,
  ) {
    final s = S.of(context);
    final (AppBadgeTone tone, String text, IconData icon) = switch (status) {
      BridgeTransactionStatus.pending => (
        AppBadgeTone.warning,
        s.g_key_bridge_status_pending,
        Icons.hourglass_empty,
      ),
      BridgeTransactionStatus.inProgress => (
        AppBadgeTone.info,
        s.g_key_bridge_status_in_progress,
        Icons.sync,
      ),
      BridgeTransactionStatus.completed => (
        AppBadgeTone.success,
        s.g_key_bridge_status_completed,
        Icons.check_circle,
      ),
      BridgeTransactionStatus.failed => (
        AppBadgeTone.danger,
        s.g_key_bridge_status_failed,
        Icons.error,
      ),
    };

    if (status == BridgeTransactionStatus.inProgress) {
      return AppBadge(
        label: text,
        tone: tone,
        leading: _SpinningIcon(
          icon: icon,
          color: AppColorTokens.of(context).info,
          size: 14,
        ),
      );
    }
    return AppBadge(label: text, tone: tone, icon: icon);
  }

  // ─── 工具方法 ─────────────────────────────────────────────────────────────

  String _shortenHash(String hash) {
    if (hash.length <= 16) return hash;
    return '${hash.substring(0, 8)}...${hash.substring(hash.length - 6)}';
  }

  /// 根据 chainId 返回区块链浏览器 URL
  String _explorerUrl(int chainId, String txHash) {
    final base = switch (chainId) {
      BridgeChainIds.ethereum => 'https://etherscan.io/tx',
      BridgeChainIds.bsc => 'https://bscscan.com/tx',
      BridgeChainIds.polygon => 'https://polygonscan.com/tx',
      BridgeChainIds.arbitrum => 'https://arbiscan.io/tx',
      BridgeChainIds.optimism => 'https://optimistic.etherscan.io/tx',
      BridgeChainIds.avalanche => 'https://snowtrace.io/tx',
      BridgeChainIds.base => 'https://basescan.org/tx',
      BridgeChainIds.linea => 'https://lineascan.build/tx',
      BridgeChainIds.scroll => 'https://scrollscan.com/tx',
      BridgeChainIds.zksync => 'https://explorer.zksync.io/tx',
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
  const _SpinningIcon({
    required this.icon,
    required this.color,
    required this.size,
  });

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
