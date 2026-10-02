import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/market/market_coin_info.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _OfflineHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _OfflineHttpClient();
}

class _OfflineHttpClient implements HttpClient {
  @override
  void Function(X509Certificate cert, String host, int port)?
  badCertificateCallback;

  @override
  void close({bool force = false}) {}

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      throw const SocketException('Network disabled in market coin tests');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MarketAssetBundle extends CachingAssetBundle {
  static final _pixel = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/yZcAAAAASUVORK5CYII=',
  );

  @override
  Future<ByteData> load(String key) async {
    if (key == 'assets/img/list.default.png') {
      return ByteData.sublistView(_pixel);
    }
    return rootBundle.load(key);
  }
}

void main() {
  late HttpOverrides? originalOverrides;

  setUp(() {
    originalOverrides = HttpOverrides.current;
    HttpOverrides.global = _OfflineHttpOverrides();
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() => HttpOverrides.global = originalOverrides);

  Future<void> openInfo(WidgetTester tester, Map<String, dynamic> coin) async {
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
          home: DefaultAssetBundle(
            bundle: _MarketAssetBundle(),
            child: MarketCoinInfo(coin),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows supplied price, change, and fallback chart offline', (
    tester,
  ) async {
    await openInfo(tester, {
      'coin': '',
      'name': 'Sample asset',
      'price': 12.5,
      'price_change_per_24h': 3.25,
      'kline_default': [10.0, 11.0, 12.5],
    });

    expect(find.textContaining('Sample asset'), findsOneWidget);
    expect(find.textContaining('12.5'), findsWidgets);
    expect(find.textContaining('+3.25%'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('period selector remains interactive when chart has no coin id', (
    tester,
  ) async {
    await openInfo(tester, {
      'coin': '',
      'name': 'No identifier',
      'price': 1,
      'price_change_per_24h': -2,
    });

    final period = find.text('7D');
    await tester.ensureVisible(period);
    await tester.tap(period);
    await tester.pump();

    expect(period, findsOneWidget);
    expect(find.textContaining('-2.00%'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
