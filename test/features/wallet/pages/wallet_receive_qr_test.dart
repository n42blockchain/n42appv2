import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_receive_qr.dart';

void main() {
  const address = '0x17511Ac8358D0F989fC0D5be57C947efbeDE65b3';

  group('buildReceiveQrData', () {
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

    test('uses the address alone when no amount is requested', () {
      expect(
        buildReceiveQrData(
          address: address,
          blockchainType: 'Ethereum',
          amount: '',
          chainId: 94,
        ),
        address,
      );
    });
  });
}
