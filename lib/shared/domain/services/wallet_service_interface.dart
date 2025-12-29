// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:n42appv2/shared/domain/entities/wallet_info.dart';
import 'package:n42appv2/shared/domain/entities/balance_info.dart';

/// Wallet Service Interface
///
/// This interface allows other features (like Mining) to access wallet
/// functionality without direct dependency on the Wallet feature.
///
/// The Wallet feature implements this interface, and other features
/// depend only on this abstraction.
abstract class IWalletService {
  /// Get current selected wallet
  SharedWalletInfo? get currentWallet;

  /// Get all wallets
  List<SharedWalletInfo> get wallets;

  /// Get wallet by address
  SharedWalletInfo? getWalletByAddress(String address);

  /// Get wallet by index
  SharedWalletInfo? getWalletByIndex(int index);

  /// Get balance for specific coin
  Future<SharedBalanceInfo?> getBalance(String address, String coinSymbol);

  /// Get all balances for wallet
  Future<List<SharedBalanceInfo>> getAllBalances(String address);

  /// Check if wallet exists
  bool hasWallet(String address);

  /// Get wallet count
  int get walletCount;

  /// Stream of wallet changes
  Stream<SharedWalletInfo?> get currentWalletStream;
}

