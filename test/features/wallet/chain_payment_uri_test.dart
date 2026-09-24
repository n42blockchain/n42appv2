import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/scan_to_pay_utils.dart';
import 'package:n42_wallet/features/wallet/utils/chain_payment_uri.dart';
import 'package:n42_wallet/features/wallet/utils/eip681.dart';

void main() {
  group('ChainPaymentUri', () {
    test('round-trips chain, network, token identity and display amount', () {
      const request = ChainPaymentRequest(
        chain: 'solana',
        network: ChainPaymentNetwork.testnet,
        assetType: ChainPaymentAssetType.token,
        recipient: 'wallet&one',
        contract: 'mint+one',
        amount: '0.25',
      );

      expect(
        ChainPaymentUri.tryParse(ChainPaymentUri.encode(request)),
        request,
      );
    });

    test('round-trips native requests with an editable amount', () {
      const request = ChainPaymentRequest(
        chain: 'n42',
        network: ChainPaymentNetwork.mainnet,
        assetType: ChainPaymentAssetType.native,
        recipient: 'N42Recipient',
      );

      final encoded = ChainPaymentUri.encode(request);
      expect(encoded, contains('type=native'));
      expect(encoded, isNot(contains('amount=')));
      expect(ChainPaymentUri.tryParse(encoded), request);
    });

    test('rejects unsupported versions, missing identity and unknown keys', () {
      expect(
        ChainPaymentUri.tryParse(
          'n42pay://v2/pay?chain=n42&network=mainnet&type=native&to=addr',
        ),
        isNull,
      );
      expect(
        ChainPaymentUri.tryParse(
          'n42pay://v1/pay?network=mainnet&type=native&to=addr',
        ),
        isNull,
      );
      expect(
        ChainPaymentUri.tryParse(
          'n42pay://v1/pay?chain=n42&network=mainnet&type=native&to=addr&memo=x',
        ),
        isNull,
      );
    });

    test('rejects repeated and malformed query values', () {
      expect(
        ChainPaymentUri.tryParse(
          'n42pay://v1/pay?chain=n42&chain=solana&network=mainnet'
          '&type=native&to=addr',
        ),
        isNull,
      );
      expect(
        ChainPaymentUri.tryParse(
          'n42pay://v1/pay?chain=n42&network=mainnet&type=native&to=%zz',
        ),
        isNull,
      );
    });

    test(
      'requires token contract and forbids contracts on native requests',
      () {
        expect(
          ChainPaymentUri.tryParse(
            'n42pay://v1/pay?chain=solana&network=mainnet&type=token&to=wallet',
          ),
          isNull,
        );
        expect(
          ChainPaymentUri.tryParse(
            'n42pay://v1/pay?chain=solana&network=mainnet&type=native'
            '&to=wallet&contract=mint',
          ),
          isNull,
        );
      },
    );

    test('rejects zero, negative, scientific and localized amounts', () {
      for (final amount in ['0', '-1', '1e3', '1,000', '1.']) {
        expect(
          ChainPaymentUri.tryParse(
            'n42pay://v1/pay?chain=n42&network=mainnet&type=native'
            '&to=recipient&amount=$amount',
          ),
          isNull,
          reason: 'amount $amount must be invalid',
        );
      }
    });

    test('parses BIP-321 mainnet and testnet payment requests', () {
      expect(
        ChainPaymentUri.tryParse('bitcoin:bc1qreceiver?amount=0.001'),
        const ChainPaymentRequest(
          chain: 'BTC',
          network: ChainPaymentNetwork.mainnet,
          assetType: ChainPaymentAssetType.native,
          recipient: 'bc1qreceiver',
          amount: '0.001',
        ),
      );
      expect(
        ChainPaymentUri.tryParse('bitcoin:?tb=tb1qreceiver&amount=0.001'),
        const ChainPaymentRequest(
          chain: 'BTC',
          network: ChainPaymentNetwork.testnet,
          assetType: ChainPaymentAssetType.native,
          recipient: 'tb1qreceiver',
          amount: '0.001',
        ),
      );
    });

    test('parses Solana Pay token requests by mint with open amount', () {
      expect(
        ChainPaymentUri.tryParse(
          'solana:SolanaRecipient?spl-token=MintAddress',
        ),
        const ChainPaymentRequest(
          chain: 'SOL',
          network: ChainPaymentNetwork.mainnet,
          assetType: ChainPaymentAssetType.token,
          recipient: 'SolanaRecipient',
          contract: 'MintAddress',
        ),
      );
    });

    test('parses supported legacy native payment schemes', () {
      expect(
        ChainPaymentUri.tryParse('ton:transfer/TonRecipient?amount=2'),
        const ChainPaymentRequest(
          chain: 'TON',
          network: ChainPaymentNetwork.mainnet,
          assetType: ChainPaymentAssetType.native,
          recipient: 'TonRecipient',
          amount: '2',
        ),
      );
    });

    test('rejects malformed and ambiguous standard payment requests', () {
      for (final recipient in [
        'tb1qwrongnetwork',
        'bcrt1qregtest',
        'mTestnetP2pkh',
        'nTestnetP2pkh',
        '2TestnetP2sh',
      ]) {
        expect(
          ChainPaymentUri.tryParse('bitcoin:$recipient?amount=1'),
          isNull,
          reason: '$recipient must not be treated as a mainnet address',
        );
      }
      expect(
        ChainPaymentUri.tryParse('bitcoin:bc1qreceiver?amount=1&amount=2'),
        isNull,
      );
      expect(
        ChainPaymentUri.tryParse('solana:receiver?spl-token=mint&unknown=x'),
        isNull,
      );
    });
  });

  CoinModel native({required String coinType, required int chainId}) {
    final coin = CoinModel.fromMap({
      'coinType': coinType,
      'blockchainType': BlockchainType.Ethereum.name,
      'miniName': coinType,
      'decimals': 18,
      'isContract': false,
      'chainId': chainId,
      'contract': '',
    });
    coin.address = '0x0000000000000000000000000000000000000001';
    return coin;
  }

  CoinModel nonEvmAsset({
    required String mKey,
    required String coinType,
    required String blockchainType,
    required bool isContract,
    required String contract,
    required int decimals,
    bool isTest = false,
    String? parentChainMKey,
  }) {
    final coin = CoinModel.fromMap({
      'mKey': mKey,
      'coinType': coinType,
      'blockchainType': blockchainType,
      'miniName': isContract ? 'USDC' : coinType,
      'decimals': decimals,
      'isContract': isContract,
      'contract': contract,
    });
    coin.isTest = isTest;
    coin.parentChainMKey = parentChainMKey;
    coin.address = 'wallet-address';
    return coin;
  }

  test('rejects duplicate EIP-681 payment parameters', () {
    final coin = native(coinType: 'ETH', chainId: 1);
    final request = Eip681.parse(
      'ethereum:0x0000000000000000000000000000000000000001@1'
      '?value=100&value=200',
    )!;

    expect(
      ScanToPayResolver.resolve(request: request, coinModels: [coin]),
      isNull,
    );
  });

  test(
    'does not route unsupported EIP-681 function calls as native payments',
    () {
      final coin = native(coinType: 'ETH', chainId: 1);
      final request = Eip681.parse(
        'ethereum:0x0000000000000000000000000000000000000001@1'
        '/approve?spender=0x0000000000000000000000000000000000000002&uint256=5',
      )!;

      expect(
        ScanToPayResolver.resolve(request: request, coinModels: [coin]),
        isNull,
      );
    },
  );

  test('does not guess among chains for a chainless native request', () {
    final eth = native(coinType: 'ETH', chainId: 1);
    final polygon = native(coinType: 'MATIC', chainId: 137);
    final request = Eip681.parse(
      'ethereum:0x0000000000000000000000000000000000000001',
    )!;

    expect(
      ScanToPayResolver.resolve(request: request, coinModels: [eth, polygon]),
      isNull,
    );
  });

  test('rejects negative EIP-681 amounts instead of opening a blank form', () {
    final eth = native(coinType: 'ETH', chainId: 1);
    final request = Eip681.parse(
      'ethereum:0x0000000000000000000000000000000000000001@1?value=-1',
    )!;

    expect(
      ScanToPayResolver.resolve(request: request, coinModels: [eth]),
      isNull,
    );
  });

  test(
    'resolves N42 payment requests by mKey and network with open amount',
    () {
      final mainnet = nonEvmAsset(
        mKey: 'solana-mainnet',
        coinType: 'SOL',
        blockchainType: 'Solana',
        isContract: false,
        contract: '',
        decimals: 9,
      );
      final testnet = nonEvmAsset(
        mKey: 'solana-testnet',
        coinType: 'SOL',
        blockchainType: 'Solana',
        isContract: false,
        contract: '',
        decimals: 9,
        isTest: true,
      );
      const request = ChainPaymentRequest(
        chain: 'solana-mainnet',
        network: ChainPaymentNetwork.mainnet,
        assetType: ChainPaymentAssetType.native,
        recipient: 'receiver',
      );

      final result = ScanToPayResolver.resolve(
        chainRequest: request,
        coinModels: [mainnet, testnet],
      );

      expect(result?.coinModel, same(mainnet));
      expect(result?.recipient, 'receiver');
      expect(result?.amount, isNull);
    },
  );

  test('resolves N42 token by contract rather than symbol', () {
    final chain = nonEvmAsset(
      mKey: 'solana-mainnet',
      coinType: 'SOL',
      blockchainType: 'Solana',
      isContract: false,
      contract: '',
      decimals: 9,
    );
    final usdc = nonEvmAsset(
      mKey: 'usdc-token',
      coinType: 'SOL',
      blockchainType: 'Solana',
      isContract: true,
      contract: 'USDC-MINT',
      decimals: 6,
      parentChainMKey: 'solana-mainnet',
    );
    final otherUsdc = nonEvmAsset(
      mKey: 'other-usdc-token',
      coinType: 'SOL',
      blockchainType: 'Solana',
      isContract: true,
      contract: 'OTHER-MINT',
      decimals: 6,
      parentChainMKey: 'solana-mainnet',
    );
    const request = ChainPaymentRequest(
      chain: 'solana-mainnet',
      network: ChainPaymentNetwork.mainnet,
      assetType: ChainPaymentAssetType.token,
      recipient: 'receiver',
      contract: 'USDC-MINT',
      amount: '1.250000',
    );

    final result = ScanToPayResolver.resolve(
      chainRequest: request,
      coinModels: [chain, usdc, otherUsdc],
    );

    expect(result?.coinModel, same(usdc));
    expect(result?.amount, '1.250000');
  });

  test('rejects N42 network mismatches and amounts beyond asset precision', () {
    final chain = nonEvmAsset(
      mKey: 'solana-mainnet',
      coinType: 'SOL',
      blockchainType: 'Solana',
      isContract: false,
      contract: '',
      decimals: 9,
    );
    const wrongNetwork = ChainPaymentRequest(
      chain: 'solana-mainnet',
      network: ChainPaymentNetwork.testnet,
      assetType: ChainPaymentAssetType.native,
      recipient: 'receiver',
    );
    const tooPrecise = ChainPaymentRequest(
      chain: 'solana-mainnet',
      network: ChainPaymentNetwork.mainnet,
      assetType: ChainPaymentAssetType.native,
      recipient: 'receiver',
      amount: '1.1234567890',
    );

    expect(
      ScanToPayResolver.resolve(
        chainRequest: wrongNetwork,
        coinModels: [chain],
      ),
      isNull,
    );
    expect(
      ScanToPayResolver.resolve(chainRequest: tooPrecise, coinModels: [chain]),
      isNull,
    );
  });

  test(
    'classifies recognized payment schemes separately from plain addresses',
    () {
      expect(
        WalletPaymentScanParser.parse(
          '0x0000000000000000000000000000000000000001',
        ).kind,
        WalletPaymentScanKind.plainAddress,
      );
      expect(
        WalletPaymentScanParser.parse('n42pay://v9/pay?to=receiver').kind,
        WalletPaymentScanKind.unsupported,
      );
      expect(
        WalletPaymentScanParser.parse('n42://pay?address=receiver').kind,
        WalletPaymentScanKind.unsupported,
      );
      expect(
        WalletPaymentScanParser.parse('bitcoin:bc1qreceiver').kind,
        WalletPaymentScanKind.chainAware,
      );
    },
  );

  test('resolves Solana Pay against the exact token mint', () {
    final chain = nonEvmAsset(
      mKey: 'SOL',
      coinType: 'SOL',
      blockchainType: 'Solana',
      isContract: false,
      contract: '',
      decimals: 9,
    );
    final usdc = nonEvmAsset(
      mKey: 'token-usdc',
      coinType: 'SOL',
      blockchainType: 'Solana',
      isContract: true,
      contract: 'UsdcMint',
      decimals: 6,
      parentChainMKey: 'SOL',
    );
    final request = ChainPaymentUri.tryParse(
      'solana:SolanaRecipient?spl-token=UsdcMint&amount=1.25',
    )!;

    final result = ScanToPayResolver.resolve(
      chainRequest: request,
      coinModels: [chain, usdc],
    );

    expect(result?.coinModel, same(usdc));
    expect(result?.recipient, 'SolanaRecipient');
    expect(result?.amount, '1.25');
  });

  test('does not resolve a token whose parent chain differs from request', () {
    final mainnet = nonEvmAsset(
      mKey: 'solana-mainnet',
      coinType: 'SOL',
      blockchainType: 'Solana',
      isContract: false,
      contract: '',
      decimals: 9,
    );
    final otherNetwork = nonEvmAsset(
      mKey: 'solana-custom',
      coinType: 'SOL',
      blockchainType: 'Solana',
      isContract: false,
      contract: '',
      decimals: 9,
    );
    final sameMintOnOtherNetwork = nonEvmAsset(
      mKey: 'same-mint',
      coinType: 'SOL',
      blockchainType: 'Solana',
      isContract: true,
      contract: 'SharedMint',
      decimals: 6,
      parentChainMKey: 'solana-custom',
    );
    const request = ChainPaymentRequest(
      chain: 'solana-mainnet',
      network: ChainPaymentNetwork.mainnet,
      assetType: ChainPaymentAssetType.token,
      recipient: 'receiver',
      contract: 'SharedMint',
    );

    expect(
      ScanToPayResolver.resolve(
        chainRequest: request,
        coinModels: [mainnet, otherNetwork, sameMintOnOtherNetwork],
      ),
      isNull,
    );
  });
}
