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
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
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

  Future<void> _updatePermissions(VoidCallback update) async {
    if (_isSaving) {
      return;
    }

    final previousState = (
      chatOnly: _chatOnly,
      hideMyMoments: _hideMyMoments,
      hideTheirMoments: _hideTheirMoments,
      hideMyStatus: _hideMyStatus,
    );
    final messenger = ScaffoldMessenger.of(context);
    final saveFailedMessage = S.of(context)?.commonSaveFailed ?? 'Save failed';

    setState(() {
      _isSaving = true;
      update();
    });

    try {
      await _savePermissions();
    } catch (e) {
      debugLog('ContactPermissionsPage: Failed to save permissions: $e');
      if (!mounted) {
        return;
      }
      setState(() {
        _chatOnly = previousState.chatOnly;
        _hideMyMoments = previousState.hideMyMoments;
        _hideTheirMoments = previousState.hideTheirMoments;
        _hideMyStatus = previousState.hideMyStatus;
      });
      messenger.showSnackBar(
        SnackBar(
          content: Text(saveFailedMessage),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = context.surfaceColor;
    final textColor = context.textPrimary;
    final subtitleColor = context.textSecondary;
    final dividerColor = context.dividerColor;

    return Scaffold(
      backgroundColor: context.pageBackground,
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
                  onChanged: (v) => _updatePermissions(() => _chatOnly = v),
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
                  onChanged: (v) =>
                      _updatePermissions(() => _hideMyMoments = v),
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
                  onChanged: (v) =>
                      _updatePermissions(() => _hideTheirMoments = v),
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
                  onChanged: (v) =>
                      _updatePermissions(() => _hideMyStatus = v),
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
