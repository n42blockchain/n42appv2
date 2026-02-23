// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/mining/domain/entities/mining_entity.dart';
import 'package:n42_wallet/features/mining/presentation/providers/mining_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/mining_v2/provider/mining_v2_provider.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/detail_refresh_widget.dart';

class MiningNodeDetailPage extends ConsumerStatefulWidget {
  const MiningNodeDetailPage({super.key});

  @override
  ConsumerState<MiningNodeDetailPage> createState() =>
      _MiningNodeDetailPageState();
}

class _MiningNodeDetailPageState extends ConsumerState<MiningNodeDetailPage> {
  @override
  Widget build(BuildContext context) {
    final mpValue = ref.watch(miningBridgeProvider);
    final node = mpValue.fullNodeEntity;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_mining_node_key1,
      ),
      body: SafeArea(
        child: DetailRefreshWidget(
          callback: () async {
            await mpValue.getBeaconValidator();
          },
          childWidget: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(30),
              vertical: ScreenUtil().setWidth(20),
            ),
            child: node == null
                ? _buildEmpty(context)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildStatusHeader(context, mpValue, node, isDark),
                      SizedBox(height: ScreenUtil().setWidth(20)),
                      _buildTwoColumnCards(context, mpValue, node, isDark),
                      SizedBox(height: ScreenUtil().setWidth(20)),
                      _buildInfoList(context, mpValue, node, isDark),
                      SizedBox(height: ScreenUtil().setWidth(24)),
                      _buildRedemptionSection(context, mpValue),
                      SizedBox(height: ScreenUtil().setWidth(60)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ── Status header card ──────────────────────────────────────────────────

  Widget _buildStatusHeader(
    BuildContext context,
    MiningV2Provider mpValue,
    FullNodeEntity node,
    bool isDark,
  ) {
    final badgeColor = _statusColor(node.status);
    final pubKey = node.id;
    final shortKey = pubKey.length > 12
        ? '${pubKey.substring(0, 8)}...${pubKey.substring(pubKey.length - 6)}'
        : pubKey;

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: _cardDecoration(context, isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badge row
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(16),
                  vertical: ScreenUtil().setWidth(6),
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: ScreenUtil().setWidth(10),
                      height: ScreenUtil().setWidth(10),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: ScreenUtil().setWidth(8)),
                    Text(
                      _statusLabel(context, node.status),
                      style: TextStyle(
                        color: badgeColor,
                        fontSize: ScreenUtil().setSp(22),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                node.name,
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemSubtitleTextColor.name),
                  fontSize: ScreenUtil().setSp(22),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          // Pubkey row
          Row(
            children: [
              Text(
                '${S.of(context).g_mining_node_key2}: ',
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemSubtitleTextColor.name),
                  fontSize: ScreenUtil().setSp(24),
                ),
              ),
              Expanded(
                child: Text(
                  shortKey,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
                    fontSize: ScreenUtil().setSp(24),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: pubKey));
                  ToastUtils.show(S.of(context).copy);
                },
                child: Padding(
                  padding: EdgeInsets.only(left: ScreenUtil().setWidth(8)),
                  child: Icon(
                    Icons.copy_outlined,
                    size: ScreenUtil().setWidth(32),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainBlueColor.name),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Two-column info cards ───────────────────────────────────────────────

  Widget _buildTwoColumnCards(
    BuildContext context,
    MiningV2Provider mpValue,
    FullNodeEntity node,
    bool isDark,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            context,
            isDark,
            icon: Icons.account_balance_wallet_outlined,
            label: S.of(context).g_key_29,
            value: '${mpValue.balanceInBeacon} ${CoinType.N.name}',
          ),
        ),
        SizedBox(width: ScreenUtil().setWidth(16)),
        Expanded(
          child: _buildInfoCard(
            context,
            isDark,
            icon: Icons.timer_outlined,
            label: 'Uptime',
            value: '${node.uptimePercentage.toStringAsFixed(1)}%',
            valueColor: _uptimeColor(node.uptimePercentage),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: _cardDecoration(context, isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: ScreenUtil().setWidth(28),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
              ),
              SizedBox(width: ScreenUtil().setWidth(8)),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemSubtitleTextColor.name),
                    fontSize: ScreenUtil().setSp(22),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          Text(
            value,
            style: TextStyle(
              color: valueColor ??
                  AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Info list ──────────────────────────────────────────────────────────

  Widget _buildInfoList(
    BuildContext context,
    MiningV2Provider mpValue,
    FullNodeEntity node,
    bool isDark,
  ) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    return Container(
      decoration: _cardDecoration(context, isDark),
      child: Column(
        children: [
          _buildListTile(
            context,
            label: 'Activation Time',
            value: dateFormat.format(node.activatedAt),
          ),
          _divider(context),
          _buildListTileWidget(
            context,
            label: 'WS Status',
            trailing: _buildWsStatus(context, mpValue.wsState),
          ),
          if (node.expiresAt != null) ...[
            _divider(context),
            _buildListTile(
              context,
              label: S.of(context).g_mining_node_key6,
              value: dateFormat.format(node.expiresAt!),
              valueColor: const Color(0xFFEB5851),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(20),
        vertical: ScreenUtil().setWidth(18),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
              fontSize: ScreenUtil().setSp(26),
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ??
                    AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(26),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTileWidget(
    BuildContext context, {
    required String label,
    required Widget trailing,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(20),
        vertical: ScreenUtil().setWidth(18),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
              fontSize: ScreenUtil().setSp(26),
            ),
          ),
          const Spacer(),
          trailing,
        ],
      ),
    );
  }

  Widget _buildWsStatus(BuildContext context, WebSocketState state) {
    switch (state) {
      case WebSocketState.connected:
        return _wsDot(context, const Color(0xff32D74B),
            S.of(context).g_mining_node_key3);
      case WebSocketState.reconnecting:
        return _wsDot(context, const Color(0xFFFF9500),
            S.of(context).g_mining_node_key5);
      case WebSocketState.connecting:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: ScreenUtil().setWidth(20),
              height: ScreenUtil().setWidth(20),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
              ),
            ),
          ],
        );
      case WebSocketState.disconnected:
        return _wsDot(context, const Color(0xffEB5851),
            S.of(context).g_mining_node_key4);
    }
  }

  Widget _wsDot(BuildContext context, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: ScreenUtil().setWidth(10),
          height: ScreenUtil().setWidth(10),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: ScreenUtil().setWidth(6)),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: ScreenUtil().setSp(24),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _divider(BuildContext context) {
    return Divider(
      height: 1,
      indent: ScreenUtil().setWidth(20),
      endIndent: ScreenUtil().setWidth(20),
      color: AppThemeUtils.getColorByKey(
          context, AppThemeKeys.dividerColor.name),
    );
  }

  // ── Redemption section ─────────────────────────────────────────────────

  Widget _buildRedemptionSection(
      BuildContext context, MiningV2Provider mpValue) {
    // Redemption button: show when activated and not yet requested
    if (mpValue.showRedemption == true && mpValue.redeem == false) {
      return SizedBox(
        height: ScreenUtil().setWidth(88),
        child: buttonStyle6(
          context,
          () {
            if (mpValue.exitDepositLoad == Load.finish) {
              _showUnlockDialog(context, mpValue);
            }
          },
          S.of(context).g_mining_key_77,
          AppThemeUtils.getColorByKey(
            context,
            mpValue.exitDepositLoad == Load.loading
                ? AppThemeKeys.mainButtonBgColor3.name
                : AppThemeKeys.mainButtonBgColor.name,
          ),
          AppThemeUtils.getColorByKey(
            context,
            mpValue.exitDepositLoad == Load.loading
                ? AppThemeKeys.mainButtonTextColor3.name
                : AppThemeKeys.mainButtonTextColor.name,
          ),
          mpValue.exitDepositLoad == Load.loading,
        ),
      );
    }
    // Activation pending hint
    if (mpValue.depositsEnable == true && mpValue.showRedemption == false) {
      return Text(
        S.of(context).g_mining_key_88,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(28),
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.textColorOrange.name),
        ),
        textAlign: TextAlign.center,
      );
    }
    // Redemption in progress hint
    if (mpValue.redeem == true && mpValue.showRedemption2 == true) {
      return Text(
        S.of(context).g_mining_key_115,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(28),
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.textColorOrange.name),
        ),
        textAlign: TextAlign.center,
      );
    }
    return const SizedBox.shrink();
  }

  void _showUnlockDialog(BuildContext context, MiningV2Provider mpValue) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: Text(
            S.current.g_mining_key20,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
            ),
          ),
          actions: [
            TextButton(
              child: Text(S.current.g_key_79),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text(S.current.g_key_78),
              onPressed: () async {
                try {
                  if (mpValue.exitDepositLoad == Load.loading) return;
                  await mpValue.createExitDepositUnsignedTx();
                } catch (e) {
                  debugPrint('unLockAstMining error: $e');
                } finally {
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────

  Widget _buildEmpty(BuildContext context) {
    return SizedBox(
      height: ScreenUtil().setWidth(400),
      child: Center(
        child: Text(
          S.of(context).g_mining_key_47,
          style: TextStyle(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemSubtitleTextColor.name),
            fontSize: ScreenUtil().setSp(28),
          ),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  BoxDecoration _cardDecoration(BuildContext context, bool isDark) {
    return BoxDecoration(
      color: AppThemeUtils.getColorByKey(
          context, AppThemeKeys.itemBgColor.name),
      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        width: 1,
      ),
    );
  }

  Color _statusColor(NodeStatus status) {
    switch (status) {
      case NodeStatus.online:
        return const Color(0xff32D74B);
      case NodeStatus.offline:
      case NodeStatus.error:
        return const Color(0xffEB5851);
      case NodeStatus.syncing:
        return const Color(0xFFFF9500);
    }
  }

  String _statusLabel(BuildContext context, NodeStatus status) {
    switch (status) {
      case NodeStatus.online:
        return S.of(context).g_key_193;
      case NodeStatus.offline:
      case NodeStatus.error:
        return S.of(context).g_mining_key_47;
      case NodeStatus.syncing:
        return S.of(context).g_mining_key_102;
    }
  }

  Color _uptimeColor(double pct) {
    if (pct >= 90) return const Color(0xff32D74B);
    if (pct >= 60) return const Color(0xFFFF9500);
    return const Color(0xffEB5851);
  }
}
