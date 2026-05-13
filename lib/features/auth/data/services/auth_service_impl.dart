// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:injectable/injectable.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/core/security/secure_storage.dart';
import 'package:n42_wallet/shared/domain/entities/wallet_info.dart';
import 'package:n42_wallet/shared/domain/services/auth_service_interface.dart';
import 'package:n42_wallet/features/home/widgets/face_recognition_public.dart';
import 'package:n42_wallet/core/passkey/passkey_service.dart';
import 'package:n42_wallet/core/passkey/passkey_platform_adapter.dart';

/// Implementation of IAuthService
@LazySingleton(as: IAuthService)
class AuthServiceImpl implements IAuthService {
  final SPUtil _spUtil;
  final SecureStorage _secureStorage;
  final StreamController<bool> _authStateController =
      StreamController<bool>.broadcast();

  SharedUserInfo? _currentUser;
  String? _authToken;

  AuthServiceImpl(this._spUtil, this._secureStorage) {
    _initializeFromStorage();
  }

  Future<void> _initializeFromStorage() async {
    try {
      final userInfo = await _spUtil.getUserInfo();
      if (userInfo != null) {
        _currentUser = SharedUserInfo(
          uuid: userInfo['uuid'] ?? '',
          email: userInfo['email'] ?? '',
          name: userInfo['name'],
          avatarUrl: userInfo['image'],
          isLoggedIn: true,
        );
        _authToken = userInfo['token'];
        _authStateController.add(true);
      }
    } catch (e) {
      AppLogger.w('AuthService', 'init error: $e');
      _authStateController.add(false);
    }
  }

  @override
  bool isLoggedIn() => _currentUser != null && _authToken != null;

  @override
  SharedUserInfo? getCurrentUser() => _currentUser;

  @override
  Future<String?> getAuthToken() async => _authToken;

  @override
  Future<bool> verifyPassword(String password) async {
    try {
      if (password.isEmpty) return false;
      final credentials = await _secureStorage.getUserInfo();
      if (credentials == null) return false;
      final storedPassword = credentials['password'] as String?;
      if (storedPassword == null || storedPassword.isEmpty) return false;
      // Use constant-time comparison to prevent timing side-channel attacks.
      // Hash both values so the comparison time is independent of content.
      final storedHash = sha256.convert(utf8.encode(storedPassword)).bytes;
      final inputHash = sha256.convert(utf8.encode(password)).bytes;
      if (storedHash.length != inputHash.length) return false;
      var result = 0;
      for (var i = 0; i < storedHash.length; i++) {
        result |= storedHash[i] ^ inputHash[i];
      }
      return result == 0;
    } catch (e) {
      AppLogger.w('AuthService', 'password verification error: $e');
      return false;
    }
  }

  @override
  Future<bool> verifyBiometric() async {
    try {
      final frp = FaceRecognitionPublic();
      final available = await frp.checkBiometrics();
      if (!available) return false;
      final result = await frp.authenticateWithBiometrics();
      return result == BiometricAuthResult.success;
    } catch (e) {
      AppLogger.w('AuthService', 'biometric auth error: $e');
      return false;
    }
  }

  PasskeyService? _passkeyService;
  PasskeyService get _passkey =>
      _passkeyService ??= PasskeyService(_secureStorage);

  @override
  Future<bool> verifyPasskey() async {
    try {
      final enabled = await _passkey.isEnabled();
      if (!enabled) return false;
      await _passkey.authenticate();
      return true;
    } on PasskeyException catch (e) {
      if (e.isCancelled) return false;
      AppLogger.w('AuthService', 'passkey auth error: $e');
      return false;
    } catch (e) {
      AppLogger.w('AuthService', 'passkey auth error: $e');
      return false;
    }
  }

  @override
  Future<bool> isPasskeyAvailable() async {
    try {
      return PasskeyPlatformAdapter.isSupported();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isPasskeyEnabled() async {
    try {
      return _passkey.isEnabled();
    } catch (_) {
      return false;
    }
  }

  @override
  Stream<bool> get authStateStream => _authStateController.stream;

  @override
  Future<void> logout() async {
    _currentUser = null;
    _authToken = null;
    await _spUtil.saveUserInfo(null);
    await _secureStorage.clearUserData();
    _authStateController.add(false);
  }

  /// Update current user
  void updateUser(SharedUserInfo user) {
    _currentUser = user;
    _authStateController.add(true);
  }

  /// Set auth token
  Future<void> setAuthToken(String token) async {
    _authToken = token;
    await _secureStorage.saveToken(token);
  }

  void dispose() {
    _authStateController.close();
  }
}

/// Provider for IAuthService
final authServiceProvider = Provider<IAuthService>((ref) {
  final spUtil = SPUtil();
  final secureStorage = SecureStorage();
  final service = AuthServiceImpl(spUtil, secureStorage);
  ref.onDispose(() => service.dispose());
  return service;
});

/// Auth State Provider
final authStateProvider = StreamProvider<bool>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateStream;
});

/// Current User Provider
final currentAuthUserProvider = Provider<SharedUserInfo?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.getCurrentUser();
});

/// Is Logged In Provider
final isLoggedInProvider = Provider<bool>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.isLoggedIn();
});
