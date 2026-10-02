import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/features/home/setting/setting_theme.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../helpers/widget_test_helpers.dart';

class _ThemeSettingsSpUtil extends SPUtil {
  int? storedThemeMode;
  int? storedAccentColor;

  @override
  Future<int?> getThemeMode() async => storedThemeMode;

  @override
  Future<void> setThemeMode(int value) async => storedThemeMode = value;

  @override
  Future<int?> getAccentColor() async => storedAccentColor;

  @override
  Future<void> setAccentColor(int value) async => storedAccentColor = value;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('selecting a theme mode updates the selection and persistence', (
    tester,
  ) async {
    final storage = _ThemeSettingsSpUtil();
    await tester.pumpWidget(
      wrapForTest(
        const SettingTheme(),
        overrides: [spUtilProvider.overrideWithValue(storage)],
      ),
    );
    await tester.pumpAndSettle();

    final darkMode = find.text(S.current.g_key_129);
    await tester.scrollUntilVisible(
      darkMode,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(darkMode);
    await tester.pumpAndSettle();

    expect(storage.storedThemeMode, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('choosing a style preset applies its accent and theme mode', (
    tester,
  ) async {
    final storage = _ThemeSettingsSpUtil();
    await tester.pumpWidget(
      wrapForTest(
        const SettingTheme(),
        overrides: [spUtilProvider.overrideWithValue(storage)],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('深空'));
    await tester.pumpAndSettle();

    expect(storage.storedAccentColor, const Color(0xFF5B6CFF).toARGB32());
    expect(storage.storedThemeMode, 2);
    expect(find.text('深空'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('custom accent can be reset to the default color', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final storage = _ThemeSettingsSpUtil();
    await tester.pumpWidget(
      wrapForTest(
        const SettingTheme(),
        overrides: [spUtilProvider.overrideWithValue(storage)],
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text(S.current.g_theme_accent_color),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    final tealAccent = find
        .byWidgetPredicate(
          (widget) => widget is InkWell && widget.customBorder is CircleBorder,
        )
        .at(1);
    await tester.scrollUntilVisible(
      tealAccent,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(tealAccent);
    await tester.pumpAndSettle();

    expect(storage.storedAccentColor, const Color(0xFF009688).toARGB32());
    expect(find.text(S.current.g_theme_accent_reset), findsOneWidget);

    await tester.tap(find.text(S.current.g_theme_accent_reset));
    await tester.pumpAndSettle();

    expect(storage.storedAccentColor, 0);
    expect(find.text(S.current.g_theme_accent_reset), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
