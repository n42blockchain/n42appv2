// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:dartz/dartz.dart';
import 'package:n42_wallet/core/error/failures.dart';
import 'package:n42_wallet/features/wallet/domain/entities/wallet_entity.dart';

/// Wallet Repository Interface
///
/// Defines the contract for wallet data operations.
/// Implementations should handle data source details.
abstract class WalletRepository {
  /// Create a new wallet
  Future<Either<Failure, WalletEntity>> createWallet({
    required String name,
    required String password,
    required ChainType chainType,
  });

  /// Import wallet from mnemonic
  Future<Either<Failure, WalletEntity>> importFromMnemonic({
    required String mnemonic,
    required String name,
    required String password,
    required ChainType chainType,
  });

  /// Import wallet from private key
  Future<Either<Failure, WalletEntity>> importFromPrivateKey({
    required String privateKey,
    required String name,
    required String password,
    required ChainType chainType,
  });

  /// Get all wallets
  Future<Either<Failure, List<WalletEntity>>> getWallets();

  /// Get wallet by address
  Future<Either<Failure, WalletEntity?>> getWalletByAddress(String address);

  /// Get assets for wallet
  Future<Either<Failure, List<AssetEntity>>> getAssets({
    required String address,
    ChainType? chainType,
  });

  /// Get balance for specific token
  Future<Either<Failure, AssetEntity?>> getTokenBalance({
    required String address,
    required String tokenAddress,
    required ChainType chainType,
  });

  /// Delete wallet
  Future<Either<Failure, void>> deleteWallet(String address);

  /// Update wallet name
  Future<Either<Failure, WalletEntity>> updateWalletName({
    required String address,
    required String newName,
  });

  /// Export mnemonic (requires password verification)
  Future<Either<Failure, String>> exportMnemonic({
    required String address,
    required String password,
  });

  /// Export private key (requires password verification)
  Future<Either<Failure, String>> exportPrivateKey({
    required String address,
    required String password,
  });

  /// Verify wallet password
  Future<Either<Failure, bool>> verifyPassword({
    required String address,
    required String password,
  });

  /// Change wallet password
  Future<Either<Failure, void>> changePassword({
    required String address,
    required String oldPassword,
    required String newPassword,
  });
}

