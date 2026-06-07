// Copyright 2021-2026 N42 Inc. All rights reserved.

part of 'mining_node_detail_page.dart';

/// Extracted widget builders and helpers for [MiningNodeDetailPage].
mixin _MiningNodeDetailWidgets on ConsumerState<MiningNodeDetailPage> {
  Color _themeColor(BuildContext context, AppThemeKeys key) {
    return AppThemeUtils.getColorByKey(context, key.name);
  }

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
            valueColor: _uptimeColor(context, node.uptimePercentage),
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
                color: _themeColor(context, AppThemeKeys.mainBlueColor),
              ),
              SizedBox(width: ScreenUtil().setWidth(8)),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: _themeColor(
                      context,
                      AppThemeKeys.itemSubtitleTextColor,
                    ),
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
              color:
                  valueColor ??
                  _themeColor(context, AppThemeKeys.mainTextColor),
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

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
              valueColor: AppColorTokens.of(context).danger,
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
    return _buildListTileWidget(
      context,
      label: label,
      trailing: Flexible(
        child: Text(
          value,
          style: TextStyle(
            color:
                valueColor ?? _themeColor(context, AppThemeKeys.mainTextColor),
            fontSize: ScreenUtil().setSp(24),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.end,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
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
          Flexible(
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                color: _themeColor(context, AppThemeKeys.itemSubtitleTextColor),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const Spacer(),
          trailing,
        ],
      ),
    );
  }

  Widget _buildWsStatus(BuildContext context, WebSocketState state) =>
      switch (state) {
        WebSocketState.connected => AppBadge(
          label: S.of(context).g_mining_node_key3,
          tone: AppBadgeTone.success,
          dot: true,
        ),
        WebSocketState.reconnecting => AppBadge(
          label: S.of(context).g_mining_node_key5,
          tone: AppBadgeTone.warning,
          dot: true,
        ),
        WebSocketState.connecting => SizedBox(
          width: ScreenUtil().setWidth(20),
          height: ScreenUtil().setWidth(20),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: _themeColor(context, AppThemeKeys.mainBlueColor),
          ),
        ),
        WebSocketState.disconnected => AppBadge(
          label: S.of(context).g_mining_node_key4,
          tone: AppBadgeTone.danger,
          dot: true,
        ),
      };

  Widget _divider(BuildContext context) {
    return Divider(
      height: 1,
      indent: ScreenUtil().setWidth(20),
      endIndent: ScreenUtil().setWidth(20),
      color: _themeColor(context, AppThemeKeys.dividerColor),
    );
  }

  Widget _buildRedemptionSection(
    BuildContext context,
    MiningV2Provider mpValue,
  ) {
    // Redemption button: show when activated and not yet requested
    if (mpValue.showRedemption == true && mpValue.redeem == false) {
      final isLoading = mpValue.exitDepositLoad == Load.loading;
      return SizedBox(
        height: ScreenUtil().setWidth(88),
        child: AppButton(
          label: S.of(context).g_mining_key_77,
          loading: isLoading,
          onPressed: () {
            if (!isLoading) _showUnlockDialog(context, mpValue);
          },
        ),
      );
    }

    // Activation pending hint
    if (mpValue.depositsEnable == true && mpValue.showRedemption == false) {
      return _hintText(context, S.of(context).g_mining_key_88);
    }

    // Redemption in progress hint
    if (mpValue.redeem == true && mpValue.showRedemption2 == true) {
      return _hintText(context, S.of(context).g_mining_key_115);
    }

    return const SizedBox.shrink();
  }

  Widget _hintText(BuildContext context, String text) {
    return Text(
      text,
      style: AppTypography.body.copyWith(
        color: _themeColor(context, AppThemeKeys.textColorOrange),
      ),
      textAlign: TextAlign.center,
    );
  }

  void _showUnlockDialog(BuildContext context, MiningV2Provider mpValue) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Text(
              S.current.g_mining_key20,
              style: TextStyle(
                color: _themeColor(context, AppThemeKeys.mainTextColor),
              ),
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
                  AppLogger.w('MiningNodeDetail', 'unLockAstMining error: $e');
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

  BoxDecoration _cardDecoration(BuildContext context, bool isDark) {
    return BoxDecoration(
      color: _themeColor(context, AppThemeKeys.itemBgColor),
      borderRadius: AppRadius.brMd,
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.18)
              : Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  Color _statusColor(BuildContext context, NodeStatus status) {
    final c = AppColorTokens.of(context);
    return switch (status) {
      NodeStatus.online => c.success,
      NodeStatus.offline || NodeStatus.error => c.danger,
      NodeStatus.syncing => c.warning,
    };
  }

  String _statusLabel(BuildContext context, NodeStatus status) =>
      switch (status) {
        NodeStatus.online => S.of(context).g_key_193,
        NodeStatus.offline || NodeStatus.error => S.of(context).g_mining_key_47,
        NodeStatus.syncing => S.of(context).g_mining_key_102,
      };

  Color _uptimeColor(BuildContext context, double pct) {
    final c = AppColorTokens.of(context);
    if (pct >= 90) return c.success;
    if (pct >= 60) return c.warning;
    return c.danger;
  }
}
