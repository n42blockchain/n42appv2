import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/transactions/evm_transaction_hash_input.dart';

void main() {
  group('normalizeEvmTransactionHashInput', () {
    const validHash =
        '0x88af7937214cb1a0fd4a9a4a65125ddb103886a4e7d4047cc032f6bd7928b4e9';

    test('accepts a valid 0x-prefixed hash', () {
      expect(normalizeEvmTransactionHashInput(validHash), validHash);
    });

    test('adds 0x prefix for bare 64-char hex hashes', () {
      expect(
        normalizeEvmTransactionHashInput(validHash.substring(2)),
        validHash,
      );
    });

    test('extracts hashes from explorer URLs', () {
      expect(
        normalizeEvmTransactionHashInput(
          'https://testnet.n42.world/tx/$validHash',
        ),
        validHash,
      );
    });

    test('extracts hashes from query parameters', () {
      expect(
        normalizeEvmTransactionHashInput(
          'n42app://tx?hash=${Uri.encodeComponent(validHash)}',
        ),
        validHash,
      );
    });

    test('rejects invalid-length hashes', () {
      expect(
        normalizeEvmTransactionHashInput(
          '0x5019c1cc21d8d19cd11d6c66b3cd383f9f9f2a15c688e455',
        ),
        isNull,
      );
      expect(
        isValidEvmTransactionHash(
          '0x5019c1cc21d8d19cd11d6c66b3cd383f9f9f2a15c688e455',
        ),
        isFalse,
      );
    });
  });
}
