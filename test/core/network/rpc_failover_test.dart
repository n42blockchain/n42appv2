import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/network/rpc_failover.dart';

void main() {
  setUp(RpcFailover.resetAll);
  tearDown(RpcFailover.resetAll);

  test('unknown chain preserves caller fallback and cannot advance', () {
    expect(
      RpcFailover.getActiveRpc('unknown', fallback: 'https://custom.invalid'),
      'https://custom.invalid',
    );
    expect(RpcFailover.markFailed('unknown'), isFalse);
  });

  test(
    'failover advances once per failure and stays at exhausted endpoint',
    () {
      final primary = RpcFailover.getActiveRpc('eth', fallback: 'unused');
      expect(RpcFailover.markFailed('ETH'), isTrue);
      final second = RpcFailover.getActiveRpc('eth', fallback: 'unused');
      expect(second, isNot(primary));
      expect(RpcFailover.markFailed('eTh'), isTrue);
      final third = RpcFailover.getActiveRpc('ETH', fallback: 'unused');
      expect(third, isNot(second));
      expect(RpcFailover.markFailed('eth'), isFalse);
      expect(RpcFailover.getActiveRpc('ETH', fallback: 'unused'), third);
      RpcFailover.reset('eTh');
      expect(RpcFailover.getActiveRpc('ETH', fallback: 'unused'), primary);
    },
  );

  test('failures and reset remain isolated per chain', () {
    final eth = RpcFailover.getActiveRpc('ETH', fallback: 'unused');
    final sol = RpcFailover.getActiveRpc('SOL', fallback: 'unused');
    RpcFailover.markFailed('ETH');
    expect(RpcFailover.getActiveRpc('SOL', fallback: 'unused'), sol);
    RpcFailover.markFailed('SOL');
    RpcFailover.reset('ETH');
    expect(RpcFailover.getActiveRpc('ETH', fallback: 'unused'), eth);
    expect(RpcFailover.getActiveRpc('SOL', fallback: 'unused'), isNot(sol));
    RpcFailover.resetAll();
    expect(RpcFailover.getActiveRpc('SOL', fallback: 'unused'), sol);
  });
}
