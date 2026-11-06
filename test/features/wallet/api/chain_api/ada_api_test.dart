import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/ada_api.dart';

void main() {
  for (final hex in ['00017f80ff', '0x00017F80FF']) {
    for (final isTest in [false, true]) {
      test('CBOR decoding $hex testnet=$isTest', () async {
        var calls = 0;
        final api = AdaApi(
          projectId: 'fixture-project',
          submit: (url, bytes, {required header, required enableRetry}) async {
            calls++;
            expect(url, endsWith('/tx/submit'));
            expect(bytes, isA<Uint8List>());
            expect(bytes, [0, 1, 127, 128, 255]);
            expect(header['content-type'], 'application/cbor');
            expect(header['project_id'], 'fixture-project');
            expect(enableRetry, isFalse);
            return 'ab' * 32;
          },
        );
        final result = await api.sendTransaction(hex, isTest: isTest);
        expect(result.error, isFalse);
        expect(result.data, 'ab' * 32);
        expect(calls, 1);
      });
    }
  }
  for (final hex in [
    '',
    '0x',
    'a',
    '0x123',
    'gg',
    '0x00\n',
    ' 00',
    '00 01',
    '0x0x00',
  ]) {
    test('malformed hex fails before HTTP: ${jsonEncode(hex)}', () async {
      final api = AdaApi(
        projectId: 'fixture-project',
        submit: (url, bytes, {required header, required enableRetry}) async {
          fail('Malformed hex must not be submitted');
        },
      );
      expect((await api.sendTransaction(hex)).error, isTrue);
    });
  }
  for (final response in [
    null,
    '',
    'ab',
    {'error': 'rejected'},
    ['ab' * 32],
    'x' * 64,
  ]) {
    test(
      'invalid success body ${jsonEncode(response)} is not accepted',
      () async {
        final api = AdaApi(
          projectId: 'fixture-project',
          submit: (url, bytes, {required header, required enableRetry}) async =>
              response,
        );
        expect((await api.sendTransaction('00')).error, isTrue);
      },
    );
  }
  test('lost response is not retried', () async {
    var calls = 0;
    final api = AdaApi(
      projectId: 'fixture-project',
      submit: (url, bytes, {required header, required enableRetry}) async {
        calls++;
        expect(enableRetry, isFalse);
        throw TimeoutException('fixture');
      },
    );
    expect((await api.sendTransaction('00')).error, isTrue);
    expect(calls, 1);
  });
  test(
    'real transport delivers binary CBOR without JSON or hex encoding',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      final received = Completer<List<int>>();
      server.listen((request) async {
        final bytes = await request.fold<List<int>>(
          [],
          (all, chunk) => all..addAll(chunk),
        );
        expect(request.method, 'POST');
        expect(request.uri.path, '/tx/submit');
        expect(request.headers.contentType?.mimeType, 'application/cbor');
        expect(request.headers.value('project_id'), 'fixture-project');
        received.complete(bytes);
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode('ab' * 32));
        await request.response.close();
      });
      final api = AdaApi(
        projectId: 'fixture-project',
        submit: (_, bytes, {required header, required enableRetry}) =>
            BaseApi.requestEmptyH.post(
              'http://127.0.0.1:${server.port}/tx/submit',
              params: {},
              data: bytes,
              header: header,
              enableRetry: enableRetry,
              defaultReturn: false,
            ),
      );
      expect((await api.sendTransaction('0x00017f80ff')).error, isFalse);
      expect(await received.future.timeout(const Duration(seconds: 5)), [
        0,
        1,
        127,
        128,
        255,
      ]);
    },
  );
}
