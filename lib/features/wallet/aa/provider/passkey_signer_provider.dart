// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:n42_wallet/core/passkey/passkey_credential.dart';
import 'package:n42_wallet/core/passkey/passkey_platform_adapter.dart';
import 'package:n42_wallet/core/passkey/passkey_service.dart';
import 'package:n42_wallet/core/security/secure_storage.dart';
import 'package:n42_wallet/features/wallet/aa/builder/passkey_signature_builder.dart';
import 'package:n42_wallet/features/wallet/aa/builder/signature_builder.dart';
import 'package:n42_wallet/features/wallet/aa/models/user_operation.dart';

/// Provider for Passkey-based AA signing operations.
///
/// **Status: designed but not wired into the production AA path.** The
/// live transfer signer in `aa_transfer_handler._signUserOperation`
/// signs UserOperations through `trustdart.signMessage` (ECDSA with
/// mnemonic/privateKey), never through this provider — `passkeySignerProvider`
/// has zero consumers across `lib/` and `test/`.
///
/// Kept as the canonical reference for the on-chain P-256 signing path:
/// the supporting infrastructure ([PasskeyService.signUserOperation],
/// [PasskeySignatureBuilder.formatPasskeySignature],
/// [SignatureBuilder.attachSignature]) is real and exercised by Passkey
/// registration/auth — only the final attach-to-transfer step is unwired.
///
/// Migration flow when the production path adopts Passkey signing:
/// 1. Build unsigned UserOperation
/// 2. Compute userOpHash
/// 3. Present WebAuthn assertion prompt with userOpHash as challenge
/// 4. Encode the resulting P-256 signature for on-chain verification
/// 5. Attach encoded signature to UserOperation
class PasskeySignerProvider extends ChangeNotifier {
  final PasskeyService _passkeyService;

  bool _isSigning = false;
  bool get isSigning => _isSigning;

  String? _lastError;
  String? get lastError => _lastError;

  PasskeySignerProvider(this._passkeyService);

  /// Sign a UserOperation using Passkey.
  ///
  /// [userOp] — the unsigned UserOperation.
  /// [entryPoint] — EntryPoint contract address.
  /// [chainId] — target chain.
  /// [credentialId] — specific Passkey to use, or null for primary.
  ///
  /// Returns a new UserOperation with the Passkey signature attached.
  Future<UserOperation?> signUserOperation({
    required UserOperation userOp,
    required String entryPoint,
    required BigInt chainId,
    String? credentialId,
  }) async {
    if (_isSigning) return null;

    _isSigning = true;
    _lastError = null;
    notifyListeners();

    try {
      // 1. Compute userOpHash
      final userOpHash = userOp.getUserOpHash(entryPoint, chainId);

      // 2. Sign with Passkey (presents system biometric prompt)
      final authResult = await _passkeyService.signUserOperation(
        userOpHash: Uint8List.fromList(userOpHash),
        credentialId: credentialId,
      );

      // 3. Encode as on-chain verifiable signature
      final signature = PasskeySignatureBuilder.formatPasskeySignature(authResult);

      // 4. Attach to UserOperation
      return SignatureBuilder.attachSignature(userOp, signature);
    } on PasskeyException catch (e) {
      if (!e.isCancelled) {
        _lastError = e.message;
      }
      return null;
    } catch (e) {
      _lastError = e.toString();
      return null;
    } finally {
      _isSigning = false;
      notifyListeners();
    }
  }

  /// Get the primary Passkey credential for display purposes.
  Future<PasskeyCredential?> getPrimaryCredential() {
    return _passkeyService.getPrimaryCredential();
  }

  /// Check if Passkey signing is available.
  Future<bool> isAvailable() async {
    final supported = await PasskeyPlatformAdapter.isSupported();
    if (!supported) return false;
    return _passkeyService.isEnabled();
  }
}

/// Riverpod provider for PasskeySignerProvider.
final passkeySignerProvider = ChangeNotifierProvider<PasskeySignerProvider>((ref) {
  final secureStorage = SecureStorage();
  final passkeyService = PasskeyService(secureStorage);
  final provider = PasskeySignerProvider(passkeyService);
  ref.onDispose(() => provider.dispose());
  return provider;
});
