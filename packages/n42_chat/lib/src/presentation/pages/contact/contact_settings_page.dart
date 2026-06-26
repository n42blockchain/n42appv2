import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../domain/repositories/contact_repository.dart';
import '../../../domain/repositories/message_repository.dart';
import '../../blocs/contact/contact_bloc.dart';
import '../../blocs/contact/contact_event.dart';
import '../../blocs/contact/contact_state.dart';
import '../../widgets/chat/contact_card_select_sheet.dart';
import 'contact_detail_page.dart';
import 'contact_permissions_page.dart';
import '../../../core/utils/debug_log.dart';

/// 联系人设置页面（仿微信 - 图二）
class ContactSettingsPage extends StatefulWidget {
  final String userId;
  final String displayName;
  final bool isStarred;
  final void Function(bool)? onStarChanged;

  const ContactSettingsPage({
    super.key,
    required this.userId,
    required this.displayName,
    this.isStarred = false,
    this.onStarChanged,
  });

  @override
  State<ContactSettingsPage> createState() => _ContactSettingsPageState();
}

class _ContactSettingsPageState extends State<ContactSettingsPage> {
  late bool _isStarred;
  bool _isBlocked = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _isStarred = widget.isStarred;
    try {
      final contact = context
          .read<ContactBloc>()
          .state
          .contacts
          .where((c) => c.userId == widget.userId)
          .firstOrNull;
      _isBlocked = contact?.isBlocked ?? false;
    } catch (_) {
      _isBlocked = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = context.pageBackground;
    final cardColor = context.surfaceColor;
    final textColor = context.textPrimary;
    final secondaryTextColor = context.textSecondary;
    final dividerColor = context.dividerThin;

    return BlocListener<ContactBloc, ContactState>(
      listenWhen: (previous, current) =>
          _isDeleting &&
          (previous.status != current.status ||
              previous.deletedUserId != current.deletedUserId ||
              previous.errorMessage != current.errorMessage),
      listener: (context, state) {
        if (!_isDeleting) {
          return;
        }

        if (state.status == ContactStatus.deleted &&
            state.deletedUserId == widget.userId) {
          setState(() {
            _isDeleting = false;
          });
          final navigator = Navigator.of(context);
          navigator.pop();
          if (navigator.canPop()) {
            navigator.pop();
          }
        } else if (state.status == ContactStatus.error) {
          setState(() {
            _isDeleting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? ''),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              AppIcons.back,
              color: textColor,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            S.of(context)?.commonSettings ?? 'Settings',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // 编辑备注
                  _buildMenuSection(
                    cardColor: cardColor,
                    dividerColor: dividerColor,
                    children: [
                      _buildMenuItem(
                        title:
                            S.of(context)?.contactEditRemark ?? 'Edit Remark',
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        onTap: () => _openEditRemark(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // 设置权限
                  _buildMenuSection(
                    cardColor: cardColor,
                    dividerColor: dividerColor,
                    children: [
                      _buildMenuItem(
                        title:
                            S.of(context)?.contactSetPermissions ??
                            'Set Permissions',
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        onTap: () => _openPermissions(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // 把他(她)推荐给朋友
                  _buildMenuSection(
                    cardColor: cardColor,
                    dividerColor: dividerColor,
                    children: [
                      _buildMenuItem(
                        title:
                            S.of(context)?.contactRecommendToFriend ??
                            'Share contact',
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        onTap: () => _shareContact(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // 设为星标朋友 & 加入黑名单
                  _buildMenuSection(
                    cardColor: cardColor,
                    dividerColor: dividerColor,
                    children: [
                      _buildSwitchItem(
                        title:
                            S.of(context)?.contactSetAsStarred ??
                            'Set as Starred',
                        value: _isStarred,
                        textColor: textColor,
                        onChanged: (value) {
                          setState(() {
                            _isStarred = value;
                          });
                          widget.onStarChanged?.call(value);
                        },
                      ),
                      _buildDivider(dividerColor),
                      _buildSwitchItem(
                        title:
                            S.of(context)?.contactAddToBlocklist ??
                            'Add to Blocklist',
                        value: _isBlocked,
                        textColor: textColor,
                        onChanged: (value) {
                          setState(() {
                            _isBlocked = value;
                          });
                          try {
                            if (value) {
                              context.read<ContactBloc>().add(
                                IgnoreUser(widget.userId),
                              );
                            } else {
                              context.read<ContactBloc>().add(
                                UnignoreUser(widget.userId),
                              );
                            }
                          } catch (_) {
                            debugLog(
                              'ContactBloc not available for blocklist toggle',
                            );
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // 投诉
                  _buildMenuSection(
                    cardColor: cardColor,
                    dividerColor: dividerColor,
                    children: [
                      _buildMenuItem(
                        title: S.of(context)?.commonReport ?? 'Report',
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        onTap: () => _showReportDialog(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 删除联系人
                  _buildMenuSection(
                    cardColor: cardColor,
                    dividerColor: dividerColor,
                    children: [
                      InkWell(
                        onTap: () => _showDeleteConfirm(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          alignment: Alignment.center,
                          child: Text(
                            S.of(context)?.contactDeleteContact ??
                                'Delete Contact',
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),

            if (_isDeleting)
              const ColoredBox(
                color: Color(0x80000000),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection({
    required Color cardColor,
    required Color dividerColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        border: Border(
          top: BorderSide(color: dividerColor, width: 0.5),
          bottom: BorderSide(color: dividerColor, width: 0.5),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required Color textColor,
    required Color secondaryTextColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(title, style: TextStyle(fontSize: 16, color: textColor)),
            const Spacer(),
            Icon(
              AppIcons.chevron,
              color: secondaryTextColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required String title,
    required bool value,
    required Color textColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(title, style: TextStyle(fontSize: 16, color: textColor)),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Divider(height: 0.5, thickness: 0.5, color: color),
    );
  }

  void _openPermissions() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ContactPermissionsPage(
          userId: widget.userId,
          displayName: widget.displayName,
        ),
      ),
    );
  }

  Future<void> _shareContact() async {
    final isDark = context.isDarkMode;
    final l10n = S.of(context);
    final currentContact = context
        .read<ContactBloc>()
        .state
        .contacts
        .where((c) => c.userId == widget.userId)
        .firstOrNull;
    final displayName = currentContact?.effectiveDisplayName.isNotEmpty == true
        ? currentContact!.effectiveDisplayName
        : widget.displayName;

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ContactCardSelectSheet(
        isDark: isDark,
        selectContactText:
            l10n?.contactSelectFriendToRecommend ??
            'Select friend to recommend',
        searchContactHintText: l10n?.commonSearchContacts ?? 'Search contacts',
        noContactsFoundText:
            l10n?.contactNoContactsFound ?? 'No contacts found',
        excludeUserId: widget.userId,
      ),
    );

    if (result == null || !mounted) return;

    final targetUserId = result['id'] as String;
    final targetDisplayName = result['name'] as String;

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Text(l10n?.contactSendingCard ?? 'Sending contact card...'),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      final contactRepository = getIt<IContactRepository>();
      final messageRepository = getIt<IMessageRepository>();
      final roomId = await contactRepository.startDirectChat(targetUserId);
      final eventId = await messageRepository.sendContactCard(
        roomId,
        userId: widget.userId,
        displayName: displayName,
        avatarUrl: currentContact?.avatarUrl,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (eventId == null || eventId.isEmpty) {
        throw StateError('Failed to send contact card');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.contactRecommendedCardTo(displayName, targetDisplayName) ??
                'Recommended $displayName\'s card to $targetDisplayName',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      debugLog('Share contact error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.contactRecommendFailed(e.toString()) ??
                'Recommend failed: $e',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showReportDialog() {
    final descController = TextEditingController();
    String? selectedReason;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: context.surfaceColor,
          title: Text(
            S.of(context)?.reportTitle ?? 'Report',
            style: TextStyle(
              color: context.textPrimary,
            ),
          ),
          content: RadioGroup<String>(
            groupValue: selectedReason,
            onChanged: (val) => setDialogState(() => selectedReason = val),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...[
                  S.of(context)?.reportReasonSpam ?? 'Spam',
                  S.of(context)?.reportReasonHarassment ?? 'Harassment',
                  S.of(context)?.reportReasonFraud ?? 'Fraud',
                  S.of(context)?.reportReasonOther ?? 'Other',
                ].map(
                  (reason) => RadioListTile<String>(
                    title: Text(
                      reason,
                      style: TextStyle(
                        color: context.textPrimary,
                      ),
                    ),
                    value: reason,
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  style: TextStyle(
                    color: context.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        S.of(context)?.reportDescription ??
                        'Additional description (optional)',
                    hintStyle: TextStyle(
                      color: context.textSecondary,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (selectedReason == null) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text(
                        S.of(context)?.reportSelectReason ??
                            'Please select a reason',
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                  return;
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      S.of(context)?.reportSubmitted ?? 'Report submitted',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Text(S.of(context)?.commonConfirm ?? 'Submit'),
            ),
          ],
        ),
      ),
    ).whenComplete(descController.dispose);
  }

  void _openEditRemark() {
    // 获取当前的 ContactBloc
    ContactBloc? contactBloc;
    try {
      contactBloc = context.read<ContactBloc>();
    } catch (e) {
      // ContactBloc 可能不可用
      debugLog('Error: $e');
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) {
          final page = FriendInfoPage(
            userId: widget.userId,
            displayName: widget.displayName,
          );

          if (contactBloc != null) {
            return BlocProvider.value(value: contactBloc, child: page);
          }
          return page;
        },
      ),
    );
  }

  void _showDeleteConfirm() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(context)?.contactDeleteContact ?? 'Delete Contact'),
        content: Text(
          S.of(context)?.contactDeleteContactConfirm(widget.displayName) ??
              'Are you sure you want to delete ${widget.displayName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _deleteContact();
            },
            child: Text(
              S.of(context)?.commonDelete ?? 'Delete',
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteContact() {
    setState(() {
      _isDeleting = true;
    });
    context.read<ContactBloc>().add(DeleteContact(widget.userId));
  }
}
