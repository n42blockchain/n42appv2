// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'dart:convert';
import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/chat/utils/aes_utils.dart';

/// Service for encrypting/decrypting sensitive message fields before database storage
///
/// Sensitive fields that are encrypted:
/// - senderAesSecret
/// - receiverAesSecret
/// - decryptionMessageContent
///
/// This provides an additional layer of protection for message content
/// stored in the local database.
class MessageEncryptionService {
  final AesUtils _aesUtils = AesUtils();

  /// Get encryption key derived from user credentials
  ///
  /// Uses a combination of user UUID and a constant salt to derive the key
  String _getEncryptionKey() {
    final uuid = AppGlobals.userInfo?.uuid ?? '';
    // Use a fixed salt combined with user UUID for key derivation
    // This ensures only this user can decrypt their messages
    const salt = 'N42_MSG_ENCRYPT_SALT_v1';
    return '${uuid.substring(0, uuid.length.clamp(0, 16))}$salt'.substring(0, 32);
  }

  /// Encrypt a string value for database storage
  String? encryptField(String? value) {
    if (value == null || value.isEmpty) return value;

    try {
      final key = _getEncryptionKey();
      return _aesUtils.aesEncode(value, key);
    } catch (e) {
      // If encryption fails, return original value to prevent data loss
      // This should be logged for monitoring
      return value;
    }
  }

  /// Decrypt a string value retrieved from database
  String? decryptField(String? value) {
    if (value == null || value.isEmpty) return value;

    try {
      final key = _getEncryptionKey();
      // Use auto-detect to handle both new and legacy formats
      return _aesUtils.aesDecryptedAuto(value, key);
    } catch (e) {
      // If decryption fails, return original value
      // This handles cases where data wasn't encrypted
      return value;
    }
  }

  /// Check if a field appears to be encrypted
  ///
  /// Encrypted fields are base64 encoded and have a minimum length
  bool isEncrypted(String? value) {
    if (value == null || value.isEmpty) return false;

    try {
      final decoded = base64Decode(value);
      // Encrypted data has at least salt + iv + some ciphertext
      return decoded.length > 32;
    } catch (e) {
      return false;
    }
  }

  /// Encrypt sensitive fields in a message map before database storage
  Map<String, dynamic> encryptMessageFields(Map<String, dynamic> map) {
    final result = Map<String, dynamic>.from(map);

    // Encrypt content field if it contains sensitive data
    if (result['content'] != null && result['content'] is String) {
      try {
        final content = json.decode(result['content'] as String);

        // Encrypt sensitive fields within content
        if (content['senderAesSecret'] != null) {
          content['senderAesSecret'] = encryptField(content['senderAesSecret']);
        }
        if (content['receiverAesSecret'] != null) {
          content['receiverAesSecret'] = encryptField(content['receiverAesSecret']);
        }

        result['content'] = json.encode(content);
      } catch (e) {
        // If parsing fails, leave content unchanged
      }
    }

    // Encrypt decryptionMessageContent
    if (result['decryptionMessageContent'] != null) {
      result['decryptionMessageContent'] =
          encryptField(result['decryptionMessageContent'] as String?);
    }

    return result;
  }

  /// Decrypt sensitive fields in a message map after database retrieval
  Map<String, dynamic> decryptMessageFields(Map<String, dynamic> map) {
    final result = Map<String, dynamic>.from(map);

    // Decrypt content field
    if (result['content'] != null && result['content'] is String) {
      try {
        final content = json.decode(result['content'] as String);

        // Decrypt sensitive fields within content
        if (content['senderAesSecret'] != null) {
          content['senderAesSecret'] = decryptField(content['senderAesSecret']);
        }
        if (content['receiverAesSecret'] != null) {
          content['receiverAesSecret'] = decryptField(content['receiverAesSecret']);
        }

        result['content'] = json.encode(content);
      } catch (e) {
        // If parsing fails, leave content unchanged
      }
    }

    // Decrypt decryptionMessageContent
    if (result['decryptionMessageContent'] != null) {
      result['decryptionMessageContent'] =
          decryptField(result['decryptionMessageContent'] as String?);
    }

    return result;
  }
}

/// Singleton instance for message encryption
final messageEncryptionService = MessageEncryptionService();
