import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/sticker_pack_entity.dart';

void main() {
  group('Sticker', () {
    test('should create sticker with required fields', () {
      const sticker = Sticker(id: 'test_id', url: 'mxc://test/url');

      expect(sticker.id, 'test_id');
      expect(sticker.url, 'mxc://test/url');
      expect(sticker.httpUrl, null);
      expect(sticker.name, null);
      expect(sticker.emoji, null);
    });

    test('should create sticker with all fields', () {
      const sticker = Sticker(
        id: 'test_id',
        url: 'mxc://test/url',
        httpUrl: 'https://test.com/image.png',
        name: 'Test Sticker',
        emoji: '😊',
        width: 256,
        height: 256,
        mimeType: 'image/png',
        size: 10240,
        usageCount: 5,
      );

      expect(sticker.id, 'test_id');
      expect(sticker.url, 'mxc://test/url');
      expect(sticker.httpUrl, 'https://test.com/image.png');
      expect(sticker.name, 'Test Sticker');
      expect(sticker.emoji, '😊');
      expect(sticker.width, 256);
      expect(sticker.height, 256);
      expect(sticker.mimeType, 'image/png');
      expect(sticker.size, 10240);
      expect(sticker.usageCount, 5);
    });

    test('should detect emoji sticker correctly', () {
      const emojiSticker = Sticker(id: 'smile', url: 'emoji:😊', emoji: '😊');
      const imageSticker = Sticker(id: 'cat', url: 'mxc://test/cat.png');

      expect(emojiSticker.url.startsWith('emoji:'), true);
      expect(imageSticker.url.startsWith('emoji:'), false);
    });

    test('should support equality', () {
      const sticker1 = Sticker(id: 'test', url: 'mxc://test');
      const sticker2 = Sticker(id: 'test', url: 'mxc://test');
      const sticker3 = Sticker(id: 'other', url: 'mxc://other');

      expect(sticker1, equals(sticker2));
      expect(sticker1, isNot(equals(sticker3)));
    });
  });

  group('StickerPack', () {
    test('should create sticker pack with required fields', () {
      const pack = StickerPack(
        id: 'pack_1',
        name: 'Test Pack',
      );

      expect(pack.id, 'pack_1');
      expect(pack.name, 'Test Pack');
      expect(pack.stickers, isEmpty);
      expect(pack.source, StickerPackSource.custom); // default source is custom
      expect(pack.isInstalled, false);
      expect(pack.isOfficial, false);
    });

    test('should create sticker pack with stickers', () {
      const stickers = [
        Sticker(id: 's1', url: 'emoji:😊', emoji: '😊'),
        Sticker(id: 's2', url: 'emoji:😂', emoji: '😂'),
        Sticker(id: 's3', url: 'emoji:❤️', emoji: '❤️'),
      ];

      const pack = StickerPack(
        id: 'emoji_pack',
        name: 'Emoji Pack',
        stickers: stickers,
        source: StickerPackSource.builtin,
        isInstalled: true,
        isOfficial: true,
      );

      expect(pack.stickers.length, 3);
      expect(pack.stickerCount, 3);
      expect(pack.source, StickerPackSource.builtin);
      expect(pack.isInstalled, true);
      expect(pack.isOfficial, true);
    });

    test('should provide preview stickers (max 4)', () {
      const stickers = [
        Sticker(id: 's1', url: 'emoji:😊', emoji: '😊'),
        Sticker(id: 's2', url: 'emoji:😂', emoji: '😂'),
        Sticker(id: 's3', url: 'emoji:❤️', emoji: '❤️'),
        Sticker(id: 's4', url: 'emoji:👍', emoji: '👍'),
        Sticker(id: 's5', url: 'emoji:🔥', emoji: '🔥'),
        Sticker(id: 's6', url: 'emoji:🎉', emoji: '🎉'),
      ];

      const pack = StickerPack(
        id: 'emoji_pack',
        name: 'Emoji Pack',
        stickers: stickers,
      );

      expect(pack.previewStickers.length, 4);
      expect(pack.previewStickers[0].id, 's1');
      expect(pack.previewStickers[3].id, 's4');
    });

    test('should support copyWith', () {
      const pack = StickerPack(
        id: 'pack_1',
        name: 'Original Name',
        isInstalled: false,
      );

      final updatedPack = pack.copyWith(
        name: 'Updated Name',
        isInstalled: true,
      );

      expect(updatedPack.id, 'pack_1');
      expect(updatedPack.name, 'Updated Name');
      expect(updatedPack.isInstalled, true);
      expect(pack.name, 'Original Name'); // Original unchanged
    });

    test('should support equality', () {
      const pack1 = StickerPack(id: 'test', name: 'Test');
      const pack2 = StickerPack(id: 'test', name: 'Test');
      const pack3 = StickerPack(id: 'other', name: 'Other');

      expect(pack1, equals(pack2));
      expect(pack1, isNot(equals(pack3)));
    });
  });

  group('StickerPackSource', () {
    test('should have all source types', () {
      expect(StickerPackSource.values, contains(StickerPackSource.matrix));
      expect(StickerPackSource.values, contains(StickerPackSource.custom));
      expect(StickerPackSource.values, contains(StickerPackSource.store));
      expect(StickerPackSource.values, contains(StickerPackSource.builtin));
    });
  });

  group('RecentSticker', () {
    test('should create recent sticker with usage tracking', () {
      const sticker = Sticker(id: 'smile', url: 'emoji:😊', emoji: '😊');
      final lastUsed = DateTime(2024, 1, 15, 10, 30);

      final recent = RecentSticker(
        sticker: sticker,
        packId: 'emoji_pack',
        lastUsedAt: lastUsed,
        usageCount: 10,
      );

      expect(recent.sticker.id, 'smile');
      expect(recent.packId, 'emoji_pack');
      expect(recent.lastUsedAt, lastUsed);
      expect(recent.usageCount, 10);
    });

    test('should support equality', () {
      const sticker = Sticker(id: 'smile', url: 'emoji:😊');
      final now = DateTime.now();

      final recent1 = RecentSticker(
        sticker: sticker,
        packId: 'pack1',
        lastUsedAt: now,
        usageCount: 1,
      );

      final recent2 = RecentSticker(
        sticker: sticker,
        packId: 'pack1',
        lastUsedAt: now,
        usageCount: 1,
      );

      expect(recent1, equals(recent2));
    });
  });

  group('StickerCategory', () {
    test('should create category with all fields', () {
      const category = StickerCategory(
        id: 'animals',
        name: 'Animals',
        icon: '🐾',
        packCount: 10,
      );

      expect(category.id, 'animals');
      expect(category.name, 'Animals');
      expect(category.icon, '🐾');
      expect(category.packCount, 10);
    });

    test('should support equality', () {
      const cat1 = StickerCategory(id: 'test', name: 'Test', packCount: 5);
      const cat2 = StickerCategory(id: 'test', name: 'Test', packCount: 5);
      const cat3 = StickerCategory(id: 'other', name: 'Other', packCount: 3);

      expect(cat1, equals(cat2));
      expect(cat1, isNot(equals(cat3)));
    });
  });
}
