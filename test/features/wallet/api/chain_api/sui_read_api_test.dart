import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/utils/result.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/sui_api.dart';

/// Read paths against real Sui GraphQL replies (test/fixtures/sui_graphql),
/// captured read-only from graphql.{mainnet,testnet}.sui.io.
Map<String, dynamic> fixture(String name) =>
    jsonDecode(File('test/fixtures/sui_graphql/$name').readAsStringSync())
        as Map<String, dynamic>;

/// Replays whole HTTP bodies through the real GraphQL envelope handling.
class ReplayApi extends SuiApi {
  final List<Object> replies;
  final requests = <Map<String, dynamic>>[];
  ReplayApi(this.replies);
  @override
  Future<Result<dynamic, AppError>> graphQL(
    String document,
    Map<String, dynamic> variables, {
    bool enableRetry = true,
  }) {
    requests.add({'query': document, 'variables': variables});
    final reply = replies.removeAt(0);
    return SuiApi(
      post: (url, body) async {
        if (reply is Exception) throw reply;
        return reply;
      },
    ).graphQL(document, variables, enableRetry: enableRetry);
  }
}

Map<String, dynamic> coinsPage(
  List<Map<String, dynamic>> nodes, {
  Object? hasNext = false,
  Object? cursor,
}) => {
  'data': {
    'address': {
      'objects': {
        'pageInfo': {'hasNextPage': hasNext, 'endCursor': cursor},
        'nodes': nodes,
      },
    },
  },
};

void main() {
  group('balance', () {
    test('real mainnet balance is the total in MIST', () async {
      final api = ReplayApi([fixture('balance_mainnet.json')]);
      final result = await api.getBalanceSui('0xowner');
      expect(result.error, isFalse);
      expect(result.data, BigInt.parse('243001381957'));
      expect(api.requests.single, {
        'query': SuiApi.balanceQuery,
        'variables': {'owner': '0xowner'},
      });
    });

    test('an unused address reads zero', () async {
      final api = ReplayApi([fixture('balance_unused.json')]);
      expect((await api.getBalanceSui('0x1')).data, BigInt.zero);
    });

    for (final (name, reply) in [
      (
        'missing balance',
        {
          'data': {
            'address': {'balance': null},
          },
        },
      ),
      (
        'missing address',
        {
          'data': {'address': null},
        },
      ),
      (
        'negative',
        {
          'data': {
            'address': {
              'balance': {'totalBalance': '-1'},
            },
          },
        },
      ),
      (
        'decimal',
        {
          'data': {
            'address': {
              'balance': {'totalBalance': '1.5'},
            },
          },
        },
      ),
      ('graphql error', fixture('tx_bad_digest.json')),
    ]) {
      test('$name is an error, never zero', () async {
        final api = ReplayApi([reply]);
        expect((await api.getBalanceSui('0x1')).error, isTrue);
      });
    }

    test('transport failure is an error', () async {
      final api = ReplayApi([const SocketException('down')]);
      expect((await api.getBalanceSui('0x1')).error, isTrue);
    });
  });

  group('gas price', () {
    test('real reference gas price', () async {
      final api = ReplayApi([fixture('gas_mainnet.json')]);
      final result = await api.getGasPriceSui();
      expect(result.data, BigInt.from(100));
      expect(api.requests.single['query'], SuiApi.gasPriceQuery);
    });

    test('missing epoch is an error', () async {
      final api = ReplayApi([
        {
          'data': {'epoch': null},
        },
      ]);
      expect((await api.getGasPriceSui()).error, isTrue);
    });
  });

  group('owned SUI coins', () {
    test('real testnet coins map to signer coin references', () async {
      final reply = fixture('coins_testnet.json');
      final nodes = reply['data']['address']['objects']['nodes'] as List;
      final api = ReplayApi([reply]);
      final coins = await api.getOwnedObjects('0xowner');
      expect(coins, hasLength(nodes.length));
      expect(coins.first, {
        'data': {
          'objectId': nodes.first['address'],
          'version': '${nodes.first['version']}',
          'digest': nodes.first['digest'],
          'content': {
            'fields': {'balance': nodes.first['contents']['json']['balance']},
          },
        },
      });
      expect(api.requests.single, {
        'query': SuiApi.coinsQuery,
        'variables': {'owner': '0xowner', 'after': null},
      });
    });

    test('no coins is an empty list', () async {
      final api = ReplayApi([fixture('coins_none.json')]);
      expect(await api.getOwnedObjects('0xowner'), isEmpty);
    });

    final coin =
        (fixture('coins_testnet.json')['data']['address']['objects']['nodes']
                    as List)
                .first
            as Map<String, dynamic>;

    test('pagination follows the cursor and keeps every page', () async {
      final second = {...coin, 'address': '0x${'cd' * 32}'};
      final api = ReplayApi([
        coinsPage([coin], hasNext: true, cursor: 'c1'),
        coinsPage([second]),
      ]);
      final coins = await api.getOwnedObjects('0xowner');
      expect(coins.map((c) => c['data']['objectId']), [
        coin['address'],
        second['address'],
      ]);
      expect(api.requests[1]['variables']['after'], 'c1');
    });

    test('a repeated cursor never yields a partial selection', () async {
      final page = coinsPage([coin], hasNext: true, cursor: 'same');
      final api = ReplayApi([page, page]);
      expect(await api.getOwnedObjects('0xowner'), isEmpty);
    });

    for (final (name, reply) in [
      ('later page error', null),
      ('missing pageInfo flag', coinsPage([coin], hasNext: 'false')),
      (
        'missing version',
        coinsPage([
          {...coin, 'version': null},
        ]),
      ),
      (
        'missing digest',
        coinsPage([
          {...coin, 'digest': ''},
        ]),
      ),
      (
        'missing balance',
        coinsPage([
          {...coin, 'contents': null},
        ]),
      ),
    ]) {
      test('$name discards the whole selection', () async {
        final api = ReplayApi([
          coinsPage([coin], hasNext: true, cursor: 'next'),
          reply ?? fixture('tx_bad_digest.json'),
        ]);
        expect(await api.getOwnedObjects('0xowner'), isEmpty);
      });
    }
  });

  group('simulation', () {
    Map<String, dynamic> simulation({
      Object? computation = 9007199254740993,
      String status = 'SUCCESS',
      Object? rebate = 3,
    }) => {
      'data': {
        'simulateTransaction': {
          'effects': {
            'status': status,
            'executionError': status == 'SUCCESS'
                ? null
                : {'message': 'InsufficientCoinBalance'},
            'gasEffects': {
              'gasSummary': {
                'computationCost': computation,
                'storageCost': 2,
                'storageRebate': rebate,
              },
            },
          },
        },
      },
    };

    test('real mainnet simulation yields the net gas cost', () async {
      final api = ReplayApi([fixture('simulate_success_mainnet.json')]);
      final result = await api.dryRunTransactionBlock('unsigned');
      expect(result.error, isFalse);
      // 100000 + 47872400 - 47594040
      expect(result.data, BigInt.from(378360));
      expect(api.requests.single, {
        'query': SuiApi.simulateQuery,
        'variables': {
          'transaction': {
            'bcs': {'value': 'unsigned'},
          },
        },
      });
    });

    test('large integers keep their precision', () async {
      final api = ReplayApi([simulation(computation: '9007199254740993')]);
      expect(
        (await api.dryRunTransactionBlock('unsigned')).data,
        BigInt.parse('9007199254740992'),
      );
    });

    test('rejected bytes are an error', () async {
      final api = ReplayApi([fixture('simulate_invalid_bcs.json')]);
      final result = await api.dryRunTransactionBlock('Z2FyYmFnZQ==');
      expect(result.error, isTrue);
      expect(result.data, contains('invalid transaction'));
    });

    for (final bad in [null, -1, '1.2', '-1', '', 1.5]) {
      test('simulation rejects malformed gas $bad', () async {
        final api = ReplayApi([simulation(computation: bad)]);
        expect((await api.dryRunTransactionBlock('unsigned')).error, isTrue);
      });
    }

    test('failed simulation never becomes a fee estimate', () async {
      final api = ReplayApi([simulation(status: 'FAILURE')]);
      final result = await api.dryRunTransactionBlock('unsigned');
      expect(result.error, isTrue);
      expect(result.data, contains('InsufficientCoinBalance'));
    });

    test('storage rebate cannot produce a negative reserved cost', () async {
      final api = ReplayApi([simulation(computation: 1, rebate: 100)]);
      expect((await api.dryRunTransactionBlock('unsigned')).data, BigInt.zero);
    });
  });

  group('transaction lookup', () {
    test('real reply returns the transaction object', () async {
      final reply = fixture('tx_success_mainnet.json');
      final api = ReplayApi([reply]);
      final result = await api.getTransactionBlock('digest');
      expect(result.data, reply['data']['transaction']);
      expect(api.requests.single['query'], SuiApi.transactionQuery);
    });

    test('not found is null data, not an error', () async {
      final api = ReplayApi([fixture('tx_not_found.json')]);
      final result = await api.getTransactionBlock('digest');
      expect(result.error, isFalse);
      expect(result.data, isNull);
    });

    test('GraphQL error is an error', () async {
      final api = ReplayApi([fixture('tx_bad_digest.json')]);
      final result = await api.getTransactionBlock('abc');
      expect(result.error, isTrue);
      expect(result.data, contains('Expected digest to be 32B'));
    });

    test('reply without the transaction field is an error', () async {
      final api = ReplayApi([
        {'data': <String, dynamic>{}},
      ]);
      expect((await api.getTransactionBlock('digest')).error, isTrue);
    });
  });
}
