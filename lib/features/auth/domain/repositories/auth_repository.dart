// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:dartz/dartz.dart';
import 'package:n42_wallet/core/error/failures.dart';
import 'package:n42_wallet/features/auth/domain/entities/auth_entity.dart';

/// Auth Repository Interface
///
/// Defines the contract for authentication operations.
abstract class AuthRepository {
  /// Login with email and password
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  /// Login with verification code
  Future<Either<Failure, UserEntity>> loginWithCode({
    required String email,
    required String code,
  });

  /// Register new user
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String code,
  });

  /// Send verification code
  Future<Either<Failure, void>> sendVerificationCode({
    required String email,
    required CodeType type,
  });

  /// Verify code
  Future<Either<Failure, bool>> verifyCode({
    required String email,
    required String code,
    required CodeType type,
  });

  /// Reset password
  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });

  /// Change password
  Future<Either<Failure, void>> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  /// Get current user
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Refresh token
  Future<Either<Failure, AuthTokenEntity>> refreshToken();

  /// Logout
  Future<Either<Failure, void>> logout();

  /// Delete account
  Future<Either<Failure, void>> deleteAccount({
    required String password,
  });

  /// Check if logged in
  Future<bool> isLoggedIn();

  /// Get stored token
  Future<String?> getToken();

  /// Update user profile
  Future<Either<Failure, UserEntity>> updateProfile({
    String? name,
    String? avatar,
    String? description,
  });

  /// Enable/disable Google authenticator
  Future<Either<Failure, GoogleAuthEntity>> setupGoogleAuth();

  /// Verify Google authenticator
  Future<Either<Failure, bool>> verifyGoogleAuth(String code);

  /// Disable Google authenticator
  Future<Either<Failure, void>> disableGoogleAuth(String code);
}

/// Verification Code Type
enum CodeType {
  register,
  login,
  resetPassword,
  changeEmail,
}

