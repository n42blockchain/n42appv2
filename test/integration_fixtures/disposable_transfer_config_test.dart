import 'package:flutter_test/flutter_test.dart';

import '../../integration_test/fixtures/disposable_transfer_config.dart';

void main() {
  Map<String, dynamic> valid() => {
    'rpc': 'http://127.0.0.1:18545',
    'disposable': true,
    'chainId': DisposableTransferConfig.chainId,
    'genesisHash': '0x${'1' * 64}',
    'clientVersion': 'owned-node-fixture',
    'privateKey': '1' * 64,
    'sender': '0x${'1' * 40}',
    'recipient': '0x${'2' * 40}',
  };
  test('accepts an explicit owned loopback chain', () {
    expect(DisposableTransferConfig.fromJson(valid()).rpc.host, '127.0.0.1');
  });
  for (final rpc in [
    'https://rpc.example.com',
    'http://10.0.2.2:18545',
    'http://localhost:18545',
    'http://127.0.0.1:80',
    'http://127.0.0.1:18545/?token=hidden',
    'http://user@127.0.0.1:18545',
  ]) {
    test('rejects a non-owned or ambiguous endpoint $rpc', () {
      expect(
        () => DisposableTransferConfig.fromJson(valid()..['rpc'] = rpc),
        throwsFormatException,
      );
    });
  }
  for (final field in [
    'disposable',
    'chainId',
    'genesisHash',
    'clientVersion',
    'privateKey',
    'sender',
    'recipient',
  ]) {
    test('requires complete provenance and account field $field', () {
      expect(
        () => DisposableTransferConfig.fromJson(valid()..remove(field)),
        throwsFormatException,
      );
    });
  }
}
