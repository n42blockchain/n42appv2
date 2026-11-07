import 'dart:convert';
import 'dart:io';

import 'package:fast_base58/fast_base58.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/near_api.dart';

void main() {
  final fixture = jsonDecode(
    File('test/native/near_reference.json').readAsStringSync(),
  ) as Map;
  final hex = fixture['transactionHashHex'] as String;
  final hash = Base58Encode(
    List.generate(
      32,
      (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16),
    ),
  );
  final signed = fixture['signedTransaction'] as String;
  for (final status in [
    null,
    {},
    {'Unknown': null},
    {'SuccessReceiptId': hash},
    {'SuccessValue': 1},
    {'SuccessValue': '!'},
    {'Failure': {}},
    {'SuccessValue': '', 'Failure': {}},
  ]) {
    test('does not claim completion for $status', () async {
      final api = NearApi(
        request: (_, _) async => {
          'result': {
            'transaction': {'hash': hash},
            'status': ?status,
          },
        },
      );
      expect((await api.sendTransaction(signed)).error, isTrue);
    });
  }
  for (final value in [
    null,
    '',
    'bad',
    Base58Encode(List.filled(31, 7)),
    123,
  ]) {
    test('rejects malformed transaction hash $value', () async {
      final api = NearApi(
        request: (_, _) async => {
          'result': {
            'transaction': {'hash': value},
            'status': {'SuccessValue': ''},
          },
        },
      );
      expect((await api.sendTransaction(signed)).error, isTrue);
    });
  }
  for (final value in ['', base64Encode(utf8.encode('ok'))]) {
    test('accepts terminal success value $value', () async {
      final api = NearApi(
        isTest: true,
        request: (url, body) async {
          expect(url, 'https://rpc.testnet.near.org');
          expect(body['method'], 'broadcast_tx_commit');
          expect(body['params'], [signed]);
          return {
            'result': {
              'transaction': {'hash': hash},
              'status': {'SuccessValue': value},
            },
          };
        },
      );
      final result = await api.sendTransaction(signed);
      expect(result.error, isFalse);
      expect(result.data, hash);
    });
  }
  for (final invalid in ['', '!', 'YWJj\n']) {
    test('malformed signed bytes never reach RPC: $invalid', () async {
      var calls = 0;
      final api = NearApi(
        request: (_, _) async {
          calls++;
          return {};
        },
      );
      final result = await api.sendTransaction(invalid);
      expect(result.error, isTrue);
      expect(result.data, 'Invalid signed NEAR encoding');
      expect(calls, 0);
    });
  }
  test('transport failure is not success and is not retried by API', () async {
    var calls = 0;
    final api = NearApi(
      request: (_, _) async {
        calls++;
        throw StateError('offline');
      },
    );
    expect((await api.sendTransaction(signed)).error, isTrue);
    expect(calls, 1);
  });
  test(
    'unrelated well-formed transaction hash is not this submission',
    () async {
      final api = NearApi(
        request: (_, _) async => {
          'result': {
            'transaction': {'hash': Base58Encode(List.filled(32, 9))},
            'status': {'SuccessValue': ''},
          },
        },
      );
      final result = await api.sendTransaction(signed);
      expect(result.error, isTrue);
      expect(result.data, contains('unknown'));
    },
  );
}
