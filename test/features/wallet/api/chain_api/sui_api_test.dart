import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fast_base58/fast_base58.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/sui_api.dart';

/// executeTransaction is only exercised against mocks: reply shapes follow the
/// live schema (Mutation.executeTransaction -> ExecutionResult ->
/// TransactionEffects) and the error envelope the service returns for
/// rejected input (test/fixtures/sui_graphql/*.json).
void main() {
  final digest = Base58Encode(List.filled(32, 7));
  Map<String, dynamic> executed(String status, {String? error}) => {
    'data': {
      'executeTransaction': {
        'effects': {
          'digest': digest,
          'status': status,
          'executionError': error == null ? null : {'message': error},
          'checkpoint': null,
        },
      },
    },
  };

  SuiApi api(Object reply, List<Map<String, dynamic>> bodies) => SuiApi(
    post: (url, body) async {
      bodies.add(body);
      if (reply is Exception) throw reply;
      return reply;
    },
  );

  test('endpoints are the official GraphQL services', () {
    expect(SuiApi().url, 'https://graphql.mainnet.sui.io/graphql');
    expect(SuiApi(isTest: true).url, 'https://graphql.testnet.sui.io/graphql');
  });

  test('successful execution returns the confirmed digest', () async {
    final bodies = <Map<String, dynamic>>[];
    final response = await api(
      executed('SUCCESS'),
      bodies,
    ).submit('bytes', 'signature');
    expect(response.error, isFalse);
    expect(response.data['digest'], digest);
    expect(response.data['effects']['status'], 'SUCCESS');
    expect(bodies.single['query'], SuiApi.executeMutation);
    expect(bodies.single['variables'], {
      'transactionDataBcs': 'bytes',
      'signatures': ['signature'],
    });
  });

  final invalid = <String, Object>{
    'failure effects': executed('FAILURE', error: 'InsufficientGas'),
    'graphql error': {
      'data': null,
      'errors': [
        {
          'message': 'Invalid argument: invalid transaction',
          'path': ['executeTransaction'],
          'extensions': {'code': 'BAD_USER_INPUT'},
        },
      ],
    },
    'partial data with errors': {
      ...executed('SUCCESS'),
      'errors': [
        {'message': 'Request timed out'},
      ],
    },
    'no effects': {
      'data': {
        'executeTransaction': {'effects': null},
      },
    },
    'no data': <String, dynamic>{},
    'not a map': 'oops',
    'short digest': {
      'data': {
        'executeTransaction': {
          'effects': {
            'digest': Base58Encode(List.filled(31, 7)),
            'status': 'SUCCESS',
          },
        },
      },
    },
    'lower-case status': {
      'data': {
        'executeTransaction': {
          'effects': {'digest': digest, 'status': 'success'},
        },
      },
    },
    'transport error': const SocketException('reset'),
  };
  invalid.forEach((name, reply) {
    test('execution that is not confirmed is an error: $name', () async {
      final bodies = <Map<String, dynamic>>[];
      final response = await api(reply, bodies).submit('bytes', 'signature');
      expect(response.error, isTrue);
      expect(bodies, hasLength(1));
    });
  });

  test('execution failure keeps the chain reason', () async {
    final response = await api(
      executed('FAILURE', error: 'InsufficientGas'),
      [],
    ).submit('bytes', 'signature');
    expect(response.data, contains('InsufficientGas'));
  });

  test('GraphQL error message is surfaced', () async {
    final response = await api({
      'data': null,
      'errors': [
        {'message': 'Transaction is locked by another transaction'},
      ],
    }, []).submit('bytes', 'signature');
    expect(response.data, 'Transaction is locked by another transaction');
  });

  for (final fail in [false, true]) {
    test(
      'real HTTP execution posts one GraphQL mutation; error=$fail',
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
            jsonEncode(
              fail
                  ? {
                      'data': null,
                      'errors': [
                        {'message': 'Rejected'},
                      ],
                    }
                  : executed('SUCCESS'),
            ),
          );
          await request.response.close();
        });
        final client = SuiApi()..url = 'http://127.0.0.1:${server.port}';
        final response = await client.submit('bytes', 'signature');
        final body = await received.future.timeout(const Duration(seconds: 5));
        expect(body['query'], SuiApi.executeMutation);
        expect(body['variables']['signatures'], ['signature']);
        expect(response.error, fail);
        expect(calls, 1);
      },
    );
  }
}
