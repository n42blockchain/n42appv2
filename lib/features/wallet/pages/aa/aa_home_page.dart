// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/aa/models/smart_account.dart';
import 'package:n42_wallet/features/wallet/pages/aa/aa_account_create_page.dart';
import 'package:n42_wallet/features/wallet/pages/aa/aa_account_detail_page.dart';
import 'package:n42_wallet/features/wallet/pages/aa/aa_account_list_page.dart';
import 'package:n42_wallet/features/wallet/pages/aa/aa_send_page.dart';
import 'package:n42_wallet/features/wallet/pages/aa/aa_batch_transaction_page.dart';
import 'package:n42_wallet/features/wallet/pages/aa/session_key_manage_page.dart';
import 'package:n42_wallet/features/wallet/widgets/aa/smart_account_card.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';

part 'aa_home_page_widgets.dart';

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
  List<SmartAccount> accounts = [];

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  void _loadAccounts() {
    if (widget.accountInfo != null) {
      accounts = [];
      for (final accountList in widget.accountInfo!.smartAccounts.values) {
        accounts.addAll(accountList);
      }
    }
    setState(() {});
  }

  void navigateToCreateAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AAAccountCreatePage(
          ownerAddress: widget.walletAddress,
        ),
      ),
    ).then((_) => _loadAccounts());
  }

  void navigateToAccountList() {
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

  void navigateToAccountDetail(SmartAccount account) {
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

  void navigateToSend(SmartAccount account) {
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

  void navigateToBatchTransaction(SmartAccount account) {
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

  void navigateToSessionKeys(SmartAccount account) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SessionKeyManagePage(
          account: account,
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
            buildHeaderCard(),
            SizedBox(height: ScreenUtil().setWidth(24)),

            // 功能入口
            buildFeatureCards(),
            SizedBox(height: ScreenUtil().setWidth(24)),

            // 高级功能
            buildAdvancedFeatures(),
            SizedBox(height: ScreenUtil().setWidth(24)),

            // 智能账户列表
            buildAccountsSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToCreateAccount,
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
}
