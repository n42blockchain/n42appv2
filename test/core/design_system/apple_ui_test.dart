import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/text_field_widget.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

import '../../helpers/widget_test_helpers.dart';

void appleTestWidgets(String description, WidgetTesterCallback callback) {
  testWidgets(
    description,
    callback,
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final iconPath = Platform.environment['APPLE_UI_ICON_FONT'];
    if (iconPath != null) {
      final loader = FontLoader('MaterialIcons')
        ..addFont(
          Future.value(
            ByteData.sublistView(await File(iconPath).readAsBytes()),
          ),
        );
      await loader.load();
    }
    final fontPath = Platform.environment['APPLE_UI_SYSTEM_FONT'];
    if (fontPath != null) {
      final bytes = ByteData.sublistView(await File(fontPath).readAsBytes());
      for (final family in ['CupertinoSystemText', 'CupertinoSystemDisplay']) {
        final loader = FontLoader(family)..addFont(Future.value(bytes));
        await loader.load();
      }
    }
  });
  test('Apple scale uses point sizes and system fonts', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    expect(AppTypography.body.fontSize, 17);
    expect(AppTypography.body.fontFamily, 'CupertinoSystemText');
    expect(AppTypography.body.letterSpacing, -0.41);
    expect(AppTypography.displayXl.fontSize, 34);
    expect(AppTypography.displayXl.fontFamily, 'CupertinoSystemDisplay');
    expect(AppTypography.captionSm.fontSize, 11);
  });

  for (final dark in [false, true]) {
    appleTestWidgets('default and custom palettes remain selectable ($dark)', (
      tester,
    ) async {
      const custom = Color(0xFF8B5CF6);
      for (final accent in [ThemeAdapter.defaultAccent, custom]) {
        final theme = dark
            ? ThemeAdapter.buildDark(accent)
            : ThemeAdapter.buildLight(accent);
        late AppColorTokens colors;
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Builder(
              builder: (context) {
                colors = AppColorTokens.of(context);
                return const SizedBox();
              },
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          colors.brand,
          accent == custom
              ? custom
              : (dark
                    ? CupertinoColors.systemBlue.darkColor
                    : CupertinoColors.systemBlue.color),
        );
        expect(
          colors.bgBase,
          accent == custom
              ? (dark ? const Color(0xFF0E0F13) : const Color(0xFFF5F6F8))
              : (dark
                    ? CupertinoColors.systemGroupedBackground.darkColor
                    : CupertinoColors.systemGroupedBackground.color),
        );
      }
    });
  }

  for (final width in [320.0, 390.0, 768.0]) {
    for (final scale in [1.0, 1.6, 2.0, 3.0]) {
      for (final dark in [false, true]) {
        appleTestWidgets('controls fit $width at scale $scale dark=$dark', (
          tester,
        ) async {
          tester.view.physicalSize = Size(width, 1100);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final captureLabels =
              Platform.environment['APPLE_UI_CAPTURE_DIR'] != null;
          final boundary = GlobalKey();
          var submissions = 0;
          await tester.pumpWidget(
            wrapForTest(
              RepaintBoundary(
                key: boundary,
                child: Builder(
                  builder: (context) => ColoredBox(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: ListView(
                      padding: AppSpacing.pageHorizontal,
                      children: [
                        Text(
                          captureLabels ? 'Wallet' : 'Wallet 钱包',
                          style: AppTypography.displayXl,
                        ),
                        Text(
                          captureLabels
                              ? 'Apple system typography'
                              : 'Apple system typography · 保留自定义配色',
                          style: AppTypography.body,
                        ),
                        const SizedBox(height: 24),
                        AppButton(
                          label: captureLabels
                              ? 'Confirm transaction'
                              : 'Confirm transaction 确认交易',
                          icon: Icons.check,
                          onPressed: () => submissions++,
                        ),
                        const SizedBox(height: 12),
                        AppButton(
                          label: captureLabels ? 'Cancel' : 'Cancel 取消',
                          variant: AppButtonVariant.secondary,
                          onPressed: () {},
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: captureLabels ? 'Recipient' : 'Recipient 收款地址',
                          hint: captureLabels ? 'Address' : 'Address 地址',
                        ),
                        const SizedBox(height: 12),
                        Builder(
                          builder: (context) => buttonStyle6(
                            context,
                            () => submissions++,
                            captureLabels ? 'Submitting' : 'Submitting 提交中',
                            AppColorTokens.of(context).brand,
                            Colors.white,
                            true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              adaptiveViewport: true,
              themeMode: dark ? ThemeMode.dark : ThemeMode.light,
              textScaler: TextScaler.linear(scale),
            ),
          );
          await tester.pump();
          final button = find.byType(FilledButton).first;
          final size = tester.getSize(button);
          expect(size.width, greaterThanOrEqualTo(44));
          expect(size.height, greaterThanOrEqualTo(44));
          await tester.ensureVisible(button);
          await tester.pump();
          await tester.tap(button);
          expect(submissions, 1);
          final submitting = tester.widget<TextButton>(find.byType(TextButton));
          expect(submitting.onPressed, isNull);
          expect(tester.takeException(), isNull);
          // Optional review artifacts; assertions above are independent of images.
          final capture = Platform.environment['APPLE_UI_CAPTURE_DIR'];
          if (capture != null && width == 390 && (scale == 1 || scale == 2)) {
            await tester.runAsync(() async {
              final render =
                  boundary.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary;
              final image = await render.toImage();
              final data = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              await Directory(capture).create(recursive: true);
              await File('$capture/controls-$dark-$scale.png')
                  .writeAsBytes(data!.buffer.asUint8List());
              image.dispose();
            });
          }
        });
      }
    }
  }

  for (final width in [320.0, 768.0]) {
    for (final scale in [1.0, 3.0]) {
      appleTestWidgets('legacy inputs grow and accept text: $width / $scale', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 1100);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final address = TextEditingController();
        final password = TextEditingController();
        addTearDown(address.dispose);
        addTearDown(password.dispose);
        await tester.pumpWidget(
          wrapForTest(
            Builder(
              builder: (context) => ListView(
                children: [
                  textFieldStyle2(
                    context,
                    controller: address,
                    hintText: 'Address',
                  ),
                  const SizedBox(height: 16),
                  textFieldStyle3(
                    context,
                    controller: password,
                    obscure: true,
                    hintText: 'Password',
                  ),
                ],
              ),
            ),
            adaptiveViewport: true,
            textScaler: TextScaler.linear(scale),
          ),
        );
        await tester.pump();
        final first = find.byType(TextField).first;
        expect(tester.getSize(first).height, greaterThanOrEqualTo(44));
        expect(tester.getSize(first).height, greaterThanOrEqualTo(22 * scale));
        await tester.enterText(first, 'synthetic-recipient');
        expect(address.text, 'synthetic-recipient');
        expect(
          tester.widget<TextField>(find.byType(TextField).last).obscureText,
          isTrue,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }

  appleTestWidgets('long confirmation remains reachable with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      wrapForTest(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => AppDialog.show(
              context,
              title: 'Confirm transaction 确认交易',
              message:
                  'Review the address and amount before confirming. 核对地址和金额后确认。' *
                  5,
              confirmText: 'Confirm 确认',
              cancelText: 'Cancel 取消',
            ),
            child: const Text('Open'),
          ),
        ),
        textScaler: TextScaler.linear(2),
        adaptiveViewport: true,
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Confirm 确认'));
    await tester.tap(find.text('Confirm 确认'));
    await tester.pumpAndSettle();
    expect(find.byType(AppDialog), findsNothing);
  });
}
