import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/message_entity.dart';
import '../../../domain/entities/message_reaction_entity.dart';

/// 消息操作菜单项
class MessageMenuItem {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isDestructive;

  const MessageMenuItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.isDestructive = false,
  });
}

/// 消息操作菜单
class MessageMenu extends StatelessWidget {
  final MessageEntity message;
  final bool canEdit;
  final bool canRedact;
  final void Function(String emoji)? onReaction;
  final VoidCallback? onReply;
  final VoidCallback? onCopy;
  final VoidCallback? onForward;
  final VoidCallback? onEdit;
  final VoidCallback? onRedact;
  final VoidCallback? onSave;
  final VoidCallback? onMore;

  const MessageMenu({
    super.key,
    required this.message,
    this.canEdit = false,
    this.canRedact = false,
    this.onReaction,
    this.onReply,
    this.onCopy,
    this.onForward,
    this.onEdit,
    this.onRedact,
    this.onSave,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 快速反应栏
            if (onReaction != null) _buildQuickReactions(isDark),

            const Divider(height: 1),

            // 操作列表
            _buildActionList(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickReactions(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: CommonEmojis.reactions.take(6).map((emoji) {
          return GestureDetector(
            onTap: () => onReaction?.call(emoji),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 28),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionList(BuildContext context, bool isDark) {
    final s = S.of(context);
    final items = <MessageMenuItem>[
      if (onReply != null)
        MessageMenuItem(
          icon: Icons.reply,
          label: s?.chatReply ?? 'Reply',
          onTap: () {
            Navigator.pop(context);
            onReply?.call();
          },
        ),
      if (onCopy != null && message.type == MessageType.text)
        MessageMenuItem(
          icon: Icons.copy,
          label: s?.chatCopy ?? 'Copy',
          onTap: () {
            Clipboard.setData(ClipboardData(text: message.content));
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(s?.commonCopiedToClipboard ?? 'Copied to clipboard')),
            );
            onCopy?.call();
          },
        ),
      if (onForward != null)
        MessageMenuItem(
          icon: Icons.forward,
          label: s?.commonForward ?? 'Forward',
          onTap: () {
            Navigator.pop(context);
            onForward?.call();
          },
        ),
      if (canEdit && onEdit != null)
        MessageMenuItem(
          icon: Icons.edit,
          label: s?.commonEdit ?? 'Edit',
          onTap: () {
            Navigator.pop(context);
            onEdit?.call();
          },
        ),
      if (onSave != null)
        MessageMenuItem(
          icon: Icons.bookmark_outline,
          label: s?.commonFavorite ?? 'Favorite',
          onTap: () {
            Navigator.pop(context);
            onSave?.call();
          },
        ),
      if (canRedact && onRedact != null)
        MessageMenuItem(
          icon: Icons.delete_outline,
          label: s?.chatRecall ?? 'Recall',
          onTap: () {
            Navigator.pop(context);
            onRedact?.call();
          },
          isDestructive: true,
        ),
      if (onMore != null)
        MessageMenuItem(
          icon: Icons.more_horiz,
          label: s?.commonMore ?? 'More',
          onTap: () {
            Navigator.pop(context);
            onMore?.call();
          },
        ),
    ];

    return Column(
      children: items.map((item) => _buildActionItem(item, isDark)).toList(),
    );
  }

  Widget _buildActionItem(MessageMenuItem item, bool isDark) {
    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: 22,
              color: item.isDestructive
                  ? AppColors.error
                  : (AppColors.textPrimaryOf(isDark)),
            ),
            const SizedBox(width: 16),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 16,
                color: item.isDestructive
                    ? AppColors.error
                    : (AppColors.textPrimaryOf(isDark)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 转发选择对话框
class ForwardDialog extends StatefulWidget {
  final List<ForwardTarget> targets;
  final void Function(List<String> roomIds)? onConfirm;

  const ForwardDialog({
    super.key,
    required this.targets,
    this.onConfirm,
  });

  @override
  State<ForwardDialog> createState() => _ForwardDialogState();
}

class _ForwardDialogState extends State<ForwardDialog> {
  final Set<String> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // 标题栏
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  S.of(context)?.chatSelectForwardTarget ?? 'Select Forward Target',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryOf(isDark),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _selectedIds.isEmpty
                      ? null
                      : () {
                          widget.onConfirm?.call(_selectedIds.toList());
                          Navigator.pop(context);
                        },
                  child: Text(
                    S.of(context)?.commonSendCount(_selectedIds.length) ?? 'Send(${_selectedIds.length})',
                    style: TextStyle(
                      color: _selectedIds.isEmpty
                          ? AppColors.textSecondary
                          : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // 列表
          Expanded(
            child: ListView.builder(
              itemCount: widget.targets.length,
              itemBuilder: (context, index) {
                final target = widget.targets[index];
                final isSelected = _selectedIds.contains(target.roomId);

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: target.avatarUrl != null
                        ? NetworkImage(target.avatarUrl!)
                        : null,
                    child: target.avatarUrl == null
                        ? Text(target.name.isNotEmpty ? target.name[0] : '?')
                        : null,
                  ),
                  title: Text(target.name),
                  trailing: Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedIds.add(target.roomId);
                        } else {
                          _selectedIds.remove(target.roomId);
                        }
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedIds.remove(target.roomId);
                      } else {
                        _selectedIds.add(target.roomId);
                      }
                    });
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

/// 转发目标
class ForwardTarget {
  final String roomId;
  final String name;
  final String? avatarUrl;
  final bool isGroup;

  const ForwardTarget({
    required this.roomId,
    required this.name,
    this.avatarUrl,
    this.isGroup = false,
  });
}

