import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/ens/ens_management_page.dart';
import 'package:n42_wallet/features/wallet/pages/ens/ens_management_widgets.dart';
import 'package:n42_wallet/features/wallet/services/ens_registration_service.dart';

import '../../../helpers/widget_test_helpers.dart';

class _EnsHttpOverrides extends HttpOverrides {
  _EnsHttpOverrides(this.respond);

  Map<String, dynamic> Function(String method, Uri uri, String body) respond;
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
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _EnsHttpRequest(method, url, overrides);

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
  final _body = BytesBuilder();
  final _headers = _EnsHttpHeaders();

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
  Encoding get encoding => utf8;
  @override
  set encoding(Encoding value) {}
  @override
  void write(Object? object) => add(utf8.encode(object.toString()));
  @override
  void writeAll(Iterable<dynamic> objects, [String separator = '']) =>
      write(objects.join(separator));
  @override
  void writeln([Object? object = '']) => write('$object\n');
  @override
  Future<void> addStream(Stream<List<int>> stream) async {
    await for (final bytes in stream) {
      add(bytes);
    }
  }

  @override
  Future<void> flush() async {}

  @override
  Future<HttpClientResponse> close() async {
    final body = utf8.decode(_body.takeBytes());
    overrides.requests.add((method, uri, body));
    return _EnsHttpResponse(
      utf8.encode(jsonEncode(overrides.respond(method, uri, body))),
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

const _wallet = '0x0000000000000000000000000000000000000001';
final _ownedEns = OwnedEns(
  name: 'alice.eth',
  ownerAddress: _wallet,
  resolvedAddress: _wallet,
  expiresAt: DateTime.utc(2030),
  textRecords: {'email': 'alice@example.test'},
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final previousOverrides = HttpOverrides.current;
  final httpOverrides = _EnsHttpOverrides((method, uri, body) => {});

  setUpAll(() {
    HttpOverrides.global = httpOverrides;
  });

  setUp(() {
    EnsRegistrationServiceProvider.reset();
    httpOverrides.requests.clear();
    httpOverrides.respond = (method, uri, body) {
      if (uri.path.endsWith('/v1/ens/subdomains')) {
        return {
          'code': 200,
          'data': [
            {'label': 'blog', 'fullName': 'blog.alice.eth', 'owner': _wallet},
            {
              'label': 'old',
              'fullName': 'old.alice.eth',
              'owner': '0x0000000000000000000000000000000000000000',
            },
          ],
        };
      }
      return {
        'code': 200,
        'data': {'txHash': '0xtest'},
      };
    };
  });

  tearDownAll(() {
    EnsRegistrationServiceProvider.reset();
    HttpOverrides.global = previousOverrides;
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      wrapForTest(
        EnsManagementPage(ownedEns: _ownedEns, walletAddress: _wallet),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('loads live subdomains and omits deleted entries', (
    tester,
  ) async {
    await pumpPage(tester);

    expect(find.text('blog.alice.eth'), findsOneWidget);
    expect(find.text('old.alice.eth'), findsNothing);
    expect(
      httpOverrides.requests.single.$2.queryParameters['name'],
      'alice.eth',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'rejects an invalid resolution address without sending a request',
    (tester) async {
      await pumpPage(tester);
      await tester.ensureVisible(find.byType(EnsAddressSection));
      await tester.enterText(
        find.descendant(
          of: find.byType(EnsAddressSection),
          matching: find.byType(TextField),
        ),
        'not-an-address',
      );
      await tester.tap(
        find.descendant(
          of: find.byType(EnsAddressSection),
          matching: find.widgetWithText(TextButton, 'Save'),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        httpOverrides.requests.where(
          (request) => request.$2.path.endsWith('/v1/ens/set-address'),
        ),
        isEmpty,
      );
      expect(find.byType(SnackBar), findsOneWidget);
    },
  );

  testWidgets('trims and saves a valid resolution address', (tester) async {
    await pumpPage(tester);
    await tester.ensureVisible(find.byType(EnsAddressSection));
    const newAddress = '0x0000000000000000000000000000000000000002';
    await tester.enterText(
      find.descendant(
        of: find.byType(EnsAddressSection),
        matching: find.byType(TextField),
      ),
      ' $newAddress ',
    );
    await tester.tap(
      find.descendant(
        of: find.byType(EnsAddressSection),
        matching: find.widgetWithText(TextButton, 'Save'),
      ),
    );
    await tester.pumpAndSettle();

    final request = httpOverrides.requests.singleWhere(
      (request) => request.$2.path.endsWith('/v1/ens/set-address'),
    );
    expect(jsonDecode(request.$3), {
      'name': 'alice.eth',
      'address': newAddress,
    });
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('saves only nonempty text records', (tester) async {
    await pumpPage(tester);
    await tester.ensureVisible(find.byType(EnsTextRecordsSection));
    await tester.enterText(
      find.descendant(
        of: find.byType(EnsTextRecordsSection),
        matching: find.widgetWithText(TextField, 'Email'),
      ),
      'new@example.test',
    );
    await tester.enterText(
      find.descendant(
        of: find.byType(EnsTextRecordsSection),
        matching: find.widgetWithText(TextField, 'Website'),
      ),
      '',
    );
    await tester.tap(
      find.descendant(
        of: find.byType(EnsTextRecordsSection),
        matching: find.widgetWithText(TextButton, 'Save'),
      ),
    );
    await tester.pumpAndSettle();

    final request = httpOverrides.requests.singleWhere(
      (request) => request.$2.path.endsWith('/v1/ens/update-records'),
    );
    expect(jsonDecode(request.$3), {
      'name': 'alice.eth',
      'records': {'email': 'new@example.test'},
    });
  });

  testWidgets('sets this ENS name as the wallet primary name', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text('Set as Primary'));
    await tester.pumpAndSettle();

    final request = httpOverrides.requests.singleWhere(
      (request) => request.$2.path.endsWith('/v1/ens/set-primary'),
    );
    expect(jsonDecode(request.$3), {'name': 'alice.eth', 'address': _wallet});
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('transfer dialog rejects an invalid owner before submission', (
    tester,
  ) async {
    await pumpPage(tester);
    await tester.ensureVisible(find.byType(EnsAdvancedSection));
    await tester.tap(find.text('Transfer'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Transfer'));
    await tester.pumpAndSettle();

    expect(
      find.text('Invalid address (must be 0x + 40 hex chars)'),
      findsOneWidget,
    );
    expect(
      httpOverrides.requests.where(
        (request) => request.$2.path.endsWith('/v1/ens/transfer'),
      ),
      isEmpty,
    );
  });
}
