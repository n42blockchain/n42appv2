import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/xlm_api.dart';

void main() {
  test('real HTTP submits exactly one URL-encoded tx field', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    final received = Completer<(String?, String)>();
    var calls = 0;
    server.listen((request) async {
      calls++;
      final raw = await utf8.decoder.bind(request).join();
      received.complete((request.headers.contentType?.mimeType, raw));
      request.response.headers.contentType = ContentType.json;
      request.response.write(
        jsonEncode({'hash': 'ab' * 32, 'successful': true}),
      );
      await request.response.close();
    });
    // Includes +, / and =, all of which require lossless form encoding.
    const xdr = '+/8=';
    final api = XlmApi(
      submit: (url, body, {required header, required enableRetry}) {
        expect(url, endsWith('/transactions'));
        expect(enableRetry, isFalse);
        return BaseApi.requestEmptyH.post(
          'http://127.0.0.1:${server.port}/transactions',
          params: {},
          data: body,
          header: header,
          enableRetry: enableRetry,
          defaultReturn: false,
        );
      },
    );
    final result = await api.sendTransaction(xdr);
    final (contentType, raw) = await received.future.timeout(
      const Duration(seconds: 5),
    );
    expect(result.error, isFalse);
    expect(contentType, 'application/x-www-form-urlencoded');
    expect(Uri.splitQueryString(raw), {'tx': xdr});
    expect(calls, 1);
  });
  for (final input in [
    '',
    'not XDR',
    'AA',
    'AB==',
    'AA==\n',
    ' AA==',
    '_w==',
    '%2B/8=',
  ]) {
    test(
      'malformed/noncanonical encoding rejected: ${jsonEncode(input)}',
      () async {
        final api = XlmApi(
          submit: (_, body, {required header, required enableRetry}) async {
            fail('Malformed encoding must not reach transport');
          },
        );
        expect((await api.sendTransaction(input)).error, isTrue);
      },
    );
  }
  for (final response in [
    null,
    'ok',
    {},
    [],
    {'hash': 'ab' * 32},
    {'successful': false, 'hash': 'ab' * 32},
    {'successful': 'true', 'hash': 'ab' * 32},
    {'successful': true, 'hash': 'ab'},
    {'successful': true, 'hash': 'gg' * 32},
  ]) {
    test('invalid success response ${jsonEncode(response)}', () async {
      var calls = 0;
      final api = XlmApi(
        submit: (_, body, {required header, required enableRetry}) async {
          calls++;
          expect(body, {'tx': '+/8='});
          expect(enableRetry, isFalse);
          return response;
        },
      );
      expect((await api.sendTransaction('+/8=')).error, isTrue);
      expect(calls, 1);
    });
  }
  for (final isTest in [false, true]) {
    test('valid submission testnet=$isTest', () async {
      final api = XlmApi(
        submit: (url, body, {required header, required enableRetry}) async {
          expect(url, endsWith('/transactions'));
          expect(body, {'tx': '+/8='});
          expect(header['content-type'], 'application/x-www-form-urlencoded');
          expect(enableRetry, isFalse);
          return {'hash': 'ab' * 32, 'successful': true};
        },
      );
      final result = await api.sendTransaction('+/8=', isTest: isTest);
      expect(result.error, isFalse);
      expect(result.data['hash'], 'ab' * 32);
    });
  }
  test('timeout does not retry submission', () async {
    var calls = 0;
    final api = XlmApi(
      submit: (_, body, {required header, required enableRetry}) async {
        calls++;
        expect(enableRetry, isFalse);
        throw TimeoutException('Lost response');
      },
    );
    expect((await api.sendTransaction('+/8=')).error, isTrue);
    expect(calls, 1);
  });
}
