// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:n42_wallet/core/utils/app_logger.dart';

/// Hyperliquid perpetual DEX integration.
///
/// Hyperliquid is a fully on-chain order-book DEX for perpetual futures.
/// Key features:
/// - Up to 50x leverage on major pairs
/// - Sub-second settlement on custom L1
/// - No gas fees for trading (only for deposits/withdrawals)
/// - API-compatible for programmatic trading
///
/// API docs: https://hyperliquid.gitbook.io/hyperliquid-docs/
class HyperliquidService {
  HyperliquidService._();

  static const String _infoUrl = 'https://api.hyperliquid.xyz/info';

  /// Exchange endpoint for order submission (requires EIP-712 signing).
  static const String exchangeUrl = 'https://api.hyperliquid.xyz/exchange';

  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Content-Type': 'application/json'},
  ));

  // ==================== Market Data ====================

  /// Fetch all available perpetual markets with current prices.
  static Future<List<PerpMarket>> getMarkets() async {
    try {
      final response = await _dio.post(
        _infoUrl,
        data: jsonEncode({'type': 'metaAndAssetCtxs'}),
      );

      if (response.data is! List || (response.data as List).length < 2) {
        return [];
      }

      final meta = response.data[0] as Map<String, dynamic>;
      final assetCtxs = response.data[1] as List<dynamic>;
      final universe = meta['universe'] as List<dynamic>? ?? [];

      final markets = <PerpMarket>[];
      for (var i = 0; i < universe.length && i < assetCtxs.length; i++) {
        final info = universe[i] as Map<String, dynamic>;
        final ctx = assetCtxs[i] as Map<String, dynamic>;

        markets.add(PerpMarket(
          symbol: info['name'] as String? ?? '',
          szDecimals: info['szDecimals'] as int? ?? 2,
          maxLeverage: info['maxLeverage'] as int? ?? 50,
          markPrice: double.tryParse(ctx['markPx']?.toString() ?? '') ?? 0,
          oraclePrice: double.tryParse(ctx['oraclePx']?.toString() ?? '') ?? 0,
          volume24h: double.tryParse(ctx['dayNtlVlm']?.toString() ?? '') ?? 0,
          openInterest: double.tryParse(ctx['openInterest']?.toString() ?? '') ?? 0,
          fundingRate: double.tryParse(ctx['funding']?.toString() ?? '') ?? 0,
          priceChange24h: double.tryParse(ctx['prevDayPx']?.toString() ?? '') ?? 0,
        ));
      }

      return markets;
    } catch (e) {
      AppLogger.w('Hyperliquid', 'markets error: $e');
      return [];
    }
  }

  /// Fetch clearinghouse state (positions + margin) in a single API call.
  ///
  /// Avoids duplicate requests since both getPositions and getMarginSummary
  /// need the same endpoint.
  static Future<ClearinghouseState> getClearinghouseState(String address) async {
    try {
      final response = await _dio.post(
        _infoUrl,
        data: jsonEncode({
          'type': 'clearinghouseState',
          'user': address.toLowerCase(),
        }),
      );

      final data = response.data as Map<String, dynamic>?;
      if (data == null) return ClearinghouseState.empty();

      final assetPositions = data['assetPositions'] as List<dynamic>? ?? [];
      final positions = assetPositions
          .map((p) {
            final pos = p['position'] as Map<String, dynamic>?;
            if (pos == null) return null;
            return PerpPosition.fromJson(pos);
          })
          .whereType<PerpPosition>()
          .where((p) => p.size != 0)
          .toList();

      final marginData = data['marginSummary'] as Map<String, dynamic>?;
      final margin = marginData != null
          ? MarginSummary(
              accountValue: double.tryParse(marginData['accountValue']?.toString() ?? '') ?? 0,
              totalMarginUsed: double.tryParse(marginData['totalMarginUsed']?.toString() ?? '') ?? 0,
              totalNtlPos: double.tryParse(marginData['totalNtlPos']?.toString() ?? '') ?? 0,
              totalRawUsd: double.tryParse(marginData['totalRawUsd']?.toString() ?? '') ?? 0,
            )
          : null;

      return ClearinghouseState(positions: positions, margin: margin);
    } catch (e) {
      AppLogger.w('Hyperliquid', 'clearinghouse error: $e');
      return ClearinghouseState.empty();
    }
  }

  /// Fetch user's open positions (convenience wrapper).
  static Future<List<PerpPosition>> getPositions(String address) async {
    final state = await getClearinghouseState(address);
    return state.positions;
  }

  /// Fetch user's open orders.
  static Future<List<PerpOrder>> getOpenOrders(String address) async {
    try {
      final response = await _dio.post(
        _infoUrl,
        data: jsonEncode({
          'type': 'openOrders',
          'user': address.toLowerCase(),
        }),
      );

      if (response.data is! List) return [];

      return (response.data as List<dynamic>)
          .map((o) => PerpOrder.fromJson(o as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.w('Hyperliquid', 'orders error: $e');
      return [];
    }
  }

  /// Fetch order book for a market.
  static Future<OrderBook?> getOrderBook(String symbol) async {
    try {
      final response = await _dio.post(
        _infoUrl,
        data: jsonEncode({
          'type': 'l2Book',
          'coin': symbol,
        }),
      );

      final data = response.data as Map<String, dynamic>?;
      if (data == null) return null;

      final levels = data['levels'] as List<dynamic>? ?? [];
      if (levels.length < 2) return null;

      return OrderBook(
        bids: _parseLevels(levels[0] as List<dynamic>),
        asks: _parseLevels(levels[1] as List<dynamic>),
      );
    } catch (e) {
      AppLogger.w('Hyperliquid', 'orderbook error: $e');
      return null;
    }
  }

  /// Fetch account margin summary (convenience wrapper).
  static Future<MarginSummary?> getMarginSummary(String address) async {
    final state = await getClearinghouseState(address);
    return state.margin;
  }

  // ==================== Order Building ====================

  /// Build a market order payload.
  ///
  /// Note: Actual order submission requires EIP-712 signing with the user's
  /// private key. The signed payload is sent to the exchange endpoint.
  static Map<String, dynamic> buildMarketOrder({
    required int assetIndex,
    required bool isBuy,
    required double size,
    required double slippageBps, // basis points, e.g. 50 = 0.5%
    double? markPrice,
  }) {
    // For market orders, use a limit price with slippage
    final price = markPrice ?? 0;
    final slippageMultiplier = isBuy
        ? (1 + slippageBps / 10000)
        : (1 - slippageBps / 10000);
    final limitPrice = price * slippageMultiplier;

    return {
      'type': 'order',
      'orders': [
        {
          'a': assetIndex,
          'b': isBuy,
          's': size.toString(),
          'r': false, // not reduce only
          't': {
            'limit': {
              'tif': 'Ioc', // Immediate or Cancel for market-like behavior
            },
          },
          'p': limitPrice.toStringAsFixed(1),
        },
      ],
      'grouping': 'na',
    };
  }

  /// Build a limit order payload.
  static Map<String, dynamic> buildLimitOrder({
    required int assetIndex,
    required bool isBuy,
    required double size,
    required double price,
    bool postOnly = false,
    bool reduceOnly = false,
  }) {
    return {
      'type': 'order',
      'orders': [
        {
          'a': assetIndex,
          'b': isBuy,
          's': size.toString(),
          'r': reduceOnly,
          't': {
            'limit': {
              'tif': postOnly ? 'Alo' : 'Gtc', // Add Liquidity Only or Good til Cancel
            },
          },
          'p': price.toStringAsFixed(1),
        },
      ],
      'grouping': 'na',
    };
  }

  /// Build a close position (market) payload.
  static Map<String, dynamic> buildClosePosition({
    required int assetIndex,
    required double currentSize,
    required double markPrice,
    double slippageBps = 100, // 1% default for closing
  }) {
    final isBuy = currentSize < 0; // if short, buy to close
    final size = currentSize.abs();
    return buildMarketOrder(
      assetIndex: assetIndex,
      isBuy: isBuy,
      size: size,
      slippageBps: slippageBps,
      markPrice: markPrice,
    );
  }

  /// Build a cancel order payload.
  static Map<String, dynamic> buildCancelOrder({
    required int assetIndex,
    required int orderId,
  }) {
    return {
      'type': 'cancel',
      'cancels': [
        {'a': assetIndex, 'o': orderId},
      ],
    };
  }

  // ==================== Internal ====================

  static List<OrderBookLevel> _parseLevels(List<dynamic> levels) {
    return levels.map((l) {
      final level = l as Map<String, dynamic>;
      return OrderBookLevel(
        price: double.tryParse(level['px']?.toString() ?? '') ?? 0,
        size: double.tryParse(level['sz']?.toString() ?? '') ?? 0,
        numOrders: level['n'] as int? ?? 0,
      );
    }).toList();
  }
}

// ==================== Data Models ====================

/// A perpetual futures market on Hyperliquid.
class PerpMarket {
  final String symbol;
  final int szDecimals;
  final int maxLeverage;
  final double markPrice;
  final double oraclePrice;
  final double volume24h;
  final double openInterest;
  final double fundingRate;
  final double priceChange24h;

  PerpMarket({
    required this.symbol,
    required this.szDecimals,
    required this.maxLeverage,
    required this.markPrice,
    required this.oraclePrice,
    required this.volume24h,
    required this.openInterest,
    required this.fundingRate,
    required this.priceChange24h,
  });

  /// 24h price change percentage.
  double get priceChangePct {
    if (priceChange24h == 0) return 0;
    return ((markPrice - priceChange24h) / priceChange24h) * 100;
  }

  /// Annualized funding rate.
  double get fundingRateAnnualized => fundingRate * 24 * 365 * 100;
}

/// An open perpetual position.
class PerpPosition {
  final String symbol;
  final double size; // positive = long, negative = short
  final double entryPrice;
  final double markPrice;
  final double unrealizedPnl;
  final double leverage;
  final double liquidationPrice;
  final double marginUsed;

  PerpPosition({
    required this.symbol,
    required this.size,
    required this.entryPrice,
    required this.markPrice,
    required this.unrealizedPnl,
    required this.leverage,
    required this.liquidationPrice,
    required this.marginUsed,
  });

  bool get isLong => size > 0;
  bool get isShort => size < 0;
  String get sideLabel => isLong ? 'Long' : 'Short';

  double get pnlPercentage {
    if (marginUsed == 0) return 0;
    return (unrealizedPnl / marginUsed) * 100;
  }

  factory PerpPosition.fromJson(Map<String, dynamic> json) {
    final szi = double.tryParse(json['szi']?.toString() ?? '') ?? 0;
    final entryPx = double.tryParse(json['entryPx']?.toString() ?? '') ?? 0;
    final positionValue = double.tryParse(json['positionValue']?.toString() ?? '') ?? 0;
    final unrealizedPnl = double.tryParse(json['unrealizedPnl']?.toString() ?? '') ?? 0;
    final leverage = json['leverage'] as Map<String, dynamic>?;
    final levVal = double.tryParse(leverage?['value']?.toString() ?? '1') ?? 1;
    final liqPx = double.tryParse(json['liquidationPx']?.toString() ?? '') ?? 0;
    final marginUsed = double.tryParse(json['marginUsed']?.toString() ?? '') ?? 0;

    return PerpPosition(
      symbol: json['coin'] as String? ?? '',
      size: szi,
      entryPrice: entryPx,
      markPrice: positionValue != 0 && szi != 0 ? positionValue / szi.abs() : 0,
      unrealizedPnl: unrealizedPnl,
      leverage: levVal,
      liquidationPrice: liqPx,
      marginUsed: marginUsed,
    );
  }
}

/// An open order on Hyperliquid.
class PerpOrder {
  final int oid;
  final String symbol;
  final bool isBuy;
  final double size;
  final double price;
  final String status;
  final DateTime timestamp;

  PerpOrder({
    required this.oid,
    required this.symbol,
    required this.isBuy,
    required this.size,
    required this.price,
    required this.status,
    required this.timestamp,
  });

  String get sideLabel => isBuy ? 'Buy' : 'Sell';

  factory PerpOrder.fromJson(Map<String, dynamic> json) {
    return PerpOrder(
      oid: json['oid'] as int? ?? 0,
      symbol: json['coin'] as String? ?? '',
      isBuy: json['side'] == 'B',
      size: double.tryParse(json['sz']?.toString() ?? '') ?? 0,
      price: double.tryParse(json['limitPx']?.toString() ?? '') ?? 0,
      status: json['orderType'] as String? ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        json['timestamp'] as int? ?? 0,
      ),
    );
  }
}

/// Order book snapshot.
class OrderBook {
  final List<OrderBookLevel> bids;
  final List<OrderBookLevel> asks;

  OrderBook({required this.bids, required this.asks});

  double get spread {
    if (asks.isEmpty || bids.isEmpty) return 0;
    return asks.first.price - bids.first.price;
  }

  double get midPrice {
    if (asks.isEmpty || bids.isEmpty) return 0;
    return (asks.first.price + bids.first.price) / 2;
  }
}

/// A single order book price level.
class OrderBookLevel {
  final double price;
  final double size;
  final int numOrders;

  OrderBookLevel({
    required this.price,
    required this.size,
    required this.numOrders,
  });
}

/// Combined clearinghouse state (positions + margin) from a single API call.
class ClearinghouseState {
  final List<PerpPosition> positions;
  final MarginSummary? margin;

  ClearinghouseState({required this.positions, this.margin});

  factory ClearinghouseState.empty() =>
      ClearinghouseState(positions: []);
}

/// Account margin summary.
class MarginSummary {
  final double accountValue;
  final double totalMarginUsed;
  final double totalNtlPos;
  final double totalRawUsd;

  MarginSummary({
    required this.accountValue,
    required this.totalMarginUsed,
    required this.totalNtlPos,
    required this.totalRawUsd,
  });

  double get freeMargin => accountValue - totalMarginUsed;

  double get marginUtilization {
    if (accountValue == 0) return 0;
    return (totalMarginUsed / accountValue) * 100;
  }
}
