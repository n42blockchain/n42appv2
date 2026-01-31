// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/aa/models/smart_account.dart';
import 'package:n42appv2/src/wallet/pages/aa/aa_account_create_page.dart';
import 'package:n42appv2/src/wallet/pages/aa/aa_account_detail_page.dart';
import 'package:n42appv2/src/wallet/pages/aa/aa_account_list_page.dart';
import 'package:n42appv2/src/wallet/pages/aa/aa_send_page.dart';
import 'package:n42appv2/src/wallet/pages/aa/aa_batch_transaction_page.dart';
import 'package:n42appv2/src/wallet/pages/aa/session_key_manage_page.dart';
import 'package:n42appv2/src/wallet/widgets/aa/smart_account_card.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';

/// AA 功能主页
///
/// 提供 Account Abstraction 功能入口:
/// - 智能账户概览
/// - 创建新账户
/// - 发送交易
/// - 批量操作
class AAHomePage extends StatefulWidget {
  /// 当前钱包地址 (EOA)
  final String walletAddress;

  /// AA 账户信息
  final AAAccountInfo? accountInfo;

  const AAHomePage({
    super.key,
    required this.walletAddress,
    this.accountInfo,
  });

  @override
  State<AAHomePage> createState() => _AAHomePageState();
}

class _AAHomePageState extends State<AAHomePage> {
  List<SmartAccount> _accounts = [];

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  void _loadAccounts() {
    if (widget.accountInfo != null) {
      _accounts = [];
      for (final accountList in widget.accountInfo!.smartAccounts.values) {
        _accounts.addAll(accountList);
      }
    }
    setState(() {});
  }

  void _navigateToCreateAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AAAccountCreatePage(
          ownerAddress: widget.walletAddress,
        ),
      ),
    ).then((_) => _loadAccounts());
  }

  void _navigateToAccountList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AAAccountListPage(
          walletAddress: widget.walletAddress,
          accountInfo: widget.accountInfo,
        ),
      ),
    );
  }

  void _navigateToAccountDetail(SmartAccount account) {
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

  void _navigateToSend(SmartAccount account) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AASendPage(
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
        text: S.of(context).g_key_aa_title,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 顶部说明卡片
            _buildHeaderCard(),
            SizedBox(height: ScreenUtil().setWidth(24)),

            // 功能入口
            _buildFeatureCards(),
            SizedBox(height: ScreenUtil().setWidth(24)),

            // 高级功能
            _buildAdvancedFeatures(),
            SizedBox(height: ScreenUtil().setWidth(24)),

            // 智能账户列表
            _buildAccountsSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateAccount,
        backgroundColor: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.mainBlueColor.name,
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          S.of(context).g_key_aa_create_account,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withAlpha(30),
            const Color(0xFF8B5CF6).withAlpha(15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: ScreenUtil().setWidth(56),
                height: ScreenUtil().setWidth(56),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withAlpha(30),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
                ),
                child: Center(
                  child: Icon(
                    Icons.account_balance_wallet,
                    size: ScreenUtil().setWidth(32),
                    color: const Color(0xFF6366F1),
                  ),
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).g_key_aa_smart_accounts,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(32),
                        fontWeight: FontWeight.bold,
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.mainTextColor.name,
                        ),
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(4)),
                    Text(
                      S.of(context).g_key_aa_description,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(24),
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
          SizedBox(height: ScreenUtil().setWidth(20)),
          // 特性列表
          _buildFeatureItem(
            Icons.local_gas_station,
            S.of(context).g_key_aa_feature_gas,
          ),
          _buildFeatureItem(
            Icons.layers,
            S.of(context).g_key_aa_feature_batch,
          ),
          _buildFeatureItem(
            Icons.security,
            S.of(context).g_key_aa_feature_security,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(8)),
      child: Row(
        children: [
          Icon(
            icon,
            size: ScreenUtil().setWidth(20),
            color: const Color(0xFF6366F1),
          ),
          SizedBox(width: ScreenUtil().setWidth(10)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemSubtitleTextColor.name,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCards() {
    return Row(
      children: [
        Expanded(
          child: _buildFeatureCard(
            icon: Icons.send,
            title: S.of(context).g_key_48,
            subtitle: S.of(context).g_key_aa_send_desc,
            color: const Color(0xFF5E97F6),
            onTap: _accounts.isNotEmpty
                ? () => _navigateToSend(_accounts.first)
                : null,
          ),
        ),
        SizedBox(width: ScreenUtil().setWidth(12)),
        Expanded(
          child: _buildFeatureCard(
            icon: Icons.layers,
            title: S.of(context).g_key_aa_batch,
            subtitle: S.of(context).g_key_aa_batch_desc,
            color: const Color(0xFFFF9800),
            onTap: _accounts.isNotEmpty
                ? () => _navigateToBatchTransaction(_accounts.first)
                : null,
          ),
        ),
      ],
    );
  }

  void _navigateToBatchTransaction(SmartAccount account) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AABatchTransactionPage(
          account: account,
          walletAddress: widget.walletAddress,
        ),
      ),
    );
  }

  void _navigateToSessionKeys(SmartAccount account) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SessionKeyManagePage(
          account: account,
        ),
      ),
    );
  }

  Widget _buildAdvancedFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).g_key_advanced_features,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(26),
            fontWeight: FontWeight.w600,
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainTextColor.name,
            ),
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(12)),
        _buildFeatureCard(
          icon: Icons.key,
          title: S.of(context).g_key_aa_session_keys,
          subtitle: S.of(context).g_key_aa_session_keys_desc,
          color: const Color(0xFF8B5CF6),
          onTap: _accounts.isNotEmpty
              ? () => _navigateToSessionKeys(_accounts.first)
              : null,
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    final isDisabled = onTap == null;

    return GestureDetector(
      onTap: isDisabled
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(S.of(context).g_key_aa_create_first),
                ),
              );
            }
          : onTap,
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
          border: Border.all(
            color: isDisabled ? Colors.grey.withAlpha(30) : color.withAlpha(40),
          ),
        ),
        child: Opacity(
          opacity: isDisabled ? 0.5 : 1.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: ScreenUtil().setWidth(44),
                height: ScreenUtil().setWidth(44),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                ),
                child: Icon(
                  icon,
                  size: ScreenUtil().setWidth(24),
                  color: color,
                ),
              ),
              SizedBox(height: ScreenUtil().setWidth(12)),
              Text(
                title,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  fontWeight: FontWeight.w600,
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainTextColor.name,
                  ),
                ),
              ),
              SizedBox(height: ScreenUtil().setWidth(4)),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(22),
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemSubtitleTextColor.name,
                  ),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              S.of(context).g_key_aa_my_accounts,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(30),
                fontWeight: FontWeight.bold,
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.mainTextColor.name,
                ),
              ),
            ),
            if (_accounts.isNotEmpty)
              TextButton(
                onPressed: _navigateToAccountList,
                child: Text(S.of(context).g_key_aa_view_all),
              ),
          ],
        ),
        SizedBox(height: ScreenUtil().setWidth(16)),
        if (_accounts.isEmpty)
          _buildEmptyState()
        else
          _buildAccountsList(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(32)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        border: Border.all(
          color: const Color(0xFF6366F1).withAlpha(30),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: ScreenUtil().setWidth(64),
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.itemSubtitleTextColor.name,
            ).withAlpha(100),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Text(
            S.of(context).g_key_aa_no_accounts,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.w500,
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(8)),
          Text(
            S.of(context).g_key_aa_create_first_account,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ScreenUtil().setWidth(20)),
          ElevatedButton.icon(
            onPressed: _navigateToCreateAccount,
            icon: const Icon(Icons.add, size: 20),
            label: Text(S.of(context).g_key_aa_create_account),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(24),
                vertical: ScreenUtil().setWidth(12),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountsList() {
    // 显示最多 3 个账户
    final displayAccounts = _accounts.take(3).toList();

    return Column(
      children: displayAccounts.map((account) {
        return Padding(
          padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
          child: SmartAccountCard(
            account: account,
            onTap: () => _navigateToAccountDetail(account),
          ),
        );
      }).toList(),
    );
  }
}
