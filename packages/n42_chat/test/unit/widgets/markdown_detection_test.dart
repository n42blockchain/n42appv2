import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/utils/message_markdown_utils.dart';

void main() {
  group('containsMarkdown', () {
    group('bold syntax', () {
      test('should detect **bold** (asterisks)', () {
        expect(containsMarkdown('This is **bold** text'), true);
      });

      test('should detect __bold__ (underscores)', () {
        expect(containsMarkdown('This is __bold__ text'), true);
      });

      test('should not detect incomplete bold **', () {
        expect(containsMarkdown('This is ** not bold'), false);
      });
    });

    group('italic syntax', () {
      test('should detect *italic* (single asterisk)', () {
        expect(containsMarkdown('This is *italic* text'), true);
      });

      test('should detect _italic_ (single underscore)', () {
        expect(containsMarkdown('This is _italic_ text'), true);
      });
    });

    group('strikethrough syntax', () {
      test('should detect ~~strikethrough~~', () {
        expect(containsMarkdown('This is ~~deleted~~ text'), true);
      });

      test('should not detect incomplete strikethrough', () {
        expect(containsMarkdown('This is ~~ not strikethrough'), false);
      });
    });

    group('code syntax', () {
      test('should detect `inline code`', () {
        expect(containsMarkdown('Use `print()` function'), true);
      });

      test('should detect ```code block```', () {
        expect(containsMarkdown('```\ncode here\n```'), true);
      });

      test('should detect code block with language', () {
        expect(containsMarkdown('```dart\nvoid main() {}\n```'), true);
      });
    });

    group('heading syntax', () {
      test('should detect # h1', () {
        expect(containsMarkdown('# Title'), true);
      });

      test('should detect ## h2', () {
        expect(containsMarkdown('## Subtitle'), true);
      });

      test('should detect ### h3', () {
        expect(containsMarkdown('### Section'), true);
      });

      test('should detect #### h4', () {
        expect(containsMarkdown('#### Subsection'), true);
      });

      test('should detect ##### h5', () {
        expect(containsMarkdown('##### Minor'), true);
      });

      test('should detect ###### h6', () {
        expect(containsMarkdown('###### Smallest'), true);
      });

      test('should not detect # without space', () {
        expect(containsMarkdown('#hashtag'), false);
      });
    });

    group('list syntax', () {
      test('should detect unordered list with -', () {
        expect(containsMarkdown('- item one'), true);
      });

      test('should detect unordered list with *', () {
        expect(containsMarkdown('* item one'), true);
      });

      test('should detect unordered list with +', () {
        expect(containsMarkdown('+ item one'), true);
      });

      test('should detect ordered list', () {
        expect(containsMarkdown('1. First item'), true);
      });

      test('should detect ordered list with higher number', () {
        expect(containsMarkdown('42. Forty-second item'), true);
      });

      test('should detect indented list items', () {
        expect(containsMarkdown('  - nested item'), true);
      });
    });

    group('link syntax', () {
      test('should detect [text](url)', () {
        expect(containsMarkdown('Click [here](https://example.com)'), true);
      });

      test('should detect link with title', () {
        expect(containsMarkdown('[link](https://example.com "title")'), true);
      });

      test('should not detect incomplete link', () {
        expect(containsMarkdown('[text only]'), false);
      });
    });

    group('blockquote syntax', () {
      test('should detect > blockquote', () {
        expect(containsMarkdown('> This is a quote'), true);
      });

      test('should detect indented blockquote', () {
        expect(containsMarkdown('  > nested quote'), true);
      });
    });

    group('horizontal rule syntax', () {
      test('should detect ---', () {
        expect(containsMarkdown('---'), true);
      });

      test('should detect --- with surrounding whitespace', () {
        expect(containsMarkdown('  ---  '), true);
      });
    });

    group('table syntax', () {
      test('should detect markdown tables', () {
        const text = '''
| Name | Owner |
| --- | --- |
| Roadmap | Team |
''';
        expect(containsMarkdown(text), true);
      });
    });

    group('plain text (no markdown)', () {
      test('should return false for simple text', () {
        expect(containsMarkdown('Hello World'), false);
      });

      test('should return false for text with numbers', () {
        expect(containsMarkdown('I have 3 cats'), false);
      });

      test('should return false for empty string', () {
        expect(containsMarkdown(''), false);
      });

      test('should return false for text with common punctuation', () {
        expect(containsMarkdown('Hello! How are you?'), false);
      });

      test('should return false for URL without markdown link syntax', () {
        expect(containsMarkdown('https://example.com'), false);
      });

      test('should return false for email address', () {
        expect(containsMarkdown('user@example.com'), false);
      });

      test('should not treat snake_case identifiers as markdown', () {
        expect(containsMarkdown('foo_bar_baz.dart'), false);
      });
    });

    group('mixed content', () {
      test('should detect markdown in multiline text', () {
        const text = '''
This is a paragraph.

# This is a heading

And more text.
''';
        expect(containsMarkdown(text), true);
      });

      test('should detect markdown when mixed with plain text', () {
        expect(containsMarkdown('Here is some **important** info'), true);
      });

      test('should detect list in multiline', () {
        const text = 'Shopping:\n- Apples\n- Oranges\n- Bananas';
        expect(containsMarkdown(text), true);
      });
    });
  });

  group('sanitization', () {
    test('escapes raw html tags when markdown is present', () {
      final sanitized = sanitizeMarkdownDisplayText(
        '**bold** <img src="x" onerror="alert(1)">',
      );

      expect(
        sanitized,
        contains('&lt;img src=&quot;x&quot; onerror=&quot;alert(1)&quot;&gt;'),
      );
      expect(sanitized, isNot(contains('<img')));
    });

    test('buildMatrixFormattedBody keeps plain snake_case untouched', () {
      final html = buildMatrixFormattedBody('foo_bar_baz.dart');

      expect(html, 'foo_bar_baz.dart');
    });
  });
}
