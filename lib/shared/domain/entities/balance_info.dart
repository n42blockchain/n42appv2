// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

/// Shared Balance Information Entity
///
/// Represents balance data that can be shared across features
/// (e.g., Wallet and Mining features both need balance info).
class SharedBalanceInfo {
  final String coinSymbol;
  final String coinName;
  final String balance;
  final String? usdValue;
  final String? iconUrl;
  final String? contractAddress;

  const SharedBalanceInfo({
    required this.coinSymbol,
    required this.coinName,
    required this.balance,
    this.usdValue,
    this.iconUrl,
    this.contractAddress,
  });

  /// Check if balance is zero
  bool get isZero {
    try {
      return double.parse(balance) == 0;
    } catch (_) {
      return true;
    }
  }

  /// Get balance as double
  double get balanceAsDouble {
    try {
      return double.parse(balance);
    } catch (_) {
      return 0.0;
    }
  }

  SharedBalanceInfo copyWith({
    String? coinSymbol,
    String? coinName,
    String? balance,
    String? usdValue,
    String? iconUrl,
    String? contractAddress,
  }) {
    return SharedBalanceInfo(
      coinSymbol: coinSymbol ?? this.coinSymbol,
      coinName: coinName ?? this.coinName,
      balance: balance ?? this.balance,
      usdValue: usdValue ?? this.usdValue,
      iconUrl: iconUrl ?? this.iconUrl,
      contractAddress: contractAddress ?? this.contractAddress,
    );
  }

  @override
  String toString() {
    return 'SharedBalanceInfo($coinSymbol: $balance)';
  }
}

