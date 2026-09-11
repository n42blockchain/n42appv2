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

import 'package:n42_wallet/core/constants/language_constants.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/features/wallet/pages/transactions/wallet_activity_page.dart';
import 'package:n42_wallet/features/wallet/pages/gas/gas_tracker_page.dart';
import 'package:n42_wallet/features/wallet/pages/batch_transfer/batch_transfer_select_page.dart';
import 'package:n42_wallet/features/wallet/pages/portfolio/portfolio_page.dart';
import 'package:n42_wallet/features/wallet_connect/pages/wc_session_list_page.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:rate_us_on_store/rate_us_on_store.dart';

part 'profile_home_page_widgets.dart';

/// 我的页面
///
/// 聚合用户设置、安全、硬件钱包等功能
class ProfileHomePage extends ConsumerWidget {
  const ProfileHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).g_key_94)),
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
            SliverToBoxAdapter(child: _buildGeneralSection(context, ref)),

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
      padding: EdgeInsets.all(AppSpacing.space8),
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
          SizedBox(width: AppSpacing.space4),

          // 用户信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).g_key_6,
                  style: AppTypography.title.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColorTokens.of(context).textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.space2),
                Text(
                  S.of(context).g_audit_manage_settings,
                  style: AppTypography.bodySm.copyWith(
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
    return _buildSection(context, S.of(context).g_key_6, [
      _buildMenuItem(
        context,
        S.of(context).g_audit_wallet_management,
        S.of(context).g_audit_manage_wallets,
        Icons.account_balance_wallet,
        AppColorTokens.of(context).brand,
        () => _navigateToWalletManagement(context),
      ),
      _buildMenuItem(
        context,
        S.of(context).g_audit_hardware,
        'Ledger · Keystone · Trezor',
        Icons.usb,
        Colors.purple,
        () => _navigateToHardwareWallet(context),
      ),
      _buildMenuItem(
        context,
        S.of(context).g_key_108,
        S.of(context).g_audit_saved_addresses,
        Icons.contacts,
        AppColorTokens.of(context).success,
        () => _navigateToAddressBook(context),
      ),
      _buildMenuItem(
        context,
        S.of(context).g_key_tran_1,
        S.of(context).g_audit_activity_local,
        Icons.history,
        AppColorTokens.of(context).warning,
        () => _navigateToTransactionHistory(context),
      ),
      _buildMenuItem(
        context,
        S.of(context).g_portfolio_title,
        S.of(context).g_portfolio_all_holdings,
        Icons.pie_chart_outline,
        AppColorTokens.of(context).brand,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PortfolioPage()),
        ),
      ),
      _buildMenuItem(
        context,
        S.of(context).g_audit_gas,
        S.of(context).g_audit_gas_desc,
        Icons.local_gas_station_outlined,
        AppColorTokens.of(context).warning,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GasTrackerPage()),
        ),
      ),
      _buildMenuItem(
        context,
        S.of(context).g_audit_batch,
        S.of(context).g_audit_batch_desc,
        Icons.playlist_add_check,
        AppColorTokens.of(context).brand,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BatchTransferSelectPage()),
        ),
      ),
    ]);
  }

  Widget _buildSecuritySection(BuildContext context) {
    return _buildSection(context, S.of(context).s_key_11, [
      _buildMenuItem(
        context,
        'WalletConnect',
        S.of(context).g_audit_connections_desc,
        Icons.link,
        AppColorTokens.of(context).brand,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WcSessionListPage()),
        ),
      ),

      _buildMenuItem(
        context,
        S.of(context).s_key_11,
        S.of(context).g_audit_protect_wallet,
        Icons.security,
        AppColorTokens.of(context).danger,
        () => _navigateToSecuritySettings(context),
      ),
      _buildMenuItem(
        context,
        S.of(context).g_key_wallet_c38,
        S.of(context).g_audit_encrypted_backup,
        Icons.backup,
        AppColorTokens.of(context).warning,
        () => _navigateToBackupWallet(context),
      ),
      _buildMenuItem(
        context,
        S.of(context).g_audit_biometrics,
        S.of(context).g_audit_biometrics_desc,
        Icons.fingerprint,
        Colors.teal,
        () => _navigateToBiometricSettings(context),
      ),
    ]);
  }

  Widget _buildGeneralSection(BuildContext context, WidgetRef ref) {
    return _buildSection(context, S.of(context).g_key_94, [
      _buildMenuItem(
        context,
        S.of(context).s_key_4,
        S.of(context).g_audit_display_language,
        Icons.language,
        Colors.indigo,
        () => _navigateToLanguageSettings(context, ref),
        trailing: Text(
          getLanguageByCode(
            languageCodeFromLocale(ref.watch(localeProvider)),
          ).name,
          style: AppTypography.bodySm.copyWith(
            color: AppColorTokens.of(context).textSubtitle,
          ),
        ),
      ),
      ListTile(
        leading: Icon(
          Icons.attach_money,
          color: AppColorTokens.of(context).success,
        ),
        title: Text(S.of(context).g_audit_currency),
        subtitle: Text(S.of(context).g_audit_currency_usd),
        trailing: const Text('USD'),
      ),
      _buildMenuItem(
        context,
        S.of(context).g_key_126,
        S.of(context).g_audit_theme_desc,
        Icons.palette,
        Colors.pink,
        () => _navigateToThemeSettings(context),
      ),
      _buildMenuItem(
        context,
        S.of(context).g_mining_key84,
        S.of(context).g_audit_network_desc,
        Icons.wifi,
        Colors.cyan,
        () => _navigateToNetworkSettings(context),
      ),
    ]);
  }

  Widget _buildAboutSection(BuildContext context) {
    return _buildSection(context, S.of(context).g_key_m_6, [
      _buildMenuItem(
        context,
        S.of(context).g_audit_rate,
        S.of(context).g_audit_rate_desc,
        Icons.star_outline,
        AppColorTokens.of(context).warning,
        () => _rateApp(context),
      ),
      _buildMenuItem(
        context,
        S.of(context).g_key_m_6,
        S.of(context).g_audit_about_desc,
        Icons.info_outline,
        AppColorTokens.of(context).textTertiary,
        () => _navigateToAbout(context),
      ),
    ]);
  }
}
