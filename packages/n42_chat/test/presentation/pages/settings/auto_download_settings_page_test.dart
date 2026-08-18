import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/data/datasources/local/preferences_datasource.dart';
import 'package:n42_chat/src/presentation/pages/settings/auto_download_settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _buildTestApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: S.localizationsDelegates,
    supportedLocales: S.supportedLocales,
    locale: const Locale('en'),
    home: child,
  );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    if (GetIt.I.isRegistered<PreferencesDataSource>()) {
      GetIt.I.unregister<PreferencesDataSource>();
    }
    GetIt.I.registerSingleton<PreferencesDataSource>(PreferencesDataSource());
  });

  tearDown(() {
    if (GetIt.I.isRegistered<PreferencesDataSource>()) {
      GetIt.I.unregister<PreferencesDataSource>();
    }
  });

  testWidgets(
    'AutoDownloadSettingsPage hides roaming toggles and shows fallback note',
    (tester) async {
      await tester.pumpWidget(_buildTestApp(const AutoDownloadSettingsPage()));
      await tester.pumpAndSettle();

      expect(find.text('Wi-Fi'), findsOneWidget);
      expect(find.text('Mobile Data'), findsOneWidget);
      expect(find.text('Roaming'), findsNothing);
      expect(find.text('Roaming uses Mobile Data rules'), findsOneWidget);
      expect(
        find.textContaining('Dedicated roaming detection is not available yet'),
        findsOneWidget,
      );
    },
  );
}
