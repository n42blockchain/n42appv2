import 'package:flutter/services.dart';
import 'package:n42_wallet/core/error/exceptions.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/core/wallet_sdk/models/wallet_sdk_models.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';

/// Address generation, validation, and chain-specific utilities.
class WalletAddress {
  final Trustdart _trustdart;

  WalletAddress(this._trustdart);

  String _firstNonEmptyAddress(Map<String, String> addresses) {
    return addresses['legacy'] ??
        (addresses.isNotEmpty ? addresses.values.first : '');
  }

  /// Generate a [WalletAccount] for the specified coin.
  ///
  /// Derives the address from [mnemonic] (HD wallet) or [privateKey] (import).
  Future<WalletAccount> generateAddress({
    required String coin,
    required String path,
    required String addressType,
    String mnemonic = '',
    String passphrase = '',
    String privateKey = '',
    bool isImport = false,
    bool isTestnet = false,
  }) async {
    try {
      final Map result = await _trustdart.generateAddress(
        coin,
        path,
        addressType,
        mnemonic: mnemonic,
        passphrase: passphrase,
        pk: privateKey,
        isImport: isImport,
        isTest: isTestnet,
      );

      if (result.isEmpty) {
        throw WalletException(
          message: 'Failed to generate address for $coin',
          code: 'ADDRESS_GENERATION_FAILED',
        );
      }

      // Build typed address map
      final addresses = <String, String>{};
      for (final entry in result.entries) {
        if (entry.value is String) {
          final value = (entry.value as String).trim();
          if (value.isNotEmpty) {
            addresses[entry.key.toString()] = value;
          }
        }
      }

      // Primary address: prefer 'legacy', fall back to first available.
      final primaryAddress = _firstNonEmptyAddress(addresses);
      if (primaryAddress.isEmpty) {
        throw WalletException(
          message: 'Failed to generate address for $coin',
          code: 'ADDRESS_GENERATION_FAILED',
        );
      }

      return WalletAccount(
        coin: coin,
        path: path,
        addressType: addressType,
        address: primaryAddress,
        addresses: addresses,
        isImported: isImport,
      );
    } on PlatformException catch (e) {
      throw WalletException(
        message: 'Address generation failed: ${e.message}',
        code: 'PLATFORM_ERROR',
        originalError: e,
      );
    }
  }

  /// Validate whether [address] is valid for the given [coin].
  Future<bool> validateAddress({
    required String coin,
    required String address,
  }) async {
    try {
      return await _trustdart.validateAddress(coin, address);
    } on PlatformException catch (e) {
      AppLogger.w('WalletAddress', 'validateAddress: $e');
      return false;
    }
  }

  /// Get the Solana Associated Token Account address for a wallet + mint.
  Future<String> getSolanaTokenAccount({
    required String walletAddress,
    required String mintAddress,
  }) async {
    try {
      final result = await _trustdart.getPubKeySOL(walletAddress, mintAddress);
      if (result.isEmpty) {
        throw WalletException(
          message: 'Failed to derive Solana token account',
          code: 'SOL_TOKEN_ACCOUNT_FAILED',
        );
      }
      return result;
    } on PlatformException catch (e) {
      throw WalletException(
        message: 'Solana token account derivation failed: ${e.message}',
        code: 'PLATFORM_ERROR',
        originalError: e,
      );
    }
  }
}
