import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/ada_api.dart';

Map<String, dynamic> utxo(int id) => {
  'tx_hash': id.toRadixString(16).padLeft(64, '0'),
  'output_index': 0,
  'address': 'addr_owner',
  'amount': [
    {'unit': 'lovelace', 'quantity': '1000000'},
  ],
};

void main() {
  for (final change in ['hash', 'height', 'slot', 'offline', 'malformed']) {
    test(
      'changed or unavailable closing tip ($change) discards disjoint pages',
      () async {
        var tips = 0;
        var pages = 0;
        final urls = <String>[];
        final api = AdaApi(
          projectId: 'fixture',
          readChainTip: (url, header) async {
            urls.add(url);
            expect(header['project_id'], 'fixture');
            tips++;
            final tip = <String, dynamic>{
              'hash': 'ab' * 32,
              'height': 100,
              'slot': 100000,
            };
            if (tips == 2) {
              if (change == 'offline') throw const SocketException('offline');
              if (change == 'malformed') return {'hash': 'ab' * 32};
              tip[change] = change == 'hash'
                  ? 'cd' * 32
                  : (tip[change] as int) + 1;
            }
            return tip;
          },
          readUtxoPage: (url, query, header) async {
            pages++;
            return pages == 1
                ? [for (var i = 0; i < 100; i++) utxo(i)]
                : [utxo(101)];
          },
        );
        final result = await api.getAddressUtxos('addr_owner', isTest: true);
        expect(result.error, isTrue);
        expect(result.data, isNot(isA<List>()));
        expect(pages, 2);
        expect(tips, 2);
        expect(urls.toSet(), hasLength(1));
        expect(urls.first, endsWith('/blocks/latest'));
      },
    );
  }
  for (final malformed in [
    null,
    {},
    {'hash': 'ab' * 32, 'height': -1, 'slot': 2},
    {'hash': 'ab' * 32, 'height': 1, 'slot': '2'},
    {'hash': 'invalid', 'height': 1, 'slot': 2},
  ]) {
    test('malformed opening tip $malformed stops before page reads', () async {
      var pages = 0;
      final api = AdaApi(
        projectId: 'fixture',
        readChainTip: (_, _) async => malformed,
        readUtxoPage: (_, _, _) async {
          pages++;
          return [];
        },
      );
      expect((await api.getAddressUtxos('addr_owner')).error, isTrue);
      expect(pages, 0);
    });
  }
  for (final total in [0, 1, 99, 100, 101, 200, 201]) {
    test(
      'returns all $total inputs with stable query and credentials',
      () async {
        final pages = <int>[];
        final urls = <String>[];
        final api = AdaApi(
          readChainTip: (_, _) async => {
            'hash': 'ab' * 32,
            'height': 100,
            'slot': 100000,
          },
          projectId: 'fixture-project',
          readUtxoPage: (url, query, header) async {
            urls.add(url);
            final page = query['page'] as int;
            pages.add(page);
            expect(query['count'], 100);
            expect(query['order'], 'asc');
            expect(header['project_id'], 'fixture-project');
            final start = (page - 1) * 100;
            return [
              for (var i = start; i < total && i < start + 100; i++) utxo(i),
            ];
          },
        );
        final result = await api.getAddressUtxos('addr_owner', isTest: true);
        expect(result.error, isFalse);
        expect(result.data, [for (var i = 0; i < total; i++) utxo(i)]);
        expect(pages, [for (var i = 1; i <= total ~/ 100 + 1; i++) i]);
        expect(urls.toSet(), hasLength(1));
        expect(urls.first, endsWith('/addresses/addr_owner/utxos'));
      },
    );
  }
  for (final scenario in [
    'offline',
    'not list',
    'bad item',
    'duplicate',
    'oversize',
  ]) {
    test('$scenario on later page discards the partial scan', () async {
      var calls = 0;
      final api = AdaApi(
        readChainTip: (_, _) async => {
          'hash': 'ab' * 32,
          'height': 100,
          'slot': 100000,
        },
        projectId: 'fixture',
        readUtxoPage: (url, query, header) async {
          calls++;
          if (calls == 1) return [for (var i = 0; i < 100; i++) utxo(i)];
          return switch (scenario) {
            'offline' => throw const SocketException('offline'),
            'not list' => {'error': 'unavailable'},
            'bad item' => ['bad'],
            'duplicate' => [utxo(0)..['tx_hash'] = '0' * 64],
            _ => [for (var i = 100; i < 201; i++) utxo(i)],
          };
        },
      );
      final result = await api.getAddressUtxos('addr_owner');
      expect(result.error, isTrue);
      expect(result.data, isNot(isA<List>()));
      expect(calls, 2);
    });
  }
  test('bounded scan does not return a truncated success', () async {
    var calls = 0;
    final api = AdaApi(
      readChainTip: (_, _) async => {
        'hash': 'ab' * 32,
        'height': 100,
        'slot': 100000,
      },
      projectId: 'fixture',
      readUtxoPage: (url, query, header) async {
        final start = calls++ * 100;
        return [for (var i = start; i < start + 100; i++) utxo(i)];
      },
    );
    final result = await api.getAddressUtxos('addr_owner');
    expect(result.error, isTrue);
    expect(calls, 100);
    expect(result.data.toString(), contains('complete input set unavailable'));
  });
  for (final index in [-1, 1.5, true, '1', 4294967296]) {
    test('malformed outpoint index $index fails', () async {
      final api = AdaApi(
        readChainTip: (_, _) async => {
          'hash': 'ab' * 32,
          'height': 100,
          'slot': 100000,
        },
        projectId: 'fixture',
        readUtxoPage: (_, _, _) async => [utxo(0)..['output_index'] = index],
      );
      expect((await api.getAddressUtxos('addr_owner')).error, isTrue);
    });
  }
}
