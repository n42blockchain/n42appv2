import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/core/services/gif_service.dart';
import 'package:n42_chat/src/core/services/giphy_service.dart';
import 'package:n42_chat/src/domain/entities/sticker_pack_entity.dart';
import 'package:n42_chat/src/domain/repositories/sticker_repository.dart';
import 'package:n42_chat/src/presentation/widgets/chat/expression_panel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Gifs implements GifService {
  int loads = 0;
  @override
  bool get isAvailable => true;
  @override
  Future<GiphySearchResult> getTrendingGifs({
    int offset = 0,
    String? cursor,
    int? limit,
    String rating = 'g',
  }) async {
    loads++;
    return const GiphySearchResult(gifs: [], totalCount: 0, offset: 0);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Stickers implements IStickerRepository {
  int loads = 0;
  final used = <String>[];
  @override
  Future<List<StickerPack>> getInstalledPacks() async {
    loads++;
    return [
      const StickerPack(
        id: 'pack',
        name: 'Fixture',
        isInstalled: true,
        stickers: [Sticker(id: 'puzzle', url: 'emoji:🧩', emoji: '🧩')],
      ),
    ];
  }

  @override
  Future<List<RecentSticker>> getRecentStickers({int limit = 20}) async => [];
  @override
  Future<void> recordStickerUsage(String packId, String stickerId) async =>
      used.add('$packId/$stickerId');
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _Gifs gifs;
  late _Stickers stickers;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    gifs = _Gifs();
    stickers = _Stickers();
    GetIt.instance.registerSingleton<GifService>(gifs);
    GetIt.instance.registerSingleton<IStickerRepository>(stickers);
  });
  tearDown(() => GetIt.instance.reset());

  Future<void> mount(
    WidgetTester tester, {
    String locale = 'en',
    double scale = 1,
    void Function(Sticker, String)? onSticker,
  }) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(320, 800),
            padding: const EdgeInsets.only(bottom: 34),
            textScaler: TextScaler.linear(scale),
          ),
          child: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: ExpressionPanel(
                onEmojiSelected: (_) {},
                onStickerSelected: onSticker ?? (_, _) {},
                onGifSelected: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('visible tabs load on demand and preserve GIF state on return', (
    tester,
  ) async {
    await mount(tester);
    expect(gifs.loads, 0);
    expect(stickers.loads, 0);
    expect(find.text('GIF'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('expression-tab-gif')));
    await tester.pumpAndSettle();
    expect(gifs.loads, 1);
    await tester.tap(find.byKey(const ValueKey('expression-tab-emoji')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('expression-tab-gif')));
    await tester.pumpAndSettle();
    expect(gifs.loads, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'sticker tab reaches installed pack and dispatches selected sticker',
    (tester) async {
      String? selected;
      await mount(
        tester,
        onSticker: (sticker, pack) => selected = '$pack/${sticker.id}',
      );
      await tester.tap(find.byKey(const ValueKey('expression-tab-sticker')));
      await tester.pumpAndSettle();
      expect(stickers.loads, 1);
      await tester.tap(find.text('🧩').last);
      await tester.pump();
      expect(selected, 'pack/puzzle');
      expect(stickers.used, ['pack/puzzle']);
      expect(tester.takeException(), isNull);
    },
  );

  for (final locale in ['en', 'zh', 'ar']) {
    testWidgets('$locale tabs respect bottom inset and enlarged text', (
      tester,
    ) async {
      await mount(tester, locale: locale, scale: 1.5);
      for (final tab in ExpressionTab.values) {
        final entry = find.byKey(ValueKey('expression-tab-${tab.name}'));
        expect(entry, findsOneWidget);
        expect(tester.getRect(entry).bottom, lessThanOrEqualTo(766));
        await tester.tap(entry);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  }
}
