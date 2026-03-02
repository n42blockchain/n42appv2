// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

/// Unified coin price model normalized across all datasources.
class CoinPrice {
  /// Uppercase symbol (e.g. 'BTC', 'ETH').
  final String symbol;

  /// Current USD price.
  final double priceUsd;

  /// 24-hour price change percentage (can be negative).
  final double? change24h;

  /// 24-hour trading volume in USD.
  final double? volume24h;

  /// Market cap in USD.
  final double? marketCap;

  /// Which API source provided this data.
  final String source;

  /// Timestamp when this price was fetched.
  final DateTime fetchedAt;

  const CoinPrice({
    required this.symbol,
    required this.priceUsd,
    this.change24h,
    this.volume24h,
    this.marketCap,
    required this.source,
    required this.fetchedAt,
  });
}
