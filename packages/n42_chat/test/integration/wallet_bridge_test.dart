import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/n42_chat.dart';
import '../mocks/mock_wallet_bridge.dart';

void main() {
  group('IWalletBridge interface', () {
    group('TransferResult', () {
      test('success factory should create successful result', () {
        final result = TransferResult.success('0xabc123');

        expect(result.success, isTrue);
        expect(result.transactionHash, '0xabc123');
        expect(result.errorMessage, isNull);
        expect(result.errorCode, isNull);
      });

      test('failure factory should create failed result', () {
        final result =
            TransferResult.failure('Insufficient funds', code: 'INSUFFICIENT');

        expect(result.success, isFalse);
        expect(result.transactionHash, isNull);
        expect(result.errorMessage, 'Insufficient funds');
        expect(result.errorCode, 'INSUFFICIENT');
      });

      test('cancelled factory should create cancelled result', () {
        final result = TransferResult.cancelled();

        expect(result.success, isFalse);
        expect(result.errorCode, 'CANCELLED');
      });
    });

    group('PaymentRequest', () {
      test('should correctly report not expired', () {
        final request = PaymentRequest(
          requestId: '1',
          amount: '10',
          token: 'ETH',
          receiverAddress: '0x123',
          qrCodeData: 'n42://pay',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );

        expect(request.isExpired, isFalse);
      });

      test('should correctly report expired', () {
        final request = PaymentRequest(
          requestId: '1',
          amount: '10',
          token: 'ETH',
          receiverAddress: '0x123',
          qrCodeData: 'n42://pay',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        expect(request.isExpired, isTrue);
      });

      test('should not expire when expiresAt is null', () {
        final request = PaymentRequest(
          requestId: '1',
          amount: '10',
          token: 'ETH',
          receiverAddress: '0x123',
          qrCodeData: 'n42://pay',
          createdAt: DateTime.now(),
        );

        expect(request.isExpired, isFalse);
      });

      test('formattedAmount should combine amount and token', () {
        final request = PaymentRequest(
          requestId: '1',
          amount: '10.5',
          token: 'ETH',
          receiverAddress: '0x123',
          qrCodeData: 'n42://pay',
          createdAt: DateTime.now(),
        );

        expect(request.formattedAmount, '10.5 ETH');
      });
    });

    group('TokenInfo', () {
      test('should create with required fields', () {
        const token = TokenInfo(
          symbol: 'ETH',
          name: 'Ethereum',
          decimals: 18,
        );

        expect(token.symbol, 'ETH');
        expect(token.name, 'Ethereum');
        expect(token.decimals, 18);
        expect(token.contractAddress, isNull);
        expect(token.iconUrl, isNull);
        expect(token.isNative, isFalse);
      });

      test('should create native token', () {
        const token = TokenInfo(
          symbol: 'ETH',
          name: 'Ethereum',
          decimals: 18,
          isNative: true,
        );

        expect(token.isNative, isTrue);
      });

      test('should create ERC-20 token with contract address', () {
        const token = TokenInfo(
          symbol: 'USDT',
          name: 'Tether USD',
          decimals: 6,
          contractAddress: '0xdac17f958d2ee523a2206206994597c13d831ec7',
        );

        expect(token.contractAddress, isNotNull);
        expect(token.isNative, isFalse);
      });
    });

    group('WalletUserInfo', () {
      test('should display username when available', () {
        const info = WalletUserInfo(
          address: '0x1234567890abcdef1234567890abcdef12345678',
          username: 'Alice',
        );

        expect(info.displayName, 'Alice');
      });

      test('should display shortened address when no username', () {
        const info = WalletUserInfo(
          address: '0x1234567890abcdef1234567890abcdef12345678',
        );

        expect(info.displayName, '0x1234...5678');
      });

      test('should display shortened address when username is empty', () {
        const info = WalletUserInfo(
          address: '0x1234567890abcdef1234567890abcdef12345678',
          username: '',
        );

        expect(info.displayName, '0x1234...5678');
      });

      test('should display full address when short', () {
        const info = WalletUserInfo(
          address: '0x12345678',
        );

        expect(info.displayName, '0x12345678');
      });
    });
  });

  group('MockWalletBridge', () {
    late MockWalletBridge bridge;

    setUp(() {
      bridge = MockWalletBridge();
    });

    test('should report wallet as connected', () {
      expect(bridge.isWalletConnected, isTrue);
    });

    test('should return valid address', () {
      expect(bridge.walletAddress, isNotNull);
      expect(bridge.walletAddress!.startsWith('0x'), isTrue);
      expect(bridge.walletAddress!.length, 42);
    });

    test('should return supported tokens', () async {
      final tokens = await bridge.getSupportedTokens();

      expect(tokens, isNotEmpty);
      expect(tokens.any((t) => t.symbol == 'ETH'), isTrue);
      expect(tokens.any((t) => t.symbol == 'USDT'), isTrue);
    });

    test('should return balance for ETH', () async {
      final balance = await bridge.getBalance('ETH');

      expect(balance, '1.5');
    });

    test('should return balance for non-ETH token', () async {
      final balance = await bridge.getBalance('USDT');

      expect(balance, '100.00');
    });

    test('should return successful transfer result', () async {
      final result = await bridge.requestTransfer(
        toAddress: '0x0000000000000000000000000000000000000001',
        amount: '1.0',
        token: 'ETH',
      );

      expect(result.success, isTrue);
      expect(result.transactionHash, isNotNull);
    });

    test('should generate valid payment request', () async {
      final request = await bridge.generatePaymentRequest(
        amount: '10',
        token: 'ETH',
      );

      expect(request.amount, '10');
      expect(request.token, 'ETH');
      expect(request.receiverAddress, bridge.walletAddress);
      expect(request.qrCodeData, contains('n42://pay'));
      expect(request.isExpired, isFalse);
    });

    test('should validate ETH address format', () {
      expect(bridge.isValidAddress('0x1234567890abcdef1234567890abcdef12345678'),
          isTrue);
      expect(bridge.isValidAddress('invalid'), isFalse);
      expect(bridge.isValidAddress('0x123'), isFalse);
    });

    test('should return null for user info', () async {
      final info = await bridge.getUserInfoByAddress('0x123');
      expect(info, isNull);
    });

    // Test default ENS implementations
    test('resolveEnsName should return null by default', () async {
      final result = await bridge.resolveEnsName('test.eth');
      expect(result, isNull);
    });

    test('lookupEnsName should return null by default', () async {
      final result = await bridge.lookupEnsName('0x123');
      expect(result, isNull);
    });

    test('getEnsAvatar should return null by default', () async {
      final result = await bridge.getEnsAvatar('test.eth');
      expect(result, isNull);
    });

    test('batchLookupEnsNames should return map with nulls by default',
        () async {
      final result =
          await bridge.batchLookupEnsNames(['0x111', '0x222']);
      expect(result.length, 2);
      expect(result['0x111'], isNull);
      expect(result['0x222'], isNull);
    });

    // Test default token gate implementations
    test('getErc20Balance should return zero by default', () async {
      final result = await bridge.getErc20Balance(
        contractAddress: '0x123',
        chainId: 1,
      );
      expect(result, BigInt.zero);
    });

    test('getErc721Balance should return zero by default', () async {
      final result = await bridge.getErc721Balance(
        contractAddress: '0x123',
        chainId: 1,
      );
      expect(result, 0);
    });

    test('getErc1155Balance should return zero by default', () async {
      final result = await bridge.getErc1155Balance(
        contractAddress: '0x123',
        tokenId: BigInt.one,
        chainId: 1,
      );
      expect(result, BigInt.zero);
    });
  });
}
