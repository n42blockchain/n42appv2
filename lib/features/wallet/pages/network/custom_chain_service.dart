// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing custom EVM chains added by the user.
///
/// Features:
/// - Manual input: RPC URL + Chain ID + Token Symbol + Explorer URL
/// - Chainlist.org validation: verify chain ID and RPC health
/// - Persistence via SharedPreferences
/// - RPC health check before adding
class CustomChainService {
  CustomChainService._();

  static const String _storageKey = 'custom_evm_chains';

  /// Chainlist API for chain metadata lookup.
  static const String _chainlistApi = 'https://chainid.network/chains.json';

  /// Cached chainlist data.
  static List<Map<String, dynamic>>? _chainlistCache;

  /// Get all user-added custom chains.
  static Future<List<CustomChain>> getCustomChains() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    if (data == null) return [];

    try {
      final list = jsonDecode(data) as List<dynamic>;
      return list
          .map((e) => CustomChain.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.w('CustomChain', 'failed to load custom chains: $e');
      return [];
    }
  }

  /// Add a new custom chain after validation.
  ///
  /// Throws [CustomChainException] if validation fails.
  static Future<CustomChain> addChain(CustomChain chain) async {
    // Validate chain ID is not a built-in chain
    if (_builtInChainIds.contains(chain.chainId)) {
      throw CustomChainException(
        'Chain ID ${chain.chainId} is a built-in chain',
      );
    }

    // Check for duplicates
    final existing = await getCustomChains();
    if (existing.any((c) => c.chainId == chain.chainId)) {
      throw CustomChainException('Chain ID ${chain.chainId} already exists');
    }

    // Validate RPC endpoint
    final rpcValid = await validateRpc(chain.rpcUrl, chain.chainId);
    if (!rpcValid) {
      throw CustomChainException('RPC endpoint validation failed');
    }

    // Save
    existing.add(chain);
    await _persist(existing);

    return chain;
  }

  /// Remove a custom chain by chain ID.
  static Future<void> removeChain(int chainId) async {
    final chains = await getCustomChains();
    chains.removeWhere((c) => c.chainId == chainId);
    await _persist(chains);
  }

  /// Update a custom chain's RPC URL.
  static Future<void> updateRpc(int chainId, String newRpcUrl) async {
    final chains = await getCustomChains();
    final idx = chains.indexWhere((c) => c.chainId == chainId);
    if (idx >= 0) {
      chains[idx] = chains[idx].copyWith(rpcUrl: newRpcUrl);
      await _persist(chains);
    }
  }

  /// Validate an RPC endpoint by calling eth_chainId and checking the result.
  static Future<bool> validateRpc(String rpcUrl, int expectedChainId) async {
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      final response = await dio.post(
        rpcUrl,
        data: jsonEncode({
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'eth_chainId',
          'params': [],
        }),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final result = response.data['result'] as String?;
      if (result == null) return false;

      final returnedChainId = int.tryParse(
        result.replaceFirst('0x', ''),
        radix: 16,
      );

      return returnedChainId == expectedChainId;
    } catch (e) {
      AppLogger.w('CustomChain', 'RPC validation error: $e');
      return false;
    }
  }

  /// Look up chain metadata from chainlist.org.
  static Future<ChainlistInfo?> lookupChain(int chainId) async {
    try {
      if (_chainlistCache == null) {
        final dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
          ),
        );
        final response = await dio.get(_chainlistApi);
        if (response.data is List) {
          _chainlistCache = (response.data as List<dynamic>)
              .whereType<Map<String, dynamic>>()
              .toList();
        }
      }

      final match = _chainlistCache?.firstWhere(
        (c) => c['chainId'] == chainId,
        orElse: () => <String, dynamic>{},
      );

      if (match == null || match.isEmpty) return null;

      final rpcs =
          (match['rpc'] as List<dynamic>?)
              ?.map((r) => r.toString())
              .where((r) => r.startsWith('https://'))
              .where((r) => !r.contains('\${'))
              .toList() ??
          [];

      final nativeCurrency = match['nativeCurrency'] as Map<String, dynamic>?;

      return ChainlistInfo(
        chainId: chainId,
        name: match['name'] as String? ?? 'Unknown',
        symbol: nativeCurrency?['symbol'] as String? ?? 'ETH',
        decimals: nativeCurrency?['decimals'] as int? ?? 18,
        rpcUrls: rpcs,
        explorerUrl: _extractExplorerUrl(match),
      );
    } catch (e) {
      AppLogger.w('CustomChain', 'Chainlist lookup error: $e');
      return null;
    }
  }

  static String? _extractExplorerUrl(Map<String, dynamic> chainData) {
    final explorers = chainData['explorers'] as List<dynamic>?;
    if (explorers == null || explorers.isEmpty) return null;
    final first = explorers.first as Map<String, dynamic>?;
    return first?['url'] as String?;
  }

  static Future<void> _persist(List<CustomChain> chains) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(chains.map((c) => c.toJson()).toList()),
    );
  }

  /// Built-in chain IDs that cannot be overridden.
  static const Set<int> _builtInChainIds = {
    1, // Ethereum
    56, // BSC
    137, // Polygon
    42161, // Arbitrum
    10, // Optimism
    43114, // Avalanche
    8453, // Base
    324, // zkSync Era
    59144, // Linea
  };

  /// Public view of built-in chain IDs (for preset filtering / tests).
  static Set<int> get builtInChainIds => _builtInChainIds;
}

/// User-added custom EVM chain configuration.
class CustomChain {
  final int chainId;
  final String name;
  final String rpcUrl;
  final String symbol;
  final int decimals;
  final String? explorerUrl;
  final String? iconUrl;
  final DateTime addedAt;

  CustomChain({
    required this.chainId,
    required this.name,
    required this.rpcUrl,
    required this.symbol,
    this.decimals = 18,
    this.explorerUrl,
    this.iconUrl,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  String get chainIdHex => '0x${chainId.toRadixString(16)}';

  factory CustomChain.fromJson(Map<String, dynamic> json) {
    return CustomChain(
      chainId: json['chainId'] as int,
      name: json['name'] as String,
      rpcUrl: json['rpcUrl'] as String,
      symbol: json['symbol'] as String,
      decimals: json['decimals'] as int? ?? 18,
      explorerUrl: json['explorerUrl'] as String?,
      iconUrl: json['iconUrl'] as String?,
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'chainId': chainId,
    'name': name,
    'rpcUrl': rpcUrl,
    'symbol': symbol,
    'decimals': decimals,
    'explorerUrl': explorerUrl,
    'iconUrl': iconUrl,
    'addedAt': addedAt.toIso8601String(),
  };

  CustomChain copyWith({
    int? chainId,
    String? name,
    String? rpcUrl,
    String? symbol,
    int? decimals,
    String? explorerUrl,
    String? iconUrl,
  }) {
    return CustomChain(
      chainId: chainId ?? this.chainId,
      name: name ?? this.name,
      rpcUrl: rpcUrl ?? this.rpcUrl,
      symbol: symbol ?? this.symbol,
      decimals: decimals ?? this.decimals,
      explorerUrl: explorerUrl ?? this.explorerUrl,
      iconUrl: iconUrl ?? this.iconUrl,
      addedAt: addedAt,
    );
  }

  @override
  String toString() => 'CustomChain($name, chainId: $chainId)';
}

/// Chain metadata from chainlist.org.
class ChainlistInfo {
  final int chainId;
  final String name;
  final String symbol;
  final int decimals;
  final List<String> rpcUrls;
  final String? explorerUrl;

  ChainlistInfo({
    required this.chainId,
    required this.name,
    required this.symbol,
    required this.decimals,
    required this.rpcUrls,
    this.explorerUrl,
  });
}

/// Exception thrown by custom chain operations.
class CustomChainException implements Exception {
  final String message;
  CustomChainException(this.message);

  @override
  String toString() => 'CustomChainException: $message';
}
