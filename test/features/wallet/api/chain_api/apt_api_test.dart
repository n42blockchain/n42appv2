import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/apt_api.dart';

void main() {
  final hash = '0x${List.filled(64, 'a').join()}';
  for (final encoded in ['00aBff', '0x00aBff', '0X00aBff']) {
    for (final isTest in [false, true]) {
      test('native hex $encoded sends bytes on testnet=$isTest', () async {
        var calls = 0;
        final api = AptApi(
          isTest: isTest,
          submit: (url, bytes, {required header, required enableRetry}) async {
            calls++;
            expect(url, contains(isTest ? 'testnet' : 'mainnet'));
            expect(url, endsWith('/transactions'));
            expect(bytes, [0, 171, 255]);
            expect(
              header['content-type'],
              'application/x.aptos.signed_transaction+bcs',
            );
            expect(enableRetry, isFalse);
            return {'type': 'pending_transaction', 'hash': hash};
          },
        );
        final result = await api.sendTxHash(encoded);
        expect(result.error, isFalse);
        expect(result.data, hash);
        expect(calls, 1);
      });
    }
  }
  for (final invalid in ['', '0x', '0x0', 'zz', ' aa', 'aa\n', '0x0x12']) {
    test('invalid hex $invalid never dispatches', () async {
      var calls = 0;
      final api = AptApi(
        submit: (_, _, {required header, required enableRetry}) async {
          calls++;
          return {'hash': hash};
        },
      );
      expect((await api.sendTxHash(invalid)).error, isTrue);
      expect(calls, 0);
    });
  }
  for (final response in [
    null,
    <String, dynamic>{},
    {'hash': ''},
    {'hash': 42},
    {'hash': '0x12'},
    {'hash': '$hash\n'},
    {'hash': hash, 'success': false},
    {'hash': hash, 'success': 'true'},
  ]) {
    test('invalid response $response cannot report success', () async {
      final api = AptApi(
        submit: (_, _, {required header, required enableRetry}) async =>
            response,
      );
      expect((await api.sendTxHash('00ff')).error, isTrue);
    });
  }
  test(
    'committed successful response preserves its transaction hash',
    () async {
      final api = AptApi(
        submit: (_, _, {required header, required enableRetry}) async => {
          'hash': hash,
          'success': true,
        },
      );
      final response = await api.sendTxHash('00ff');
      expect(response.error, isFalse);
      expect(response.data, hash);
    },
  );
  test('transport timeout is not retried or reported as success', () async {
    var calls = 0;
    final api = AptApi(
      submit: (_, _, {required header, required enableRetry}) async {
        calls++;
        expect(enableRetry, isFalse);
        throw TimeoutException('fixture');
      },
    );
    expect((await api.sendTxHash('00ff')).error, isTrue);
    expect(calls, 1);
  });
  test('real HTTP transport preserves the BCS bytes', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    final received = Completer<List<int>>();
    server.listen((request) async {
      final bytes = await request.fold<List<int>>(
        [],
        (all, chunk) => all..addAll(chunk),
      );
      expect(
        request.headers.contentType?.mimeType,
        'application/x.aptos.signed_transaction+bcs',
      );
      received.complete(bytes);
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({'hash': hash}));
      await request.response.close();
    });
    final api = AptApi(
      submit: (_, bytes, {required header, required enableRetry}) =>
          BaseApi.requestEmptyH.post(
            'http://127.0.0.1:${server.port}/transactions',
            params: {},
            data: bytes,
            header: header,
            enableRetry: enableRetry,
          ),
    );
    final result = await api.sendTxHash('0x00017f80ff');
    expect(result.error, isFalse);
    expect(await received.future.timeout(const Duration(seconds: 5)), [
      0,
      1,
      127,
      128,
      255,
    ]);
  });
}
