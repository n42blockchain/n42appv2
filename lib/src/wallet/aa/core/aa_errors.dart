// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

/// Base class for all Account Abstraction errors
abstract class AAError implements Exception {
  final String message;
  final String? details;
  final int? code;

  const AAError(this.message, {this.details, this.code});

  @override
  String toString() {
    final buffer = StringBuffer('AAError: $message');
    if (details != null) {
      buffer.write(' ($details)');
    }
    if (code != null) {
      buffer.write(' [code: $code]');
    }
    return buffer.toString();
  }
}

/// Error thrown when a chain is not supported for AA
class AAUnsupportedChainError extends AAError {
  final String chainSymbol;

  const AAUnsupportedChainError(this.chainSymbol)
      : super('Chain $chainSymbol is not supported for Account Abstraction');
}

/// Error thrown when UserOperation building fails
class UserOperationBuildError extends AAError {
  const UserOperationBuildError(super.message, {super.details});
}

/// Error thrown when UserOperation validation fails
class UserOperationValidationError extends AAError {
  final String? field;

  const UserOperationValidationError(
    super.message, {
    this.field,
    super.details,
  });

  @override
  String toString() {
    if (field != null) {
      return 'UserOperationValidationError: $message (field: $field)';
    }
    return 'UserOperationValidationError: $message';
  }
}

/// Error thrown when Bundler RPC call fails
class BundlerRpcError extends AAError {
  final String? method;

  const BundlerRpcError(
    super.message, {
    this.method,
    super.code,
    super.details,
  });

  @override
  String toString() {
    final buffer = StringBuffer('BundlerRpcError');
    if (method != null) {
      buffer.write(' ($method)');
    }
    buffer.write(': $message');
    if (code != null) {
      buffer.write(' [code: $code]');
    }
    return buffer.toString();
  }

  /// Check if this is a retryable error
  bool get isRetryable {
    // Network errors and rate limiting are retryable
    if (code == null) return true;
    return code == -32603 || // Internal error
        code == -32000 || // Server error
        code == 429; // Rate limited
  }
}

/// Error thrown when gas estimation fails
class GasEstimationError extends AAError {
  const GasEstimationError(super.message, {super.details});
}

/// Error thrown when smart account operations fail
class SmartAccountError extends AAError {
  final SmartAccountErrorType type;

  const SmartAccountError(
    super.message, {
    required this.type,
    super.details,
  });

  @override
  String toString() {
    return 'SmartAccountError (${type.name}): $message';
  }
}

enum SmartAccountErrorType {
  notDeployed,
  deploymentFailed,
  addressCalculationFailed,
  invalidOwner,
  invalidNonce,
  notFound,
}

/// Error thrown when Paymaster operations fail
class PaymasterError extends AAError {
  final PaymasterErrorType type;

  const PaymasterError(
    super.message, {
    required this.type,
    super.details,
    super.code,
  });

  @override
  String toString() {
    return 'PaymasterError (${type.name}): $message';
  }
}

enum PaymasterErrorType {
  validationFailed,
  insufficientBalance,
  unsupportedToken,
  signatureInvalid,
  expired,
  notAvailable,
}

/// Error thrown when signature operations fail
class SignatureError extends AAError {
  const SignatureError(super.message, {super.details});
}

/// Error thrown when transaction execution fails on-chain
class ExecutionError extends AAError {
  final String? txHash;
  final String? revertReason;

  const ExecutionError(
    super.message, {
    this.txHash,
    this.revertReason,
    super.details,
  });

  @override
  String toString() {
    final buffer = StringBuffer('ExecutionError: $message');
    if (revertReason != null) {
      buffer.write(' (revert: $revertReason)');
    }
    if (txHash != null) {
      buffer.write(' [tx: $txHash]');
    }
    return buffer.toString();
  }
}

/// Error thrown when waiting for UserOperation receipt times out
class ReceiptTimeoutError extends AAError {
  final String userOpHash;

  const ReceiptTimeoutError(this.userOpHash)
      : super('Timeout waiting for UserOperation receipt');

  @override
  String toString() {
    return 'ReceiptTimeoutError: $message (userOpHash: $userOpHash)';
  }
}

/// Error thrown for configuration issues
class AAConfigurationError extends AAError {
  const AAConfigurationError(super.message, {super.details});
}

/// Helper extension for parsing Bundler error responses
extension BundlerErrorParser on Map<String, dynamic> {
  /// Parse bundler error response into appropriate error type
  AAError toAAError() {
    final error = this['error'] as Map<String, dynamic>?;
    if (error == null) {
      return const BundlerRpcError('Unknown bundler error');
    }

    final code = error['code'] as int?;
    final message = error['message'] as String? ?? 'Unknown error';
    final data = error['data']?.toString();

    // Parse specific error types based on code
    switch (code) {
      case -32500:
        return UserOperationValidationError(message, details: data);
      case -32501:
        return SignatureError(message, details: data);
      case -32502:
        return PaymasterError(
          message,
          type: PaymasterErrorType.validationFailed,
          details: data,
          code: code,
        );
      case -32503:
        return GasEstimationError(message, details: data);
      case -32521:
        return ExecutionError(message, revertReason: data);
      default:
        return BundlerRpcError(message, code: code, details: data);
    }
  }
}
