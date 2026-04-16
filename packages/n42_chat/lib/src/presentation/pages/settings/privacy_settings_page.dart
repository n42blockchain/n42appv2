import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/services/screenshot_protection_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/local/preferences_datasource.dart';
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../../domain/entities/user_profile_entity.dart';
import '../../blocs/conversation/conversation_bloc.dart';
import '../../blocs/conversation/conversation_event.dart';
import '../../helpers/privacy_security_summary_helper.dart';
import '../../widgets/common/common_widgets.dart';
import 'hidden_chats_page.dart';

/// 隐私设置页面
class PrivacySettingsPage extends StatefulWidget {
  final PrivacySettings settings;
  final void Function(PrivacySettings)? onSave;
  final void Function(dynamic conversation)? onConversationTap;

  const PrivacySettingsPage({
    super.key,
    required this.settings,
    this.onSave,
    this.onConversationTap,
  });

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  late PrivacySettings _settings;
  bool _screenshotProtection = false;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
    _loadScreenshotProtection();
  }

  Future<void> _loadScreenshotProtection() async {
    await ScreenshotProtectionService.instance.initialize();
    if (mounted) {
      setState(() {
        _screenshotProtection =
            ScreenshotProtectionService.instance.isGlobalEnabled;
      });
    }
  }

  void _updateSettings(PrivacySettings newSettings) {
    if (!mounted) return;
    setState(() => _settings = newSettings);
    unawaited(_persistSettings(newSettings));
    widget.onSave?.call(newSettings);
  }

  Future<void> _persistSettings(PrivacySettings settings) async {
    try {
      await getIt<PreferencesDataSource>().savePrivacySettingsModel(settings);
      await MatrixClientManager.instance.updateNetworkPrivacy(settings);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save privacy settings: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final l10n = S.of(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: N42AppBar(
        title: l10n?.settingsPrivacy ?? 'Privacy',
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // 可见性设置
          _buildSectionHeader(l10n?.settingsWhoCanSee ?? 'Who can see', isDark),
          Container(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            child: Column(
              children: [
                _buildVisibilityItem(
                  context,
                  l10n?.profileAvatar ?? 'Avatar',
                  Icons.account_circle_outlined,
                  _settings.avatarVisibility,
                  (value) => _updateSettings(
                    _settings.copyWith(avatarVisibility: value),
                  ),
                  isDark,
                ),
                _buildDivider(isDark),
                _buildVisibilityItem(
                  context,
                  l10n?.profileStatus ?? 'Status',
                  Icons.info_outline,
                  _settings.statusVisibility,
                  (value) => _updateSettings(
                    _settings.copyWith(statusVisibility: value),
                  ),
                  isDark,
                ),
                _buildDivider(isDark),
                _buildVisibilityItem(
                  context,
                  l10n?.settingsLastSeen ?? 'Last Seen',
                  Icons.access_time,
                  _settings.lastSeenVisibility,
                  (value) => _updateSettings(
                    _settings.copyWith(lastSeenVisibility: value),
                  ),
                  isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _buildSectionHeader('Privacy Hardening', isDark),
          Container(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            child: Column(
              children: [
                _buildSwitchTile(
                  title: 'Hide Phone Number',
                  subtitle:
                      'Mask any bound phone number in profile-level surfaces on this device',
                  icon: Icons.phone_disabled_outlined,
                  value: _settings.hidePhoneNumber,
                  onChanged: (value) => _updateSettings(
                    _settings.copyWith(hidePhoneNumber: value),
                  ),
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildSwitchTile(
                  title: 'Encrypt New Chats By Default',
                  subtitle:
                      'Start new direct chats and private rooms with E2EE enabled',
                  icon: Icons.enhanced_encryption_outlined,
                  value: _settings.defaultEncryptNewChats,
                  onChanged: (value) => _updateSettings(
                    _settings.copyWith(defaultEncryptNewChats: value),
                  ),
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildSwitchTile(
                  title: 'Private Chat Mode',
                  subtitle:
                      'Temporarily enable screenshot blocking when viewing private or encrypted chats',
                  icon: Icons.lock_person_outlined,
                  value: _settings.privateChatMode,
                  onChanged: (value) => _updateSettings(
                    _settings.copyWith(privateChatMode: value),
                  ),
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildValueItem(
                  title: 'Default Auto-Destruct Timer',
                  subtitle:
                      'Apply a default self-destruct timer to newly sent messages',
                  icon: Icons.timer_outlined,
                  value: _formatSelfDestructDuration(
                    _settings.defaultSelfDestructSeconds,
                  ),
                  onTap: _pickDefaultSelfDestructDuration,
                  isDark: isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _buildSectionHeader('Network Privacy', isDark),
          Container(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            child: Column(
              children: [
                _buildSwitchTile(
                  title: 'Link Previews',
                  subtitle:
                      'Fetch titles, descriptions, and thumbnails when messages contain URLs',
                  icon: Icons.link_outlined,
                  value: _settings.showLinkPreviews,
                  onChanged: (value) => _updateSettings(
                    _settings.copyWith(showLinkPreviews: value),
                  ),
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildSwitchTile(
                  title: 'IP Address Protection',
                  subtitle:
                      'Route Matrix and link-preview requests through your configured HTTP privacy proxy when available',
                  icon: Icons.shield_outlined,
                  value: _settings.protectIpAddress,
                  onChanged: (value) => _updateSettings(
                    _settings.copyWith(protectIpAddress: value),
                  ),
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildSwitchTile(
                  title: 'Use Tor / Privoxy HTTP Proxy',
                  subtitle:
                      'Use a local HTTP proxy endpoint such as Privoxy on 127.0.0.1:8118. Native SOCKS5 Tor routing is not supported here.',
                  icon: Icons.travel_explore_outlined,
                  value: _settings.useTor,
                  onChanged: (value) => _updateSettings(
                    _settings.copyWith(
                      useTor: value,
                      proxyEnabled: value ? false : _settings.proxyEnabled,
                    ),
                  ),
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildSwitchTile(
                  title: 'Custom Proxy',
                  subtitle:
                      'Use a custom HTTP or HTTPS proxy for Matrix traffic and link previews',
                  icon: Icons.route_outlined,
                  value: _settings.proxyEnabled,
                  onChanged: (value) async {
                    await _handleCustomProxyToggle(value);
                  },
                  isDark: isDark,
                ),
                if (_settings.proxyEnabled) ...[
                  _buildDivider(isDark),
                  _buildValueItem(
                    title: 'Proxy Endpoint',
                    subtitle: 'HTTP/HTTPS proxy address (SOCKS not supported)',
                    icon: Icons.dns_outlined,
                    value: _settings.proxyUrl?.trim().isNotEmpty == true
                        ? (PrivacySecuritySummaryHelper.hasValidCustomProxy(
                                _settings,
                              )
                              ? _settings.proxyUrl!.trim()
                              : 'Invalid endpoint')
                        : 'Not set',
                    onTap: _editProxyUrl,
                    isDark: isDark,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 隐藏聊天入口
          _buildSectionHeader(l10n?.commonChat ?? 'Chat', isDark),
          Container(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            child: Column(
              children: [
                _buildNavigationItem(
                  context,
                  l10n?.settingsHiddenChats ?? 'Hidden Chats',
                  Icons.visibility_off_outlined,
                  () => _navigateToHiddenChats(context),
                  isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 消息设置
          _buildSectionHeader(
            l10n?.settingsMessagesLabel ?? 'Messages',
            isDark,
          ),
          Container(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            child: Column(
              children: [
                _buildSwitchTile(
                  title:
                      l10n?.settingsAllowStrangerMessages ??
                      'Allow Stranger Messages',
                  subtitle:
                      l10n?.settingsReceiveMessagesFromNonContacts ??
                      'Receive messages from non-contacts',
                  icon: Icons.person_add_outlined,
                  value: _settings.allowStrangerMessage,
                  onChanged: (value) => _updateSettings(
                    _settings.copyWith(allowStrangerMessage: value),
                  ),
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildSwitchTile(
                  title: l10n?.settingsReadReceipts ?? 'Read Receipts',
                  subtitle:
                      l10n?.settingsLetOthersKnowYouRead ??
                      'Let others know you read their messages',
                  icon: Icons.done_all,
                  value: _settings.showReadReceipts,
                  onChanged: (value) => _updateSettings(
                    _settings.copyWith(showReadReceipts: value),
                  ),
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildSwitchTile(
                  title: l10n?.settingsTypingIndicator ?? 'Typing Indicator',
                  subtitle:
                      l10n?.settingsLetOthersKnowYouTyping ??
                      'Let others know you are typing',
                  icon: Icons.keyboard,
                  value: _settings.showTypingIndicator,
                  onChanged: (value) => _updateSettings(
                    _settings.copyWith(showTypingIndicator: value),
                  ),
                  isDark: isDark,
                ),
              ],
            ),
          ),

          // 移动端显示截图防护
          if (Platform.isAndroid || Platform.isIOS) ...[
            const SizedBox(height: 16),
            _buildSectionHeader(l10n?.settingsSecurity ?? 'Security', isDark),
            Container(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              child: _buildSwitchTile(
                title:
                    l10n?.settingsScreenshotProtection ??
                    'Screenshot Protection',
                subtitle:
                    l10n?.settingsScreenshotProtectionDesc ??
                    'Prevent screenshots and screen recording',
                icon: Icons.screenshot_monitor_outlined,
                value: _screenshotProtection,
                onChanged: (value) async {
                  await ScreenshotProtectionService.instance.setEnabled(value);
                  if (mounted) setState(() => _screenshotProtection = value);
                },
                isDark: isDark,
                iconColor: Colors.red,
              ),
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 56),
      child: Divider(
        height: 1,
        color: isDark ? AppColors.dividerDark : AppColors.divider,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor ?? AppColors.primary,
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
                    subtitle,
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildValueItem({
    required String title,
    String? subtitle,
    required IconData icon,
    required String value,
    required VoidCallback onTap,
    required bool isDark,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor ?? AppColors.primary,
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
                      subtitle,
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
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisibilityItem(
    BuildContext context,
    String title,
    IconData icon,
    VisibilityLevel value,
    void Function(VisibilityLevel) onChanged,
    bool isDark,
  ) {
    return InkWell(
      onTap: () => _showVisibilityPicker(context, title, value, onChanged),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              _getVisibilityLabel(context, value),
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  String _getVisibilityLabel(BuildContext context, VisibilityLevel level) {
    final l10n = S.of(context);
    switch (level) {
      case VisibilityLevel.everyone:
        return l10n?.settingsEveryone ?? 'Everyone';
      case VisibilityLevel.contacts:
        return l10n?.settingsContactsOnly ?? 'Contacts Only';
      case VisibilityLevel.nobody:
        return l10n?.settingsNobody ?? 'Nobody';
    }
  }

  Widget _buildNavigationItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
    bool isDark,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
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
    );
  }

  void _navigateToHiddenChats(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) =>
              getIt<ConversationBloc>()..add(const LoadHiddenConversations()),
          child: HiddenChatsPage(
            onConversationTap: widget.onConversationTap != null
                ? (conversation) => widget.onConversationTap!(conversation)
                : null,
          ),
        ),
      ),
    );
  }

  Future<void> _showVisibilityPicker(
    BuildContext context,
    String title,
    VisibilityLevel currentValue,
    void Function(VisibilityLevel) onChanged,
  ) async {
    final result = await showModalBottomSheet<VisibilityLevel>(
      context: context,
      builder: (ctx) =>
          _VisibilityPickerSheet(title: title, currentValue: currentValue),
    );

    if (result != null) {
      onChanged(result);
    }
  }

  Future<void> _pickDefaultSelfDestructDuration() async {
    final durations = <int?>[null, 30, 300, 3600, 86400];
    final result = await showModalBottomSheet<Object?>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: durations
              .map(
                (seconds) => ListTile(
                  title: Text(_formatSelfDestructDuration(seconds)),
                  trailing: _settings.defaultSelfDestructSeconds == seconds
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () => Navigator.pop(ctx, seconds ?? 'off'),
                ),
              )
              .toList(),
        ),
      ),
    );

    if (result == null) {
      return;
    }

    _updateSettings(
      _settings.copyWith(
        defaultSelfDestructSeconds: result == 'off' ? null : result as int?,
      ),
    );
  }

  Future<void> _editProxyUrl() async {
    final value = await _showProxyUrlEditor(_settings.proxyUrl ?? '');
    if (value == null) {
      return;
    }
    _saveProxyUrl(value, enableProxyAfterSave: _settings.proxyEnabled);
  }

  Future<void> _handleCustomProxyToggle(bool value) async {
    if (!value) {
      _updateSettings(_settings.copyWith(proxyEnabled: false));
      return;
    }

    if (PrivacySecuritySummaryHelper.hasValidCustomProxy(_settings)) {
      _updateSettings(_settings.copyWith(proxyEnabled: true, useTor: false));
      return;
    }

    final valueFromDialog = await _showProxyUrlEditor(_settings.proxyUrl ?? '');
    if (valueFromDialog == null) {
      return;
    }
    _saveProxyUrl(valueFromDialog, enableProxyAfterSave: true);
  }

  Future<String?> _showProxyUrlEditor(String initialValue) async {
    final controller = TextEditingController(text: initialValue);
    try {
      return await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Proxy Endpoint'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'http://127.0.0.1:7890',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.url,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () {
                final text = controller.text.trim();
                Navigator.pop(ctx, text);
              },
              child: Text(S.of(context)?.commonSave ?? 'Save'),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  void _saveProxyUrl(String value, {required bool enableProxyAfterSave}) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      _updateSettings(
        _settings.copyWith(
          proxyUrl: '',
          proxyEnabled: enableProxyAfterSave ? false : _settings.proxyEnabled,
        ),
      );
      if (enableProxyAfterSave && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Custom proxy stays off until you set a valid endpoint',
            ),
          ),
        );
      }
      return;
    }

    final error = PrivacySecuritySummaryHelper.validateCustomProxyUrl(trimmed);
    if (error != null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
      return;
    }

    _updateSettings(
      _settings.copyWith(
        proxyUrl: trimmed,
        proxyEnabled: enableProxyAfterSave ? true : _settings.proxyEnabled,
        useTor: false,
      ),
    );
  }

  String _formatSelfDestructDuration(int? seconds) {
    if (seconds == null || seconds <= 0) {
      return 'Off';
    }
    if (seconds < 60) {
      return '${seconds}s';
    }
    if (seconds < 3600) {
      return '${seconds ~/ 60}m';
    }
    if (seconds < 86400) {
      return '${seconds ~/ 3600}h';
    }
    return '${seconds ~/ 86400}d';
  }
}

class _VisibilityPickerSheet extends StatelessWidget {
  final String title;
  final VisibilityLevel currentValue;

  const _VisibilityPickerSheet({
    required this.title,
    required this.currentValue,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final l10n = S.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n?.settingsWhoCanSeeTitle(title) ?? 'Who can see $title',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
            const Divider(height: 1),
            ...VisibilityLevel.values.map(
              (level) => ListTile(
                title: Text(_getLabel(context, level)),
                trailing: currentValue == level
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.pop(context, level),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLabel(BuildContext context, VisibilityLevel level) {
    final l10n = S.of(context);
    switch (level) {
      case VisibilityLevel.everyone:
        return l10n?.settingsEveryone ?? 'Everyone';
      case VisibilityLevel.contacts:
        return l10n?.settingsContactsOnly ?? 'Contacts Only';
      case VisibilityLevel.nobody:
        return l10n?.settingsNobody ?? 'Nobody';
    }
  }
}
