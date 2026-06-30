// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/features/ai_assistant/domain/wallet_snapshot.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';

/// Builds the read-only wallet context used by the wallet AI assistant.
///
/// This intentionally copies only display-safe data from [CoinModel]: symbol,
/// formatted balance, USD value, and chain labels. It never reads keys, seed
/// phrases, addresses, or signing-capable objects.
WalletSnapshot buildWalletAiSnapshot({
  required double totalUsd,
  required Iterable<CoinModel> coins,
  double? gasGwei,
}) {
  final visibleCoins = coins.where((coin) => coin.showList).toList();
  final assets =
      visibleCoins
          .map(_toAsset)
          .where((asset) => asset.balance != '0' || asset.usdValue > 0)
          .toList()
        ..sort((a, b) {
          final byValue = b.usdValue.compareTo(a.usdValue);
          if (byValue != 0) return byValue;
          return a.symbol.compareTo(b.symbol);
        });

  return WalletSnapshot(
    totalUsd: totalUsd,
    assets: assets.take(20).toList(growable: false),
    gasGwei: gasGwei,
    chainName: _chainName(visibleCoins),
  );
}

WalletAsset _toAsset(CoinModel coin) {
  return WalletAsset(
    symbol: _symbol(coin),
    balance: _balance(coin),
    usdValue: coin.value,
  );
}

String _symbol(CoinModel coin) {
  final config = coin.config;
  final candidates = [
    config.miniName,
    config.symbol.toUpperCase(),
    config.coinType,
    config.mKey,
    config.name,
  ];
  return candidates.firstWhere(
    (value) => value.trim().isNotEmpty,
    orElse: () => 'UNKNOWN',
  );
}

String _balance(CoinModel coin) {
  try {
    final balance = coin.balanceStringAll().trim();
    return balance.isEmpty ? '0' : balance;
  } catch (_) {
    return coin.balance.toString();
  }
}

String? _chainName(List<CoinModel> coins) {
  final chainNames = coins
      .where((coin) => !coin.config.isContract)
      .map((coin) {
        final name = coin.config.name.trim();
        if (name.isNotEmpty) return name;
        return coin.config.coinType.trim();
      })
      .where((name) => name.isNotEmpty)
      .toSet();

  if (chainNames.isEmpty) return null;
  if (chainNames.length == 1) return chainNames.first;
  return 'Multi-chain';
}
