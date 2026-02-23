// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.



import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/aa/models/smart_account.dart';
import 'package:n42_wallet/features/wallet/aa/repository/session_key_repository.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';

import 'session_key_models.dart';
import 'session_key_sheets.dart';

// ════════════════════════════════════════════════════════════════════════════
// Main page
// ════════════════════════════════════════════════════════════════════════════

/// Session Key management page for a specific [SmartAccount].
///
/// Displays active / expired / revoked keys in a tab view. Users can:
/// - Browse existing authorisations with plain-language permission summaries
/// - Revoke an active key (optimistic UI update + local DB update)
/// - Create new keys via a guided wizard with preset permission templates
class SessionKeyManagePage extends StatefulWidget {
  final SmartAccount account;

  const SessionKeyManagePage({
    super.key,
    required this.account,
  });

  @override
  State<SessionKeyManagePage> createState() => _SessionKeyManagePageState();
}

class _SessionKeyManagePageState extends State<SessionKeyManagePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late SessionKeyRepository _repository;
  bool _isLoading = true;
  List<SessionKeyData> _sessionKeys = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _repository = SessionKeyRepository(AppDatabase());
    _loadSessionKeys();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSessionKeys() async {
    setState(() => _isLoading = true);
    final keys = await _repository.loadKeys(widget.account.chainId);
    if (mounted) {
      setState(() {
        _sessionKeys = keys;
        _isLoading = false;
      });
    }
  }

  // ── Filtered lists ────────────────────────────────────────────────────────

  List<SessionKeyData> get _activeKeys =>
      _sessionKeys.where((k) => k.status == SessionKeyStatus.active).toList();

  List<SessionKeyData> get _expiredKeys =>
      _sessionKeys.where((k) => k.status == SessionKeyStatus.expired).toList();

  List<SessionKeyData> get _revokedKeys =>
      _sessionKeys.where((k) => k.status == SessionKeyStatus.revoked).toList();

  // ── Actions ───────────────────────────────────────────────────────────────

  void _createNewSessionKey() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateSessionKeySheet(
        account: widget.account,
        repository: _repository,
        onCreated: (key) {
          setState(() => _sessionKeys.insert(0, key));
          _tabController.animateTo(0); // jump to Active tab
        },
      ),
    );
  }

  void _revokeSessionKey(SessionKeyData key) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).g_key_aa_revoke_session),
        content: Text(S.of(context).g_key_aa_revoke_confirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).g_key_79),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performRevoke(key);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(S.of(context).g_key_aa_revoke),
          ),
        ],
      ),
    );
  }

  Future<void> _performRevoke(SessionKeyData key) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).g_key_aa_revoking),
        duration: const Duration(seconds: 2),
      ),
    );

    // Optimistic UI update
    final idx =
        _sessionKeys.indexWhere((k) => k.keyAddress == key.keyAddress);
    if (idx >= 0 && mounted) {
      setState(() {
        _sessionKeys[idx] =
            key.copyWith(status: SessionKeyStatus.revoked);
      });
    }

    // Persist to SQLite
    final ok =
        await _repository.revokeKey(key.keyAddress, widget.account.chainId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok
              ? S.of(context).g_key_aa_revoked
              : S.of(context).g_key_aa_session_create_failed),
          backgroundColor: ok ? Colors.green : Colors.red,
        ),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_aa_session_keys,
      ),
      body: Column(
        children: [
          _buildInfoHeader(),
          _buildTabBar(),
          Expanded(
            child: _isLoading ? _buildLoading() : _buildTabContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewSessionKey,
        backgroundColor: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.mainBlueColor.name,
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          S.of(context).g_key_aa_create_session,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildInfoHeader() {
    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(24)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8B5CF6).withAlpha(25),
            const Color(0xFF8B5CF6).withAlpha(10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: ScreenUtil().setWidth(48),
                height: ScreenUtil().setWidth(48),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withAlpha(25),
                  borderRadius:
                      BorderRadius.circular(ScreenUtil().setWidth(14)),
                ),
                child: Icon(
                  Icons.key,
                  size: ScreenUtil().setWidth(28),
                  color: const Color(0xFF8B5CF6),
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).g_key_aa_session_keys,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(28),
                        fontWeight: FontWeight.bold,
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.mainTextColor.name,
                        ),
                      ),
                    ),
                    Text(
                      S.of(context).g_key_aa_session_keys_desc,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(22),
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.itemSubtitleTextColor.name,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Row(
            children: [
              _buildStatItem(
                _activeKeys.length.toString(),
                S.of(context).g_key_aa_active,
                Colors.green,
              ),
              SizedBox(width: ScreenUtil().setWidth(16)),
              _buildStatItem(
                _expiredKeys.length.toString(),
                S.of(context).g_key_aa_expired,
                Colors.orange,
              ),
              SizedBox(width: ScreenUtil().setWidth(16)),
              _buildStatItem(
                _revokedKeys.length.toString(),
                S.of(context).g_key_aa_revoked_status,
                Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(12),
          vertical: ScreenUtil().setWidth(10),
        ),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(32),
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(20),
                color: color.withAlpha(180),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final blueColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainBlueColor.name);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        color:
            AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: blueColor,
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.itemSubtitleTextColor.name,
        ),
        labelStyle: TextStyle(
          fontSize: ScreenUtil().setSp(24),
          fontWeight: FontWeight.w600,
        ),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
              text:
                  '${S.of(context).g_key_aa_active} (${_activeKeys.length})'),
          Tab(
              text:
                  '${S.of(context).g_key_aa_expired} (${_expiredKeys.length})'),
          Tab(
              text:
                  '${S.of(context).g_key_aa_revoked_status} (${_revokedKeys.length})'),
        ],
      ),
    );
  }

  Widget _buildLoading() =>
      const Center(child: CircularProgressIndicator());

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildKeyList(_activeKeys, showActions: true),
        _buildKeyList(_expiredKeys, showActions: false),
        _buildKeyList(_revokedKeys, showActions: false),
      ],
    );
  }

  Widget _buildKeyList(List<SessionKeyData> keys,
      {required bool showActions}) {
    if (keys.isEmpty) return _buildEmptyState();
    return ListView.builder(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      itemCount: keys.length,
      itemBuilder: (context, index) =>
          _buildSessionKeyCard(keys[index], showActions: showActions),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.key_off,
            size: ScreenUtil().setWidth(64),
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.itemSubtitleTextColor.name,
            ).withAlpha(100),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Text(
            S.of(context).g_key_aa_no_session_keys,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionKeyCard(SessionKeyData key,
      {required bool showActions}) {
    final permColor = sessionKeyPermissionColor(key.permission);
    final statusColor = _statusColor(key.status);

    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(16)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color:
            AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        border: Border.all(color: statusColor.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Row(
            children: [
              _buildDappIcon(key),
              SizedBox(width: ScreenUtil().setWidth(14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      key.label,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(28),
                        fontWeight: FontWeight.w600,
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.mainTextColor.name,
                        ),
                      ),
                    ),
                    if (key.dappName != null)
                      Text(
                        key.dappName!,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(22),
                          color: AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.itemSubtitleTextColor.name,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              _buildStatusChip(key.status),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(14)),

          // ── Address ──────────────────────────────────────────────────────
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: key.keyAddress));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(S.of(context).copy),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(12),
                vertical: ScreenUtil().setWidth(8),
              ),
              decoration: BoxDecoration(
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.backGroundColor.name,
                ).withAlpha(100),
                borderRadius:
                    BorderRadius.circular(ScreenUtil().setWidth(8)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.key,
                    size: ScreenUtil().setWidth(16),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemSubtitleTextColor.name,
                    ),
                  ),
                  SizedBox(width: ScreenUtil().setWidth(8)),
                  Text(
                    key.shortAddress,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(22),
                      fontFamily: 'monospace',
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainTextColor.name,
                      ),
                    ),
                  ),
                  SizedBox(width: ScreenUtil().setWidth(6)),
                  Icon(
                    Icons.copy,
                    size: ScreenUtil().setWidth(14),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemSubtitleTextColor.name,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(14)),

          // ── Chips ────────────────────────────────────────────────────────
          Wrap(
            spacing: ScreenUtil().setWidth(8),
            runSpacing: ScreenUtil().setWidth(6),
            children: [
              _buildChip(
                Icons.security,
                _permissionLabel(key.permission),
                permColor,
              ),
              _buildChip(
                Icons.swap_horiz,
                '${key.transactionCount ?? 0} txns',
                null,
              ),
              if (key.isActive)
                _buildChip(
                  Icons.timer,
                  _formatRemainingTime(key.remainingTime),
                  key.remainingTime.inDays < 3 ? Colors.orange : null,
                ),
              if (key.spendingLimit != null && key.spendingToken != null)
                _buildChip(
                  Icons.account_balance_wallet,
                  '≤ ${_formatBigInt(key.spendingLimit!, 18)} ${key.spendingToken}',
                  null,
                ),
            ],
          ),

          // ── Spending progress ────────────────────────────────────────────
          if (key.spendingLimit != null && key.isActive) ...[
            SizedBox(height: ScreenUtil().setWidth(14)),
            _buildSpendingProgress(key),
          ],

          // ── Actions ──────────────────────────────────────────────────────
          if (showActions && key.isActive) ...[
            SizedBox(height: ScreenUtil().setWidth(14)),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showKeyDetails(key),
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: Text(S.of(context).g_key_aa_details),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainBlueColor.name,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ScreenUtil().setWidth(10),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(12)),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _revokeSessionKey(key),
                    icon: const Icon(Icons.block, size: 18),
                    label: Text(S.of(context).g_key_aa_revoke),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ScreenUtil().setWidth(10),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDappIcon(SessionKeyData key) {
    final color = sessionKeyPermissionColor(key.permission);
    return Container(
      width: ScreenUtil().setWidth(48),
      height: ScreenUtil().setWidth(48),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(14)),
      ),
      child: key.dappIcon != null
          ? ClipRRect(
              borderRadius:
                  BorderRadius.circular(ScreenUtil().setWidth(14)),
              child: Image.network(
                key.dappIcon!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Icon(
                  sessionKeyPermissionIcon(key.permission),
                  size: ScreenUtil().setWidth(28),
                  color: color,
                ),
              ),
            )
          : Icon(
              sessionKeyPermissionIcon(key.permission),
              size: ScreenUtil().setWidth(28),
              color: color,
            ),
    );
  }

  Widget _buildStatusChip(SessionKeyStatus status) {
    final color = _statusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(12),
        vertical: ScreenUtil().setWidth(6),
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          fontSize: ScreenUtil().setSp(20),
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, Color? color) {
    final chipColor = color ??
        AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.itemSubtitleTextColor.name,
        );
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(10),
        vertical: ScreenUtil().setWidth(4),
      ),
      decoration: BoxDecoration(
        color: chipColor.withAlpha(15),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: ScreenUtil().setWidth(14), color: chipColor),
          SizedBox(width: ScreenUtil().setWidth(4)),
          Text(
            label,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(20),
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingProgress(SessionKeyData key) {
    final pct = key.usagePercentage;
    final color = pct > 0.8 ? Colors.orange : Colors.green;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              S.of(context).g_key_aa_spending_limit,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemSubtitleTextColor.name,
                ),
              ),
            ),
            Text(
              '${(pct * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: ScreenUtil().setWidth(8)),
        ClipRRect(
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(4)),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: Colors.grey.withAlpha(30),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: ScreenUtil().setWidth(8),
          ),
        ),
      ],
    );
  }

  void _showKeyDetails(SessionKeyData key) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => KeyDetailsSheet(keyData: key),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Color _statusColor(SessionKeyStatus status) {
    switch (status) {
      case SessionKeyStatus.active:
        return Colors.green;
      case SessionKeyStatus.expired:
        return Colors.orange;
      case SessionKeyStatus.revoked:
        return Colors.red;
    }
  }

  String _statusLabel(SessionKeyStatus status) {
    switch (status) {
      case SessionKeyStatus.active:
        return S.of(context).g_key_aa_active;
      case SessionKeyStatus.expired:
        return S.of(context).g_key_aa_expired;
      case SessionKeyStatus.revoked:
        return S.of(context).g_key_aa_revoked_status;
    }
  }

  static Color sessionKeyPermissionColor(SessionKeyPermission permission) {
    switch (permission) {
      case SessionKeyPermission.transfer:
        return const Color(0xFF5E97F6);
      case SessionKeyPermission.approve:
        return const Color(0xFF66BB6A);
      case SessionKeyPermission.contractCall:
        return const Color(0xFF9C27B0);
      case SessionKeyPermission.full:
        return const Color(0xFFFF5722);
    }
  }

  static IconData sessionKeyPermissionIcon(SessionKeyPermission permission) {
    switch (permission) {
      case SessionKeyPermission.transfer:
        return Icons.send;
      case SessionKeyPermission.approve:
        return Icons.check_circle_outline;
      case SessionKeyPermission.contractCall:
        return Icons.code;
      case SessionKeyPermission.full:
        return Icons.all_inclusive;
    }
  }

  String _permissionLabel(SessionKeyPermission permission) {
    switch (permission) {
      case SessionKeyPermission.transfer:
        return S.of(context).g_key_aa_session_preset_transfer;
      case SessionKeyPermission.approve:
        return S.of(context).g_key_aa_approve;
      case SessionKeyPermission.contractCall:
        return S.of(context).g_key_aa_session_preset_contract;
      case SessionKeyPermission.full:
        return S.of(context).g_key_aa_session_preset_full;
    }
  }

  static String _formatRemainingTime(Duration d) {
    if (d.inDays > 0) return '${d.inDays}d';
    if (d.inHours > 0) return '${d.inHours}h';
    if (d.inMinutes > 0) return '${d.inMinutes}m';
    return 'expired';
  }

  /// Format [BigInt] wei amount into a human-readable string.
  static String _formatBigInt(BigInt value, int decimals) {
    if (value == BigInt.zero) return '0';
    final pow = BigInt.from(10).pow(decimals);
    final whole = value ~/ pow;
    final frac = (value % pow).toString().padLeft(decimals, '0');
    final trimmed = frac.replaceAll(RegExp(r'0+$'), '');
    return trimmed.isEmpty ? whole.toString() : '$whole.$trimmed';
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Key details bottom sheet
// ════════════════════════════════════════════════════════════════════════════

