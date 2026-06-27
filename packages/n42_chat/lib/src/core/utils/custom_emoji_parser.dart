import '../../domain/entities/custom_emoji.dart';

/// 文本片段：普通文本或一个自定义 emoji
class CustomEmojiToken {
  /// 普通文本（emoji 片段时为 `:shortcode:` 原文）
  final String text;

  /// 命中的自定义 emoji（null 表示普通文本）
  final CustomEmoji? emoji;

  const CustomEmojiToken.text(this.text) : emoji = null;
  const CustomEmojiToken.emoji(this.emoji, this.text);

  bool get isEmoji => emoji != null;
}

/// `:shortcode:` 自定义 emoji 解析（纯逻辑，便于单测）
class CustomEmojiParser {
  CustomEmojiParser._();

  /// 短代码合法字符：字母/数字/下划线/加减号
  static final RegExp _shortcodePattern = RegExp(
    r':([a-z0-9_+\-]+):',
    caseSensitive: false,
  );

  /// 触发联想用：光标前的 `:partial`（无闭合冒号）
  static final RegExp _triggerPattern = RegExp(
    r':([a-z0-9_+\-]*)$',
    caseSensitive: false,
  );

  /// 文本是否可能含自定义 emoji（快速预判，避免无谓分词）
  static bool mightContain(String text) => text.contains(':');

  /// 把 [text] 解析为文本/emoji 片段序列。
  ///
  /// 仅 [BuiltinCustomEmojis.has] 命中的 `:code:` 才视为 emoji，未知的保留为
  /// 普通文本（避免把 `http://` 等误判）。相邻文本片段会合并。
  static List<CustomEmojiToken> parse(String text) {
    if (text.isEmpty || !mightContain(text)) {
      return [CustomEmojiToken.text(text)];
    }

    final tokens = <CustomEmojiToken>[];
    final buffer = StringBuffer();
    var index = 0;

    void flushText() {
      if (buffer.isNotEmpty) {
        tokens.add(CustomEmojiToken.text(buffer.toString()));
        buffer.clear();
      }
    }

    for (final match in _shortcodePattern.allMatches(text)) {
      final code = match.group(1)!;
      final emoji = BuiltinCustomEmojis.lookup(code);
      if (emoji == null) continue; // 未知短代码 → 当普通文本

      // match 前的普通文本
      buffer.write(text.substring(index, match.start));
      flushText();
      tokens.add(CustomEmojiToken.emoji(emoji, match.group(0)!));
      index = match.end;
    }

    if (index < text.length) {
      buffer.write(text.substring(index));
    }
    flushText();

    if (tokens.isEmpty) {
      return [CustomEmojiToken.text(text)];
    }
    return tokens;
  }

  /// 文本是否包含至少一个已知自定义 emoji
  static bool hasKnownEmoji(String text) {
    if (!mightContain(text)) return false;
    for (final match in _shortcodePattern.allMatches(text)) {
      if (BuiltinCustomEmojis.has(match.group(1)!)) return true;
    }
    return false;
  }

  /// 从输入框文本（光标位置 [cursorOffset] 之前）提取 `:partial` 联想词。
  ///
  /// 返回 null 表示不触发。需要至少 1 个字符，且 `:` 前不是字母/数字
  /// （避免把 `http://` 的 `//` 之类误触发；`a:b` 等也不触发）。
  static String? extractTrigger(String text, int cursorOffset) {
    if (text.isEmpty) return null;
    final offset = (cursorOffset < 0 || cursorOffset > text.length)
        ? text.length
        : cursorOffset;
    final before = text.substring(0, offset);
    final match = _triggerPattern.firstMatch(before);
    if (match == null) return null;

    final colonStart = match.start;
    if (colonStart > 0) {
      final prev = before[colonStart - 1];
      if (RegExp(r'[A-Za-z0-9]').hasMatch(prev)) return null;
    }
    final query = match.group(1)!;
    if (query.length > 32) return null;
    return query; // 可能为空字符串（刚输入 `:`），由调用方决定是否展示全部
  }
}
