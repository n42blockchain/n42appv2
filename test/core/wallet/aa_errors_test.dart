// Tests for AA error classes and enums in aa_errors.dart.
// All classes are pure Dart with no platform or network dependencies.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/aa/core/aa_errors.dart';

void main() {
  // ─────────────────────────────────────────────────
  // SmartAccountErrorType enum
  // ─────────────────────────────────────────────────

  group('SmartAccountErrorType enum', () {
    test('has 6 values', () {
      expect(SmartAccountErrorType.values.length, 6);
    });

    test('contains all expected values', () {
      expect(SmartAccountErrorType.values, containsAll([
        SmartAccountErrorType.notDeployed,
        SmartAccountErrorType.deploymentFailed,
        SmartAccountErrorType.addressCalculationFailed,
        SmartAccountErrorType.invalidOwner,
        SmartAccountErrorType.invalidNonce,
        SmartAccountErrorType.notFound,
      ]));
    });
  });

  // ─────────────────────────────────────────────────
  // PaymasterErrorType enum
  // ─────────────────────────────────────────────────

  group('PaymasterErrorType enum', () {
    test('has 6 values', () {
      expect(PaymasterErrorType.values.length, 6);
    });

    test('contains all expected values', () {
      expect(PaymasterErrorType.values, containsAll([
        PaymasterErrorType.validationFailed,
        PaymasterErrorType.insufficientBalance,
        PaymasterErrorType.unsupportedToken,
        PaymasterErrorType.signatureInvalid,
        PaymasterErrorType.expired,
        PaymasterErrorType.notAvailable,
      ]));
    });
  });

  // ─────────────────────────────────────────────────
  // AAUnsupportedChainError
  // ─────────────────────────────────────────────────

  group('AAUnsupportedChainError', () {
    test('stores chainSymbol', () {
      const err = AAUnsupportedChainError('BSC');
      expect(err.chainSymbol, 'BSC');
    });

    test('message includes chain symbol', () {
      const err = AAUnsupportedChainError('POLYGON');
      expect(err.message, contains('POLYGON'));
    });

    test('is an AAError (implements Exception)', () {
      const err = AAUnsupportedChainError('ETH');
      expect(err, isA<AAError>());
      expect(err, isA<Exception>());
    });
  });

  // ─────────────────────────────────────────────────
  // AAError base class toString
  // ─────────────────────────────────────────────────

  group('AAError toString', () {
    test('message only → "AAError: <message>"', () {
      const err = UserOperationBuildError('build failed');
      // UserOperationBuildError uses base toString since it does not override
      expect(err.toString(), 'AAError: build failed');
    });

    test('with details → includes parenthesised details', () {
      const err = UserOperationBuildError('build failed', details: 'bad calldata');
      expect(err.toString(), 'AAError: build failed (bad calldata)');
    });

    test('GasEstimationError with code → includes [code: N]', () {
      // GasEstimationError inherits base toString
      const err = GasEstimationError('out of gas');
      // GasEstimationError doesn't pass code, so no code segment
      expect(err.toString(), 'AAError: out of gas');
    });

    test('AAConfigurationError stores message', () {
      const err = AAConfigurationError('bad config', details: 'entryPoint missing');
      expect(err.message, 'bad config');
      expect(err.details, 'entryPoint missing');
    });

    test('SignatureError stores message and details', () {
      const err = SignatureError('invalid sig', details: 'expected v27');
      expect(err.message, 'invalid sig');
      expect(err.details, 'expected v27');
    });
  });

  // ─────────────────────────────────────────────────
  // UserOperationValidationError
  // ─────────────────────────────────────────────────

  group('UserOperationValidationError', () {
    test('without field → "UserOperationValidationError: <message>"', () {
      const err = UserOperationValidationError('nonce mismatch');
      expect(err.toString(), 'UserOperationValidationError: nonce mismatch');
    });

    test('with field → includes "(field: <field>)"', () {
      const err = UserOperationValidationError('invalid value', field: 'callData');
      expect(err.toString(), 'UserOperationValidationError: invalid value (field: callData)');
    });

    test('stores field', () {
      const err = UserOperationValidationError('err', field: 'sender');
      expect(err.field, 'sender');
    });

    test('field is null when not provided', () {
      const err = UserOperationValidationError('err');
      expect(err.field, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // BundlerRpcError — toString
  // ─────────────────────────────────────────────────

  group('BundlerRpcError toString', () {
    test('no method, no code → "BundlerRpcError: <message>"', () {
      const err = BundlerRpcError('call failed');
      expect(err.toString(), 'BundlerRpcError: call failed');
    });

    test('with method → "BundlerRpcError (<method>): <message>"', () {
      const err = BundlerRpcError('call failed', method: 'eth_sendUserOperation');
      expect(err.toString(), 'BundlerRpcError (eth_sendUserOperation): call failed');
    });

    test('with code → appends "[code: N]"', () {
      const err = BundlerRpcError('rate limited', code: 429);
      expect(err.toString(), 'BundlerRpcError: rate limited [code: 429]');
    });

    test('with method and code', () {
      const err = BundlerRpcError('error', method: 'eth_call', code: -32000);
      expect(err.toString(), 'BundlerRpcError (eth_call): error [code: -32000]');
    });
  });

  // ─────────────────────────────────────────────────
  // BundlerRpcError — isRetryable
  // ─────────────────────────────────────────────────

  group('BundlerRpcError.isRetryable', () {
    test('null code → retryable (network error assumed)', () {
      const err = BundlerRpcError('timeout');
      expect(err.isRetryable, isTrue);
    });

    test('code -32603 (Internal error) → retryable', () {
      const err = BundlerRpcError('internal', code: -32603);
      expect(err.isRetryable, isTrue);
    });

    test('code -32000 (Server error) → retryable', () {
      const err = BundlerRpcError('server error', code: -32000);
      expect(err.isRetryable, isTrue);
    });

    test('code 429 (Rate limited) → retryable', () {
      const err = BundlerRpcError('rate limited', code: 429);
      expect(err.isRetryable, isTrue);
    });

    test('code -32500 (validation) → NOT retryable', () {
      const err = BundlerRpcError('validation', code: -32500);
      expect(err.isRetryable, isFalse);
    });

    test('code -32521 (execution reverted) → NOT retryable', () {
      const err = BundlerRpcError('reverted', code: -32521);
      expect(err.isRetryable, isFalse);
    });

    test('unknown code → NOT retryable', () {
      const err = BundlerRpcError('unknown', code: 9999);
      expect(err.isRetryable, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // SmartAccountError
  // ─────────────────────────────────────────────────

  group('SmartAccountError', () {
    test('stores type', () {
      const err = SmartAccountError('not deployed', type: SmartAccountErrorType.notDeployed);
      expect(err.type, SmartAccountErrorType.notDeployed);
    });

    test('toString → "SmartAccountError (<typeName>): <message>"', () {
      const err = SmartAccountError('failed', type: SmartAccountErrorType.deploymentFailed);
      expect(err.toString(), 'SmartAccountError (deploymentFailed): failed');
    });

    test('toString with invalidOwner type', () {
      const err = SmartAccountError('bad owner', type: SmartAccountErrorType.invalidOwner);
      expect(err.toString(), 'SmartAccountError (invalidOwner): bad owner');
    });
  });

  // ─────────────────────────────────────────────────
  // PaymasterError
  // ─────────────────────────────────────────────────

  group('PaymasterError', () {
    test('stores type', () {
      const err = PaymasterError('no funds', type: PaymasterErrorType.insufficientBalance);
      expect(err.type, PaymasterErrorType.insufficientBalance);
    });

    test('toString → "PaymasterError (<typeName>): <message>"', () {
      const err = PaymasterError('token not supported', type: PaymasterErrorType.unsupportedToken);
      expect(err.toString(), 'PaymasterError (unsupportedToken): token not supported');
    });

    test('stores code when provided', () {
      const err = PaymasterError('expired', type: PaymasterErrorType.expired, code: -32502);
      expect(err.code, -32502);
    });
  });

  // ─────────────────────────────────────────────────
  // ExecutionError
  // ─────────────────────────────────────────────────

  group('ExecutionError', () {
    test('toString without txHash or revertReason → "ExecutionError: <message>"', () {
      const err = ExecutionError('tx failed');
      expect(err.toString(), 'ExecutionError: tx failed');
    });

    test('toString with revertReason → includes "(revert: ...)"', () {
      const err = ExecutionError('tx failed', revertReason: 'ERC20: insufficient allowance');
      expect(err.toString(), contains('revert: ERC20: insufficient allowance'));
    });

    test('toString with txHash → includes "[tx: ...]"', () {
      const err = ExecutionError('tx failed', txHash: '0xdeadbeef');
      expect(err.toString(), contains('[tx: 0xdeadbeef]'));
    });

    test('toString with both revertReason and txHash', () {
      const err = ExecutionError(
        'tx failed',
        revertReason: 'revert',
        txHash: '0xabc',
      );
      final str = err.toString();
      expect(str, contains('revert:'));
      expect(str, contains('[tx: 0xabc]'));
    });

    test('stores txHash and revertReason', () {
      const err = ExecutionError('err', txHash: '0x1', revertReason: 'out of gas');
      expect(err.txHash, '0x1');
      expect(err.revertReason, 'out of gas');
    });
  });

  // ─────────────────────────────────────────────────
  // ReceiptTimeoutError
  // ─────────────────────────────────────────────────

  group('ReceiptTimeoutError', () {
    test('stores userOpHash', () {
      const err = ReceiptTimeoutError('0xhash123');
      expect(err.userOpHash, '0xhash123');
    });

    test('message mentions timeout', () {
      const err = ReceiptTimeoutError('0xhash123');
      expect(err.message.toLowerCase(), contains('timeout'));
    });

    test('toString includes userOpHash', () {
      const err = ReceiptTimeoutError('0xhash456');
      expect(err.toString(), contains('0xhash456'));
    });
  });

  // ─────────────────────────────────────────────────
  // BundlerErrorParser.toAAError()
  // ─────────────────────────────────────────────────

  group('BundlerErrorParser.toAAError()', () {
    test('missing "error" key → BundlerRpcError with unknown message', () {
      final result = <String, dynamic>{}.toAAError();
      expect(result, isA<BundlerRpcError>());
      expect(result.message, contains('Unknown'));
    });

    test('null "error" value → BundlerRpcError with unknown message', () {
      final result = <String, dynamic>{'error': null}.toAAError();
      expect(result, isA<BundlerRpcError>());
    });

    test('code -32500 → UserOperationValidationError', () {
      final result = <String, dynamic>{
        'error': {'code': -32500, 'message': 'validation failed'},
      }.toAAError();
      expect(result, isA<UserOperationValidationError>());
      expect(result.message, 'validation failed');
    });

    test('code -32501 → SignatureError', () {
      final result = <String, dynamic>{
        'error': {'code': -32501, 'message': 'bad signature'},
      }.toAAError();
      expect(result, isA<SignatureError>());
    });

    test('code -32502 → PaymasterError with validationFailed type', () {
      final result = <String, dynamic>{
        'error': {'code': -32502, 'message': 'paymaster failed'},
      }.toAAError();
      expect(result, isA<PaymasterError>());
      expect((result as PaymasterError).type, PaymasterErrorType.validationFailed);
    });

    test('code -32503 → GasEstimationError', () {
      final result = <String, dynamic>{
        'error': {'code': -32503, 'message': 'gas estimation failed'},
      }.toAAError();
      expect(result, isA<GasEstimationError>());
    });

    test('code -32521 → ExecutionError', () {
      final result = <String, dynamic>{
        'error': {'code': -32521, 'message': 'execution reverted'},
      }.toAAError();
      expect(result, isA<ExecutionError>());
    });

    test('unknown code → BundlerRpcError with that code', () {
      final result = <String, dynamic>{
        'error': {'code': -99999, 'message': 'weird error'},
      }.toAAError();
      expect(result, isA<BundlerRpcError>());
      expect(result.code, -99999);
      expect(result.message, 'weird error');
    });

    test('missing "message" in error object → defaults to "Unknown error"', () {
      final result = <String, dynamic>{
        'error': {'code': -99999},
      }.toAAError();
      expect(result.message, 'Unknown error');
    });
  });
}
