import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/live/domain/live_beauty_settings.dart';
import 'package:n42_wallet/features/live/presentation/widgets/live_beauty_sheet.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('beauty settings persist all stream-processing controls', () async {
    const expected = LiveBeautySettings(
      smooth: 0.7,
      brightness: 0.4,
      rosy: 0.3,
      filter: LiveFilterPreset.cool,
      filterStrength: 0.6,
    );
    final store = LiveBeautySettingsStore();

    await store.save(expected);
    final restored = await store.load();

    expect(restored.smooth, expected.smooth);
    expect(restored.brightness, expected.brightness);
    expect(restored.rosy, expected.rosy);
    expect(restored.filter, expected.filter);
    expect(restored.filterStrength, expected.filterStrength);
    expect(restored.isEnabled, isTrue);
  });

  testWidgets('beauty sheet exposes core WeChat-style controls and reset', (
    tester,
  ) async {
    var latest = const LiveBeautySettings();
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, _) => MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: Scaffold(
            body: LiveBeautySheet(
              initial: latest,
              onChanged: (value) => latest = value,
              onCompareChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    final l10n = S.of(tester.element(find.byType(LiveBeautySheet)));
    expect(find.text(l10n.g_ui3_live_smooth), findsOneWidget);
    expect(find.text(l10n.g_ui3_live_brighten), findsOneWidget);
    expect(find.text(l10n.g_ui3_live_rosy), findsOneWidget);
    expect(find.text(l10n.g_ui3_live_filter_natural), findsOneWidget);
    expect(find.text(l10n.g_ui3_live_filter_warm), findsOneWidget);
    expect(find.text(l10n.g_ui3_live_filter_cool), findsOneWidget);
    expect(find.text(l10n.g_ui3_live_filter_vivid), findsOneWidget);
    expect(find.text(l10n.g_ui3_live_filter_mono), findsOneWidget);
    expect(find.text(l10n.g_ui3_live_hold_compare), findsOneWidget);

    await tester.tap(find.text(l10n.g_ui3_live_beauty_reset));
    await tester.pump();
    expect(latest.isEnabled, isFalse);
  });
}
