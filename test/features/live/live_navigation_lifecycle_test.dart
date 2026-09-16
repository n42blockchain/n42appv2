import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:n42_wallet/features/live/presentation/pages/live_app.dart';
import 'package:n42_wallet/features/live/presentation/pages/go_live_page.dart';
import 'package:n42_wallet/features/live/presentation/pages/live_home_page.dart';

void main() {
  testWidgets(
    'reopening Live starts at the requested entry, not the previous route',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      Future<void> open(String location) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(home: LiveApp(initialLocation: location)),
          ),
        );
        await tester.pumpAndSettle();
      }

      await open('/live/go');
      expect(find.byType(GoLivePage), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await open('/live');
      expect(find.byType(LiveHomePage), findsOneWidget);
      expect(find.byType(GoLivePage), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await open('/live/go');
      expect(find.byType(GoLivePage), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
