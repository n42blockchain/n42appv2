import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/group_entity.dart';
import '../../blocs/contact/contact_bloc.dart';
import '../../blocs/contact/contact_event.dart';
import '../../blocs/group/group_bloc.dart';
import '../../blocs/group/group_event.dart';
import '../../blocs/group/group_state.dart';
import '../../helpers/bloc_message_helper.dart';
import '../../widgets/common/common_widgets.dart';
import '../../../n42_chat.dart';
import 'create_group_page.dart';
import 'group_settings_page.dart';

/// 群聊列表页面
class GroupListPage extends StatefulWidget {
  const GroupListPage({super.key});

  @override
  State<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  @override
  void initState() {
    super.initState();
    context.read<GroupBloc>().add(const LoadGroups());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: N42AppBar(
        title: S.of(context)?.commonGroupChat ?? 'Group Chat',
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            onPressed: () => _navigateToCreateGroup(),
          ),
        ],
      ),
      body: BlocConsumer<GroupBloc, GroupState>(
        listener: (context, state) {
          if (state.status == GroupStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(resolveBlocMessage(context, state.errorMessage!)),
              ),
            );
          } else if (state.status == GroupStatus.success &&
              state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  resolveBlocMessage(context, state.successMessage!),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const N42Loading();
          }

          if (state.status == GroupStatus.loaded) {
            return _buildGroupList(state, isDark);
          }

          return N42EmptyState(
            icon: Icons.group_outlined,
            title: S.of(context)?.commonNoGroups ?? 'No groups',
            description:
                S.of(context)?.groupCreateGroupToChat ??
                'Create a group to start chatting',
          );
        },
      ),
    );
  }

  Widget _buildGroupList(GroupState state, bool isDark) {
    if (state.groups.isEmpty && state.invites.isEmpty) {
      return Center(
        child: N42EmptyState(
          icon: Icons.group_outlined,
          title: S.of(context)?.commonNoGroups ?? 'No groups',
          description:
              S.of(context)?.groupCreateGroupToChat ??
              'Create a group to start chatting',
          buttonText: S.of(context)?.commonCreateGroup ?? 'Create Group',
          onButtonPressed: () => _navigateToCreateGroup(),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<GroupBloc>().add(const RefreshGroups());
      },
      child: ListView(
        children: [
          // 群邀请
          if (state.invites.isNotEmpty) ...[
            _buildSectionHeader(
              S.of(context)?.commonGroupInvites ?? 'Group Invites',
              isDark,
            ),
            ...state.invites.map((invite) => _buildInviteTile(invite, isDark)),
          ],

          // 我的群聊
          if (state.groups.isNotEmpty) ...[
            _buildSectionHeader(
              S.of(context)?.commonMyGroups(state.groups.length) ??
                  'My Groups (${state.groups.length})',
              isDark,
            ),
            ...state.groups.map((group) => _buildGroupTile(group, isDark)),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: isDark ? AppColors.backgroundDark : AppColors.background,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildGroupTile(GroupEntity group, bool isDark) {
    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      child: ListTile(
        leading: N42Avatar(
          imageUrl: group.avatarUrl,
          name: group.name,
          size: 48,
        ),
        title: Text(
          group.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          S.of(context)?.commonMemberCount(group.memberCount) ??
              '${group.memberCount} members',
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
        ),
        trailing: group.isEncrypted
            ? Icon(
                Icons.lock,
                size: 16,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              )
            : null,
        onTap: () => _navigateToChat(group.roomId),
        onLongPress: () => _showGroupOptions(group),
      ),
    );
  }

  Widget _buildInviteTile(GroupEntity group, bool isDark) {
    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      child: ListTile(
        leading: N42Avatar(
          imageUrl: group.avatarUrl,
          name: group.name,
          size: 48,
        ),
        title: Text(
          group.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          S.of(context)?.commonInvitedToJoinGroup ?? 'Invited to join group',
          style: const TextStyle(fontSize: 13, color: AppColors.primary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                context.read<GroupBloc>().add(RejectGroupInvite(group.roomId));
              },
              child: Text(S.of(context)?.commonReject ?? 'Reject'),
            ),
            TextButton(
              onPressed: () {
                context.read<GroupBloc>().add(AcceptGroupInvite(group.roomId));
              },
              child: Text(S.of(context)?.commonAccept ?? 'Accept'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCreateGroup() async {
    final roomId = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => getIt<ContactBloc>()..add(const LoadContacts()),
            ),
            BlocProvider(create: (_) => getIt<GroupBloc>()),
          ],
          child: const CreateGroupPage(),
        ),
      ),
    );
    if (roomId != null) {
      if (!mounted) return;
      context.read<GroupBloc>().add(const RefreshGroups());
      _navigateToChat(roomId);
    }
  }

  void _navigateToChat(String roomId) {
    N42Chat.openConversation(roomId, context: context);
  }

  void _showGroupOptions(GroupEntity group) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(S.of(context)?.groupProfile ?? 'Group Info'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(this.context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => BlocProvider.value(
                      value: this.context.read<GroupBloc>(),
                      child: GroupSettingsPage(roomId: group.roomId),
                    ),
                  ),
                );
              },
            ),
            if (group.isOwner)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: Text(
                  S.of(context)?.commonDissolveGroup ?? 'Dissolve Group',
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteGroup(group);
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.red),
                title: Text(
                  S.of(context)?.commonLeaveGroup ?? 'Leave Group',
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmLeaveGroup(group);
                },
              ),
          ],
        ),
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
              context.read<GroupBloc>().add(LeaveGroup(group.roomId));
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
              context.read<GroupBloc>().add(DeleteGroup(group.roomId));
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
}
