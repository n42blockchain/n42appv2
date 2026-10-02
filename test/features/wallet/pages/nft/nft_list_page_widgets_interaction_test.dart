import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/nft/nft_list_page.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../helpers/widget_test_helpers.dart';

Map<String, dynamic> _nft({
  required String name,
  required String tokenId,
  String type = 'ERC721',
  String collection = 'Gallery',
  String? animationUrl,
  int quantity = 1,
  Map<String, dynamic>? floorPrice,
}) => {
  'nft_id': 'ethereum.0xabc.$tokenId',
  'name': name,
  'token_id': tokenId,
  'chain': 'ethereum',
  'quantity': quantity,
  'animation_url': animationUrl,
  'contract': {'address': '0xabc', 'type': type},
  'collection': {
    'name': collection,
    if (floorPrice != null) 'floor_prices': [floorPrice],
  },
};

class _NftHttpOverrides extends HttpOverrides {
  _NftHttpOverrides(this.nfts);

  final List<Map<String, dynamic>> nfts;

  @override
  HttpClient createHttpClient(SecurityContext? context) => _NftHttpClient(nfts);
}

class _NftHttpClient implements HttpClient {
  _NftHttpClient(this.nfts);

  final List<Map<String, dynamic>> nfts;

  @override
  Duration? connectionTimeout;

  @override
  set badCertificateCallback(
    bool Function(X509Certificate certificate, String host, int port)? callback,
  ) {}

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _NftHttpRequest(nfts);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NftHttpRequest implements HttpClientRequest {
  _NftHttpRequest(this.nfts);

  final List<Map<String, dynamic>> nfts;
  final _NftHttpHeaders _headers = _NftHttpHeaders();

  @override
  HttpHeaders get headers => _headers;

  @override
  set followRedirects(bool value) {}

  @override
  set maxRedirects(int value) {}

  @override
  set persistentConnection(bool value) {}

  @override
  Future<HttpClientResponse> close() async => _NftHttpResponse(
    utf8.encode(jsonEncode({'nfts': nfts, 'next_cursor': null})),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NftHttpResponse extends Stream<List<int>> implements HttpClientResponse {
  _NftHttpResponse(this.body);

  final List<int> body;

  @override
  int get statusCode => HttpStatus.ok;

  @override
  String get reasonPhrase => 'OK';

  @override
  HttpHeaders get headers => _NftHttpHeaders(body.length);

  @override
  bool get isRedirect => false;

  @override
  List<RedirectInfo> get redirects => const [];

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => Stream<List<int>>.value(body).listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NftHttpHeaders implements HttpHeaders {
  _NftHttpHeaders([this._contentLength]);

  final int? _contentLength;

  @override
  int get contentLength => _contentLength ?? -1;

  @override
  void forEach(void Function(String name, List<String> values) action) {
    if (_contentLength case final length?) {
      action(HttpHeaders.contentLengthHeader, ['$length']);
    }
    action(HttpHeaders.contentTypeHeader, ['application/json']);
  }

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

CoinModel _coin({String coinType = 'ETH'}) {
  final coin = CoinModel();
  coin.address = '0x0000000000000000000000000000000000000001';
  coin.coin = {'coinType': coinType};
  return coin;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final previousHttpOverrides = HttpOverrides.current;
  final gallery = [
    _nft(
      name: 'Alpha Dragon',
      tokenId: '1',
      collection: 'Alpha',
      floorPrice: {
        'value': 0.5,
        'payment_token': {'symbol': 'ETH'},
      },
    ),
    _nft(
      name: 'Beta Movie',
      tokenId: '2',
      type: 'ERC1155',
      collection: 'Beta',
      animationUrl: 'https://assets.example/movie.mp4?size=small',
      quantity: 3,
    ),
    _nft(name: 'Claim a reward', tokenId: '3', collection: 'Airdrop'),
  ];

  setUp(() {
    HttpOverrides.global = _NftHttpOverrides(gallery);
  });

  tearDown(() {
    HttpOverrides.global = previousHttpOverrides;
  });

  Future<void> pumpGallery(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(wrapForTest(NftListPage(_coin())));
    await tester.pumpAndSettle();
  }

  testWidgets('search and type chips filter the loaded gallery', (
    tester,
  ) async {
    await pumpGallery(tester);

    expect(find.text('Alpha Dragon'), findsOneWidget);
    expect(find.text('Beta Movie'), findsOneWidget);
    expect(find.text('Claim a reward'), findsNothing);
    expect(find.text('0.5000 ETH'), findsOneWidget);
    expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);

    await tester.tap(find.text(S.current.g_key_nft_filter_video));
    await tester.pumpAndSettle();
    expect(find.text('Beta Movie'), findsOneWidget);
    expect(find.text('Alpha Dragon'), findsNothing);

    await tester.tap(find.text(S.current.g_key_nft_filter_all));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'alpha');
    await tester.pumpAndSettle();
    expect(find.text('Alpha Dragon'), findsOneWidget);
    expect(find.text('Beta Movie'), findsNothing);

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();
    expect(find.text('Alpha Dragon'), findsOneWidget);
    expect(find.text('Beta Movie'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('spam switch reveals hidden items and grouping adds headers', (
    tester,
  ) async {
    await pumpGallery(tester);

    expect(find.text('Claim a reward'), findsNothing);
    await tester.tap(find.byIcon(Icons.shield));
    await tester.pumpAndSettle();
    expect(find.text('Claim a reward'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.dashboard_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);
    expect(find.text('Airdrop'), findsOneWidget);
    expect(find.byType(CustomScrollView), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('long press selects a transferable NFT and close clears it', (
    tester,
  ) async {
    await pumpGallery(tester);

    await tester.longPress(find.text('Alpha Dragon'));
    await tester.pumpAndSettle();
    expect(find.text('1 selected'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text(S.current.g_key_nft_gallery), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
