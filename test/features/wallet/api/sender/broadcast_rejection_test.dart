import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fast_base58/fast_base58.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/network/base_http.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/ada_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/near_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/xlm_api.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';

/// Only an explicit refusal from the submission API is a rejection. Timeouts,
/// gateway errors and foreign error bodies must stay "unknown".
void main() {
  group('Stellar submission', () {
    XlmApi api(Object? response) => XlmApi(
      submit: (url, body, {required header, required enableRetry}) async {
        expect(enableRetry, isFalse);
        if (response is Exception) throw response;
        return response;
      },
    );
    final horizonFailed = {
      'type': 'https://stellar.org/horizon-errors/transaction_failed',
      'title': 'Transaction Failed',
      'status': 400,
      'extras': {
        'result_codes': {
          'transaction': 'tx_bad_seq',
        },
      },
    };

    test('Horizon transaction_failed is an explicit rejection', () async {
      final result = await api(
        HttpStatusResult(400, horizonFailed),
      ).sendTransaction('AAAA');
      expect(result.error, isTrue);
      expect(result.data, isA<BroadcastRejected>());
      expect(result.data.toString(), contains('tx_bad_seq'));
    });

    test('Horizon problem body as text is still recognised', () async {
      final result = await api(
        HttpStatusResult(400, jsonEncode(horizonFailed)),
      ).sendTransaction('AAAA');
      expect(result.data, isA<BroadcastRejected>());
    });

    for (final response in [
      const HttpStatusResult(null, null),
      HttpStatusResult(504, {'type': 'timeout', 'status': 504}),
      const HttpStatusResult(400, 'Bad gateway page'),
      HttpStatusResult(400, {'status': 400, 'type': 'about:blank'}),
      HttpStatusResult(500, horizonFailed),
    ]) {
      test(
        'status ${response.statusCode} ${response.data} is unknown',
        () async {
          final result = await api(response).sendTransaction('AAAA');
          expect(result.error, isTrue);
          expect(result.data, isNot(isA<BroadcastRejected>()));
        },
      );
    }

    test('accepted envelope is still success', () async {
      final result = await api(
        HttpStatusResult(200, {'successful': true, 'hash': 'ab' * 32}),
      ).sendTransaction('AAAA');
      expect(result.error, isFalse);
    });
  });

  group('Cardano submission', () {
    AdaApi api(Object? response) => AdaApi(
      projectId: 'fixture-project',
      submit: (url, bytes, {required header, required enableRetry}) async {
        expect(bytes, isA<Uint8List>());
        expect(enableRetry, isFalse);
        return response;
      },
    );

    test('Blockfrost 400 is an explicit rejection', () async {
      final result = await api(
        HttpStatusResult(400, {
          'status_code': 400,
          'error': 'Bad Request',
          'message': 'BadInputsUTxO',
        }),
      ).sendTransaction('00ff');
      expect(result.data, isA<BroadcastRejected>());
      expect(result.data.toString(), contains('BadInputsUTxO'));
    });

    for (final response in [
      const HttpStatusResult(null, null),
      HttpStatusResult(425, {'status_code': 425, 'error': 'Mempool Full'}),
      HttpStatusResult(400, {'error': 'Bad Request'}),
      const HttpStatusResult(502, '<html>'),
    ]) {
      test('status ${response.statusCode} is unknown', () async {
        final result = await api(response).sendTransaction('00ff');
        expect(result.error, isTrue);
        expect(result.data, isNot(isA<BroadcastRejected>()));
      });
    }

    test('accepted hash is still success', () async {
      final result = await api(
        HttpStatusResult(200, 'ab' * 32),
      ).sendTransaction('00ff');
      expect(result.error, isFalse);
      expect(result.data, 'ab' * 32);
    });
  });

  group('NEAR submission', () {
    final fixture =
        jsonDecode(File('test/native/near_reference.json').readAsStringSync())
            as Map;
    final hex = fixture['transactionHashHex'] as String;
    final hash = Base58Encode(
      List.generate(
        32,
        (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16),
      ),
    );
    final signed = fixture['signedTransaction'] as String;

    test('INVALID_TRANSACTION is an explicit rejection', () async {
      final api = NearApi(
        request: (_, _) async => {
          'error': {
            'name': 'HANDLER_ERROR',
            'cause': {
              'name': 'INVALID_TRANSACTION',
              'info': {},
            },
          },
        },
      );
      final result = await api.sendTransaction(signed);
      expect(result.data, isA<BroadcastRejected>());
    });

    test('execution failure of this transaction is terminal', () async {
      final api = NearApi(
        request: (_, _) async => {
          'result': {
            'transaction': {'hash': hash},
            'status': {'Failure': {'ActionError': {}}},
          },
        },
      );
      expect((await api.sendTransaction(signed)).data, isA<BroadcastRejected>());
    });

    for (final response in [
      {
        'error': {
          'name': 'HANDLER_ERROR',
          'cause': {'name': 'TIMEOUT_ERROR'},
        },
      },
      {
        'error': {'name': 'REQUEST_VALIDATION_ERROR'},
      },
      {
        'result': {
          'transaction': {'hash': Base58Encode(List.filled(32, 9))},
          'status': {'Failure': {}},
        },
      },
    ]) {
      test('$response is unknown', () async {
        final api = NearApi(request: (_, _) async => response);
        final result = await api.sendTransaction(signed);
        expect(result.error, isTrue);
        expect(result.data, isNot(isA<BroadcastRejected>()));
      });
    }
  });
}
