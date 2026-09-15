// Tests for JsEscapeUtils.escapeJs — static pure-string utility.
// Verifies each special character substitution and passthrough behaviour.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/utils/js_escape_utils.dart';

void main() {
  group('JsEscapeUtils.escapeJs', () {
    // ──────────────────────────────
    // Passthrough cases
    // ──────────────────────────────

    test('empty string returns empty string', () {
      expect(JsEscapeUtils.escapeJs(''), '');
    });

    test('plain ASCII text is unchanged', () {
      expect(JsEscapeUtils.escapeJs('Hello, World!'), 'Hello, World!');
    });

    test('digits and punctuation passthrough', () {
      expect(JsEscapeUtils.escapeJs('abc123!@#\$%^&*()'), 'abc123!@#\$%^&*()');
    });

    test('unicode letters passthrough', () {
      expect(JsEscapeUtils.escapeJs('こんにちは'), 'こんにちは');
    });

    // ──────────────────────────────
    // Escape sequences
    // ──────────────────────────────

    test('backslash is doubled', () {
      expect(JsEscapeUtils.escapeJs(r'\'), r'\\');
    });

    test('multiple backslashes are each doubled', () {
      expect(JsEscapeUtils.escapeJs(r'\\'), r'\\\\');
    });

    test('double-quote is escaped', () {
      expect(JsEscapeUtils.escapeJs('"hello"'), r'\"hello\"');
    });

    test('single-quote is escaped', () {
      expect(JsEscapeUtils.escapeJs("it's"), r"it\'s");
    });

    test('newline is escaped to \\n', () {
      expect(JsEscapeUtils.escapeJs('line1\nline2'), r'line1\nline2');
    });

    test('carriage return is escaped to \\r', () {
      expect(JsEscapeUtils.escapeJs('line\r'), r'line\r');
    });

    test('tab is escaped to \\t', () {
      expect(JsEscapeUtils.escapeJs('\t'), r'\t');
    });

    test('null byte is escaped to \\0', () {
      expect(JsEscapeUtils.escapeJs('\u0000'), r'\0');
    });

    test('line separator U+2028 is escaped', () {
      expect(JsEscapeUtils.escapeJs('\u2028'), r'\u2028');
    });

    test('paragraph separator U+2029 is escaped', () {
      expect(JsEscapeUtils.escapeJs('\u2029'), r'\u2029');
    });

    // ──────────────────────────────
    // Mixed content
    // ──────────────────────────────

    test('mixed content escapes all special chars', () {
      final input = 'He said "hello\\nworld" and it\'s fine';
      final expected = 'He said \\"hello\\\\nworld\\" and it\\\'s fine';
      expect(JsEscapeUtils.escapeJs(input), expected);
    });

    test('XSS injection attempt is safely escaped', () {
      final input = '<script>alert("xss")</script>';
      // angle brackets pass through; quotes are escaped
      expect(JsEscapeUtils.escapeJs(input), r'<script>alert(\"xss\")</script>');
    });

    test('SQL injection pattern with quotes is escaped', () {
      final input = "' OR '1'='1";
      expect(JsEscapeUtils.escapeJs(input), r"\' OR \'1\'=\'1");
    });

    test('backslash before quote — both escaped independently', () {
      // Input: \"  →  Output: \\\"
      expect(JsEscapeUtils.escapeJs('\\"'), r'\\\"');
    });
  });
}
