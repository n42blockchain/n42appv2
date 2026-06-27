/// 长文阅读器纯逻辑（阅读时长估算 + 标题提取），无 IO，便于单测。
class ArticleReaderUtils {
  ArticleReaderUtils._();

  /// 视为「长文」的最小字符数（达到才提供阅读模式入口）
  static const int longArticleThreshold = 240;

  static final RegExp _cjk = RegExp(r'[一-鿿぀-ヿ가-힯]');
  static final RegExp _wordSep = RegExp(r'\s+');
  static final RegExp _headingLine = RegExp(r'^\s{0,3}#{1,6}\s+(.+?)\s*#*\s*$');
  static final RegExp _mdInline = RegExp(r'[*_`~\[\]()>#]');

  /// 是否达到长文阈值（按可见字符数，去掉首尾空白）
  static bool isLongArticle(String text) =>
      text.trim().length >= longArticleThreshold;

  /// 估算阅读分钟数（至少 1 分钟）。
  ///
  /// 中日韩按字符计（~300 字/分），其余按空白分词的词数计（~200 词/分），两者相加。
  static int estimateReadingMinutes(String text) {
    final cjkCount = _cjk.allMatches(text).length;
    final nonCjk = text.replaceAll(_cjk, ' ').trim();
    final wordCount = nonCjk.isEmpty
        ? 0
        : nonCjk.split(_wordSep).where((w) => w.isNotEmpty).length;
    final minutes = (cjkCount / 300.0) + (wordCount / 200.0);
    final rounded = minutes.ceil();
    return rounded < 1 ? 1 : rounded;
  }

  /// 提取标题：首个 Markdown 标题行；否则首个非空行（截断到 60 字，去内联标记）。
  static String extractTitle(String text, {String fallback = 'Article'}) {
    final lines = text.split('\n');
    for (final line in lines) {
      final m = _headingLine.firstMatch(line);
      if (m != null) {
        final t = m.group(1)!.trim();
        if (t.isNotEmpty) return _clip(t);
      }
    }
    for (final line in lines) {
      final t = line.trim();
      if (t.isNotEmpty) return _clip(_stripInline(t));
    }
    return fallback;
  }

  static String _stripInline(String s) => s.replaceAll(_mdInline, '').trim();

  static String _clip(String s) => s.length <= 60 ? s : '${s.substring(0, 60)}…';
}
