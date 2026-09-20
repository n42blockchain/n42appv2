import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:n42_wallet/features/payments/data/local_payment_client.dart';

void main() {
  final receipt = {
    'mode': 'localSimulation',
    'id': 'transfer_${'a' * 64}',
    'asset': 'test-usdc',
    'amount': '10',
    'recipient': 'b',
  };
  http.Response response(Map<String, dynamic> fields) =>
      http.Response(jsonEncode({'mode': 'localSimulation', ...fields}), 200);
  LocalPaymentClient client(
    FutureOr<http.Response> Function(http.Request) handler,
  ) => LocalPaymentClient(
    endpoint: Uri.parse('http://127.0.0.1:8765'),
    transport: MockClient((r) async => handler(r)),
    enabled: true,
  )..activateTestAccount('synthetic-test-accounta');
  test('key query encodes reserved characters without resubmitting', () async {
    const key = 'original/a?b%#';
    final c = client((r) {
      expect(r.method, 'GET');
      expect(r.url.pathSegments, ['requests', key]);
      expect(r.url.query, isEmpty);
      return response({'status': 'completed', 'receipt': receipt});
    });
    final result = await c.recoverRequest(key);
    expect(result.isCompleted, isTrue);
    expect(result.receipt, receipt);
    expect(() => result.receipt!['amount'] = '20', throwsUnsupportedError);
  });
  test('unresolved is distinct from completion and does not retry', () async {
    var calls = 0;
    final c = client((r) {
      calls++;
      expect(r.method, 'GET');
      return response({'status': 'unresolved'});
    });
    final result = await c.recoverRequest('k');
    expect(result.isCompleted, isFalse);
    expect(result.receipt, isNull);
    expect(calls, 1);
  });
  test('malformed and foreign nested receipts fail closed', () async {
    for (final bad in [
      {'status': 'completed'},
      {'status': 'paid', 'receipt': receipt},
      {
        'status': 'completed',
        'receipt': {...receipt, 'mode': 'production'},
      },
      {
        'status': 'completed',
        'receipt': {...receipt, 'amount': 10},
      },
      {'status': 'unresolved', 'receipt': receipt},
    ]) {
      final c = client((_) => response(bad));
      await expectLater(
        c.recoverRequest('k'),
        throwsA(isA<LocalPaymentException>()),
      );
    }
  });
  test('claim recovery validates packet and amount', () async {
    final c = client(
      (_) => response({
        'status': 'completed',
        'receipt': {
          'mode': 'localSimulation',
          'packet': 'packet_${'b' * 64}',
          'asset': 'a',
          'amount': '20',
        },
      }),
    );
    expect((await c.recoverRequest('claim')).receipt!['amount'], '20');
  });
  test('switching accounts drops a delayed recovery response', () async {
    final pending = Completer<http.Response>();
    final c = client((_) => pending.future);
    final check = expectLater(
      c.recoverRequest('k'),
      throwsA(
        isA<LocalPaymentException>().having(
          (e) => e.code,
          'code',
          'account_changed',
        ),
      ),
    );
    c.activateTestAccount('synthetic-test-accountb');
    pending.complete(response({'status': 'completed', 'receipt': receipt}));
    await check;
  });
}
