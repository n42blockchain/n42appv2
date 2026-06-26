import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart' as matrix;

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../../domain/entities/group_entity.dart';
import '../../widgets/common/common_widgets.dart';

/// 共同群组页面
///
/// 显示当前用户与指定用户的共同群组列表
class CommonGroupsPage extends StatefulWidget {
  /// 目标用户ID
  final String userId;

  /// 目标用户显示名称
  final String displayName;

  /// 群组点击回调
  final void Function(GroupEntity group)? onGroupTap;

  const CommonGroupsPage({
    super.key,
    required this.userId,
    required this.displayName,
    this.onGroupTap,
  });

  @override
  State<CommonGroupsPage> createState() => _CommonGroupsPageState();
}

class _CommonGroupsPageState extends State<CommonGroupsPage> {
  List<GroupEntity>? _groups;
  bool _isLoading = true;
  String? _error;
  int _loadVersion = 0;

  @override
  void initState() {
    super.initState();
    _loadCommonGroups();
  }

  Future<void> _loadCommonGroups() async {
    final loadVersion = ++_loadVersion;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final client = MatrixClientManager.instance.client;
      if (client == null) throw Exception('Matrix client not initialized');

      // 从本地内存中查找与目标用户共同的群组：
      // 过滤出非 Space、非直聊、且对方也是成员的所有房间
      final commonGroups = client.rooms
          .where((room) {
            // 排除 Space 类型房间
            final createEvent = room.getState(matrix.EventTypes.RoomCreate);
            if (createEvent?.content['type'] == 'm.space') return false;
            // 排除直聊房间（DM）
            if (room.isDirectChat) return false;
            // 检查 widget.userId 是否在成员列表中
            return room.getParticipants().any((u) => u.id == widget.userId);
          })
          .map(_roomToGroupEntity)
          .toList();

      if (mounted && loadVersion == _loadVersion) {
        setState(() {
          _groups = commonGroups;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted && loadVersion == _loadVersion) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  /// 将 Matrix Room 转换为 GroupEntity（轻量级，仅展示所需字段）
  GroupEntity _roomToGroupEntity(matrix.Room room) {
    final members = room.getParticipants();

    return GroupEntity(
      roomId: room.id,
      name: room.name,
      topic: room.topic.isNotEmpty ? room.topic : null,
      avatarUrl: room.avatar?.toString(),
      memberCount: room.summary.mJoinedMemberCount ?? members.length,
      members: [],
      isPublic: room.joinRules == matrix.JoinRules.public,
      createdAt: DateTime.now(),
      myRole: GroupRole.member,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = context.pageBackground;
    final cardColor = context.surfaceColor;
    final textColor = context.textPrimary;
    final secondaryTextColor = context.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        title: Text(
          S.of(context)?.contactCommonGroups ?? 'Groups in common',
          style: TextStyle(
            color: textColor,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(cardColor, textColor, secondaryTextColor),
    );
  }

  Widget _buildBody(
    Color cardColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    if (_isLoading) {
      return Center(
        child: N42Loading(
          message: S.of(context)?.commonLoading ?? 'Loading...',
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: N42EmptyState.error(
          title: S.of(context)?.commonLoadFailed ?? 'Load failed',
          description: _error,
          buttonText: S.of(context)?.commonRetry ?? 'Retry',
          onButtonPressed: _loadCommonGroups,
        ),
      );
    }

    if (_groups == null || _groups!.isEmpty) {
      return Center(
        child: N42EmptyState.noData(
          title: S.of(context)?.contactNoCommonGroups ?? 'No common groups',
          description:
              S.of(context)?.contactNoCommonGroupsDescription ??
              'You don\'t have any groups in common',
        ),
      );
    }

    return ListView.builder(
      itemCount: _groups!.length,
      itemBuilder: (context, index) {
        final group = _groups![index];
        return _buildGroupTile(group, cardColor, textColor, secondaryTextColor);
      },
    );
  }

  Widget _buildGroupTile(
    GroupEntity group,
    Color cardColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Container(
      color: cardColor,
      child: ListTile(
        leading: _buildGroupAvatar(group),
        title: Text(
          group.name,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          S.of(context)?.commonMemberCount(group.memberCount) ??
              '${group.memberCount} members',
          style: TextStyle(color: secondaryTextColor, fontSize: 13),
        ),
        trailing: Icon(
          AppIcons.chevron,
          color: secondaryTextColor,
          size: 20,
        ),
        onTap: () {
          if (widget.onGroupTap != null) {
            widget.onGroupTap!(group);
          } else {
            Navigator.pop(context, group);
          }
        },
      ),
    );
  }

  Widget _buildGroupAvatar(GroupEntity group) {
    if (group.avatarUrl != null && group.avatarUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          group.avatarUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildDefaultAvatar(group.name),
        ),
      );
    }
    return _buildDefaultAvatar(group.name);
  }

  Widget _buildDefaultAvatar(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColorPalettes.getAvatarColor(name),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
