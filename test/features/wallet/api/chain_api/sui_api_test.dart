import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fast_base58/fast_base58.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/utils/result.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/sui_api.dart';

class _Api extends SuiApi {
  dynamic response;
  int calls = 0;
  @override
  Future<Result<dynamic, AppError>> baseRPCSui(
    String method,
    dynamic value, {
    bool enableRetry = true,
  }) async {
    calls++;
    expect(method, 'sui_executeTransactionBlock');
    expect(value, [
      'bytes',
      ['signature'],
      {'showEffects': true, 'showEvents': true},
    ]);
    expect(enableRetry, isFalse);
    return Result.success(response);
  }
}

void main() {
  final digest = Base58Encode(List.filled(32, 7));
  Map<String, dynamic> receipt(String status) => {
    'digest': digest,
    'effects': {
      'status': {'status': status},
    },
    'events': [],
  };
  test('successful submission retains the full confirmed response', () async {
    final api = _Api()..response = receipt('success');
    final response = await api.submit('bytes', 'signature');
    expect(response.error, isFalse);
    expect(response.data, api.response);
    expect(api.calls, 1);
  });
  final invalid = <dynamic>[
    null,
    {},
    digest,
    {'digest': digest},
    receipt('failure'),
    receipt('pending'),
    {
      ...receipt('success'),
      'effects': {'status': 'success'},
    },
    {...receipt('success'), 'digest': ''},
    {...receipt('success'), 'digest': 42},
    {...receipt('success'), 'digest': 'invalid'},
    {...receipt('success'), 'digest': '$digest\n'},
    {...receipt('success'), 'digest': Base58Encode(List.filled(31, 7))},
  ];
  for (var i = 0; i < invalid.length; i++) {
    test('unconfirmed receipt $i cannot report success', () async {
      final api = _Api()..response = invalid[i];
      expect((await api.submit('bytes', 'signature')).error, isTrue);
      expect(api.calls, 1);
    });
  }
  for (final fail in [false, true]) {
    test(
      'real HTTP submission preserves positional params; RPC error=$fail',
      () async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        addTearDown(() => server.close(force: true));
        var calls = 0;
        final received = Completer<Map<String, dynamic>>();
        server.listen((request) async {
          calls++;
          final body = jsonDecode(
            await utf8.decoder.bind(request).join(),
          ) as Map<String, dynamic>;
          if (!received.isCompleted) received.complete(body);
          request.response.headers.contentType = ContentType.json;
          request.response.write(
            jsonEncode({
              'jsonrpc': '2.0',
              'id': body['id'],
              if (fail)
                'error': {'code': -32000, 'message': 'Rejected'}
              else
                'result': receipt('success'),
            }),
          );
          await request.response.close();
        });
        final api = SuiApi()..url = 'http://127.0.0.1:${server.port}';
        final response = await api.submit('bytes', 'signature');
        final body = await received.future.timeout(const Duration(seconds: 5));
        expect(body['method'], 'sui_executeTransactionBlock');
        expect(body['params'], [
          'bytes',
          ['signature'],
          {'showEffects': true, 'showEvents': true},
        ]);
        expect(response.error, fail);
        expect(calls, 1);
      },
    );
  }
}
