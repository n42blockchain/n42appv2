// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:n42_wallet/shared/domain/entities/wallet_info.dart';

/// Shared interface for authentication across features.
abstract class IAuthService {
  bool isLoggedIn();
  SharedUserInfo? getCurrentUser();
  Future<String?> getAuthToken();
  Future<bool> verifyPassword(String password);
  Future<bool> verifyBiometric();
  Future<bool> verifyPasskey();
  Future<bool> isPasskeyAvailable();
  Future<bool> isPasskeyEnabled();
  Stream<bool> get authStateStream;
  Future<void> logout();
}

