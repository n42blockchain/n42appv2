import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/browser/models/watch_asset_request.dart';

void main() {
  const address = '0x52908400098527886E0F7030069857D2E4169EE7';
  List<dynamic> request([Map<String, dynamic> options = const {}]) => [
    {
      'type': 'ERC20',
      'options': {'address': address, ...options},
    },
  ];
  Matcher rpc(int code) =>
      throwsA(isA<Map>().having((e) => e['code'], 'code', code));

  test('accepts a checksummed contract on the current network', () {
    final result = WatchAssetRequest.parse(request(), 1);
    expect(result.address.eip55With0x, address);
    expect(result.chainId, 1);
    expect(result.suggestedSymbol, isNull);
    expect(result.suggestedDecimals, isNull);
  });
  test('retains optional hints without treating them as verified metadata', () {
    final result = WatchAssetRequest.parse(
      request({'symbol': 'ABC', 'decimals': 0}),
      1,
    );
    expect(result.suggestedSymbol, 'ABC');
    expect(result.suggestedDecimals, 0);
  });
  test('rejects malformed shape and unsupported asset types', () {
    for (final value in <List<dynamic>>[
      [],
      [null],
      [
        {'type': 'ERC20'},
      ],
      [...request(), ...request()],
    ]) {
      expect(() => WatchAssetRequest.parse(value, 1), rpc(-32602));
    }
    expect(
      () => WatchAssetRequest.parse([
        {'type': 'ERC721', 'options': {}},
      ], 1),
      rpc(4200),
    );
  });
  test('rejects invalid address checksums and missing prefix', () {
    for (final value in [
      address.toLowerCase(),
      '${address}00',
      '${address}suffix',
      '0x52908400098527886E0F7030069857D2E4169Ee7',
      address.substring(2),
      '0x123',
      42,
    ]) {
      expect(
        () => WatchAssetRequest.parse(request({'address': value}), 1),
        rpc(-32602),
      );
    }
  });
  test('rejects a different network without switching it', () {
    expect(
      () => WatchAssetRequest.parse(request({'chainId': 137}), 1),
      rpc(4902),
    );
  });
  test('rejects ambiguous or unsafe chain IDs', () {
    for (final value in ['1', '0x1', 1.0, 0, -1, 9007199254740992]) {
      expect(
        () => WatchAssetRequest.parse(request({'chainId': value}), 1),
        rpc(-32602),
      );
    }
  });
  test('rejects malformed metadata hints', () {
    for (final value in ['', 'A\nB', 2, 'a' * 33]) {
      expect(
        () => WatchAssetRequest.parse(request({'symbol': value}), 1),
        rpc(-32602),
      );
    }
    for (final value in [-1, 256, 1.0, '18', true]) {
      expect(
        () => WatchAssetRequest.parse(request({'decimals': value}), 1),
        rpc(-32602),
      );
    }
  });
}
