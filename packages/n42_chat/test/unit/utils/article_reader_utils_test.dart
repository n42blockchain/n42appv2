import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/utils/article_reader_utils.dart';

void main() {
  group('isLongArticle', () {
    test('false for short text', () {
      expect(ArticleReaderUtils.isLongArticle('hi there'), isFalse);
    });

    test('true at/over threshold', () {
      final long = 'a' * ArticleReaderUtils.longArticleThreshold;
      expect(ArticleReaderUtils.isLongArticle(long), isTrue);
    });

    test('ignores surrounding whitespace', () {
      expect(ArticleReaderUtils.isLongArticle('   hi   '), isFalse);
    });
  });

  group('estimateReadingMinutes', () {
    test('at least 1 minute for any non-trivial text', () {
      expect(ArticleReaderUtils.estimateReadingMinutes('short'), 1);
    });

    test('scales with English word count (~200 wpm)', () {
      final words = List.filled(600, 'word').join(' '); // ~3 min
      expect(ArticleReaderUtils.estimateReadingMinutes(words), 3);
    });

    test('counts CJK characters (~300 cpm)', () {
      final cjk = '字' * 900; // ~3 min
      expect(ArticleReaderUtils.estimateReadingMinutes(cjk), 3);
    });
  });

  group('extractTitle', () {
    test('uses first markdown heading even if not the first line', () {
      const md = 'intro line\n\n# Real Title\n\nbody';
      expect(ArticleReaderUtils.extractTitle(md), 'Real Title');
    });

    test('prefers heading when it is first non-empty', () {
      const md = '## Heading Here\nbody text';
      expect(ArticleReaderUtils.extractTitle(md), 'Heading Here');
    });

    test('falls back to first non-empty line, stripped of markdown', () {
      const md = '**Bold** lead paragraph';
      expect(ArticleReaderUtils.extractTitle(md), 'Bold lead paragraph');
    });

    test('clips very long titles', () {
      final long = 'word ' * 40;
      final title = ArticleReaderUtils.extractTitle(long);
      expect(title.endsWith('…'), isTrue);
      expect(title.length, lessThanOrEqualTo(61));
    });

    test('returns fallback for empty content', () {
      expect(ArticleReaderUtils.extractTitle('   ', fallback: 'X'), 'X');
    });
  });
}
