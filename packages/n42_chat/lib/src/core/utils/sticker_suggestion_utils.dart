import '../../domain/entities/sticker_pack_entity.dart';

/// 贴纸搜索 / 输入联想纯逻辑工具
///
/// 不依赖任何 IO，便于单测：
/// - [rank] 在给定贴纸包列表内按关键词/emoji 排序命中单个贴纸；
/// - [extractQuery] 从输入框文本中提取可触发联想的词。
class StickerSuggestionUtils {
  StickerSuggestionUtils._();

  /// 在 [packs] 内按 [query] 搜索单个贴纸并按相关度排序。
  ///
  /// 排序优先级：emoji 精确匹配 > 名称前缀匹配 > 名称包含 > emoji 包含。
  /// 按贴纸 id 去重，最多返回 [limit] 个。
  static List<StickerHit> rank(
    Iterable<StickerPack> packs,
    String query, {
    int limit = 24,
  }) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];

    final seen = <String>{};
    final scored = <_ScoredHit>[];

    for (final pack in packs) {
      for (final sticker in pack.stickers) {
        if (!seen.add(sticker.id)) continue;

        final name = sticker.name?.toLowerCase() ?? '';
        final emoji = sticker.emoji ?? '';

        int? score;
        if (emoji.isNotEmpty && emoji == query) {
          score = 0; // emoji 精确匹配
        } else if (name.isNotEmpty && name == q) {
          score = 1; // 名称精确匹配
        } else if (name.startsWith(q)) {
          score = 2; // 名称前缀匹配
        } else if (name.contains(q)) {
          score = 3; // 名称包含
        } else if (emoji.isNotEmpty && emoji.contains(query)) {
          score = 4; // emoji 包含
        }

        if (score != null) {
          scored.add(_ScoredHit(
            StickerHit(sticker: sticker, packId: pack.id),
            score,
          ));
        }
      }
    }

    // 同分按使用次数降序，保持稳定排序
    scored.sort((a, b) {
      final byScore = a.score.compareTo(b.score);
      if (byScore != 0) return byScore;
      return b.hit.sticker.usageCount.compareTo(a.hit.sticker.usageCount);
    });

    return scored.take(limit).map((e) => e.hit).toList();
  }

  /// 含 markdown / 提及 / 命令等标记，不触发联想
  static final RegExp _markdownChars = RegExp(r'[*_~`\[\]()]');
  static final RegExp _lastWord = RegExp(r'(\S+)$');
  static final RegExp _asciiOnly = RegExp(r'^[\x00-\x7F]+$');

  /// 从 [text] 中（光标位置 [cursorOffset] 之前）提取可触发贴纸联想的词。
  ///
  /// 返回 null 表示不触发。规则：
  /// - 斜杠命令 / @提及 / #话题 / 含 markdown 标记不触发；
  /// - 取光标前最后一个以空白分隔的词；
  /// - 纯 ASCII 词需 ≥2 个字符（避免 "a"/"i" 等噪声），
  ///   含非 ASCII（emoji/中文等）放宽到 ≥1；
  /// - 词过长（>32）不触发。
  static String? extractQuery(String text, int cursorOffset) {
    if (text.isEmpty) return null;
    final offset =
        (cursorOffset < 0 || cursorOffset > text.length) ? text.length : cursorOffset;
    final before = text.substring(0, offset);
    if (before.trimLeft().startsWith('/')) return null;

    final match = _lastWord.firstMatch(before);
    if (match == null) return null;
    final word = match.group(1)!.trim();
    if (word.isEmpty) return null;
    if (word.startsWith('@') || word.startsWith('#')) return null;
    if (_markdownChars.hasMatch(word)) return null;
    if (word.length > 32) return null;

    final isAscii = _asciiOnly.hasMatch(word);
    if (isAscii && word.length < 2) return null;

    return word;
  }
}

class _ScoredHit {
  final StickerHit hit;
  final int score;
  const _ScoredHit(this.hit, this.score);
}
