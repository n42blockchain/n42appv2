import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/room_metadata_utils.dart';
import '../../../domain/entities/channel_entity.dart';
import '../../blocs/group/group_bloc.dart';
import '../../blocs/group/group_event.dart';
import '../../blocs/group/group_state.dart';
import '../../widgets/common/common_widgets.dart';
import 'group_channels_page.dart';
import 'channel_editor_sheet.dart';
import '../../../n42_chat.dart';

/// 群话题列表页面（用户视角，Telegram Topics 风格）
///
/// 展示群内所有话题频道，支持点击进入对应话题聊天。
/// 管理员可从此页进入频道管理（[GroupChannelsPage]）和新建话题。
class GroupTopicsPage extends StatefulWidget {
  final String roomId;

  const GroupTopicsPage({super.key, required this.roomId});

  @override
  State<GroupTopicsPage> createState() => _GroupTopicsPageState();
}

class _GroupTopicsPageState extends State<GroupTopicsPage> {
  late GroupBloc _groupBloc;

  @override
  void initState() {
    super.initState();
    _groupBloc = getIt<GroupBloc>()
      ..add(LoadGroupDetails(widget.roomId))
      ..add(LoadChannels(widget.roomId));
  }

  @override
  void dispose() {
    _groupBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GroupBloc>.value(
      value: _groupBloc,
      child: _GroupTopicsBody(roomId: widget.roomId),
    );
  }
}

class _GroupTopicsBody extends StatelessWidget {
  final String roomId;

  const _GroupTopicsBody({required this.roomId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = S.of(context);

    return BlocBuilder<GroupBloc, GroupState>(
      builder: (context, state) {
        final canManage = state.currentGroup?.canChangeSettings ?? false;
        final channels = state.channels;

        // 分区：置顶（order == 0 或名称含 announcement）+ 普通
        final pinned = channels
            .where(
              (c) => c.order == 0 || c.name.toLowerCase().contains('announce'),
            )
            .toList();
        final regular = channels.where((c) => !pinned.contains(c)).toList()
          ..sort((a, b) => a.order.compareTo(b.order));
        final regularByCategory = <String?, List<ChannelEntity>>{};
        for (final channel in regular) {
          final key = normalizeChannelCategory(channel.category);
          regularByCategory.putIfAbsent(key, () => []).add(channel);
        }

        return Scaffold(
          backgroundColor: isDark
              ? AppColors.backgroundDark
              : AppColors.background,
          appBar: N42AppBar(
            title: l10n?.groupTopics ?? 'Topics',
            actions: [
              if (canManage)
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => GroupChannelsPage(roomId: roomId),
                    ),
                  ),
                  child: Text(
                    l10n?.commonEdit ?? 'Edit',
                    style: const TextStyle(color: AppColors.primary),
                  ),
                ),
            ],
          ),
          floatingActionButton: canManage
              ? FloatingActionButton(
                  onPressed: () => _showCreateTopicSheet(context),
                  backgroundColor: AppColors.primary,
                  tooltip: l10n?.groupChannelCreate ?? 'New Topic',
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : null,
          body: state.isLoading
              ? const N42Loading()
              : Builder(
                  builder: (context) {
                    // 始终插入 General 条目作为父房间入口
                    final effectivePinned = pinned;

                    return ListView(
                      children: [
                        // 置顶话题
                        if (effectivePinned.isNotEmpty) ...[
                          _buildSectionHeader(
                            context,
                            isDark,
                            Icons.push_pin_outlined,
                            l10n?.groupChannels ?? 'Pinned',
                          ),
                          ...effectivePinned.map(
                            (c) => _buildTopicTile(
                              context,
                              c,
                              isDark,
                              isPinned: true,
                            ),
                          ),
                        ],

                        _buildSectionHeader(
                          context,
                          isDark,
                          Icons.forum_outlined,
                          'General',
                        ),
                        _buildTopicTile(
                          context,
                          ChannelEntity.general(roomId),
                          isDark,
                        ),
                        ...regularByCategory.entries.expand((entry) {
                          final label =
                              entry.key ?? (l10n?.groupTopics ?? 'Topics');
                          return <Widget>[
                            _buildSectionHeader(
                              context,
                              isDark,
                              entry.key == null
                                  ? Icons.tag
                                  : Icons.folder_outlined,
                              label,
                            ),
                            ...entry.value.map(
                              (c) => _buildTopicTile(context, c, isDark),
                            ),
                          ];
                        }),

                        const SizedBox(height: 80), // FAB 间距
                      ],
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    bool isDark,
    IconData icon,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicTile(
    BuildContext context,
    ChannelEntity channel,
    bool isDark, {
    bool isPinned = false,
  }) {
    final lastMsg = channel.lastMessage;
    final unread = channel.unreadCount;

    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isPinned
                    ? Colors.orange.withValues(alpha: 0.15)
                    : AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isPinned ? Icons.campaign_outlined : Icons.tag,
                color: isPinned ? Colors.orange : AppColors.primary,
                size: 22,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    channel.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (channel.category != null && channel.roomId != roomId)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      channel.category!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: lastMsg != null
                ? Text(
                    lastMsg.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  )
                : (channel.topic != null
                      ? Text(
                          channel.topic!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        )
                      : null),
            trailing: unread > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      unread > 99 ? '99+' : '$unread',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  )
                : null,
            onTap: () {
              N42Chat.openConversation(channel.roomId, context: context);
            },
          ),
          Divider(
            height: 1,
            indent: 76,
            color: isDark ? AppColors.dividerDark : AppColors.divider,
          ),
        ],
      ),
    );
  }

  void _showCreateTopicSheet(BuildContext context) {
    final l10n = S.of(context);
    showChannelEditorSheet(
      context,
      title: l10n?.groupChannelCreate ?? 'New Topic',
      confirmLabel: l10n?.commonConfirm ?? 'Create',
    ).then((draft) {
      if (!context.mounted || draft == null) {
        return;
      }
      context.read<GroupBloc>().add(
        CreateChannel(
          parentRoomId: roomId,
          name: draft.name,
          topic: draft.topic,
          category: draft.category,
        ),
      );
    });
  }
}
