import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../n42_chat.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../domain/entities/user_profile_entity.dart';
import '../../widgets/common/common_widgets.dart';
import 'notification_filter_page.dart';

/// 通知设置页面
class NotificationSettingsPage extends StatefulWidget {
  final NotificationSettings settings;
  final FutureOr<void> Function(NotificationSettings)? onSave;

  const NotificationSettingsPage({
    super.key,
    required this.settings,
    this.onSave,
  });

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  late NotificationSettings _settings;
  late NotificationSettings _savedSettings;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
    _savedSettings = widget.settings;
  }

  Future<void> _updateSettings(NotificationSettings newSettings) async {
    if (!mounted || _isSaving) return;
    setState(() {
      _settings = newSettings;
      _isSaving = true;
    });
    try {
      if (widget.onSave != null) {
        await widget.onSave!(newSettings);
      } else {
        await N42Chat.applyNotificationSettings(newSettings);
      }
      _savedSettings = newSettings;
    } catch (_) {
      if (mounted) {
        setState(() => _settings = _savedSettings);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context)?.commonSaveFailed ?? 'Failed to save'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _privacyModeLabel(NotificationPrivacyMode mode) {
    final l10n = S.of(context);
    switch (mode) {
      case NotificationPrivacyMode.full:
        return l10n?.settingsShowMessagePreview ?? 'Show sender and message';
      case NotificationPrivacyMode.senderOnly:
        return l10n?.settingsSenderOnly ?? 'Show sender only';
      case NotificationPrivacyMode.hidden:
        return l10n?.settingsHiddenNotification ?? 'Hide sender and message';
    }
  }

  Future<void> _selectPrivacyMode() async {
    final selected = await showModalBottomSheet<NotificationPrivacyMode>(
      context: context,
      backgroundColor: context.surfaceColor,
      builder: (ctx) {
        final textColor = context.textPrimary;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: NotificationPrivacyMode.values.map((mode) {
              return ListTile(
                title: Text(
                  _privacyModeLabel(mode),
                  style: TextStyle(color: textColor),
                ),
                trailing: mode == _settings.privacyMode
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.pop(ctx, mode),
              );
            }).toList(),
          ),
        );
      },
    );

    if (selected != null) {
      await _updateSettings(_settings.copyWith(privacyMode: selected));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: N42AppBar(
        title: l10n?.settingsMessageNotifications ?? 'Message Notifications',
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: AbsorbPointer(
        absorbing: _isSaving,
        child: ListView(
          children: [
            const SizedBox(height: 16),

            // 通知开关
            Material(
              color: context.surfaceColor,
              child: Column(
                children: [
                  _buildSwitchTile(
                    title:
                        l10n?.settingsMessageNotifications ??
                        'Message Notifications',
                    subtitle:
                        l10n?.settingsReceiveNewMessageNotifications ??
                        'Receive new message notifications',
                    icon: Icons.notifications_outlined,
                    value: _settings.enabled,
                    onChanged: (value) =>
                        _updateSettings(_settings.copyWith(enabled: value)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 通知详情设置
            if (_settings.enabled) ...[
              Material(
                color: context.surfaceColor,
                child: Column(
                  children: [
                    _buildSwitchTile(
                      title:
                          l10n?.settingsShowMessagePreview ??
                          'Show Message Preview',
                      subtitle:
                          l10n?.settingsShowMessageContentInNotification ??
                          'Show message content in notifications',
                      icon: Icons.visibility_outlined,
                      value: _settings.showPreview,
                      onChanged: (value) => _updateSettings(
                        _settings.copyWith(showPreview: value),
                      ),
                    ),
                    _buildDivider(),
                    _buildValueTile(
                      title:
                          l10n?.settingsNotificationPrivacy ??
                          'Notification Privacy',
                      icon: Icons.privacy_tip_outlined,
                      value: _privacyModeLabel(_settings.privacyMode),
                      onTap: _selectPrivacyMode,
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      title:
                          l10n?.settingsNotificationSound ??
                          'Notification Sound',
                      subtitle:
                          l10n?.settingsPlaySoundOnMessage ??
                          'Play sound when receiving messages',
                      icon: Icons.volume_up_outlined,
                      value: _settings.playSound,
                      onChanged: (value) =>
                          _updateSettings(_settings.copyWith(playSound: value)),
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      title: l10n?.commonVibration ?? 'Vibration',
                      subtitle:
                          l10n?.settingsVibrateOnMessage ??
                          'Vibrate when receiving messages',
                      icon: Icons.vibration,
                      value: _settings.vibrate,
                      onChanged: (value) =>
                          _updateSettings(_settings.copyWith(vibrate: value)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 免打扰设置
              Material(
                color: context.surfaceColor,
                child: Column(
                  children: [
                    _buildSwitchTile(
                      title: l10n?.settingsDoNotDisturbMode ?? 'Do Not Disturb',
                      subtitle:
                          l10n?.settingsDoNotDisturbDescription ??
                          'Do not receive notifications during specified time',
                      icon: Icons.do_not_disturb_on_outlined,
                      value: _settings.doNotDisturb,
                      onChanged: (value) => _updateSettings(
                        _settings.copyWith(doNotDisturb: value),
                      ),
                    ),
                    if (_settings.doNotDisturb) ...[
                      _buildDivider(),
                      _buildTimeTile(
                        title: l10n?.settingsStartTime ?? 'Start Time',
                        value: _settings.doNotDisturbStart ?? '22:00',
                        icon: Icons.access_time,
                        onTap: () => _selectTime(true),
                      ),
                      _buildDivider(),
                      _buildTimeTile(
                        title: l10n?.settingsEndTime ?? 'End Time',
                        value: _settings.doNotDisturbEnd ?? '07:00',
                        icon: Icons.access_time,
                        onTap: () => _selectTime(false),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 智能过滤（优先通知 / 关键词屏蔽）
              Material(
                color: context.surfaceColor,
                child: _buildValueTile(
                  title: l10n?.settingsSmartFilter ?? 'Smart Filter',
                  icon: Icons.filter_alt_outlined,
                  value: '',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const NotificationFilterPage(),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
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
                  style: TextStyle(fontSize: 16, color: context.textPrimary),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.textSecondary,
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

  Widget _buildTimeTile({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
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
                color: AppColors.info,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 16, color: context.textPrimary),
              ),
            ),
            Text(value, style: TextStyle(color: context.textSecondary)),
            const SizedBox(width: 8),
            Icon(AppIcons.chevron, color: context.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildValueTile({
    required String title,
    String? subtitle,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
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
                color: AppColors.primary,
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
                    style: TextStyle(fontSize: 16, color: context.textPrimary),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: context.textSecondary),
              ),
            ),
            const SizedBox(width: 8),
            Icon(AppIcons.chevron, color: context.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 56),
      child: Divider(height: 1, color: context.dividerColor),
    );
  }

  Future<void> _selectTime(bool isStart) async {
    final currentTime = isStart
        ? _settings.doNotDisturbStart ?? '22:00'
        : _settings.doNotDisturbEnd ?? '07:00';
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (!mounted || time == null) return;

    final formatted =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    await _updateSettings(
      isStart
          ? _settings.copyWith(doNotDisturbStart: formatted)
          : _settings.copyWith(doNotDisturbEnd: formatted),
    );
  }
}
