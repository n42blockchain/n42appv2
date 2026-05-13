// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:n42_wallet/core/utils/app_logger.dart';

import 'passkey_config.dart';
import 'passkey_credential.dart';

/// Platform-agnostic adapter for WebAuthn Passkey operations.
///
/// Delegates to native implementations via MethodChannel:
/// - Android: Credential Manager API (Android 9+)
/// - iOS/macOS: ASAuthorizationController (iOS 16+ / macOS 13+)
/// - Web: navigator.credentials API (via dart:js_interop)
///
/// Each platform returns raw P-256 public key coordinates and signatures,
/// enabling both application-level auth and on-chain AA signature verification.
class PasskeyPlatformAdapter {
  static const _channel = MethodChannel('n42.wallet/passkey');

  /// Check if the current platform supports Passkeys.
  static Future<bool> isSupported() async {
    try {
      final result = await _channel.invokeMethod<bool>('isSupported');
      return result ?? false;
    } on MissingPluginException {
      return false;
    } catch (e) {
      AppLogger.w('Passkey', 'support check failed: $e');
      return false;
    }
  }

  /// Register a new Passkey credential (WebAuthn registration / attestation).
  ///
  /// [userId] — opaque user identifier (e.g., user UUID).
  /// [userName] — human-readable user name shown in system prompt.
  /// [challenge] — server-generated random challenge (base64url-encoded).
  /// [excludeCredentialIds] — already-registered credential IDs to prevent
  ///   duplicate registrations on the same authenticator.
  ///
  /// Returns a [PasskeyRegistrationResult] containing the credential ID,
  /// raw P-256 public key coordinates, and attestation data.
  ///
  /// Throws [PasskeyException] on failure.
  static Future<PasskeyRegistrationResult> register({
    required String userId,
    required String userName,
    required String challenge,
    List<String> excludeCredentialIds = const [],
  }) async {
    try {
      final result = await _channel
          .invokeMapMethod<String, dynamic>('register', {
            'rpId': PasskeyConfig.rpId,
            'rpName': PasskeyConfig.rpName,
            'userId': userId,
            'userName': userName,
            'challenge': challenge,
            'timeout': PasskeyConfig.timeout,
            'attestation': PasskeyConfig.attestation,
            'authenticatorAttachment': PasskeyConfig.authenticatorAttachment,
            'userVerification': PasskeyConfig.userVerification,
            'requireResidentKey': PasskeyConfig.requireResidentKey,
            'pubKeyCredParams': PasskeyConfig.pubKeyCredParams,
            'excludeCredentialIds': excludeCredentialIds,
          });

      if (result == null) {
        throw PasskeyException('Registration returned null');
      }

      return PasskeyRegistrationResult(
        credentialId: result['credentialId'] as String,
        publicKeyX: result['publicKeyX'] as String,
        publicKeyY: result['publicKeyY'] as String,
        attestationObject: result['attestationObject'] != null
            ? base64Url.decode(result['attestationObject'] as String)
            : null,
        clientDataJSON: base64Url.decode(result['clientDataJSON'] as String),
        backedUp: result['backedUp'] as bool? ?? false,
      );
    } on PlatformException catch (e) {
      throw PasskeyException.fromPlatform(e);
    }
  }

  /// Authenticate with an existing Passkey (WebAuthn assertion).
  ///
  /// [challenge] — server or local challenge to sign (base64url-encoded).
  ///   For AA on-chain signing, this is the userOpHash.
  /// [allowCredentialIds] — restrict to specific credentials. Empty = any.
  ///
  /// Returns a [PasskeyAuthResult] containing the signature components
  /// and authenticator/client data needed for on-chain verification.
  ///
  /// Throws [PasskeyException] on failure.
  static Future<PasskeyAuthResult> authenticate({
    required String challenge,
    List<String> allowCredentialIds = const [],
  }) async {
    try {
      final result = await _channel
          .invokeMapMethod<String, dynamic>('authenticate', {
            'rpId': PasskeyConfig.rpId,
            'challenge': challenge,
            'timeout': PasskeyConfig.timeout,
            'userVerification': PasskeyConfig.userVerification,
            'allowCredentialIds': allowCredentialIds,
          });

      if (result == null) {
        throw PasskeyException('Authentication returned null');
      }

      final authenticatorData = base64Url.decode(
        result['authenticatorData'] as String,
      );
      final clientDataJSON = base64Url.decode(
        result['clientDataJSON'] as String,
      );

      // Parse r, s from DER-encoded or raw signature
      final sigR = BigInt.parse(result['signatureR'] as String, radix: 16);
      final sigS = BigInt.parse(result['signatureS'] as String, radix: 16);

      // Find value offsets in clientDataJSON for on-chain parsing.
      final challengeIndex = _jsonStringValueStart(clientDataJSON, 'challenge');
      final typeIndex = _jsonStringValueStart(clientDataJSON, 'type');

      return PasskeyAuthResult(
        credentialId: result['credentialId'] as String,
        authenticatorData: authenticatorData,
        clientDataJSON: clientDataJSON,
        r: sigR,
        s: sigS,
        challengeIndex: challengeIndex,
        typeIndex: typeIndex,
      );
    } on PlatformException catch (e) {
      throw PasskeyException.fromPlatform(e);
    }
  }

  static int _jsonStringValueStart(Uint8List jsonBytes, String key) {
    final keyBytes = utf8.encode('"$key"');
    for (var i = 0; i <= jsonBytes.length - keyBytes.length; i++) {
      var matched = true;
      for (var j = 0; j < keyBytes.length; j++) {
        if (jsonBytes[i + j] != keyBytes[j]) {
          matched = false;
          break;
        }
      }
      if (!matched) continue;

      var offset = i + keyBytes.length;
      while (offset < jsonBytes.length &&
          _isJsonWhitespace(jsonBytes[offset])) {
        offset++;
      }
      if (offset >= jsonBytes.length || jsonBytes[offset] != 0x3A) {
        continue;
      }
      offset++;
      while (offset < jsonBytes.length &&
          _isJsonWhitespace(jsonBytes[offset])) {
        offset++;
      }
      if (offset < jsonBytes.length && jsonBytes[offset] == 0x22) {
        return offset + 1;
      }
    }
    return -1;
  }

  static bool _isJsonWhitespace(int byte) {
    return byte == 0x20 || byte == 0x0A || byte == 0x0D || byte == 0x09;
  }
}

/// Result from a successful Passkey registration ceremony.
class PasskeyRegistrationResult {
  /// Base64URL-encoded credential ID.
  final String credentialId;

  /// P-256 public key X coordinate (hex, 32 bytes).
  final String publicKeyX;

  /// P-256 public key Y coordinate (hex, 32 bytes).
  final String publicKeyY;

  /// Raw attestation object (CBOR-encoded) — may be null for `attestation: none`.
  final Uint8List? attestationObject;

  /// Raw clientDataJSON from the ceremony.
  final Uint8List clientDataJSON;

  /// Whether the credential is backed up (cloud synced).
  final bool backedUp;

  PasskeyRegistrationResult({
    required this.credentialId,
    required this.publicKeyX,
    required this.publicKeyY,
    this.attestationObject,
    required this.clientDataJSON,
    this.backedUp = false,
  });

  /// Convert to a storable [PasskeyCredential].
  PasskeyCredential toCredential({
    required String label,
    required PasskeyPlatform platform,
  }) {
    return PasskeyCredential(
      credentialId: credentialId,
      publicKeyX: publicKeyX,
      publicKeyY: publicKeyY,
      rpId: PasskeyConfig.rpId,
      label: label,
      createdAt: DateTime.now(),
      platform: platform,
      backedUp: backedUp,
    );
  }
}

/// Exception thrown by Passkey operations.
class PasskeyException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  PasskeyException(this.message, {this.code, this.details});

  factory PasskeyException.fromPlatform(PlatformException e) {
    return PasskeyException(
      e.message ?? 'Unknown passkey error',
      code: e.code,
      details: e.details,
    );
  }

  /// User explicitly cancelled the Passkey prompt.
  bool get isCancelled =>
      code == 'CANCELLED' ||
      code == 'ERROR_CANCELED' ||
      message.contains('cancel');

  /// No matching credential found on this device.
  bool get isNotFound => code == 'NOT_FOUND' || code == 'ERROR_NO_CREDENTIALS';

  /// Platform does not support Passkeys.
  bool get isNotSupported =>
      code == 'NOT_SUPPORTED' || code == 'ERROR_NOT_SUPPORTED';

  @override
  String toString() => 'PasskeyException($code): $message';
}
