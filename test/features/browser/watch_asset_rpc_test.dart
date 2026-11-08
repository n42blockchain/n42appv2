import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/browser/handler/dapp_request_handler.dart';
import 'package:n42_wallet/features/browser/models/watch_asset_request.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late HttpServer server;
  late DAppRequestHandler handler;
  late CoinModel polygon;
  HttpOverrides? previous;
  late List<(String, String)> requests;
  Future<void> Function()? gate;
  bool large = false;
  String rpc(String path) => 'http://127.0.0.1:${server.port}$path';
  WatchAssetRequest asset() => WatchAssetRequest.parse(
    [
      {
        'type': 'ERC20',
        'options': {
          'address': '0x52908400098527886E0F7030069857D2E4169EE7',
          'chainId': 137,
        },
      },
    ],
    1,
    supportedChainIds: {1, 137},
  );
  Matcher code(int code) =>
      throwsA(isA<Map>().having((e) => e['code'], 'code', code));

  setUp(() async {
    previous = HttpOverrides.current;
    HttpOverrides.global = null;
    requests = [];
    gate = null;
    large = false;
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      try {
        final input =
            jsonDecode(await utf8.decoder.bind(request).join()) as Map;
        final method = input['method'] as String;
        requests.add((request.uri.path, method));
        await gate?.call();
        if (request.uri.path == '/redirect') {
          request.response.statusCode = 302;
          request.response.headers.set('location', rpc('/capture'));
        } else {
          final params = input['params'] as List;
          final dynamic result = switch (method) {
            'eth_chainId' => request.uri.path == '/polygon' ? '0x89' : '0x1',
            'eth_getCode' => '0x6000',
            _ =>
              (params.first as Map)['data'] == '0x95d89b41'
                  ? (large
                        ? '0x${'ab' * 1100000}'
                        : '0x414243${''.padRight(58, '0')}')
                  : '0x${'12'.padLeft(64, '0')}',
          };
          request.response.headers.contentType = ContentType.json;
          request.response.write(
            jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': result}),
          );
        }
        await request.response.close();
      } catch (_) {
        try {
          await request.response.close();
        } catch (_) {}
      }
    });
    final ethereum = CoinModel()
      ..isTest = false
      ..coin = {'chainId': 1, 'service': rpc('/ethereum')};
    polygon = CoinModel()
      ..isTest = false
      ..coin = {'chainId': 137, 'service': rpc('/polygon')};
    handler = DAppRequestHandler(ethCoinModels: [ethereum, polygon]);
  });
  tearDown(() async {
    handler.dispose();
    await server.close(force: true);
    HttpOverrides.global = previous;
  });

  test('metadata uses the requested network RPC without switching the active chain', () async {
    final result = await handler.loadAssetMetadata(
      asset(),
      validateRequest: () {},
    );
    expect(result.symbol, 'ABC');
    expect(result.decimals, 18);
    expect(handler.chainIdInt, 1);
    expect(requests.map((e) => e.$1).toSet(), {'/polygon'});
    expect(requests.map((e) => e.$2), [
      'eth_chainId',
      'eth_getCode',
      'eth_call',
      'eth_call',
    ]);
  });
  test(
    'changing the target RPC during a pending read stops all further requests',
    () async {
      final entered = Completer<void>();
      final release = Completer<void>();
      gate = () async {
        entered.complete();
        await release.future;
      };
      final pending = handler.loadAssetMetadata(
        asset(),
        validateRequest: () {},
      );
      await entered.future;
      polygon.coin['service'] = rpc('/replacement');
      release.complete();
      await expectLater(pending, code(4001));
      expect(requests.length, 1);
    },
  );
  test('metadata response size is bounded', () async {
    large = true;
    await expectLater(
      handler.loadAssetMetadata(asset(), validateRequest: () {}),
      code(-32603),
    );
    expect(requests.length, 3);
  });
  test('transport errors never reveal configured RPC secrets', () async {
    polygon.coin['service'] = 'http://[fake-secret';
    await expectLater(
      handler.loadAssetMetadata(asset(), validateRequest: () {}),
      throwsA(
        isA<Map>().having(
          (e) => e['message'],
          'message',
          'Unable to verify token metadata',
        ),
      ),
    );
    expect(requests, isEmpty);
  });
  test(
    'RPC redirects are rejected rather than forwarding credentials',
    () async {
      polygon.coin['service'] = rpc('/redirect');
      await expectLater(
        handler.loadAssetMetadata(asset(), validateRequest: () {}),
        code(-32603),
      );
      expect(requests, [('/redirect', 'eth_chainId')]);
    },
  );
}
