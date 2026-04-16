// Tests for StringUtils and TextPart.
// Pure Dart — no platform dependencies.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/utils/string_utils.dart';

void main() {
  // ─────────────────────────────────────────────────
  // extractUsername
  // ─────────────────────────────────────────────────

  group('StringUtils.extractUsername', () {
    test('extracts user part from @user:server.com', () {
      expect(StringUtils.extractUsername('@alice:server.com'), 'alice');
    });

    test('handles @ prefix with no colon — strips leading @', () {
      expect(StringUtils.extractUsername('@alice'), 'alice');
    });

    test('empty string returns empty', () {
      expect(StringUtils.extractUsername(''), '');
    });

    test('string without @ is returned as-is', () {
      expect(StringUtils.extractUsername('alice'), 'alice');
    });

    test('preserves digits and underscores in username', () {
      expect(StringUtils.extractUsername('@user_123:server.com'), 'user_123');
    });

    test('server contains dots — only extracts before first colon', () {
      expect(StringUtils.extractUsername('@bob:matrix.example.org'), 'bob');
    });
  });

  // ─────────────────────────────────────────────────
  // extractServer
  // ─────────────────────────────────────────────────

  group('StringUtils.extractServer', () {
    test('extracts server part from @user:server.com', () {
      expect(StringUtils.extractServer('@alice:server.com'), 'server.com');
    });

    test('empty string returns empty', () {
      expect(StringUtils.extractServer(''), '');
    });

    test('string without colon returns empty', () {
      expect(StringUtils.extractServer('@alice'), '');
    });

    test('colon at last position returns empty', () {
      expect(StringUtils.extractServer('alice:'), '');
    });

    test('full Matrix ID returns full server', () {
      expect(StringUtils.extractServer('@bob:matrix.example.org'), 'matrix.example.org');
    });
  });

  // ─────────────────────────────────────────────────
  // createMatrixId
  // ─────────────────────────────────────────────────

  group('StringUtils.createMatrixId', () {
    test('creates @user:server format', () {
      expect(StringUtils.createMatrixId('alice', 'server.com'), '@alice:server.com');
    });

    test('strips leading @ from username if present', () {
      expect(StringUtils.createMatrixId('@alice', 'server.com'), '@alice:server.com');
    });

    test('strips leading : from server if present', () {
      expect(StringUtils.createMatrixId('alice', ':server.com'), '@alice:server.com');
    });

    test('handles both having prefix', () {
      expect(StringUtils.createMatrixId('@alice', ':server.com'), '@alice:server.com');
    });
  });

  // ─────────────────────────────────────────────────
  // truncate
  // ─────────────────────────────────────────────────

  group('StringUtils.truncate', () {
    test('short string is returned unchanged', () {
      expect(StringUtils.truncate('hello', 10), 'hello');
    });

    test('string at exact limit is returned unchanged', () {
      expect(StringUtils.truncate('hello', 5), 'hello');
    });

    test('long string is truncated with default ellipsis', () {
      expect(StringUtils.truncate('hello world', 8), 'hello...');
    });

    test('custom ellipsis is applied', () {
      expect(StringUtils.truncate('hello world', 6, ellipsis: '…'), 'hello…');
    });

    test('ellipsis-only truncation when maxLength equals ellipsis length', () {
      expect(StringUtils.truncate('hello', 3), '...');
    });
  });

  // ─────────────────────────────────────────────────
  // getDisplayName
  // ─────────────────────────────────────────────────

  group('StringUtils.getDisplayName', () {
    test('returns displayName when non-empty', () {
      expect(StringUtils.getDisplayName('Alice', '@alice:server.com'), 'Alice');
    });

    test('returns username from userId when displayName is null', () {
      expect(StringUtils.getDisplayName(null, '@alice:server.com'), 'alice');
    });

    test('returns username from userId when displayName is empty', () {
      expect(StringUtils.getDisplayName('', '@alice:server.com'), 'alice');
    });
  });

  // ─────────────────────────────────────────────────
  // getInitials
  // ─────────────────────────────────────────────────

  group('StringUtils.getInitials', () {
    test('empty name returns ?', () {
      expect(StringUtils.getInitials(''), '?');
    });

    test('single word — first 2 chars uppercased', () {
      expect(StringUtils.getInitials('alice'), 'AL');
    });

    test('single char word', () {
      expect(StringUtils.getInitials('a'), 'A');
    });

    test('two words — first letter of each', () {
      expect(StringUtils.getInitials('Alice Bob'), 'AB');
    });

    test('three words — only takes first 2 (maxLength=2)', () {
      expect(StringUtils.getInitials('Alice Bob Charlie'), 'AB');
    });

    test('custom maxLength=3 takes 3 word initials', () {
      expect(StringUtils.getInitials('Alice Bob Charlie', maxLength: 3), 'ABC');
    });

    test('multiple spaces between words', () {
      expect(StringUtils.getInitials('Alice  Bob'), 'AB');
    });
  });

  // ─────────────────────────────────────────────────
  // isValidMatrixId / isValidRoomId / isValidRoomAlias
  // ─────────────────────────────────────────────────

  group('StringUtils.isValidMatrixId', () {
    test('valid Matrix user ID returns true', () {
      expect(StringUtils.isValidMatrixId('@alice:server.com'), isTrue);
    });

    test('missing @ prefix returns false', () {
      expect(StringUtils.isValidMatrixId('alice:server.com'), isFalse);
    });

    test('missing server returns false', () {
      expect(StringUtils.isValidMatrixId('@alice'), isFalse);
    });

    test('empty string returns false', () {
      expect(StringUtils.isValidMatrixId(''), isFalse);
    });
  });

  group('StringUtils.isValidRoomId', () {
    test('valid room ID with ! prefix returns true', () {
      expect(StringUtils.isValidRoomId('!roomabc123:server.com'), isTrue);
    });

    test('missing ! prefix returns false', () {
      expect(StringUtils.isValidRoomId('roomabc123:server.com'), isFalse);
    });

    test('@ prefix (user ID) returns false', () {
      expect(StringUtils.isValidRoomId('@user:server.com'), isFalse);
    });
  });

  group('StringUtils.isValidRoomAlias', () {
    test('valid room alias with # prefix returns true', () {
      expect(StringUtils.isValidRoomAlias('#general:server.com'), isTrue);
    });

    test('missing # prefix returns false', () {
      expect(StringUtils.isValidRoomAlias('general:server.com'), isFalse);
    });

    test('room ID (!) is not a room alias', () {
      expect(StringUtils.isValidRoomAlias('!roomid:server.com'), isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // formatMessagePreview
  // ─────────────────────────────────────────────────

  group('StringUtils.formatMessagePreview', () {
    test('short content is returned unchanged', () {
      expect(StringUtils.formatMessagePreview('Hello world'), 'Hello world');
    });

    test('newlines are collapsed to spaces', () {
      final result = StringUtils.formatMessagePreview('Hello\nworld');
      expect(result, 'Hello world');
    });

    test('multiple whitespace collapsed to single space', () {
      final result = StringUtils.formatMessagePreview('Hello   world');
      expect(result, 'Hello world');
    });

    test('long content is truncated to default 50 chars', () {
      final longText = 'a' * 60;
      final result = StringUtils.formatMessagePreview(longText);
      expect(result.length, 50);
      expect(result.endsWith('...'), isTrue);
    });

    test('custom maxLength is respected', () {
      final result = StringUtils.formatMessagePreview('Hello world', maxLength: 8);
      expect(result, 'Hello...');
    });
  });

  // ─────────────────────────────────────────────────
  // formatFileSize
  // ─────────────────────────────────────────────────

  group('StringUtils.formatFileSize', () {
    test('bytes (< 1024) shows B', () {
      expect(StringUtils.formatFileSize(500), '500 B');
    });

    test('kilobytes (1024–1048575) shows KB', () {
      expect(StringUtils.formatFileSize(1024), '1.0 KB');
      expect(StringUtils.formatFileSize(2048), '2.0 KB');
    });

    test('megabytes shows MB', () {
      expect(StringUtils.formatFileSize(1024 * 1024), '1.0 MB');
    });

    test('gigabytes shows GB', () {
      expect(StringUtils.formatFileSize(1024 * 1024 * 1024), '1.0 GB');
    });

    test('0 bytes shows 0 B', () {
      expect(StringUtils.formatFileSize(0), '0 B');
    });
  });

  // ─────────────────────────────────────────────────
  // extractUrls
  // ─────────────────────────────────────────────────

  group('StringUtils.extractUrls', () {
    test('extracts single http URL', () {
      final urls = StringUtils.extractUrls('visit http://example.com today');
      expect(urls, ['http://example.com']);
    });

    test('extracts single https URL', () {
      final urls = StringUtils.extractUrls('check https://example.com');
      expect(urls, ['https://example.com']);
    });

    test('extracts multiple URLs', () {
      final urls = StringUtils.extractUrls('https://a.com and https://b.com');
      expect(urls.length, 2);
    });

    test('no URLs returns empty list', () {
      final urls = StringUtils.extractUrls('no links here');
      expect(urls, isEmpty);
    });

    test('empty string returns empty list', () {
      expect(StringUtils.extractUrls(''), isEmpty);
    });
  });

  // ─────────────────────────────────────────────────
  // isOnlyEmoji
  // ─────────────────────────────────────────────────

  group('StringUtils.isOnlyEmoji', () {
    test('single emoji returns true', () {
      expect(StringUtils.isOnlyEmoji('😀'), isTrue);
    });

    test('multiple emojis returns true', () {
      expect(StringUtils.isOnlyEmoji('😀😍🎉'), isTrue);
    });

    test('text with emoji returns false', () {
      expect(StringUtils.isOnlyEmoji('Hello 😀'), isFalse);
    });

    test('plain text returns false', () {
      expect(StringUtils.isOnlyEmoji('hello'), isFalse);
    });

    test('empty string returns false (not emoji-only)', () {
      expect(StringUtils.isOnlyEmoji(''), isFalse);
    });

    test('whitespace-only returns false', () {
      expect(StringUtils.isOnlyEmoji('   '), isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // highlightKeyword
  // ─────────────────────────────────────────────────

  group('StringUtils.highlightKeyword', () {
    test('empty keyword returns single non-highlighted part', () {
      final parts = StringUtils.highlightKeyword('Hello world', '');
      expect(parts.length, 1);
      expect(parts.first.text, 'Hello world');
      expect(parts.first.isHighlight, isFalse);
    });

    test('keyword not found returns single non-highlighted part', () {
      final parts = StringUtils.highlightKeyword('Hello world', 'xyz');
      expect(parts.length, 1);
      expect(parts.first.isHighlight, isFalse);
    });

    test('keyword matches entire string', () {
      final parts = StringUtils.highlightKeyword('hello', 'hello');
      expect(parts.length, 1);
      expect(parts.first.isHighlight, isTrue);
      expect(parts.first.text, 'hello');
    });

    test('keyword at start produces [highlighted, normal]', () {
      final parts = StringUtils.highlightKeyword('Hello world', 'Hello');
      expect(parts.length, 2);
      expect(parts[0].isHighlight, isTrue);
      expect(parts[0].text, 'Hello');
      expect(parts[1].isHighlight, isFalse);
      expect(parts[1].text, ' world');
    });

    test('keyword at end produces [normal, highlighted]', () {
      final parts = StringUtils.highlightKeyword('Hello world', 'world');
      expect(parts.length, 2);
      expect(parts[0].isHighlight, isFalse);
      expect(parts[1].isHighlight, isTrue);
    });

    test('keyword in middle produces [normal, highlighted, normal]', () {
      final parts = StringUtils.highlightKeyword('say hello now', 'hello');
      expect(parts.length, 3);
      expect(parts[0].isHighlight, isFalse);
      expect(parts[1].isHighlight, isTrue);
      expect(parts[1].text, 'hello');
      expect(parts[2].isHighlight, isFalse);
    });

    test('case-insensitive matching', () {
      final parts = StringUtils.highlightKeyword('Hello World', 'hello');
      expect(parts.any((p) => p.isHighlight), isTrue);
    });

    test('multiple occurrences all highlighted', () {
      final parts = StringUtils.highlightKeyword('ab ab ab', 'ab');
      final highlighted = parts.where((p) => p.isHighlight).toList();
      expect(highlighted.length, 3);
    });
  });

  // ─────────────────────────────────────────────────
  // TextPart
  // ─────────────────────────────────────────────────

  group('TextPart', () {
    test('stores text and isHighlight flag', () {
      const part = TextPart('hello', isHighlight: true);
      expect(part.text, 'hello');
      expect(part.isHighlight, isTrue);
    });

    test('non-highlighted part', () {
      const part = TextPart('world', isHighlight: false);
      expect(part.isHighlight, isFalse);
    });
  });
}
