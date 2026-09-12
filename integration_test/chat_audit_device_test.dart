import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';
import 'package:n42_chat/src/domain/entities/sticker_pack_entity.dart';
import 'package:n42_chat/src/domain/repositories/sticker_repository.dart';
import 'package:n42_chat/src/presentation/pages/ai/ai_assistant_page.dart';
import 'package:n42_chat/src/presentation/widgets/chat/expression_panel.dart';
import 'package:n42_chat/src/presentation/widgets/chat/wechat_message_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _StickerFixture implements IStickerRepository {
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
  Future<List<RecentSticker>> getRecentStickers({int limit = 20}) async => [];
  @override
  Future<void> recordStickerUsage(String packId, String stickerId) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  var converted = false;
  Future<void> capture(WidgetTester tester, String name) async {
    if (Platform.isAndroid && !converted) {
      await binding.convertFlutterSurfaceToImage();
      converted = true;
    }
    await tester.pumpAndSettle();
    await binding.takeScreenshot(
      '${Platform.isAndroid ? 'android' : 'ios'}-$name',
    );
  }

  testWidgets(
    'audit expressions, compact actions, RTL and unavailable AI on device',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await GetIt.instance.reset();
      GetIt.instance.registerSingleton<IStickerRepository>(_StickerFixture());
      var selected = '';
      await tester.pumpWidget(
        _app(
          Scaffold(
            appBar: AppBar(title: const Text('Chat · UI acceptance')),
            body: Align(
              alignment: Alignment.bottomCenter,
              child: ExpressionPanel(
                onEmojiSelected: (_) {},
                onGifSelected: (_) {},
                onStickerSelected: (sticker, packId) =>
                    selected = '$packId/${sticker.id}',
              ),
            ),
          ),
        ),
      );
      await capture(tester, 'expression-en');
      await tester.tap(find.byKey(const ValueKey('expression-tab-sticker')));
      await capture(tester, 'stickers-en');
      await tester.tap(find.text('🧩').last);
      expect(selected, 'audit/puzzle');
      await tester.tap(find.byKey(const ValueKey('expression-tab-gif')));
      await capture(tester, 'gif-unavailable-en');
      expect(find.text('Retry'), findsOneWidget);

      var invoked = 0;
      for (final locale in ['en', 'ar']) {
        await tester.pumpWidget(
          _app(_menu(() => invoked++), locale: locale, dark: locale == 'ar'),
        );
        await capture(tester, 'menu-compact-$locale');
        expect(
          find.byKey(const ValueKey('message-action-delete')),
          findsNothing,
        );
        final more = find.byKey(const ValueKey('message-action-more'));
        await tester.ensureVisible(more);
        await tester.tap(more);
        await capture(tester, 'menu-expanded-$locale');
        final deletion = find.byKey(const ValueKey('message-action-delete'));
        await tester.ensureVisible(deletion);
        await tester.tap(deletion);
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
      expect(invoked, 2);
      await tester.pumpWidget(
        _app(const AiAssistantPage(), locale: 'ar', dark: true),
      );
      await capture(tester, 'ai-unavailable-ar');
      expect(find.byType(TextField), findsNothing);
      expect(tester.takeException(), isNull);
      await GetIt.instance.reset();
    },
  );
}

Widget _app(Widget home, {String locale = 'en', bool dark = false}) =>
    MaterialApp(
      key: ValueKey('$locale-$dark-${home.runtimeType}'),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: S.localizationsDelegates,
      supportedLocales: S.supportedLocales,
      locale: Locale(locale),
      theme: dark ? ThemeData.dark() : ThemeData.light(),
      home: home,
    );

Widget _menu(VoidCallback onDelete) => WeChatMessageMenu(
  message: MessageEntity(
    id: 'audit',
    roomId: '!audit:local',
    senderId: '@audit:local',
    senderName: 'Audit',
    content: 'Local UI fixture',
    type: MessageType.text,
    timestamp: DateTime(2026),
    isFromMe: true,
  ),
  position: const Offset(40, 350),
  messageSize: const Size(200, 44),
  onDismiss: () {},
  onQuote: () {},
  onCopy: () {},
  onForward: () {},
  onFavorite: () {},
  onEdit: () {},
  onReplyInThread: () {},
  onMultiSelect: () {},
  onTranslate: () {},
  onSpeak: () {},
  onReadingMode: () {},
  onRecall: () {},
  onDelete: onDelete,
  onReaction: (_) {},
);
