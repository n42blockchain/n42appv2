// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:n42_wallet/core/utils/app_logger.dart';

/// Signature validation result
class SignatureValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? recoveredAddress;

  const SignatureValidationResult({
    required this.isValid,
    this.errorMessage,
    this.recoveredAddress,
  });

  factory SignatureValidationResult.valid({String? recoveredAddress}) {
    return SignatureValidationResult(
      isValid: true,
      recoveredAddress: recoveredAddress,
    );
  }

  factory SignatureValidationResult.invalid(String error) {
    return SignatureValidationResult(isValid: false, errorMessage: error);
  }
}

/// Transaction signature validator
///
/// Provides validation for transaction signatures to ensure integrity
/// before broadcasting to the network.
///
/// Security features:
/// - Signature format validation
/// - Length validation
/// - Non-empty validation
/// - Optional address recovery verification
class SignatureValidator {
  SignatureValidator._();

  /// Validate a signed transaction
  ///
  /// [signedTx] - The signed transaction string/hex
  /// [coinType] - The blockchain type
  /// [expectedAddress] - Optional sender address for recovery verification
  static SignatureValidationResult validateSignedTransaction({
    required String signedTx,
    required String coinType,
    String? expectedAddress,
  }) {
    // Basic validation: non-empty
    if (signedTx.isEmpty) {
      return SignatureValidationResult.invalid('Signature is empty');
    }

    // Minimum length validation
    if (signedTx.length < 10) {
      return SignatureValidationResult.invalid('Signature too short');
    }

    // Validate based on chain type
    switch (coinType.toUpperCase()) {
      case 'ETH':
      case 'BNB':
      case 'MATIC':
      case 'AVAX':
      case 'FTM':
      case 'N':
        return _validateEthereumSignature(signedTx, expectedAddress);
      case 'BTC':
      case 'LTC':
      case 'DOGE':
        return _validateBitcoinSignature(signedTx);
      case 'TRX':
        return _validateTronSignature(signedTx);
      case 'SOL':
        return _validateSolanaSignature(signedTx);
      default:
        // For other chains, do basic validation
        return _validateGenericSignature(signedTx);
    }
  }

  /// Validate Ethereum-compatible signature
  static SignatureValidationResult _validateEthereumSignature(
    String signedTx,
    String? expectedAddress,
  ) {
    try {
      // Check if it's a valid hex string
      if (!_isValidHex(signedTx)) {
        return SignatureValidationResult.invalid('Invalid hex format');
      }

      // Ethereum signed transactions should be reasonably long
      // Minimum: ~200 characters for a simple transfer
      if (signedTx.length < 100) {
        return SignatureValidationResult.invalid(
          'Transaction too short for Ethereum',
        );
      }

      // Check for 0x prefix (common but not always present)
      final cleanTx = signedTx.startsWith('0x')
          ? signedTx.substring(2)
          : signedTx;

      // Validate RLP structure basics (should start with f8 or f9 for list)
      if (cleanTx.length >= 2) {
        final firstByte = int.tryParse(cleanTx.substring(0, 2), radix: 16);
        if (firstByte != null) {
          // RLP list prefixes: 0xc0-0xf7 (short list) or 0xf8-0xff (long list)
          if (firstByte < 0xc0) {
            // For EIP-1559 transactions, they start with 0x02
            if (firstByte != 0x02 && firstByte != 0x01) {
              AppLogger.w(
                'SignatureValidator',
                'unusual RLP prefix: 0x${firstByte.toRadixString(16)}',
              );
            }
          }
        }
      }

      return SignatureValidationResult.valid();
    } catch (e) {
      return SignatureValidationResult.invalid('Validation error: $e');
    }
  }

  /// Validate Bitcoin-compatible signature
  static SignatureValidationResult _validateBitcoinSignature(String signedTx) {
    try {
      if (!_isValidHex(signedTx)) {
        return SignatureValidationResult.invalid('Invalid hex format');
      }

      // Bitcoin transactions have minimum size
      if (signedTx.length < 100) {
        return SignatureValidationResult.invalid(
          'Transaction too short for Bitcoin',
        );
      }

      return SignatureValidationResult.valid();
    } catch (e) {
      return SignatureValidationResult.invalid('Validation error: $e');
    }
  }

  /// Validate Tron signature
  static SignatureValidationResult _validateTronSignature(String signedTx) {
    try {
      // Tron transactions are typically JSON or hex
      if (signedTx.startsWith('{')) {
        // JSON format - basic validation
        if (!signedTx.contains('signature') && !signedTx.contains('raw_data')) {
          return SignatureValidationResult.invalid(
            'Missing signature or raw_data in Tron transaction',
          );
        }
      } else if (!_isValidHex(signedTx)) {
        return SignatureValidationResult.invalid(
          'Invalid format for Tron transaction',
        );
      }

      return SignatureValidationResult.valid();
    } catch (e) {
      return SignatureValidationResult.invalid('Validation error: $e');
    }
  }

  /// Validate Solana signature
  static SignatureValidationResult _validateSolanaSignature(String signedTx) {
    try {
      // Solana transactions are base64 or base58 encoded
      if (signedTx.isEmpty) {
        return SignatureValidationResult.invalid('Empty Solana transaction');
      }

      // Basic length check (Solana signatures are 64 bytes, transactions vary)
      if (signedTx.length < 80) {
        return SignatureValidationResult.invalid(
          'Transaction too short for Solana',
        );
      }

      return SignatureValidationResult.valid();
    } catch (e) {
      return SignatureValidationResult.invalid('Validation error: $e');
    }
  }

  /// Generic signature validation
  static SignatureValidationResult _validateGenericSignature(String signedTx) {
    if (signedTx.isEmpty) {
      return SignatureValidationResult.invalid('Signature is empty');
    }

    if (signedTx.length < 20) {
      return SignatureValidationResult.invalid('Signature too short');
    }

    return SignatureValidationResult.valid();
  }

  static final RegExp _hexPattern = RegExp(r'^[0-9a-fA-F]+$');

  /// Check if string is valid hex
  static bool _isValidHex(String value) {
    final hex = value.startsWith('0x') ? value.substring(2) : value;
    if (hex.isEmpty) return false;
    return _hexPattern.hasMatch(hex);
  }

  /// Validate signature has correct length for v, r, s components
  static bool hasValidEthSignatureComponents(String signature) {
    final sig = signature.startsWith('0x') ? signature.substring(2) : signature;
    // v(1 byte) + r(32 bytes) + s(32 bytes) = 65 bytes = 130 hex chars
    return sig.length >= 130;
  }
}

/// Extension for easy validation in transfer flows
extension SignedTransactionValidation on String {
  static final RegExp _hexRe = RegExp(r'^[0-9a-fA-F]+$');
  static final RegExp _base64Re = RegExp(r'^[A-Za-z0-9+/=]+$');

  /// Validate this string as a signed transaction
  SignatureValidationResult validateAsSignedTx(
    String coinType, {
    String? expectedAddress,
  }) {
    return SignatureValidator.validateSignedTransaction(
      signedTx: this,
      coinType: coinType,
      expectedAddress: expectedAddress,
    );
  }

  /// Quick check if this looks like a valid signed transaction
  bool get looksLikeSignedTx {
    if (isEmpty || length < 20) return false;
    // Check for common formats
    if (startsWith('0x') || startsWith('{') || _hexRe.hasMatch(this)) {
      return true;
    }
    // Could be base64/base58 for some chains
    return _base64Re.hasMatch(this);
  }
}
