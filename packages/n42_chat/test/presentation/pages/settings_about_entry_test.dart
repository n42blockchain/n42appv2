import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/presentation/pages/settings/about_page.dart';
import 'package:n42_chat/src/presentation/pages/settings/settings_page.dart';

void main() {
  testWidgets('About has a working default route without fabricated version', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: SettingsPage(),
      ),
    );
    await tester.pumpAndSettle();
    final about = find.text('About');
    await tester.scrollUntilVisible(
      about,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(about);
    await tester.pumpAndSettle();
    await tester.tap(about);
    await tester.pumpAndSettle();
    expect(find.byType(AboutPage), findsOneWidget);
    expect(find.text('Version 1.0.0'), findsNothing);
    expect(find.text('N42 Chat'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
