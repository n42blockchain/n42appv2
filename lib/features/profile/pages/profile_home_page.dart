// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/hardware_wallet/pages/hardware_wallet_page.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/wallet_list.dart';
import 'package:n42_wallet/features/wallet/pages/address_book/address_book_list.dart';
import 'package:n42_wallet/features/home/setting/security/security_setting.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_backup/export_cloud_backup.dart';
import 'package:n42_wallet/features/home/setting/setting_sys_language.dart';
import 'package:n42_wallet/features/home/setting/setting_theme.dart';
import 'package:n42_wallet/features/wallet/pages/manage_chains_page.dart';
import 'package:n42_wallet/features/home/setting/about_app.dart';

part 'profile_home_page_widgets.dart';

/// 我的页面
///
/// 聚合用户设置、安全、硬件钱包等功能
class ProfileHomePage extends ConsumerWidget {
  const ProfileHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 顶部用户信息
            SliverToBoxAdapter(child: _buildUserHeader(context, ref)),

            // 钱包管理区域
            SliverToBoxAdapter(child: _buildWalletSection(context)),

            // 安全设置
            SliverToBoxAdapter(child: _buildSecuritySection(context)),

            // 通用设置
            SliverToBoxAdapter(child: _buildGeneralSection(context)),

            // 关于与支持
            SliverToBoxAdapter(child: _buildAboutSection(context)),

            // 底部间距
            SliverToBoxAdapter(
              child: SizedBox(height: ScreenUtil().setWidth(100)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
      child: Row(
        children: [
          // 用户头像
          Container(
            width: ScreenUtil().setWidth(80),
            height: ScreenUtil().setWidth(80),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColorTokens.of(context).brand,
                  AppColorTokens.of(context).brand.withAlpha(180),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppRadius.brMd,
            ),
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: ScreenUtil().setWidth(48),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(20)),

          // 用户信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Wallet',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(36),
                    fontWeight: FontWeight.w600,
                    color: AppColorTokens.of(context).textPrimary,
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(4)),
                Text(
                  'Manage your settings',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    color: AppColorTokens.of(context).textSubtitle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletSection(BuildContext context) {
    return _buildSection(context, 'Wallet', [
      _buildMenuItem(
        context,
        'Wallet Management',
        'Manage your wallets',
        Icons.account_balance_wallet,
        Colors.blue,
        () => _navigateToWalletManagement(context),
      ),
      _buildMenuItem(
        context,
        'Hardware Wallet',
        'Connect Ledger device',
        Icons.usb,
        Colors.purple,
        () => _navigateToHardwareWallet(context),
        isNew: true,
      ),
      _buildMenuItem(
        context,
        'Address Book',
        'Saved addresses',
        Icons.contacts,
        Colors.green,
        () => _navigateToAddressBook(context),
      ),
      _buildMenuItem(
        context,
        'Transaction History',
        'View all transactions',
        Icons.history,
        Colors.orange,
        () => _navigateToTransactionHistory(context),
      ),
    ]);
  }

  Widget _buildSecuritySection(BuildContext context) {
    return _buildSection(context, 'Security', [
      _buildMenuItem(
        context,
        'Security Settings',
        'Protect your wallet',
        Icons.security,
        Colors.red,
        () => _navigateToSecuritySettings(context),
      ),
      _buildMenuItem(
        context,
        'Backup Wallet',
        'Backup your recovery phrase',
        Icons.backup,
        Colors.amber,
        () => _navigateToBackupWallet(context),
      ),
      _buildMenuItem(
        context,
        'Biometric Auth',
        'Face ID / Fingerprint',
        Icons.fingerprint,
        Colors.teal,
        () => _navigateToBiometricSettings(context),
      ),
    ]);
  }

  Widget _buildGeneralSection(BuildContext context) {
    return _buildSection(context, 'General', [
      _buildMenuItem(
        context,
        'Language',
        'Display language',
        Icons.language,
        Colors.indigo,
        () => _navigateToLanguageSettings(context),
        trailing: Text(
          'English',
          style: TextStyle(
            fontSize: ScreenUtil().setSp(26),
            color: AppColorTokens.of(context).textSubtitle,
          ),
        ),
      ),
      _buildMenuItem(
        context,
        'Currency',
        'Display currency',
        Icons.attach_money,
        Colors.green,
        () => _navigateToCurrencySettings(context),
        trailing: Text(
          'USD',
          style: TextStyle(
            fontSize: ScreenUtil().setSp(26),
            color: AppColorTokens.of(context).textSubtitle,
          ),
        ),
      ),
      _buildMenuItem(
        context,
        'Theme',
        'Light / Dark mode',
        Icons.palette,
        Colors.pink,
        () => _navigateToThemeSettings(context),
      ),
      _buildMenuItem(
        context,
        'Network',
        'RPC settings',
        Icons.wifi,
        Colors.cyan,
        () => _navigateToNetworkSettings(context),
      ),
    ]);
  }

  Widget _buildAboutSection(BuildContext context) {
    return _buildSection(context, 'About', [
      _buildMenuItem(
        context,
        'Rate Us',
        'Love the app? Rate us!',
        Icons.star_outline,
        Colors.amber,
        () => _rateApp(context),
      ),
      _buildMenuItem(
        context,
        'About N42',
        'Version 2.0.0',
        Icons.info_outline,
        Colors.grey,
        () => _navigateToAbout(context),
      ),
    ]);
  }
}
