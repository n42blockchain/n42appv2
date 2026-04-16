import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/privacy_redaction_utils.dart';
import '../../../data/datasources/local/preferences_datasource.dart';
import '../../../domain/entities/user_profile_entity.dart';
import '../../widgets/common/common_widgets.dart';
import 'quick_replies_page.dart';
import 'translation_settings_page.dart';
import 'backup_restore_page.dart';
import 'storage_management_page.dart';
import 'auto_download_settings_page.dart';
import 'privacy_security_page.dart';
import 'system_accounts_page.dart';

/// 设置页面
class SettingsPage extends StatelessWidget {
  final UserProfileEntity? profile;
  final VoidCallback? onEditProfile;
  final VoidCallback? onNotification;
  final VoidCallback? onPrivacy;
  final VoidCallback? onAppearance;
  final VoidCallback? onChat;
  final VoidCallback? onLanguage;
  final VoidCallback? onSecurity;
  final VoidCallback? onAccounts;
  final VoidCallback? onChangePassword;
  final VoidCallback? onChangeEmail;
  final VoidCallback? onAbout;
  final VoidCallback? onLogout;

  /// 生物识别登录相关
  final bool isBiometricAvailable;
  final bool isBiometricEnabled;
  final String? biometricTypeDescription;
  final ValueChanged<bool>? onBiometricToggle;

  const SettingsPage({
    super.key,
    this.profile,
    this.onEditProfile,
    this.onNotification,
    this.onPrivacy,
    this.onAppearance,
    this.onChat,
    this.onLanguage,
    this.onSecurity,
    this.onAccounts,
    this.onChangePassword,
    this.onChangeEmail,
    this.onAbout,
    this.onLogout,
    this.isBiometricAvailable = false,
    this.isBiometricEnabled = false,
    this.biometricTypeDescription,
    this.onBiometricToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: N42AppBar(
        title: S.of(context)?.commonSettings ?? 'Settings',
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: ListView(
        children: [
          // 个人资料卡片
          if (profile != null) _buildProfileCard(context, isDark),

          const SizedBox(height: 16),

          // 设置组1：通知与隐私安全
          _SettingsGroup(
            children: [
              _SettingsItem(
                icon: Icons.notifications_outlined,
                iconColor: Colors.red,
                title:
                    S.of(context)?.settingsNotificationSettings ??
                    'Notifications',
                onTap: onNotification,
                isDark: isDark,
              ),
              _SettingsItem(
                icon: Icons.shield_moon_outlined,
                iconColor: Colors.blue,
                title: 'Privacy & Security',
                subtitle:
                    'E2EE, disappearing messages, screenshot protection, and proxies',
                onTap: () => _navigateToPrivacySecurity(context),
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 设置组2：外观、聊天与语言
          _SettingsGroup(
            children: [
              _SettingsItem(
                icon: Icons.palette_outlined,
                iconColor: Colors.purple,
                title: S.of(context)?.settingsAppearance ?? 'Appearance',
                onTap: onAppearance,
                isDark: isDark,
              ),
              _SettingsItem(
                icon: Icons.chat_outlined,
                iconColor: Colors.green,
                title: S.of(context)?.commonChat ?? 'Chat',
                onTap: onChat,
                isDark: isDark,
              ),
              _SettingsItem(
                icon: Icons.flash_on_outlined,
                iconColor: Colors.orange,
                title: S.of(context)?.settingsQuickReply ?? 'Quick Reply',
                onTap: () => _navigateToQuickReplies(context),
                isDark: isDark,
              ),
              _SettingsItem(
                icon: Icons.language_outlined,
                iconColor: Colors.blue,
                title: S.of(context)?.settingsLanguage ?? 'Language',
                onTap: onLanguage,
                isDark: isDark,
              ),
              _SettingsItem(
                icon: Icons.translate,
                iconColor: Colors.teal,
                title: S.of(context)?.settingsTranslation ?? 'Translation',
                onTap: () => _navigateToTranslation(context),
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 设置组2.5：存储与下载
          _SettingsGroup(
            children: [
              _SettingsItem(
                icon: Icons.storage,
                iconColor: Colors.blueGrey,
                title: S.of(context)?.storageManagement ?? 'Storage',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const StorageManagementPage(),
                    ),
                  );
                },
                isDark: isDark,
              ),
              _SettingsItem(
                icon: Icons.download,
                iconColor: Colors.lightBlue,
                title: S.of(context)?.autoDownload ?? 'Auto-Download',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AutoDownloadSettingsPage(),
                    ),
                  );
                },
                isDark: isDark,
              ),
              _SettingsItem(
                icon: Icons.backup,
                iconColor: Colors.deepOrange,
                title: 'Backup & Restore',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const BackupRestorePage(),
                    ),
                  );
                },
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 设置组2.8：System & Accounts
          _SettingsGroup(
            children: [
              _SettingsItem(
                icon: Icons.settings_suggest_outlined,
                iconColor: Colors.indigo,
                title: 'System & Accounts',
                subtitle:
                    'Accounts, devices, usernames, notifications, and bridges',
                onTap: () => _navigateToSystemAccounts(context),
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 设置组3：账号安全
          _SettingsGroup(
            children: [
              if (isBiometricAvailable)
                _SettingsItem(
                  icon: biometricTypeDescription?.contains('Face') == true
                      ? Icons.face
                      : Icons.fingerprint,
                  iconColor: Colors.green,
                  title:
                      S.of(context)?.settingsBiometricLogin ??
                      'Biometric Login',
                  subtitle: biometricTypeDescription,
                  trailing: Switch(
                    value: isBiometricEnabled,
                    onChanged: onBiometricToggle,
                    activeTrackColor: AppColors.primary,
                  ),
                  onTap: onBiometricToggle != null
                      ? () => onBiometricToggle!(!isBiometricEnabled)
                      : null,
                  isDark: isDark,
                ),
              _SettingsItem(
                icon: Icons.lock_outline,
                iconColor: Colors.indigo,
                title:
                    S.of(context)?.settingsChangePassword ?? 'Change Password',
                onTap: onChangePassword,
                isDark: isDark,
              ),
              _SettingsItem(
                icon: Icons.email_outlined,
                iconColor: Colors.cyan,
                title: S.of(context)?.commonChangeEmail ?? 'Change Email',
                onTap: onChangeEmail,
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 设置组4：关于
          _SettingsGroup(
            children: [
              _SettingsItem(
                icon: Icons.info_outline,
                iconColor: Colors.orange,
                title: S.of(context)?.settingsAbout ?? 'About',
                onTap: onAbout,
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // 退出登录按钮
          if (onLogout != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: N42Button.danger(
                text: S.of(context)?.commonLogout ?? 'Log Out',
                onPressed: () => _showLogoutConfirmDialog(context),
              ),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, bool isDark) {
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onEditProfile,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                N42Avatar(
                  imageUrl: profile!.avatarUrl,
                  name: profile!.effectiveDisplayName,
                  size: 64,
                  decorationPreset: profile!.avatarDecorationPreset,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FutureBuilder<PrivacySettings>(
                    future: getIt<PreferencesDataSource>()
                        .getPrivacySettingsModel(),
                    builder: (context, snapshot) {
                      final hidePhoneNumber =
                          snapshot.data?.hidePhoneNumber ?? false;
                      final phoneNumber = hidePhoneNumber
                          ? maskPhoneNumber(profile!.phoneNumber)
                          : profile!.phoneNumber?.trim();
                      final email = profile!.email?.trim();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile!.effectiveDisplayName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profile!.userId,
                            style: TextStyle(
                              fontSize: 13,
                              color: secondaryColor,
                            ),
                          ),
                          if (phoneNumber != null &&
                              phoneNumber.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              phoneNumber,
                              style: TextStyle(
                                fontSize: 13,
                                color: secondaryColor,
                              ),
                            ),
                          ],
                          if (email != null && email.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: TextStyle(
                                fontSize: 13,
                                color: secondaryColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (profile!.statusMessage != null &&
                              profile!.statusMessage!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              profile!.statusMessage!,
                              style: TextStyle(
                                fontSize: 13,
                                color: secondaryColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToSystemAccounts(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SystemAccountsPage(
          onOpenAccounts: onAccounts == null
              ? null
              : () async {
                  onAccounts!.call();
                },
          onOpenSecuritySettings: onSecurity == null
              ? null
              : () async {
                  onSecurity!.call();
                },
        ),
      ),
    );
  }

  void _navigateToPrivacySecurity(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PrivacySecurityPage(
          onOpenPrivacySettings: onPrivacy == null
              ? null
              : () async {
                  onPrivacy!.call();
                },
          onOpenSecuritySettings: onSecurity == null
              ? null
              : () async {
                  onSecurity!.call();
                },
        ),
      ),
    );
  }

  void _navigateToTranslation(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const TranslationSettingsPage()),
    );
  }

  void _navigateToQuickReplies(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            QuickRepliesPage(storageDataSource: getIt<PreferencesDataSource>()),
      ),
    );
  }

  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context)?.commonLogout ?? 'Log Out'),
        content: Text(
          S.of(context)?.commonLogoutConfirm ??
              'Are you sure you want to log out?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onLogout?.call();
            },
            child: Text(
              S.of(context)?.commonLogout ?? 'Log Out',
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// 设置组
class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      child: Column(
        children: List.generate(children.length * 2 - 1, (index) {
          if (index.isOdd) {
            return Padding(
              padding: const EdgeInsets.only(left: 56),
              child: Divider(
                height: 1,
                color: isDark ? AppColors.dividerDark : AppColors.divider,
              ),
            );
          }
          return children[index ~/ 2];
        }),
      ),
    );
  }
}

/// 设置项
class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDark;

  const _SettingsItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              trailing ??
                  Icon(
                    Icons.chevron_right,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
