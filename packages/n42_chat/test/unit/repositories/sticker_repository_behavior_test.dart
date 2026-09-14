import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/bundled_sticker_packs.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_sticker_datasource.dart';
import 'package:n42_chat/src/data/repositories/sticker_repository_impl.dart';
import 'package:n42_chat/src/domain/entities/sticker_pack_entity.dart';

class _Source extends Mock implements MatrixStickerDataSource {}

void main() {
  const custom = StickerPack(
    id: 'custom-one',
    name: 'Travel',
    description: 'Holiday collection',
    source: StickerPackSource.custom,
    isInstalled: true,
    stickers: [
      Sticker(
        id: 'one',
        url: 'mxc://fixture/one',
        name: 'Airplane',
        emoji: '✈️',
      ),
      Sticker(id: 'two', url: 'mxc://fixture/two', name: 'Ship', emoji: '🚢'),
    ],
  );
  late _Source source;
  late StickerRepositoryImpl repository;
  late List<StickerPack> remote;
  final bytes = Uint8List.fromList([1, 2, 3]);

  setUpAll(() {
    registerFallbackValue(custom);
    registerFallbackValue(Uint8List(0));
  });
  setUp(() {
    source = _Source();
    remote = [custom];
    when(() => source.getInstalledPacks()).thenAnswer((_) async => remote);
    when(() => source.installPack(any(), any())).thenAnswer((invocation) async {
      final pack = invocation.positionalArguments[1] as StickerPack;
      remote = [...remote.where((p) => p.id != pack.id), pack];
      return true;
    });
    when(() => source.uninstallPack(any())).thenAnswer((invocation) async {
      remote = remote
          .where((p) => p.id != invocation.positionalArguments[0])
          .toList();
      return true;
    });
    when(
      () => source.uploadStickerImage(any(), any(), any()),
    ).thenAnswer((_) async => 'mxc://fixture/new');
    repository = StickerRepositoryImpl(source);
  });
  tearDown(() => repository.dispose());

  test(
    'bundled packs retain precedence over remote copies and reads use cache',
    () async {
      remote = [
        BundledStickerPacks.all.first.copyWith(name: 'Remote duplicate'),
        custom,
      ];
      final packs = await repository.getInstalledPacks();
      expect(packs.first.name, BundledStickerPacks.all.first.name);
      expect(packs.where((p) => p.id == packs.first.id), hasLength(1));
      expect(packs.last, custom);
      expect(await repository.getInstalledPacks(), packs);
      verify(() => source.getInstalledPacks()).called(1);
    },
  );

  test('failed fetch is not cached and a later read can retry', () async {
    when(() => source.getInstalledPacks()).thenThrow(StateError('offline'));
    await expectLater(repository.getInstalledPacks(), throwsStateError);
    when(() => source.getInstalledPacks()).thenAnswer((_) async => remote);
    expect((await repository.getInstalledPacks()).last, custom);
  });

  for (final entry in {
    'emotions': 'store_emotions',
    'food': 'store_food',
    'celebration': 'store_celebration',
  }.entries) {
    test('store category ${entry.key} excludes unrelated packs', () async {
      expect(
        (await repository.getStorePacks(category: entry.key)).map((p) => p.id),
        [entry.value],
      );
    });
  }
  test(
    'store pagination respects category ordering and exhausted offsets',
    () async {
      final all = await repository.getStorePacks(category: 'popular');
      expect(all.first.downloadCount, greaterThan(all.last.downloadCount));
      expect(
        await repository.getStorePacks(
          category: 'popular',
          offset: 1,
          limit: 2,
        ),
        all.sublist(1, 3),
      );
      expect(await repository.getStorePacks(offset: 99), isEmpty);
      expect(await repository.getStorePacks(category: 'unknown'), isEmpty);
      expect(await repository.getStorePacks(limit: 0), isEmpty);
    },
  );
  test('new category returns the same catalog without losing packs', () async {
    final all = await repository.getStorePacks();
    final recent = await repository.getStorePacks(category: 'new');
    expect(recent.map((p) => p.id).toSet(), all.map((p) => p.id).toSet());
  });
  for (final query in ['TRAVEL', 'holiday', 'airplane', '✈️']) {
    test('pack search includes custom metadata for $query', () async {
      expect(
        (await repository.searchPacks(query)).map((p) => p.id),
        contains(custom.id),
      );
    });
  }
  test('sticker search limits ranked results', () async {
    expect(await repository.searchStickers('ship', limit: 1), hasLength(1));
    expect(await repository.searchStickers('does-not-exist'), isEmpty);
  });
  test(
    'pack lookup resolves installed, catalog and missing identifiers',
    () async {
      expect(await repository.getPackById(custom.id), custom);
      expect((await repository.getPackById('store_food'))?.id, 'store_food');
      expect(await repository.getPackById('missing'), isNull);
    },
  );
  test('unknown pack is not installed', () async {
    expect(await repository.installPack('missing'), isFalse);
    verifyNever(() => source.installPack(any(), any()));
  });
  test('rejected install preserves the existing cache', () async {
    final before = await repository.getInstalledPacks();
    when(() => source.installPack(any(), any())).thenAnswer((_) async => false);
    expect(await repository.installPack('store_food'), isFalse);
    expect(await repository.getInstalledPacks(), before);
    verify(() => source.getInstalledPacks()).called(1);
  });
  test('successful install refreshes subscribers with the new pack', () async {
    final events = <List<StickerPack>>[];
    final subscription = repository.watchInstalledPacks().listen(events.add);
    addTearDown(subscription.cancel);
    await Future<void>.delayed(Duration.zero);
    expect(await repository.installPack('store_food'), isTrue);
    await Future<void>.delayed(Duration.zero);
    expect(events, hasLength(2));
    expect(events.first.any((p) => p.id == 'store_food'), isFalse);
    expect(events.last.any((p) => p.id == 'store_food'), isTrue);
  });
  test('uninstall removes custom data on the next read', () async {
    await repository.getInstalledPacks();
    expect(await repository.deleteCustomPack(custom.id), isTrue);
    expect(
      (await repository.getInstalledPacks()).any((p) => p.id == custom.id),
      isFalse,
    );
  });
  test('rejected uninstall keeps custom pack available', () async {
    await repository.getInstalledPacks();
    when(() => source.uninstallPack(any())).thenAnswer((_) async => false);
    expect(await repository.uninstallPack(custom.id), isFalse);
    expect(await repository.getPackById(custom.id), custom);
  });
  test('custom creation uploads avatar and persists its metadata', () async {
    final pack = await repository.createCustomPack(
      name: 'Mine',
      description: 'Private pack',
      avatarBytes: bytes,
    );
    expect(pack?.source, StickerPackSource.custom);
    expect(pack?.avatarUrl, 'mxc://fixture/new');
    expect(pack?.description, 'Private pack');
    expect(await repository.getPackById(pack!.id), pack);
    verify(
      () => source.uploadStickerImage(bytes, 'avatar.png', 'image/png'),
    ).called(1);
  });
  test('custom creation without an avatar does not upload an image', () async {
    expect(await repository.createCustomPack(name: 'Text'), isNotNull);
    verifyNever(() => source.uploadStickerImage(any(), any(), any()));
  });
  test('rejected custom creation does not enter installed cache', () async {
    when(() => source.installPack(any(), any())).thenAnswer((_) async => false);
    expect(await repository.createCustomPack(name: 'Rejected'), isNull);
    expect(
      (await repository.getInstalledPacks()).any((p) => p.name == 'Rejected'),
      isFalse,
    );
  });
  test('avatar upload exceptions prevent persistence', () async {
    when(
      () => source.uploadStickerImage(any(), any(), any()),
    ).thenThrow(StateError('offline'));
    expect(
      await repository.createCustomPack(name: 'Mine', avatarBytes: bytes),
      isNull,
    );
    verifyNever(() => source.installPack(any(), any()));
  });
  for (final entry in {
    'image.PNG': 'image/png',
    'photo.jpg': 'image/jpeg',
    'photo.jpeg': 'image/jpeg',
    'motion.gif': 'image/gif',
    'image.webp': 'image/webp',
    'unknown.bin': null,
  }.entries) {
    test(
      'adding ${entry.key} retains existing stickers and upload metadata',
      () async {
        expect(
          await repository.addStickerToPack(
            packId: custom.id,
            imageBytes: bytes,
            filename: entry.key,
            name: 'New',
            emoji: '⭐',
          ),
          isTrue,
        );
        final updated = await repository.getPackById(custom.id);
        expect(updated!.stickers.take(2), custom.stickers);
        expect(updated.stickers.last.size, bytes.length);
        expect(updated.stickers.last.mimeType, entry.value);
        expect(updated.stickers.last.emoji, '⭐');
        verify(
          () => source.uploadStickerImage(bytes, entry.key, entry.value),
        ).called(1);
      },
    );
  }
  test('null upload result cannot append an unusable sticker', () async {
    when(
      () => source.uploadStickerImage(any(), any(), any()),
    ).thenAnswer((_) async => null);
    expect(
      await repository.addStickerToPack(
        packId: custom.id,
        imageBytes: bytes,
        filename: 'a.png',
      ),
      isFalse,
    );
    expect(
      (await repository.getPackById(custom.id))!.stickers,
      custom.stickers,
    );
    verifyNever(() => source.installPack(any(), any()));
  });
  test('missing pack prevents image upload', () async {
    expect(
      await repository.addStickerToPack(
        packId: 'missing',
        imageBytes: bytes,
        filename: 'a.png',
      ),
      isFalse,
    );
    verifyNever(() => source.uploadStickerImage(any(), any(), any()));
  });
  test(
    'failed image persistence retains the previous sticker collection',
    () async {
      when(
        () => source.installPack(any(), any()),
      ).thenAnswer((_) async => false);
      expect(
        await repository.addStickerToPack(
          packId: custom.id,
          imageBytes: bytes,
          filename: 'a.png',
        ),
        isFalse,
      );
      expect(
        (await repository.getPackById(custom.id))!.stickers,
        custom.stickers,
      );
    },
  );
  test('image upload exception is surfaced as failure', () async {
    when(
      () => source.uploadStickerImage(any(), any(), any()),
    ).thenThrow(StateError('offline'));
    expect(
      await repository.addStickerToPack(
        packId: custom.id,
        imageBytes: bytes,
        filename: 'a.png',
      ),
      isFalse,
    );
  });
  test('removing one sticker preserves the rest of the pack', () async {
    expect(
      await repository.removeStickerFromPack(
        packId: custom.id,
        stickerId: 'one',
      ),
      isTrue,
    );
    expect(
      (await repository.getPackById(custom.id))!.stickers.map((s) => s.id),
      ['two'],
    );
  });
  test('rejected removal preserves both stickers', () async {
    when(() => source.installPack(any(), any())).thenAnswer((_) async => false);
    expect(
      await repository.removeStickerFromPack(
        packId: custom.id,
        stickerId: 'one',
      ),
      isFalse,
    );
    expect(
      (await repository.getPackById(custom.id))!.stickers,
      custom.stickers,
    );
  });
  test('rename preserves stickers and refreshes cached name', () async {
    expect(await repository.renamePack(custom.id, 'Trips'), isTrue);
    final updated = await repository.getPackById(custom.id);
    expect(updated!.name, 'Trips');
    expect(updated.stickers, custom.stickers);
  });
  test('rejected rename keeps the previous name', () async {
    when(() => source.installPack(any(), any())).thenAnswer((_) async => false);
    expect(await repository.renamePack(custom.id, 'Trips'), isFalse);
    expect((await repository.getPackById(custom.id))!.name, custom.name);
  });
  test('missing packs cannot be renamed or have stickers removed', () async {
    expect(await repository.renamePack('missing', 'Trips'), isFalse);
    expect(
      await repository.removeStickerFromPack(
        packId: 'missing',
        stickerId: 'one',
      ),
      isFalse,
    );
    verifyNever(() => source.installPack(any(), any()));
  });
  test(
    'persistence exceptions during rename and removal return failure',
    () async {
      when(
        () => source.installPack(any(), any()),
      ).thenThrow(StateError('offline'));
      expect(await repository.renamePack(custom.id, 'Trips'), isFalse);
      expect(
        await repository.removeStickerFromPack(
          packId: custom.id,
          stickerId: 'one',
        ),
        isFalse,
      );
    },
  );
}
