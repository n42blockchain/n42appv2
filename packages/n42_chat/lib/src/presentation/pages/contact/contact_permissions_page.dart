import 'package:flutter/material.dart';
import '../../../core/di/injection.dart';
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../../data/datasources/matrix/contact_privacy_service.dart';

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
  bool _saveFailed = false;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  bool _isLoading = true;
  ContactPrivacyService get _privacy =>
      ContactPrivacyService(getIt<MatrixClientManager>());

  Future<void> _loadPermissions() async {
    try {
      final data = await _privacy.load(widget.userId);
      if (!mounted) return;
      setState(() {
        _chatOnly = data['chatOnly'] == true;
        _hideMyMoments = data['hideMyMoments'] == true;
        _hideTheirMoments = data['hideTheirMoments'] == true;
        _hideMyStatus = data['hideMyStatus'] == true;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context)?.commonLoadFailed ?? 'Failed to load'),
            action: SnackBarAction(
              label: S.of(context)?.commonRetry ?? 'Retry',
              onPressed: _loadPermissions,
            ),
          ),
        );
    }
  }

  Future<void> _savePermissions() => _privacy.save(widget.userId, {
    'chatOnly': _chatOnly,
    'hideMyMoments': _hideMyMoments,
    'hideTheirMoments': _hideTheirMoments,
    'hideMyStatus': _hideMyStatus,
  });

  Future<void> _updatePermissions(VoidCallback update) async {
    if (_isSaving || _isLoading) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final saveFailedMessage = S.of(context)?.commonSaveFailed ?? 'Save failed';

    setState(() {
      _isSaving = true;
      update();
    });

    try {
      await _savePermissions();
      if (mounted) setState(() => _saveFailed = false);
    } catch (e) {
      debugLog('ContactPermissionsPage: Failed to save permissions: $e');
      if (!mounted) {
        return;
      }
      await _loadPermissions();
      if (!mounted) return;
      setState(() => _saveFailed = true);
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
          if (_saveFailed)
            MaterialBanner(
              content: Text(S.of(context)?.commonSaveFailed ?? 'Save failed'),
              actions: [
                TextButton(
                  onPressed: _isSaving ? null : () => _updatePermissions(() {}),
                  child: Text(S.of(context)?.commonRetry ?? 'Retry'),
                ),
              ],
            ),
          const SizedBox(height: 8),
          Container(
            color: cardColor,
            child: Column(
              children: [
                _buildToggleItem(
                  title:
                      S.of(context)?.contactSetChatOnly ?? 'Set as chat-only',
                  subtitle:
                      S.of(context)?.contactChatOnlyDesc ??
                      'Only allow chatting, hide other content',
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
                  title:
                      S.of(context)?.contactHideMyMoments ?? 'Hide my Moments',
                  subtitle:
                      S.of(context)?.contactHideMyMomentsDesc ??
                      'This friend cannot see my Moments',
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
                  title:
                      S.of(context)?.contactHideTheirMoments ??
                      'Hide their Moments',
                  subtitle:
                      S.of(context)?.contactHideTheirMomentsDesc ??
                      "Don't see this friend's Moments",
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
                  subtitle:
                      S.of(context)?.contactHideMyStatusDesc ??
                      'This friend cannot see my status',
                  value: _hideMyStatus,
                  onChanged: (v) => _updatePermissions(() => _hideMyStatus = v),
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
                Text(title, style: TextStyle(fontSize: 16, color: textColor)),
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
            onChanged: _isLoading || _isSaving ? null : onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
