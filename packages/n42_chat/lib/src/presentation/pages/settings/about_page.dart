import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
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
    final l10n = S.of(context);

    return Scaffold(
      backgroundColor: context.pageBackground,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 24,
                    height: 1.3,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n?.settingsVersionInfo(version) ?? 'Version $version',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.3,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 检查更新
          if (onCheckUpdate != null) ...[
            Container(
              color: context.surfaceColor,
              child: ListTile(
                title: Text(
                  l10n?.settingsCheckForUpdates ?? 'Check for Updates',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    height: 1.3,
                    color: context.textPrimary,
                  ),
                ),
                trailing: Icon(
                  AppIcons.chevron,
                  color: context.textSecondary,
                ),
                onTap: onCheckUpdate,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 链接列表
          Container(
            color: context.surfaceColor,
            child: Column(
              children: [
                if (onPrivacyPolicy != null)
                  _buildLinkItem(context, l10n?.authPrivacyPolicy ?? 'Privacy Policy', onPrivacyPolicy!),
                if (onTermsOfService != null) ...[
                  _buildDivider(context),
                  _buildLinkItem(context, l10n?.authTermsOfService ?? 'Terms of Service', onTermsOfService!),
                ],
                if (onOpenSource != null) ...[
                  _buildDivider(context),
                  _buildLinkItem(context, l10n?.settingsOpenSourceLicenses ?? 'Open Source Licenses', onOpenSource!),
                ],
                if (onFeedback != null) ...[
                  _buildDivider(context),
                  _buildLinkItem(context, l10n?.settingsFeedbackAndSuggestions ?? 'Feedback & Suggestions', onFeedback!),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.3,
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '© 2024 N42. All rights reserved.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    color: context.textSecondary,
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

  Widget _buildLinkItem(BuildContext context, String title, VoidCallback onTap) {
    return ListTile(
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          height: 1.3,
          color: context.textPrimary,
        ),
      ),
      trailing: Icon(
        AppIcons.chevron,
        color: context.textSecondary,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Divider(
        height: 1,
        color: context.dividerColor,
      ),
    );
  }
}

