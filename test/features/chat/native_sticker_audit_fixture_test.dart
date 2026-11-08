import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/domain/repositories/sticker_repository.dart';
import 'package:n42_chat/src/presentation/widgets/chat/expression_panel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../integration_test/fixtures/audit_sticker_fixture.dart';

void main() {
  test(
    'native audit fixture implements the actual installed-pack stream',
    () async {
      final repository = AuditStickerFixture();
      final packs = await repository.watchInstalledPacks().first;
      expect(packs.single.id, 'audit');
      expect(packs.single.stickers.single.id, 'puzzle');
    },
  );

  testWidgets(
    'native audit expression fixture builds and selects its sticker',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await GetIt.instance.reset();
      addTearDown(() => GetIt.instance.reset());
      GetIt.instance.registerSingleton<IStickerRepository>(
        AuditStickerFixture(),
      );
      var selected = '';
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
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
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('expression-tab-sticker')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('🧩').last);
      expect(selected, 'audit/puzzle');
    },
  );
}
