import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_sticker_datasource.dart';
import 'package:n42_chat/src/data/repositories/sticker_repository_impl.dart';
import 'package:n42_chat/src/domain/entities/sticker_pack_entity.dart';

class MockMatrixStickerDataSource extends Mock
    implements MatrixStickerDataSource {}

void main() {
  late MockMatrixStickerDataSource mockDataSource;
  late StickerRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockMatrixStickerDataSource();
    repository = StickerRepositoryImpl(mockDataSource);
  });

  test('getStorePacks filters sample store packs by category', () async {
    final packs = await repository.getStorePacks(category: 'animals');

    expect(packs, hasLength(1));
    expect(packs.single.id, 'store_cute_animals');
  });

  test('searchStickers returns empty for blank query', () async {
    expect(await repository.searchStickers('   '), isEmpty);
  });

  test('searchStickers matches bundled stickers by name', () async {
    when(() => mockDataSource.getInstalledPacks())
        .thenAnswer((_) async => const []);

    final hits = await repository.searchStickers('rocket');

    expect(hits, isNotEmpty);
    expect(hits.first.sticker.emoji, '🚀');
    expect(hits.first.packId, isNotEmpty);
  });

  test('searchStickers matches bundled stickers by emoji', () async {
    when(() => mockDataSource.getInstalledPacks())
        .thenAnswer((_) async => const []);

    final hits = await repository.searchStickers('🔥');

    expect(hits, isNotEmpty);
    expect(hits.every((h) => h.sticker.emoji == '🔥'), isTrue);
  });

  test('searchPacks deduplicates installed and store results by pack id', () async {
    const installedPack = StickerPack(
      id: 'store_cute_animals',
      name: 'Cute Animals',
      description: 'Installed copy',
      isInstalled: true,
      stickers: [
        Sticker(id: 'cat1', url: 'emoji:🐱', emoji: '🐱'),
      ],
    );

    when(() => mockDataSource.getInstalledPacks())
        .thenAnswer((_) async => const [installedPack]);

    final packs = await repository.searchPacks('cute');

    expect(packs, hasLength(1));
    expect(packs.single.id, 'store_cute_animals');
    expect(packs.single.isInstalled, isTrue);
  });
}
