// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:equatable/equatable.dart';

/// Wallet Entity
///
/// Core domain entity representing a cryptocurrency wallet.
/// This is a pure Dart class with no framework dependencies.
class WalletEntity extends Equatable {
  /// Unique wallet identifier
  final String id;

  /// User-defined wallet name
  final String name;

  /// Wallet address on the blockchain
  final String address;

  /// Chain type identifier (e.g., 'ethereum', 'bitcoin')
  final String chainType;

  /// Wallet creation timestamp
  final DateTime createdAt;

  /// Whether this is an HD wallet
  final bool isHD;

  /// HD derivation path (e.g., "m/44'/60'/0'/0/0")
  final String? derivationPath;

  /// Whether this is a watch-only wallet
  final bool isWatchOnly;

  /// Wallet index in the HD hierarchy
  final int? index;

  /// Mini name/symbol of the primary coin
  final String? coinMiniName;

  const WalletEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.chainType,
    required this.createdAt,
    this.isHD = true,
    this.derivationPath,
    this.isWatchOnly = false,
    this.index,
    this.coinMiniName,
  });

  /// Get shortened address for display
  String get shortAddress {
    if (address.length <= 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  /// Create a copy with modified fields
  WalletEntity copyWith({
    String? id,
    String? name,
    String? address,
    String? chainType,
    DateTime? createdAt,
    bool? isHD,
    String? derivationPath,
    bool? isWatchOnly,
    int? index,
    String? coinMiniName,
  }) {
    return WalletEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      chainType: chainType ?? this.chainType,
      createdAt: createdAt ?? this.createdAt,
      isHD: isHD ?? this.isHD,
      derivationPath: derivationPath ?? this.derivationPath,
      isWatchOnly: isWatchOnly ?? this.isWatchOnly,
      index: index ?? this.index,
      coinMiniName: coinMiniName ?? this.coinMiniName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        chainType,
        createdAt,
        isHD,
        derivationPath,
        isWatchOnly,
        index,
        coinMiniName,
      ];
}

/// Asset Entity
///
/// Represents a token or coin asset in a wallet.
class AssetEntity extends Equatable {
  static final RegExp _trailingZeros = RegExp(r'0+$');

  /// Asset symbol (e.g., 'ETH', 'BTC')
  final String symbol;

  /// Full asset name
  final String name;

  /// Raw balance value
  final BigInt balance;

  /// Number of decimal places
  final int decimals;

  /// Contract address for tokens (null for native coins)
  final String? contractAddress;

  /// Asset icon URL
  final String? iconUrl;

  /// Whether this is a native coin
  final bool isNative;

  /// Current price in USD
  final double? priceUsd;

  /// Chain type this asset belongs to
  final String chainType;

  const AssetEntity({
    required this.symbol,
    required this.name,
    required this.balance,
    required this.decimals,
    required this.chainType,
    this.contractAddress,
    this.iconUrl,
    this.isNative = false,
    this.priceUsd,
  });

  /// Get formatted balance string
  String get formattedBalance {
    if (balance == BigInt.zero) return '0';
    final divisor = BigInt.from(10).pow(decimals);
    final whole = balance ~/ divisor;
    final fraction = balance.remainder(divisor);

    if (fraction == BigInt.zero) return whole.toString();

    final trimmed = fraction
        .toString()
        .padLeft(decimals, '0')
        .replaceAll(_trailingZeros, '');
    return trimmed.isEmpty ? whole.toString() : '$whole.$trimmed';
  }

  /// Get USD value
  double? get valueUsd {
    if (priceUsd == null) return null;
    final divisor = BigInt.from(10).pow(decimals);
    final balanceDouble = balance / divisor;
    return balanceDouble.toDouble() * priceUsd!;
  }

  @override
  List<Object?> get props => [
        symbol,
        name,
        balance,
        decimals,
        contractAddress,
        iconUrl,
        isNative,
        priceUsd,
        chainType,
      ];
}

/// Transaction Entity
class TransactionEntity extends Equatable {
  final String hash;
  final String from;
  final String to;
  final BigInt value;
  final DateTime timestamp;
  final TransactionStatus status;
  final String? errorMessage;
  final BigInt? gasUsed;
  final BigInt? gasPrice;

  const TransactionEntity({
    required this.hash,
    required this.from,
    required this.to,
    required this.value,
    required this.timestamp,
    required this.status,
    this.errorMessage,
    this.gasUsed,
    this.gasPrice,
  });

  @override
  List<Object?> get props => [
        hash,
        from,
        to,
        value,
        timestamp,
        status,
        errorMessage,
        gasUsed,
        gasPrice,
      ];
}

/// Transaction Status
enum TransactionStatus {
  pending,
  confirmed,
  failed,
}

/// Blockchain Chain Types
enum ChainType {
  ethereum,
  bitcoin,
  solana,
  tron,
  filecoin,
  polkadot,
  algorand,
  aptos,
  sui,
  cosmos,
  ripple,
  tezos,
  ton,
}

