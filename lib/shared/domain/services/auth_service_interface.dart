// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:n42appv2/shared/domain/entities/wallet_info.dart';

/// Auth Service Interface
///
/// Shared interface for authentication operations that can be used across features.
/// This prevents circular dependencies while allowing access to auth state.
abstract class IAuthService {
  /// Check if user is logged in
  bool isLoggedIn();

  /// Get current user info
  SharedUserInfo? getCurrentUser();

  /// Get current auth token
  Future<String?> getAuthToken();

  /// Verify user password
  Future<bool> verifyPassword(String password);

  /// Verify biometric authentication
  Future<bool> verifyBiometric();

  /// Stream of auth state changes
  Stream<bool> get authStateStream;

  /// Logout current user
  Future<void> logout();
}

