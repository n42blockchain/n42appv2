import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';

/// 关于页面
class AboutPage extends StatelessWidget {
  final String appName;
  final String version;
  final String? buildNumber;
  final VoidCallback? onCheckUpdate;
  final VoidCallback? onPrivacyPolicy;
  final VoidCallback? onTermsOfService;
  final VoidCallback? onOpenSource;
  final VoidCallback? onFeedback;

  const AboutPage({
    super.key,
    this.appName = 'N42 Chat',
    this.version = '1.0.0',
    this.buildNumber,
    this.onCheckUpdate,
    this.onPrivacyPolicy,
    this.onTermsOfService,
    this.onOpenSource,
    this.onFeedback,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final l10n = S.of(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: N42AppBar(
        title: l10n?.settingsAbout ?? 'About',
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 32),

          // App图标和名称
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.chat,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  appName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n?.settingsVersionInfo(version) ?? 'Version $version',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 检查更新
          if (onCheckUpdate != null) ...[
            Container(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              child: ListTile(
                title: Text(
                  l10n?.settingsCheckForUpdates ?? 'Check for Updates',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
                onTap: onCheckUpdate,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 链接列表
          Container(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            child: Column(
              children: [
                if (onPrivacyPolicy != null)
                  _buildLinkItem(l10n?.authPrivacyPolicy ?? 'Privacy Policy', onPrivacyPolicy!, isDark),
                if (onTermsOfService != null) ...[
                  _buildDivider(isDark),
                  _buildLinkItem(l10n?.authTermsOfService ?? 'Terms of Service', onTermsOfService!, isDark),
                ],
                if (onOpenSource != null) ...[
                  _buildDivider(isDark),
                  _buildLinkItem(l10n?.settingsOpenSourceLicenses ?? 'Open Source Licenses', onOpenSource!, isDark),
                ],
                if (onFeedback != null) ...[
                  _buildDivider(isDark),
                  _buildLinkItem(l10n?.settingsFeedbackAndSuggestions ?? 'Feedback & Suggestions', onFeedback!, isDark),
                ],
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 技术说明
          Center(
            child: Column(
              children: [
                Text(
                  l10n?.settingsBuiltOnMatrix ?? 'Built on Matrix Protocol',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '© 2024 N42. All rights reserved.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildLinkItem(String title, VoidCallback onTap, bool isDark) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Divider(
        height: 1,
        color: isDark ? AppColors.dividerDark : AppColors.divider,
      ),
    );
  }
}

