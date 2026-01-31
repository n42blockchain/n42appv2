// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/aa/models/smart_account.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';

/// Session Key 权限类型
enum SessionKeyPermission {
  /// 转账权限
  transfer,

  /// 代币 Approve 权限
  approve,

  /// 合约交互权限
  contractCall,

  /// 完整权限
  full,
}

/// Session Key 状态
enum SessionKeyStatus {
  /// 活跃
  active,

  /// 已过期
  expired,

  /// 已撤销
  revoked,
}

/// Session Key 数据模型
class SessionKeyData {
  final String keyAddress;
  final String label;
  final SessionKeyPermission permission;
  final SessionKeyStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String? dappName;
  final String? dappIcon;
  final List<String>? allowedContracts;
  final BigInt? spendingLimit;
  final BigInt? usedAmount;
  final int? transactionCount;

  const SessionKeyData({
    required this.keyAddress,
    required this.label,
    required this.permission,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.dappName,
    this.dappIcon,
    this.allowedContracts,
    this.spendingLimit,
    this.usedAmount,
    this.transactionCount,
  });

  String get shortAddress {
    if (keyAddress.length <= 12) return keyAddress;
    return '${keyAddress.substring(0, 6)}...${keyAddress.substring(keyAddress.length - 4)}';
  }

  bool get isActive => status == SessionKeyStatus.active;

  Duration get remainingTime {
    final now = DateTime.now();
    if (expiresAt.isBefore(now)) return Duration.zero;
    return expiresAt.difference(now);
  }

  double get usagePercentage {
    if (spendingLimit == null || spendingLimit == BigInt.zero) return 0;
    if (usedAmount == null) return 0;
    return (usedAmount! / spendingLimit!).toDouble().clamp(0.0, 1.0);
  }
}

/// Session Key 管理页面
///
/// 管理智能账户的会话密钥:
/// - 查看已授权的 DApp
/// - 管理权限和限额
/// - 撤销授权
/// - 创建新的会话密钥
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
  bool _isLoading = true;
  List<SessionKeyData> _sessionKeys = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSessionKeys();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSessionKeys() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _sessionKeys = [
          SessionKeyData(
            keyAddress: '0x1234567890abcdef1234567890abcdef12345678',
            label: 'Uniswap Trading',
            permission: SessionKeyPermission.contractCall,
            status: SessionKeyStatus.active,
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
            expiresAt: DateTime.now().add(const Duration(days: 25)),
            dappName: 'Uniswap',
            dappIcon: 'https://app.uniswap.org/favicon.ico',
            allowedContracts: [
              '0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45',
            ],
            spendingLimit: BigInt.from(10) * BigInt.from(10).pow(18),
            usedAmount: BigInt.from(3) * BigInt.from(10).pow(18),
            transactionCount: 12,
          ),
          SessionKeyData(
            keyAddress: '0xabcdef1234567890abcdef1234567890abcdef12',
            label: 'OpenSea NFT',
            permission: SessionKeyPermission.approve,
            status: SessionKeyStatus.active,
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
            expiresAt: DateTime.now().add(const Duration(days: 5)),
            dappName: 'OpenSea',
            transactionCount: 3,
          ),
          SessionKeyData(
            keyAddress: '0x7890abcdef1234567890abcdef1234567890abcd',
            label: 'Old Session',
            permission: SessionKeyPermission.transfer,
            status: SessionKeyStatus.expired,
            createdAt: DateTime.now().subtract(const Duration(days: 35)),
            expiresAt: DateTime.now().subtract(const Duration(days: 5)),
            dappName: 'Aave',
            transactionCount: 28,
          ),
          SessionKeyData(
            keyAddress: '0xdef1234567890abcdef1234567890abcdef123456',
            label: 'Revoked Key',
            permission: SessionKeyPermission.full,
            status: SessionKeyStatus.revoked,
            createdAt: DateTime.now().subtract(const Duration(days: 15)),
            expiresAt: DateTime.now().add(const Duration(days: 15)),
            dappName: 'Unknown DApp',
            transactionCount: 5,
          ),
        ];
      });
    }
  }

  List<SessionKeyData> get _activeKeys =>
      _sessionKeys.where((k) => k.status == SessionKeyStatus.active).toList();

  List<SessionKeyData> get _expiredKeys =>
      _sessionKeys.where((k) => k.status == SessionKeyStatus.expired).toList();

  List<SessionKeyData> get _revokedKeys =>
      _sessionKeys.where((k) => k.status == SessionKeyStatus.revoked).toList();

  void _createNewSessionKey() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCreateSessionKeySheet(),
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

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        final index = _sessionKeys.indexWhere((k) => k.keyAddress == key.keyAddress);
        if (index >= 0) {
          _sessionKeys[index] = SessionKeyData(
            keyAddress: key.keyAddress,
            label: key.label,
            permission: key.permission,
            status: SessionKeyStatus.revoked,
            createdAt: key.createdAt,
            expiresAt: key.expiresAt,
            dappName: key.dappName,
            dappIcon: key.dappIcon,
            allowedContracts: key.allowedContracts,
            spendingLimit: key.spendingLimit,
            usedAmount: key.usedAmount,
            transactionCount: key.transactionCount,
          );
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).g_key_aa_revoked),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

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
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(14)),
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
                context,
                _activeKeys.length.toString(),
                S.of(context).g_key_aa_active,
                Colors.green,
              ),
              SizedBox(width: ScreenUtil().setWidth(16)),
              _buildStatItem(
                context,
                _expiredKeys.length.toString(),
                S.of(context).g_key_aa_expired,
                Colors.orange,
              ),
              SizedBox(width: ScreenUtil().setWidth(16)),
              _buildStatItem(
                context,
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

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    Color color,
  ) {
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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppThemeUtils.getColorByKey(
            context,
            AppThemeKeys.mainBlueColor.name,
          ),
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
          Tab(text: '${S.of(context).g_key_aa_active} (${_activeKeys.length})'),
          Tab(text: '${S.of(context).g_key_aa_expired} (${_expiredKeys.length})'),
          Tab(text: '${S.of(context).g_key_aa_revoked_status} (${_revokedKeys.length})'),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

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

  Widget _buildKeyList(List<SessionKeyData> keys, {required bool showActions}) {
    if (keys.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        return _buildSessionKeyCard(keys[index], showActions: showActions);
      },
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

  Widget _buildSessionKeyCard(SessionKeyData key, {required bool showActions}) {
    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(16)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        border: Border.all(
          color: _getStatusColor(key.status).withAlpha(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部
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
          SizedBox(height: ScreenUtil().setWidth(16)),

          // 地址
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
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
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
          SizedBox(height: ScreenUtil().setWidth(16)),

          // 详情信息
          Row(
            children: [
              _buildDetailChip(
                context,
                Icons.security,
                _getPermissionLabel(key.permission),
              ),
              SizedBox(width: ScreenUtil().setWidth(10)),
              _buildDetailChip(
                context,
                Icons.swap_horiz,
                '${key.transactionCount ?? 0} txns',
              ),
              SizedBox(width: ScreenUtil().setWidth(10)),
              if (key.isActive)
                _buildDetailChip(
                  context,
                  Icons.timer,
                  _formatRemainingTime(key.remainingTime),
                  color: key.remainingTime.inDays < 3 ? Colors.orange : null,
                ),
            ],
          ),

          // 使用限额进度
          if (key.spendingLimit != null && key.isActive) ...[
            SizedBox(height: ScreenUtil().setWidth(16)),
            _buildSpendingProgress(key),
          ],

          // 操作按钮
          if (showActions && key.isActive) ...[
            SizedBox(height: ScreenUtil().setWidth(16)),
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
    return Container(
      width: ScreenUtil().setWidth(48),
      height: ScreenUtil().setWidth(48),
      decoration: BoxDecoration(
        color: _getPermissionColor(key.permission).withAlpha(25),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(14)),
      ),
      child: key.dappIcon != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(14)),
              child: Image.network(
                key.dappIcon!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  _getPermissionIcon(key.permission),
                  size: ScreenUtil().setWidth(28),
                  color: _getPermissionColor(key.permission),
                ),
              ),
            )
          : Icon(
              _getPermissionIcon(key.permission),
              size: ScreenUtil().setWidth(28),
              color: _getPermissionColor(key.permission),
            ),
    );
  }

  Widget _buildStatusChip(SessionKeyStatus status) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(12),
        vertical: ScreenUtil().setWidth(6),
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withAlpha(20),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
        border: Border.all(
          color: _getStatusColor(status).withAlpha(50),
        ),
      ),
      child: Text(
        _getStatusLabel(status),
        style: TextStyle(
          fontSize: ScreenUtil().setSp(20),
          fontWeight: FontWeight.w600,
          color: _getStatusColor(status),
        ),
      ),
    );
  }

  Widget _buildDetailChip(
    BuildContext context,
    IconData icon,
    String label, {
    Color? color,
  }) {
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
    final percentage = key.usagePercentage;

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
              '${(percentage * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                fontWeight: FontWeight.w600,
                color: percentage > 0.8 ? Colors.orange : Colors.green,
              ),
            ),
          ],
        ),
        SizedBox(height: ScreenUtil().setWidth(8)),
        ClipRRect(
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(4)),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey.withAlpha(30),
            valueColor: AlwaysStoppedAnimation(
              percentage > 0.8 ? Colors.orange : Colors.green,
            ),
            minHeight: ScreenUtil().setWidth(8),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(SessionKeyStatus status) {
    switch (status) {
      case SessionKeyStatus.active:
        return Colors.green;
      case SessionKeyStatus.expired:
        return Colors.orange;
      case SessionKeyStatus.revoked:
        return Colors.red;
    }
  }

  String _getStatusLabel(SessionKeyStatus status) {
    switch (status) {
      case SessionKeyStatus.active:
        return S.of(context).g_key_aa_active;
      case SessionKeyStatus.expired:
        return S.of(context).g_key_aa_expired;
      case SessionKeyStatus.revoked:
        return S.of(context).g_key_aa_revoked_status;
    }
  }

  Color _getPermissionColor(SessionKeyPermission permission) {
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

  IconData _getPermissionIcon(SessionKeyPermission permission) {
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

  String _getPermissionLabel(SessionKeyPermission permission) {
    switch (permission) {
      case SessionKeyPermission.transfer:
        return S.of(context).g_key_37;
      case SessionKeyPermission.approve:
        return S.of(context).g_key_aa_approve;
      case SessionKeyPermission.contractCall:
        return S.of(context).g_key_aa_contract;
      case SessionKeyPermission.full:
        return S.of(context).g_key_aa_full_access;
    }
  }

  String _formatRemainingTime(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    }
    return 'expired';
  }

  void _showKeyDetails(SessionKeyData key) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(ScreenUtil().setWidth(24)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: ScreenUtil().setWidth(40),
                height: ScreenUtil().setWidth(4),
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(50),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(20)),
            Text(
              S.of(context).g_key_aa_session_details,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(32),
                fontWeight: FontWeight.bold,
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.mainTextColor.name,
                ),
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(20)),
            _buildDetailRow(S.of(context).g_key_aa_label, key.label),
            _buildDetailRow(S.of(context).g_key_aa_permission, _getPermissionLabel(key.permission)),
            _buildDetailRow(S.of(context).g_key_aa_created, _formatDate(key.createdAt)),
            _buildDetailRow(S.of(context).g_key_aa_expires, _formatDate(key.expiresAt)),
            _buildDetailRow(S.of(context).g_key_aa_transactions, '${key.transactionCount ?? 0}'),
            SizedBox(height: ScreenUtil().setWidth(24)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              fontWeight: FontWeight.w500,
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Widget _buildCreateSessionKeySheet() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ScreenUtil().setWidth(24)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: ScreenUtil().setWidth(40),
              height: ScreenUtil().setWidth(4),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(50),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(20)),
          Text(
            S.of(context).g_key_aa_create_session,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(32),
              fontWeight: FontWeight.bold,
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(24)),
          Text(
            S.of(context).g_key_aa_create_session_desc,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(24)),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(S.of(context).g_key_aa_coming_soon),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainBlueColor.name,
              ),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(14)),
              ),
            ),
            child: Text(
              S.of(context).g_key_aa_continue,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
        ],
      ),
    );
  }
}
