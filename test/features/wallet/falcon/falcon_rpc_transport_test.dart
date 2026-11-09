import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/falcon/falcon_network.dart';

void main() {
  for (final scenario in [
    'unsupported',
    'other method',
    'wrong id',
    'other error',
  ]) {
    test('Falcon RPC transport distinguishes $scenario', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      final requestHandled = server.first.then((request) async {
        final body = jsonDecode(await utf8.decoder.bind(request).join()) as Map;
        request.response.headers.contentType = ContentType.json;
        request.response.write(
          jsonEncode({
            'jsonrpc': '2.0',
            'id': scenario == 'wrong id' ? -1 : body['id'],
            'error': {
              'code': scenario == 'other error' ? -32603 : -32601,
              'message': 'Method unavailable',
            },
          }),
        );
        await request.response.close();
      });
      final network = FalconNetwork.endpoint('http://127.0.0.1:${server.port}');
      await expectLater(
        network.rpc(
          scenario == 'other method' ? 'eth_chainId' : 'n42_getPQCapabilities',
          [],
        ),
        scenario == 'unsupported'
            ? throwsA(isA<FalconNetworkNotEnabled>())
            : throwsA(
                isA<StateError>().having(
                  (e) => e is FalconNetworkNotEnabled,
                  'unsupported capability',
                  false,
                ),
              ),
      );
      await requestHandled;
    });
  }
}
