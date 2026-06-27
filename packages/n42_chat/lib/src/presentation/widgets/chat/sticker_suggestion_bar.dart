import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../domain/entities/sticker_pack_entity.dart';
import 'sticker_thumb.dart';

/// 贴纸输入联想条
///
/// 用户在输入框打字时，按词推荐匹配的贴纸（对齐 Telegram/iMessage）。
/// 横向滚动展示候选贴纸，点击即发送对应贴纸。置于输入栏正上方。
class StickerSuggestionBar extends StatelessWidget {
  final List<StickerHit> suggestions;
  final void Function(Sticker sticker, String packId) onSelected;

  const StickerSuggestionBar({
    super.key,
    required this.suggestions,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: context.inputBarColor,
        border: Border(
          top: BorderSide(color: context.dividerColor, width: 0.5),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        itemCount: suggestions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final hit = suggestions[index];
          return GestureDetector(
            onTap: () => onSelected(hit.sticker, hit.packId),
            child: SizedBox(
              width: 48,
              child: StickerThumb(
                sticker: hit.sticker,
                emojiFontSize: 30,
                padding: const EdgeInsets.all(4),
              ),
            ),
          );
        },
      ),
    );
  }
}
