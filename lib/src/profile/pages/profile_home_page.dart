// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/hardware_wallet/pages/hardware_wallet_page.dart';

/// 我的页面
///
/// 聚合用户设置、安全、硬件钱包等功能
class ProfileHomePage extends StatelessWidget {
  const ProfileHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 顶部用户信息
            SliverToBoxAdapter(
              child: _buildUserHeader(context),
            ),

            // 钱包管理区域
            SliverToBoxAdapter(
              child: _buildWalletSection(context),
            ),

            // 安全设置
            SliverToBoxAdapter(
              child: _buildSecuritySection(context),
            ),

            // 通用设置
            SliverToBoxAdapter(
              child: _buildGeneralSection(context),
            ),

            // 关于与支持
            SliverToBoxAdapter(
              child: _buildAboutSection(context),
            ),

            // 底部间距
            SliverToBoxAdapter(
              child: SizedBox(height: ScreenUtil().setWidth(100)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
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
                  AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                  AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
                      .withAlpha(180),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
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
                    fontWeight: FontWeight.bold,
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(4)),
                Text(
                  'Manage your settings',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemSubtitleTextColor.name,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 通知按钮
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  // TODO: 导航到通知页面
                },
                icon: Icon(
                  Icons.notifications_outlined,
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  size: ScreenUtil().setWidth(36),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: ScreenUtil().setWidth(16),
                  height: ScreenUtil().setWidth(16),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWalletSection(BuildContext context) {
    return _buildSection(
      context,
      'Wallet',
      [
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
      ],
    );
  }

  Widget _buildSecuritySection(BuildContext context) {
    return _buildSection(
      context,
      'Security',
      [
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
      ],
    );
  }

  Widget _buildGeneralSection(BuildContext context) {
    return _buildSection(
      context,
      'General',
      [
        _buildMenuItem(
          context,
          'Language',
          'English',
          Icons.language,
          Colors.indigo,
          () => _navigateToLanguageSettings(context),
          trailing: Text(
            'English',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
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
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
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
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return _buildSection(
      context,
      'About',
      [
        _buildMenuItem(
          context,
          'Help Center',
          'FAQ & Support',
          Icons.help_outline,
          Colors.blue,
          () => _navigateToHelpCenter(context),
        ),
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
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30),
        vertical: ScreenUtil().setWidth(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.bold,
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          Container(
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
            ),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    Widget? trailing,
    bool isNew = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      child: Padding(
        padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
        child: Row(
          children: [
            // 图标
            Container(
              width: ScreenUtil().setWidth(48),
              height: ScreenUtil().setWidth(48),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
              ),
              child: Icon(
                icon,
                color: color,
                size: ScreenUtil().setWidth(28),
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(16)),

            // 内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(28),
                          fontWeight: FontWeight.w500,
                          color: AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.mainTextColor.name,
                          ),
                        ),
                      ),
                      if (isNew) ...[
                        SizedBox(width: ScreenUtil().setWidth(8)),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(8),
                            vertical: ScreenUtil().setWidth(2),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
                          ),
                          child: Text(
                            'NEW',
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(18),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: ScreenUtil().setWidth(2)),
                  Text(
                    subtitle,
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

            // 尾部
            trailing ??
                Icon(
                  Icons.chevron_right,
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemSubtitleTextColor.name,
                  ),
                  size: ScreenUtil().setWidth(28),
                ),
          ],
        ),
      ),
    );
  }

  // Navigation methods
  void _navigateToWalletManagement(BuildContext context) {
    // TODO: Navigate to wallet management
  }

  void _navigateToHardwareWallet(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HardwareWalletPage()),
    );
  }

  void _navigateToAddressBook(BuildContext context) {
    // TODO: Navigate to address book
  }

  void _navigateToTransactionHistory(BuildContext context) {
    // TODO: Navigate to transaction history
  }

  void _navigateToSecuritySettings(BuildContext context) {
    // TODO: Navigate to security settings
  }

  void _navigateToBackupWallet(BuildContext context) {
    // TODO: Navigate to backup wallet
  }

  void _navigateToBiometricSettings(BuildContext context) {
    // TODO: Navigate to biometric settings
  }

  void _navigateToLanguageSettings(BuildContext context) {
    // TODO: Navigate to language settings
  }

  void _navigateToCurrencySettings(BuildContext context) {
    // TODO: Navigate to currency settings
  }

  void _navigateToThemeSettings(BuildContext context) {
    // TODO: Navigate to theme settings
  }

  void _navigateToNetworkSettings(BuildContext context) {
    // TODO: Navigate to network settings
  }

  void _navigateToHelpCenter(BuildContext context) {
    // TODO: Navigate to help center
  }

  void _rateApp(BuildContext context) {
    // TODO: Open app store rating
  }

  void _navigateToAbout(BuildContext context) {
    // TODO: Navigate to about page
  }
}
