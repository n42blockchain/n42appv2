import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../../domain/entities/group_entity.dart';
import '../../blocs/group/group_bloc.dart';
import '../../blocs/group/group_event.dart';
import '../../blocs/group/group_state.dart';
import '../../helpers/bloc_message_helper.dart';
import '../../widgets/common/common_widgets.dart';
import '../../../n42_chat.dart';

/// 群成员管理页面
class GroupMembersPage extends StatefulWidget {
  final String roomId;

  const GroupMembersPage({super.key, required this.roomId});

  @override
  State<GroupMembersPage> createState() => _GroupMembersPageState();
}

class _GroupMembersPageState extends State<GroupMembersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<GroupBloc>().add(LoadGroupDetails(widget.roomId));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: N42AppBar(
        title: S.of(context)?.groupMembersTitle ?? 'Group Members',
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

          if (state.currentGroup == null) {
            return N42EmptyState(
              icon: Icons.error_outline,
              title: S.of(context)?.commonLoadFailed ?? 'Load failed',
            );
          }

          return _buildBody(state, isDark);
        },
      ),
    );
  }

  Widget _buildBody(GroupState state, bool isDark) {
    final group = state.currentGroup!;
    var members = state.members;

    // 搜索过滤
    if (_searchQuery.isNotEmpty) {
      members = members
          .where(
            (m) =>
                m.displayName.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                m.userId.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    // 排序：群主 > 管理员 > 普通成员
    members.sort((a, b) {
      if (a.isOwner) return -1;
      if (b.isOwner) return 1;
      if (a.isAdmin && !b.isAdmin) return -1;
      if (b.isAdmin && !a.isAdmin) return 1;
      return a.displayName.compareTo(b.displayName);
    });

    return Column(
      children: [
        // 搜索栏
        Container(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          padding: const EdgeInsets.all(12),
          child: N42SearchBar(
            controller: _searchController,
            hintText: S.of(context)?.groupSearchMembers ?? 'Search members',
            onChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
          ),
        ),

        // 成员数量
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          alignment: Alignment.centerLeft,
          child: Text(
            S.of(context)?.groupTotalMembers(state.currentGroup!.memberCount) ??
                '${state.currentGroup!.memberCount} members',
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
        ),

        // 成员列表
        Expanded(
          child: ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return _buildMemberTile(member, group, isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMemberTile(GroupMember member, GroupEntity group, bool isDark) {
    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      child: ListTile(
        leading: N42Avatar(
          imageUrl: member.avatarUrl,
          name: member.displayName,
          size: 44,
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                member.displayName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (member.isOwner) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  S.of(context)?.commonGroupOwner ?? 'Owner',
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ] else if (member.isAdmin) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  S.of(context)?.commonGroupAdmin ?? 'Admin',
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          member.userId,
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
        ),
        onTap: () => _showMemberOptions(member, group),
      ),
    );
  }

  void _showMemberOptions(GroupMember member, GroupEntity group) {
    final myUserId = MatrixClientManager.instance.client?.userID;
    final isSelf = member.userId == myUserId;
    final canManage = _canManageMember(group, member, isSelf: isSelf);
    final canSetAdmin = group.isOwner && !member.isOwner && !isSelf;

    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 查看资料
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(
                S.of(this.context)?.groupViewProfile ?? 'View Profile',
              ),
              onTap: () {
                Navigator.pop(context);
                N42Chat.openUserProfile(member.userId, context: this.context);
              },
            ),

            // 发送消息
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: Text(
                S.of(this.context)?.commonSendMessage ?? 'Send Message',
              ),
              onTap: () async {
                final pageContext = this.context;
                final messenger = ScaffoldMessenger.of(pageContext);
                final l10n = S.of(pageContext);
                Navigator.pop(context);
                try {
                  final roomId = await N42Chat.createDirectMessage(
                    member.userId,
                  );
                  if (!mounted || !pageContext.mounted) return;
                  await N42Chat.openConversation(roomId, context: pageContext);
                } catch (e) {
                  if (!mounted || !pageContext.mounted) return;
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n?.commonFeatureInDevelopment('') ??
                            'Feature in development...',
                      ),
                    ),
                  );
                }
              },
            ),

            // 设置/取消管理员
            if (canSetAdmin)
              ListTile(
                leading: Icon(
                  member.isAdmin ? Icons.remove_moderator : Icons.add_moderator,
                ),
                title: Text(
                  member.isAdmin
                      ? (S.of(this.context)?.groupRemoveAdmin ?? 'Remove Admin')
                      : (S.of(this.context)?.groupSetAsAdmin ?? 'Set as Admin'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  if (member.isAdmin) {
                    this.context.read<GroupBloc>().add(
                      RemoveAdmin(widget.roomId, member.userId),
                    );
                  } else {
                    this.context.read<GroupBloc>().add(
                      SetAsAdmin(widget.roomId, member.userId),
                    );
                  }
                },
              ),

            // 移出群聊
            if (canManage)
              ListTile(
                leading: const Icon(Icons.person_remove, color: Colors.red),
                title: Text(
                  S.of(this.context)?.chatRemoveFromGroup ??
                      'Remove from Group',
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmKickMember(member);
                },
              ),
          ],
        ),
      ),
    );
  }

  bool _canManageMember(
    GroupEntity group,
    GroupMember member, {
    required bool isSelf,
  }) {
    if (!group.canKick || isSelf || member.isOwner) {
      return false;
    }

    if (group.isOwner) {
      return true;
    }

    return !member.isAdmin;
  }

  void _confirmKickMember(GroupMember member) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(context)?.groupRemoveMember ?? 'Remove Member'),
        content: Text(
          S.of(context)?.groupConfirmRemoveMember(member.displayName) ??
              'Are you sure you want to remove "${member.displayName}" from the group?',
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
                KickMember(widget.roomId, member.userId),
              );
            },
            child: Text(
              S.of(context)?.commonRemove ?? 'Remove',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
