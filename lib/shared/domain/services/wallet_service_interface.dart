// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:n42_wallet/shared/domain/entities/wallet_info.dart';

/// Shared interface for wallet operations across features.
///
/// Prevents circular dependencies while providing wallet data access.
abstract class IWalletService {
  SharedWalletInfo? getCurrentWallet();
  SharedWalletInfo? getMainWallet();
  SharedWalletInfo? getWalletByAddress(String address);
  List<SharedWalletInfo> getAllWallets();
  int get walletCount;

  SharedWalletInfo? getMiningWallet();
  int get miningWalletIndex;

  bool walletExists(String address);
  Stream<SharedWalletInfo?> get currentWalletStream;

  Future<String?> getChainAddress(String walletId, String chainType);
  Map<String, dynamic>? getCoinInfoForWallet(int walletIndex);
  Future<String?> getPrivateKeyForWallet(int walletIndex);
  Future<String?> getMnemonicForWallet(int walletIndex);
  Future<WalletBalanceInfo?> getBalance(String address, String coinType);

  /// Read the mnemonic and private key for [walletIndex] together.
  ///
  /// Missing fields are returned as empty strings, matching the long-
  /// standing contract relied on by chains that derive their signatures
  /// from the N-coin private key (see [getPrivateKeyForWallet] which
  /// already falls back to mnemonic-derived N-coin keys).
  Future<({String mnemonic, String privateKey})> getCredentials(int walletIndex);

  /// Refresh wallet list from storage after external modifications.
  Future<void> refreshWallets();
}

