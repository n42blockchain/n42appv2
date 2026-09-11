import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/evm_sender.dart';
import 'package:n42_wallet/generated/l10n.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final previousHttpOverrides = HttpOverrides.current;
  setUpAll(() => HttpOverrides.global = null);
  tearDownAll(() => HttpOverrides.global = previousHttpOverrides);
  setUpAll(() async => S.load(const Locale('en')));

  for (final contract in ['', '0x0000000000000000000000000000000000000003']) {
    test(
      'reserves the replacement tip before signing ${contract.isEmpty ? 'native' : 'token'} sends',
      () async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        addTearDown(() => server.close(force: true));
        final calls = <String>[];
        String? estimatedPrice;
        server.listen((request) async {
          final body =
              jsonDecode(await utf8.decoder.bind(request).join())
                  as Map<String, dynamic>;
          final method = body['method'] as String;
          calls.add(method);
          if (method == 'eth_estimateGas') {
            estimatedPrice =
                (body['params'] as List).first['maxFeePerGas'] as String?;
          }
          final result = switch (method) {
            'eth_getBalance' => '0x3e8',
            'eth_call' =>
              '0x${BigInt.from(1000).toRadixString(16).padLeft(64, '0')}',
            'eth_gasPrice' => '0x1',
            'eth_estimateGas' => '0x15',
            _ => '0x0',
          };
          request.response.headers.contentType = ContentType.json;
          request.response.write(
            jsonEncode({'jsonrpc': '2.0', 'id': body['id'], 'result': result}),
          );
          await request.response.close();
        });
        final sender = EvmSender();
        final result = await sender.send(
          SendParams(
            coinType: 'ETH',
            fromAddress: '0x0000000000000000000000000000000000000001',
            toAddress: '0x0000000000000000000000000000000000000002',
            amount: 1,
            decimals: 0,
            tokenDecimals: 0,
            path: '',
            contractAddress: contract,
            chainConfig: {
              'chainId': 1,
              'service': 'http://127.0.0.1:${server.port}',
            },
            tipOverride: BigInt.from(100),
          ),
        );

        // The old cap of 2 reserved only 52; the signed cap of 100 costs 2600.
        expect(estimatedPrice, '0x64');
        expect(result.success, isFalse);
        expect(result.error, S.current.g_key_wallet_m5('ETH'));
        expect(calls, isNot(contains('eth_getTransactionCount')));
        expect(calls, isNot(contains('eth_sendRawTransaction')));
      },
    );
  }
}
