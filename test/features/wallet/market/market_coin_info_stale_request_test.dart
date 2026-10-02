import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/market/market_coin_info.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _OfflineHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _OfflineHttpClient();
}

class _OfflineHttpClient implements HttpClient {
  @override
  set badCertificateCallback(
    bool Function(X509Certificate certificate, String host, int port)? callback,
  ) {}

  @override
  void close({bool force = false}) {}

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      throw const SocketException('Network disabled in market tests');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late HttpOverrides? originalOverrides;

  setUp(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
    originalOverrides = HttpOverrides.current;
    HttpOverrides.global = _OfflineHttpOverrides();
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    HttpOverrides.global = originalOverrides;
  });

  testWidgets('a stale detail failure does not hide the current coin info', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final oldResponse = Completer<dynamic>();
    final currentResponse = Completer<dynamic>();
    final requests = <String>[];

    Future<dynamic> loadCoinInfo(String coinId) {
      requests.add(coinId);
      return switch (coinId) {
        'old-coin' => oldResponse.future,
        'current-coin' => currentResponse.future,
        _ => throw StateError('Unexpected coin id: $coinId'),
      };
    }

    Widget build(String coinId, String name) => ProviderScope(
      child: ScreenUtilInit(
        designSize: const Size(750, 1334),
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [S.delegate],
          supportedLocales: S.delegate.supportedLocales,
          home: MarketCoinInfo({
            'coin_gecko_id': coinId,
            'coin': '',
            'name': name,
            'price': 1,
          }, loadCoinInfoForTesting: loadCoinInfo),
        ),
      ),
    );

    await tester.pumpWidget(build('old-coin', 'Old coin'));
    final originalState = tester.state(find.byType(MarketCoinInfo));
    await tester.pumpWidget(build('current-coin', 'Current coin'));
    expect(
      identical(originalState, tester.state(find.byType(MarketCoinInfo))),
      isTrue,
      reason: 'coin changes should reuse the page and exercise didUpdateWidget',
    );
    expect(requests, ['old-coin', 'current-coin']);

    currentResponse.complete({
      'description': {'en': 'Current coin description'},
    });
    await tester.pumpAndSettle();
    expect(find.text('Current coin description'), findsOneWidget);

    oldResponse.completeError(StateError('old request failed'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Current coin description'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
