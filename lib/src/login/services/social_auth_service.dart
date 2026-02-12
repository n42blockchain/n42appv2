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
      // Sign out first to ensure fresh login
      await _googleSignIn.signOut();

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
    } catch (e) {
      debugPrint('Google Sign-Out error: $e');
    }
  }

}
