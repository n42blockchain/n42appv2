// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:n42_wallet/shared/domain/entities/wallet_info.dart';

/// Shared interface for authentication across features.
///
/// **Status: designed surface, partially wired.** Production code currently
/// reads login state from [AppGlobals.userInfo] (static) and the
/// `currentUserProvider` Riverpod state, and calls into
/// `FaceRecognitionPublic` / `PasskeyService` directly for biometric and
/// passkey verification. The unique surface area this interface adds
/// over the production path is:
///
/// - [verifyPassword]: SHA-256 constant-time compare against the password
///   stored by [SecureStorage]. Production has no equivalent — wallet
///   password verification is currently performed inside the wallet UI
///   layer using the legacy `WalletActionProvider`.
/// - [authStateStream]: a reactive stream of login-state changes.
///   Production drives login/logout side-effects through imperative calls
///   into [AppGlobals.login] / [AppGlobals.logout], which fan out to
///   wallet / WalletConnect state synchronously.
///
/// Before wiring this interface into production, note that
/// [AuthServiceImpl.logout] is the simplified form — it does **not**
/// clear `walletListProvider`, reinitialise the wallet adapter, or wipe
/// WalletConnect sessions the way [AppGlobals.logout] does. Any migration
/// must hoist those side-effects in.
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

