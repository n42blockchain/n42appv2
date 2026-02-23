// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:n42_wallet/features/wallet/domain/entities/wallet_entity.dart';

/// Wallet Local Data Source Interface
///
/// Defines operations for local wallet storage.
/// Implementations handle secure storage of wallet data.
abstract class WalletLocalDataSource {
  /// Create a new wallet and store locally
  Future<WalletEntity> createWallet({
    required String name,
    required String password,
    required ChainType chainType,
  });

  /// Import wallet from mnemonic
  Future<WalletEntity> importFromMnemonic({
    required String mnemonic,
    required String name,
    required String password,
    required ChainType chainType,
  });

  /// Import wallet from private key
  Future<WalletEntity> importFromPrivateKey({
    required String privateKey,
    required String name,
    required String password,
    required ChainType chainType,
  });

  /// Get all stored wallets
  Future<List<WalletEntity>> getWallets();

  /// Get wallet by address
  Future<WalletEntity?> getWalletByAddress(String address);

  /// Delete wallet from local storage
  Future<void> deleteWallet(String address);

  /// Update wallet name
  Future<WalletEntity> updateWalletName({
    required String address,
    required String newName,
  });

  /// Export mnemonic (requires password)
  Future<String> exportMnemonic({
    required String address,
    required String password,
  });

  /// Export private key (requires password)
  Future<String> exportPrivateKey({
    required String address,
    required String password,
  });

  /// Verify wallet password
  Future<bool> verifyPassword({
    required String address,
    required String password,
  });

  /// Change wallet password
  Future<void> changePassword({
    required String address,
    required String oldPassword,
    required String newPassword,
  });

  /// Get current selected wallet address
  Future<String?> getCurrentWalletAddress();

  /// Set current selected wallet
  Future<void> setCurrentWallet(String address);
}

