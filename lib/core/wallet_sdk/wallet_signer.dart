import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:n42_wallet/core/error/exceptions.dart';
import 'package:n42_wallet/core/wallet_sdk/models/wallet_sdk_models.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';

/// Transaction and message signing for all supported chains.
///
/// **Wallet Core responsibilities** (via this class):
/// - Transaction signing (all chains)
/// - Message signing (EIP-191 personal_sign)
///
/// **web3dart responsibilities** (NOT this class):
/// - ABI encoding/decoding
/// - Contract call construction
/// - Gas estimation, nonce management
class WalletSigner {
  final Trustdart _trustdart;

  WalletSigner(this._trustdart);

  SigningResult _requireRawTransaction({
    required String rawTx,
    required String coin,
    required String operation,
  }) {
    if (rawTx.isEmpty) {
      throw TransactionException(
        message: '$operation returned empty result for $coin',
        code: 'SIGNING_FAILED',
      );
    }

    return SigningResult(rawTx: rawTx);
  }

  // ---------------------------------------------------------------------------
  // Transaction signing
  // ---------------------------------------------------------------------------

  /// Sign a transaction and return the hex-encoded signed data.
  Future<SigningResult> signTransaction({
    required String coin,
    required String path,
    required Map<String, dynamic> txData,
    String mnemonic = '',
    String privateKey = '',
    String passphrase = '',
  }) async {
    try {
      final rawTx = await _trustdart.signTransaction(
        coin,
        path,
        txData,
        mnemonic: mnemonic,
        pk: privateKey,
        passphrase: passphrase,
      );
      return _requireRawTransaction(
        rawTx: rawTx,
        coin: coin,
        operation: 'Transaction signing',
      );
    } on PlatformException catch (e) {
      throw TransactionException(
        message: 'Transaction signing failed for $coin: ${e.message}',
        code: 'SIGNING_FAILED',
        originalError: e,
      );
    }
  }

  /// Sign a transaction with gas estimation variant (_g suffix).
  Future<SigningResult> signTransactionWithGas({
    required String coin,
    required String path,
    required Map<String, dynamic> txData,
    String mnemonic = '',
    String privateKey = '',
    String passphrase = '',
  }) async {
    try {
      final rawTx = await _trustdart.signTransactionG(
        coin,
        path,
        txData,
        mnemonic: mnemonic,
        pk: privateKey,
        passphrase: passphrase,
      );
      return _requireRawTransaction(
        rawTx: rawTx,
        coin: coin,
        operation: 'Transaction signing (gas)',
      );
    } on PlatformException catch (e) {
      throw TransactionException(
        message: 'Transaction signing (gas) failed for $coin: ${e.message}',
        code: 'SIGNING_FAILED',
        originalError: e,
      );
    }
  }

  /// Sign a BTC P2WSH transaction.
  Future<SigningResult> signBtcP2wsh({
    required String path,
    required Map<String, dynamic> txData,
    String mnemonic = '',
    String privateKey = '',
    String passphrase = '',
  }) async {
    try {
      final rawTx = await _trustdart.signTransactionBtcP2wsh(
        'BTC',
        path,
        txData,
        mnemonic: mnemonic,
        pk: privateKey,
        passphrase: passphrase,
      );
      return _requireRawTransaction(
        rawTx: rawTx,
        coin: 'BTC',
        operation: 'BTC P2WSH signing',
      );
    } on PlatformException catch (e) {
      throw TransactionException(
        message: 'BTC P2WSH signing failed: ${e.message}',
        code: 'SIGNING_FAILED',
        originalError: e,
      );
    }
  }

  /// Sign a transaction returning byte array result (e.g. Solana, Aptos).
  Future<ByteArraySigningResult> signTransactionByteArray({
    required String coin,
    required String path,
    required Map<String, dynamic> txData,
    String mnemonic = '',
    String privateKey = '',
    String passphrase = '',
  }) async {
    try {
      final map = await _trustdart.signTransactionByteArray(
        coin,
        path,
        txData,
        mnemonic: mnemonic,
        pk: privateKey,
        passphrase: passphrase,
      );
      final result = ByteArraySigningResult.fromMap(map);
      if (!result.success || result.signHash.isEmpty) {
        throw TransactionException(
          message: 'ByteArray signing returned invalid result for $coin',
          code: 'SIGNING_FAILED',
        );
      }
      return result;
    } on PlatformException catch (e) {
      throw TransactionException(
        message: 'ByteArray signing failed for $coin: ${e.message}',
        code: 'SIGNING_FAILED',
        originalError: e,
      );
    }
  }

  /// Calculate the maximum transaction value (for "send max" feature).
  Future<String> getMaxTransactionValue({
    required String coin,
    required String path,
    required Map<String, dynamic> txData,
    String mnemonic = '',
    String privateKey = '',
    String passphrase = '',
  }) async {
    try {
      final maxValue = await _trustdart.signTransactionMaxValue(
        coin,
        path,
        txData,
        mnemonic: mnemonic,
        pk: privateKey,
        passphrase: passphrase,
      );
      if (maxValue.isEmpty) {
        throw TransactionException(
          message: 'Max value calculation returned empty result for $coin',
          code: 'MAX_VALUE_FAILED',
        );
      }
      return maxValue;
    } on PlatformException catch (e) {
      throw TransactionException(
        message: 'Max value calculation failed for $coin: ${e.message}',
        code: 'MAX_VALUE_FAILED',
        originalError: e,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Message signing
  // ---------------------------------------------------------------------------

  /// Sign an arbitrary message (EIP-191 personal_sign for EVM chains).
  Future<String> signMessage({
    required String coin,
    required String path,
    required String message,
    String mnemonic = '',
    String privateKey = '',
    String passphrase = '',
  }) async {
    try {
      final signature = await _trustdart.signMessage(
        coin,
        path,
        message,
        mnemonic: mnemonic,
        pk: privateKey,
        passphrase: passphrase,
      );
      if (signature.isEmpty) {
        throw TransactionException(
          message: 'Message signing returned empty result for $coin',
          code: 'MESSAGE_SIGNING_FAILED',
        );
      }
      return signature;
    } on PlatformException catch (e) {
      throw TransactionException(
        message: 'Message signing failed for $coin: ${e.message}',
        code: 'SIGNING_FAILED',
        originalError: e,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // EVM utilities
  // ---------------------------------------------------------------------------

  /// Execute an EVM-specific operation via the native channel.
  Future<Map<String, dynamic>?> evmEmit(Map<String, dynamic> params) async {
    try {
      return await _trustdart.evmEmit(params);
    } on PlatformException catch (e) {
      if (kDebugMode) debugPrint('WalletSigner.evmEmit: $e');
      return null;
    }
  }
}
