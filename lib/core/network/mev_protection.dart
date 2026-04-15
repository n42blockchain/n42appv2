// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// MEV (Maximal Extractable Value) protection service.
///
/// Integrates Flashbots Protect RPC and MEV Blocker to prevent sandwich
/// attacks, frontrunning, and other MEV exploitation during swaps and
/// high-value transactions on Ethereum and supported L2s.
///
/// Protection methods:
/// 1. **Flashbots Protect RPC** — Ethereum mainnet private transaction pool
/// 2. **MEV Blocker** — Multi-chain MEV protection (by CoW Protocol)
/// 3. **Private mempool detection** — Identifies when to use protection
class MevProtectionService {
  MevProtectionService._();

  static final MevProtectionService instance = MevProtectionService._();

  /// Flashbots Protect RPC endpoint (Ethereum mainnet only).
  /// Transactions are sent directly to block builders, bypassing the public mempool.
  static const String flashbotsRpc = 'https://rpc.flashbots.net';

  /// Flashbots fast mode — slightly less privacy but faster inclusion.
  static const String flashbotsFastRpc = 'https://rpc.flashbots.net/fast';

  /// MEV Blocker RPC (by CoW Protocol) — multi-builder protection.
  static const String mevBlockerRpc = 'https://rpc.mevblocker.io';

  /// 1 ETH in wei — threshold for "large value" risk assessment.
  static final BigInt _oneEthInWei = BigInt.from(10).pow(18);

  /// Chain IDs where MEV protection is available.
  static const Map<int, MevProtectionConfig> supportedChains = {
    1: MevProtectionConfig(
      chainId: 1,
      chainName: 'Ethereum',
      protectedRpc: flashbotsRpc,
      fastRpc: flashbotsFastRpc,
      provider: MevProvider.flashbots,
    ),
    // MEV Blocker supports these chains
    // Additional chains can be added as providers expand coverage
  };

  /// Whether MEV protection is enabled globally.
  bool isEnabled = true;

  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
  ));

  /// Check if MEV protection is available for a specific chain.
  static bool isAvailable(int chainId) => supportedChains.containsKey(chainId);

  /// Get the protected RPC URL for a chain, or null if not available.
  static String? getProtectedRpc(int chainId, {bool fast = false}) {
    final config = supportedChains[chainId];
    if (config == null) return null;
    return fast ? (config.fastRpc ?? config.protectedRpc) : config.protectedRpc;
  }

  /// Analyze a transaction to determine if MEV protection should be used.
  ///
  /// Returns [MevRiskAssessment] with risk level and recommendation.
  static MevRiskAssessment assessRisk({
    required int chainId,
    required String data,
    BigInt? value,
  }) {
    if (!isAvailable(chainId)) {
      return MevRiskAssessment(
        level: MevRiskLevel.none,
        reason: 'MEV protection not available on this chain',
        shouldProtect: false,
      );
    }

    // Decode function selector
    if (data.length < 10) {
      return MevRiskAssessment(
        level: MevRiskLevel.low,
        reason: 'Simple transfer',
        shouldProtect: false,
      );
    }

    final selector = data.substring(2, 10).toLowerCase();

    // High-risk: DEX swap functions
    const swapSelectors = {
      '7ff36ab5', // swapExactETHForTokens
      '38ed1739', // swapExactTokensForTokens
      '18cbafe5', // swapExactTokensForETH
      '8803dbee', // swapTokensForExactTokens
      'fb3bdb41', // swapETHForExactTokens
      '5c11d795', // swapExactTokensForTokensSupportingFeeOnTransferTokens
      'b6f9de95', // swapExactETHForTokensSupportingFeeOnTransferTokens
      '791ac947', // swapExactTokensForETHSupportingFeeOnTransferTokens
      '04e45aaf', // Uniswap V3 exactInputSingle
      'b858183f', // Uniswap V3 exactInput
      '5023b4df', // Uniswap V3 exactOutputSingle
      'ac9650d8', // multicall (often wraps swaps)
      '5ae401dc', // multicall with deadline
      '472b43f3', // Uniswap Universal Router execute
      '3593564c', // Uniswap Universal Router execute
    };

    // Medium-risk: approval functions (can be front-run to drain)
    const approvalSelectors = {
      '095ea7b3', // approve
      'a22cb465', // setApprovalForAll
      'd505accf', // permit
    };

    final isLargeValue = value != null && value > _oneEthInWei;

    if (swapSelectors.contains(selector)) {
      return MevRiskAssessment(
        level: MevRiskLevel.high,
        reason: 'DEX swap — vulnerable to sandwich attacks',
        shouldProtect: true,
        estimatedSavings: 'Up to 2-5% slippage protection',
      );
    }

    if (approvalSelectors.contains(selector)) {
      return MevRiskAssessment(
        level: MevRiskLevel.medium,
        reason: 'Token approval — could be front-run',
        shouldProtect: true,
      );
    }

    if (isLargeValue) {
      return MevRiskAssessment(
        level: MevRiskLevel.medium,
        reason: 'Large value transfer',
        shouldProtect: true,
      );
    }

    return MevRiskAssessment(
      level: MevRiskLevel.low,
      reason: 'Standard transaction',
      shouldProtect: false,
    );
  }

  /// Send a transaction through the protected RPC (private mempool).
  ///
  /// [chainId] — target chain.
  /// [signedTx] — hex-encoded signed transaction (0x-prefixed).
  /// [fast] — use fast mode (slightly less privacy, faster inclusion).
  ///
  /// Returns the transaction hash on success.
  Future<String> sendProtectedTransaction({
    required int chainId,
    required String signedTx,
    bool fast = false,
  }) async {
    final rpcUrl = getProtectedRpc(chainId, fast: fast);
    if (rpcUrl == null) {
      throw MevProtectionException('MEV protection not available for chain $chainId');
    }

    try {
      final response = await _dio.post(
        rpcUrl,
        data: jsonEncode({
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'eth_sendRawTransaction',
          'params': [signedTx],
        }),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final result = response.data;
      if (result['error'] != null) {
        throw MevProtectionException(
          'Protected RPC error: ${result['error']['message']}',
          code: result['error']['code'],
        );
      }

      return result['result'] as String;
    } on DioException catch (e) {
      throw MevProtectionException('Network error: ${e.message}');
    }
  }

  /// Get the status of a Flashbots bundle.
  Future<FlashbotsStatus?> getBundleStatus(String txHash) async {
    try {
      final response = await _dio.post(
        flashbotsRpc,
        data: jsonEncode({
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'flashbots_getBundleStatsV2',
          'params': [txHash],
        }),
      );

      final result = response.data;
      if (result['result'] == null) return null;

      return FlashbotsStatus.fromJson(result['result']);
    } catch (e) {
      debugPrint('Failed to get bundle status: $e');
      return null;
    }
  }
}

/// MEV protection configuration for a specific chain.
class MevProtectionConfig {
  final int chainId;
  final String chainName;
  final String protectedRpc;
  final String? fastRpc;
  final MevProvider provider;

  const MevProtectionConfig({
    required this.chainId,
    required this.chainName,
    required this.protectedRpc,
    this.fastRpc,
    required this.provider,
  });
}

/// MEV protection provider.
enum MevProvider {
  /// Flashbots Protect (Ethereum mainnet).
  flashbots,

  /// MEV Blocker by CoW Protocol.
  mevBlocker,
}

/// MEV risk level for a transaction.
enum MevRiskLevel {
  /// No MEV risk (e.g., unsupported chain).
  none,

  /// Low risk (simple transfers).
  low,

  /// Medium risk (approvals, large transfers).
  medium,

  /// High risk (DEX swaps — sandwich attack target).
  high,
}

/// Result of MEV risk assessment for a transaction.
class MevRiskAssessment {
  final MevRiskLevel level;
  final String reason;
  final bool shouldProtect;
  final String? estimatedSavings;

  const MevRiskAssessment({
    required this.level,
    required this.reason,
    required this.shouldProtect,
    this.estimatedSavings,
  });

  /// Color value for UI display.
  int get colorValue {
    switch (level) {
      case MevRiskLevel.none:
        return 0xFF71717A; // gray
      case MevRiskLevel.low:
        return 0xFF22C55E; // green
      case MevRiskLevel.medium:
        return 0xFFF97316; // orange
      case MevRiskLevel.high:
        return 0xFFEF4444; // red
    }
  }
}

/// Flashbots bundle status.
class FlashbotsStatus {
  final bool isSimulated;
  final bool isSentToMiners;
  final bool isOnChain;
  final int? receivedAt;

  FlashbotsStatus({
    required this.isSimulated,
    required this.isSentToMiners,
    required this.isOnChain,
    this.receivedAt,
  });

  factory FlashbotsStatus.fromJson(Map<String, dynamic> json) {
    return FlashbotsStatus(
      isSimulated: json['isSimulated'] == true,
      isSentToMiners: json['isSentToMiners'] == true,
      isOnChain: json['isOnChain'] == true,
      receivedAt: json['receivedAt'] as int?,
    );
  }
}

/// Exception thrown by MEV protection operations.
class MevProtectionException implements Exception {
  final String message;
  final int? code;

  MevProtectionException(this.message, {this.code});

  @override
  String toString() => 'MevProtectionException: $message';
}
