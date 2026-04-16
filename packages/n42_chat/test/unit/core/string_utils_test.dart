// Tests for StringUtils and TextPart in string_utils.dart.
// All methods are pure Dart — no platform deps.
//
// Note: extractUsername, extractServer, isValidMatrixId, isValidRoomId,
// isValidRoomAlias, and truncate are already covered via string_extension_test;
// this file focuses on createMatrixId, getDisplayName, getInitials,
// formatMessagePreview, formatFileSize, extractUrls, isOnlyEmoji,
// highlightKeyword, and TextPart.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/utils/string_utils.dart';

void main() {
  // ─────────────────────────────────────────────────
  // createMatrixId
  // ─────────────────────────────────────────────────

  group('StringUtils.createMatrixId', () {
    test('combines username and server with @ and :', () {
      expect(StringUtils.createMatrixId('alice', 'matrix.org'), '@alice:matrix.org');
    });

    test('strips leading @ from username', () {
      expect(StringUtils.createMatrixId('@alice', 'matrix.org'), '@alice:matrix.org');
    });

    test('strips leading : from server', () {
      expect(StringUtils.createMatrixId('alice', ':matrix.org'), '@alice:matrix.org');
    });

    test('strips both @ and : from components', () {
      expect(StringUtils.createMatrixId('@bob', ':server.com'), '@bob:server.com');
    });

    test('plain username without @ is prefixed', () {
      expect(StringUtils.createMatrixId('charlie', 'example.com'), '@charlie:example.com');
    });
  });

  // ─────────────────────────────────────────────────
  // getDisplayName
  // ─────────────────────────────────────────────────

  group('StringUtils.getDisplayName', () {
    test('non-null non-empty displayName is returned', () {
      expect(StringUtils.getDisplayName('Alice', '@alice:matrix.org'), 'Alice');
    });

    test('null displayName falls back to username extracted from userId', () {
      expect(StringUtils.getDisplayName(null, '@bob:matrix.org'), 'bob');
    });

    test('empty displayName falls back to username', () {
      expect(StringUtils.getDisplayName('', '@carol:matrix.org'), 'carol');
    });

    test('userId without @ is returned as-is when displayName absent', () {
      expect(StringUtils.getDisplayName(null, 'plainid'), 'plainid');
    });
  });

  // ─────────────────────────────────────────────────
  // getInitials
  // ─────────────────────────────────────────────────

  group('StringUtils.getInitials', () {
    test('empty string returns ?', () {
      expect(StringUtils.getInitials(''), '?');
    });

    test('single word ≥2 chars returns 2 chars uppercased', () {
      expect(StringUtils.getInitials('alice'), 'AL');
    });

    test('single 1-char word returns 1 char uppercased', () {
      expect(StringUtils.getInitials('x'), 'X');
    });

    test('two words returns first char of each', () {
      expect(StringUtils.getInitials('Alice Bob'), 'AB');
    });

    test('three words with default maxLength=2 returns 2 chars', () {
      expect(StringUtils.getInitials('Alice Bob Carol'), 'AB');
    });

    test('three words with maxLength=3 returns 3 chars', () {
      expect(StringUtils.getInitials('Alice Bob Carol', maxLength: 3), 'ABC');
    });

    test('extra whitespace is collapsed', () {
      expect(StringUtils.getInitials('  Alice   Bob  '), 'AB');
    });
  });

  // ─────────────────────────────────────────────────
  // formatMessagePreview
  // ─────────────────────────────────────────────────

  group('StringUtils.formatMessagePreview', () {
    test('short content is returned as-is', () {
      expect(StringUtils.formatMessagePreview('Hello world'), 'Hello world');
    });

    test('newlines replaced with spaces', () {
      expect(StringUtils.formatMessagePreview('Hello\nworld'), 'Hello world');
    });

    test('multiple whitespace collapsed to single space', () {
      expect(StringUtils.formatMessagePreview('Hello   world'), 'Hello world');
    });

    test('leading/trailing whitespace is trimmed', () {
      expect(StringUtils.formatMessagePreview('  Hello  '), 'Hello');
    });

    test('content longer than default 50 chars is truncated', () {
      final long = 'A' * 60;
      final result = StringUtils.formatMessagePreview(long);
      expect(result.length, 50);
      expect(result.endsWith('...'), isTrue);
    });

    test('custom maxLength is respected', () {
      final result = StringUtils.formatMessagePreview('Hello world', maxLength: 8);
      expect(result.length, 8);
      expect(result.endsWith('...'), isTrue);
    });
  });

  // ─────────────────────────────────────────────────
  // formatFileSize
  // ─────────────────────────────────────────────────

  group('StringUtils.formatFileSize', () {
    test('0 bytes', () {
      expect(StringUtils.formatFileSize(0), '0 B');
    });

    test('1023 bytes → B', () {
      expect(StringUtils.formatFileSize(1023), '1023 B');
    });

    test('1024 bytes → 1.0 KB', () {
      expect(StringUtils.formatFileSize(1024), '1.0 KB');
    });

    test('1536 bytes → 1.5 KB', () {
      expect(StringUtils.formatFileSize(1536), '1.5 KB');
    });

    test('1 MB (1024*1024)', () {
      expect(StringUtils.formatFileSize(1024 * 1024), '1.0 MB');
    });

    test('1.5 MB', () {
      expect(StringUtils.formatFileSize((1024 * 1024 * 1.5).toInt()), '1.5 MB');
    });

    test('1 GB (1024^3)', () {
      expect(StringUtils.formatFileSize(1024 * 1024 * 1024), '1.0 GB');
    });

    test('2 GB', () {
      expect(StringUtils.formatFileSize(2 * 1024 * 1024 * 1024), '2.0 GB');
    });
  });

  // ─────────────────────────────────────────────────
  // extractUrls
  // ─────────────────────────────────────────────────

  group('StringUtils.extractUrls', () {
    test('extracts single https URL', () {
      final urls = StringUtils.extractUrls('Visit https://example.com for info');
      expect(urls, ['https://example.com']);
    });

    test('extracts single http URL', () {
      final urls = StringUtils.extractUrls('See http://example.com/page');
      expect(urls, ['http://example.com/page']);
    });

    test('extracts multiple URLs', () {
      final urls = StringUtils.extractUrls(
        'Go to https://foo.com and https://bar.com',
      );
      expect(urls, ['https://foo.com', 'https://bar.com']);
    });

    test('no URLs returns empty list', () {
      final urls = StringUtils.extractUrls('Hello world, no links here');
      expect(urls, isEmpty);
    });

    test('plain domain without scheme is not extracted', () {
      final urls = StringUtils.extractUrls('Visit example.com today');
      expect(urls, isEmpty);
    });

    test('empty text returns empty list', () {
      expect(StringUtils.extractUrls(''), isEmpty);
    });
  });

  // ─────────────────────────────────────────────────
  // isOnlyEmoji
  // ─────────────────────────────────────────────────

  group('StringUtils.isOnlyEmoji', () {
    test('single emoji → true', () {
      expect(StringUtils.isOnlyEmoji('😀'), isTrue);
    });

    test('multiple emojis → true', () {
      expect(StringUtils.isOnlyEmoji('😀🎉'), isTrue);
    });

    test('emoji with text → false', () {
      expect(StringUtils.isOnlyEmoji('Hello 😀'), isFalse);
    });

    test('plain text → false', () {
      expect(StringUtils.isOnlyEmoji('Hello'), isFalse);
    });

    test('empty string → false (text must not be empty)', () {
      expect(StringUtils.isOnlyEmoji(''), isFalse);
    });

    test('whitespace only → false', () {
      expect(StringUtils.isOnlyEmoji('   '), isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // highlightKeyword
  // ─────────────────────────────────────────────────

  group('StringUtils.highlightKeyword', () {
    test('empty keyword returns single non-highlight part', () {
      final parts = StringUtils.highlightKeyword('Hello world', '');
      expect(parts, hasLength(1));
      expect(parts[0].text, 'Hello world');
      expect(parts[0].isHighlight, isFalse);
    });

    test('keyword at start of text', () {
      final parts = StringUtils.highlightKeyword('Hello world', 'Hello');
      expect(parts, hasLength(2));
      expect(parts[0].text, 'Hello');
      expect(parts[0].isHighlight, isTrue);
      expect(parts[1].text, ' world');
      expect(parts[1].isHighlight, isFalse);
    });

    test('keyword at end of text', () {
      final parts = StringUtils.highlightKeyword('Hello world', 'world');
      expect(parts, hasLength(2));
      expect(parts[0].text, 'Hello ');
      expect(parts[0].isHighlight, isFalse);
      expect(parts[1].text, 'world');
      expect(parts[1].isHighlight, isTrue);
    });

    test('keyword in middle of text', () {
      final parts = StringUtils.highlightKeyword('say hello there', 'hello');
      expect(parts, hasLength(3));
      expect(parts[0].isHighlight, isFalse);
      expect(parts[1].isHighlight, isTrue);
      expect(parts[2].isHighlight, isFalse);
    });

    test('keyword appears twice', () {
      final parts = StringUtils.highlightKeyword('foo bar foo', 'foo');
      final highlights = parts.where((p) => p.isHighlight).toList();
      expect(highlights, hasLength(2));
    });

    test('matching is case-insensitive', () {
      final parts = StringUtils.highlightKeyword('Hello World', 'hello');
      expect(parts[0].isHighlight, isTrue);
      expect(parts[0].text, 'Hello'); // preserves original case
    });

    test('no match returns single non-highlight part', () {
      final parts = StringUtils.highlightKeyword('Hello world', 'xyz');
      expect(parts, hasLength(1));
      expect(parts[0].isHighlight, isFalse);
    });

    test('exact match of whole text', () {
      final parts = StringUtils.highlightKeyword('hello', 'hello');
      expect(parts, hasLength(1));
      expect(parts[0].isHighlight, isTrue);
    });
  });

  // ─────────────────────────────────────────────────
  // TextPart
  // ─────────────────────────────────────────────────

  group('TextPart', () {
    test('stores text and isHighlight=false', () {
      const p = TextPart('hello', isHighlight: false);
      expect(p.text, 'hello');
      expect(p.isHighlight, isFalse);
    });

    test('stores text and isHighlight=true', () {
      const p = TextPart('world', isHighlight: true);
      expect(p.text, 'world');
      expect(p.isHighlight, isTrue);
    });

    test('empty text is allowed', () {
      const p = TextPart('', isHighlight: false);
      expect(p.text, '');
    });
  });
}
