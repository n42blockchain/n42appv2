// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Social authentication result
class SocialAuthResult {
  final bool success;
  final String? provider;
  final String? idToken;
  final String? accessToken;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? userId;
  final String? error;

  /// Apple Sign-In only: the raw (unhashed) nonce used to generate the SHA256
  /// nonce embedded in [idToken]. Pass to your backend so it can verify the
  /// JWT's `nonce` claim via SHA256(rawNonce).
  final String? rawNonce;

  /// True when the user explicitly cancelled the sign-in flow.
  final bool cancelled;

  SocialAuthResult({
    required this.success,
    this.provider,
    this.idToken,
    this.accessToken,
    this.email,
    this.displayName,
    this.photoUrl,
    this.userId,
    this.error,
    this.rawNonce,
    this.cancelled = false,
  });

  factory SocialAuthResult.failure(String error) {
    return SocialAuthResult(success: false, error: error);
  }

  factory SocialAuthResult.cancelled() {
    return SocialAuthResult(success: false, cancelled: true);
  }

  bool get hasUsableIdToken => idToken != null && idToken!.isNotEmpty;
}

/// Social authentication service
/// Handles Google Sign-In and Apple Sign-In
class SocialAuthService {
  static final SocialAuthService _instance = SocialAuthService._internal();
  factory SocialAuthService() => _instance;
  SocialAuthService._internal();

  // Google Sign-In instance (google_sign_in 7.x uses singleton pattern)
  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;

  /// Check if Apple Sign-In is available (iOS 13+ or macOS 10.15+)
  Future<bool> isAppleSignInAvailable() async {
    if (!Platform.isIOS && !Platform.isMacOS) {
      return false;
    }
    return await SignInWithApple.isAvailable();
  }

  /// Sign in with Google
  /// google_sign_in 7.x API changes:
  /// - Uses GoogleSignIn.instance singleton
  /// - authenticate() replaces signIn()
  /// - accessToken requires separate authorization request
  Future<SocialAuthResult> signInWithGoogle() async {
    try {
      // Best-effort sign-out first to ensure account chooser visibility.
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        _debugLog('Google pre-login signOut failed: $e');
      }

      // Authenticate with Google (google_sign_in 7.x)
      final GoogleSignInAccount account = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );

      // Get id token from authentication
      final GoogleSignInAuthentication auth = account.authentication;

      // For access token, need to request authorization separately
      String? accessToken;
      try {
        final authorization = await account.authorizationClient.authorizationForScopes(
          ['email', 'profile'],
        );
        accessToken = authorization?.accessToken;
      } catch (e) {
        _debugLog('Failed to get access token: $e');
        // Continue without access token - idToken is usually sufficient
      }

      return SocialAuthResult(
        success: true,
        provider: 'google',
        idToken: auth.idToken,
        accessToken: accessToken,
        email: account.email,
        displayName: account.displayName,
        photoUrl: account.photoUrl,
        userId: account.id,
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return SocialAuthResult.cancelled();
      }
      _debugLog('Google Sign-In error: $e');
      return SocialAuthResult.failure(e.toString());
    } catch (e) {
      _debugLog('Google Sign-In error: $e');
      return SocialAuthResult.failure(e.toString());
    }
  }

  /// Sign in with Apple
  ///
  /// Generates a cryptographic nonce for each request.  Apple embeds
  /// SHA256(rawNonce) in the returned identity token; the backend must verify
  /// SHA256([SocialAuthResult.rawNonce]) == token's `nonce` claim.
  ///
  /// Apple only returns [email] and the user's full name on the **first**
  /// authorization.  Subsequent logins have `null` for both — use
  /// [SocialAuthResult.userId] (stable sub) to identify the account.
  Future<SocialAuthResult> signInWithApple() async {
    try {
      if (!await isAppleSignInAvailable()) {
        return SocialAuthResult.failure('Apple Sign-In not available');
      }

      // Generate a secure random nonce for this sign-in attempt.
      final rawNonce = _generateNonce();
      final hashedNonce = _sha256ofString(rawNonce);

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      // Build display name from given name and family name.
      // NOTE: Apple only provides these on first login; subsequent logins → null.
      String? displayName;
      if (credential.givenName != null || credential.familyName != null) {
        displayName = [
          credential.givenName,
          credential.familyName,
        ].where((s) => s != null && s.isNotEmpty).join(' ');
      }

      return SocialAuthResult(
        success: true,
        provider: 'apple',
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
        email: credential.email,        // null on re-login — handled by backend
        displayName: displayName,
        userId: credential.userIdentifier,
        rawNonce: rawNonce,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return SocialAuthResult.cancelled();
      }
      _debugLog('Apple Sign-In authorization error: $e');
      return SocialAuthResult.failure(e.message);
    } catch (e) {
      _debugLog('Apple Sign-In error: $e');
      return SocialAuthResult.failure(e.toString());
    }
  }

  // ─── Nonce helpers ────────────────────────────────────────────────────────

  /// Generates a cryptographically-secure random 32-character nonce string.
  String _generateNonce() {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      32,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  /// Returns the SHA256 hex digest of [input].
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Sign out from Google
  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      _debugLog('Google Sign-Out error: $e');
    }
  }

  void _debugLog(String message) {
    if (!kDebugMode) return;
    debugPrint(message);
  }
}
