import 'dart:async';

import 'package:fast_base58/fast_base58.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/near_api.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/provider/transaction_state_resolver.dart';

final hash = Base58Encode(List.filled(32, 7));
TransationRecordModel record() => TransationRecordModel()
  ..coin = {'blockchainType': 'Near'}
  ..coinMiniName = 'NEAR'
  ..txHash = hash
  ..from1 = 'alice.near'
  ..to1 = 'bob.near'
  ..price = BigInt.from(123);
Map<String, dynamic> receipt() => {
  'final_execution_status': 'FINAL',
  'status': {'SuccessValue': ''},
  'transaction': {
    'hash': hash,
    'signer_id': 'alice.near',
    'receiver_id': 'bob.near',
    'actions': [
      {
        'Transfer': <String, dynamic>{'deposit': '123'},
      },
    ],
  },
};
void main() {
  for (final testnet in [false, true]) {
    for (final failed in [false, true]) {
      test(
        'final receipt on selected network $testnet failure=$failed',
        () async {
          var calls = 0;
          final resolver = TransactionStateResolver(
            nearApiFactory: (selected) {
              expect(selected, testnet);
              return NearApi(
                isTest: selected,
                request: (url, body) async {
                  calls++;
                  expect(
                    url,
                    testnet
                        ? 'https://rpc.testnet.near.org'
                        : 'https://rpc.mainnet.near.org',
                  );
                  expect(body['method'], 'tx');
                  expect(body['params'], {
                    'tx_hash': hash,
                    'sender_account_id': 'alice.near',
                    'wait_until': 'FINAL',
                  });
                  final result = receipt();
                  if (failed) {
                    result['status'] = {
                      'Failure': {
                        'ActionError': {'index': 0},
                      },
                    };
                  }
                  return {'result': result};
                },
              );
            },
          );
          expect(
            await resolver.resolveState(record()..isTest = testnet ? 1 : 0),
            failed ? 2 : 1,
          );
          expect(calls, 1);
        },
      );
    }
  }
  final mutations = <String, void Function(Map<String, dynamic>)>{
    'other hash': (r) =>
        r['transaction']['hash'] = Base58Encode(List.filled(32, 8)),
    'other signer': (r) => r['transaction']['signer_id'] = 'other.near',
    'other receiver': (r) => r['transaction']['receiver_id'] = 'other.near',
    'other amount': (r) =>
        r['transaction']['actions'][0]['Transfer']['deposit'] = '124',
    'numeric amount': (r) =>
        r['transaction']['actions'][0]['Transfer']['deposit'] = 123,
    'other action': (r) => r['transaction']['actions'] = ['DeleteAccount'],
    'additional action': (r) => r['transaction']['actions'].add({
      'Transfer': {'deposit': '1'},
    }),
    'missing transaction': (r) => r.remove('transaction'),
    'missing finality': (r) => r.remove('final_execution_status'),
    'optimistic': (r) => r['final_execution_status'] = 'EXECUTED_OPTIMISTIC',
    'executed': (r) => r['final_execution_status'] = 'EXECUTED',
    'unknown status': (r) => r['status'] = 'Unknown',
    'pending receipt': (r) => r['status'] = {'SuccessReceiptId': hash},
    'bad success': (r) => r['status'] = {'SuccessValue': 'not base64!'},
    'empty failure': (r) => r['status'] = {'Failure': {}},
    'ambiguous': (r) => r['status'] = {
      'SuccessValue': '',
      'Failure': {'error': 'x'},
    },
  };
  for (final entry in mutations.entries) {
    test('${entry.key} remains unresolved', () async {
      final result = receipt();
      entry.value(result);
      final resolver = TransactionStateResolver(
        nearApiFactory: (_) =>
            NearApi(request: (_, _) async => {'result': result}),
      );
      expect(await resolver.resolveState(record()), -1);
    });
  }
  for (final mode in ['timeout', 'not found', 'empty']) {
    test('$mode never proves failure or safe retry', () async {
      final resolver = TransactionStateResolver(
        nearApiFactory: (_) => NearApi(
          request: (_, _) async {
            if (mode == 'timeout') throw TimeoutException('test');
            if (mode == 'empty') return null;
            return {
              'error': {'message': 'UNKNOWN_TRANSACTION'},
            };
          },
        ),
      );
      expect(await resolver.resolveState(record()), -1);
    });
  }
  for (final change in <String, void Function(TransationRecordModel)>{
    'owner': (r) => r.userUuid = 'other',
    'network': (r) => r.isTest = 1,
    'hash': (r) => r.txHash = Base58Encode(List.filled(32, 9)),
    'amount': (r) => r.price = BigInt.one,
    'receiver': (r) => r.to1 = 'other.near',
  }.entries) {
    test('${change.key} mutation during request discards receipt', () async {
      final tx = record();
      final resolver = TransactionStateResolver(
        nearApiFactory: (_) => NearApi(
          request: (_, _) async {
            change.value(tx);
            return {'result': receipt()};
          },
        ),
      );
      expect(await resolver.resolveState(tx), -1);
    });
  }
  test('invalid local identity never queries', () async {
    var calls = 0;
    final resolver = TransactionStateResolver(
      nearApiFactory: (_) {
        calls++;
        return NearApi();
      },
    );
    for (final tx in [
      record()..txHash = 'bad',
      record()..isTest = 2,
      record()..contract = 'token',
      record()..price = BigInt.zero,
    ]) {
      expect(await resolver.resolveState(tx), -1);
    }
    expect(calls, 0);
  });
}
