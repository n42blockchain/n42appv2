import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/domain/entities/user_profile_entity.dart';
import 'package:n42_chat/src/presentation/pages/settings/privacy_settings_page.dart';
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
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('PrivacySettingsPage clarifies Tor support is HTTP proxy only', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildTestApp(const PrivacySettingsPage(settings: PrivacySettings())),
    );
    await tester.pumpAndSettle();

    final torTitle = find.text(
      'Use Tor / Privoxy HTTP Proxy',
      skipOffstage: false,
    );
    await tester.scrollUntilVisible(torTitle, 300);
    await tester.pumpAndSettle();

    expect(torTitle, findsOneWidget);
    expect(
      find.textContaining(
        'Native SOCKS5 Tor routing is not supported here.',
        skipOffstage: false,
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Use a custom HTTP or HTTPS proxy for Matrix traffic and link previews',
        skipOffstage: false,
      ),
      findsOneWidget,
    );
    expect(find.text('Link Previews', skipOffstage: false), findsOneWidget);
  });
}
