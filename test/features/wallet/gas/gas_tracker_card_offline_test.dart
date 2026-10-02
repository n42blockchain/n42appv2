import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/gas/gas_tracker_page.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _OfflineOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _OfflineClient();
}

class _OfflineClient implements HttpClient {
  @override
  void close({bool force = false}) {}

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      throw const SocketException('Network disabled in gas card tests');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late HttpOverrides? originalOverrides;

  setUp(() {
    originalOverrides = HttpOverrides.current;
    HttpOverrides.global = _OfflineOverrides();
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    HttpOverrides.global = originalOverrides;
  });

  Future<void> pumpTracker(WidgetTester tester) async {
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
    await tester.pumpAndSettle();
  }

  testWidgets('failed initial loads settle into unavailable cards', (
    tester,
  ) async {
    await pumpTracker(tester);

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Ethereum'), findsOneWidget);
    expect(find.text('BNB Chain'), findsOneWidget);
    expect(find.text('...'), findsNWidgets(2));
    expect(find.text('Loading '), findsNWidgets(2));
  });

  testWidgets('pull to refresh returns to the same safe unavailable state', (
    tester,
  ) async {
    await pumpTracker(tester);

    await tester.drag(find.byType(ListView), const Offset(0, 500));
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Ethereum'), findsOneWidget);
    expect(find.text('BNB Chain'), findsOneWidget);
    expect(find.text('...'), findsNWidgets(2));
    expect(find.text('Loading '), findsNWidgets(2));
  });
}
