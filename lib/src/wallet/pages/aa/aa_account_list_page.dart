// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/src/wallet/aa/models/smart_account.dart';
import 'package:n42_wallet/src/wallet/pages/aa/aa_account_create_page.dart';
import 'package:n42_wallet/src/wallet/pages/aa/aa_account_detail_page.dart';
import 'package:n42_wallet/src/wallet/widgets/aa/smart_account_card.dart';
import 'package:n42_wallet/src/widgets/app_bar_widget.dart';

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
    final accounts = <SmartAccount>[];
    for (final list in widget.accountInfo!.smartAccounts.values) {
      accounts.addAll(list);
    }
    return accounts;
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
        builder: (context) => AAAccountCreatePage(
          ownerAddress: widget.walletAddress,
        ),
      ),
    ).then((_) => setState(() {}));
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
      appBar: AppBarWidget(
        text: S.of(context).g_key_aa_my_accounts,
      ),
      body: Column(
        children: [
          // 筛选器
          _buildFilters(),
          // 账户列表
          Expanded(
            child: _filteredAccounts.isEmpty
                ? _buildEmptyState()
                : _buildAccountList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreate,
        backgroundColor: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.mainBlueColor.name,
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
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
          // 链筛选
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
          SizedBox(height: ScreenUtil().setWidth(12)),
          // 状态筛选
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
    final isSelected = _filterChain == chain;

    return GestureDetector(
      onTap: () => setState(() => _filterChain = chain),
      child: Container(
        margin: EdgeInsets.only(right: ScreenUtil().setWidth(10)),
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(16),
          vertical: ScreenUtil().setWidth(8),
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.mainBlueColor.name,
                )
              : Colors.transparent,
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
          border: Border.all(
            color: isSelected
                ? AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainBlueColor.name,
                  )
                : AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemSubtitleTextColor.name,
                  ).withAlpha(50),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(24),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? Colors.white
                : AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainTextColor.name,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(SmartAccountState? status, String label) {
    final isSelected = _filterStatus == status;

    Color chipColor;
    if (status == null) {
      chipColor = AppThemeUtils.getColorByKey(
        context,
        AppThemeKeys.mainBlueColor.name,
      );
    } else {
      switch (status) {
        case SmartAccountState.deployed:
          chipColor = Colors.green;
          break;
        case SmartAccountState.notDeployed:
          chipColor = Colors.grey;
          break;
        case SmartAccountState.deploying:
          chipColor = Colors.orange;
          break;
        case SmartAccountState.error:
          chipColor = Colors.red;
          break;
      }
    }

    return GestureDetector(
      onTap: () => setState(() => _filterStatus = status),
      child: Container(
        margin: EdgeInsets.only(right: ScreenUtil().setWidth(10)),
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(16),
          vertical: ScreenUtil().setWidth(8),
        ),
        decoration: BoxDecoration(
          color: isSelected ? chipColor.withAlpha(20) : Colors.transparent,
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
          border: Border.all(
            color: isSelected
                ? chipColor
                : AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemSubtitleTextColor.name,
                  ).withAlpha(50),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(24),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? chipColor
                : AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainTextColor.name,
                  ),
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
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.itemSubtitleTextColor.name,
            ).withAlpha(100),
          ),
          SizedBox(height: ScreenUtil().setWidth(20)),
          Text(
            S.of(context).g_key_aa_no_accounts_filter,
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

  Widget _buildAccountList() {
    return ListView.builder(
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
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
