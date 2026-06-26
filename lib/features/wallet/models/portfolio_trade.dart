// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

/// A single buy-trade record stored in the local SQLite database.
class PortfolioTrade {
  final int? id;
  final String coinId; // CoinGecko ID (e.g. 'bitcoin')
  final String symbol; // lowercase ticker (e.g. 'btc')
  final String name; // display name (e.g. 'Bitcoin')
  final double quantity; // amount purchased
  final double buyPriceUsd; // USD price per coin at purchase
  final int buyTimeMs; // epoch milliseconds

  const PortfolioTrade({
    this.id,
    required this.coinId,
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.buyPriceUsd,
    required this.buyTimeMs,
  });

  factory PortfolioTrade.fromDb(Map<String, dynamic> map) {
    return PortfolioTrade(
      id: map['id'] as int?,
      coinId: map['coin_id'] as String? ?? '',
      symbol: map['symbol'] as String? ?? '',
      name: map['name'] as String? ?? '',
      quantity: _toDouble(map['quantity']),
      buyPriceUsd: _toDouble(map['buy_price_usd']),
      buyTimeMs: map['buy_time_ms'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMapDb() => {
    if (id != null) 'id': id,
    'coin_id': coinId,
    'symbol': symbol,
    'name': name,
    'quantity': quantity,
    'buy_price_usd': buyPriceUsd,
    'buy_time_ms': buyTimeMs,
  };

  DateTime get buyTime => DateTime.fromMillisecondsSinceEpoch(buyTimeMs);

  static double _toDouble(dynamic v, [double fallback = 0.0]) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }
}

// ─── Aggregate P&L view ────────────────────────────────────────────────────

/// Computed aggregate across all trades of a single coin.
/// All monetary values are USD.
class CoinPnlSummary {
  final List<PortfolioTrade> trades;

  CoinPnlSummary(this.trades);

  double get totalQty => trades.fold(0.0, (s, t) => s + t.quantity);

  double get totalCost =>
      trades.fold(0.0, (s, t) => s + t.quantity * t.buyPriceUsd);

  double get avgCost => totalQty > 0 ? totalCost / totalQty : 0.0;

  double pnlUsd(double currentPrice) => (currentPrice - avgCost) * totalQty;

  double pnlPct(double currentPrice) =>
      avgCost > 0 ? (currentPrice - avgCost) / avgCost * 100 : 0.0;
}
