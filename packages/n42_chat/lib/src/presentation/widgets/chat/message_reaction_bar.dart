import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/message_reaction_entity.dart';

/// 消息反应栏（显示在消息下方）
class MessageReactionBar extends StatelessWidget {
  final List<MessageReactionEntity> reactions;
  final String currentUserId;
  final void Function(String emoji)? onReactionTap;
  final VoidCallback? onAddReaction;

  const MessageReactionBar({
    super.key,
    required this.reactions,
    required this.currentUserId,
    this.onReactionTap,
    this.onAddReaction,
  });

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) return const SizedBox.shrink();

    final isDark = context.isDarkMode;

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        ...reactions.map((reaction) => _ReactionChip(
              reaction: reaction,
              hasReacted: reaction.hasReacted(currentUserId),
              onTap: () => onReactionTap?.call(reaction.emoji),
              isDark: isDark,
            )),
        if (onAddReaction != null)
          _AddReactionButton(
            onTap: onAddReaction,
            isDark: isDark,
          ),
      ],
    );
  }
}

/// 单个反应芯片
class _ReactionChip extends StatelessWidget {
  final MessageReactionEntity reaction;
  final bool hasReacted;
  final VoidCallback? onTap;
  final bool isDark;

  const _ReactionChip({
    required this.reaction,
    required this.hasReacted,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: hasReacted
              ? AppColors.primary.withValues(alpha: 0.2)
              : (isDark ? AppColors.surfaceDark : AppColors.surface),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasReacted
                ? AppColors.primary
                : (isDark ? AppColors.dividerDark : AppColors.divider),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              reaction.emoji,
              style: const TextStyle(fontSize: 14),
            ),
            if (reaction.count > 1) ...[
              const SizedBox(width: 4),
              Text(
                '${reaction.count}',
                style: TextStyle(
                  fontSize: 12,
                  color: hasReacted
                      ? AppColors.primary
                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 添加反应按钮
class _AddReactionButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isDark;

  const _AddReactionButton({
    this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.divider,
            width: 1,
          ),
        ),
        child: Icon(
          Icons.add,
          size: 14,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// 快速反应选择器（长按消息时显示）
class QuickReactionPicker extends StatelessWidget {
  final void Function(String emoji)? onReactionSelected;

  const QuickReactionPicker({
    super.key,
    this.onReactionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: CommonEmojis.reactions.map((emoji) {
          return GestureDetector(
            onTap: () => onReactionSelected?.call(emoji),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// 完整反应选择器（底部弹出）
class FullReactionPicker extends StatelessWidget {
  final void Function(String emoji)? onReactionSelected;

  const FullReactionPicker({
    super.key,
    this.onReactionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题栏
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Emoji',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 常用表情
            Text(
              'Frequently Used',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CommonEmojis.extendedReactions.map((emoji) {
                return GestureDetector(
                  onTap: () {
                    onReactionSelected?.call(emoji);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.backgroundDark : AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

