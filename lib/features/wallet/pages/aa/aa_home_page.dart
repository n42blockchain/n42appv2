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
import 'package:n42_wallet/features/wallet/utils/feature_address_utils.dart';
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

  const AAHomePage({super.key, required this.walletAddress, this.accountInfo});

  @override
  State<AAHomePage> createState() => _AAHomePageState();
}

class _AAHomePageState extends State<AAHomePage> {
  List<SmartAccount> accounts = [];

  bool get _hasOwnerAddress =>
      FeatureAddressUtils.isValidEvmAddress(widget.walletAddress);

  void _showUnsupportedSnack() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of(context).g_key_bridge_chain_not_supported)),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  void _loadAccounts() {
    if (!mounted) return;
    accounts = [
      if (widget.accountInfo != null)
        for (final list in widget.accountInfo!.smartAccounts.values) ...list,
    ];
    setState(() {});
  }

  Future<void> _pushPage(Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  void navigateToCreateAccount() {
    if (!_hasOwnerAddress) {
      _showUnsupportedSnack();
      return;
    }
    _pushPage(AAAccountCreatePage(ownerAddress: widget.walletAddress)).then((
      _,
    ) {
      if (!mounted) return;
      _loadAccounts();
    });
  }

  void navigateToAccountList() {
    if (!_hasOwnerAddress) {
      _showUnsupportedSnack();
      return;
    }
    _pushPage(
      AAAccountListPage(
        walletAddress: widget.walletAddress,
        accountInfo: widget.accountInfo,
      ),
    );
  }

  void navigateToAccountDetail(SmartAccount account) {
    if (!_hasOwnerAddress) {
      _showUnsupportedSnack();
      return;
    }
    _pushPage(
      AAAccountDetailPage(
        account: account,
        walletAddress: widget.walletAddress,
      ),
    );
  }

  void navigateToSend(SmartAccount account) {
    if (!_hasOwnerAddress) {
      _showUnsupportedSnack();
      return;
    }
    _pushPage(
      AASendPage(account: account, walletAddress: widget.walletAddress),
    );
  }

  void navigateToBatchTransaction(SmartAccount account) {
    if (!_hasOwnerAddress) {
      _showUnsupportedSnack();
      return;
    }
    _pushPage(
      AABatchTransactionPage(
        account: account,
        walletAddress: widget.walletAddress,
      ),
    );
  }

  void navigateToSessionKeys(SmartAccount account) {
    if (!_hasOwnerAddress) {
      _showUnsupportedSnack();
      return;
    }
    _pushPage(SessionKeyManagePage(account: account));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(text: S.of(context).g_key_aa_title),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildHeaderCard(),
            SizedBox(height: ScreenUtil().setWidth(24)),
            buildFeatureCards(),
            SizedBox(height: ScreenUtil().setWidth(24)),
            buildAdvancedFeatures(),
            SizedBox(height: ScreenUtil().setWidth(24)),
            buildAccountsSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _hasOwnerAddress
            ? navigateToCreateAccount
            : _showUnsupportedSnack,
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
