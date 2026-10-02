import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/gas/gas_tracker_page.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _OfflineHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _OfflineHttpClient();
}

class _OfflineHttpClient implements HttpClient {
  @override
  void close({bool force = false}) {}

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      throw const SocketException('Network disabled in gas tracker tests');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late HttpOverrides? originalOverrides;

  setUp(() {
    originalOverrides = HttpOverrides.current;
    HttpOverrides.global = _OfflineHttpOverrides();
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    HttpOverrides.global = originalOverrides;
  });

  Future<void> openTracker(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 800),
        child: MaterialApp(
          theme: ThemeData.light(),
          localizationsDelegates: const [S.delegate],
          supportedLocales: S.delegate.supportedLocales,
          home: const GasTrackerPage(),
        ),
      ),
    );
    // Initial RPC/API calls fail immediately through the offline override.
    await tester.pumpAndSettle();
  }

  testWidgets('renders network cards in unavailable state offline', (
    tester,
  ) async {
    await openTracker(tester);

    expect(find.text('Ethereum'), findsOneWidget);
    expect(find.text('BNB Chain'), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('overview opens network alert editor and validates threshold', (
    tester,
  ) async {
    await openTracker(tester);

    await tester.tap(find.byTooltip('Gas Alert'));
    await tester.pumpAndSettle();
    expect(find.text('Ethereum'), findsNWidgets(2));
    expect(find.text('BNB Chain'), findsNWidgets(2));

    await tester.tap(find.text('Ethereum').last);
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);

    const saveLabel = 'Save';
    await tester.tap(find.text(saveLabel));
    await tester.pumpAndSettle();
    expect(find.text('Enter a whole number greater than 0.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '24.5');
    await tester.tap(find.text('Alert when above'));
    await tester.tap(find.text(saveLabel));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('gasAlertSettings'), contains('ETH'));
    expect(prefs.getString('gasAlertSettings'), contains('24.5'));
  });
}
