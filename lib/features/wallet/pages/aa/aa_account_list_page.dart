// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/wallet/aa/models/smart_account.dart';
import 'package:n42_wallet/features/wallet/pages/aa/aa_account_create_page.dart';
import 'package:n42_wallet/features/wallet/pages/aa/aa_account_detail_page.dart';
import 'package:n42_wallet/features/wallet/widgets/aa/smart_account_card.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';

/// AA 账户列表页面
class AAAccountListPage extends StatefulWidget {
  final String walletAddress;
  final AAAccountInfo? accountInfo;

  const AAAccountListPage({
    super.key,
    required this.walletAddress,
    this.accountInfo,
  });

  @override
  State<AAAccountListPage> createState() => _AAAccountListPageState();
}

class _AAAccountListPageState extends State<AAAccountListPage> {
  String _filterChain = 'all';
  SmartAccountState? _filterStatus;

  List<SmartAccount> get _allAccounts {
    if (widget.accountInfo == null) return [];
    return widget.accountInfo!.smartAccounts.values
        .expand((list) => list)
        .toList();
  }

  List<SmartAccount> get _filteredAccounts {
    var accounts = _allAccounts;

    // 按链筛选
    if (_filterChain != 'all') {
      final chainId = _getChainId(_filterChain);
      accounts = accounts.where((a) => a.chainId == chainId).toList();
    }

    // 按状态筛选
    if (_filterStatus != null) {
      accounts = accounts.where((a) => a.state == _filterStatus).toList();
    }

    return accounts;
  }

  int _getChainId(String symbol) {
    const chainIds = {
      'ETH': 1,
      'BASE': 8453,
      'ARB': 42161,
      'OP': 10,
      'MATIC': 137,
    };
    return chainIds[symbol] ?? 1;
  }

  void _navigateToCreate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AAAccountCreatePage(ownerAddress: widget.walletAddress),
      ),
    ).then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  void _navigateToDetail(SmartAccount account) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AAAccountDetailPage(
          account: account,
          walletAddress: widget.walletAddress,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_aa_my_accounts),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _filteredAccounts.isEmpty
                ? _buildEmptyState()
                : _buildAccountList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreate,
        backgroundColor: AppColorTokens.of(context).brand,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColorTokens.of(context).bgSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildChainChip('all', S.of(context).g_key_9),
                _buildChainChip('ETH', 'Ethereum'),
                _buildChainChip('BASE', 'Base'),
                _buildChainChip('ARB', 'Arbitrum'),
                _buildChainChip('OP', 'Optimism'),
                _buildChainChip('MATIC', 'Polygon'),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.space4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusChip(null, S.of(context).g_key_9),
                _buildStatusChip(
                  SmartAccountState.deployed,
                  S.of(context).g_key_aa_deployed,
                ),
                _buildStatusChip(
                  SmartAccountState.notDeployed,
                  S.of(context).g_key_aa_not_deployed,
                ),
                _buildStatusChip(
                  SmartAccountState.deploying,
                  S.of(context).g_key_aa_deploying,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChainChip(String chain, String label) {
    final blue = AppColorTokens.of(context).brand;
    return _buildFilterChip(
      label: label,
      isSelected: _filterChain == chain,
      activeColor: blue,
      selectedBgColor: blue,
      selectedTextColor: Colors.white,
      onTap: () => setState(() => _filterChain = chain),
    );
  }

  Color _statusColor(SmartAccountState? status) {
    final c = AppColorTokens.of(context);
    return switch (status) {
      null => c.brand,
      SmartAccountState.deployed => c.success,
      SmartAccountState.notDeployed => c.textTertiary,
      SmartAccountState.deploying => c.warning,
      SmartAccountState.error => c.danger,
    };
  }

  Widget _buildStatusChip(SmartAccountState? status, String label) {
    final chipColor = _statusColor(status);
    return _buildFilterChip(
      label: label,
      isSelected: _filterStatus == status,
      activeColor: chipColor,
      selectedBgColor: chipColor.withAlpha(20),
      selectedTextColor: chipColor,
      onTap: () => setState(() => _filterStatus = status),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required Color activeColor,
    required Color selectedBgColor,
    required Color selectedTextColor,
    required VoidCallback onTap,
  }) {
    final subtitleColor = AppColorTokens.of(context).textSubtitle;
    final mainTextColor = AppColorTokens.of(context).textPrimary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: ScreenUtil().setWidth(10)),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? selectedBgColor : Colors.transparent,
          borderRadius: AppRadius.brMd,
          border: Border.all(
            color: isSelected ? activeColor : subtitleColor.withAlpha(50),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? selectedTextColor : mainTextColor,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: ScreenUtil().setWidth(80),
            color: AppColorTokens.of(context).textSubtitle.withAlpha(100),
          ),
          SizedBox(height: AppSpacing.space4),
          Text(
            S.of(context).g_key_aa_no_accounts_filter,
            style: AppTypography.body.copyWith(
              color: AppColorTokens.of(context).textSubtitle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountList() {
    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.space4),
      itemCount: _filteredAccounts.length,
      itemBuilder: (context, index) {
        final account = _filteredAccounts[index];
        return Padding(
          padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
          child: SmartAccountCard(
            account: account,
            showDetails: true,
            onTap: () => _navigateToDetail(account),
          ),
        );
      },
    );
  }
}
