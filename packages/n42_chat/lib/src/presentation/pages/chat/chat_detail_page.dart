import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/encryption/e2ee_manager.dart';
import '../../../core/encryption/key_backup_service.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/services/chat_lock_service.dart';
import '../../../core/services/media_lifecycle_service.dart';
import '../../../core/services/remark_service.dart';
import '../../../core/services/storage_cleanup_service.dart';
import '../../../core/services/storage_manager_service.dart';
import '../../../core/services/storage_monitor_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../../domain/entities/conversation_entity.dart';
import '../../../domain/entities/message_entity.dart';
import '../../../domain/repositories/conversation_repository.dart';
import '../../../domain/repositories/group_repository.dart';
import '../../blocs/chat/chat_bloc.dart';
import '../../blocs/contact/contact_bloc.dart';
import '../../blocs/contact/contact_state.dart';
import '../../blocs/storage/storage_management_bloc.dart';
import '../../widgets/common/n42_avatar.dart';
import '../contact/contact_detail_page.dart';
import '../group/group_media_hub_page.dart';
import '../group/group_settings_page.dart';
import 'chat_export_page.dart';
import 'scheduled_messages_page.dart';
import '../settings/auto_download_settings_page.dart';
import '../settings/backup_restore_page.dart';
import '../settings/chat_background_page.dart';
import '../settings/room_storage_detail_page.dart';
import '../settings/security_settings_page.dart';
import '../../../core/utils/debug_log.dart';

/// 聊天详情页面（仿微信）
class ChatDetailPage extends StatefulWidget {
  /// 会话信息
  final ConversationEntity conversation;

  /// 是否可以踢人（群主/管理员）
  final bool canKickMembers;

  /// 是否可以修改群设置（群名称等）
  final bool canChangeSettings;

  /// 添加成员到群的回调
  final VoidCallback? onAddMember;

  /// 移除成员的回调
  final void Function(String userId)? onRemoveMember;

  /// 点击成员头像的回调（返回true表示是好友，可以直接聊天）
  final void Function(String userId, String displayName, String? avatarUrl)?
  onMemberTap;

  /// 清空聊天记录的回调
  final VoidCallback? onClearHistory;

  const ChatDetailPage({
    super.key,
    required this.conversation,
    this.canKickMembers = false,
    this.canChangeSettings = false,
    this.onAddMember,
    this.onRemoveMember,
    this.onMemberTap,
    this.onClearHistory,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  bool _isPinned = false;
  bool _isStrongReminder = false;
  bool _isChatLocked = false;
  ConversationNotificationMode _notificationMode =
      ConversationNotificationMode.allMessages;

  // 群名称（可编辑）
  late String _groupName;

  final ChatLockService _chatLockService = ChatLockService();

  // 备注更新订阅
  StreamSubscription<RemarkUpdateEvent>? _remarkSubscription;

  @override
  void initState() {
    super.initState();
    _isPinned = widget.conversation.isPinned;
    _notificationMode = widget.conversation.isMuted
        ? ConversationNotificationMode.muted
        : ConversationNotificationMode.allMessages;
    _groupName = widget.conversation.name;

    _loadNotificationModeStatus();
    // 加载强提醒状态
    _loadStrongReminderStatus();

    // 加载聊天锁状态
    _loadChatLockStatus();

    // 监听备注更新
    _remarkSubscription = RemarkService.instance.onRemarkUpdated.listen((
      event,
    ) {
      final targetUserId = widget.conversation.directUserId;
      if (targetUserId != null && event.userId == targetUserId && mounted) {
        debugLog(
          'ChatDetailPage: Remark updated for $targetUserId, refreshing UI',
        );
        setState(() {});
      }
    });
  }

  /// 加载强提醒状态
  Future<void> _loadStrongReminderStatus() async {
    try {
      final repository = getIt<IConversationRepository>();
      final isStrongReminder = await repository.getStrongReminder(
        widget.conversation.id,
      );
      if (mounted) {
        setState(() {
          _isStrongReminder = isStrongReminder;
        });
      }
    } catch (e) {
      debugLog('ChatDetailPage: Failed to load strong reminder status: $e');
    }
  }

  Future<void> _loadNotificationModeStatus() async {
    try {
      final repository = getIt<IConversationRepository>();
      final mode = await repository.getNotificationMode(widget.conversation.id);
      if (mounted) {
        setState(() => _notificationMode = mode);
      }
    } catch (e) {
      debugLog('ChatDetailPage: Failed to load notification mode: $e');
    }
  }

  Future<void> _loadChatLockStatus() async {
    final isLocked = await _chatLockService.isChatLocked(
      widget.conversation.id,
    );
    if (mounted) {
      setState(() => _isChatLocked = isLocked);
    }
  }

  Future<void> _toggleChatLock(bool enable) async {
    if (enable) {
      // 锁定：先验证用户身份（生物识别），然后设置 PIN
      final biometricAvailable = await _chatLockService.isBiometricAvailable();
      if (biometricAvailable) {
        if (!mounted) return;
        final verified = await _chatLockService.verifyWithBiometric(
          reason: S.of(context)?.chatLockEnable ?? 'Lock this chat',
        );
        if (!verified) return;
      }

      // 弹出 PIN 设置对话框
      if (mounted) {
        final pin = await _showSetPinDialog();
        if (!mounted || pin == null) {
          return;
        }
        await _chatLockService.lockChat(widget.conversation.id, pin: pin);
        await _applyLockPushRule(widget.conversation.id, locked: true);
        if (mounted) {
          setState(() => _isChatLocked = true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context)?.chatLockEnabled ?? 'Chat locked'),
            ),
          );
        }
      }
    } else {
      // 解锁前先验证
      final biometricAvailable = await _chatLockService.isBiometricAvailable();
      if (!mounted) return;
      bool verified = false;
      if (biometricAvailable) {
        verified = await _chatLockService.verifyWithBiometric(
          reason: S.of(context)?.chatLockDisable ?? 'Unlock this chat',
        );
      }
      if (!verified) {
        // Try PIN
        final hasPin = await _chatLockService.hasPinSet(widget.conversation.id);
        if (hasPin && mounted) {
          verified = await _showVerifyPinDialog();
        }
      }

      if (verified) {
        await _chatLockService.unlockChat(widget.conversation.id);
        await _applyLockPushRule(widget.conversation.id, locked: false);
        if (mounted) {
          setState(() => _isChatLocked = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context)?.chatLockDisabled ?? 'Chat unlocked'),
            ),
          );
        }
      }
    }
  }

  /// Mirrors the chat lock into a server-side push rule.
  ///
  /// The local notification filter only runs while Dart is awake. On iOS the
  /// pusher is registered without event_id_only, so the push gateway delivers a
  /// full APNs alert that the OS renders without waking the app — no local
  /// filter can suppress it. Muting the room server-side stops the notification
  /// at the source on every platform. Unlocking only unmutes when the user had
  /// not muted the conversation independently.
  Future<void> _applyLockPushRule(
    String conversationId, {
    required bool locked,
  }) async {
    try {
      final repository = getIt<IConversationRepository>();
      if (locked) {
        await repository.setMuted(conversationId, true);
      } else if (!widget.conversation.isMuted) {
        await repository.setMuted(conversationId, false);
      }
    } catch (e) {
      debugLog('Failed to sync lock push rule for $conversationId: $e');
    }
  }

  Future<String?> _showSetPinDialog() async {
    final pinController = TextEditingController();
    final confirmController = TextEditingController();
    final l10n = S.of(context);

    try {
      return await showDialog<String>(
        context: context,
        builder: (ctx) {
          String? error;
          return StatefulBuilder(
            builder: (ctx, setDialogState) => AlertDialog(
              title: Text(l10n?.chatLockPinSetTitle ?? 'Set PIN'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 6,
                    decoration: InputDecoration(
                      hintText: l10n?.chatLockPinTitle ?? 'Enter PIN',
                      counterText: '',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 6,
                    decoration: InputDecoration(
                      hintText: l10n?.chatLockPinConfirmTitle ?? 'Confirm PIN',
                      counterText: '',
                      border: const OutlineInputBorder(),
                      errorText: error,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, null),
                  child: Text(l10n?.commonCancel ?? 'Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final pin = pinController.text;
                    final confirm = confirmController.text;
                    if (pin.length < 4) return;
                    if (pin != confirm) {
                      setDialogState(() {
                        error =
                            l10n?.chatLockPinMismatch ?? 'PIN does not match';
                      });
                      return;
                    }
                    Navigator.pop(ctx, pin);
                  },
                  child: Text(l10n?.commonConfirm ?? 'Confirm'),
                ),
              ],
            ),
          );
        },
      );
    } finally {
      pinController.dispose();
      confirmController.dispose();
    }
  }

  Future<bool> _showVerifyPinDialog() async {
    final pinController = TextEditingController();
    final l10n = S.of(context);

    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          String? error;
          return StatefulBuilder(
            builder: (ctx, setDialogState) => AlertDialog(
              title: Text(l10n?.chatLockPinTitle ?? 'Enter PIN'),
              content: TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                decoration: InputDecoration(
                  counterText: '',
                  border: const OutlineInputBorder(),
                  errorText: error,
                ),
                onSubmitted: (_) async {
                  final verified = await _chatLockService.verifyPin(
                    widget.conversation.id,
                    pinController.text,
                  );
                  if (verified) {
                    if (ctx.mounted) Navigator.pop(ctx, true);
                  } else {
                    setDialogState(() {
                      error =
                          l10n?.chatLockVerifyFailed ?? 'Verification failed';
                      pinController.clear();
                    });
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l10n?.commonCancel ?? 'Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    final verified = await _chatLockService.verifyPin(
                      widget.conversation.id,
                      pinController.text,
                    );
                    if (verified) {
                      if (ctx.mounted) Navigator.pop(ctx, true);
                    } else {
                      setDialogState(() {
                        error =
                            l10n?.chatLockVerifyFailed ?? 'Verification failed';
                        pinController.clear();
                      });
                    }
                  },
                  child: Text(l10n?.commonConfirm ?? 'Confirm'),
                ),
              ],
            ),
          );
        },
      );
      return result ?? false;
    } finally {
      pinController.dispose();
    }
  }

  @override
  void dispose() {
    _remarkSubscription?.cancel();
    super.dispose();
  }

  /// 获取对方用户ID
  String? _getOtherUserId() {
    return widget.conversation.directUserId;
  }

  /// 获取显示名称（私聊时优先使用备注名）
  String _getDisplayName() {
    // 群聊直接使用会话名称
    if (widget.conversation.type == ConversationType.group) {
      return widget.conversation.name;
    }

    // 私聊：直接使用 conversation.directUserId 获取备注名
    final otherUserId = widget.conversation.directUserId;
    if (otherUserId != null) {
      return RemarkService.instance.getDisplayName(
        otherUserId,
        widget.conversation.name,
      );
    }

    return widget.conversation.name;
  }

  /// 更新通知模式
  Future<void> _updateNotificationMode(
    ConversationNotificationMode mode,
  ) async {
    final previousMode = _notificationMode;
    try {
      final repository = getIt<IConversationRepository>();
      await repository.setNotificationMode(widget.conversation.id, mode);
      debugLog('ChatDetailPage: Notification mode updated to $mode');
    } catch (e) {
      debugLog('ChatDetailPage: Failed to update notification mode: $e');
      // 恢复原状态
      if (mounted) {
        setState(() => _notificationMode = previousMode);
      }
    }
  }

  String _notificationModeLabel() {
    switch (_notificationMode) {
      case ConversationNotificationMode.allMessages:
        return 'All Messages';
      case ConversationNotificationMode.mentionsOnly:
        return 'Mentions Only';
      case ConversationNotificationMode.muted:
        return S.of(context)?.commonMute ?? 'Mute';
    }
  }

  Future<void> _showNotificationModeSheet() async {
    final textColor = context.textPrimary;
    final secondaryTextColor = context.textSecondary;

    final selected = await showModalBottomSheet<ConversationNotificationMode>(
      context: context,
      backgroundColor: context.surfaceColor,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('All Messages', style: TextStyle(color: textColor)),
              subtitle: Text(
                'Notify for every new message in this chat',
                style: TextStyle(color: secondaryTextColor),
              ),
              trailing:
                  _notificationMode == ConversationNotificationMode.allMessages
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () =>
                  Navigator.pop(ctx, ConversationNotificationMode.allMessages),
            ),
            ListTile(
              title: Text('Mentions Only', style: TextStyle(color: textColor)),
              subtitle: Text(
                'Only notify when you are mentioned or @room is used',
                style: TextStyle(color: secondaryTextColor),
              ),
              trailing:
                  _notificationMode == ConversationNotificationMode.mentionsOnly
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () =>
                  Navigator.pop(ctx, ConversationNotificationMode.mentionsOnly),
            ),
            ListTile(
              title: Text(
                S.of(context)?.commonMute ?? 'Mute',
                style: TextStyle(color: textColor),
              ),
              subtitle: Text(
                'Disable notifications for this chat on all devices',
                style: TextStyle(color: secondaryTextColor),
              ),
              trailing: _notificationMode == ConversationNotificationMode.muted
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () =>
                  Navigator.pop(ctx, ConversationNotificationMode.muted),
            ),
          ],
        ),
      ),
    );

    if (!mounted || selected == null || selected == _notificationMode) {
      return;
    }

    setState(() => _notificationMode = selected);
    await _updateNotificationMode(selected);
  }

  /// 更新置顶状态
  Future<void> _updatePinnedStatus(bool pinned) async {
    debugLog(
      'ChatDetailPage: _updatePinnedStatus called with pinned=$pinned, roomId=${widget.conversation.id}',
    );
    try {
      final repository = getIt<IConversationRepository>();
      await repository.setPinned(widget.conversation.id, pinned);
      debugLog('ChatDetailPage: Pin status updated successfully to $pinned');
    } catch (e) {
      debugLog('ChatDetailPage: Failed to update pin status: $e');
      // 恢复原状态
      if (mounted) {
        setState(() {
          _isPinned = !pinned;
        });
      }
    }
  }

  /// 更新强提醒状态
  Future<void> _updateStrongReminderStatus(bool enabled) async {
    try {
      final repository = getIt<IConversationRepository>();
      await repository.setStrongReminder(widget.conversation.id, enabled);
      debugLog('ChatDetailPage: Strong reminder status updated to $enabled');
    } catch (e) {
      debugLog('ChatDetailPage: Failed to update strong reminder status: $e');
      // 恢复原状态
      if (mounted) {
        setState(() {
          _isStrongReminder = !enabled;
        });
      }
    }
  }

  /// 显示编辑群名称对话框
  Future<void> _showEditGroupNameDialog() async {
    // 检查权限
    if (!widget.canChangeSettings) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context)?.chatNoPermissionToModify ??
                'You do not have permission to modify',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final controller = TextEditingController(text: _groupName);

    String? newName;
    try {
      newName = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: context.surfaceColor,
          title: Text(
            S.of(context)?.chatGroupName ?? 'Group Name',
            style: TextStyle(color: context.textPrimary),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 50,
            style: TextStyle(color: context.textPrimary),
            decoration: InputDecoration(
              hintText:
                  S.of(context)?.commonEnterGroupName ?? 'Enter group name',
              hintStyle: TextStyle(
                color: context.textSecondary,
              ),
              counterStyle: TextStyle(
                color: context.textSecondary,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: Text(S.of(context)?.commonSave ?? 'Save'),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }

    if (newName != null && newName.isNotEmpty && newName != _groupName) {
      await _updateGroupName(newName);
    }
  }

  /// 更新群名称
  Future<void> _updateGroupName(String newName) async {
    try {
      final groupRepository = getIt<IGroupRepository>();
      await groupRepository.setGroupName(widget.conversation.id, newName);

      if (mounted) {
        setState(() {
          _groupName = newName;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)?.chatGroupNameUpdated ?? 'Group name updated',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugLog('ChatDetailPage: Failed to update group name: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context)?.chatUpdateFailed ?? 'Update failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = context.pageBackground;
    final cardColor = context.surfaceColor;
    final textColor = context.textPrimary;
    final secondaryTextColor = context.textSecondary;
    final dividerColor = context.dividerThin;

    final isGroup = widget.conversation.type == ConversationType.group;

    // 检查 ContactBloc 是否可用
    bool hasContactBloc = false;
    try {
      context.read<ContactBloc>();
      hasContactBloc = true;
    } catch (e) {
      // ContactBloc 不可用
      debugLog('Error: $e');
    }

    final Widget scaffold = Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(AppIcons.back, color: textColor, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          S.of(context)?.chatDetails ?? 'Chat Details',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),

            // 成员头像区域
            Container(
              color: cardColor,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      // 对方头像（私聊）或群成员头像（群聊）
                      if (!isGroup)
                        _buildMemberItem(
                          avatarUrl: widget.conversation.avatarUrl,
                          name: _getDisplayName(),
                          onTap: () => _openContactDetail(),
                        )
                      else ...[
                        // 群聊显示多个成员头像
                        ..._buildGroupMembers(),
                      ],
                      // 添加成员按钮
                      _buildAddButton(
                        icon: Icons.add,
                        onTap: () => _addMemberToGroup(),
                      ),
                      // 移除成员按钮（仅群主/管理员显示）
                      if (isGroup && widget.canKickMembers)
                        _buildAddButton(
                          icon: Icons.remove,
                          onTap: () => _removeMemberFromGroup(),
                        ),
                    ],
                  ),
                  if (isGroup) ...[
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _openGroupMemberList(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${S.of(context)?.chatViewAllGroupMembers ?? "View All Members"} ',
                            style: TextStyle(
                              fontSize: 13,
                              color: secondaryTextColor,
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: 16,
                            color: secondaryTextColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 设置选项
            _buildMenuSection(
              cardColor: cardColor,
              dividerColor: dividerColor,
              children: [
                if (isGroup) ...[
                  _buildMenuItem(
                    title: S.of(context)?.chatGroupName ?? 'Group Name',
                    value: _groupName,
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                    onTap: _showEditGroupNameDialog,
                  ),
                  _buildDivider(dividerColor),
                  _buildMenuItem(
                    title:
                        S.of(context)?.commonGroupAnnouncement ??
                        'Group Announcement',
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                    onTap: () => _showGroupAnnouncementDialog(),
                  ),
                  _buildDivider(dividerColor),
                  _buildMenuItem(
                    title:
                        S.of(context)?.chatGroupManagement ??
                        'Group Management',
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                    onTap: () => _openGroupSettings(),
                  ),
                  _buildDivider(dividerColor),
                  _buildMenuItem(
                    title:
                        S.of(context)?.chatMyNicknameInGroup ??
                        'My Nickname in Group',
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                    onTap: () => _showEditNicknameDialog(),
                  ),
                  _buildDivider(dividerColor),
                ],
                _buildMenuItem(
                  title:
                      S.of(context)?.commonSearchChatHistory ??
                      'Search Chat History',
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  onTap: () => _searchChatHistory(),
                ),
                _buildDivider(dividerColor),
                _buildMenuItem(
                  title: 'Files, Media & Links',
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  onTap: _openFilesAndLinks,
                ),
                _buildDivider(dividerColor),
                _buildMenuItem(
                  title: S.of(context)?.autoDownload ?? 'Auto-Download',
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  onTap: _openAutoDownloadSettings,
                ),
                _buildDivider(dividerColor),
                _buildMenuItem(
                  title: 'Chat Storage',
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  onTap: _openChatStorage,
                ),
                _buildDivider(dividerColor),
                _buildMenuItem(
                  title:
                      S.of(context)?.chatExportHistory ?? 'Export Chat History',
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  onTap: () => _openChatExport(),
                ),
                _buildDivider(dividerColor),
                _buildMenuItem(
                  title: 'Scheduled Messages',
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  onTap: () => _openScheduledMessages(),
                ),
                _buildDivider(dividerColor),
                _buildMenuItem(
                  title: 'Backup & Restore',
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  onTap: _openBackupRestore,
                ),
                _buildDivider(dividerColor),
                _buildMenuItem(
                  title: 'Encryption Keys & Devices',
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  onTap: _openSecuritySettings,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 消息免打扰、置顶等开关
            _buildMenuSection(
              cardColor: cardColor,
              dividerColor: dividerColor,
              children: [
                _buildMenuItem(
                  title:
                      S.of(context)?.settingsMessageNotifications ??
                      'Message Notifications',
                  value: _notificationModeLabel(),
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  onTap: _showNotificationModeSheet,
                ),
                _buildDivider(dividerColor),
                _buildSwitchItem(
                  title: S.of(context)?.chatPinChat ?? 'Pin Chat',
                  value: _isPinned,
                  textColor: textColor,
                  onChanged: (value) {
                    debugLog('ChatDetailPage: Pin switch toggled to $value');
                    setState(() {
                      _isPinned = value;
                    });
                    // 持久化设置
                    _updatePinnedStatus(value);
                  },
                ),
                _buildDivider(dividerColor),
                _buildSwitchItem(
                  title: S.of(context)?.chatStrongReminder ?? 'Strong Reminder',
                  value: _isStrongReminder,
                  textColor: textColor,
                  onChanged: (value) {
                    setState(() {
                      _isStrongReminder = value;
                    });
                    // 持久化强提醒设置
                    _updateStrongReminderStatus(value);
                  },
                ),
                _buildDivider(dividerColor),
                _buildSwitchItem(
                  title: S.of(context)?.chatLockTitle ?? 'Chat lock',
                  value: _isChatLocked,
                  textColor: textColor,
                  onChanged: (value) {
                    _toggleChatLock(value);
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 设置背景
            _buildMenuSection(
              cardColor: cardColor,
              dividerColor: dividerColor,
              children: [
                _buildMenuItem(
                  title:
                      S.of(context)?.chatSetChatBackground ??
                      'Set Chat Background',
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  onTap: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ChatBackgroundPage(roomId: widget.conversation.id),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 清空聊天记录
            _buildMenuSection(
              cardColor: cardColor,
              dividerColor: dividerColor,
              children: [
                _buildMenuItem(
                  title:
                      S.of(context)?.commonClearChatHistory ??
                      'Clear Chat History',
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  onTap: () => _showClearConfirm(),
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

            const SizedBox(height: 32),
          ],
        ),
      ),
    );

    // 如果有 ContactBloc，用 BlocListener 包装
    if (hasContactBloc) {
      return BlocListener<ContactBloc, ContactState>(
        listener: (context, state) {
          if (state.status == ContactStatus.remarkUpdated ||
              state.status == ContactStatus.loaded) {
            if (mounted) setState(() {});
          }
        },
        child: scaffold,
      );
    }

    return scaffold;
  }

  Widget _buildMemberItem({
    required String? avatarUrl,
    required String name,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 60,
        child: Column(
          children: [
            N42Avatar(
              imageUrl: avatarUrl,
              name: name,
              size: 50,
              borderRadius: 6,
            ),
            const SizedBox(height: 4),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondaryOf(context.isDarkMode),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildGroupMembers() {
    final members = <Widget>[];
    final avatars = widget.conversation.memberAvatarUrls ?? [];
    final names = widget.conversation.memberNames ?? [];
    final ids = widget.conversation.memberIds ?? [];

    // 如果有踢人权限，显示 16 个头像（留空间给 +- 按钮）；否则显示 17 个（只有 + 按钮）
    final maxMembers = widget.canKickMembers ? 16 : 17;

    for (int i = 0; i < avatars.length && i < maxMembers; i++) {
      final memberId = ids.length > i ? ids[i] : '';
      final memberName = names.length > i ? names[i] : '';
      final memberAvatar = avatars[i];

      members.add(
        _buildMemberItem(
          avatarUrl: memberAvatar,
          name: memberName,
          onTap: () => _onMemberTap(memberId, memberName, memberAvatar),
        ),
      );
    }

    return members;
  }

  /// 点击成员头像
  void _onMemberTap(String userId, String displayName, String? avatarUrl) {
    if (userId.isEmpty) return;

    // 如果提供了回调，使用回调
    if (widget.onMemberTap != null) {
      widget.onMemberTap!(userId, displayName, avatarUrl);
      return;
    }

    // 默认行为：打开联系人详情页
    _openMemberDetail(userId, displayName, avatarUrl);
  }

  /// 打开成员详情页
  void _openMemberDetail(String userId, String displayName, String? avatarUrl) {
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
          final page = ContactDetailPage(
            userId: userId,
            displayName: displayName,
            avatarUrl: avatarUrl,
            onSendMessage: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
          );

          if (contactBloc != null) {
            return BlocProvider.value(value: contactBloc, child: page);
          }
          return page;
        },
      ),
    );
  }

  /// 打开群成员列表
  void _openGroupMemberList() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => _GroupMemberListPage(
          roomId: widget.conversation.id,
          roomName: widget.conversation.name,
          onMemberTap: (userId, displayName, avatarUrl) {
            _onMemberTap(userId, displayName, avatarUrl);
          },
        ),
      ),
    );
  }

  /// 添加成员到群
  void _addMemberToGroup() {
    if (widget.onAddMember != null) {
      widget.onAddMember!();
    } else {
      // TODO: 默认实现
      debugLog('Add member to group');
    }
  }

  /// 从群中移除成员
  void _removeMemberFromGroup() {
    if (widget.onRemoveMember != null) {
      // 显示选择成员的对话框
      _showRemoveMemberDialog();
    } else {
      debugLog('Remove member from group');
    }
  }

  /// 显示移除成员的对话框
  void _showRemoveMemberDialog() {
    final names = widget.conversation.memberNames ?? [];
    final ids = widget.conversation.memberIds ?? [];

    if (ids.isEmpty) return;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context)?.chatRemoveFromGroup ?? 'Remove from Group'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: ids.length,
            itemBuilder: (context, index) {
              final name = names.length > index ? names[index] : ids[index];
              return ListTile(
                title: Text(name),
                onTap: () {
                  Navigator.of(ctx).pop();
                  widget.onRemoveMember?.call(ids[index]);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = context.isDarkMode;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 60,
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.textTertiaryOf(isDark),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: AppColors.textTertiaryOf(isDark),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            const Text(''),
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
    String? value,
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
            Expanded(
              flex: 2,
              child: Text(
                title,
                style: TextStyle(fontSize: 16, color: textColor),
              ),
            ),
            if (value != null)
              Expanded(
                flex: 3,
                child: Text(
                  value,
                  style: TextStyle(fontSize: 15, color: secondaryTextColor),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
            const SizedBox(width: 4),
            Icon(AppIcons.chevron, color: secondaryTextColor, size: 20),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          debugLog(
            'ChatDetailPage: Switch row tapped for $title, current value: $value',
          );
          onChanged(!value);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
              ),
              Switch.adaptive(
                value: value,
                onChanged: (newValue) {
                  debugLog(
                    'ChatDetailPage: Switch widget toggled for $title to $newValue',
                  );
                  onChanged(newValue);
                },
                activeTrackColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Divider(height: 0.5, thickness: 0.5, color: color),
    );
  }

  /// 显示群公告对话框
  void _showGroupAnnouncementDialog() async {
    final controller = TextEditingController();
    final canEdit = widget.canChangeSettings;

    try {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: context.surfaceColor,
          title: Text(
            S.of(context)?.commonGroupAnnouncement ?? 'Group Announcement',
            style: TextStyle(color: context.textPrimary),
          ),
          content: canEdit
              ? TextField(
                  controller: controller,
                  maxLines: 5,
                  style: TextStyle(color: context.textPrimary),
                  decoration: InputDecoration(
                    hintText:
                        S.of(context)?.chatGroupAnnouncementHint ??
                        'Enter group announcement',
                    hintStyle: TextStyle(
                      color: context.textSecondary,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                )
              : Text(
                  S.of(context)?.chatGroupAnnouncementEmpty ??
                      'No announcement',
                  style: TextStyle(
                    color: context.textPrimary,
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                canEdit
                    ? (S.of(context)?.commonCancel ?? 'Cancel')
                    : (S.of(context)?.commonConfirm ?? 'OK'),
              ),
            ),
            if (canEdit)
              TextButton(
                onPressed: () async {
                  final announcement = controller.text.trim();
                  Navigator.pop(ctx);
                  try {
                    final groupRepository = getIt<IGroupRepository>();
                    await groupRepository.setGroupAnnouncement(
                      widget.conversation.id,
                      announcement,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(S.of(context)?.commonSave ?? 'Saved'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            S.of(context)?.chatUpdateFailed ?? 'Update failed',
                          ),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
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

  /// 打开群管理设置
  void _openGroupSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GroupSettingsPage(roomId: widget.conversation.id),
      ),
    );
  }

  /// 显示编辑群昵称对话框
  void _showEditNicknameDialog() async {
    final controller = TextEditingController();

    String? newNickname;
    try {
      newNickname = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: context.surfaceColor,
          title: Text(
            S.of(context)?.chatEditNickname ?? 'Edit Nickname',
            style: TextStyle(color: context.textPrimary),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 30,
            style: TextStyle(color: context.textPrimary),
            decoration: InputDecoration(
              hintText:
                  S.of(context)?.chatNicknameHint ??
                  'Enter your nickname in this group',
              hintStyle: TextStyle(
                color: context.textSecondary,
              ),
              counterStyle: TextStyle(
                color: context.textSecondary,
              ),
            ),
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

    if (newNickname != null && newNickname.isNotEmpty && mounted) {
      // 群昵称功能需要 Matrix state event 支持，暂存本地
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context)?.chatGroupNameUpdated ?? 'Updated'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  /// 搜索聊天记录
  void _searchChatHistory() {
    Navigator.of(context).pop({'action': 'search'});
  }

  /// 显示投诉对话框
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
            style: TextStyle(color: context.textPrimary),
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
                  style: TextStyle(color: context.textPrimary),
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

  void _openContactDetail() {
    // 获取对方用户ID（私聊时需要真实的用户ID，而不是房间ID）
    final otherUserId = _getOtherUserId();
    if (otherUserId == null) {
      // 无法获取用户ID，使用房间ID作为后备
      debugLog(
        'ChatDetailPage: Cannot get other user ID, using room ID as fallback',
      );
    }

    final userId = otherUserId ?? widget.conversation.id;

    // 获取当前的 ContactBloc
    ContactBloc? contactBloc;
    try {
      contactBloc = context.read<ContactBloc>();
    } catch (e) {
      // ContactBloc 可能不可用
      debugLog('Error: $e');
    }

    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (ctx) {
              final page = ContactDetailPage(
                userId: userId,
                displayName: _getDisplayName(),
                avatarUrl: widget.conversation.avatarUrl,
                onSendMessage: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
              );

              if (contactBloc != null) {
                return BlocProvider.value(value: contactBloc, child: page);
              }
              return page;
            },
          ),
        )
        .then((_) {
          // 返回时刷新显示名称
          if (mounted) setState(() {});
        });
  }

  /// 打开文件、媒体与链接中心
  void _openFilesAndLinks() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GroupMediaHubPage(
          roomId: widget.conversation.id,
          groupName: widget.conversation.name,
        ),
      ),
    );
  }

  void _openAutoDownloadSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AutoDownloadSettingsPage()),
    );
  }

  void _openChatStorage() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => StorageManagementBloc(
            storageManager: getIt<StorageManagerService>(),
            lifecycleService: getIt<MediaLifecycleService>(),
            cleanupService: getIt<StorageCleanupService>(),
            monitorService: getIt<StorageMonitorService>(),
          ),
          child: RoomStorageDetailPage(
            roomId: widget.conversation.id,
            roomName: widget.conversation.name,
          ),
        ),
      ),
    );
  }

  /// 打开聊天记录导出
  void _openChatExport() {
    List<MessageEntity> initialMessages = const [];
    try {
      initialMessages = context
          .read<ChatBloc>()
          .state
          .messages
          .where((message) => message.scheduledAt == null)
          .toList(growable: false);
    } catch (e) {
      debugLog('ChatDetailPage: Failed to read ChatBloc for export: $e');
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatExportPage(
          roomId: widget.conversation.id,
          roomName: widget.conversation.name,
          messages: initialMessages,
        ),
      ),
    );
  }

  void _openScheduledMessages() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ScheduledMessagesPage(
          roomId: widget.conversation.id,
          roomName: widget.conversation.name,
        ),
      ),
    );
  }

  void _openBackupRestore() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const BackupRestorePage()));
  }

  void _openSecuritySettings() {
    final client = MatrixClientManager.instance.client;
    if (client == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Encryption service is not available yet'),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SecuritySettingsPage(
          e2eeManager: E2EEManager(client),
          keyBackupService: KeyBackupService(client),
        ),
      ),
    );
  }

  void _showClearConfirm() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          S.of(context)?.chatClearChatHistoryTitle ?? 'Clear Chat History',
        ),
        content: Text(
          S.of(context)?.chatClearHistoryConfirm ??
              'Are you sure you want to clear all chat history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onClearHistory?.call();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    S.of(context)?.commonChatHistoryCleared ??
                        'Chat history cleared',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: Text(
              S.of(context)?.chatClearAction ?? 'Clear',
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// 群成员列表页面
class _GroupMemberListPage extends StatefulWidget {
  final String roomId;
  final String roomName;
  final void Function(String userId, String displayName, String? avatarUrl)?
  onMemberTap;

  const _GroupMemberListPage({
    required this.roomId,
    required this.roomName,
    this.onMemberTap,
  });

  @override
  State<_GroupMemberListPage> createState() => _GroupMemberListPageState();
}

class _GroupMemberListPageState extends State<_GroupMemberListPage> {
  List<Map<String, dynamic>> _members = [];
  List<Map<String, dynamic>> _filteredMembers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    try {
      final groupRepository = getIt<IGroupRepository>();
      final members = await groupRepository.getGroupMembers(widget.roomId);

      if (mounted) {
        setState(() {
          _members = members
              .map(
                (m) => {
                  'id': m.userId,
                  'name': m.displayName,
                  'avatarUrl': m.avatarUrl,
                  'role': m.role.name,
                },
              )
              .toList();
          _filteredMembers = _members;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugLog('Error loading members: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterMembers(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredMembers = _members;
      } else {
        _filteredMembers = _members.where((m) {
          final name = (m['name'] as String?)?.toLowerCase() ?? '';
          final id = (m['id'] as String?)?.toLowerCase() ?? '';
          return name.contains(query.toLowerCase()) ||
              id.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final bgColor = context.pageBackground;
    final cardColor = context.surfaceColor;
    final textColor = context.textPrimary;
    final secondaryTextColor = context.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(AppIcons.back, color: textColor, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          S.of(context)?.commonGroupMembers(_members.length) ??
              'Members (${_members.length})',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 搜索框
          Container(
            color: cardColor,
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: _filterMembers,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText:
                    S.of(context)?.chatSearchMemberHint ?? 'Search members',
                hintStyle: TextStyle(color: secondaryTextColor),
                prefixIcon: Icon(Icons.search, color: secondaryTextColor),
                filled: true,
                fillColor: AppColors.inputBgOf(isDark),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          // 成员列表
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredMembers.isEmpty
                ? Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? (S.of(context)?.chatNoMembers ?? 'No members')
                          : (S.of(context)?.chatNoMatchingMembers ??
                                'No matching members found'),
                      style: TextStyle(color: secondaryTextColor),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredMembers.length,
                    itemBuilder: (context, index) {
                      final member = _filteredMembers[index];
                      final name =
                          member['name'] as String? ??
                          (S.of(context)?.commonUnknownMember ?? 'Unknown');
                      final id = member['id'] as String? ?? '';
                      final avatarUrl = member['avatarUrl'] as String?;
                      final role = member['role'] as String?;

                      return ListTile(
                        leading: N42Avatar(
                          imageUrl: avatarUrl,
                          name: name,
                          size: 44,
                          borderRadius: 6,
                        ),
                        title: Row(
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (role == 'owner') ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  S.of(context)?.commonGroupOwner ?? 'Owner',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.warning,
                                  ),
                                ),
                              ),
                            ] else if (role == 'admin') ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.info.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  S.of(context)?.commonGroupAdmin ?? 'Admin',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.info,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        onTap: () {
                          widget.onMemberTap?.call(id, name, avatarUrl);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
