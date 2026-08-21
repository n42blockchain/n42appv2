// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/presentation/pages/discover/discover_page.dart';
import 'package:n42_chat/src/presentation/pages/profile/services_page.dart';
import 'package:n42_wallet/features/live/domain/live_beauty_settings.dart';
import 'package:n42_wallet/features/live/presentation/widgets/live_beauty_sheet.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('captures Discover, Me services, and live beauty on device', (
    tester,
  ) async {
    await tester.pumpWidget(_chatApp(const DiscoverPage()));
    await tester.pumpAndSettle();
    expect(find.text('Listen'), findsOneWidget);
    expect(find.text('Watch'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await binding.takeScreenshot('chat-discover-top');

    await tester.drag(find.byType(ListView), const Offset(0, -560));
    await tester.pumpAndSettle();
    expect(find.text('Nearby'), findsOneWidget);
    expect(find.text('Channels'), findsOneWidget);
    await binding.takeScreenshot('chat-discover-nearby');

    await tester.pumpWidget(_chatApp(const ServicesPage()));
    await tester.pumpAndSettle();
    expect(find.text('Red Packet'), findsOneWidget);
    expect(find.text('Card Pack'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await binding.takeScreenshot('chat-me-services');

    var settings = const LiveBeautySettings();
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark(),
          home: Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: LiveBeautySheet(
                initial: settings,
                onChanged: (value) => settings = value,
                onCompareChanged: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('磨皮'), findsOneWidget);
    expect(find.text('美白'), findsOneWidget);
    expect(find.text('红润'), findsOneWidget);
    expect(find.text('按住查看原图'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await binding.takeScreenshot('chat-live-beauty');
  });
}

Widget _chatApp(Widget home) => MaterialApp(
  debugShowCheckedModeBanner: false,
  localizationsDelegates: S.localizationsDelegates,
  supportedLocales: S.supportedLocales,
  locale: const Locale('en'),
  theme: ThemeData.dark(),
  home: home,
);
