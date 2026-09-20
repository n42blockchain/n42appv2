import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:n42_wallet/features/payments/data/local_payment_client.dart';

void main() {
  http.Response response(Map<String, dynamic> data, [int status = 200]) =>
      http.Response(jsonEncode({'mode': 'localSimulation', ...data}), status);
  LocalPaymentClient client(
    FutureOr<http.Response> Function(http.Request) handler, {
    bool enabled = true,
    Duration timeout = const Duration(seconds: 2),
  }) => LocalPaymentClient(
    endpoint: Uri.parse('http://127.0.0.1:8765'),
    transport: MockClient((request) async => handler(request)),
    enabled: enabled,
    timeout: timeout,
  );
  Matcher code(String value) =>
      isA<LocalPaymentException>().having((e) => e.code, 'code', value);

  test('disabled and missing account never reach transport', () async {
    var calls = 0;
    final disabled = client((_) {
      calls++;
      return response({});
    }, enabled: false);
    expect(
      () => disabled.activateTestAccount('synthetic-test-accounta'),
      throwsA(code('disabled')),
    );
    await expectLater(disabled.balance('asset'), throwsA(code('disabled')));
    final missing = client((_) {
      calls++;
      return response({});
    });
    await expectLater(
      missing.balance('asset'),
      throwsA(code('account_required')),
    );
    expect(calls, 0);
  });
  test('remote endpoints credentials and real tokens are rejected', () {
    for (final uri in [
      'https://127.0.0.1',
      'http://localhost',
      'http://example.com',
      'http://u:p@127.0.0.1',
      'http://127.0.0.1/api',
      'http://127.0.0.1?x=1',
    ]) {
      expect(
        () => LocalPaymentClient(
          endpoint: Uri.parse(uri),
          transport: MockClient((_) async => response({})),
        ),
        throwsArgumentError,
      );
    }
    final c = client((_) => response({}));
    expect(() => c.activateTestAccount('real-token'), throwsArgumentError);
  });
  test(
    'transfer preserves exact units, idempotency key and account auth',
    () async {
      final c = client((request) {
        expect(request.followRedirects, isFalse);
        expect(request.url.path, '/transfers');
        expect(
          request.headers['Authorization'],
          'Bearer synthetic-test-accounta',
        );
        expect(request.headers['Idempotency-Key'], 'transfer-1');
        expect(jsonDecode(request.body), {
          'recipient': 'b',
          'asset': 'test-asset',
          'amount': '9000000000000000',
        });
        return response({
          'amount': '9000000000000000',
          'asset': 'test-asset',
          'recipient': 'b',
          'id': 'transfer_${'a' * 64}',
        });
      })..activateTestAccount('synthetic-test-accounta');
      final receipt = await c.transfer(
        recipient: 'b',
        asset: 'test-asset',
        amount: BigInt.parse('9000000000000000'),
        key: 'transfer-1',
      );
      expect(receipt['amount'], '9000000000000000');
      expect(() => receipt['amount'] = '1', throwsUnsupportedError);
    },
  );
  test(
    'switching accounts rejects old success and uses new account token',
    () async {
      final pending = Completer<http.Response>();
      var calls = 0;
      final c = client((request) {
        calls++;
        if (calls == 1) return pending.future;
        expect(
          request.headers['Authorization'],
          'Bearer synthetic-test-accountb',
        );
        return response({'asset': 'a', 'available': '2'});
      })..activateTestAccount('synthetic-test-accounta');
      final old = c.balance('a');
      final check = expectLater(old, throwsA(code('account_changed')));
      c.activateTestAccount('synthetic-test-accountb');
      pending.complete(response({'asset': 'a', 'available': '99'}));
      await check;
      expect(await c.balance('a'), BigInt.two);
    },
  );
  test('logout invalidates delayed error and blocks later requests', () async {
    final pending = Completer<http.Response>();
    final c = client((_) => pending.future)
      ..activateTestAccount('synthetic-test-accounta');
    final check = expectLater(c.balance('a'), throwsA(code('account_changed')));
    c.clearAccount();
    pending.complete(
      response({
        'error': {'code': 'unauthorized'},
      }, 401),
    );
    await check;
    await expectLater(c.balance('a'), throwsA(code('account_required')));
  });
  test(
    'rejects foreign mode, wrong asset and imprecise numeric response',
    () async {
      for (final data in [
        {'mode': 'production', 'asset': 'a', 'available': '1'},
        {'asset': 'b', 'available': '1'},
        {'asset': 'a', 'available': 1},
        {'asset': 'a', 'available': '1e6'},
        {'asset': 'a', 'available': '01'},
      ]) {
        final c = client((_) => response(data))
          ..activateTestAccount('synthetic-test-accounta');
        await expectLater(c.balance('a'), throwsA(code('invalid_response')));
      }
    },
  );
  test(
    'server and network errors never echo sensitive response text',
    () async {
      final c = client(
        (_) => response({
          'error': {'code': 'conflict', 'message': 'private-data'},
        }, 409),
      )..activateTestAccount('synthetic-test-accounta');
      await expectLater(c.balance('a'), throwsA(code('conflict')));
      final broken = client((_) => throw Exception('secret'))
        ..activateTestAccount('synthetic-test-accounta');
      await expectLater(broken.balance('a'), throwsA(code('transport_error')));
    },
  );
  test('timeout does not retry a potentially accepted transfer', () async {
    var calls = 0;
    final pending = Completer<http.Response>();
    final c = client(
      (_) {
        calls++;
        return pending.future;
      },
      timeout: const Duration(milliseconds: 10),
    )..activateTestAccount('synthetic-test-accounta');
    await expectLater(
      c.transfer(recipient: 'b', asset: 'a', amount: BigInt.one, key: 't'),
      throwsA(code('transport_error')),
    );
    expect(calls, 1);
    pending.complete(response({'amount': '1'}));
  });
  test(
    'packet request sends integer strings and claim paths are constrained',
    () async {
      final c = client((r) {
        final body = jsonDecode(r.body);
        expect(body['total'], '60');
        expect(body['slots'], '3');
        expect(body['expiresAt'], '100');
        return response({
          'id': 'packet_${'a' * 64}',
          'asset': 'a',
          'total': '60',
          'slots': '3',
          'expiresAt': '100',
        });
      })..activateTestAccount('synthetic-test-accounta');
      await c.createPacket(
        room: 'r',
        asset: 'a',
        total: BigInt.from(60),
        slots: 3,
        expiresAt: DateTime.fromMillisecondsSinceEpoch(100000),
        key: 'p',
      );
      expect(() => c.claim('../transfers', key: 'x'), throwsArgumentError);
      c.close();
      await expectLater(c.balance('a'), throwsA(code('disabled')));
    },
  );
  test('incomplete or mismatched transfer receipts are rejected', () async {
    for (final data in [
      <String, dynamic>{},
      {'id': 't', 'asset': 'wrong', 'recipient': 'b', 'amount': '1'},
    ]) {
      final c = client((_) => response(data))
        ..activateTestAccount('synthetic-test-accounta');
      await expectLater(
        c.transfer(recipient: 'b', asset: 'a', amount: BigInt.one, key: 'k'),
        throwsA(code('invalid_response')),
      );
    }
  });
  test(
    'redirects and oversized responses never become successful balances',
    () async {
      for (final reply in [
        response({'asset': 'a', 'available': '1'}, 302),
        http.Response('x' * 65537, 200),
      ]) {
        final c = client((_) => reply)
          ..activateTestAccount('synthetic-test-accounta');
        await expectLater(
          c.balance('a'),
          throwsA(isA<LocalPaymentException>()),
        );
      }
    },
  );
  test('packet receipt must be usable by the claim endpoint', () async {
    final c = client(
      (_) => response({
        'id': 'p',
        'asset': 'a',
        'total': '60',
        'slots': '3',
        'expiresAt': '100',
      }),
    )..activateTestAccount('synthetic-test-accounta');
    await expectLater(
      c.createPacket(
        room: 'r',
        asset: 'a',
        total: BigInt.from(60),
        slots: 3,
        expiresAt: DateTime.fromMillisecondsSinceEpoch(100000),
        key: 'p',
      ),
      throwsA(code('invalid_response')),
    );
  });
  test(
    'local amount upper bound rejects requests and responses beyond server limit',
    () async {
      var calls = 0;
      final c = client((_) {
        calls++;
        return response({'asset': 'a', 'available': '9000000000000001'});
      })..activateTestAccount('synthetic-test-accounta');
      expect(
        () => c.transfer(
          recipient: 'b',
          asset: 'a',
          amount: BigInt.parse('9000000000000001'),
          key: 'k',
        ),
        throwsArgumentError,
      );
      expect(calls, 0);
      await expectLater(c.balance('a'), throwsA(code('invalid_response')));
    },
  );
}
