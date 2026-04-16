import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/group_entity.dart';
import '../../../domain/repositories/group_repository.dart';
import '../../blocs/group/group_bloc.dart';
import '../../blocs/group/group_event.dart';
import '../../blocs/group/group_state.dart';
import '../../blocs/contact/contact_bloc.dart';
import '../../helpers/bloc_message_helper.dart';
import '../../widgets/common/common_widgets.dart';
import 'bot_settings_page.dart';
import 'content_filter_settings_page.dart';
import 'group_members_page.dart';
import 'group_media_hub_page.dart';
import 'group_topics_page.dart';
import 'invite_members_page.dart';
import 'token_gate_settings_page.dart';
import '../../../core/utils/debug_log.dart';
import '../../../n42_chat.dart';

/// 群设置页面
class GroupSettingsPage extends StatefulWidget {
  final String roomId;
  final VoidCallback? onClearHistory;

  const GroupSettingsPage({
    super.key,
    required this.roomId,
    this.onClearHistory,
  });

  @override
  State<GroupSettingsPage> createState() => _GroupSettingsPageState();
}

class _GroupSettingsPageState extends State<GroupSettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<GroupBloc>().add(LoadGroupDetails(widget.roomId));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return BlocConsumer<GroupBloc, GroupState>(
      listener: (context, state) {
        if (state.status == GroupStatus.error && state.errorMessage != null) {
          final s = S.of(context);
          String message = state.errorMessage!;
          if (message.contains('do not have permission') ||
              message.contains('permission')) {
            message = s?.chatNoPermissionToModify ?? message;
          } else {
            message = resolveBlocMessage(context, message);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        } else if (state.status == GroupStatus.success &&
            state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(resolveBlocMessage(context, state.successMessage!)),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return Scaffold(
            appBar: N42AppBar(
              title: S.of(context)?.groupProfile ?? 'Group Info',
            ),
            body: const N42Loading(),
          );
        }

        if (state.currentGroup == null) {
          return Scaffold(
            appBar: N42AppBar(
              title: S.of(context)?.groupProfile ?? 'Group Info',
            ),
            body: N42EmptyState(
              icon: Icons.error_outline,
              title: S.of(context)?.commonLoadFailed ?? 'Load failed',
            ),
          );
        }

        return _buildBody(state, isDark);
      },
    );
  }

  Widget _buildBody(GroupState state, bool isDark) {
    final group = state.currentGroup!;
    final members = state.members;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: N42AppBar(
        title: S.of(context)?.groupProfile ?? 'Group Info',
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () => _showMoreOptions(group),
          ),
        ],
      ),
      body: ListView(
        children: [
          // 群基本信息
          _buildGroupHeader(group, isDark),

          const SizedBox(height: 10),

          // 成员列表预览
          _buildMembersSection(group, members, isDark),

          const SizedBox(height: 10),

          // 群设置
          _buildSettingsSection(group, isDark),

          const SizedBox(height: 10),

          // 操作按钮
          _buildActionSection(group, isDark),
        ],
      ),
    );
  }

  Widget _buildGroupHeader(GroupEntity group, bool isDark) {
    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 群头像
          GestureDetector(
            onTap: group.canEditAvatar ? () => _changeAvatar() : null,
            child: Stack(
              children: [
                N42Avatar(
                  imageUrl: group.avatarUrl,
                  name: group.name,
                  size: 64,
                ),
                if (group.canEditAvatar)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // 群名称和信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    debugLog(
                      'Group name tapped: canChangeSettings=${group.canChangeSettings}, myRole=${group.myRole}',
                    );
                    if (group.canEditName) {
                      _editGroupName(group);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            S.of(context)?.groupNoPermissionToEditGroupName ??
                                'You do not have permission to edit group name',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          group.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        group.canEditName ? Icons.edit : Icons.lock_outline,
                        size: 16,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: group.roomId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          S.of(context)?.groupIdCopied ?? 'Group ID copied',
                        ),
                      ),
                    );
                  },
                  child: Text(
                    S
                            .of(context)
                            ?.groupMemberCountClickToCopy(group.memberCount) ??
                        '${group.memberCount} members - Click to copy group ID',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersSection(
    GroupEntity group,
    List<GroupMember> members,
    bool isDark,
  ) {
    const maxShow = 8;
    final showMembers = members.take(maxShow).toList();

    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context)?.commonGroupMembers(group.memberCount) ??
                    'Group Members (${group.memberCount})',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => _navigateToMemberList(group),
                child: Text(S.of(context)?.groupViewAll ?? 'View All'),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 成员头像列表
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ...showMembers.map((member) => _buildMemberItem(member)),
              if (group.canInvite) _buildAddMemberButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemberItem(GroupMember member) {
    return GestureDetector(
      onTap: () => N42Chat.openUserProfile(member.userId, context: context),
      child: Column(
        children: [
          Stack(
            children: [
              N42Avatar(
                imageUrl: member.avatarUrl,
                name: member.displayName,
                size: 44,
              ),
              if (member.isOwner)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      S.of(context)?.commonGroupOwner ?? 'Owner',
                      style: const TextStyle(fontSize: 8, color: Colors.white),
                    ),
                  ),
                )
              else if (member.isAdmin)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      S.of(context)?.commonGroupAdmin ?? 'Admin',
                      style: const TextStyle(fontSize: 8, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 50,
            child: Text(
              member.displayName,
              style: const TextStyle(fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMemberButton() {
    return GestureDetector(
      onTap: () => _inviteMembers(),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 50,
            child: Text(
              S.of(context)?.groupInvite ?? 'Invite',
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(GroupEntity group, bool isDark) {
    final widgets = <Widget>[
      // 聊天文件
      ListTile(
        leading: const Icon(Icons.folder_outlined),
        title: Text(S.of(context)?.groupChatFiles ?? 'Chat Files'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => GroupMediaHubPage(
                roomId: widget.roomId,
                groupName: group.name,
              ),
            ),
          );
        },
      ),
      _buildSettingsDivider(isDark),
      ListTile(
        leading: const Icon(Icons.link_outlined),
        title: const Text('Invite Link'),
        subtitle: Text(
          group.isPublic
              ? 'Share a join link for this room'
              : 'Share a room reference with invited members',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showInviteLinkActions(group),
      ),
      _buildSettingsDivider(isDark),
      ListTile(
        leading: const Icon(Icons.forum_outlined),
        title: Text(S.of(context)?.groupChannels ?? 'Topic Channels'),
        subtitle: Text(
          group.canManageChannels
              ? 'Browse topics and manage channel structure'
              : 'Browse grouped topics and channel threads',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => GroupTopicsPage(roomId: widget.roomId),
            ),
          );
        },
      ),
      _buildSettingsDivider(isDark),
      // 群公告
      ListTile(
        title: Text(
          S.of(context)?.commonGroupAnnouncement ?? 'Group Announcement',
        ),
        subtitle: Text(
          group.announcement?.isNotEmpty == true
              ? group.announcement!
              : S.of(context)?.commonNotSet ?? 'Not set',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: group.canEditDescription ? () => _editAnnouncement(group) : null,
      ),
      _buildSettingsDivider(isDark),
      // 群描述
      ListTile(
        title: Text(S.of(context)?.groupDescription ?? 'Group Description'),
        subtitle: Text(
          group.topic?.isNotEmpty == true
              ? group.topic!
              : S.of(context)?.commonNotSet ?? 'Not set',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: group.canEditDescription ? () => _editTopic(group) : null,
      ),
    ];

    final managementTiles = <Widget>[
      if (group.canChangeVisibility)
        SwitchListTile(
          title: Text(S.of(context)?.groupPublicGroup ?? 'Public Group'),
          subtitle: Text(
            S.of(context)?.groupAllowOthersToSearchAndJoin ??
                'Allow others to search and join',
          ),
          value: group.isPublic,
          onChanged: (value) {
            context.read<GroupBloc>().add(
              UpdateGroupVisibility(widget.roomId, value),
            );
          },
        ),
      if (group.canManageBot)
        ListTile(
          leading: const Icon(Icons.smart_toy_outlined),
          title: Text(S.of(context)?.groupBotSettings ?? 'Bot Settings'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BotSettingsPage(roomId: widget.roomId),
              ),
            );
          },
        ),
      if (group.canManageContentFilter)
        ListTile(
          leading: const Icon(Icons.filter_list),
          title: Text(S.of(context)?.groupContentFilter ?? 'Content Filter'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    ContentFilterSettingsPage(roomId: widget.roomId),
              ),
            );
          },
        ),
      if (group.canManageMemberLimit)
        ListTile(
          leading: const Icon(Icons.people_outline),
          title: Text(S.of(context)?.groupMaxMembers ?? 'Member Limit'),
          subtitle: Text(
            group.maxMembers == null
                ? (S.of(context)?.groupMaxMembersUnlimited ?? 'Unlimited')
                : '${group.memberCount} / ${group.maxMembers}',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showMaxMembersDialog(group),
        ),
      if (group.canManageTokenGate)
        ListTile(
          leading: Icon(
            Icons.token,
            color: group.tokenGate?.enabled == true
                ? const Color(0xFF5298FF)
                : null,
          ),
          title: Text(S.of(context)?.tokenGateTitle ?? 'Token Gate'),
          subtitle: Text(
            group.tokenGate?.enabled == true
                ? ('${group.tokenGate!.rules.length} ${S.of(context)?.tokenGateRulesActive ?? 'rules active'}')
                : (S.of(context)?.tokenGateDisabled ?? 'Disabled'),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<bool>(
                builder: (_) => BlocProvider.value(
                  value: context.read<GroupBloc>(),
                  child: TokenGateSettingsPage(
                    roomId: widget.roomId,
                    currentConfig: group.tokenGate,
                  ),
                ),
              ),
            );
          },
        ),
    ];

    if (managementTiles.isNotEmpty) {
      widgets.add(_buildSettingsDivider(isDark));
      for (var i = 0; i < managementTiles.length; i++) {
        widgets.add(managementTiles[i]);
        if (i != managementTiles.length - 1) {
          widgets.add(_buildSettingsDivider(isDark));
        }
      }
    }

    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      child: Column(children: widgets),
    );
  }

  Widget _buildSettingsDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 16,
      color: isDark ? AppColors.dividerDark : AppColors.divider,
    );
  }

  Widget _buildActionSection(GroupEntity group, bool isDark) {
    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      child: Column(
        children: [
          // 清空聊天记录
          ListTile(
            title: Text(
              S.of(context)?.commonClearChatHistory ?? 'Clear Chat History',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _clearChatHistory(),
          ),

          Divider(
            height: 1,
            indent: 16,
            color: isDark ? AppColors.dividerDark : AppColors.divider,
          ),

          // 退出/解散群聊
          ListTile(
            title: Text(
              group.isOwner
                  ? (S.of(context)?.commonDissolveGroup ?? 'Dissolve Group')
                  : (S.of(context)?.commonLeaveGroup ?? 'Leave Group'),
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () {
              if (group.isOwner) {
                _confirmDeleteGroup(group);
              } else {
                _confirmLeaveGroup(group);
              }
            },
          ),
        ],
      ),
    );
  }

  void _changeAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      context.read<GroupBloc>().add(UpdateGroupAvatar(widget.roomId, bytes));
    }
  }

  void _editGroupName(GroupEntity group) {
    final controller = TextEditingController(text: group.name);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(context)?.groupChangeGroupName ?? 'Change Group Name'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: S.of(context)?.commonEnterGroupName ?? 'Enter group name',
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(dialogContext);
                context.read<GroupBloc>().add(
                  UpdateGroupName(widget.roomId, name),
                );
              }
            },
            child: Text(S.of(context)?.commonConfirm ?? 'OK'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  void _editTopic(GroupEntity group) {
    final controller = TextEditingController(text: group.topic);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          S.of(context)?.groupEditGroupDescription ?? 'Edit Group Description',
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText:
                S.of(context)?.groupEnterGroupDescription ??
                'Enter group description',
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<GroupBloc>().add(
                UpdateGroupTopic(widget.roomId, controller.text.trim()),
              );
            },
            child: Text(S.of(context)?.commonConfirm ?? 'OK'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  void _editAnnouncement(GroupEntity group) {
    final controller = TextEditingController(text: group.announcement);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          S.of(context)?.groupEditGroupAnnouncement ??
              'Edit Group Announcement',
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText:
                S.of(context)?.groupEnterGroupAnnouncement ??
                'Enter group announcement',
            border: const OutlineInputBorder(),
          ),
          maxLines: 5,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<GroupBloc>().add(
                UpdateGroupAnnouncement(widget.roomId, controller.text.trim()),
              );
            },
            child: Text(S.of(context)?.groupPublish ?? 'Publish'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  void _showMaxMembersDialog(GroupEntity group) {
    final controller = TextEditingController(
      text: group.maxMembers?.toString() ?? '',
    );
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(context)?.groupMaxMembers ?? 'Member Limit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText:
                    S.of(context)?.groupMaxMembersHint ??
                    'Enter limit (leave empty for unlimited)',
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              final text = controller.text.trim();
              final value = text.isEmpty ? null : int.tryParse(text);
              context.read<GroupBloc>().add(
                SetMaxMembers(widget.roomId, value),
              );
            },
            child: Text(S.of(context)?.commonConfirm ?? 'OK'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  void _navigateToMemberList(GroupEntity group) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<GroupBloc>(),
          child: GroupMembersPage(roomId: group.roomId),
        ),
      ),
    );
  }

  void _inviteMembers() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<GroupBloc>()),
            BlocProvider(create: (_) => getIt<ContactBloc>()),
          ],
          child: InviteMembersPage(roomId: widget.roomId),
        ),
      ),
    );
  }

  Future<void> _showInviteLinkActions(GroupEntity group) async {
    await showResolvedShareableLinkActions(
      context,
      resolveLink: () => _resolveGroupInviteLink(group),
      presentation: _buildGroupInvitePresentation(group),
    );
  }

  Future<String> _resolveGroupInviteLink(GroupEntity group) {
    return getIt<IGroupRepository>().getGroupInviteLink(group.roomId);
  }

  ShareableLinkPresentation _buildGroupInvitePresentation(GroupEntity group) {
    return ShareableLinkPresentation(
      entityName: group.name,
      linkLabel: 'Invite Link',
      qrCodeTitle: S.of(context)?.groupQrCode ?? 'Group QR Code',
      qrCodeSubtitle: group.isPublic
          ? 'Scan to join this group directly'
          : 'Scan to share this room reference with invited members',
      errorPrefix: 'Failed to load invite link',
      copySuccessMessage: 'Invite link copied',
      icon: group.isChannel ? Icons.campaign_outlined : Icons.group_outlined,
    );
  }

  void _clearChatHistory() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          S.of(context)?.commonClearChatHistory ?? 'Clear Chat History',
        ),
        content: Text(
          S.of(context)?.groupConfirmClearChatHistory ??
              'Are you sure you want to clear chat history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              widget.onClearHistory?.call();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    S.of(context)?.commonChatHistoryCleared ??
                        'Chat history cleared',
                  ),
                ),
              );
            },
            child: Text(
              S.of(context)?.commonClear ?? 'Clear',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLeaveGroup(GroupEntity group) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(context)?.commonLeaveGroup ?? 'Leave Group'),
        content: Text(
          S.of(context)?.commonConfirmLeaveGroup(group.name) ??
              'Are you sure you want to leave "${group.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<GroupBloc>().add(LeaveGroup(widget.roomId));
              Navigator.of(context).pop();
            },
            child: Text(
              S.of(context)?.commonLeave ?? 'Leave',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteGroup(GroupEntity group) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(context)?.commonDissolveGroup ?? 'Dissolve Group'),
        content: Text(
          S.of(context)?.commonConfirmDissolveGroup(group.name) ??
              'Are you sure you want to dissolve "${group.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<GroupBloc>().add(DeleteGroup(widget.roomId));
              Navigator.of(context).pop();
            },
            child: Text(
              S.of(context)?.commonDissolve ?? 'Dissolve',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(GroupEntity group) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: Text(S.of(context)?.groupQrCode ?? 'Group QR Code'),
              onTap: () async {
                Navigator.pop(sheetContext);
                await showResolvedShareableLinkQrPage(
                  context,
                  resolveLink: () => _resolveGroupInviteLink(group),
                  presentation: _buildGroupInvitePresentation(group),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: Text(
                S.of(context)?.commonSearchChatHistory ?? 'Search Chat History',
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      S.of(context)?.commonFeatureInDevelopment('') ??
                          'Feature in development',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
