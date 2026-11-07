import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';

import '../../../helpers/wallet_connect_client_fake.dart';

class _Provider extends WalletConnectProvider {
  int selected = 0;
  String owner = 'a';
  int revision = 0;
  bool ready = true;
  int reads = 0;
  final models = [
    sessionCoin(type: 'SOL', blockchain: 'Solana', address: 'wallet-a'),
    sessionCoin(type: 'SOL', blockchain: 'Solana', address: 'wallet-b'),
  ];
  @override
  int get signingWalletIndex => selected;
  @override
  String get signingWalletOwner => owner;
  @override
  ({List<CoinModel> models, bool Function() isCurrent})
  readSigningCoinModels() {
    reads++;
    if (!ready) throw StateError('rebuild pending');
    final index = selected;
    final account = owner;
    final generation = revision;
    return (
      models: [models[index]],
      isCurrent: () =>
          ready &&
          index == selected &&
          account == owner &&
          generation == revision,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const chain = 'solana:4sGjMW1sUnHzSxGspuhpqLDx6wiyjNtZ';
  test(
    'wallet switch refreshes models before choosing the native signer',
    () async {
      final provider = _Provider();
      addTearDown(provider.dispose);
      provider.coinModelInit();
      expect(provider.coinModels.single.address, 'wallet-a');
      provider.selected = 1;
      expect(provider.signingCoinModelsAreCurrent, isFalse);
      expect(await provider.web3clientInitFromChainId(chain), isTrue);
      expect(provider.coinModels.single.address, 'wallet-b');
      expect(provider.reads, 2);
      expect(provider.signingCoinModelsAreCurrent, isTrue);
    },
  );
  test('pending source rebuild cannot relabel stale coins and later retry recovers', () async {
    final provider = _Provider();
    addTearDown(provider.dispose);
    provider.coinModelInit();
    provider.selected = 1;
    provider.ready = false;
    expect(await provider.web3clientInitFromChainId(chain), isFalse);
    expect(provider.coinModels, isEmpty);
    expect(provider.coinModelsIndex, -1);
    expect(provider.signingCoinModelsAreCurrent, isFalse);
    provider.ready = true;
    expect(await provider.web3clientInitFromChainId(chain), isTrue);
    expect(provider.coinModels.single.address, 'wallet-b');
  });
  test(
    'same-index account change and model rebuild expire the captured list',
    () {
      final provider = _Provider();
      addTearDown(provider.dispose);
      provider.coinModelInit();
      provider.owner = 'b';
      expect(provider.signingCoinModelsAreCurrent, isFalse);
      expect(provider.ensureSigningCoinModelsCurrent(), isTrue);
      provider.revision++;
      expect(provider.signingCoinModelsAreCurrent, isFalse);
      expect(provider.ensureSigningCoinModelsCurrent(), isTrue);
      expect(provider.reads, 3);
    },
  );
  test('an approved request cannot use a list from the previous wallet', () {
    const address = '0x1111111111111111111111111111111111111111';
    final client = WalletKitFake()
      ..activeSessions['request-topic'] = approvedEvmSession(
        'request-topic',
        address,
      );
    final provider = _Provider()..signClient = client;
    addTearDown(() {
      provider.signClient = null;
      provider.dispose();
    });
    provider.coinModelInit();
    final request = sessionRequest('personal_sign', ['text', address]);
    expect(provider.isSessionRequestAuthorized(request), isTrue);
    provider.selected = 1;
    expect(provider.isSessionRequestAuthorized(request), isFalse);
  });
}
