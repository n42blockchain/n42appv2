// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:io';
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
  });

  factory SocialAuthResult.failure(String error) {
    return SocialAuthResult(success: false, error: error);
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'provider': provider,
    'idToken': idToken,
    'accessToken': accessToken,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'userId': userId,
    'error': error,
  };
}

/// Supported social auth providers
enum SocialAuthProvider {
  google,
  apple,
  // Future: facebook, twitter, etc.
}

/// Social authentication service
/// Handles Google Sign-In and Apple Sign-In
class SocialAuthService {
  static final SocialAuthService _instance = SocialAuthService._internal();
  factory SocialAuthService() => _instance;
  SocialAuthService._internal();

  // Google Sign-In instance (google_sign_in 7.x uses singleton pattern)
  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;

  // Cache current signed-in account
  GoogleSignInAccount? _currentGoogleAccount;

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
      // Sign out first to ensure fresh login
      await _googleSignIn.signOut();

      // Authenticate with Google (google_sign_in 7.x)
      final GoogleSignInAccount account = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );

      _currentGoogleAccount = account;

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
        debugPrint('Failed to get access token: $e');
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
        return SocialAuthResult.failure('Google sign-in cancelled');
      }
      debugPrint('Google Sign-In error: $e');
      return SocialAuthResult.failure(e.toString());
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      return SocialAuthResult.failure(e.toString());
    }
  }

  /// Sign in with Apple
  Future<SocialAuthResult> signInWithApple() async {
    try {
      if (!await isAppleSignInAvailable()) {
        return SocialAuthResult.failure('Apple Sign-In not available');
      }

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Build display name from given name and family name
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
        email: credential.email,
        displayName: displayName,
        userId: credential.userIdentifier,
      );
    } catch (e) {
      debugPrint('Apple Sign-In error: $e');
      return SocialAuthResult.failure(e.toString());
    }
  }

  /// Sign out from Google
  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
      _currentGoogleAccount = null;
    } catch (e) {
      debugPrint('Google Sign-Out error: $e');
    }
  }

  /// Sign out from all providers
  Future<void> signOutAll() async {
    await signOutGoogle();
    // Apple doesn't have a sign-out method
  }

  /// Get current Google user (if signed in)
  /// Note: google_sign_in 7.x no longer has currentUser getter,
  /// we cache the account from the last successful sign-in
  GoogleSignInAccount? get currentGoogleUser => _currentGoogleAccount;

  /// Check if user is signed in with Google
  /// Note: In google_sign_in 7.x, use attemptLightweightAuthentication
  /// to check for existing session
  Future<bool> isSignedInWithGoogle() async {
    try {
      final account = await _googleSignIn.attemptLightweightAuthentication();
      if (account != null) {
        _currentGoogleAccount = account;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

/// OIDC Configuration for future implementation
class OIDCConfig {
  final String issuer;
  final String clientId;
  final String redirectUri;
  final List<String> scopes;

  OIDCConfig({
    required this.issuer,
    required this.clientId,
    required this.redirectUri,
    this.scopes = const ['openid', 'profile', 'email'],
  });

  /// Validate OIDC configuration
  bool validate() {
    return issuer.isNotEmpty &&
           clientId.isNotEmpty &&
           redirectUri.isNotEmpty;
  }
}

/// SAML Configuration for future implementation
class SAMLConfig {
  final String idpEntityId;
  final String idpSsoUrl;
  final String idpCertificate;
  final String spEntityId;
  final String acsUrl;

  SAMLConfig({
    required this.idpEntityId,
    required this.idpSsoUrl,
    required this.idpCertificate,
    required this.spEntityId,
    required this.acsUrl,
  });

  /// Validate SAML configuration
  bool validate() {
    return idpEntityId.isNotEmpty &&
           idpSsoUrl.isNotEmpty &&
           idpCertificate.isNotEmpty &&
           spEntityId.isNotEmpty &&
           acsUrl.isNotEmpty;
  }
}
