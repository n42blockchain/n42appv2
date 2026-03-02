// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:n42_wallet/shared/domain/entities/wallet_info.dart';

/// Wallet Service Interface
///
/// Shared interface for wallet operations that can be used across features.
/// This prevents circular dependencies between features while allowing
/// access to wallet information.
abstract class IWalletService {
  /// Get current selected wallet
  SharedWalletInfo? getCurrentWallet();

  /// Get main wallet (the wallet marked as main/primary)
  SharedWalletInfo? getMainWallet();

  /// Get wallet by address
  SharedWalletInfo? getWalletByAddress(String address);

  /// Get all wallets
  List<SharedWalletInfo> getAllWallets();

  /// Get wallet count
  int get walletCount;

  /// Get mining wallet (wallet selected for mining)
  SharedWalletInfo? getMiningWallet();

  /// Get mining wallet index
  int get miningWalletIndex;

  /// Check if wallet exists
  bool walletExists(String address);

  /// Stream of wallet changes
  Stream<SharedWalletInfo?> get currentWalletStream;

  /// Get N chain address for a wallet
  ///
  /// Returns the address for the specified chain type
  Future<String?> getChainAddress(String walletId, String chainType);

  /// Get wallet's full coin info (for Mining/advanced features)
  ///
  /// Returns the coinInfo map for the wallet at the given index
  Map<String, dynamic>? getCoinInfoForWallet(int walletIndex);

  /// Get wallet's private key (for signing, only use when necessary)
  ///
  /// Returns the private key for the wallet at the given index
  Future<String?> getPrivateKeyForWallet(int walletIndex);

  /// Get wallet's mnemonic (for backup/recovery, only use when necessary)
  ///
  /// Returns the mnemonic for the wallet at the given index
  Future<String?> getMnemonicForWallet(int walletIndex);

  /// Get balance for a wallet
  ///
  /// Returns the balance info for the specified wallet address and coin type
  Future<WalletBalanceInfo?> getBalance(String address, String coinType);

  /// Refresh wallet list from storage
  ///
  /// Call this after modifying wallet data in SharedPreferences to sync
  /// the WalletListNotifier state with the latest data.
  Future<void> refreshWallets();
}

