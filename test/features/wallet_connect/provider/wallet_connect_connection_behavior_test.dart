import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';

import '../../../helpers/wallet_connect_client_fake.dart';

class _ConnectionProvider extends WalletConnectProvider {
  int coinModelInitializations = 0;
  int chainInfoRegistrations = 0;

  @override
  void coinModelInit({int chainId = -1}) {
    coinModelInitializations++;
  }

  @override
  void setChainInfo() {
    chainInfoRegistrations++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late WalletKitFake client;
  late _ConnectionProvider provider;

  setUp(() {
    client = WalletKitFake();
    provider = _ConnectionProvider()..signClient = client;
  });

  tearDown(() {
    provider.signClient = null;
    provider.dispose();
  });

  test('connect initialization reuses the injected SDK client', () async {
    await provider.connectInit();

    expect(provider.signClient, same(client));
    expect(provider.coinModelInitializations, 1);
    expect(provider.chainInfoRegistrations, 0);
    expect(client.pairingRequests, isEmpty);
  });

  test('invalid connection URI is rejected before the SDK is called', () async {
    expect(await provider.pair('https://example.test'), isFalse);

    expect(client.pairingRequests, isEmpty);
    expect(provider.walletConnectState, WalletConnectState.error);
    expect(provider.errorMessage, 'Invalid WalletConnect URI');
  });

  test('private key access fails closed before wallet initialization', () {
    expect(
      () => provider.privateKey,
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('Private key not initialized'),
        ),
      ),
    );
  });
}
