import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/api_hub/datasources/defillama_datasource.dart';
import 'package:n42_wallet/core/api_hub/models/defi_protocol.dart';

DefiProtocol _protocol(String id, double tvl) {
  return DefiProtocol(id: id, name: 'Protocol $id', tvl: tvl);
}

DefiYield _yield(String pool, double tvlUsd) {
  return DefiYield(
    pool: pool,
    project: 'Project $pool',
    chain: 'Ethereum',
    symbol: 'ETH',
    tvlUsd: tvlUsd,
  );
}

void main() {
  group('DefiLlamaDatasource.parseProtocolsResponse', () {
    test('returns fallback when response is invalid', () {
      final fallback = [_protocol('cached', 42)];

      final result = DefiLlamaDatasource.parseProtocolsResponse({
        'unexpected': true,
      }, fallback: fallback);

      expect(result, same(fallback));
    });

    test('filters invalid items and sorts by TVL descending', () {
      final result = DefiLlamaDatasource.parseProtocolsResponse([
        {
          'slug': 'small',
          'name': 'Small',
          'tvl': 10,
          'chains': ['Base'],
        },
        {
          'slug': 'big',
          'name': 'Big',
          'tvl': 99,
          'chains': ['Ethereum', '', 1],
        },
        {'slug': 'invalid', 'name': '', 'tvl': 1000},
      ]);

      expect(result.map((item) => item.id), ['big', 'small']);
      expect(result.first.chains, ['Ethereum']);
    });
  });

  group('DefiLlamaDatasource.parseYieldsResponse', () {
    test('returns fallback when parsed yields are empty', () {
      final fallback = [_yield('cached', 123)];

      final result = DefiLlamaDatasource.parseYieldsResponse({
        'data': [
          {'pool': 'invalid', 'tvlUsd': 0},
        ],
      }, fallback: fallback);

      expect(result, same(fallback));
    });

    test('filters invalid rows and sorts by TVL descending', () {
      final result = DefiLlamaDatasource.parseYieldsResponse({
        'data': [
          {
            'pool': 'small',
            'project': 'Small',
            'chain': 'Base',
            'symbol': 'ETH',
            'tvlUsd': 5,
            'apy': 1.2,
          },
          {
            'pool': 'big',
            'project': 'Big',
            'chain': 'Ethereum',
            'symbol': 'USDC',
            'tvlUsd': 50,
            'apy': 2.3,
          },
          {'pool': 'invalid', 'project': 'Invalid', 'tvlUsd': -1},
        ],
      });

      expect(result.map((item) => item.pool), ['big', 'small']);
      expect(result.first.apy, 2.3);
    });
  });
}
