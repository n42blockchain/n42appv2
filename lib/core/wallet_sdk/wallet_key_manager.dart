import 'package:flutter/services.dart';
import 'package:n42_wallet/core/error/exceptions.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/core/wallet_sdk/models/wallet_sdk_models.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';

/// Manages mnemonic generation/validation, HD derivation, and key operations.
///
/// All methods throw [WalletException] on failure instead of returning empty
/// strings or silent fallbacks. Callers should handle exceptions explicitly.
///
/// Note: [Trustdart] currently swallows all exceptions and returns empty/default
/// values. The [PlatformException] catches here are forward-compatible — they
/// will activate once [Trustdart] is updated to propagate exceptions.
class WalletKeyManager {
  static final _hexPattern = RegExp(r'^[0-9a-fA-F]+$');
  final Trustdart _trustdart;

  WalletKeyManager(this._trustdart);

  String _normalizedNonEmptyString(Object? value) {
    if (value is! String) {
      return '';
    }
    final normalized = value.trim();
    return normalized.isEmpty ? '' : normalized;
  }

  String _extractPrimaryAddress(Object? rawAddress) {
    if (rawAddress is String) {
      return _normalizedNonEmptyString(rawAddress);
    }

    if (rawAddress is Map) {
      final legacy = _normalizedNonEmptyString(rawAddress['legacy']);
      if (legacy.isNotEmpty) {
        return legacy;
      }

      for (final value in rawAddress.values) {
        final candidate = _normalizedNonEmptyString(value);
        if (candidate.isNotEmpty) {
          return candidate;
        }
      }
    }

    return '';
  }

  // ---------------------------------------------------------------------------
  // Mnemonic
  // ---------------------------------------------------------------------------

  /// Generate a BIP-39 mnemonic phrase.
  ///
  /// [strength] bits: 128→12 words, 160→15, 192→18, 224→21, 256→24.
  Future<String> generateMnemonic({
    int strength = 128,
    String passphrase = '',
  }) async {
    try {
      final result = await _trustdart.generateMnemonic(
        passphrase: passphrase,
        length: strength,
      );
      if (result.isEmpty) {
        throw const WalletException(
          message: 'Failed to generate mnemonic',
          code: 'MNEMONIC_GENERATION_FAILED',
        );
      }
      return result;
    } on PlatformException catch (e) {
      throw WalletException(
        message: 'Mnemonic generation failed: ${e.message}',
        code: 'PLATFORM_ERROR',
        originalError: e,
      );
    }
  }

  /// Validate a BIP-39 mnemonic phrase.
  Future<bool> validateMnemonic(
    String mnemonic, {
    String passphrase = '',
  }) async {
    try {
      return await _trustdart.checkMnemonic(mnemonic, passphrase: passphrase);
    } on PlatformException catch (e) {
      AppLogger.w('WalletKeyManager', 'validateMnemonic: $e');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Key derivation
  // ---------------------------------------------------------------------------

  /// Get the hex-encoded public key for a coin at the given derivation path.
  Future<String> getPublicKey({
    required String coin,
    required String path,
    String mnemonic = '',
    String privateKey = '',
    String passphrase = '',
  }) async {
    try {
      final result = await _trustdart.getPublicKey(
        coin,
        path,
        passphrase: passphrase,
        mnemonic: mnemonic,
        pk: privateKey,
      );
      if (result.isEmpty) {
        throw WalletException(
          message: 'Failed to derive public key for $coin',
          code: 'PUBLIC_KEY_DERIVATION_FAILED',
        );
      }
      return result;
    } on PlatformException catch (e) {
      throw WalletException(
        message: 'Public key derivation failed: ${e.message}',
        code: 'PLATFORM_ERROR',
        originalError: e,
      );
    }
  }

  /// Get the hex-encoded private key for a coin at the given derivation path.
  Future<String> getPrivateKey({
    required String mnemonic,
    required String coin,
    required String path,
    String passphrase = '',
  }) async {
    try {
      final result = await _trustdart.getPrivateKey(
        mnemonic,
        coin,
        path,
        passphrase: passphrase,
      );
      if (result.isEmpty) {
        throw WalletException(
          message: 'Failed to derive private key for $coin',
          code: 'PRIVATE_KEY_DERIVATION_FAILED',
        );
      }
      return result;
    } on PlatformException catch (e) {
      throw WalletException(
        message: 'Private key derivation failed: ${e.message}',
        code: 'PLATFORM_ERROR',
        originalError: e,
      );
    }
  }

  /// Get both private key and public key as a [KeyPair].
  Future<KeyPair> getKeyPair({
    required String coin,
    required String path,
    String mnemonic = '',
    String privateKey = '',
    String passphrase = '',
  }) async {
    try {
      final raw = await _trustdart.getPrivateKeyAndPublicKeyPair(
        coin,
        path,
        pk: privateKey,
        mnemonic: mnemonic,
        passphrase: passphrase,
      );
      if (raw.isEmpty) {
        throw WalletException(
          message: 'Failed to derive key pair for $coin',
          code: 'KEY_PAIR_DERIVATION_FAILED',
        );
      }

      // Raw format: "privateKeyHex:publicKeyHex"
      final parts = raw.split(':');
      if (parts.length >= 2) {
        final privatePart = parts[0].trim();
        final publicPart = parts[1].trim();
        if (!_hexPattern.hasMatch(privatePart) || !_hexPattern.hasMatch(publicPart)) {
          throw WalletException(
            message: 'Invalid key pair format: not valid hex',
            code: 'KEY_PAIR_DERIVATION_FAILED',
          );
        }
        return KeyPair(privateKey: privatePart, publicKey: publicPart);
      }

      throw WalletException(
        message: 'Malformed key pair response for $coin',
        code: 'KEY_PAIR_DERIVATION_FAILED',
      );
    } on PlatformException catch (e) {
      throw WalletException(
        message: 'Key pair derivation failed: ${e.message}',
        code: 'PLATFORM_ERROR',
        originalError: e,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Keystore
  // ---------------------------------------------------------------------------

  /// Export a keystore JSON string for the given coin.
  Future<String> exportKeystore({
    required String coin,
    required String path,
    required String addressType,
    required String passphrase,
    String mnemonic = '',
    String privateKey = '',
  }) async {
    try {
      final result = await _trustdart.getKeyStore(
        coin,
        path,
        addressType,
        passphrase,
        mnemonic: mnemonic,
        pk: privateKey,
      );
      if (result.isEmpty) {
        throw WalletException(
          message: 'Failed to export keystore for $coin',
          code: 'KEYSTORE_EXPORT_FAILED',
        );
      }
      return result;
    } on PlatformException catch (e) {
      throw WalletException(
        message: 'Keystore export failed: ${e.message}',
        code: 'PLATFORM_ERROR',
        originalError: e,
      );
    }
  }

  /// Import wallet info from a keystore JSON. Returns [KeystoreInfo].
  Future<KeystoreInfo> importFromKeystore({
    required String keyStore,
    required String coin,
    required String passphrase,
  }) async {
    try {
      final map = await _trustdart.getWalletInfoWithKeyStore(
        keyStore,
        coin,
        passphrase,
      );
      // Native returns address as either String or Map (iOS returns addressMap)
      final address = _extractPrimaryAddress(map['address']);
      final pk = (map['privateKey'] as String?) ?? '';
      if (address.isEmpty) {
        throw WalletException(
          message: 'Invalid keystore or wrong passphrase',
          code: 'KEYSTORE_IMPORT_FAILED',
        );
      }
      return KeystoreInfo(address: address, privateKey: pk);
    } on PlatformException catch (e) {
      throw WalletException(
        message: 'Keystore import failed: ${e.message}',
        code: 'PLATFORM_ERROR',
        originalError: e,
      );
    }
  }
}
