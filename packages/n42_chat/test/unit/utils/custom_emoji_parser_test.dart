import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/utils/custom_emoji_parser.dart';
import 'package:n42_chat/src/domain/entities/custom_emoji.dart';

void main() {
  group('BuiltinCustomEmojis', () {
    test('lookup resolves primary shortcodes and aliases', () {
      expect(BuiltinCustomEmojis.lookup('fire')?.shortcode, 'fire');
      expect(BuiltinCustomEmojis.lookup('flame')?.shortcode, 'fire');
      expect(BuiltinCustomEmojis.lookup('lol')?.shortcode, 'joy');
      expect(BuiltinCustomEmojis.lookup('+1')?.shortcode, 'thumbsup');
      expect(BuiltinCustomEmojis.lookup('unknown_code'), isNull);
    });

    test('lookup is case-insensitive', () {
      expect(BuiltinCustomEmojis.lookup('FIRE')?.shortcode, 'fire');
    });

    test('search ranks prefix before contains and dedupes by primary', () {
      final hits = BuiltinCustomEmojis.search('fi');
      expect(hits.first.shortcode, 'fire');
      // no duplicate primary shortcodes
      final codes = hits.map((e) => e.shortcode).toList();
      expect(codes.toSet().length, codes.length);
    });

    test('all builtin emoji are animated with a fallback', () {
      for (final e in BuiltinCustomEmojis.all) {
        expect(e.animated, isTrue);
        expect(e.fallback, isNotEmpty);
        expect(e.asset, endsWith('.json'));
      }
    });
  });

  group('parse', () {
    test('plain text without colon returns single text token', () {
      final tokens = CustomEmojiParser.parse('hello world');
      expect(tokens, hasLength(1));
      expect(tokens.single.isEmoji, isFalse);
      expect(tokens.single.text, 'hello world');
    });

    test('replaces known shortcode with emoji token between text', () {
      final tokens = CustomEmojiParser.parse('hi :fire: there');
      expect(tokens, hasLength(3));
      expect(tokens[0].text, 'hi ');
      expect(tokens[1].isEmoji, isTrue);
      expect(tokens[1].emoji!.shortcode, 'fire');
      expect(tokens[2].text, ' there');
    });

    test('replaces known shortcode case-insensitively', () {
      final tokens = CustomEmojiParser.parse('hi :FIRE:');
      expect(tokens, hasLength(2));
      expect(tokens[1].isEmoji, isTrue);
      expect(tokens[1].emoji!.shortcode, 'fire');
    });

    test('unknown shortcode stays as plain text', () {
      final tokens = CustomEmojiParser.parse('see :nope: ok');
      expect(tokens, hasLength(1));
      expect(tokens.single.isEmoji, isFalse);
      expect(tokens.single.text, 'see :nope: ok');
    });

    test('does not misfire on url-like text', () {
      final tokens = CustomEmojiParser.parse('http://example.com');
      expect(tokens.every((t) => !t.isEmoji), isTrue);
    });

    test('handles adjacent emoji', () {
      final tokens = CustomEmojiParser.parse(':fire::joy:');
      final emojis = tokens.where((t) => t.isEmoji).toList();
      expect(emojis, hasLength(2));
    });
  });

  group('hasKnownEmoji', () {
    test('true only when a known shortcode is present', () {
      expect(CustomEmojiParser.hasKnownEmoji('a :fire: b'), isTrue);
      expect(CustomEmojiParser.hasKnownEmoji('a :nope: b'), isFalse);
      expect(CustomEmojiParser.hasKnownEmoji('no colons here'), isFalse);
    });
  });

  group('extractTrigger', () {
    test('returns partial after colon at cursor', () {
      expect(CustomEmojiParser.extractTrigger('hi :fi', 6), 'fi');
    });

    test('accepts uppercase partial after colon', () {
      expect(CustomEmojiParser.extractTrigger('hi :FI', 6), 'FI');
    });

    test('returns empty string right after lone colon', () {
      expect(CustomEmojiParser.extractTrigger('hi :', 4), '');
    });

    test('does not trigger when colon preceded by alnum', () {
      expect(CustomEmojiParser.extractTrigger('http:', 5), isNull);
      expect(CustomEmojiParser.extractTrigger('a:b', 3), isNull);
    });

    test('respects cursor position', () {
      expect(CustomEmojiParser.extractTrigger(':fire: done', 3), 'fi');
    });

    test('returns null when no colon before cursor', () {
      expect(CustomEmojiParser.extractTrigger('hello', 5), isNull);
    });
  });
}
