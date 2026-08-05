// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

part of 'profile_home_page.dart';

/// Widget builder methods and navigation for [ProfileHomePage].
extension _ProfileHomePageWidgets on ProfileHomePage {
  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: AppSpacing.space4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColorTokens.of(context).textSubtitle,
            ),
          ),
          SizedBox(height: AppSpacing.space4),
          Container(
            decoration: BoxDecoration(
              color: AppColorTokens.of(context).bgSurface,
              borderRadius: AppRadius.brMd,
            ),
            child: Column(children: children),
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
      borderRadius: AppRadius.brMd,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.space4),
        child: Row(
          children: [
            // 图标
            Container(
              width: ScreenUtil().setWidth(48),
              height: ScreenUtil().setWidth(48),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: AppRadius.brMd,
              ),
              child: Icon(icon, color: color, size: ScreenUtil().setWidth(28)),
            ),
            SizedBox(width: AppSpacing.space4),

            // 内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColorTokens.of(context).textPrimary,
                        ),
                      ),
                      if (isNew) ...[
                        SizedBox(width: AppSpacing.space2),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.space2,
                            vertical: AppSpacing.space2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColorTokens.of(context).success,
                            borderRadius: AppRadius.brSm,
                          ),
                          child: Text(
                            'NEW',
                            style: AppTypography.captionSm.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: AppSpacing.space2),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(
                      color: AppColorTokens.of(context).textSubtitle,
                    ),
                  ),
                ],
              ),
            ),

            // 尾部
            if (trailing != null) ...[
              trailing,
              SizedBox(width: AppSpacing.space2),
            ],
            Icon(
              Icons.chevron_right,
              color: AppColorTokens.of(context).textSubtitle,
              size: ScreenUtil().setWidth(28),
            ),
          ],
        ),
      ),
    );
  }

  // ── Navigation methods ──────────────────────────────────────────────────

  void _navigateToWalletManagement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WalletList()),
    );
  }

  void _navigateToHardwareWallet(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HardwareWalletPage()),
    );
  }

  void _navigateToAddressBook(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddressBookList()),
    );
  }

  // TransactionHistoryList requires a CoinModel, so navigate to wallet list first.
  // TODO: add a dedicated "all transactions" page that doesn't require pre-selecting a coin.
  void _navigateToTransactionHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WalletList()),
    );
  }

  void _navigateToSecuritySettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SecuritySetting()),
    );
  }

  void _navigateToBackupWallet(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ExportCloudBackup()),
    );
  }

  void _navigateToBiometricSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SecuritySetting()),
    );
  }

  void _navigateToLanguageSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingSysLanguage('')),
    );
  }

  // TODO: create a dedicated currency settings page.
  // Temporarily reuses language settings as no currency page exists yet.
  void _navigateToCurrencySettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingSysLanguage('')),
    );
  }

  void _navigateToThemeSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingTheme()),
    );
  }

  void _navigateToNetworkSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ManageChainsPage()),
    );
  }

  void _rateApp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thank you for your support!')),
    );
  }

  void _navigateToAbout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AboutApp()),
    );
  }
}
