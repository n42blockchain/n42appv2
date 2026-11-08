import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/browser/models/watch_asset_request.dart';
import 'package:n42_wallet/features/browser/models/watch_asset_metadata.dart';

String abiText(String text) {
  final bytes = utf8.encode(text);
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '0x${'20'.padLeft(64, '0')}${bytes.length.toRadixString(16).padLeft(64, '0')}${hex.padRight(((bytes.length + 31) ~/ 32) * 64, '0')}';
}

void main() {
  const address = '0x52908400098527886E0F7030069857D2E4169EE7';
  WatchAssetRequest request([Map<String, dynamic> hints = const {}]) =>
      WatchAssetRequest.parse([
        {
          'type': 'ERC20',
          'options': {'address': address, ...hints},
        },
      ], 1);
  Matcher invalid() =>
      throwsA(isA<Map>().having((e) => e['code'], 'code', -32602));
  late List<String> calls;
  late Map<String, dynamic> values;
  Future<dynamic> rpc(String method, List<dynamic> params) async {
    final key = method == 'eth_call'
        ? (params.first as Map)['data'] as String
        : method;
    calls.add(key);
    if (method == 'eth_call') {
      expect((params.first as Map)['to'], address);
      expect(params.last, 'latest');
    }
    return values[key];
  }

  Future<WatchAssetMetadata> load([Map<String, dynamic> hints = const {}]) =>
      WatchAssetMetadata.load(
        request: request(hints),
        rpc: rpc,
        validateRequest: () {},
      );
  setUp(() {
    calls = [];
    values = {
      'eth_chainId': '0x1',
      'eth_getCode': '0x6000',
      '0x95d89b41': abiText('ABC'),
      '0x313ce567': '0x${'12'.padLeft(64, '0')}',
    };
  });
  test('loads symbol and decimals from the matching contract without remote images', () async {
    final result = await load({
      'symbol': 'ABC',
      'decimals': 18,
      'image': 'http://127.0.0.1/private',
    });
    expect(result.symbol, 'ABC');
    expect(result.decimals, 18);
    expect(result.name, 'ABC');
    expect(calls, ['eth_chainId', 'eth_getCode', '0x95d89b41', '0x313ce567']);
  });
  test('supports a legacy bytes32 symbol and zero decimals', () async {
    values['0x95d89b41'] = '0x414243${''.padRight(58, '0')}';
    values['0x313ce567'] = '0x${''.padRight(64, '0')}';
    expect((await load()).decimals, 0);
  });
  test('rejects a mismatched RPC chain before contract calls', () async {
    values['eth_chainId'] = '0x89';
    await expectLater(load(), invalid());
    expect(calls, ['eth_chainId']);
  });
  test('rejects absent or malformed contract code', () async {
    for (final value in ['0x', '0x0000', '0x0', '0xzz', 42]) {
      values['eth_getCode'] = value;
      await expectLater(load(), invalid());
    }
  });
  test('rejects spoofed symbol and precision hints', () async {
    await expectLater(load({'symbol': 'USDT'}), invalid());
    await expectLater(load({'decimals': 6}), invalid());
  });
  test('rejects malformed or misleading contract text', () async {
    for (final value in [
      '0x',
      '0xzz',
      abiText(''),
      abiText('A\nB'),
      abiText('A\u202eB'),
      '0x${'00'.padRight(192, '0')}',
    ]) {
      values['0x95d89b41'] = value;
      await expectLater(load(), invalid());
    }
  });
  test('rejects malformed or excessive contract decimals', () async {
    for (final value in ['0x12', '0x${'100'.padLeft(64, '0')}', '0xzz', null]) {
      values['0x313ce567'] = value;
      await expectLater(load(), invalid());
    }
  });
  test(
    'rechecks account and document ownership after each network read',
    () async {
      var active = true;
      await expectLater(
        WatchAssetMetadata.load(
          request: request(),
          rpc: (method, params) async {
            active = false;
            return rpc(method, params);
          },
          validateRequest: () {
            if (!active) throw StateError('stale');
          },
        ),
        throwsStateError,
      );
      expect(calls, ['eth_chainId']);
    },
  );
}
