// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/features/wallet/pages/lending/aave_service.dart';

/// 稳定币活期收益（Stablecoin Earn）纯逻辑 —— Wallet Roadmap S1。
///
/// 把已有的 Aave V3 供给（supply）数据按「稳定币 + APY」聚合，对标
/// Trust Stablecoin Earn / Exodus Pay 一类"稳定币赚币"入口。无网络/UI 依赖，便于单测。
class StablecoinEarnUtils {
  StablecoinEarnUtils._();

  /// 识别为稳定币的符号集合（大写归一后比较）。覆盖主流法币锚定稳定币。
  static const Set<String> stablecoinSymbols = {
    'USDT', 'USDC', 'USDC.E', 'DAI', 'USDA', 'USDE', 'SUSDE',
    'FRAX', 'TUSD', 'BUSD', 'GUSD', 'USDP', 'PYUSD', 'SUSD',
    'USDD', 'LUSD', 'CRVUSD', 'GHO', 'USDS', 'FDUSD', 'USDB',
    'MIM', 'DOLA', 'USD+', 'EURC', 'EURS', 'EURT',
  };

  /// 是否稳定币（忽略大小写与首尾空白）。
  static bool isStablecoin(String symbol) {
    final s = symbol.trim().toUpperCase();
    if (s.isEmpty) return false;
    return stablecoinSymbols.contains(s);
  }

  /// 从一组 Aave reserve 中筛出稳定币，并按供给 APY 降序排序（只保留有流动性的）。
  static List<AaveReserve> filterSortStablecoins(List<AaveReserve> reserves) {
    final list = reserves
        .where((r) => isStablecoin(r.symbol))
        .where((r) => r.totalLiquidityUsd > 0)
        .toList()
      ..sort((a, b) => b.supplyApy.compareTo(a.supplyApy));
    return list;
  }

  /// 取最佳（APY 最高）的稳定币 reserve；无则返回 null。
  static AaveReserve? bestStablecoin(List<AaveReserve> reserves) {
    final sorted = filterSortStablecoins(reserves);
    return sorted.isEmpty ? null : sorted.first;
  }
}
