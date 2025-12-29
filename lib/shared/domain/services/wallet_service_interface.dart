// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:n42appv2/shared/domain/entities/wallet_info.dart';

/// Wallet Service Interface
///
/// Shared interface for wallet operations that can be used across features.
/// This prevents circular dependencies between features while allowing
/// access to wallet information.
abstract class IWalletService {
  /// Get current selected wallet
  SharedWalletInfo? getCurrentWallet();

  /// Get wallet by address
  SharedWalletInfo? getWalletByAddress(String address);

  /// Get all wallets
  List<SharedWalletInfo> getAllWallets();

  /// Check if wallet exists
  bool walletExists(String address);

  /// Stream of wallet changes
  Stream<SharedWalletInfo?> get currentWalletStream;
}
