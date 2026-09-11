import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/security/phishing_warning_dialog.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

import 'wallet_audit_screenshot_test.dart' show loadFont;

void main() {
  setUpAll(loadFont);
  for (final dark in [false, true]) {
    for (final scale in [1.0, 1.6]) {
      testWidgets(
        'phishing warning ${dark ? 'dark' : 'light'} text scale $scale',
        (tester) async {
          tester.view.physicalSize = const Size(640, 1280);
          tester.view.devicePixelRatio = 2;
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.view.reset);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final key = GlobalKey();
          final base = dark
              ? ThemeAdapter.buildDark(ThemeAdapter.defaultAccent)
              : ThemeAdapter.buildLight(ThemeAdapter.defaultAccent);
          await tester.pumpWidget(
            ScreenUtilInit(
              designSize: const Size(750, 1334),
              minTextAdapt: true,
              builder: (_, _) => RepaintBoundary(
                key: key,
                child: MaterialApp(
                  debugShowCheckedModeBanner: false,
                  locale: const Locale('en'),
                  supportedLocales: S.delegate.supportedLocales,
                  localizationsDelegates: const [
                    S.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  theme: base.copyWith(
                    textTheme: base.textTheme.apply(
                      fontFamily: 'WalletAuditFont',
                    ),
                  ),
                  home: Scaffold(
                    body: Builder(
                      builder: (context) => Center(
                        child: TextButton(
                          onPressed: () => showPhishingWarningDialog(
                            context,
                            'https://phishing.example.test/claim/verify-wallet',
                          ),
                          child: const Text('Open warning'),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.text('Open warning'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final boundary =
              key.currentContext!.findRenderObject() as RenderRepaintBoundary;
          await tester.runAsync(() async {
            final shot = await boundary.toImage(pixelRatio: 2);
            final bytes = await shot.toByteData(format: ui.ImageByteFormat.png);
            final output = Directory('test/screenshots/out/security-audit')
              ..createSync(recursive: true);
            File(
              '${output.path}/phishing-${scale == 1 ? 'normal' : 'large'}-${dark ? 'dark' : 'light'}.png',
            ).writeAsBytesSync(bytes!.buffer.asUint8List());
            shot.dispose();
          });
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
        },
      );
    }
  }
}
