// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as aes_encrypt;
import 'package:n42appv2/core/crypto/encryption_service.dart';

/// AES Encryption Service Implementation
///
/// Implements [IEncryptionService] and [IKeyDerivationService] using
/// AES-256-CBC with PBKDF2 key derivation.
///
/// Security features:
/// - Random salt for each encryption
/// - Random IV for each encryption
/// - PBKDF2 with 100,000 iterations
/// - AES-256-CBC with PKCS7 padding
class AesEncryptionService implements IEncryptionService, IKeyDerivationService {
  /// PBKDF2 iteration count (OWASP recommends >= 10,000)
  static const int _pbkdf2Iterations = 100000;

  /// Salt length in bytes
  static const int _saltLength = 16;

  /// IV length in bytes (AES block size)
  static const int _ivLength = 16;

  /// Key length in bytes (AES-256)
  static const int _keyLength = 32;

  /// Secure random number generator
  final Random _secureRandom = Random.secure();

  @override
  Uint8List generateRandomBytes(int length) {
    return Uint8List.fromList(
      List<int>.generate(length, (_) => _secureRandom.nextInt(256)),
    );
  }

  @override
  Uint8List generateIV() => generateRandomBytes(_ivLength);

  @override
  Uint8List generateSalt() => generateRandomBytes(_saltLength);

  @override
  Uint8List deriveKey(
    String password,
    Uint8List salt, {
    int keyLength = 32,
    int iterations = 100000,
  }) {
    final hmac = Hmac(sha256, utf8.encode(password));
    final blocks = (keyLength / 32).ceil();
    final derivedKey = <int>[];

    for (var blockNum = 1; blockNum <= blocks; blockNum++) {
      var block = _pbkdf2Block(hmac, salt, blockNum, iterations);
      derivedKey.addAll(block);
    }

    return Uint8List.fromList(derivedKey.sublist(0, keyLength));
  }

  /// PBKDF2 single block computation
  List<int> _pbkdf2Block(Hmac hmac, Uint8List salt, int blockNum, int iterations) {
    final blockBytes = Uint8List(4);
    blockBytes[0] = (blockNum >> 24) & 0xFF;
    blockBytes[1] = (blockNum >> 16) & 0xFF;
    blockBytes[2] = (blockNum >> 8) & 0xFF;
    blockBytes[3] = blockNum & 0xFF;

    final input = Uint8List.fromList([...salt, ...blockBytes]);
    var u = hmac.convert(input).bytes;
    var result = List<int>.from(u);

    for (var i = 1; i < iterations; i++) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < result.length; j++) {
        result[j] ^= u[j];
      }
    }

    return result;
  }

  @override
  String encrypt(String plaintext, String password) {
    // Generate random salt and IV
    final salt = generateSalt();
    final iv = generateIV();

    // Derive key using PBKDF2
    final derivedKey = deriveKey(password, salt);

    // Create AES encrypter
    final key = aes_encrypt.Key(derivedKey);
    final encrypter = aes_encrypt.Encrypter(
      aes_encrypt.AES(key, mode: aes_encrypt.AESMode.cbc, padding: 'PKCS7'),
    );

    // Encrypt
    final encrypted = encrypter.encrypt(plaintext, iv: aes_encrypt.IV(iv));

    // Combine: salt + iv + ciphertext
    final combined = Uint8List.fromList([
      ...salt,
      ...iv,
      ...encrypted.bytes,
    ]);

    return base64Encode(combined);
  }

  @override
  String decrypt(String ciphertext, String password) {
    // Decode base64
    final combined = base64Decode(ciphertext);

    // Extract salt, iv, ciphertext
    final salt = Uint8List.fromList(combined.sublist(0, _saltLength));
    final iv = Uint8List.fromList(
      combined.sublist(_saltLength, _saltLength + _ivLength),
    );
    final encryptedBytes = Uint8List.fromList(
      combined.sublist(_saltLength + _ivLength),
    );

    // Derive key using PBKDF2
    final derivedKey = deriveKey(password, salt);

    // Create AES decrypter
    final key = aes_encrypt.Key(derivedKey);
    final encrypter = aes_encrypt.Encrypter(
      aes_encrypt.AES(key, mode: aes_encrypt.AESMode.cbc, padding: 'PKCS7'),
    );

    // Decrypt
    return encrypter.decrypt(aes_encrypt.Encrypted(encryptedBytes), iv: aes_encrypt.IV(iv));
  }

  @override
  bool isEncrypted(String data) {
    try {
      final decoded = base64Decode(data);
      // Encrypted data should have at least salt + iv + some ciphertext
      return decoded.length > _saltLength + _ivLength;
    } catch (_) {
      return false;
    }
  }

  /// Decrypt with automatic format detection (new or legacy)
  ///
  /// First tries new format, falls back to legacy if that fails
  String decryptAuto(String ciphertext, String password, {String? legacyIv}) {
    try {
      if (isEncrypted(ciphertext)) {
        return decrypt(ciphertext, password);
      }
    } catch (_) {
      // New format failed, try legacy
    }

    // Legacy format: fixed IV
    if (legacyIv != null) {
      return _decryptLegacy(ciphertext, password, legacyIv);
    }

    throw FormatException('Unable to decrypt: unknown format');
  }

  /// Decrypt legacy format with fixed IV
  String _decryptLegacy(String ciphertext, String password, String legacyIv) {
    final key = aes_encrypt.Key.fromUtf8(password);
    final iv = aes_encrypt.IV.fromUtf8(legacyIv);
    final encrypter = aes_encrypt.Encrypter(
      aes_encrypt.AES(key, mode: aes_encrypt.AESMode.cbc, padding: 'PKCS7'),
    );
    return encrypter.decrypt(aes_encrypt.Encrypted.fromBase64(ciphertext), iv: iv);
  }

  /// Migrate data from legacy format to new format
  String? migrateToSecureFormat(String legacyData, String password, String legacyIv) {
    try {
      final decrypted = _decryptLegacy(legacyData, password, legacyIv);
      return encrypt(decrypted, password);
    } catch (_) {
      return null;
    }
  }
}

/// Singleton instance
final aesEncryptionService = AesEncryptionService();
