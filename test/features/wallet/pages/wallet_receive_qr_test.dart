import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_receive_qr.dart';

void main() {
  const address = '0x17511Ac8358D0F989fC0D5be57C947efbeDE65b3';

  group('buildReceiveQrData', () {
    test('selects the configured network-specific token contract', () {
      expect(
        receiveQrTokenContract(
          mainnetContract: '0xMainnetContract',
          testnetContract: '0xTestnetContract',
          isTest: true,
        ),
        '0xTestnetContract',
      );
      expect(
        receiveQrTokenContract(
          mainnetContract: '0xMainnetContract',
          testnetContract: '',
          isTest: true,
        ),
        isNull,
      );
    });

    test('uses EIP-681 minimum units for an N42 native payment request', () {
      expect(
        buildReceiveQrData(
          address: address,
          blockchainType: 'Ethereum',
          amount: '6',
          nativeDecimals: 18,
          chainId: 94,
        ),
        'ethereum:$address@94?value=6000000000000000000',
      );
    });

    test('uses ERC-20 transfer parameters for a token request', () {
      expect(
        buildReceiveQrData(
          address: address,
          blockchainType: 'Ethereum',
          amount: '1.25',
          erc20Contract: '0xD44F4fdB883994a5bA529d76Fe58e2D16575a1d1',
          erc20Decimals: 18,
          chainId: 94,
        ),
        'ethereum:0xD44F4fdB883994a5bA529d76Fe58e2D16575a1d1@94/'
        'transfer?address=$address&uint256=1250000000000000000',
      );
    });

    test('keeps EVM chain identity when no native amount is requested', () {
      expect(
        buildReceiveQrData(
          address: address,
          blockchainType: 'Ethereum',
          amount: '',
          chainId: 94,
        ),
        'ethereum:$address@94',
      );
    });

    test('keeps ERC-20 contract and recipient when no amount is requested', () {
      const contract = '0xD44F4fdB883994a5bA529d76Fe58e2D16575a1d1';
      expect(
        buildReceiveQrData(
          address: address,
          blockchainType: 'Ethereum',
          amount: '',
          erc20Contract: contract,
          chainId: 94,
        ),
        'ethereum:$contract@94/transfer?address=$address',
      );
    });

    test('includes the Solana SPL mint in an amount-free token request', () {
      const mint = 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v';
      expect(
        buildReceiveQrData(
          address: 'SolanaRecipient',
          blockchainType: 'Solana',
          amount: '',
          erc20Contract: mint,
        ),
        'solana:SolanaRecipient?spl-token=$mint',
      );
    });

    test('includes the Solana SPL mint alongside token amount', () {
      const mint = 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v';
      expect(
        buildReceiveQrData(
          address: 'SolanaRecipient',
          blockchainType: 'Solana',
          amount: '1.25',
          erc20Contract: mint,
        ),
        'solana:SolanaRecipient?amount=1.25&spl-token=$mint',
      );
    });

    test('uses the Bitcoin URI even when amount is open', () {
      expect(
        buildReceiveQrData(
          address: 'bc1qexample',
          blockchainType: 'Bitcoin',
          amount: '',
        ),
        'bitcoin:bc1qexample',
      );
    });

    test('uses BIP-321 testnet destination parameter', () {
      expect(
        buildReceiveQrData(
          address: 'tb1qreceiver',
          blockchainType: 'Bitcoin',
          amount: '',
          isTest: true,
        ),
        'bitcoin:?tb=tb1qreceiver',
      );
    });

    test(
      'uses the versioned fallback for a testnet token without a URI standard',
      () {
        expect(
          buildReceiveQrData(
            address: 'TestnetRecipient',
            blockchainType: 'Tron',
            amount: '',
            chainMKey: 'TRX',
            isTest: true,
            erc20Contract: 'TestnetContract',
          ),
          'n42pay://v1/pay?chain=TRX&network=testnet&type=token'
          '&to=TestnetRecipient&contract=TestnetContract',
        );
      },
    );

    test('uses the fallback when EVM chain ID is unavailable', () {
      expect(
        buildReceiveQrData(
          address: address,
          blockchainType: 'Ethereum',
          amount: '',
          chainId: 0,
          chainMKey: 'custom-evm',
        ),
        'n42pay://v1/pay?chain=custom-evm&network=mainnet&type=native'
        '&to=$address',
      );
    });
  });
}
