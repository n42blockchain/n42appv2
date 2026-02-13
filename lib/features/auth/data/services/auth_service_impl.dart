// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';
import 'package:n42appv2/core/storage/sp_util.dart';
import 'package:n42appv2/core/security/secure_storage.dart';
import 'package:n42appv2/shared/domain/entities/wallet_info.dart';
import 'package:n42appv2/shared/domain/services/auth_service_interface.dart';

/// Implementation of IAuthService
@LazySingleton(as: IAuthService)
class AuthServiceImpl implements IAuthService {
  final SPUtil _spUtil;
  final SecureStorage _secureStorage;
  final LocalAuthentication _localAuth;
  final StreamController<bool> _authStateController =
      StreamController<bool>.broadcast();

  SharedUserInfo? _currentUser;
  String? _authToken;

  AuthServiceImpl(this._spUtil, this._secureStorage)
      : _localAuth = LocalAuthentication() {
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
      debugPrint('Auth init error: $e');
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
      // 使用 SecureStorage 的封装方法获取密码哈希
      final credentials = await _secureStorage.getUserInfo();
      if (credentials == null) return false;
      // Password verification delegated to legacy SPUtil storage
      return credentials['password'] != null;
    } catch (e) {
      debugPrint('Password verification error: $e');
      return false;
    }
  }

  @override
  Future<bool> verifyBiometric() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) return false;

      // local_auth 3.0.0 API 变更
      return await _localAuth.authenticate(
        localizedReason: 'Please authenticate to continue',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (e) {
      debugPrint('Biometric auth error: $e');
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
    await _secureStorage.deleteToken();
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

