import 'dart:convert';
import 'dart:typed_data';

import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';

import '../../helpers/wallet_connect_client_fake.dart';

class _Provider extends WalletConnectProvider {
  int keyInitializations = 0;
  bool keyAvailable = true;

  @override
  int get signingWalletIndex => 0;
  @override
  String get signingWalletOwner => 'fixture';
  @override
  Future<String?> loadSigningKey(int index, CoinModel cm) async {
    keyInitializations++;
    return keyAvailable ? base64Encode(Uint8List(32)..[31] = 1) : null;
  }

  @override
  Future<void> viewStateDeal(WalletConnectState state, {dynamic params}) async {
    walletConnectState = state;
    errorMessage = params as String? ?? '';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Provider provider;
  setUp(() => provider = _Provider());
  tearDown(() => provider.dispose());

  for (final (chain, type, blockchain, error) in [
    ('solana:4sGjMW1sUnHzSxGspuhpqLDx6wiyjNtZ', 'SOL', 'Solana', 'Solana'),
    ('tron:0x2b6653dc', 'TRX', 'Tron', 'Tron'),
    ('aptos:1', 'APT', 'Aptos', 'Aptos'),
    ('sui:mainnet', 'SUI', 'Sui', 'Sui'),
    ('near:mainnet', 'NEAR', 'Near', 'NEAR'),
  ]) {
    test(
      '$chain selects its coin without loading an EVM signing key',
      () async {
        final coin = sessionCoin(type: type, blockchain: blockchain);
        provider.coinModels = [
          sessionCoin(address: '0x7e5f4552091a69125d5dfcb7b8c2659029395bdf'),
          coin,
        ];
        provider.coinModelsIndex = 0;
        var notifications = 0;
        provider.addListener(() => notifications++);
        expect(provider.coinModelFind(chain), same(coin));
        expect(await provider.web3clientInitFromChainId(chain), isTrue);
        expect(provider.coinModelsIndex, 1);
        expect(notifications, 1);
        expect(provider.keyInitializations, 0);
        expect(await provider.web3clientInitFromChainId(chain), isTrue);
        expect(
          notifications,
          1,
          reason: 'Repeated request should retain the same selection',
        );
      },
    );
    test('$chain missing from wallet rejects before key loading', () async {
      provider.coinModels = [sessionCoin()];
      provider.coinModelsIndex = 0;
      expect(provider.coinModelFind(chain), isNull);
      expect(await provider.web3clientInitFromChainId(chain), isFalse);
      expect(provider.coinModelsIndex, 0);
      expect(provider.walletConnectState, WalletConnectState.error);
      expect(provider.errorMessage, '$error chain not configured');
      expect(provider.keyInitializations, 0);
    });
  }

  test(
    'EVM lookup distinguishes mainnet, testnet and non-EVM chain ID collisions',
    () {
      final eth = sessionCoin();
      final testnet = sessionCoin(isTest: true);
      provider.coinModels = [
        sessionCoin(type: 'APT', blockchain: 'Aptos'),
        sessionCoin(type: 'BTC', blockchain: 'Bitcoin'),
        testnet,
        eth,
      ];
      expect(provider.coinModelFind('eip155:1'), same(eth));
      expect(provider.coinModelFind('eip155:11155111'), same(testnet));
      expect(provider.coinModelFind('eip155:137'), isNull);
      expect(provider.coinModelFind('unsupported:1'), isNull);
    },
  );

  test('EVM requests initialize once per selected chain and reuse the ready client', () async {
    provider.coinModels = [
      sessionCoin(type: 'APT', blockchain: 'Aptos'),
      sessionCoin(address: '0x7e5f4552091a69125d5dfcb7b8c2659029395bdf'),
      sessionCoin(
        type: 'MATIC',
        chainId: 137,
        address: '0x7e5f4552091a69125d5dfcb7b8c2659029395bdf',
      ),
    ];
    provider.coinModelsIndex = 0;
    expect(await provider.web3clientInitFromChainId('eip155:1'), isTrue);
    expect(provider.coinModelsIndex, 1);
    expect(provider.keyInitializations, 1);
    expect(await provider.web3clientInitFromChainId('eip155:1'), isTrue);
    expect(provider.keyInitializations, 1);
    expect(await provider.web3clientInitFromChainId('eip155:137'), isTrue);
    expect(provider.coinModelsIndex, 2);
    expect(provider.keyInitializations, 2);
  });

  test(
    'selected EVM chain with a missing client still initializes signing',
    () async {
      provider.coinModels = [
        sessionCoin(
          isTest: true,
          address: '0x7e5f4552091a69125d5dfcb7b8c2659029395bdf',
        ),
      ];
      provider.coinModelsIndex = 0;
      expect(
        await provider.web3clientInitFromChainId('eip155:11155111'),
        isTrue,
      );
      expect(provider.keyInitializations, 1);
    },
  );

  test(
    'unconfigured EVM chain leaves the current chain and key untouched',
    () async {
      provider.coinModels = [sessionCoin()];
      provider.coinModelsIndex = 0;
      expect(await provider.web3clientInitFromChainId('eip155:137'), isFalse);
      expect(provider.coinModelsIndex, 0);
      expect(provider.keyInitializations, 0);
      expect(provider.walletConnectState, WalletConnectState.error);
    },
  );

  test(
    'key initialization failure is returned to the request dispatcher',
    () async {
      provider.coinModels = [sessionCoin()];
      provider.keyAvailable = false;
      expect(await provider.web3clientInitFromChainId('eip155:1'), isFalse);
      expect(provider.keyInitializations, 1);
      expect(provider.web3client, isNull);
    },
  );
}
