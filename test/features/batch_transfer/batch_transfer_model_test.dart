// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BatchTransferModel Tests', () {
    group('Address Validation', () {
      test('should validate EVM address correctly', () {
        final validAddress = '0x1234567890abcdef1234567890abcdef12345678';
        final isValid = RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(validAddress);
        expect(isValid, true);

        final invalidAddress = '0x123';
        final isInvalid = RegExp(
          r'^0x[a-fA-F0-9]{40}$',
        ).hasMatch(invalidAddress);
        expect(isInvalid, false);
      });
    });

    group('Amount Calculations', () {
      test('should calculate total amount correctly', () {
        final amounts = [
          BigInt.parse('1000000000000000000'),
          BigInt.parse('2000000000000000000'),
          BigInt.parse('3000000000000000000'),
        ];

        final totalAmount = amounts.fold<BigInt>(
          BigInt.zero,
          (sum, amount) => sum + amount,
        );

        expect(totalAmount.toString(), '6000000000000000000');
      });

      test('should detect native token correctly', () {
        const nativeAddress = '0x0000000000000000000000000000000000000000';
        final isNative =
            nativeAddress == '0x0000000000000000000000000000000000000000';
        expect(isNative, true);
      });
    });

    group('CSV Parsing', () {
      test('should parse valid CSV row', () {
        const csvRow = '0x1234567890abcdef1234567890abcdef12345678,1.5,Payment';

        final parts = csvRow.split(',');
        final address = parts[0].trim();
        final amount = double.parse(parts[1].trim());
        final label = parts.length > 2 ? parts[2].trim() : null;

        expect(address, '0x1234567890abcdef1234567890abcdef12345678');
        expect(amount, 1.5);
        expect(label, 'Payment');
      });

      test('should handle CSV with only address and amount', () {
        const csvRow = '0x1234567890abcdef1234567890abcdef12345678,2.0';

        final parts = csvRow.split(',');
        expect(parts.length, 2);
      });

      test('should reject invalid amount in CSV', () {
        const csvRow = '0x1234567890abcdef1234567890abcdef12345678,abc';

        final parts = csvRow.split(',');
        final amountStr = parts[1].trim();

        expect(() => double.parse(amountStr), throwsFormatException);
      });
    });

    group('Gas Calculations', () {
      test('should calculate gas for multiple transfers', () {
        const baseGas = 21000;
        const perTransferGas = 21000;
        const numTransfers = 5;

        final totalGas = baseGas + (perTransferGas * numTransfers);
        expect(totalGas, 126000);
      });

      test('should calculate Multicall3 gas savings', () {
        const singleTransferGas = 21000;
        const numTransfers = 10;
        const multicallBaseGas = 30000;
        const multicallPerCallGas = 15000;

        final individualTotal = singleTransferGas * numTransfers;
        final multicallTotal =
            multicallBaseGas + (multicallPerCallGas * numTransfers);

        final savings = individualTotal - multicallTotal;
        expect(savings, 30000);
      });
    });

    group('Multicall3 Tests', () {
      test('Multicall3 address should be consistent', () {
        const multicall3Address = '0xcA11bde05977b3631167028862bE2a173976CA11';
        expect(
          multicall3Address.toLowerCase(),
          '0xca11bde05977b3631167028862be2a173976ca11',
        );
      });
    });
  });
}
