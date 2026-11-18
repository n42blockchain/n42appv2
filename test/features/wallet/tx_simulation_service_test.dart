import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/network/request_url.dart';
import 'package:n42_wallet/core/security/tx_simulation_result.dart';
import 'package:n42_wallet/features/wallet/services/tx_simulation_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const coin = 'SIMULATION_FIXTURE';
  const address = '0x0000000000000000000000000000000000000001';
  final endpoints = RequestUrl().requestUrlTest1;
  final originalOverrides = HttpOverrides.current;

  setUpAll(() => HttpOverrides.global = null);
  tearDownAll(() => HttpOverrides.global = originalOverrides);

  for (final response in <String, Map<String, Object?>>{
    'missing result': {},
    'null result': {'result': null},
    'non-hex result': {'result': 'unavailable'},
    'incomplete hex byte': {'result': '0x1'},
    'valid empty bytes': {'result': '0x'},
    'valid return bytes': {'result': '0x01'},
  }.entries) {
    test('simulation handles ${response.key}', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      endpoints[coin] = {'rpc': 'http://127.0.0.1:${server.port}'};
      addTearDown(() async {
        endpoints.remove(coin);
        await server.close(force: true);
      });
      final methods = <String>[];
      server.listen((request) async {
        final data = jsonDecode(await utf8.decoder.bind(request).join()) as Map;
        final method = data['method'] as String;
        methods.add(method);
        request.response.headers.contentType = ContentType.json;
        request.response.write(
          jsonEncode({
            'jsonrpc': '2.0',
            'id': data['id'],
            if (method == 'eth_call') ...response.value else 'result': '0x5208',
          }),
        );
        await request.response.close();
      });

      final result = await TxSimulationService.simulate(
        coinType: coin,
        from: address,
        to: address,
        isTest: true,
      );
      final valid = response.key.startsWith('valid');
      expect(
        result.status,
        valid ? TxSimStatus.success : TxSimStatus.unavailable,
      );
      expect(methods, ['eth_call', if (valid) 'eth_estimateGas']);
    });
  }
}
