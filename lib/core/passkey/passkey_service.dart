// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:n42_wallet/core/security/secure_storage.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';

import 'passkey_credential.dart';
import 'passkey_platform_adapter.dart';

/// High-level Passkey service orchestrating registration, authentication,
/// credential management, and AA signing preparation.
///
/// Coordinates between:
/// - [PasskeyPlatformAdapter] for WebAuthn ceremonies
/// - [SecureStorage] for credential metadata persistence
/// - Backend API for server-side challenge/verification (when available)
class PasskeyService {
  final SecureStorage _secureStorage;

  PasskeyService(this._secureStorage);

  // ==================== Availability ====================

  /// Check if Passkey is available on this device.
  Future<bool> isAvailable() async {
    return PasskeyPlatformAdapter.isSupported();
  }

  /// Check if user has enabled Passkey authentication.
  Future<bool> isEnabled() async {
    final credentials = await getCredentials();
    return credentials.isNotEmpty;
  }

  // ==================== Registration ====================

  /// Register a new Passkey for the current user.
  ///
  /// [userId] — unique user identifier (UUID).
  /// [userName] — display name (email or username).
  /// [label] — device label for this credential.
  ///
  /// Flow:
  /// 1. Generate challenge (local or from server)
  /// 2. Call platform WebAuthn registration
  /// 3. Store credential metadata locally
  /// 4. (Optional) Submit attestation to server
  ///
  /// Returns the newly created [PasskeyCredential].
  Future<PasskeyCredential> registerPasskey({
    required String userId,
    required String userName,
    String? label,
  }) async {
    // Check support
    final supported = await isAvailable();
    if (!supported) {
      throw PasskeyException(
        'Passkey not supported on this device',
        code: 'NOT_SUPPORTED',
      );
    }

    // Get existing credential IDs to exclude (prevent duplicate registration)
    final existing = await getCredentials();
    final excludeIds = existing.map((c) => c.credentialId).toList();

    // Generate challenge
    final challenge = _generateChallenge();

    // Perform WebAuthn registration ceremony
    final result = await PasskeyPlatformAdapter.register(
      userId: userId,
      userName: userName,
      challenge: challenge,
      excludeCredentialIds: excludeIds,
    );

    // Create credential model
    final credential = result.toCredential(
      label: label ?? _defaultLabel(),
      platform: _currentPlatform(),
    );

    // Persist credential metadata
    await _saveCredential(credential);

    return credential;
  }

  // ==================== Authentication ====================

  /// Authenticate using a registered Passkey.
  ///
  /// For app login/unlock flow. Returns [PasskeyAuthResult] on success.
  ///
  /// [credentialId] — specific credential to use, or null for any.
  Future<PasskeyAuthResult> authenticate({String? credentialId}) async {
    final credentials = await getCredentials();
    if (credentials.isEmpty) {
      throw PasskeyException('No passkey registered', code: 'NOT_FOUND');
    }

    final challenge = _generateChallenge();

    final allowIds = credentialId != null
        ? [credentialId]
        : credentials.map((c) => c.credentialId).toList();

    final result = await PasskeyPlatformAdapter.authenticate(
      challenge: challenge,
      allowCredentialIds: allowIds,
    );

    // Update last used timestamp
    await _updateLastUsed(result.credentialId);

    return result;
  }

  /// Sign an AA UserOperation hash with Passkey.
  ///
  /// [userOpHash] — the 32-byte keccak256 hash of the packed UserOperation.
  /// [credentialId] — specific credential to use, or null for primary.
  ///
  /// The userOpHash is passed as the WebAuthn challenge. The resulting
  /// [PasskeyAuthResult] contains all data needed for on-chain verification:
  /// authenticatorData, clientDataJSON, r, s, challengeIndex, typeIndex.
  Future<PasskeyAuthResult> signUserOperation({
    required Uint8List userOpHash,
    String? credentialId,
  }) async {
    if (userOpHash.length != 32) {
      throw PasskeyException(
        'userOpHash must be 32 bytes',
        code: 'INVALID_HASH',
      );
    }

    final credentials = await getCredentials();
    if (credentials.isEmpty) {
      throw PasskeyException('No passkey registered', code: 'NOT_FOUND');
    }

    // Encode userOpHash as base64url challenge for WebAuthn
    final challenge = base64Url.encode(userOpHash).replaceAll('=', '');

    final allowIds = credentialId != null
        ? [credentialId]
        : credentials.map((c) => c.credentialId).toList();

    final result = await PasskeyPlatformAdapter.authenticate(
      challenge: challenge,
      allowCredentialIds: allowIds,
    );

    await _updateLastUsed(result.credentialId);

    return result;
  }

  // ==================== Credential Management ====================

  /// Get all registered Passkey credentials.
  Future<List<PasskeyCredential>> getCredentials() async {
    try {
      final data = await _secureStorage.getPasskeyCredentials();
      if (data == null || data.isEmpty) return [];
      final list = jsonDecode(data) as List<dynamic>;
      return list
          .map((e) => PasskeyCredential.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.w('Passkey', 'failed to load credentials: $e');
      return [];
    }
  }

  /// Get the primary (most recently used) credential.
  Future<PasskeyCredential?> getPrimaryCredential() async {
    final credentials = await getCredentials();
    if (credentials.isEmpty) return null;
    credentials.sort(
      (a, b) =>
          (b.lastUsedAt ?? b.createdAt).compareTo(a.lastUsedAt ?? a.createdAt),
    );
    return credentials.first;
  }

  /// Delete a Passkey credential by ID.
  Future<void> deleteCredential(String credentialId) async {
    final credentials = await getCredentials();
    credentials.removeWhere((c) => c.credentialId == credentialId);
    await _persistCredentials(credentials);
  }

  /// Rename a Passkey credential.
  Future<void> renameCredential(String credentialId, String newLabel) async {
    final credentials = await getCredentials();
    final idx = credentials.indexWhere((c) => c.credentialId == credentialId);
    if (idx >= 0) {
      credentials[idx].label = newLabel;
      await _persistCredentials(credentials);
    }
  }

  /// Find a credential matching a given credential ID.
  Future<PasskeyCredential?> findCredential(String credentialId) async {
    final credentials = await getCredentials();
    try {
      return credentials.firstWhere((c) => c.credentialId == credentialId);
    } catch (_) {
      return null;
    }
  }

  // ==================== Internal ====================

  Future<void> _saveCredential(PasskeyCredential credential) async {
    final credentials = await getCredentials();
    credentials.add(credential);
    await _persistCredentials(credentials);
  }

  Future<void> _persistCredentials(List<PasskeyCredential> credentials) async {
    final json = jsonEncode(credentials.map((c) => c.toJson()).toList());
    await _secureStorage.savePasskeyCredentials(json);
  }

  Future<void> _updateLastUsed(String credentialId) async {
    final credentials = await getCredentials();
    final idx = credentials.indexWhere((c) => c.credentialId == credentialId);
    if (idx >= 0) {
      credentials[idx].lastUsedAt = DateTime.now();
      await _persistCredentials(credentials);
    }
  }

  /// Generate a random 32-byte challenge, base64url-encoded.
  String _generateChallenge() {
    final random = Random.secure();
    final bytes = Uint8List(32);
    for (var i = 0; i < 32; i++) {
      bytes[i] = random.nextInt(256);
    }
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  /// Get a default device label based on platform.
  String _defaultLabel() {
    if (kIsWeb) return 'Web Browser';
    if (Platform.isAndroid) return 'Android Device';
    if (Platform.isIOS) return 'iPhone';
    if (Platform.isMacOS) return 'Mac';
    if (Platform.isWindows) return 'Windows PC';
    return 'Unknown Device';
  }

  /// Determine the current platform.
  PasskeyPlatform _currentPlatform() {
    if (kIsWeb) return PasskeyPlatform.web;
    if (Platform.isAndroid) return PasskeyPlatform.android;
    if (Platform.isIOS) return PasskeyPlatform.ios;
    if (Platform.isMacOS) return PasskeyPlatform.macos;
    if (Platform.isWindows) return PasskeyPlatform.windows;
    return PasskeyPlatform.android;
  }
}
