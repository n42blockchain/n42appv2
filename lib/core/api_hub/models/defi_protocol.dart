// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

/// DeFi protocol TVL data from DeFi Llama.
class DefiProtocol {
  final String id;
  final String name;
  final String? symbol;
  final double tvl;
  final double? change1d;
  final double? change7d;
  final String? category;
  final List<String> chains;
  final String? logoUrl;

  const DefiProtocol({
    required this.id,
    required this.name,
    this.symbol,
    required this.tvl,
    this.change1d,
    this.change7d,
    this.category,
    this.chains = const [],
    this.logoUrl,
  });
}

/// DeFi yield/pool data from DeFi Llama.
class DefiYield {
  final String pool;
  final String project;
  final String chain;
  final String symbol;
  final double tvlUsd;
  final double? apyBase;
  final double? apyReward;
  final double? apy;

  const DefiYield({
    required this.pool,
    required this.project,
    required this.chain,
    required this.symbol,
    required this.tvlUsd,
    this.apyBase,
    this.apyReward,
    this.apy,
  });
}
