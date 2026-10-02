import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/ens/ens_renew_page.dart';
import 'package:n42_wallet/features/wallet/services/ens_models.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../helpers/widget_test_helpers.dart';

class _EnsHttpOverrides extends HttpOverrides {
  _EnsHttpOverrides(this.respond);

  Map<String, dynamic> Function(String method, Uri uri) respond;
  final requests = <(String, Uri, String)>[];

  @override
  HttpClient createHttpClient(SecurityContext? context) => _EnsHttpClient(this);
}

class _EnsHttpClient implements HttpClient {
  _EnsHttpClient(this.overrides);

  final _EnsHttpOverrides overrides;

  @override
  Duration? connectionTimeout;

  @override
  set badCertificateCallback(
    bool Function(X509Certificate certificate, String host, int port)? callback,
  ) {}

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return _EnsHttpRequest(method, url, overrides);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _EnsHttpRequest implements HttpClientRequest {
  _EnsHttpRequest(this.method, this.uri, this.overrides);

  @override
  final String method;
  @override
  final Uri uri;
  final _EnsHttpOverrides overrides;
  final BytesBuilder _body = BytesBuilder();
  final _EnsHttpHeaders _headers = _EnsHttpHeaders();

  @override
  HttpHeaders get headers => _headers;

  @override
  set followRedirects(bool value) {}

  @override
  set maxRedirects(int value) {}

  @override
  set persistentConnection(bool value) {}

  @override
  void add(List<int> data) => _body.add(data);

  @override
  Future<HttpClientResponse> close() async {
    overrides.requests.add((method, uri, utf8.decode(_body.takeBytes())));
    return _EnsHttpResponse(
      utf8.encode(jsonEncode(overrides.respond(method, uri))),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _EnsHttpResponse extends Stream<List<int>> implements HttpClientResponse {
  _EnsHttpResponse(this.body);

  final List<int> body;

  @override
  int get statusCode => HttpStatus.ok;

  @override
  String get reasonPhrase => 'OK';

  @override
  HttpHeaders get headers => _EnsHttpHeaders(body.length);

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

class _EnsHttpHeaders implements HttpHeaders {
  _EnsHttpHeaders([this._contentLength]);

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

final _ownedEns = OwnedEns(
  name: 'n42.eth',
  ownerAddress: '0x0000000000000000000000000000000000000001',
  expiresAt: DateTime.utc(2030, 1, 1),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final previousHttpOverrides = HttpOverrides.current;
  late _EnsHttpOverrides httpOverrides;

  setUpAll(() {
    httpOverrides = _EnsHttpOverrides((method, uri) {
      if (uri.path.endsWith('/v1/ens/price')) {
        return {
          'code': 200,
          'data': {
            'basePrice': 0,
            'annualPrice': 0.01,
            'totalPrice': 0.01,
            'years': int.tryParse(uri.queryParameters['years'] ?? '') ?? 1,
            'nameLength': 3,
            'updatedAt': '2026-10-02T00:00:00Z',
          },
        };
      }
      return {'code': 503, 'msg': 'Renewal rejected by test server'};
    });
    HttpOverrides.global = httpOverrides;
  });

  setUp(() {
    httpOverrides.requests.clear();
    httpOverrides.respond = (method, uri) {
      if (uri.path.endsWith('/v1/ens/price')) {
        return {
          'code': 200,
          'data': {
            'basePrice': 0,
            'annualPrice': 0.01,
            'totalPrice': 0.01,
            'years': int.tryParse(uri.queryParameters['years'] ?? '') ?? 1,
            'nameLength': 3,
            'updatedAt': '2026-10-02T00:00:00Z',
          },
        };
      }
      return {'code': 503, 'msg': 'Renewal rejected by test server'};
    };
  });

  tearDownAll(() {
    HttpOverrides.global = previousHttpOverrides;
  });

  Future<void> pumpRenewPage(WidgetTester tester) async {
    await tester.pumpWidget(
      wrapForTest(
        EnsRenewPage(
          ownedEns: _ownedEns,
          walletAddress: '0x0000000000000000000000000000000000000001',
        ),
      ),
    );
  }

  testWidgets('loads price and refreshes it when the renewal term changes', (
    tester,
  ) async {
    await pumpRenewPage(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.text('0.0100 ETH'), findsNWidgets(2));
    expect(
      httpOverrides.requests.map(
        (request) => request.$2.queryParameters['years'],
      ),
      ['1'],
    );

    await tester.tap(find.textContaining('+2'));
    await tester.pumpAndSettle();

    expect(
      httpOverrides.requests.map(
        (request) => request.$2.queryParameters['years'],
      ),
      ['1', '2'],
    );
    expect(find.text('0.0200 ETH'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'price error keeps renewal disabled and selecting a term retries',
    (tester) async {
      var priceAttempts = 0;
      httpOverrides.respond = (method, uri) {
        if (uri.path.endsWith('/v1/ens/price')) {
          priceAttempts++;
          if (priceAttempts == 1) return {'code': 503, 'msg': 'Unavailable'};
          return {
            'code': 200,
            'data': {
              'basePrice': 0,
              'annualPrice': 0.01,
              'totalPrice': 0.02,
              'years': 2,
              'nameLength': 3,
            },
          };
        }
        return {'code': 503, 'msg': 'Renewal rejected by test server'};
      };

      await pumpRenewPage(tester);
      await tester.pumpAndSettle();

      final renewButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, S.current.g_key_ens_confirm_renew),
      );
      expect(renewButton.onPressed, isNull);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.tap(find.textContaining('+2'));
      await tester.pumpAndSettle();

      final retriedRenewButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, S.current.g_key_ens_confirm_renew),
      );
      expect(retriedRenewButton.onPressed, isNotNull);
      expect(priceAttempts, 2);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('renew action reports transport failure without leaving page', (
    tester,
  ) async {
    await pumpRenewPage(tester);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text(S.current.g_key_ens_confirm_renew));
    await tester.tap(find.text(S.current.g_key_ens_confirm_renew));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.byType(EnsRenewPage), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
