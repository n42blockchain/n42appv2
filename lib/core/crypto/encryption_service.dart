// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'dart:typed_data';

/// Unified Encryption Service Interface
///
/// This interface consolidates all encryption operations in the application:
/// - AES encryption/decryption for messages
/// - File encryption/decryption
/// - Key derivation
/// - Secure random generation
///
/// Implementations:
/// - [AesEncryptionService] - Standard AES encryption (lib/src/chat/utils/aes_utils.dart)
/// - [FileEncryptionService] - File encryption (lib/src/chat/widgets/file_aes_crypt_utils.dart)
/// - [MessageEncryptionService] - Database field encryption (lib/src/chat/utils/message_encryption_service.dart)
abstract class IEncryptionService {
  /// Encrypt a string message
  ///
  /// Returns base64-encoded ciphertext with salt and IV prepended
  String encrypt(String plaintext, String password);

  /// Decrypt a string message
  ///
  /// Expects base64-encoded ciphertext with salt and IV prepended
  String decrypt(String ciphertext, String password);

  /// Check if data appears to be encrypted
  bool isEncrypted(String data);
}

/// File Encryption Service Interface
abstract class IFileEncryptionService {
  /// Encrypt a file at the given path
  ///
  /// Returns the path to the encrypted file, or null on failure
  Future<String?> encryptFile(String filePath, String password);

  /// Decrypt a file at the given path
  ///
  /// Returns the path to the decrypted file, or null on failure
  Future<String?> decryptFile(String filePath, String password);

  /// Encrypt file in background isolate (non-blocking)
  Future<String?> encryptFileInBackground(String filePath, String password);

  /// Decrypt file in background isolate (non-blocking)
  Future<String?> decryptFileInBackground(String filePath, String password);
}

/// Key Derivation Service Interface
abstract class IKeyDerivationService {
  /// Derive a key from password using PBKDF2
  ///
  /// [password] - The password to derive from
  /// [salt] - Salt bytes (generate randomly if not provided)
  /// [keyLength] - Output key length in bytes (default: 32 for AES-256)
  /// [iterations] - PBKDF2 iterations (default: 100000 for security)
  Uint8List deriveKey(
    String password,
    Uint8List salt, {
    int keyLength = 32,
    int iterations = 100000,
  });

  /// Generate cryptographically secure random bytes
  Uint8List generateRandomBytes(int length);

  /// Generate a random IV for AES (16 bytes)
  Uint8List generateIV();

  /// Generate a random salt (16 bytes)
  Uint8List generateSalt();
}

/// Asymmetric Encryption Service Interface (for chat E2E encryption)
abstract class IAsymmetricEncryptionService {
  /// Encrypt message with recipient's public key
  Future<String?> encryptWithPublicKey(String publicKey, String message);

  /// Decrypt message with private key
  Future<String?> decryptWithPrivateKey(String privateKey, String ciphertext);

  /// Generate a key pair
  Future<KeyPair> generateKeyPair();
}

/// Key pair for asymmetric encryption
class KeyPair {
  final String publicKey;
  final String privateKey;

  const KeyPair({
    required this.publicKey,
    required this.privateKey,
  });
}

/// Encryption type enumeration
enum EncryptionType {
  /// AES-256-CBC with PBKDF2 key derivation
  aes256Cbc,

  /// AES-256-GCM (authenticated encryption)
  aes256Gcm,

  /// Legacy AES with fixed IV (deprecated, for migration only)
  aesLegacy,

  /// File-level encryption
  fileAes,

  /// Asymmetric encryption (ECIES)
  asymmetric,
}

/// Encryption result with metadata
class EncryptionResult {
  final String ciphertext;
  final EncryptionType type;
  final DateTime timestamp;

  const EncryptionResult({
    required this.ciphertext,
    required this.type,
    required this.timestamp,
  });
}
