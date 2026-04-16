// Tests for StringExtension and NullableStringExtension in string_extension.dart.
// All methods are pure Dart — no mocks needed.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/extensions/string_extension.dart';

void main() {
  // ─────────────────────────────────────────────────
  // isBlank / isNotBlank
  // ─────────────────────────────────────────────────

  group('StringExtension.isBlank', () {
    test('empty string is blank', () {
      expect(''.isBlank, isTrue);
    });

    test('whitespace-only string is blank', () {
      expect('   '.isBlank, isTrue);
    });

    test('non-empty string is not blank', () {
      expect('hello'.isBlank, isFalse);
    });

    test('string with content after trim is not blank', () {
      expect('  hi  '.isBlank, isFalse);
    });
  });

  group('StringExtension.isNotBlank', () {
    test('non-empty string is not blank', () {
      expect('hello'.isNotBlank, isTrue);
    });

    test('empty string is not isNotBlank', () {
      expect(''.isNotBlank, isFalse);
    });

    test('whitespace-only is not isNotBlank', () {
      expect('  '.isNotBlank, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // capitalize / titleCase
  // ─────────────────────────────────────────────────

  group('StringExtension.capitalize', () {
    test('empty string stays empty', () {
      expect(''.capitalize, '');
    });

    test('first character uppercased', () {
      expect('hello'.capitalize, 'Hello');
    });

    test('rest of string preserved', () {
      expect('hELLO'.capitalize, 'HELLO');
    });

    test('already capitalized is unchanged', () {
      expect('Hello'.capitalize, 'Hello');
    });
  });

  group('StringExtension.titleCase', () {
    test('empty string stays empty', () {
      expect(''.titleCase, '');
    });

    test('single word capitalized', () {
      expect('hello'.titleCase, 'Hello');
    });

    test('multiple words each capitalized', () {
      expect('hello world foo'.titleCase, 'Hello World Foo');
    });
  });

  // ─────────────────────────────────────────────────
  // isValidEmail
  // ─────────────────────────────────────────────────

  group('StringExtension.isValidEmail', () {
    test('valid email returns true', () {
      expect('user@example.com'.isValidEmail, isTrue);
    });

    test('email with subdomain returns true', () {
      expect('user@mail.example.org'.isValidEmail, isTrue);
    });

    test('missing @ returns false', () {
      expect('userexample.com'.isValidEmail, isFalse);
    });

    test('missing domain returns false', () {
      expect('user@'.isValidEmail, isFalse);
    });

    test('empty string returns false', () {
      expect(''.isValidEmail, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // isValidUrl
  // ─────────────────────────────────────────────────

  group('StringExtension.isValidUrl', () {
    test('https URL is valid', () {
      expect('https://example.com'.isValidUrl, isTrue);
    });

    test('http URL is valid', () {
      expect('http://example.com/path'.isValidUrl, isTrue);
    });

    test('plain domain without scheme is invalid', () {
      expect('example.com'.isValidUrl, isFalse);
    });

    test('empty string is invalid', () {
      expect(''.isValidUrl, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // isValidMatrixId / isValidRoomId / isValidRoomAlias
  // ─────────────────────────────────────────────────

  group('StringExtension.isValidMatrixId', () {
    test('valid Matrix user ID returns true', () {
      expect('@alice:matrix.org'.isValidMatrixId, isTrue);
    });

    test('missing @ returns false', () {
      expect('alice:matrix.org'.isValidMatrixId, isFalse);
    });
  });

  group('StringExtension.isValidRoomId', () {
    test('valid room ID returns true', () {
      expect('!abc123:matrix.org'.isValidRoomId, isTrue);
    });

    test('missing ! returns false', () {
      expect('abc123:matrix.org'.isValidRoomId, isFalse);
    });
  });

  group('StringExtension.isValidRoomAlias', () {
    test('valid room alias returns true', () {
      expect('#general:matrix.org'.isValidRoomAlias, isTrue);
    });

    test('missing # returns false', () {
      expect('general:matrix.org'.isValidRoomAlias, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // matrixUsername / matrixServer
  // ─────────────────────────────────────────────────

  group('StringExtension.matrixUsername', () {
    test('extracts username from valid ID', () {
      expect('@alice:matrix.org'.matrixUsername, 'alice');
    });

    test('empty string → empty', () {
      expect(''.matrixUsername, '');
    });
  });

  group('StringExtension.matrixServer', () {
    test('extracts server from valid ID', () {
      expect('@alice:matrix.org'.matrixServer, 'matrix.org');
    });

    test('empty string → empty', () {
      expect(''.matrixServer, '');
    });
  });

  // ─────────────────────────────────────────────────
  // truncate
  // ─────────────────────────────────────────────────

  group('StringExtension.truncate', () {
    test('short string is returned unchanged', () {
      expect('hello'.truncate(10), 'hello');
    });

    test('long string is truncated with ellipsis', () {
      expect('hello world'.truncate(8), 'hello...');
    });

    test('custom ellipsis is used', () {
      // maxLength=7, ellipsis='…'(len=1): substring(0, 6) + '…' = 'hello …'
      expect('hello world'.truncate(7, ellipsis: '…'), 'hello …');
    });
  });

  // ─────────────────────────────────────────────────
  // stripHtml
  // ─────────────────────────────────────────────────

  group('StringExtension.stripHtml', () {
    test('removes simple tags', () {
      expect('<b>hello</b>'.stripHtml, 'hello');
    });

    test('removes multiple tags', () {
      expect('<p><b>hello</b> world</p>'.stripHtml, 'hello world');
    });

    test('plain text is unchanged', () {
      expect('plain text'.stripHtml, 'plain text');
    });

    test('empty string stays empty', () {
      expect(''.stripHtml, '');
    });
  });

  // ─────────────────────────────────────────────────
  // asSafeFileName
  // ─────────────────────────────────────────────────

  group('StringExtension.asSafeFileName', () {
    test('replaces prohibited chars with underscore', () {
      expect('file<name>.txt'.asSafeFileName, 'file_name_.txt');
    });

    test('safe characters are unchanged', () {
      expect('safe-file_name 123.txt'.asSafeFileName, 'safe-file_name 123.txt');
    });

    test('replaces slash', () {
      expect('path/to/file'.asSafeFileName, 'path_to_file');
    });
  });

  // ─────────────────────────────────────────────────
  // containsChinese
  // ─────────────────────────────────────────────────

  group('StringExtension.containsChinese', () {
    test('Chinese characters → true', () {
      expect('你好'.containsChinese, isTrue);
    });

    test('mixed Chinese and ASCII → true', () {
      expect('hello 你好'.containsChinese, isTrue);
    });

    test('ASCII only → false', () {
      expect('hello'.containsChinese, isFalse);
    });

    test('empty string → false', () {
      expect(''.containsChinese, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // firstPinyinLetter
  // ─────────────────────────────────────────────────

  group('StringExtension.firstPinyinLetter', () {
    test('empty string returns #', () {
      expect(''.firstPinyinLetter, '#');
    });

    test('uppercase letter is returned as-is', () {
      expect('Alice'.firstPinyinLetter, 'A');
    });

    test('lowercase letter is uppercased', () {
      expect('bob'.firstPinyinLetter, 'B');
    });

    test('Chinese character returns #', () {
      expect('张三'.firstPinyinLetter, '#');
    });

    test('digit returns #', () {
      expect('1abc'.firstPinyinLetter, '#');
    });
  });

  // ─────────────────────────────────────────────────
  // NullableStringExtension
  // ─────────────────────────────────────────────────

  group('NullableStringExtension.isNullOrEmpty', () {
    test('null is null or empty', () {
      const String? s = null;
      expect(s.isNullOrEmpty, isTrue);
    });

    test('empty string is null or empty', () {
      expect(''.isNullOrEmpty, isTrue);
    });

    test('non-empty string is not null or empty', () {
      expect('hello'.isNullOrEmpty, isFalse);
    });
  });

  group('NullableStringExtension.isNotNullOrEmpty', () {
    test('non-empty string is not null or empty', () {
      expect('hello'.isNotNullOrEmpty, isTrue);
    });

    test('null is not isNotNullOrEmpty', () {
      const String? s = null;
      expect(s.isNotNullOrEmpty, isFalse);
    });

    test('empty string is not isNotNullOrEmpty', () {
      expect(''.isNotNullOrEmpty, isFalse);
    });
  });

  group('NullableStringExtension.isNullOrBlank', () {
    test('null is null or blank', () {
      const String? s = null;
      expect(s.isNullOrBlank, isTrue);
    });

    test('blank string is null or blank', () {
      expect('   '.isNullOrBlank, isTrue);
    });

    test('non-blank string is not null or blank', () {
      expect('hi'.isNullOrBlank, isFalse);
    });
  });

  group('NullableStringExtension.isNotNullOrBlank', () {
    test('non-blank string is not null or blank', () {
      expect('hi'.isNotNullOrBlank, isTrue);
    });

    test('whitespace-only is not isNotNullOrBlank', () {
      expect('  '.isNotNullOrBlank, isFalse);
    });
  });

  group('NullableStringExtension.orDefault', () {
    test('null returns defaultValue', () {
      const String? s = null;
      expect(s.orDefault('fallback'), 'fallback');
    });

    test('empty string returns defaultValue', () {
      expect(''.orDefault('fallback'), 'fallback');
    });

    test('non-empty string returns itself', () {
      expect('hello'.orDefault('fallback'), 'hello');
    });
  });
}
