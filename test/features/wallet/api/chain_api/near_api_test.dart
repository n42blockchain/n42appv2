import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/near_api.dart';

void main() {
  for (final testnet in [false, true]) {
    for (final usage in [0, 770, 771, 1200]) {
      test('storage reserve at $usage bytes, testnet=$testnet', () async {
        final calls = <Map<String, dynamic>>[];
        final api = NearApi(
          isTest: testnet,
          request: (url, body) async {
            expect(
              url,
              testnet
                  ? 'https://rpc.testnet.near.org'
                  : 'https://rpc.mainnet.near.org',
            );
            calls.add(body);
            if (body['method'] == 'query') {
              expect(body['params'], {
                'request_type': 'view_account',
                'finality': 'final',
                'account_id': 'alice.near',
              });
              return {
                'result': {
                  'amount': '100000',
                  'locked': '100',
                  'storage_usage': usage,
                  'block_hash': 'finalized-block',
                },
              };
            }
            expect(body['method'], 'EXPERIMENTAL_protocol_config');
            expect(body['params'], {'block_id': 'finalized-block'});
            return {
              'result': {
                'runtime_config': {'storage_amount_per_byte': '10'},
              },
            };
          },
        );
        final result = await api.getTransferBalance('alice.near');
        expect(result.error, isFalse);
        expect(result.data['balance'], BigInt.from(100000));
        expect(
          result.data['storageReserve'],
          BigInt.from(usage <= 770 ? 0 : usage * 10 - 100),
        );
        expect(calls.length, 2);
      });
    }
  }
  for (final locked in ['12000', '12001']) {
    test(
      'locked stake covers storage without spending the stake $locked',
      () async {
        final api = NearApi(
          request: (_, body) async => body['method'] == 'query'
              ? {
                  'result': {
                    'amount': '100',
                    'locked': locked,
                    'storage_usage': 1200,
                    'block_hash': 'block',
                  },
                }
              : {
                  'result': {
                    'runtime_config': {'storage_amount_per_byte': '10'},
                  },
                },
        );
        final result = await api.getTransferBalance('alice.near');
        expect(result.error, isFalse);
        expect(result.data, {
          'balance': BigInt.from(100),
          'storageReserve': BigInt.zero,
        });
      },
    );
  }
  for (final field in ['amount', 'locked', 'storage_usage', 'block_hash']) {
    test('missing account $field fails closed', () async {
      final account = <String, dynamic>{
        'amount': '100',
        'locked': '0',
        'storage_usage': 1200,
        'block_hash': 'block',
      }..remove(field);
      final api = NearApi(
        request: (_, body) async {
          expect(body['method'], 'query');
          return {'result': account};
        },
      );
      expect((await api.getTransferBalance('alice.near')).error, isTrue);
    });
  }
  for (final invalid in [
    null,
    '0',
    '-1',
    '1.5',
    1.5,
    'invalid',
    true,
    '340282366920938463463374607431768211456',
  ]) {
    test(
      'invalid or overflowing storage price $invalid fails closed',
      () async {
        final api = NearApi(
          request: (_, body) async => body['method'] == 'query'
              ? {
                  'result': {
                    'amount': '100',
                    'locked': '0',
                    'storage_usage': 1200,
                    'block_hash': 'block',
                  },
                }
              : {
                  'result': {
                    'runtime_config': {'storage_amount_per_byte': invalid},
                  },
                },
        );
        expect((await api.getTransferBalance('alice.near')).error, isTrue);
      },
    );
  }
  test('RPC failure is not converted into zero reserve', () async {
    final api = NearApi(
      request: (_, body) async => body['method'] == 'query'
          ? {
              'result': {
                'amount': '100',
                'locked': '0',
                'storage_usage': 1200,
                'block_hash': 'block',
              },
            }
          : {
              'error': {'message': 'offline'},
            },
    );
    expect((await api.getTransferBalance('alice.near')).error, isTrue);
  });
  test('display balance preserves the existing raw amount contract', () async {
    final api = NearApi(
      request: (_, body) async => {
        'result': {'amount': '100'},
      },
    );
    expect((await api.getBalance('alice.near')).data, BigInt.from(100));
  });
}
