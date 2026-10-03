import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/features/wallet/pages/market/market_page.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _EmptyWatchlistStore extends SPUtil {
  @override
  Future<Map<String, dynamic>?> getUserInfo() async => null;

  @override
  Future<List<String>> getMarketWatchlist() async => [];
}

class _FixtureHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _FixtureHttpClient();
}

class _FixtureHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    final Object payload;
    if (url.host == 'api.alternative.me') {
      payload = {
        'data': [
          {
            'value': '78',
            'value_classification': 'Extreme Greed',
            'timestamp': '1790899200',
          },
        ],
      };
    } else if (url.path.endsWith('/market/trending')) {
      payload = {
        'coins': [
          {
            'item': {
              'id': 'bitcoin',
              'name': 'Bitcoin',
              'symbol': 'btc',
              'large': '',
              'market_cap_rank': 1,
              'data': {
                'price': r'$67,890.12',
                'price_change_percentage_24h': {'usd': -1.25},
              },
            },
          },
        ],
      };
    } else if (url.path.endsWith('/market/search')) {
      payload = {
        'coins': [
          {
            'id': 'bitcoin',
            'name': 'Bitcoin',
            'symbol': 'btc',
            'thumb': '',
            'market_cap_rank': 1,
          },
        ],
      };
    } else {
      payload = const <String, Object>{};
    }
    return _FixtureHttpRequest(jsonEncode(payload));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FixtureHttpRequest implements HttpClientRequest {
  _FixtureHttpRequest(this.body);

  final String body;
  @override
  final HttpHeaders headers = _FixtureHttpHeaders();
  @override
  Future<HttpClientResponse> close() async => _FixtureHttpResponse(body);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FixtureHttpHeaders implements HttpHeaders {
  @override
  ContentType? get contentType => ContentType.json;

  @override
  void forEach(void Function(String name, List<String> values) action) {
    action(HttpHeaders.contentTypeHeader, ['application/json; charset=utf-8']);
  }

  @override
  String? value(String name) =>
      name.toLowerCase() == HttpHeaders.contentTypeHeader
      ? 'application/json; charset=utf-8'
      : null;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FixtureHttpResponse extends Stream<List<int>>
    implements HttpClientResponse {
  _FixtureHttpResponse(String body) : _body = utf8.encode(body);

  final List<int> _body;
  @override
  int get statusCode => HttpStatus.ok;
  @override
  int get contentLength => _body.length;
  @override
  bool get isRedirect => false;
  @override
  bool get persistentConnection => false;
  @override
  String get reasonPhrase => 'OK';
  @override
  List<RedirectInfo> get redirects => const [];
  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;
  @override
  HttpHeaders get headers => _FixtureHttpHeaders();
  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => Stream<List<int>>.value(_body).listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _marketApp() => ProviderScope(
  overrides: [spUtilProvider.overrideWithValue(_EmptyWatchlistStore())],
  child: ScreenUtilInit(
    designSize: const Size(750, 1334),
    minTextAdapt: true,
    builder: (_, _) => MaterialApp(
      theme: ThemeAdapter.buildLight(ThemeAdapter.defaultAccent),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: const MarketPage.withoutInitialData(),
    ),
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final previousHttpOverrides = HttpOverrides.current;
  const pathProvider = MethodChannel('plugins.flutter.io/path_provider');

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    HttpOverrides.global = _FixtureHttpOverrides();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          pathProvider,
          (call) async => '/tmp/market_shared_widgets_test',
        );
  });
  tearDown(() {
    HttpOverrides.global = previousHttpOverrides;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProvider, null);
  });

  testWidgets(
    'trending tab renders the no-data state without network loading',
    (tester) async {
      await tester.pumpWidget(_marketApp());
      await tester.pump();

      expect(find.text('No trending data'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up_rounded), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'search tab starts with a prompt and watchlist shows its empty state',
    (tester) async {
      await tester.pumpWidget(_marketApp());
      await tester.pump();

      await tester.tap(find.text(S.current.g_market_search));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey<String>('market_search_input')),
        findsOneWidget,
      );
      expect(find.text('Search for a coin'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsNWidgets(2));

      await tester.tap(find.text(S.current.g_market_watchlist));
      await tester.pumpAndSettle();
      expect(find.text(S.current.g_market_empty_watchlist), findsOneWidget);
      expect(find.byIcon(Icons.star_outline_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('news tab renders its empty message and refresh affordance', (
    tester,
  ) async {
    await tester.pumpWidget(_marketApp());
    await tester.pump();

    await tester.tap(find.text(S.current.g_market_news));
    await tester.pumpAndSettle();
    expect(find.text(S.current.g_news_empty), findsOneWidget);
    expect(find.byIcon(Icons.newspaper_outlined), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('trending coin formats price, rank, loss and watchlist action', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [spUtilProvider.overrideWithValue(_EmptyWatchlistStore())],
        child: ScreenUtilInit(
          designSize: const Size(750, 1334),
          minTextAdapt: true,
          builder: (_, _) => MaterialApp(
            theme: ThemeAdapter.buildLight(ThemeAdapter.defaultAccent),
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            home: const MarketPage(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();

    expect(find.text('Bitcoin'), findsOneWidget);
    expect(find.text('#1'), findsOneWidget);
    expect(find.text(r'$67,890.12'), findsOneWidget);
    expect(find.text('-1.25%'), findsOneWidget);
    expect(find.byIcon(Icons.star_outline_rounded), findsOneWidget);
    expect(find.text('🤑'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('search result omits price but retains coin actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [spUtilProvider.overrideWithValue(_EmptyWatchlistStore())],
        child: ScreenUtilInit(
          designSize: const Size(750, 1334),
          minTextAdapt: true,
          builder: (_, _) => MaterialApp(
            theme: ThemeAdapter.buildLight(ThemeAdapter.defaultAccent),
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            home: const MarketPage(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
    await tester.tap(find.text(S.current.g_market_search));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey<String>('market_search_input')),
      'bitcoin',
    );
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();

    expect(find.text('Bitcoin'), findsOneWidget);
    expect(find.text('BTC'), findsOneWidget);
    expect(find.text('--'), findsNothing);
    expect(find.text('0.00%'), findsNothing);
    expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
    expect(find.byIcon(Icons.star_outline_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
