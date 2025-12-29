// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:n42appv2/features/wallet/domain/entities/wallet_entity.dart';

/// Wallet Remote Data Source Interface
///
/// Defines operations for blockchain API interactions.
abstract class WalletRemoteDataSource {
  /// Get all assets for an address
  Future<List<AssetEntity>> getAssets({
    required String address,
    ChainType? chainType,
  });

  /// Get specific token balance
  Future<AssetEntity?> getTokenBalance({
    required String address,
    required String tokenAddress,
    required ChainType chainType,
  });

  /// Get native coin balance
  Future<BigInt> getNativeBalance({
    required String address,
    required ChainType chainType,
  });

  /// Get token info
  Future<TokenInfo?> getTokenInfo({
    required String tokenAddress,
    required ChainType chainType,
  });

  /// Get gas price
  Future<BigInt> getGasPrice(ChainType chainType);

  /// Get nonce for address
  Future<int> getNonce({
    required String address,
    required ChainType chainType,
  });

  /// Broadcast signed transaction
  Future<String> broadcastTransaction({
    required String signedTx,
    required ChainType chainType,
  });

  /// Get transaction receipt
  Future<TransactionReceipt?> getTransactionReceipt({
    required String txHash,
    required ChainType chainType,
  });
}

/// Token Info Model
class TokenInfo {
  final String address;
  final String name;
  final String symbol;
  final int decimals;
  final String? iconUrl;

  const TokenInfo({
    required this.address,
    required this.name,
    required this.symbol,
    required this.decimals,
    this.iconUrl,
  });
}

/// Transaction Receipt Model
class TransactionReceipt {
  final String txHash;
  final int blockNumber;
  final BigInt gasUsed;
  final bool success;
  final String? errorMessage;

  const TransactionReceipt({
    required this.txHash,
    required this.blockNumber,
    required this.gasUsed,
    required this.success,
    this.errorMessage,
  });
}

