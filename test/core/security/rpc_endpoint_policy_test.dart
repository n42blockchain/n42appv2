import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/security/rpc_endpoint_policy.dart';

void main() {
  for (final url in [
    'http://rpc.example',
    'https://user@rpc.example',
    'https://rpc.example#x',
    'https://rpc.example.',
    'https://%72pc.example',
    'https://rрc.example',
    'https://rpc.example\\evil',
    'https://rpc.example:0',
    'https://rpc.example:65536',
    ' https://rpc.example',
    ...List.generate(
      24,
      (i) => 'https://rpc.example${String.fromCharCode(i)}/',
    ),
  ]) {
    test('reject ambiguous RPC ${Uri.encodeComponent(url)}', () {
      expect(RpcEndpointPolicy.isValid(url), isFalse);
    });
  }
  test('keeps ASCII IDNA visible for explicit warning', () {
    final uri = RpcEndpointPolicy.parse('https://xn--pple-43d.example/key');
    expect(uri.host, 'xn--pple-43d.example');
    expect(RpcEndpointPolicy.needsHostnameWarning(uri), isTrue);
    expect(
      RpcEndpointPolicy.isValid('https://rpc.example:8545/v1?key=public'),
      isTrue,
    );
  });
  test('fingerprint requires block zero and a full hash', () {
    final hash = '0x${'ab' * 32}';
    expect(
      RpcEndpointPolicy.genesisHash({'number': '0x0', 'hash': hash}),
      hash,
    );
    for (final block in [
      null,
      {},
      {'number': '0x1', 'hash': hash},
      {'number': '0x0', 'hash': '0x123'},
    ]) {
      expect(() => RpcEndpointPolicy.genesisHash(block), throwsFormatException);
    }
  });
}
