import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/nft/nft_list_page.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../helpers/widget_test_helpers.dart';

class _GalleryHttpOverrides extends HttpOverrides {
  final requests = <Uri>[];
  bool includeSpam = false;

  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      _GalleryHttpClient(requests, () => includeSpam);
}

class _GalleryHttpClient implements HttpClient {
  _GalleryHttpClient(this.requests, this.includeSpam);

  final List<Uri> requests;
  final bool Function() includeSpam;

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    requests.add(url);
    return _GalleryHttpRequest(url, includeSpam: includeSpam());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      invocation.isSetter ? null : super.noSuchMethod(invocation);
}

class _GalleryHttpRequest implements HttpClientRequest {
  _GalleryHttpRequest(this._uri, {required this.includeSpam});

  final Uri _uri;
  final bool includeSpam;
  final _GalleryHeaders _headers = _GalleryHeaders();

  @override
  Uri get uri => _uri;

  @override
  HttpHeaders get headers => _headers;

  @override
  Future<HttpClientResponse> close() async {
    final isSecondPage = _uri.queryParameters['cursor'] == 'page-2';
    final nfts = isSecondPage
        ? [_nft('erc1155', 'Game item', type: 'ERC1155', collection: 'Game')]
        : [
            _nft('azuki-1', 'Azuki #1', collection: 'Azuki'),
            _nft(
              'video-1',
              'Animated artwork',
              collection: 'Motion',
              animationUrl: 'https://media.invalid/clip.mp4',
            ),
            if (includeSpam ||
                _uri.queryParameters['wallet_addresses']?.endsWith('2') == true)
              _nft('spam-1', 'Claim reward now', collection: 'Claim rewards'),
          ];
    final payload = <String, Object?>{
      'nfts': nfts,
      if (!isSecondPage) 'next_cursor': 'page-2',
    };
    return _GalleryHttpResponse(utf8.encode(jsonEncode(payload)));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _GalleryHeaders implements HttpHeaders {
  @override
  void forEach(void Function(String name, List<String> values) action) {}

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _GalleryHttpResponse extends Stream<List<int>>
    implements HttpClientResponse {
  _GalleryHttpResponse(this.bytes);

  final List<int> bytes;

  @override
  int get statusCode => HttpStatus.ok;

  @override
  int get contentLength => bytes.length;

  @override
  bool get persistentConnection => false;

  @override
  bool get isRedirect => false;

  @override
  List<RedirectInfo> get redirects => const [];

  @override
  String get reasonPhrase => 'OK';

  @override
  HttpHeaders get headers => _GalleryHeaders();

  @override
  X509Certificate? get certificate => null;

  @override
  HttpConnectionInfo? get connectionInfo => null;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => Stream<List<int>>.value(bytes).listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Map<String, Object?> _nft(
  String id,
  String name, {
  String type = 'ERC721',
  String collection = 'Collection',
  String? animationUrl,
}) => {
  'nft_id': 'ethereum.0xabc.$id',
  'name': name,
  'token_id': id,
  'chain': 'ethereum',
  'quantity': 1,
  'contract': {'address': '0xabc', 'type': type},
  'collection': {
    'name': collection,
    'floor_prices': [
      {
        'value': 0.01234,
        'payment_token': {'symbol': 'ETH'},
      },
    ],
  },
  // The collection-if keeps the key absent when no animation is present.
  // ignore: use_null_aware_elements
  if (animationUrl != null) 'animation_url': animationUrl,
};

CoinModel _coin({
  String address = '0x0000000000000000000000000000000000000001',
}) {
  final coin = CoinModel();
  coin.address = address;
  coin.coin = {'coinType': 'ETH'};
  return coin;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final previousHttpOverrides = HttpOverrides.current;
  late _GalleryHttpOverrides overrides;

  setUp(() {
    overrides = _GalleryHttpOverrides();
    HttpOverrides.global = overrides;
  });

  tearDown(() => HttpOverrides.global = previousHttpOverrides);

  Future<void> pumpGallery(WidgetTester tester, {CoinModel? coin}) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(wrapForTest(NftListPage(coin ?? _coin())));
    await tester.pumpAndSettle();
  }

  testWidgets('loads both cursor pages and renders cards, metadata and video', (
    tester,
  ) async {
    await pumpGallery(tester);

    expect(overrides.requests, isNotEmpty);
    expect(find.text('Azuki #1'), findsOneWidget);
    expect(find.text('Animated artwork'), findsOneWidget);
    expect(find.text('Game item'), findsOneWidget);
    expect(find.text('0.0123 ETH'), findsNWidgets(3));
    expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
    expect(overrides.requests, hasLength(2));
    expect(overrides.requests.last.queryParameters['cursor'], 'page-2');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('search, type filters, grouping and clear update visible cards', (
    tester,
  ) async {
    await pumpGallery(tester);

    await tester.enterText(find.byType(TextField), 'game');
    await tester.pumpAndSettle();
    expect(find.text('Game item'), findsOneWidget);
    expect(find.text('Azuki #1'), findsNothing);

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();
    expect(find.text('Azuki #1'), findsOneWidget);
    expect(find.text('Game item'), findsOneWidget);

    await tester.tap(find.text('ERC1155'));
    await tester.pumpAndSettle();
    expect(find.text('Game item'), findsOneWidget);
    expect(find.text('Azuki #1'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'group toggle groups cards by collection and back navigation works',
    (tester) async {
      await pumpGallery(tester);
      await tester.tap(find.byIcon(Icons.dashboard_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Azuki'), findsOneWidget);
      expect(find.text('Motion'), findsOneWidget);
      expect(find.text('Game'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Animated artwork'),
        250,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Animated artwork'));
      await tester.pumpAndSettle();
      expect(find.text('Animated artwork'), findsNWidgets(2));
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Animated artwork'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('spam visibility toggle and batch selection can be cleared', (
    tester,
  ) async {
    await pumpGallery(
      tester,
      coin: _coin(address: '0x0000000000000000000000000000000000000002'),
    );

    expect(find.text('Claim reward now'), findsNothing);
    await tester.tap(find.textContaining(S.current.g_key_nft_hide_spam));
    await tester.pumpAndSettle();
    expect(find.text('Claim reward now'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.checklist_outlined));
    await tester.pumpAndSettle();
    expect(find.text('0 selected'), findsOneWidget);

    await tester.longPress(find.text('Azuki #1'));
    await tester.pumpAndSettle();
    expect(find.text('1 selected'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('1 selected'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
