import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:n42_wallet/features/wallet/models/aggregated_token.dart';
import 'package:n42_wallet/features/wallet/services/aggregated_balance_reader.dart';

void main() {
  final eth = AggregatedTokens.usdt.chains.first;
  final sol = AggregatedTokens.usdc.chains.firstWhere((c) => c.rules == 'SPL');
  final trx = AggregatedTokens.usdt.chains.firstWhere(
    (c) => c.rules == 'TRC20',
  );
  const address = '0x0000000000000000000000000000000000000001';
  Map<String, dynamic> account(String id, String amount) => {
    'pubkey': id,
    'account': {
      'data': {
        'parsed': {
          'info': {
            'owner': 'owner',
            'mint': sol.contract,
            'tokenAmount': {'amount': amount, 'decimals': sol.decimals},
          },
        },
      },
    },
  };

  test(
    'ERC20 uses exact ABI owner word and returns integer above double precision',
    () async {
      final reader = AggregatedBalanceReader(
        clientFactory: () => MockClient((request) async {
          final body = jsonDecode(request.body);
          expect(body['method'], 'eth_call');
          expect(body['params'][0]['to'], eth.contract);
          expect(
            body['params'][0]['data'],
            '0x70a08231${'1'.padLeft(64, '0')}',
          );
          return http.Response(jsonEncode({'result': '0x20000000000001'}), 200);
        }),
      );
      expect(await reader.read(eth, address), BigInt.parse('9007199254740993'));
    },
  );

  for (final payload in [
    null,
    {},
    {
      'error': {'code': -1},
    },
    {'result': '0x'},
    {'result': '-1'},
    {'result': '0x1${'0' * 64}'},
  ]) {
    test('invalid ERC20 payload fails: $payload', () async {
      final reader = AggregatedBalanceReader(
        clientFactory: () =>
            MockClient((_) async => http.Response(jsonEncode(payload), 200)),
      );
      await expectLater(reader.read(eth, address), throwsFormatException);
    });
  }
  test('ERC20 accepts the maximum uint256 balance exactly', () async {
    final reader = AggregatedBalanceReader(
      clientFactory: () => MockClient(
        (_) async =>
            http.Response(jsonEncode({'result': '0x${'f' * 64}'}), 200),
      ),
    );
    expect(await reader.read(eth, address), (BigInt.one << 256) - BigInt.one);
  });

  test('HTTP error with plausible balance is still rejected', () async {
    final reader = AggregatedBalanceReader(
      clientFactory: () =>
          MockClient((_) async => http.Response('{"result":"0x01"}', 503)),
    );
    await expectLater(reader.read(eth, address), throwsFormatException);
    await expectLater(reader.read(eth, 'wrong'), throwsFormatException);
  });
  test('SPL sums all mint accounts rather than only the first', () async {
    final reader = AggregatedBalanceReader(
      clientFactory: () => MockClient((request) async {
        final body = jsonDecode(request.body);
        expect(body['params'][1], {'mint': sol.contract});
        return http.Response(
          jsonEncode({
            'result': {
              'value': [account('a', '12'), account('b', '9007199254740993')],
            },
          }),
          200,
        );
      }),
    );
    expect(await reader.read(sol, 'owner'), BigInt.parse('9007199254741005'));
  });
  test('SPL empty account list is genuine zero', () async {
    final reader = AggregatedBalanceReader(
      clientFactory: () => MockClient(
        (_) async => http.Response('{"result":{"value":[]}}', 200),
      ),
    );
    expect(await reader.read(sol, 'owner'), BigInt.zero);
  });
  for (final invalid in ['mint', 'owner', 'decimals', 'amount', 'duplicate']) {
    test('SPL rejects $invalid mismatch without reporting zero', () async {
      final row = account('a', '12');
      final info = row['account']['data']['parsed']['info'];
      if (invalid == 'mint' || invalid == 'owner') info[invalid] = 'other';
      if (invalid == 'decimals') info['tokenAmount']['decimals'] = 18;
      if (invalid == 'amount') info['tokenAmount']['amount'] = '-1';
      final reader = AggregatedBalanceReader(
        clientFactory: () => MockClient(
          (_) async => http.Response(
            jsonEncode({
              'result': {
                'value': [row, if (invalid == 'duplicate') row],
              },
            }),
            200,
          ),
        ),
      );
      await expectLater(reader.read(sol, 'owner'), throwsFormatException);
    });
  }
  test(
    'TRON decodes and verifies Base58Check then removes the network byte',
    () async {
      final reader = AggregatedBalanceReader(
        clientFactory: () => MockClient((request) async {
          final body = jsonDecode(request.body);
          expect(request.url.path, '/wallet/triggerconstantcontract');
          expect(body['visible'], isTrue);
          expect(
            body['parameter'],
            '000000000000000000000000977c20977f412c2a1aa4ef3d49fee5ec4c31cdfb',
          );
          return http.Response(
            jsonEncode({
              'result': {'result': true},
              'constant_result': ['2a'.padLeft(64, '0')],
            }),
            200,
          );
        }),
      );
      expect(
        await reader.read(trx, 'TPnBjYQEMo4Yd4866KCzXdi4a169KGd63n'),
        BigInt.from(42),
      );
      await expectLater(
        reader.read(trx, 'TPnBjYQEMo4Yd4866KCzXdi4a169KGd63m'),
        throwsFormatException,
      );
    },
  );
  test('TRON execution failure cannot become a zero balance', () async {
    final reader = AggregatedBalanceReader(
      clientFactory: () => MockClient(
        (_) async => http.Response(
          '{"result":{"result":false},"constant_result":[]}',
          200,
        ),
      ),
    );
    await expectLater(
      reader.read(trx, 'TPnBjYQEMo4Yd4866KCzXdi4a169KGd63n'),
      throwsFormatException,
    );
  });
}
