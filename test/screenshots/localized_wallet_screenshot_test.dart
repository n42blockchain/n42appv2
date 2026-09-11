import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/import/import_cloud_backup.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_limit_order_form.dart';
import 'package:n42_wallet/generated/l10n.dart';
import '../helpers/test_current_user.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

void main() {
  setUpAll(() async {
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    for (final path in [
      '/System/Library/Fonts/Supplemental/Arial Unicode.ttf',
      '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
    ]) {
      final file = File(path);
      if (!file.existsSync()) continue;
      await (FontLoader('LocalizationAuditFont')..addFont(
            Future.value(ByteData.sublistView(file.readAsBytesSync())),
          ))
          .load();
      break;
    }
  });
  for (final locale in ['ar', 'de', 'ur', 'sw']) {
    for (final screen in ['limit-form', 'import-backup']) {
      testWidgets('$locale $screen at narrow width and larger text', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final boundaryKey = GlobalKey();
        await tester.pumpWidget(
          _captureApp(
            Builder(
              builder: (context) {
                final theme = Theme.of(context);
                final page = screen == 'limit-form'
                    ? Scaffold(
                        appBar: AppBar(
                          title: Text(S.of(context).g_ui_limit_orders),
                        ),
                        body: const DexLimitOrderForm(chain: 'ETH'),
                      )
                    : const ImportCloudBackup();
                return MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(1.3)),
                  child: Theme(
                    data: theme.copyWith(
                      textTheme: theme.textTheme.apply(
                        fontFamily: 'LocalizationAuditFont',
                      ),
                    ),
                    child: RepaintBoundary(key: boundaryKey, child: page),
                  ),
                );
              },
            ),
            locale: Locale(locale),
            overrides: [
              currentUserProvider.overrideWith((ref) => TestCurrentUser()),
            ],
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.runAsync(() async {
          final boundary =
              boundaryKey.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(
            'test/screenshots/out/localization/$locale-$screen.png',
          );
          file.parent.createSync(recursive: true);
          file.writeAsBytesSync(bytes!.buffer.asUint8List());
          image.dispose();
        });
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      });
    }
  }
}

Widget _captureApp(
  Widget child, {
  required Locale locale,
  required List<Override> overrides,
}) {
  final base = ThemeAdapter.buildLight(ThemeAdapter.defaultAccent);
  return ProviderScope(
    overrides: overrides,
    child: ScreenUtilInit(
      designSize: const Size(750, 1334),
      minTextAdapt: true,
      builder: (_, _) => MaterialApp(
        navigatorKey: AppGlobals.navigatorKey,
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: S.delegate.supportedLocales,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: base.copyWith(
          appBarTheme: base.appBarTheme.copyWith(
            titleTextStyle: base.appBarTheme.titleTextStyle?.copyWith(
              fontFamily: 'LocalizationAuditFont',
            ),
            toolbarTextStyle: base.appBarTheme.toolbarTextStyle?.copyWith(
              fontFamily: 'LocalizationAuditFont',
            ),
          ),
          primaryTextTheme: base.primaryTextTheme.apply(
            fontFamily: 'LocalizationAuditFont',
          ),
          inputDecorationTheme: base.inputDecorationTheme.copyWith(
            hintStyle: base.inputDecorationTheme.hintStyle?.copyWith(
              fontFamily: 'LocalizationAuditFont',
            ),
          ),
          textTheme: base.textTheme.apply(fontFamily: 'LocalizationAuditFont'),
        ),
        home: child,
      ),
    ),
  );
}
