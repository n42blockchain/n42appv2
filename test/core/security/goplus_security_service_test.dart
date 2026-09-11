import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/security/goplus_security_result.dart';
import 'package:n42_wallet/core/security/goplus_security_service.dart';

String address(int n) => '0x${n.toRadixString(16).padLeft(40, '0')}';
Map<String, dynamic> response(String token, {bool danger = false}) => {
  'code': 1,
  'result': {
    token: {'is_open_source': '1', 'is_honeypot': danger ? '1' : '0'},
  },
};

void main() {
  late GoplusSecurityClient client;
  late DateTime now;
  late Future<dynamic> Function(int, String) request;
  late List<(int, String)> requests;
  setUp(() {
    now = DateTime.utc(2026, 9, 10);
    requests = [];
    request = (_, token) async => response(token);
    client = GoplusSecurityClient(
      now: () => now,
      request: (chain, token) {
        requests.add((chain, token));
        return request(chain, token);
      },
    );
  });

  test(
    'each supported chain maps to its own API id, case-insensitively',
    () async {
      for (final chain in {
        'ETH': 1,
        'BSC': 56,
        'MATIC': 137,
        'ARBITRUM': 42161,
        'OPTIMISM': 10,
        'AVAXC': 43114,
        'BASE': 8453,
        'FANTOM': 250,
        'CRONOS': 25,
        'GNOSIS': 100,
      }.entries) {
        expect(
          GoplusSecurityService.supportsChain(chain.key.toLowerCase()),
          isTrue,
        );
        expect(
          await client.checkToken(chain.key.toLowerCase(), address(1)),
          isNotNull,
        );
        expect(requests.last, (chain.value, address(1)));
      }
    },
  );

  test(
    'unsupported chains and malformed contract addresses make no request',
    () async {
      for (final chain in ['', 'SOL', 'TRX', 'BTC']) {
        expect(GoplusSecurityService.supportsChain(chain), isFalse);
        expect(await client.checkToken(chain, address(1)), isNull);
      }
      for (final token in [
        '',
        '0x1',
        '0x${'g' * 40}',
        ' ${address(1)}',
        '${address(1)}&extra=1',
      ]) {
        expect(await client.checkToken('ETH', token), isNull);
      }
      expect(requests, isEmpty);
      expect(await GoplusSecurityService.checkToken('SOL', address(1)), isNull);
      expect(await GoplusSecurityService.checkToken('ETH', ''), isNull);
    },
  );

  test(
    'case variants share the normalized contract cache and retain danger flags',
    () async {
      request = (_, token) async => response(token, danger: true);
      final token = address(0xabcdef);
      final first = await client.checkToken('ETH', token.toUpperCase());
      expect(first!.overallLevel, GoplusRiskLevel.danger);
      expect(requests, [(1, token)]);
      expect(await client.checkToken('eth', token), same(first));
      expect(requests, hasLength(1));
    },
  );

  test(
    'the same contract on another chain has a separate risk result',
    () async {
      request = (chain, token) async => response(token, danger: chain == 56);
      final eth = await client.checkToken('ETH', address(1));
      final bsc = await client.checkToken('BSC', address(1));
      expect(eth!.overallLevel, GoplusRiskLevel.safe);
      expect(bsc!.overallLevel, GoplusRiskLevel.danger);
      expect(requests, hasLength(2));
    },
  );

  test(
    'malformed, unsuccessful and empty responses remain unknown and are not cached',
    () async {
      for (final payload in <dynamic>[
        null,
        [],
        'offline',
        {'code': 0},
        {'code': '1'},
        {'code': 1},
        {'code': 1, 'result': []},
        {'code': 1, 'result': {}},
        {
          'code': 1,
          'result': {address(1): []},
        },
        {
          'code': 1,
          'result': {address(1): <String, dynamic>{}},
        },
      ]) {
        request = (_, _) async => payload;
        expect(await client.checkToken('ETH', address(1)), isNull);
      }
      expect(requests, hasLength(10));
      request = (_, token) async => response(token);
      expect(await client.checkToken('ETH', address(1)), isNotNull);
      expect(requests, hasLength(11));
    },
  );

  test(
    'a single unrelated contract cannot supply or poison this token risk cache',
    () async {
      request = (_, _) async => response(address(2));
      expect(await client.checkToken('ETH', address(1)), isNull);
      request = (_, token) async => response(token, danger: true);
      expect(
        (await client.checkToken('ETH', address(1)))!.overallLevel,
        GoplusRiskLevel.danger,
      );
      expect(requests, hasLength(2));
    },
  );

  test(
    'mixed-case matching ignores unrelated entries and rejects ambiguous duplicates',
    () async {
      final token = address(0xabcdef);
      request = (_, _) async => {
        'code': 1,
        'result': {
          address(2): {'is_honeypot': '0'},
          token.toUpperCase(): {'is_honeypot': '1'},
        },
      };
      expect(
        (await client.checkToken('ETH', token))!.overallLevel,
        GoplusRiskLevel.danger,
      );
      request = (_, _) async => {
        'code': 1,
        'result': {
          token: {'is_honeypot': '0'},
          token.toUpperCase(): {'is_honeypot': '1'},
        },
      };
      expect(await client.checkToken('BSC', token), isNull);
    },
  );

  test(
    'transport exceptions remain unknown and a subsequent request can recover',
    () async {
      request = (_, _) async => throw StateError('offline');
      expect(await client.checkToken('ETH', address(1)), isNull);
      request = (_, token) async => response(token);
      expect(await client.checkToken('ETH', address(1)), isNotNull);
      expect(requests, hasLength(2));
    },
  );

  test('five-minute cache expiry refreshes exactly at the boundary', () async {
    final first = await client.checkToken('ETH', address(1));
    now = now.add(const Duration(minutes: 5) - const Duration(milliseconds: 1));
    expect(await client.checkToken('ETH', address(1)), same(first));
    now = now.add(const Duration(milliseconds: 1));
    request = (_, token) async => response(token, danger: true);
    expect(
      (await client.checkToken('ETH', address(1)))!.overallLevel,
      GoplusRiskLevel.danger,
    );
    expect(requests, hasLength(2));
  });

  test(
    'concurrent case-equivalent requests share one transport result',
    () async {
      final pending = Completer<dynamic>();
      request = (_, _) => pending.future;
      final first = client.checkToken('ETH', address(0xabcd));
      final second = client.checkToken('eth', address(0xabcd).toUpperCase());
      expect(requests, hasLength(1));
      pending.complete(response(address(0xabcd), danger: true));
      expect(await first, same(await second));
    },
  );

  test(
    'failed shared requests release their in-flight entry for retry',
    () async {
      final pending = Completer<dynamic>();
      request = (_, _) => pending.future;
      final first = client.checkToken('ETH', address(1));
      final second = client.checkToken('ETH', address(1));
      pending.completeError(StateError('offline'));
      expect(await first, isNull);
      expect(await second, isNull);
      request = (_, token) async => response(token);
      expect(await client.checkToken('ETH', address(1)), isNotNull);
      expect(requests, hasLength(2));
    },
  );

  test(
    'capacity eviction removes the oldest quarter while retaining recent results',
    () async {
      for (var i = 1; i <= 201; i++) {
        await client.checkToken('ETH', address(i));
      }
      expect(requests, hasLength(201));
      await client.checkToken('ETH', address(200));
      expect(requests, hasLength(201));
      await client.checkToken('ETH', address(1));
      expect(requests, hasLength(202));
      await client.checkToken('ETH', address(51));
      expect(requests, hasLength(202));
    },
  );

  test('expired entries are purged before capacity eviction', () async {
    for (var i = 1; i <= 200; i++) {
      await client.checkToken('ETH', address(i));
    }
    now = now.add(const Duration(minutes: 6));
    for (var i = 201; i <= 400; i++) {
      await client.checkToken('ETH', address(i));
    }
    await client.checkToken('ETH', address(201));
    expect(requests, hasLength(400));
    await client.checkToken('ETH', address(200));
    expect(requests, hasLength(401));
  });

  test(
    'independent clients cannot share stale transport or cache results',
    () async {
      await client.checkToken('ETH', address(1));
      final other = GoplusSecurityClient(
        request: (_, token) async => response(token, danger: true),
      );
      expect(
        (await other.checkToken('ETH', address(1)))!.overallLevel,
        GoplusRiskLevel.danger,
      );
      expect(
        (await client.checkToken('ETH', address(1)))!.overallLevel,
        GoplusRiskLevel.safe,
      );
    },
  );
}
