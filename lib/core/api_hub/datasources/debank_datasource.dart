// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:dio/dio.dart';

import 'package:n42_wallet/core/utils/app_logger.dart';

/// DeBank Open API datasource for DeFi position tracking.
///
/// Provides aggregated DeFi portfolio data across 800+ protocols:
/// - Lending positions (supplied/borrowed assets)
/// - Liquidity pool positions (LP tokens, concentrated liquidity)
/// - Staking positions (validator stakes, liquid staking)
/// - Claimable rewards and pending airdrops
/// - Vesting schedules
///
/// API docs: https://docs.open.debank.com/
class DeBankDatasource {
  DeBankDatasource._();

  static const String _baseUrl = 'https://pro-openapi.debank.com';

  /// DeBank API key — configured via environment or server proxy.
  static const String _apiKey = String.fromEnvironment(
    'DEBANK_API_KEY',
    defaultValue: '',
  );

  /// Whether a DeBank API key was provided at build time
  /// (`--dart-define=DEBANK_API_KEY=...`). UI 据此决定是否渲染 DeFi
  /// 头寸区块——没有 key 时任何请求都会 401,与其挂一个永远空白的区块,
  /// 不如整块隐藏。
  static bool get hasApiKey => _apiKey.isNotEmpty;

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'AccessKey': _apiKey, 'Accept': 'application/json'},
    ),
  );

  /// Fetch all DeFi positions for an address across all chains.
  ///
  /// Returns categorized positions: lending, LP, staking, rewards, etc.
  static Future<DeFiPortfolio> getPortfolio(String address) async {
    try {
      final response = await _dio.get(
        '/v1/user/all_complex_protocol_list',
        queryParameters: {'id': address.toLowerCase()},
      );

      if (response.statusCode != 200 || response.data is! List) {
        return DeFiPortfolio.empty();
      }

      return DeFiPortfolio.fromDeBankResponse(response.data as List<dynamic>);
    } catch (e) {
      AppLogger.w('DeBank', 'portfolio error: $e');
      return DeFiPortfolio.empty();
    }
  }

  /// Fetch token balances across all chains.
  static Future<List<TokenBalance>> getTokenBalances(String address) async {
    try {
      final response = await _dio.get(
        '/v1/user/all_token_list',
        queryParameters: {
          'id': address.toLowerCase(),
          'is_all': false, // only tokens with balance
        },
      );

      if (response.statusCode != 200 || response.data is! List) {
        return [];
      }

      return (response.data as List<dynamic>)
          .map((t) => TokenBalance.fromJson(t as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.w('DeBank', 'token balances error: $e');
      return [];
    }
  }

  /// Fetch total USD value of all assets.
  static Future<double> getTotalBalance(String address) async {
    try {
      final response = await _dio.get(
        '/v1/user/total_balance',
        queryParameters: {'id': address.toLowerCase()},
      );

      if (response.statusCode != 200) return 0;
      return (response.data['total_usd_value'] as num?)?.toDouble() ?? 0;
    } catch (e) {
      AppLogger.w('DeBank', 'total balance error: $e');
      return 0;
    }
  }
}

/// Aggregated DeFi portfolio across all protocols and chains.
class DeFiPortfolio {
  /// All DeFi protocol positions.
  final List<ProtocolPosition> protocols;

  /// Total USD value across all positions.
  final double totalUsdValue;

  /// Breakdown by category.
  final double lendingValue;
  final double lpValue;
  final double stakingValue;
  final double rewardsValue;

  DeFiPortfolio({
    required this.protocols,
    required this.totalUsdValue,
    required this.lendingValue,
    required this.lpValue,
    required this.stakingValue,
    required this.rewardsValue,
  });

  factory DeFiPortfolio.empty() => DeFiPortfolio(
    protocols: [],
    totalUsdValue: 0,
    lendingValue: 0,
    lpValue: 0,
    stakingValue: 0,
    rewardsValue: 0,
  );

  factory DeFiPortfolio.fromDeBankResponse(List<dynamic> data) {
    final protocols = <ProtocolPosition>[];
    double totalValue = 0;
    double lending = 0;
    double lp = 0;
    double staking = 0;
    double rewards = 0;

    for (final item in data) {
      if (item is! Map<String, dynamic>) continue;

      final protocol = ProtocolPosition.fromJson(item);
      protocols.add(protocol);
      totalValue += protocol.totalUsdValue;

      for (final pos in protocol.positions) {
        switch (pos.type) {
          case PositionType.lending:
            lending += pos.usdValue;
          case PositionType.liquidityPool:
            lp += pos.usdValue;
          case PositionType.staking:
            staking += pos.usdValue;
          case PositionType.reward:
            rewards += pos.usdValue;
          case PositionType.vesting:
          case PositionType.other:
            break;
        }
      }
    }

    // Sort by value descending
    protocols.sort((a, b) => b.totalUsdValue.compareTo(a.totalUsdValue));

    return DeFiPortfolio(
      protocols: protocols,
      totalUsdValue: totalValue,
      lendingValue: lending,
      lpValue: lp,
      stakingValue: staking,
      rewardsValue: rewards,
    );
  }

  bool get isEmpty => protocols.isEmpty;
  int get protocolCount => protocols.length;
}

/// A single DeFi protocol's positions (e.g., "Aave V3 on Ethereum").
class ProtocolPosition {
  final String id;
  final String name;
  final String? logoUrl;
  final String chain;
  final double totalUsdValue;
  final List<Position> positions;

  ProtocolPosition({
    required this.id,
    required this.name,
    this.logoUrl,
    required this.chain,
    required this.totalUsdValue,
    required this.positions,
  });

  factory ProtocolPosition.fromJson(Map<String, dynamic> json) {
    final portfolioList = json['portfolio_item_list'] as List<dynamic>? ?? [];
    final positions = portfolioList
        .whereType<Map<String, dynamic>>()
        .map((p) => Position.fromJson(p))
        .toList();

    double total = 0;
    for (final p in positions) {
      total += p.usdValue;
    }

    return ProtocolPosition(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      logoUrl: json['logo_url'] as String?,
      chain: json['chain'] as String? ?? 'eth',
      totalUsdValue: total,
      positions: positions,
    );
  }
}

/// A single position within a protocol.
class Position {
  final String name;
  final PositionType type;
  final double usdValue;
  final List<PositionToken> supplyTokens;
  final List<PositionToken> borrowTokens;
  final List<PositionToken> rewardTokens;

  Position({
    required this.name,
    required this.type,
    required this.usdValue,
    required this.supplyTokens,
    required this.borrowTokens,
    required this.rewardTokens,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    final detail = json['detail'] as Map<String, dynamic>? ?? {};
    final stats = json['stats'] as Map<String, dynamic>? ?? {};

    final supplyList = detail['supply_token_list'] as List<dynamic>? ?? [];
    final borrowList = detail['borrow_token_list'] as List<dynamic>? ?? [];
    final rewardList = detail['reward_token_list'] as List<dynamic>? ?? [];

    return Position(
      name: json['name'] as String? ?? '',
      type: _parseType(json['name'] as String? ?? ''),
      usdValue: (stats['net_usd_value'] as num?)?.toDouble() ?? 0,
      supplyTokens: supplyList
          .whereType<Map<String, dynamic>>()
          .map((t) => PositionToken.fromJson(t))
          .toList(),
      borrowTokens: borrowList
          .whereType<Map<String, dynamic>>()
          .map((t) => PositionToken.fromJson(t))
          .toList(),
      rewardTokens: rewardList
          .whereType<Map<String, dynamic>>()
          .map((t) => PositionToken.fromJson(t))
          .toList(),
    );
  }

  static PositionType _parseType(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('lend') ||
        lower.contains('supply') ||
        lower.contains('deposit')) {
      return PositionType.lending;
    }
    if (lower.contains('liquidity') ||
        lower.contains('pool') ||
        lower.contains('lp')) {
      return PositionType.liquidityPool;
    }
    if (lower.contains('stak') || lower.contains('lock')) {
      return PositionType.staking;
    }
    if (lower.contains('reward') || lower.contains('claim')) {
      return PositionType.reward;
    }
    if (lower.contains('vest')) {
      return PositionType.vesting;
    }
    return PositionType.other;
  }

  /// Whether this position has claimable rewards.
  bool get hasClaimableRewards => rewardTokens.isNotEmpty;

  /// Total claimable reward value in USD.
  double get claimableRewardUsd =>
      rewardTokens.fold(0.0, (sum, t) => sum + t.usdValue);
}

/// A token within a DeFi position.
class PositionToken {
  final String symbol;
  final String? name;
  final String? logoUrl;
  final double amount;
  final double price;
  final double usdValue;

  PositionToken({
    required this.symbol,
    this.name,
    this.logoUrl,
    required this.amount,
    required this.price,
    required this.usdValue,
  });

  factory PositionToken.fromJson(Map<String, dynamic> json) {
    final amount = (json['amount'] as num?)?.toDouble() ?? 0;
    final price = (json['price'] as num?)?.toDouble() ?? 0;
    return PositionToken(
      symbol:
          json['optimized_symbol'] as String? ??
          json['symbol'] as String? ??
          '???',
      name: json['name'] as String?,
      logoUrl: json['logo_url'] as String?,
      amount: amount,
      price: price,
      usdValue: amount * price,
    );
  }
}

/// Token balance from DeBank.
class TokenBalance {
  final String symbol;
  final String? name;
  final String chain;
  final double amount;
  final double price;
  final double usdValue;
  final String? logoUrl;

  TokenBalance({
    required this.symbol,
    this.name,
    required this.chain,
    required this.amount,
    required this.price,
    required this.usdValue,
    this.logoUrl,
  });

  factory TokenBalance.fromJson(Map<String, dynamic> json) {
    final amount = (json['amount'] as num?)?.toDouble() ?? 0;
    final price = (json['price'] as num?)?.toDouble() ?? 0;
    return TokenBalance(
      symbol:
          json['optimized_symbol'] as String? ??
          json['symbol'] as String? ??
          '???',
      name: json['name'] as String?,
      chain: json['chain'] as String? ?? 'eth',
      amount: amount,
      price: price,
      usdValue: amount * price,
      logoUrl: json['logo_url'] as String?,
    );
  }
}

/// Type of DeFi position.
enum PositionType { lending, liquidityPool, staking, reward, vesting, other }
