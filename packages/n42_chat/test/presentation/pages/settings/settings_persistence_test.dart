import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/core/di/injection.dart';
import 'package:n42_chat/src/data/datasources/local/preferences_datasource.dart';
import 'package:n42_chat/src/domain/entities/user_profile_entity.dart';
import 'package:n42_chat/src/presentation/pages/settings/appearance_settings_page.dart';
import 'package:n42_chat/src/presentation/pages/settings/chat_settings_page.dart';
import 'package:n42_chat/src/presentation/pages/settings/notification_settings_page.dart';
import 'package:n42_chat/src/presentation/pages/settings/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PendingPrivacyPreferences extends PreferencesDataSource {
  final pending = Completer<PrivacySettings>();
  @override
  Future<PrivacySettings> getPrivacySettingsModel() => pending.future;
}

Widget app(
  Widget child, {
  Locale locale = const Locale('en'),
  double scale = 1,
}) => MaterialApp(
  localizationsDelegates: S.localizationsDelegates,
  supportedLocales: S.supportedLocales,
  locale: locale,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: child,
);

void main() {
  late PreferencesDataSource prefs;
  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    prefs = PreferencesDataSource();
    getIt.registerSingleton<PreferencesDataSource>(prefs);
  });
  tearDown(() async => getIt.reset());

  testWidgets(
    'direct notification route loads, persists and reopens saved state',
    (tester) async {
      await prefs.saveNotificationSettingsModel(
        const NotificationSettings(playSound: false),
      );
      await tester.pumpWidget(app(const SettingsPage()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();
      expect(tester.widget<Switch>(find.byType(Switch).at(2)).value, isFalse);
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();
      expect((await prefs.getNotificationSettingsModel()).enabled, isFalse);
      Navigator.of(tester.element(find.byType(NotificationSettingsPage))).pop();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();
      expect(tester.widget<Switch>(find.byType(Switch).first).value, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('notification save failure rolls back and permits retry', (
    tester,
  ) async {
    final pending = Completer<void>();
    var calls = 0;
    await tester.pumpWidget(
      app(
        NotificationSettingsPage(
          settings: const NotificationSettings(),
          onSave: (_) {
            calls++;
            return calls == 1 ? pending.future : Future<void>.value();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch).first);
    await tester.pump();
    expect(tester.widget<Switch>(find.byType(Switch).first).value, isFalse);
    await tester.tap(find.byType(Switch).first, warnIfMissed: false);
    await tester.pump();
    expect(calls, 1);
    pending.completeError(StateError('disk unavailable'));
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(find.byType(Switch).first).value, isTrue);
    expect(
      find.text(
        S
            .of(tester.element(find.byType(NotificationSettingsPage)))!
            .commonSaveFailed,
      ),
      findsOneWidget,
    );
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(tester.widget<Switch>(find.byType(Switch).first).value, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'notification privacy selection persists without a host callback',
    (tester) async {
      await tester.pumpWidget(
        app(const NotificationSettingsPage(settings: NotificationSettings())),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Notification Privacy'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hide sender and message'));
      await tester.pumpAndSettle();
      expect(
        (await prefs.getNotificationSettingsModel()).privacyMode,
        NotificationPrivacyMode.hidden,
      );
      expect(find.text('Hide sender and message'), findsOneWidget);
    },
  );

  testWidgets('appearance persists changes without a host callback', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(const AppearanceSettingsPage(settings: AppearanceSettings())),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark mode option'));
    await tester.pumpAndSettle();
    expect(
      (await prefs.getAppearanceSettingsModel()).themeMode,
      ThemeMode.dark,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('appearance failure restores confirmed theme selection', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        AppearanceSettingsPage(
          settings: const AppearanceSettings(themeMode: ThemeMode.light),
          onSave: (_) async => throw StateError('write failed'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark mode option'));
    await tester.pumpAndSettle();
    final light = tester.widget<ListTile>(
      find.widgetWithText(ListTile, 'Light mode'),
    );
    final dark = tester.widget<ListTile>(
      find.widgetWithText(ListTile, 'Dark mode option'),
    );
    expect(light.trailing, isA<Icon>());
    expect(dark.trailing, isNull);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'font slider previews during drag and saves its final value once',
    (tester) async {
      final saves = <AppearanceSettings>[];
      await tester.pumpWidget(
        app(
          AppearanceSettingsPage(
            settings: const AppearanceSettings(),
            onSave: saves.add,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.byType(Slider), 250);
      await tester.ensureVisible(find.byType(Slider));
      await tester.pumpAndSettle();
      final slider = find.byType(Slider);
      final gesture = await tester.startGesture(tester.getCenter(slider));
      await gesture.moveTo(tester.getTopRight(slider) + const Offset(-25, 20));
      await tester.pump();
      expect(saves, isEmpty);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(saves, hasLength(1));
      expect(saves.single.fontSize, FontSize.extraLarge);
      expect(tester.widget<Slider>(slider).value, 3);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('late save rejection after leaving the page is handled', (
    tester,
  ) async {
    final pending = Completer<void>();
    await tester.pumpWidget(
      app(
        NotificationSettingsPage(
          settings: const NotificationSettings(),
          onSave: (_) => pending.future,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch).first);
    await tester.pumpWidget(app(const SizedBox()));
    pending.completeError(StateError('late failure'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('font slider restores the saved value when final save fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        AppearanceSettingsPage(
          settings: const AppearanceSettings(fontSize: FontSize.small),
          onSave: (_) async => throw StateError('write failed'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byType(Slider), 250);
    await tester.ensureVisible(find.byType(Slider));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Slider), const Offset(300, 0));
    await tester.pumpAndSettle();
    expect(tester.widget<Slider>(find.byType(Slider)).value, 0);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile phone remains masked while privacy loads or fails', (
    tester,
  ) async {
    final pendingPrefs = PendingPrivacyPreferences();
    await getIt.unregister<PreferencesDataSource>();
    getIt.registerSingleton<PreferencesDataSource>(pendingPrefs);
    await tester.pumpWidget(
      app(
        const SettingsPage(
          profile: UserProfileEntity(
            userId: '@test:example.org',
            displayName: 'Test',
            phoneNumber: '+15551234567',
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('+15551234567'), findsNothing);
    pendingPrefs.pending.completeError(StateError('read failed'));
    await tester.pumpAndSettle();
    expect(find.text('+15551234567'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final page in <String, Widget>{
    'settings': const SettingsPage(),
    'chat': const ChatSettingsPage(),
    'notifications': const NotificationSettingsPage(
      settings: NotificationSettings(),
    ),
  }.entries) {
    testWidgets('${page.key} fits Arabic on narrow screens with large text', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 850));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        app(page.value, locale: const Locale('ar'), scale: 1.6),
      );
      await tester.pumpAndSettle();
      expect(
        Directionality.of(tester.element(find.byType(ListView).first)),
        TextDirection.rtl,
      );
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(ListView).first, const Offset(0, -450));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Privacy & Security'), findsNothing);
      expect(find.text('Notification Privacy'), findsNothing);
      expect(find.text('Smart Filter'), findsNothing);
    });
  }
}
