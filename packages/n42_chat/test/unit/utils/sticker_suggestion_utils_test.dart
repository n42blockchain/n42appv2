import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/utils/sticker_suggestion_utils.dart';
import 'package:n42_chat/src/domain/entities/sticker_pack_entity.dart';

void main() {
  const pack = StickerPack(
    id: 'p1',
    name: 'Faces',
    stickers: [
      Sticker(id: 'fire', url: 'asset:fire.svg', name: 'Fire', emoji: '🔥'),
      Sticker(id: 'firework', url: 'asset:fw.svg', name: 'Firework', emoji: '🎆'),
      Sticker(id: 'joy', url: 'asset:joy.svg', name: 'Joy', emoji: '😂'),
      Sticker(
          id: 'heart',
          url: 'asset:heart.svg',
          name: 'Heart',
          emoji: '❤️',
          usageCount: 5),
      Sticker(
          id: 'heart2',
          url: 'asset:heart2.svg',
          name: 'Heart eyes',
          emoji: '😍'),
    ],
  );

  group('rank', () {
    test('returns empty for blank query', () {
      expect(StickerSuggestionUtils.rank([pack], ''), isEmpty);
      expect(StickerSuggestionUtils.rank([pack], '   '), isEmpty);
    });

    test('matches sticker name (case-insensitive, prefix wins over contains)',
        () {
      final hits = StickerSuggestionUtils.rank([pack], 'fire');
      expect(hits.map((h) => h.sticker.id), ['fire', 'firework']);
      expect(hits.first.packId, 'p1');
    });

    test('exact name match ranks before prefix match', () {
      final hits = StickerSuggestionUtils.rank([pack], 'heart');
      // "Heart" (exact) before "Heart eyes" (prefix)
      expect(hits.map((h) => h.sticker.id), ['heart', 'heart2']);
    });

    test('matches by emoji exactly', () {
      final hits = StickerSuggestionUtils.rank([pack], '🔥');
      expect(hits, hasLength(1));
      expect(hits.single.sticker.id, 'fire');
    });

    test('respects limit', () {
      final hits = StickerSuggestionUtils.rank([pack], 'fire', limit: 1);
      expect(hits, hasLength(1));
      expect(hits.single.sticker.id, 'fire');
    });

    test('dedupes by sticker id across packs', () {
      final hits = StickerSuggestionUtils.rank([pack, pack], 'joy');
      expect(hits, hasLength(1));
    });
  });

  group('extractQuery', () {
    test('returns null for empty text', () {
      expect(StickerSuggestionUtils.extractQuery('', 0), isNull);
    });

    test('returns the last word before cursor', () {
      expect(StickerSuggestionUtils.extractQuery('hello fire', 10), 'fire');
    });

    test('uses cursor position not end of text', () {
      // cursor after "fire", before " party"
      expect(StickerSuggestionUtils.extractQuery('fire party', 4), 'fire');
    });

    test('does not trigger on slash commands', () {
      expect(StickerSuggestionUtils.extractQuery('/help', 5), isNull);
    });

    test('does not trigger on @ mention or # topic', () {
      expect(StickerSuggestionUtils.extractQuery('hi @bob', 7), isNull);
      expect(StickerSuggestionUtils.extractQuery('see #news', 9), isNull);
    });

    test('does not trigger on markdown tokens', () {
      expect(StickerSuggestionUtils.extractQuery('**bold', 6), isNull);
    });

    test('requires >=2 chars for ascii words', () {
      expect(StickerSuggestionUtils.extractQuery('a', 1), isNull);
      expect(StickerSuggestionUtils.extractQuery('ab', 2), 'ab');
    });

    test('allows single non-ascii char (emoji/cjk)', () {
      expect(StickerSuggestionUtils.extractQuery('🔥', 2), '🔥');
      expect(StickerSuggestionUtils.extractQuery('火', 1), '火');
    });

    test('does not trigger for over-long words', () {
      final long = 'a' * 40;
      expect(StickerSuggestionUtils.extractQuery(long, long.length), isNull);
    });
  });
}
