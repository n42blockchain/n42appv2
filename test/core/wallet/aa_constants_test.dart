// Tests for constant values in aa_constants.dart:
//   AAConstants — gas, signature, selector, storage-key, validation, timeout,
//                  error-code constants.
//   NonceKeys — BigInt nonce key space identifiers.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/aa/core/aa_constants.dart';

void main() {
  // ─────────────────────────────────────────────────
  // Gas constants
  // ─────────────────────────────────────────────────

  group('AAConstants gas constants', () {
    test('defaultVerificationGasLimit is 100000', () {
      expect(AAConstants.defaultVerificationGasLimit, 100000);
    });

    test('defaultCallGasLimit is 100000', () {
      expect(AAConstants.defaultCallGasLimit, 100000);
    });

    test('defaultPreVerificationGas is 50000', () {
      expect(AAConstants.defaultPreVerificationGas, 50000);
    });

    test('gasBufferMultiplier is 1.2', () {
      expect(AAConstants.gasBufferMultiplier, closeTo(1.2, 1e-10));
    });

    test('accountDeploymentGas is 300000', () {
      expect(AAConstants.accountDeploymentGas, 300000);
    });
  });

  // ─────────────────────────────────────────────────
  // UserOperation constants
  // ─────────────────────────────────────────────────

  group('AAConstants UserOperation constants', () {
    test('emptyBytes has length 0', () {
      expect(AAConstants.emptyBytes.length, 0);
    });

    test('dummySignature has length 65', () {
      expect(AAConstants.dummySignature.length, 65);
    });

    test('dummySignature all bytes are 0xFF', () {
      for (final byte in AAConstants.dummySignature) {
        expect(byte, 0xFF);
      }
    });

    test('signatureLength is 65', () {
      expect(AAConstants.signatureLength, 65);
    });
  });

  // ─────────────────────────────────────────────────
  // Account type identifiers
  // ─────────────────────────────────────────────────

  group('AAConstants account types', () {
    test('simpleAccountType is "SimpleAccount"', () {
      expect(AAConstants.simpleAccountType, 'SimpleAccount');
    });

    test('safeAccountType is "Safe"', () {
      expect(AAConstants.safeAccountType, 'Safe');
    });

    test('kernelAccountType is "Kernel"', () {
      expect(AAConstants.kernelAccountType, 'Kernel');
    });
  });

  // ─────────────────────────────────────────────────
  // ERC-20 / Execute function selectors
  // ─────────────────────────────────────────────────

  group('AAConstants function selectors', () {
    test('erc20TransferSelector starts with 0x and is 10 chars', () {
      expect(AAConstants.erc20TransferSelector, startsWith('0x'));
      expect(AAConstants.erc20TransferSelector.length, 10);
    });

    test('erc20TransferSelector is "0xa9059cbb"', () {
      expect(AAConstants.erc20TransferSelector, '0xa9059cbb');
    });

    test('erc20ApproveSelector is "0x095ea7b3"', () {
      expect(AAConstants.erc20ApproveSelector, '0x095ea7b3');
    });

    test('executeSelector is "0xb61d27f6"', () {
      expect(AAConstants.executeSelector, '0xb61d27f6');
    });

    test('executeBatchSelector is "0x47e1da2a"', () {
      expect(AAConstants.executeBatchSelector, '0x47e1da2a');
    });

    test('createAccountSelector is "0x5fbfb9cf"', () {
      expect(AAConstants.createAccountSelector, '0x5fbfb9cf');
    });

    test('getAddressSelector is "0x8cb84e18"', () {
      expect(AAConstants.getAddressSelector, '0x8cb84e18');
    });

    test('handleOpsSelector is "0x765e827f"', () {
      expect(AAConstants.handleOpsSelector, '0x765e827f');
    });

    test('getNonceSelector is "0x35567e1a"', () {
      expect(AAConstants.getNonceSelector, '0x35567e1a');
    });
  });

  // ─────────────────────────────────────────────────
  // Storage keys
  // ─────────────────────────────────────────────────

  group('AAConstants storage keys', () {
    test('smartAccountsStorageKey is "smartAccounts"', () {
      expect(AAConstants.smartAccountsStorageKey, 'smartAccounts');
    });

    test('preferAAStorageKey is "preferAA"', () {
      expect(AAConstants.preferAAStorageKey, 'preferAA');
    });

    test('defaultPaymasterStorageKey is "defaultPaymaster"', () {
      expect(AAConstants.defaultPaymasterStorageKey, 'defaultPaymaster');
    });
  });

  // ─────────────────────────────────────────────────
  // Validation constants
  // ─────────────────────────────────────────────────

  group('AAConstants validation constants', () {
    test('maxCalldataSize is 128 * 1024 = 131072', () {
      expect(AAConstants.maxCalldataSize, 128 * 1024);
      expect(AAConstants.maxCalldataSize, 131072);
    });

    test('maxNonce is 2^192 - 1', () {
      final expected = BigInt.two.pow(192) - BigInt.one;
      expect(AAConstants.maxNonce, expected);
    });

    test('maxNonce is positive and very large', () {
      expect(AAConstants.maxNonce > BigInt.zero, isTrue);
      expect(AAConstants.maxNonce > BigInt.from(10).pow(57), isTrue);
    });

    test('minPreVerificationGas is 21000', () {
      expect(AAConstants.minPreVerificationGas, 21000);
    });
  });

  // ─────────────────────────────────────────────────
  // Timeout constants
  // ─────────────────────────────────────────────────

  group('AAConstants timeout constants', () {
    test('bundlerRpcTimeout is 30000 ms (30 seconds)', () {
      expect(AAConstants.bundlerRpcTimeout, 30000);
    });

    test('confirmationTimeout is 120000 ms (2 minutes)', () {
      expect(AAConstants.confirmationTimeout, 120000);
    });

    test('receiptPollingInterval is 2000 ms (2 seconds)', () {
      expect(AAConstants.receiptPollingInterval, 2000);
    });
  });

  // ─────────────────────────────────────────────────
  // Error codes
  // ─────────────────────────────────────────────────

  group('AAConstants error codes', () {
    test('errorInvalidUserOp is -32500', () {
      expect(AAConstants.errorInvalidUserOp, -32500);
    });

    test('errorExecutionReverted is -32521', () {
      expect(AAConstants.errorExecutionReverted, -32521);
    });

    test('errorPaymasterValidation is -32502', () {
      expect(AAConstants.errorPaymasterValidation, -32502);
    });

    test('errorInsufficientFunds is -32503', () {
      expect(AAConstants.errorInsufficientFunds, -32503);
    });
  });

  // ─────────────────────────────────────────────────
  // NonceKeys
  // ─────────────────────────────────────────────────

  group('NonceKeys', () {
    test('defaultKey is BigInt.zero', () {
      expect(NonceKeys.defaultKey, BigInt.zero);
    });

    test('sessionKeySpace is BigInt.from(1)', () {
      expect(NonceKeys.sessionKeySpace, BigInt.one);
    });

    test('batchSpace is BigInt.from(2)', () {
      expect(NonceKeys.batchSpace, BigInt.from(2));
    });

    test('all keys are distinct', () {
      expect(NonceKeys.defaultKey, isNot(NonceKeys.sessionKeySpace));
      expect(NonceKeys.sessionKeySpace, isNot(NonceKeys.batchSpace));
    });
  });
}
