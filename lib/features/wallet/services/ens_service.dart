// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/services/ens_resolution_models.dart';

export 'package:n42_wallet/features/wallet/services/ens_resolution_models.dart';

Map<String, dynamic>? _ensServiceMapValue(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, entry) => MapEntry(key.toString(), entry));
  }
  return null;
}

/// 统一域名解析服务
///
/// 支持 4 种协议（解析优先级从高到低）：
///
/// 1. **N42 Name Service** — `.n42` 后缀
/// 2. **Solana Name Service (SNS)** — `.sol` 后缀，Bonfida 协议
/// 3. **Unstoppable Domains (UD)** — `.crypto` / `.wallet` / `.nft` / …
/// 4. **Ethereum Name Service (ENS)** — `.eth` / `.xyz` / `.app` / …
///
/// **多链解析**：对于 UD 域名，通过 `preferredChain` 参数获取对应链的地址；
///              对于 SNS 域名，始终返回 Solana 地址。
///
/// **缓存策略**：所有协议共享同一套 5 分钟内存缓存。
class EnsService {
  final TokenViewApi _tokenViewApi;

  /// 正向解析缓存 (name → EnsResolutionResult)
  final Map<String, _CacheEntry<EnsResolutionResult>> _forwardCache = {};

  /// 反向解析缓存 (address → domain name)
  final Map<String, _CacheEntry<String?>> _reverseCache = {};

  /// 头像缓存
  final Map<String, _CacheEntry<String?>> _avatarCache = {};

  /// 缓存有效期（5 分钟）
  static const _cacheDuration = Duration(minutes: 5);

  /// 全部支持的域名后缀（向后兼容的公开常量）
  static const ensSuffixes = EnsProtocolUtils.allSuffixes;

  EnsService({TokenViewApi? tokenViewApi})
      : _tokenViewApi = tokenViewApi ?? TokenViewApi();

  // ── 公开静态工具方法 ──────────────────────────────────────────────────────

  /// 检查字符串是否是受支持的域名（任意协议）
  static bool isEnsName(String input) => EnsProtocolUtils.isEnsName(input);

  /// 检查链是否支持域名解析
  ///
  /// - N42、EVM 兼容链：支持 N42 NS + ENS + UD
  /// - Solana：支持 SNS + UD
  static bool chainSupportsEns(String coinType) =>
      EnsProtocolUtils.chainSupportsEns(coinType);

  /// 识别域名所属协议
  static DomainProtocol detectProtocol(String domainName) =>
      EnsProtocolUtils.detectProtocol(domainName);

  // ── 正向解析 ─────────────────────────────────────────────────────────────

  /// 将域名解析为地址（统一入口）
  ///
  /// [domainName]     — 域名（如 `alice.eth` / `alice.sol` / `alice.crypto`）
  /// [preferredChain] — 期望返回的链地址（对 UD 多链域名有效）
  /// [useCache]       — 是否使用缓存
  Future<EnsResolutionResult> resolveName(
    String domainName, {
    String? preferredChain,
    bool useCache = true,
  }) async {
    final normalized = domainName.toLowerCase().trim();

    // 缓存键：域名 + 目标链（UD 多链域名的缓存需要区分链）
    final cacheKey = preferredChain != null
        ? '$normalized@$preferredChain'
        : normalized;

    if (useCache) {
      final cached = _getFromCache(_forwardCache, cacheKey);
      if (cached != null) return cached;
    }

    try {
      final protocol = EnsProtocolUtils.detectProtocol(normalized);
      EnsResolutionResult? result;

      switch (protocol) {
        case DomainProtocol.n42:
          result = await _resolveWithN42(normalized);

        case DomainProtocol.sns:
          result = await _resolveWithSns(normalized);

        case DomainProtocol.unstoppableDomains:
          result = await _resolveWithUd(normalized, preferredChain);
          // UD 解析失败时不再 fallback（防止用户误解）

        case DomainProtocol.ens:
        case DomainProtocol.unknown:
          // N42 链优先尝试 N42 解析（支持跨协议）
          if (preferredChain == CoinType.N.name) {
            result = await _resolveWithN42(normalized);
          }
          // 再尝试 ETH ENS
          result ??= await _resolveWithEns(normalized);
      }

      result ??= EnsResolutionResult.failure('Domain name not found');

      // 写入缓存
      _addToCache(_forwardCache, cacheKey, result);
      return result;
    } catch (e) {
      AppLogger.w('DomainService', 'resolveName error: $e');
      return EnsResolutionResult.failure('Resolution failed: $e');
    }
  }

  // ── 反向解析 ─────────────────────────────────────────────────────────────

  /// 将地址反向解析为域名
  ///
  /// [address]  — 链地址
  /// [coinType] — 地址所属链（影响使用哪个协议）
  /// [useCache] — 是否使用缓存
  Future<String?> resolveAddress(
    String address, {
    String coinType = 'ETH',
    bool useCache = true,
  }) async {
    final normalizedAddr = address.toLowerCase();

    if (useCache && _isInReverseCache(normalizedAddr)) {
      return _reverseCache[normalizedAddr]!.value;
    }

    try {
      String? domainName;

      if (coinType == CoinType.SOL.name) {
        // Solana 链：优先 SNS 反向解析
        domainName = await _reverseResolveSns(address);
      } else if (coinType == CoinType.N.name) {
        // N42 链：优先 N42 反向解析
        domainName = await _reverseResolveN42(normalizedAddr);
        // fallback 到 ENS
        domainName ??= await _reverseResolveEns(normalizedAddr);
      } else {
        // EVM 链：先 ENS，再 UD
        domainName = await _reverseResolveEns(normalizedAddr);
        domainName ??= await _reverseResolveUd(normalizedAddr, coinType);
      }

      _addToCache(_reverseCache, normalizedAddr, domainName);
      return domainName;
    } catch (e) {
      AppLogger.w('DomainService', 'resolveAddress error: $e');
      return null;
    }
  }

  // ── 头像 ──────────────────────────────────────────────────────────────────

  /// 获取域名头像 URL
  ///
  /// 仅 ENS 和 N42 NS 支持头像，UD / SNS 暂不支持（直接返回 null）。
  Future<String?> getAvatar(String domainName, {bool useCache = true}) async {
    final normalized = domainName.toLowerCase().trim();

    if (useCache) {
      final cached = _getFromCache(_avatarCache, normalized);
      if (cached != null) return cached;
    }

    final protocol = EnsProtocolUtils.detectProtocol(normalized);
    // UD / SNS 目前无头像服务
    if (protocol == DomainProtocol.unstoppableDomains ||
        protocol == DomainProtocol.sns) {
      return null;
    }

    try {
      final avatar = await _fetchEnsAvatar(normalized);
      _addToCache(_avatarCache, normalized, avatar);
      return avatar;
    } catch (e) {
      AppLogger.w('DomainService', 'getAvatar error: $e');
      return null;
    }
  }

  // ── 文本记录 ─────────────────────────────────────────────────────────────

  /// 获取 ENS 文本记录（仅 ENS / N42 NS 协议支持）
  Future<EnsTextRecords?> getTextRecords(String domainName) async {
    try {
      final result = await _tokenViewApi.getEnsTextRecords(domainName);
      if (!result.error && result.data != null) {
        final data = _ensServiceMapValue(result.data) ?? <String, dynamic>{};
        return EnsTextRecords(
          email: data['email']?.toString(),
          url: data['url']?.toString(),
          avatar: data['avatar']?.toString(),
          description: data['description']?.toString(),
          twitter: data['com.twitter']?.toString(),
          github: data['com.github']?.toString(),
          discord: data['com.discord']?.toString(),
          telegram: data['org.telegram']?.toString(),
        );
      }
    } catch (e) {
      AppLogger.w('DomainService', 'getTextRecords error: $e');
    }
    return null;
  }

  // ── 批量解析 ─────────────────────────────────────────────────────────────

  /// 并行解析多个域名
  Future<Map<String, EnsResolutionResult>> resolveNames(
    List<String> domainNames, {
    String? preferredChain,
  }) async {
    final futures = domainNames.map((name) async {
      final result = await resolveName(name, preferredChain: preferredChain);
      return MapEntry(name, result);
    });
    final entries = await Future.wait(futures);
    return Map.fromEntries(entries);
  }

  /// 并行反向解析多个地址
  Future<Map<String, String?>> resolveAddresses(
    List<String> addresses, {
    String coinType = 'ETH',
  }) async {
    final futures = addresses.map((addr) async {
      final result = await resolveAddress(addr, coinType: coinType);
      return MapEntry(addr, result);
    });
    final entries = await Future.wait(futures);
    return Map.fromEntries(entries);
  }

  /// 清除全部缓存
  void clearCache() {
    _forwardCache.clear();
    _reverseCache.clear();
    _avatarCache.clear();
  }

  // ── 私有：通用 API 调用辅助 ──────────────────────────────────────────────

  /// 封装正向解析的通用模式：调用 API → 检查结果 → 包装为 [EnsResolutionResult]
  Future<EnsResolutionResult?> _resolveForward({
    required Future<dynamic> Function() apiCall,
    required String domain,
    required String sourceChain,
    required DomainProtocol protocol,
    required String debugLabel,
  }) async {
    try {
      final result = await apiCall();
      final data = result.data;
      final address = data == null ? '' : data.toString();
      if (!result.error && address.isNotEmpty) {
        return EnsResolutionResult.success(
          address: address,
          ensName: domain,
          sourceChain: sourceChain,
          protocol: protocol,
        );
      }
    } catch (e) {
      AppLogger.w('DomainService', '$debugLabel failed: $e');
    }
    return null;
  }

  /// 封装反向解析 / 头像获取的通用模式：调用 API → 检查结果 → 返回 String?
  Future<String?> _fetchStringResult(
    Future<dynamic> Function() apiCall,
    String debugLabel,
  ) async {
    try {
      final result = await apiCall();
      if (!result.error && result.data != null) return result.data.toString();
    } catch (e) {
      AppLogger.w('DomainService', '$debugLabel failed: $e');
    }
    return null;
  }

  // ── 私有：各协议解析实现 ─────────────────────────────────────────────────

  /// N42 Name Service 正向解析
  Future<EnsResolutionResult?> _resolveWithN42(String domain) =>
      _resolveForward(
        apiCall: () => _tokenViewApi.getN42EnsResolve(domain),
        domain: domain,
        sourceChain: 'N42',
        protocol: DomainProtocol.n42,
        debugLabel: 'N42 NS',
      );

  /// Ethereum Name Service 正向解析
  Future<EnsResolutionResult?> _resolveWithEns(String domain) =>
      _resolveForward(
        apiCall: () => _tokenViewApi.getEnsResolve(domain),
        domain: domain,
        sourceChain: 'ETH',
        protocol: DomainProtocol.ens,
        debugLabel: 'ETH ENS',
      );

  /// Unstoppable Domains 正向解析
  ///
  /// [domain]         — UD 域名（如 alice.crypto）
  /// [preferredChain] — 期望的链地址（ETH / BNB / MATIC / BTC / SOL 等）
  ///                    为 null 时后端返回默认 EVM 地址
  Future<EnsResolutionResult?> _resolveWithUd(
    String domain,
    String? preferredChain,
  ) {
    final ticker = EnsProtocolUtils.coinTypeToUdTicker(preferredChain);
    return _resolveForward(
      apiCall: () => _tokenViewApi.getUdResolve(domain, ticker: ticker),
      domain: domain,
      sourceChain: 'UD',
      protocol: DomainProtocol.unstoppableDomains,
      debugLabel: 'Unstoppable Domains',
    );
  }

  /// Solana Name Service 正向解析
  ///
  /// [domain] — .sol 域名（如 alice.sol）
  Future<EnsResolutionResult?> _resolveWithSns(String domain) =>
      _resolveForward(
        apiCall: () => _tokenViewApi.getSnsResolve(domain),
        domain: domain,
        sourceChain: 'SNS',
        protocol: DomainProtocol.sns,
        debugLabel: 'SNS',
      );

  // ── 私有：各协议反向解析 ────────────────────────────────────────────────

  Future<String?> _reverseResolveN42(String address) =>
      _fetchStringResult(
        () => _tokenViewApi.getN42ReverseResolve(address),
        'N42 reverse',
      );

  Future<String?> _reverseResolveEns(String address) =>
      _fetchStringResult(
        () => _tokenViewApi.getEnsReverseResolve(address),
        'ENS reverse',
      );

  Future<String?> _reverseResolveUd(String address, String coinType) {
    final ticker = EnsProtocolUtils.coinTypeToUdTicker(coinType);
    return _fetchStringResult(
      () => _tokenViewApi.getUdReverseResolve(address, ticker: ticker),
      'UD reverse',
    );
  }

  Future<String?> _reverseResolveSns(String address) =>
      _fetchStringResult(
        () => _tokenViewApi.getSnsReverseResolve(address),
        'SNS reverse',
      );

  // ── 私有：头像 ────────────────────────────────────────────────────────────

  Future<String?> _fetchEnsAvatar(String domainName) =>
      _fetchStringResult(
        () => _tokenViewApi.getEnsAvatar(domainName),
        'avatar fetch',
      );

  // ── 私有：缓存操作 ────────────────────────────────────────────────────────

  T? _getFromCache<T>(Map<String, _CacheEntry<T>> cache, String key) {
    final entry = cache[key];
    if (entry == null) return null;
    if (entry.isExpired) {
      cache.remove(key);
      return null;
    }
    return entry.value;
  }

  bool _isInReverseCache(String key) {
    final entry = _reverseCache[key];
    if (entry == null) return false;
    if (entry.isExpired) {
      _reverseCache.remove(key);
      return false;
    }
    return true;
  }

  void _addToCache<T>(
      Map<String, _CacheEntry<T>> cache, String key, T value) {
    cache[key] = _CacheEntry(value, DateTime.now().add(_cacheDuration));
  }
}

/// 缓存条目
class _CacheEntry<T> {
  final T value;
  final DateTime expiry;

  _CacheEntry(this.value, this.expiry);

  bool get isExpired => DateTime.now().isAfter(expiry);
}

/// ENS/Domain 服务单例
class EnsServiceProvider {
  static EnsService? _instance;

  static EnsService get instance => _instance ??= EnsService();

  /// 重置实例（用于测试）
  static void reset() {
    _instance = null;
  }
}
