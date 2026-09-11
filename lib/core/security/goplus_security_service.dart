// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/core/security/goplus_security_result.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';

/// Shared GoPlus client used by transfer screens.
class GoplusSecurityService {
  static final _client = GoplusSecurityClient();
  static const Map<String, int> _chainIds = {
    'ETH': 1,
    'BSC': 56,
    'MATIC': 137,
    'ARBITRUM': 42161,
    'OPTIMISM': 10,
    'AVAXC': 43114,
    'BASE': 8453,
    'FANTOM': 250,
    'CRONOS': 25,
    'GNOSIS': 100,
  };

  static bool supportsChain(String coinType) =>
      _chainIds.containsKey(coinType.toUpperCase());

  /// Unsupported chains and unavailable results return null, not a safe rating.
  static Future<GoplusSecurityResult?> checkToken(
    String coinType,
    String contractAddress,
  ) => _client.checkToken(coinType, contractAddress);
}

/// Token-risk lookup with a bounded five-minute cache and in-flight deduplication.
/// Transport and time are injectable so error and cache behavior can be verified
/// without external requests or waiting for wall-clock expiry.
class GoplusSecurityClient {
  GoplusSecurityClient({
    Future<dynamic> Function(int chainId, String address)? request,
    DateTime Function()? now,
  }) : _request = request ?? _fetchToken,
       _now = now ?? DateTime.now;

  final Future<dynamic> Function(int, String) _request;
  final DateTime Function() _now;
  final _cache = <String, _CacheEntry>{};
  final _pending = <String, Future<GoplusSecurityResult?>>{};
  static const _maxCacheSize = 200;

  static Future<dynamic> _fetchToken(int chainId, String address) =>
      BaseApi.requestEmptyH.get<dynamic>(
        'https://api.gopluslabs.io/api/v1/token_security/$chainId',
        params: {'contract_addresses': address},
        header: <String, dynamic>{},
      );

  Future<GoplusSecurityResult?> checkToken(
    String coinType,
    String contractAddress,
  ) {
    final chainId = GoplusSecurityService._chainIds[coinType.toUpperCase()];
    final address = contractAddress.toLowerCase();
    if (chainId == null || !RegExp(r'^0x[0-9a-f]{40}$').hasMatch(address)) {
      return Future.value(null);
    }
    final key = '${chainId}_$address';
    final cached = _cache[key];
    if (cached != null && !cached.isExpired(_now())) {
      return Future.value(cached.result);
    }
    return _pending.putIfAbsent(key, () async {
      try {
        final raw = await _request(chainId, address);
        if (raw is! Map || raw['code'] != 1) return null;
        final results = raw['result'];
        if (results is! Map) return null;
        // A single-entry response can still belong to a different contract.
        // Only an unambiguous address match may populate this token's cache.
        final matches = results.entries
            .where(
              (entry) =>
                  entry.key is String &&
                  (entry.key as String).toLowerCase() == address,
            )
            .toList();
        if (matches.length != 1) return null;
        final tokenData = matches.single.value;
        if (tokenData is! Map<String, dynamic> || tokenData.isEmpty) {
          return null;
        }
        final result = GoplusSecurityResult.fromTokenJson(tokenData);
        final now = _now();
        if (_cache.length >= _maxCacheSize) {
          _cache.removeWhere((_, entry) => entry.isExpired(now));
          if (_cache.length >= _maxCacheSize) {
            final oldest = _cache.keys.take(_cache.length ~/ 4).toList();
            for (final key in oldest) {
              _cache.remove(key);
            }
          }
        }
        _cache[key] = _CacheEntry(result, now);
        return result;
      } catch (e) {
        AppLogger.w('GoplusSecurity', 'checkToken error: $e');
        return null;
      } finally {
        _pending.remove(key);
      }
    });
  }
}

class _CacheEntry {
  final GoplusSecurityResult result;
  final DateTime createdAt;
  _CacheEntry(this.result, this.createdAt);

  bool isExpired(DateTime now) =>
      !now.isBefore(createdAt.add(const Duration(minutes: 5)));
}
