import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../../domain/entities/conversation_entity.dart';
import '../../../domain/entities/group_entity.dart' show GroupMember, GroupRole;
import '../../../domain/entities/space_entity.dart';
import '../../../domain/repositories/space_repository.dart';
import '../../blocs/chat/chat_bloc.dart';
import '../../blocs/contact/contact_bloc.dart';
import '../../blocs/contact/contact_event.dart';
import '../../blocs/space/space_bloc.dart';
import '../../blocs/space/space_event.dart';
import '../../blocs/space/space_state.dart';
import '../../widgets/common/common_widgets.dart';
import '../chat/chat_page.dart';

enum _PendingSpaceNavigationAction { leave, delete }

/// 社区详情页面
///
/// 通过 [spaceId] 从 [SpaceBloc] 加载 Space 详情，
/// 支持频道管理、成员管理和 Space 设置（管理员）。
class SpaceDetailPage extends StatefulWidget {
  /// Space 的 Matrix 房间 ID
  final String spaceId;

  const SpaceDetailPage({super.key, required this.spaceId});

  @override
  State<SpaceDetailPage> createState() => _SpaceDetailPageState();
}

class _SpaceDetailPageState extends State<SpaceDetailPage> {
  _PendingSpaceNavigationAction? _pendingNavigationAction;

  @override
  void initState() {
    super.initState();
    // 进入页面时加载详情（含子频道层级）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SpaceBloc>().add(LoadSpaceDetail(widget.spaceId));
      context.read<SpaceBloc>().add(LoadSpaceMembers(widget.spaceId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SpaceBloc, SpaceState>(
      listenWhen: (prev, curr) =>
          curr.errorMessage != null && prev.errorMessage != curr.errorMessage ||
          curr.operationSuccess != null &&
              prev.operationSuccess != curr.operationSuccess,
      listener: (context, state) {
        if (state.errorMessage != null) {
          _pendingNavigationAction = null;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
          context.read<SpaceBloc>().add(const ClearSpaceError());
        }
        if (state.operationSuccess != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.operationSuccess!)));
          if (_pendingNavigationAction != null) {
            _pendingNavigationAction = null;
            Navigator.of(context).maybePop();
          }
          context.read<SpaceBloc>().add(const ClearSpaceError());
        }
      },
      builder: (context, state) {
        if (state.isLoadingDetail && state.currentSpace == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final space = state.currentSpace;
        if (space == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text(
                S.of(context)?.spacesNotFound ?? 'Community not found',
              ),
            ),
          );
        }

        return _SpaceDetailScaffold(
          space: space,
          members: state.currentMembers,
          isOperating: state.isOperating,
          isLoadingMembers: state.isLoadingMembers,
          onLeaveConfirmed: _handleLeaveConfirmed,
          onDeleteConfirmed: _handleDeleteConfirmed,
        );
      },
    );
  }

  void _handleLeaveConfirmed() {
    _pendingNavigationAction = _PendingSpaceNavigationAction.leave;
    context.read<SpaceBloc>().add(LeaveSpace(widget.spaceId));
  }

  void _handleDeleteConfirmed() {
    _pendingNavigationAction = _PendingSpaceNavigationAction.delete;
    context.read<SpaceBloc>().add(DeleteSpace(widget.spaceId));
  }
}

// ──────────────────────────────────────────────────────────────
// 详情页主体（已有数据时渲染）
// ──────────────────────────────────────────────────────────────

class _SpaceDetailScaffold extends StatelessWidget {
  final SpaceEntity space;
  final List<GroupMember> members;
  final bool isOperating;
  final bool isLoadingMembers;
  final VoidCallback onLeaveConfirmed;
  final VoidCallback onDeleteConfirmed;

  const _SpaceDetailScaffold({
    required this.space,
    required this.members,
    required this.isOperating,
    required this.isLoadingMembers,
    required this.onLeaveConfirmed,
    required this.onDeleteConfirmed,
  });

  bool get _isAdmin {
    final myId = MatrixClientManager.instance.client?.userID;
    if (myId == null) return false;
    return members.any(
      (m) =>
          m.userId == myId &&
          (m.role == GroupRole.admin || m.role == GroupRole.owner),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    final channels =
        space.children.where((c) => c.type == SpaceChildType.channel).toList()
          ..sort((a, b) => a.order.compareTo(b.order));

    final subSpaces =
        space.children.where((c) => c.type == SpaceChildType.subSpace).toList()
          ..sort((a, b) => a.order.compareTo(b.order));

    return Scaffold(
      backgroundColor: context.pageBackground,
      body: CustomScrollView(
        slivers: [
          _buildHeader(context, isDark),

          // 描述
          if (space.description != null)
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16),
                color: context.surfaceColor,
                child: Text(
                  space.description!,
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ),

          // 标签
          if (space.topics.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: context.surfaceColor,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: space.topics
                      .map(
                        (topic) => Chip(
                          label: Text(
                            topic,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, height: 1.3),
                          ),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: isDark
                              ? AppColors.primary.withValues(alpha: 0.2)
                              : AppColors.primary.withValues(alpha: 0.1),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // 操作区（加入/离开按钮）
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildActionRow(context),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // 子 Space 区域
          if (subSpaces.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              isDark,
              icon: Icons.folder_outlined,
              title: S.of(context)?.spacesSubSpaces ?? 'Sub-Communities',
              count: subSpaces.length,
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _buildSubSpaceItem(ctx, subSpaces[i], isDark),
                childCount: subSpaces.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],

          // 频道区域（含管理员「新建频道」按钮）
          _buildSectionHeader(
            context,
            isDark,
            icon: Icons.tag,
            title: S.of(context)?.spacesChannels ?? 'Channels',
            count: channels.length,
            trailing: _isAdmin
                ? IconButton(
                    icon: const Icon(Icons.add, size: 20),
                    onPressed: () => _showCreateChannelDialog(context),
                    tooltip:
                        S.of(context)?.spacesCreateChannel ?? 'Add Channel',
                  )
                : null,
          ),
          channels.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        S.of(context)?.spacesNoChannels ?? 'No channels yet',
                        style: TextStyle(
                          color: context.textSecondary,
                        ),
                      ),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _buildChannelItem(ctx, channels[i], isDark),
                    childCount: channels.length,
                  ),
                ),

          // 成员区域
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          _buildSectionHeader(
            context,
            isDark,
            icon: Icons.people_outline,
            title: S.of(context)?.spacesMembers ?? 'Members',
            count: space.memberCount,
          ),
          SliverToBoxAdapter(child: _buildMembersPreview(context, isDark)),

          const SliverToBoxAdapter(child: SizedBox(height: 48)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final accessToken = MatrixClientManager.instance.client?.accessToken;
    final headers = <String, String>{};
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.primary,
      actions: [
        if (_isAdmin)
          PopupMenuButton<String>(
            onSelected: (action) => _handleAdminAction(context, action),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'edit_name',
                child: Text(S.of(context)?.spacesEditName ?? 'Edit Name'),
              ),
              PopupMenuItem(
                value: 'edit_desc',
                child: Text(
                  S.of(context)?.spacesEditDescription ?? 'Edit Description',
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  S.of(context)?.spacesDelete ?? 'Delete Community',
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          space.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (space.avatarUrl != null)
              CachedNetworkImage(
                imageUrl: space.avatarUrl!,
                fit: BoxFit.cover,
                httpHeaders: headers,
                errorWidget: (_, _, _) => Container(
                  color: AppColorPalettes.getAvatarColor(space.name),
                ),
              )
            else
              Container(
                color: AppColorPalettes.getAvatarColor(space.name),
                child: Center(
                  child: Text(
                    space.name.isNotEmpty ? space.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
            Positioned(
              bottom: 56,
              left: 16,
              child: Row(
                children: [
                  const Icon(Icons.people, size: 16, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(
                    S.of(context)?.spacesMembersCount(space.memberCount) ??
                        '${space.memberCount} members',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    space.type == SpaceType.public ? Icons.public : Icons.lock,
                    size: 16,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    space.type == SpaceType.public
                        ? (S.of(context)?.spacesPublic ?? 'Public')
                        : (S.of(context)?.spacesPrivate ?? 'Private'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow(BuildContext context) {
    final shareButton = Expanded(
      child: OutlinedButton.icon(
        onPressed: () => _showSpaceLinkActions(context),
        icon: const Icon(Icons.share_outlined),
        label: const Text('Share'),
      ),
    );

    if (space.isJoined) {
      return Row(
        children: [
          shareButton,
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isOperating ? null : () => _confirmLeave(context),
              icon: isOperating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.exit_to_app),
              label: Text(S.of(context)?.spacesLeave ?? 'Leave Community'),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
            ),
          ),
        ],
      );
    }
    return Row(
      children: [
        shareButton,
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: isOperating
                ? null
                : () => context.read<SpaceBloc>().add(JoinSpace(space.id)),
            icon: isOperating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.add),
            label: Text(S.of(context)?.spacesJoin ?? 'Join Community'),
          ),
        ),
      ],
    );
  }

  Future<void> _showSpaceLinkActions(BuildContext context) async {
    await showResolvedShareableLinkActions(
      context,
      resolveLink: () => getIt<ISpaceRepository>().getSpaceInviteLink(space.id),
      presentation: ShareableLinkPresentation(
        entityName: space.name,
        linkLabel: 'Community Link',
        qrCodeTitle: 'Community QR Code',
        qrCodeSubtitle: 'Scan to join this community and browse its channels',
        errorPrefix: 'Failed to load community link',
        copySuccessMessage: 'Community link copied',
        icon: Icons.hub_outlined,
      ),
    );
  }

  Widget _buildMembersPreview(BuildContext context, bool isDark) {
    if (isLoadingMembers) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final preview = members.take(6).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            children: preview.map((m) => _MemberAvatar(member: m)).toList(),
          ),
          if (members.length > 6)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton(
                onPressed: () => _showAllMembers(context),
                child: Text(
                  S.of(context)?.spacesViewAllMembers(members.length) ??
                      'View all ${members.length} members',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String title,
    required int count,
    Widget? trailing,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isDark ? Colors.white54 : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                height: 1.3,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '($count)',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                height: 1.3,
                color: context.textTertiary,
              ),
            ),
            const Spacer(),
            ?trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildChannelItem(
    BuildContext context,
    SpaceChild child,
    bool isDark,
  ) {
    return Container(
      color: context.surfaceColor,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.tag, color: AppColors.primary, size: 20),
        ),
        title: Text(
          child.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: child.description != null
            ? Text(
                child.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: context.textSecondary,
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (child.isSuggested)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  S.of(context)?.spacesSuggested ?? 'Suggested',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                    color: AppColors.success,
                  ),
                ),
              ),
            if (_isAdmin)
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                color: AppColors.error.withValues(alpha: 0.7),
                onPressed: () => _confirmDeleteChannel(context, child),
              ),
            Icon(
              AppIcons.chevron,
              color: context.textSecondary,
            ),
          ],
        ),
        onTap: () => _navigateToChannelChat(context, child),
      ),
    );
  }

  Widget _buildSubSpaceItem(
    BuildContext context,
    SpaceChild child,
    bool isDark,
  ) {
    return Container(
      color: context.surfaceColor,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.folder_outlined,
            color: Colors.purple,
            size: 20,
          ),
        ),
        title: Text(
          child.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: child.description != null
            ? Text(
                child.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: context.textSecondary,
                ),
              )
            : null,
        trailing: Icon(
          AppIcons.chevron,
          color: context.textSecondary,
        ),
        onTap: () {
          // 进入子 Space 详情
          Navigator.push<void>(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<SpaceBloc>(),
                child: SpaceDetailPage(spaceId: child.roomId),
              ),
            ),
          );
        },
      ),
    );
  }

  // ──────────────────────────────────────────────
  // 对话框 / 操作方法
  // ──────────────────────────────────────────────

  void _showCreateChannelDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final topicCtrl = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context)?.spacesCreateChannel ?? 'Create Channel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: S.of(context)?.spacesChannelName ?? 'Channel Name',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: topicCtrl,
              decoration: InputDecoration(
                labelText:
                    S.of(context)?.spacesChannelTopic ?? 'Topic (optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              context.read<SpaceBloc>().add(
                CreateChannel(
                  spaceId: space.id,
                  name: name,
                  topic: topicCtrl.text.trim().isEmpty
                      ? null
                      : topicCtrl.text.trim(),
                ),
              );
              Navigator.pop(ctx);
            },
            child: Text(S.of(context)?.spacesCreate ?? 'Create'),
          ),
        ],
      ),
    ).whenComplete(() {
      nameCtrl.dispose();
      topicCtrl.dispose();
    });
  }

  void _confirmDeleteChannel(BuildContext context, SpaceChild child) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context)?.spacesDeleteChannel ?? 'Delete Channel'),
        content: Text(
          S.of(context)?.spacesDeleteChannelConfirm(child.name) ??
              'Are you sure you want to delete "#${child.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              context.read<SpaceBloc>().add(
                DeleteChannel(space.id, child.roomId),
              );
              Navigator.pop(ctx);
            },
            child: Text(S.of(context)?.commonDelete ?? 'Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmLeave(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context)?.spacesLeave ?? 'Leave Community'),
        content: Text(
          S.of(context)?.spacesLeaveConfirm(space.name) ??
              'Are you sure you want to leave "${space.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              onLeaveConfirmed();
            },
            child: Text(S.of(context)?.spacesLeave ?? 'Leave'),
          ),
        ],
      ),
    );
  }

  void _handleAdminAction(BuildContext context, String action) {
    switch (action) {
      case 'edit_name':
        _showEditTextDialog(
          context,
          title: S.of(context)?.spacesEditName ?? 'Edit Name',
          initialValue: space.name,
          onConfirm: (value) =>
              context.read<SpaceBloc>().add(UpdateSpaceName(space.id, value)),
        );
      case 'edit_desc':
        _showEditTextDialog(
          context,
          title: S.of(context)?.spacesEditDescription ?? 'Edit Description',
          initialValue: space.description ?? '',
          multiline: true,
          onConfirm: (value) => context.read<SpaceBloc>().add(
            UpdateSpaceDescription(space.id, value),
          ),
        );
      case 'delete':
        _confirmDelete(context);
    }
  }

  void _showEditTextDialog(
    BuildContext context, {
    required String title,
    required String initialValue,
    bool multiline = false,
    required void Function(String) onConfirm,
  }) {
    final ctrl = TextEditingController(text: initialValue);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          maxLines: multiline ? 4 : 1,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = ctrl.text.trim();
              if (value.isEmpty) return;
              onConfirm(value);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ).whenComplete(ctrl.dispose);
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context)?.spacesDelete ?? 'Delete Community'),
        content: Text(
          S.of(context)?.spacesDeleteConfirm(space.name) ??
              'This will permanently delete "${space.name}" and all its channels. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              onDeleteConfirmed();
            },
            child: Text(S.of(context)?.commonDelete ?? 'Delete'),
          ),
        ],
      ),
    );
  }

  void _showAllMembers(BuildContext context) {
    // 展示成员列表底部弹出
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (ctx, scrollCtrl) => _MembersBottomSheet(
          members: members,
          spaceId: space.id,
          isAdmin: _isAdmin,
          scrollController: scrollCtrl,
        ),
      ),
    );
  }

  /// 进入频道聊天室
  void _navigateToChannelChat(BuildContext context, SpaceChild channel) {
    final conversation = ConversationEntity(
      id: channel.roomId,
      name: channel.name,
      avatarUrl: channel.avatarUrl,
      type: ConversationType.group,
      memberCount: channel.memberCount,
      topic: channel.description,
    );
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => getIt<ChatBloc>()),
            BlocProvider(
              create: (_) => getIt<ContactBloc>()..add(const LoadContacts()),
            ),
          ],
          child: ChatPage(
            conversation: conversation,
            onBack: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 成员头像（小）
// ──────────────────────────────────────────────────────────────

class _MemberAvatar extends StatelessWidget {
  final GroupMember member;

  const _MemberAvatar({required this.member});

  @override
  Widget build(BuildContext context) {
    final displayName = member.displayName.isNotEmpty
        ? member.displayName
        : member.userId;
    return Tooltip(
      message: displayName,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: AppColorPalettes.getAvatarColor(displayName),
        child: Text(
          displayName[0].toUpperCase(),
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 成员列表底部弹窗
// ──────────────────────────────────────────────────────────────

class _MembersBottomSheet extends StatelessWidget {
  final List<GroupMember> members;
  final String spaceId;
  final bool isAdmin;
  final ScrollController scrollController;

  const _MembersBottomSheet({
    required this.members,
    required this.spaceId,
    required this.isAdmin,
    required this.scrollController,
  });

  GroupMember? get _currentUser {
    final myId = MatrixClientManager.instance.client?.userID;
    if (myId == null) return null;
    for (final member in members) {
      if (member.userId == myId) {
        return member;
      }
    }
    return null;
  }

  bool _canManageMember(GroupMember member) {
    final currentUser = _currentUser;
    final myId = currentUser?.userId;
    if (!isAdmin ||
        currentUser == null ||
        member.userId == myId ||
        member.isOwner) {
      return false;
    }

    if (currentUser.isOwner) {
      return true;
    }

    return !member.isAdmin;
  }

  bool _canPromoteToAdmin(GroupMember member) {
    final currentUser = _currentUser;
    return currentUser?.isOwner == true &&
        member.role == GroupRole.member &&
        member.userId != currentUser?.userId;
  }

  bool _canDemoteAdmin(GroupMember member) {
    final currentUser = _currentUser;
    return currentUser?.isOwner == true &&
        member.role == GroupRole.admin &&
        member.userId != currentUser?.userId;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: context.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  S.of(context)?.spacesMembers ?? 'Members',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    height: 1.3,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${members.length})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    height: 1.3,
                    color: context.textSecondary,
                  ),
                ),
                const Spacer(),
                if (isAdmin)
                  IconButton(
                    icon: const Icon(Icons.person_add_outlined),
                    onPressed: () => _showInviteDialog(context),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: members.length,
              itemBuilder: (ctx, i) {
                final m = members[i];
                final name = m.displayName.isNotEmpty
                    ? m.displayName
                    : m.userId;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColorPalettes.getAvatarColor(name),
                    child: Text(
                      name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    m.userId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      color: context.textSecondary,
                    ),
                  ),
                  trailing: _buildRoleBadge(m.role, isDark),
                  onLongPress:
                      _canManageMember(m) ||
                          _canPromoteToAdmin(m) ||
                          _canDemoteAdmin(m)
                      ? () => _showMemberActions(ctx, m)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(GroupRole role, bool isDark) {
    Color color;
    String label;
    switch (role) {
      case GroupRole.owner:
        color = AppColors.warning;
        label = 'Owner';
      case GroupRole.admin:
        color = AppColors.info;
        label = 'Admin';
      case GroupRole.member:
        return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 11, height: 1.3, fontWeight: FontWeight.w500, color: color),
      ),
    );
  }

  void _showMemberActions(BuildContext context, GroupMember member) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 设为/撤销管理员
            if (_canPromoteToAdmin(member))
              ListTile(
                leading: const Icon(Icons.star_outline, color: AppColors.info),
                title: Text(
                  S.of(context)?.spacesPromoteAdmin ?? 'Promote to Admin',
                ),
                onTap: () {
                  context.read<SpaceBloc>().add(
                    SetMemberPowerLevel(spaceId, member.userId, 50),
                  );
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              )
            else if (_canDemoteAdmin(member))
              ListTile(
                leading: const Icon(Icons.star, color: AppColors.warning),
                title: Text(S.of(context)?.spacesDemoteAdmin ?? 'Remove Admin'),
                onTap: () {
                  context.read<SpaceBloc>().add(
                    SetMemberPowerLevel(spaceId, member.userId, 0),
                  );
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            // 踢出
            if (_canManageMember(member))
              ListTile(
                leading: const Icon(
                  Icons.person_remove_outlined,
                  color: AppColors.warning,
                ),
                title: Text(
                  S
                          .of(context)
                          ?.spacesKickMemberTitle(
                            member.displayName.isNotEmpty
                                ? member.displayName
                                : member.userId,
                          ) ??
                      'Kick ${member.displayName.isNotEmpty ? member.displayName : member.userId}',
                ),
                onTap: () {
                  context.read<SpaceBloc>().add(
                    KickMember(spaceId, member.userId),
                  );
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            // 封禁
            if (_canManageMember(member))
              ListTile(
                leading: const Icon(Icons.block, color: AppColors.error),
                title: Text(
                  S
                          .of(context)
                          ?.spacesBanMemberTitle(
                            member.displayName.isNotEmpty
                                ? member.displayName
                                : member.userId,
                          ) ??
                      'Ban ${member.displayName.isNotEmpty ? member.displayName : member.userId}',
                ),
                onTap: () {
                  context.read<SpaceBloc>().add(
                    BanMember(spaceId, member.userId),
                  );
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showInviteDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context)?.spacesInviteMember ?? 'Invite Member'),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            labelText:
                S.of(context)?.spacesInviteMemberUserId ??
                'User ID (e.g. @user:server.com)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final userId = ctrl.text.trim();
              if (userId.isEmpty) return;
              context.read<SpaceBloc>().add(InviteMember(spaceId, userId));
              Navigator.pop(ctx);
            },
            child: Text(S.of(context)?.spacesInviteMember ?? 'Invite'),
          ),
        ],
      ),
    ).whenComplete(ctrl.dispose);
  }
}
