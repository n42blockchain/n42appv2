import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../domain/entities/custom_emoji.dart';
import 'custom_emoji_text.dart';

/// 自定义 emoji 输入联想条
///
/// 用户输入 `:partial` 时，推荐匹配的自定义动画 emoji（对齐 Discord/Telegram）。
/// 点击候选把 `:partial` 替换为完整 `:shortcode:`。置于输入栏正上方。
class CustomEmojiSuggestionBar extends StatelessWidget {
  final List<CustomEmoji> suggestions;
  final ValueChanged<CustomEmoji> onSelected;

  const CustomEmojiSuggestionBar({
    super.key,
    required this.suggestions,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: context.inputBarColor,
        border: Border(
          top: BorderSide(color: context.dividerColor, width: 0.5),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        itemCount: suggestions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 4),
        itemBuilder: (context, index) {
          final emoji = suggestions[index];
          return InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => onSelected(emoji),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  CustomEmojiInline(emoji: emoji, size: 24),
                  const SizedBox(width: 6),
                  Text(
                    ':${emoji.shortcode}:',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
