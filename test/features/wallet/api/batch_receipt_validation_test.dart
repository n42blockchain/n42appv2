import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:n42_wallet/features/wallet/api/batch_transfer_api.dart';

void main() {
  final hash = '0x${'ab' * 32}';
  Map<String, dynamic> receipt() => {
    'transactionHash': hash,
    'blockHash': '0x${'cd' * 32}',
    'blockNumber': '0x1',
    'status': '0x1',
  };
  for (final status in ['0x0', '0x1']) {
    test('returns a matching mined receipt with status $status', () async {
      final result = await BatchTransferApi.waitForReceipt(
        'https://rpc.invalid',
        hash,
        maxAttempts: 1,
        intervalMs: 0,
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'jsonrpc': '2.0',
              'id': 1,
              'result': receipt()..['status'] = status,
            }),
            200,
          ),
        ),
      );
      expect(result?['status'], status);
    });
  }
  for (final mutation in [
    'wrongHash',
    'missingBlock',
    'invalidStatus',
    'wrongId',
    'rpcError',
    'httpError',
  ]) {
    test(
      '$mutation remains unknown rather than successful or reverted',
      () async {
        final value = receipt();
        final envelope = <String, dynamic>{
          'jsonrpc': '2.0',
          'id': 1,
          'result': value,
        };
        if (mutation == 'wrongHash') {
          value['transactionHash'] = '0x${'00' * 32}';
        }
        if (mutation == 'missingBlock') value.remove('blockHash');
        if (mutation == 'invalidStatus') value['status'] = '0x2';
        if (mutation == 'wrongId') envelope['id'] = 2;
        if (mutation == 'rpcError') envelope['error'] = {'code': -1};
        final result = await BatchTransferApi.waitForReceipt(
          'https://rpc.invalid',
          hash,
          maxAttempts: 1,
          intervalMs: 0,
          client: MockClient(
            (_) async => http.Response(
              jsonEncode(envelope),
              mutation == 'httpError' ? 500 : 200,
            ),
          ),
        );
        expect(result, isNull);
      },
    );
  }
}
