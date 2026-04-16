// Extended tests for sticker_pack_entity — covers methods NOT in existing tests:
//   Sticker (aspectRatio, isAnimated, copyWith),
//   StickerPack (stickerCount, isEmpty, isNotEmpty, previewStickers, copyWith),
//   RecentSticker (copyWith, props),
//   StickerCategory (props)

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/sticker_pack_entity.dart';

const _baseSticker = Sticker(id: 's1', url: 'mxc://a/b');

StickerPack _pack({List<Sticker> stickers = const []}) => StickerPack(
      id: 'p1',
      name: 'Test Pack',
      stickers: stickers,
    );

void main() {
  // ─────────────────────────────────────────────────
  // Sticker.aspectRatio
  // ─────────────────────────────────────────────────

  group('Sticker.aspectRatio', () {
    test('returns 1.0 when height is null', () {
      const s = Sticker(id: 's', url: 'mxc://a/b', width: 200);
      expect(s.aspectRatio, 1.0);
    });

    test('returns 1.0 when height is 0', () {
      const s = Sticker(id: 's', url: 'mxc://a/b', width: 200, height: 0);
      expect(s.aspectRatio, 1.0);
    });

    test('returns 1.0 when width is null', () {
      const s = Sticker(id: 's', url: 'mxc://a/b', height: 200);
      expect(s.aspectRatio, 1.0);
    });

    test('computes correctly for valid dimensions', () {
      const s = Sticker(id: 's', url: 'mxc://a/b', width: 300, height: 200);
      expect(s.aspectRatio, closeTo(1.5, 0.001));
    });
  });

  // ─────────────────────────────────────────────────
  // Sticker.isAnimated
  // ─────────────────────────────────────────────────

  group('Sticker.isAnimated', () {
    test('returns false when mimeType is null', () {
      expect(_baseSticker.isAnimated, isFalse);
    });

    test('returns true for image/gif', () {
      const s = Sticker(id: 's', url: 'mxc://a/b', mimeType: 'image/gif');
      expect(s.isAnimated, isTrue);
    });

    test('returns true for image/webp', () {
      const s = Sticker(id: 's', url: 'mxc://a/b', mimeType: 'image/webp');
      expect(s.isAnimated, isTrue);
    });

    test('returns false for image/png', () {
      const s = Sticker(id: 's', url: 'mxc://a/b', mimeType: 'image/png');
      expect(s.isAnimated, isFalse);
    });

    test('is case-insensitive', () {
      const s = Sticker(id: 's', url: 'mxc://a/b', mimeType: 'image/GIF');
      expect(s.isAnimated, isTrue);
    });
  });

  // ─────────────────────────────────────────────────
  // Sticker.copyWith
  // ─────────────────────────────────────────────────

  group('Sticker.copyWith', () {
    test('changes single field leaving others intact', () {
      const s = Sticker(
        id: 's1',
        url: 'mxc://a/b',
        name: 'cat',
        emoji: '🐱',
        usageCount: 3,
      );
      final updated = s.copyWith(name: 'dog');
      expect(updated.name, 'dog');
      expect(updated.id, 's1');
      expect(updated.emoji, '🐱');
      expect(updated.usageCount, 3);
    });

    test('changes usageCount', () {
      const s = Sticker(id: 's1', url: 'mxc://a/b');
      final updated = s.copyWith(usageCount: 10);
      expect(updated.usageCount, 10);
      expect(updated.url, 'mxc://a/b');
    });
  });

  // ─────────────────────────────────────────────────
  // StickerPack — stickerCount, isEmpty, isNotEmpty, previewStickers
  // ─────────────────────────────────────────────────

  group('StickerPack.stickerCount', () {
    test('returns 0 for empty pack', () {
      expect(_pack().stickerCount, 0);
    });

    test('returns count of stickers', () {
      final stickers = List.generate(5, (i) => Sticker(id: 's$i', url: 'mxc://a/$i'));
      expect(_pack(stickers: stickers).stickerCount, 5);
    });
  });

  group('StickerPack.isEmpty / isNotEmpty', () {
    test('isEmpty is true for empty pack', () {
      expect(_pack().isEmpty, isTrue);
      expect(_pack().isNotEmpty, isFalse);
    });

    test('isNotEmpty is true when stickers present', () {
      final p = _pack(stickers: [_baseSticker]);
      expect(p.isEmpty, isFalse);
      expect(p.isNotEmpty, isTrue);
    });
  });

  group('StickerPack.previewStickers', () {
    test('returns up to 4 stickers', () {
      final stickers = List.generate(6, (i) => Sticker(id: 's$i', url: 'mxc://a/$i'));
      final preview = _pack(stickers: stickers).previewStickers;
      expect(preview, hasLength(4));
      expect(preview.first.id, 's0');
    });

    test('returns all when fewer than 4 stickers', () {
      final stickers = List.generate(2, (i) => Sticker(id: 's$i', url: 'mxc://a/$i'));
      expect(_pack(stickers: stickers).previewStickers, hasLength(2));
    });

    test('returns empty list for empty pack', () {
      expect(_pack().previewStickers, isEmpty);
    });
  });

  // ─────────────────────────────────────────────────
  // StickerPack.copyWith
  // ─────────────────────────────────────────────────

  group('StickerPack.copyWith', () {
    test('changes isInstalled leaving others intact', () {
      final p = _pack();
      final updated = p.copyWith(isInstalled: true);
      expect(updated.isInstalled, isTrue);
      expect(updated.id, p.id);
      expect(updated.name, p.name);
    });

    test('changes stickers list', () {
      final p = _pack();
      final updated = p.copyWith(stickers: [_baseSticker]);
      expect(updated.stickers, hasLength(1));
    });
  });

  // ─────────────────────────────────────────────────
  // RecentSticker
  // ─────────────────────────────────────────────────

  group('RecentSticker.copyWith', () {
    test('changes usageCount', () {
      final rs = RecentSticker(
        sticker: _baseSticker,
        packId: 'p1',
        lastUsedAt: DateTime(2025, 1, 1),
        usageCount: 3,
      );
      final updated = rs.copyWith(usageCount: 7);
      expect(updated.usageCount, 7);
      expect(updated.packId, 'p1');
    });
  });

  group('RecentSticker.props equality', () {
    test('two identical instances are equal', () {
      final ts = DateTime(2025, 6, 1);
      final a = RecentSticker(sticker: _baseSticker, packId: 'p1', lastUsedAt: ts);
      final b = RecentSticker(sticker: _baseSticker, packId: 'p1', lastUsedAt: ts);
      expect(a, equals(b));
    });

    test('different packId → not equal', () {
      final ts = DateTime(2025, 6, 1);
      final a = RecentSticker(sticker: _baseSticker, packId: 'p1', lastUsedAt: ts);
      final b = RecentSticker(sticker: _baseSticker, packId: 'p2', lastUsedAt: ts);
      expect(a, isNot(equals(b)));
    });
  });

  // ─────────────────────────────────────────────────
  // StickerCategory
  // ─────────────────────────────────────────────────

  group('StickerCategory.props', () {
    test('two identical instances are equal', () {
      const a = StickerCategory(id: 'c1', name: 'Animals', packCount: 5);
      const b = StickerCategory(id: 'c1', name: 'Animals', packCount: 5);
      expect(a, equals(b));
    });

    test('different id → not equal', () {
      const a = StickerCategory(id: 'c1', name: 'Animals');
      const b = StickerCategory(id: 'c2', name: 'Animals');
      expect(a, isNot(equals(b)));
    });
  });
}
