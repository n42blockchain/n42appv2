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

  /// Get AST/N chain address for a wallet
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
}

/// Chat Crypto Service Interface
///
/// Handles encryption/decryption operations for the Chat feature.
/// Isolates sensitive key operations from direct access.
abstract class IChatCryptoService {
  /// Get public key for encrypting messages to this wallet
  Future<String?> getPublicKeyForChat();

  /// Get private key for decrypting messages (only from main wallet)
  Future<String?> getPrivateKeyForChat();

  /// Encrypt a message using the recipient's public key
  Future<String?> encryptMessage(String recipientPubKey, String message);

  /// Decrypt a message using wallet's private key
  Future<String?> decryptMessage(String encryptedMessage);

  /// Get all public key and private key pairs from wallets
  ///
  /// Returns a map where key is public key and value is private key.
  /// Used for multi-wallet message decryption.
  Future<Map<String, String>> getPublicKeyAndPrivateKeyPairs();

  /// Decrypt message with auto key selection
  ///
  /// Automatically finds the correct private key based on the public key.
  Future<String?> decryptMessageWithKeyPair(String pubKey, String encryptedMessage);
}
