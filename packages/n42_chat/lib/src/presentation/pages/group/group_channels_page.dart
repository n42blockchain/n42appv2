import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/channel_entity.dart';
import '../../blocs/group/group_bloc.dart';
import '../../blocs/group/group_event.dart';
import '../../blocs/group/group_state.dart';
import '../../widgets/common/common_widgets.dart';
import '../../../n42_chat.dart';
import 'channel_editor_sheet.dart';

/// 群话题频道列表页面
class GroupChannelsPage extends StatefulWidget {
  final String roomId;

  const GroupChannelsPage({super.key, required this.roomId});

  @override
  State<GroupChannelsPage> createState() => _GroupChannelsPageState();
}

class _GroupChannelsPageState extends State<GroupChannelsPage> {
  @override
  void initState() {
    super.initState();
    context.read<GroupBloc>().add(LoadGroupDetails(widget.roomId));
    context.read<GroupBloc>().add(LoadChannels(widget.roomId));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = S.of(context);

    return BlocBuilder<GroupBloc, GroupState>(
      builder: (context, state) {
        final canManage = state.currentGroup?.canChangeSettings ?? false;

        return Scaffold(
          appBar: N42AppBar(title: l10n?.groupChannels ?? 'Topic Channels'),
          backgroundColor: isDark
              ? AppColors.backgroundDark
              : AppColors.background,
          floatingActionButton: canManage
              ? FloatingActionButton(
                  onPressed: () => _showCreateChannelDialog(context),
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : null,
          body: state.channels.isEmpty
              ? N42EmptyState(
                  icon: Icons.forum_outlined,
                  title: l10n?.groupChannelsEmpty ?? 'No channels yet',
                )
              : ListView.separated(
                  itemCount: state.channels.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    indent: 16,
                    color: isDark ? AppColors.dividerDark : AppColors.divider,
                  ),
                  itemBuilder: (context, index) {
                    final channel = state.channels[index];
                    return _buildChannelTile(
                      context,
                      channel,
                      canManage,
                      isDark,
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildChannelTile(
    BuildContext context,
    ChannelEntity channel,
    bool canManage,
    bool isDark,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withValues(alpha: 0.12),
        child: const Icon(Icons.tag, color: AppColors.primary, size: 18),
      ),
      title: Text(
        channel.name,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      ),
      subtitle: channel.topic != null || channel.category != null
          ? Text(
              [
                if (channel.category != null) channel.category!,
                if (channel.topic != null) channel.topic!,
              ].join(' • '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            )
          : null,
      trailing: channel.unreadCount > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                channel.unreadCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            )
          : null,
      onTap: () => N42Chat.openConversation(channel.roomId, context: context),
      onLongPress: canManage
          ? () => _showChannelOptions(context, channel)
          : null,
    );
  }

  Future<void> _showCreateChannelDialog(BuildContext context) async {
    final l10n = S.of(context);
    final draft = await showChannelEditorSheet(
      context,
      title: l10n?.groupChannelCreate ?? 'New Channel',
      confirmLabel: l10n?.commonConfirm ?? 'Create',
    );
    if (!context.mounted || draft == null) {
      return;
    }
    context.read<GroupBloc>().add(
      CreateChannel(
        parentRoomId: widget.roomId,
        name: draft.name,
        topic: draft.topic,
        category: draft.category,
      ),
    );
  }

  void _showChannelOptions(BuildContext context, ChannelEntity channel) {
    final l10n = S.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l10n?.commonEdit ?? 'Edit'),
              onTap: () {
                Navigator.pop(sheetCtx);
                _showEditChannelDialog(context, channel);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text(
                l10n?.groupChannelDelete ?? 'Delete Channel',
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(sheetCtx);
                _confirmDeleteChannel(context, channel);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditChannelDialog(
    BuildContext context,
    ChannelEntity channel,
  ) async {
    final l10n = S.of(context);
    final draft = await showChannelEditorSheet(
      context,
      title: channel.name,
      confirmLabel: l10n?.commonConfirm ?? 'Save',
      initialName: channel.name,
      initialTopic: channel.topic,
      initialCategory: channel.category,
    );
    if (!context.mounted || draft == null) {
      return;
    }
    context.read<GroupBloc>().add(
      UpdateChannel(
        parentRoomId: widget.roomId,
        channelRoomId: channel.roomId,
        name: draft.name,
        topic: draft.topic,
        category: draft.category,
      ),
    );
  }

  void _confirmDeleteChannel(BuildContext context, ChannelEntity channel) {
    final l10n = S.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n?.groupChannelDelete ?? 'Delete Channel'),
        content: Text(
          l10n?.groupChannelDeleteConfirm ??
              'Delete this channel? All messages will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<GroupBloc>().add(
                DeleteChannel(
                  parentRoomId: widget.roomId,
                  channelRoomId: channel.roomId,
                ),
              );
            },
            child: Text(
              l10n?.commonDelete ?? 'Delete',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
