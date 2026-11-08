import 'package:n42_chat/src/domain/entities/sticker_pack_entity.dart';
import 'package:n42_chat/src/domain/repositories/sticker_repository.dart';

class AuditStickerFixture implements IStickerRepository {
  @override
  Future<List<StickerPack>> getInstalledPacks() async => [
    const StickerPack(
      id: 'audit',
      name: 'Audit',
      isInstalled: true,
      stickers: [Sticker(id: 'puzzle', url: 'emoji:🧩', emoji: '🧩')],
    ),
  ];
  @override
  Stream<List<StickerPack>> watchInstalledPacks() =>
      Stream.fromFuture(getInstalledPacks());

  @override
  Future<List<RecentSticker>> getRecentStickers({int limit = 20}) async => [];
  @override
  Future<void> recordStickerUsage(String packId, String stickerId) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
