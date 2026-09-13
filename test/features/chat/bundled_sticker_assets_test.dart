import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/data/datasources/bundled_sticker_packs.dart';
import 'package:n42_chat/src/domain/entities/sticker_pack_entity.dart';
import 'package:n42_chat/src/domain/repositories/sticker_repository.dart';
import 'package:n42_chat/src/presentation/widgets/chat/sticker_picker.dart';
import 'package:n42_chat/src/presentation/widgets/chat/sticker_thumb.dart';

class _BundledStickerRepository implements IStickerRepository {
  _BundledStickerRepository(this.pack);

  final StickerPack pack;

  @override
  Future<List<StickerPack>> getInstalledPacks() async => [pack];

  @override
  Future<List<RecentSticker>> getRecentStickers({int limit = 20}) async => [];

  @override
  Future<void> recordStickerUsage(String packId, String stickerId) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'every built-in sticker loads at the path used for display and upload',
    () async {
      for (final pack in BundledStickerPacks.all) {
        for (final sticker in pack.stickers) {
          final path = BundledStickerPacks.assetPath(sticker.url);
          final hostData = await rootBundle.load(path);
          final packageData = await rootBundle.load('packages/n42_chat/$path');
          expect(hostData.lengthInBytes, greaterThan(0), reason: path);
          expect(
            hostData.buffer.asUint8List(
              hostData.offsetInBytes,
              hostData.lengthInBytes,
            ),
            orderedEquals(
              packageData.buffer.asUint8List(
                packageData.offsetInBytes,
                packageData.lengthInBytes,
              ),
            ),
            reason:
                '$path must stay in sync with the resolved n42_chat package',
          );
        }
      }
    },
  );

  for (final pack in BundledStickerPacks.all) {
    testWidgets('${pack.name} renders real stickers and allows selection', (
      tester,
    ) async {
      await GetIt.instance.reset();
      addTearDown(() => GetIt.instance.reset());
      GetIt.instance.registerSingleton<IStickerRepository>(
        _BundledStickerRepository(pack),
      );
      Sticker? selected;
      String? selectedPackId;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: TickerMode(
              enabled: false,
              child: Column(
                children: [
                  StickerPicker(
                    onStickerSelected: (sticker, packId) {
                      selected = sticker;
                      selectedPackId = packId;
                    },
                  ),
                  SizedBox(
                    height: 72,
                    width: 72,
                    child: StickerThumb(sticker: pack.stickers.first),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(ErrorWidget), findsNothing);
      final grid = find.byType(GridView).first;
      final tile = find
          .descendant(of: grid, matching: find.byType(GestureDetector))
          .first;
      await tester.tap(tile);
      await tester.pump();
      expect(selected, pack.stickers.first);
      expect(selectedPackId, pack.id);
      expect(tester.takeException(), isNull);
    });
  }
}
