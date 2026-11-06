import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/mpc/mpc_login_config.dart';
import 'package:n42_wallet/features/wallet/mpc/mpc_provider.dart';

void main() {
  tearDown(() => MpcProviderRegistry.instance.disposeAll());
  test('does not activate with absent credentials or unknown network', () {
    for (final config in [
      const MpcLoginConfig(),
      const MpcLoginConfig(enabled: true, clientId: ' '),
      const MpcLoginConfig(enabled: true, clientId: 'test', network: 'typo'),
      const MpcLoginConfig(clientId: 'test'),
    ]) {
      expect(config.register(isMobile: true), false);
      expect(MpcProviderRegistry.instance.defaultProvider, isNull);
    }
  });
  test('registers the configured provider once without native calls', () {
    const config = MpcLoginConfig(enabled: true, clientId: 'test');
    expect(config.register(isMobile: false), false);
    expect(config.register(isMobile: true), true);
    final first = MpcProviderRegistry.instance.defaultProvider;
    expect(first?.isInitialized, false);
    expect(config.register(isMobile: true), true);
    expect(MpcProviderRegistry.instance.defaultProvider, same(first));
  });
}
