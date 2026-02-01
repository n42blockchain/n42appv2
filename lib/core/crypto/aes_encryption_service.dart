// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';
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

  /// Add PKCS7 padding
  Uint8List _addPKCS7Padding(Uint8List data, int blockSize) {
    final padLength = blockSize - (data.length % blockSize);
    final padded = Uint8List(data.length + padLength);
    padded.setAll(0, data);
    for (var i = data.length; i < padded.length; i++) {
      padded[i] = padLength;
    }
    return padded;
  }

  /// Remove PKCS7 padding
  Uint8List _removePKCS7Padding(Uint8List data) {
    final padLength = data.last;
    if (padLength > data.length || padLength > 16) {
      throw FormatException('Invalid PKCS7 padding');
    }
    return Uint8List.fromList(data.sublist(0, data.length - padLength));
  }

  @override
  String encrypt(String plaintext, String password) {
    // Generate random salt and IV
    final salt = generateSalt();
    final iv = generateIV();

    // Derive key using PBKDF2
    final derivedKey = deriveKey(password, salt);

    // Create AES-CBC cipher
    final cipher = CBCBlockCipher(AESEngine())
      ..init(true, ParametersWithIV(KeyParameter(derivedKey), iv));

    // Add PKCS7 padding and encrypt
    final plaintextBytes = utf8.encode(plaintext);
    final paddedPlaintext = _addPKCS7Padding(Uint8List.fromList(plaintextBytes), 16);
    final encrypted = Uint8List(paddedPlaintext.length);

    for (var offset = 0; offset < paddedPlaintext.length; offset += 16) {
      cipher.processBlock(paddedPlaintext, offset, encrypted, offset);
    }

    // Combine: salt + iv + ciphertext
    final combined = Uint8List.fromList([
      ...salt,
      ...iv,
      ...encrypted,
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

    // Create AES-CBC cipher for decryption
    final cipher = CBCBlockCipher(AESEngine())
      ..init(false, ParametersWithIV(KeyParameter(derivedKey), iv));

    // Decrypt
    final decrypted = Uint8List(encryptedBytes.length);
    for (var offset = 0; offset < encryptedBytes.length; offset += 16) {
      cipher.processBlock(encryptedBytes, offset, decrypted, offset);
    }

    // Remove PKCS7 padding
    final unpadded = _removePKCS7Padding(decrypted);
    return utf8.decode(unpadded);
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
    final keyBytes = Uint8List.fromList(utf8.encode(password));
    final ivBytes = Uint8List.fromList(utf8.encode(legacyIv));

    // Pad key to 32 bytes if needed
    final paddedKey = Uint8List(32);
    paddedKey.setAll(0, keyBytes.length > 32 ? keyBytes.sublist(0, 32) : keyBytes);

    // Pad IV to 16 bytes if needed
    final paddedIv = Uint8List(16);
    paddedIv.setAll(0, ivBytes.length > 16 ? ivBytes.sublist(0, 16) : ivBytes);

    final encryptedBytes = base64Decode(ciphertext);

    // Create AES-CBC cipher for decryption
    final cipher = CBCBlockCipher(AESEngine())
      ..init(false, ParametersWithIV(KeyParameter(paddedKey), paddedIv));

    // Decrypt
    final decrypted = Uint8List(encryptedBytes.length);
    for (var offset = 0; offset < encryptedBytes.length; offset += 16) {
      cipher.processBlock(encryptedBytes, offset, decrypted, offset);
    }

    // Remove PKCS7 padding
    final unpadded = _removePKCS7Padding(decrypted);
    return utf8.decode(unpadded);
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
