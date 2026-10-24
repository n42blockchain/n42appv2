import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/eth_api.dart';
import 'package:n42_wallet/features/wallet/api/batch_transfer_api.dart';
import 'package:n42_wallet/features/wallet/models/batch_transfer_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final previous = HttpOverrides.current;
  setUpAll(() => HttpOverrides.global = null);
  tearDownAll(() => HttpOverrides.global = previous);
  test(
    '500 state-dependent RPC estimates preserve payload and never cap at 21000',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      var index = 0;
      server.listen((request) async {
        final body = jsonDecode(await utf8.decoder.bind(request).join()) as Map;
        final tx = (body['params'] as List).first as Map;
        expect(body['method'], 'eth_estimateGas');
        expect(tx.containsKey('gas'), isFalse);
        expect(tx['value'], '0x${index.toRadixString(16)}');
        expect(tx['data'], index.isEven ? '0x12345678' : null);
        final estimate = 12000 + index * 997;
        request.response.headers.contentType = ContentType.json;
        request.response.write(
          jsonEncode({
            'id': body['id'],
            'jsonrpc': '2.0',
            'result': '0x${estimate.toRadixString(16)}',
          }),
        );
        await request.response.close();
      });
      final api = EthAPI.init(null, 'http://127.0.0.1:${server.port}', null);
      for (index = 0; index < 500; index++) {
        final result = await api.getGasLimit(
          '0x${'11' * 20}',
          '0x${'22' * 20}',
          BigInt.one,
          BigInt.from(index),
          BigInt.from(21000),
          coinType: 'ETH',
          data: index.isEven ? '0x12345678' : '',
        );
        expect(result.error, isFalse);
        expect(result.data, BigInt.from(12000 + index * 997));
      }
    },
  );
  for (final result in [null, '0x0', '0x-1', '0xzz', '0x20000000000000']) {
    test('batch rejects missing or invalid estimate $result', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      server.listen((request) async {
        final body = jsonDecode(await utf8.decoder.bind(request).join());
        request.response.headers.contentType = ContentType.json;
        request.response.write(
          jsonEncode({'id': body['id'], 'jsonrpc': '2.0', 'result': result}),
        );
        await request.response.close();
      });
      final quote = await BatchTransferApi().estimateBatchGas(
        rpcUrl: 'http://127.0.0.1:${server.port}',
        chainSymbol: 'ETH',
        fromAddress: '0x${'11' * 20}',
        tokenAddress: null,
        items: [
          BatchTransferItem(
            id: 'one',
            toAddress: '0x${'22' * 20}',
            amount: BigInt.one,
          ),
        ],
      );
      expect(quote.error, isTrue);
      expect(quote.data, isNot(isA<BigInt>()));
    });
  }
}
