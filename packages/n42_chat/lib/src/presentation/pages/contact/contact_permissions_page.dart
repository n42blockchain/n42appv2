import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';
import '../../../core/utils/debug_log.dart';

/// 联系人权限设置页面
class ContactPermissionsPage extends StatefulWidget {
  final String userId;
  final String displayName;

  const ContactPermissionsPage({
    super.key,
    required this.userId,
    required this.displayName,
  });

  @override
  State<ContactPermissionsPage> createState() => _ContactPermissionsPageState();
}

class _ContactPermissionsPageState extends State<ContactPermissionsPage> {
  bool _chatOnly = false;
  bool _hideMyMoments = false;
  bool _hideTheirMoments = false;
  bool _hideMyStatus = false;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'permissions_${widget.userId}';
    final json = prefs.getString(key);
    if (json != null) {
      try {
        final data = jsonDecode(json) as Map<String, dynamic>;
        setState(() {
          _chatOnly = data['chatOnly'] as bool? ?? false;
          _hideMyMoments = data['hideMyMoments'] as bool? ?? false;
          _hideTheirMoments = data['hideTheirMoments'] as bool? ?? false;
          _hideMyStatus = data['hideMyStatus'] as bool? ?? false;
        });
      } catch (e) {
        debugLog('Failed to load permissions: $e');
      }
    }
  }

  Future<void> _savePermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'permissions_${widget.userId}';
    final data = {
      'chatOnly': _chatOnly,
      'hideMyMoments': _hideMyMoments,
      'hideTheirMoments': _hideTheirMoments,
      'hideMyStatus': _hideMyStatus,
    };
    await prefs.setString(key, jsonEncode(data));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtitleColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final dividerColor = isDark ? AppColors.dividerDark : AppColors.divider;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: N42AppBar(
        title: S.of(context)?.contactFriendPermissions ?? 'Friend Permissions',
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          Container(
            color: cardColor,
            child: Column(
              children: [
                _buildToggleItem(
                  title: S.of(context)?.contactSetChatOnly ?? 'Set as chat-only',
                  subtitle: S.of(context)?.contactChatOnlyDesc ?? 'Only allow chatting, hide other content',
                  value: _chatOnly,
                  onChanged: (v) {
                    setState(() => _chatOnly = v);
                    _savePermissions();
                  },
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Divider(height: 1, color: dividerColor),
                ),
                _buildToggleItem(
                  title: S.of(context)?.contactHideMyMoments ?? 'Hide my Moments',
                  subtitle: S.of(context)?.contactHideMyMomentsDesc ?? 'This friend cannot see my Moments',
                  value: _hideMyMoments,
                  onChanged: (v) {
                    setState(() => _hideMyMoments = v);
                    _savePermissions();
                  },
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Divider(height: 1, color: dividerColor),
                ),
                _buildToggleItem(
                  title: S.of(context)?.contactHideTheirMoments ?? 'Hide their Moments',
                  subtitle: S.of(context)?.contactHideTheirMomentsDesc ?? "Don't see this friend's Moments",
                  value: _hideTheirMoments,
                  onChanged: (v) {
                    setState(() => _hideTheirMoments = v);
                    _savePermissions();
                  },
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Divider(height: 1, color: dividerColor),
                ),
                _buildToggleItem(
                  title: S.of(context)?.contactHideMyStatus ?? 'Hide my status',
                  subtitle: S.of(context)?.contactHideMyStatusDesc ?? 'This friend cannot see my status',
                  value: _hideMyStatus,
                  onChanged: (v) {
                    setState(() => _hideMyStatus = v);
                    _savePermissions();
                  },
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color textColor,
    required Color subtitleColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: subtitleColor),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
