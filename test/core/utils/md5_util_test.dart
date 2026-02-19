// Tests for Md5Util.
// Uses the crypto + convert packages — pure Dart, no platform dependencies.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42appv2/src/utils/md5_util.dart';

void main() {
  final util = Md5Util();

  // ─────────────────────────────────────────────────
  // generateMd5
  // ─────────────────────────────────────────────────

  group('Md5Util.generateMd5', () {
    test('empty string returns well-known MD5', () {
      // MD5('') = d41d8cd98f00b204e9800998ecf8427e
      expect(util.generateMd5(''), 'd41d8cd98f00b204e9800998ecf8427e');
    });

    test('"hello" returns well-known MD5', () {
      // MD5('hello') = 5d41402abc4b2a76b9719d911017c592
      expect(util.generateMd5('hello'), '5d41402abc4b2a76b9719d911017c592');
    });

    test('"test" returns well-known MD5', () {
      // MD5('test') = 098f6bcd4621d373cade4e832627b4f6
      expect(util.generateMd5('test'), '098f6bcd4621d373cade4e832627b4f6');
    });

    test('result is 32 hex characters', () {
      final hash = util.generateMd5('any string');
      expect(hash.length, 32);
    });

    test('result contains only lowercase hex characters', () {
      final hash = util.generateMd5('sample');
      expect(RegExp(r'^[0-9a-f]+$').hasMatch(hash), isTrue);
    });

    test('same input always produces same output (deterministic)', () {
      const input = 'hello world';
      expect(util.generateMd5(input), util.generateMd5(input));
    });

    test('different inputs produce different hashes', () {
      expect(util.generateMd5('abc'), isNot(equals(util.generateMd5('def'))));
    });

    test('case-sensitive: "Hello" != "hello"', () {
      expect(util.generateMd5('Hello'), isNot(equals(util.generateMd5('hello'))));
    });

    test('handles unicode input', () {
      final hash = util.generateMd5('中文');
      expect(hash.length, 32);
    });

    test('handles numeric string', () {
      final hash = util.generateMd5('12345678');
      expect(hash.length, 32);
    });
  });
}
