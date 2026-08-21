import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/live/domain/live_beauty_settings.dart';
import 'package:n42_wallet/features/live/presentation/widgets/live_beauty_sheet.dart';
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

    expect(find.text('磨皮'), findsOneWidget);
    expect(find.text('美白'), findsOneWidget);
    expect(find.text('红润'), findsOneWidget);
    expect(find.text('自然'), findsOneWidget);
    expect(find.text('暖阳'), findsOneWidget);
    expect(find.text('清冷'), findsOneWidget);
    expect(find.text('鲜明'), findsOneWidget);
    expect(find.text('黑白'), findsOneWidget);
    expect(find.text('按住查看原图'), findsOneWidget);

    await tester.tap(find.text('恢复原图'));
    await tester.pump();
    expect(latest.isEnabled, isFalse);
  });
}
