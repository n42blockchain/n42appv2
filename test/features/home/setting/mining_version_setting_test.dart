import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/enums/mining_engine_kind.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/features/home/setting/setting_home_page.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../helpers/widget_test_helpers.dart';

class _MiningSettingsStore extends SPUtil {
  MiningEngineKind stored = MiningEngineKind.v2;
  @override
  Future<MiningEngineKind> getMiningEngine() async => stored;
  @override
  Future<void> setMiningEngine(MiningEngineKind kind) async => stored = kind;
  @override
  Future<String?> getSysLang() async => null;
}

void main() {
  test('V3 availability uses the supported platform, not build mode', () {
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    for (final platform in TargetPlatform.values) {
      debugDefaultTargetPlatformOverride = platform;
      expect(
        miningV3Available,
        platform == TargetPlatform.android || platform == TargetPlatform.iOS,
      );
    }
  });

  for (final locale in [const Locale('en'), const Locale('zh', 'TW')]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
        'Android settings selects all versions at 320/$scale/$locale',
        (tester) async {
          tester.view.physicalSize = const Size(320, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final storage = _MiningSettingsStore();
          await tester.pumpWidget(
            wrapForTest(
              const SettingHomePage(),
              overrides: [spUtilProvider.overrideWithValue(storage)],
              locale: locale,
              adaptiveViewport: true,
              textScaler: TextScaler.linear(scale),
            ),
          );
          await tester.pumpAndSettle();
          for (final kind in [
            MiningEngineKind.v1,
            MiningEngineKind.v3,
            MiningEngineKind.v2,
          ]) {
            await tester.ensureVisible(find.text(kind.name.toUpperCase()));
            await tester.tap(find.text(kind.name.toUpperCase()));
            await tester.pumpAndSettle();
            final control = tester.widget<SegmentedButton<MiningEngineKind>>(
              find.byType(SegmentedButton<MiningEngineKind>),
            );
            expect(control.selected, {kind});
            expect(storage.stored, kind);
            if (kind == MiningEngineKind.v3) {
              expect(
                find.text(S.current.g_setting_mining_v3_label),
                findsOneWidget,
              );
            }
            expect(tester.takeException(), isNull);
          }
        },
        variant: TargetPlatformVariant.only(TargetPlatform.android),
      );
    }
  }

  testWidgets('stored V3 survives reopening settings', (tester) async {
    final storage = _MiningSettingsStore()..stored = MiningEngineKind.v3;
    await tester.pumpWidget(
      wrapForTest(
        const SettingHomePage(),
        overrides: [spUtilProvider.overrideWithValue(storage)],
      ),
    );
    await tester.pumpAndSettle();
    final control = tester.widget<SegmentedButton<MiningEngineKind>>(
      find.byType(SegmentedButton<MiningEngineKind>),
    );
    expect(control.selected, {MiningEngineKind.v3});
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('iOS offers V3 and restores its saved selection', (tester) async {
    final storage = _MiningSettingsStore()..stored = MiningEngineKind.v3;
    await tester.pumpWidget(
      wrapForTest(
        const SettingHomePage(),
        overrides: [spUtilProvider.overrideWithValue(storage)],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('V3'), findsOneWidget);
    expect(
      tester
          .widget<SegmentedButton<MiningEngineKind>>(
            find.byType(SegmentedButton<MiningEngineKind>),
          )
          .selected,
      {MiningEngineKind.v3},
    );
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('unsupported platform falls back from saved V3 to V2', (
    tester,
  ) async {
    final storage = _MiningSettingsStore()..stored = MiningEngineKind.v3;
    await tester.pumpWidget(
      wrapForTest(
        const SettingHomePage(),
        overrides: [spUtilProvider.overrideWithValue(storage)],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('V3'), findsNothing);
    final control = tester.widget<SegmentedButton<MiningEngineKind>>(
      find.byType(SegmentedButton<MiningEngineKind>),
    );
    expect(control.selected, {MiningEngineKind.v2});
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));
}
