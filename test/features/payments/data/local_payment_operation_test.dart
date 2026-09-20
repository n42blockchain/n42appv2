import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:n42_wallet/features/payments/data/local_payment_client.dart';

void main() {
  final id = 'transfer_${'a' * 64}';
  Map<String, dynamic> receipt() => {
    'mode': 'localSimulation',
    'id': id,
    'asset': 'test-usdc',
    'amount': '10',
    'recipient': 'b',
  };
  LocalPaymentClient client(
    FutureOr<http.Response> Function(http.Request) handler,
  ) => LocalPaymentClient(
    endpoint: Uri.parse('http://127.0.0.1:8765'),
    transport: MockClient((r) async => handler(r)),
    enabled: true,
  )..activateTestAccount('synthetic-test-accounta');
  test(
    'known operation lookup only reads and validates its identity',
    () async {
      final c = client((r) {
        expect(r.method, 'GET');
        expect(r.url.path, '/operations/$id');
        expect(r.body, isEmpty);
        expect(r.headers['Authorization'], 'Bearer synthetic-test-accounta');
        return http.Response(jsonEncode(receipt()), 200);
      });
      expect(await c.operation(id), receipt());
    },
  );
  test('foreign and unknown operation errors do not reveal receipt', () async {
    final c = client(
      (_) => http.Response(
        jsonEncode({
          'mode': 'localSimulation',
          'error': {'code': 'not_found'},
        }),
        404,
      ),
    );
    await expectLater(
      c.operation(id),
      throwsA(
        isA<LocalPaymentException>().having((e) => e.code, 'code', 'not_found'),
      ),
    );
  });
  test('malformed IDs never invoke transport', () async {
    var calls = 0;
    final c = client((_) {
      calls++;
      return http.Response('{}', 200);
    });
    for (final invalid in [
      'seed_${'a' * 64}',
      '../balances',
      'transfer_short',
    ]) {
      await expectLater(c.operation(invalid), throwsArgumentError);
    }
    expect(calls, 0);
  });
  test('receipt with wrong ID or missing amount is not accepted', () async {
    for (final bad in [
      receipt()..['id'] = 'refund_${'b' * 64}',
      receipt()..remove('amount'),
    ]) {
      final c = client((_) => http.Response(jsonEncode(bad), 200));
      await expectLater(c.operation(id), throwsA(isA<LocalPaymentException>()));
    }
  });
  test('account switch discards an in-flight receipt query', () async {
    final pending = Completer<http.Response>();
    final c = client((_) => pending.future);
    final check = expectLater(
      c.operation(id),
      throwsA(
        isA<LocalPaymentException>().having(
          (e) => e.code,
          'code',
          'account_changed',
        ),
      ),
    );
    c.activateTestAccount('synthetic-test-accountb');
    pending.complete(http.Response(jsonEncode(receipt()), 200));
    await check;
  });
}
