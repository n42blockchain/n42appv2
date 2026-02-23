// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:n42_wallet/src/component/enums/coin_type.dart';
import 'package:n42_wallet/src/wallet/api/token_view_api.dart';

/// 域名解析协议
enum DomainProtocol {
  /// N42 Name Service (.n42)
  n42,

  /// Ethereum Name Service (.eth / .xyz / .app / .luxe / .kred / .art)
  ens,

  /// Unstoppable Domains (.crypto / .wallet / .nft / .blockchain / .dao / …)
  unstoppableDomains,

  /// Solana Name Service (.sol)
  sns,

  unknown,
}

/// ENS 解析结果
class EnsResolutionResult {
  /// 解析是否成功
  final bool success;

  /// 解析后的地址
  final String? address;

  /// ENS 名称
  final String? ensName;

  /// 头像 URL
  final String? avatar;

  /// 错误信息
  final String? error;

  /// 来源链标签（'N42' / 'ETH' / 'UD' / 'SNS'）
  final String? sourceChain;

  /// 解析使用的协议
  final DomainProtocol protocol;

  const EnsResolutionResult({
    required this.success,
    this.address,
    this.ensName,
    this.avatar,
    this.error,
    this.sourceChain,
    this.protocol = DomainProtocol.unknown,
  });

  factory EnsResolutionResult.success({
    required String address,
    String? ensName,
    String? avatar,
    String? sourceChain,
    DomainProtocol protocol = DomainProtocol.unknown,
  }) {
    return EnsResolutionResult(
      success: true,
      address: address,
      ensName: ensName,
      avatar: avatar,
      sourceChain: sourceChain,
      protocol: protocol,
    );
  }

  factory EnsResolutionResult.failure(String error) {
    return EnsResolutionResult(
      success: false,
      error: error,
    );
  }
}

/// ENS 文本记录
class EnsTextRecords {
  final String? email;
  final String? url;
  final String? avatar;
  final String? description;
  final String? twitter;
  final String? github;
  final String? discord;
  final String? telegram;
  final Map<String, String> custom;

  const EnsTextRecords({
    this.email,
    this.url,
    this.avatar,
    this.description,
    this.twitter,
    this.github,
    this.discord,
    this.telegram,
    this.custom = const {},
  });
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

  // ── 各协议的域名后缀 ──────────────────────────────────────────────────────

  /// N42 Name Service 后缀
  static const _n42Suffixes = ['.n42'];

  /// Solana Name Service 后缀
  static const _snsSuffixes = ['.sol'];

  /// Unstoppable Domains 后缀（截止 2025 年已发布的 TLD）
  ///
  /// 参考：https://docs.unstoppabledomains.com/getting-started/supported-domains/
  static const _udSuffixes = [
    '.crypto',     // UD 首批 TLD（2019）
    '.wallet',     // 多链钱包域名（2021）
    '.bitcoin',    // Bitcoin 生态（2021）
    '.nft',        // NFT 身份（2022）
    '.blockchain', // 通用区块链（2021）
    '.dao',        // DAO 组织（2022）
    '.888',        // 吉祥数字（2022）
    '.zil',        // Zilliqa 生态（迁移到 Polygon L2）
    '.x',          // 简短域名（2023）
    '.klever',     // Klever 生态（2022）
    '.hi',         // HI 金融（2022）
    '.kresus',     // Kresus 生态（2022）
    '.manga',      // 动漫文化（2023）
    '.binanceus',  // Binance US 生态（2022）
    '.coin',       // 通用代币（2023）
    '.polygon',    // Polygon 生态（2023）
  ];

  /// 以太坊 ENS 后缀
  static const _ensSuffixes = [
    '.eth',
    '.xyz',
    '.app',
    '.luxe',
    '.kred',
    '.art',
  ];

  /// 全部支持的域名后缀（用于 isEnsName 快速判断）
  static const ensSuffixes = [
    ..._n42Suffixes,
    ..._snsSuffixes,
    ..._udSuffixes,
    ..._ensSuffixes,
  ];

  EnsService({TokenViewApi? tokenViewApi})
      : _tokenViewApi = tokenViewApi ?? TokenViewApi();

  // ── 公开静态工具方法 ──────────────────────────────────────────────────────

  /// 检查字符串是否是受支持的域名（任意协议）
  static bool isEnsName(String input) {
    final lower = input.toLowerCase().trim();
    for (final suffix in ensSuffixes) {
      if (lower.endsWith(suffix)) return true;
    }
    return false;
  }

  /// 检查链是否支持域名解析
  ///
  /// - N42、EVM 兼容链：支持 N42 NS + ENS + UD
  /// - Solana：支持 SNS + UD
  static bool chainSupportsEns(String coinType) {
    // Solana：支持 SNS + UD
    if (coinType == CoinType.SOL.name) return true;
    // N42 链
    if (coinType == CoinType.N.name) return true;
    // ETH 主网
    if (coinType == CoinType.ETH.name) return true;
    // 其他 EVM 兼容链（也支持 UD 多链解析）
    const evmChains = [
      'BNB', 'MATIC', 'AVAX', 'FTM', 'OP', 'ARB',
      'CELO', 'ONE', 'CRO', 'MOVR', 'GLMR',
    ];
    return evmChains.contains(coinType);
  }

  /// 识别域名所属协议
  static DomainProtocol detectProtocol(String domainName) {
    final lower = domainName.toLowerCase().trim();
    if (_n42Suffixes.any((s) => lower.endsWith(s))) {
      return DomainProtocol.n42;
    }
    if (_snsSuffixes.any((s) => lower.endsWith(s))) {
      return DomainProtocol.sns;
    }
    if (_udSuffixes.any((s) => lower.endsWith(s))) {
      return DomainProtocol.unstoppableDomains;
    }
    if (_ensSuffixes.any((s) => lower.endsWith(s))) {
      return DomainProtocol.ens;
    }
    return DomainProtocol.unknown;
  }

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
      final protocol = detectProtocol(normalized);
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
      debugPrint('[DomainService] resolveName error: $e');
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
      debugPrint('[DomainService] resolveAddress error: $e');
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

    final protocol = detectProtocol(normalized);
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
      debugPrint('[DomainService] getAvatar error: $e');
      return null;
    }
  }

  // ── 文本记录 ─────────────────────────────────────────────────────────────

  /// 获取 ENS 文本记录（仅 ENS / N42 NS 协议支持）
  Future<EnsTextRecords?> getTextRecords(String domainName) async {
    try {
      final result = await _tokenViewApi.getEnsTextRecords(domainName);
      if (!result.error && result.data != null) {
        final data = result.data as Map<String, dynamic>;
        return EnsTextRecords(
          email: data['email'] as String?,
          url: data['url'] as String?,
          avatar: data['avatar'] as String?,
          description: data['description'] as String?,
          twitter: data['com.twitter'] as String?,
          github: data['com.github'] as String?,
          discord: data['com.discord'] as String?,
          telegram: data['org.telegram'] as String?,
        );
      }
    } catch (e) {
      debugPrint('[DomainService] getTextRecords error: $e');
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
      final result =
          await resolveName(name, preferredChain: preferredChain);
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

  // ── 私有：各协议解析实现 ─────────────────────────────────────────────────

  /// N42 Name Service 正向解析
  Future<EnsResolutionResult?> _resolveWithN42(String domain) async {
    try {
      final result = await _tokenViewApi.getN42EnsResolve(domain);
      if (!result.error && result.data != null) {
        return EnsResolutionResult.success(
          address: result.data as String,
          ensName: domain,
          sourceChain: 'N42',
          protocol: DomainProtocol.n42,
        );
      }
    } catch (e) {
      debugPrint('[DomainService] N42 NS failed: $e');
    }
    return null;
  }

  /// Ethereum Name Service 正向解析
  Future<EnsResolutionResult?> _resolveWithEns(String domain) async {
    try {
      final result = await _tokenViewApi.getEnsResolve(domain);
      if (!result.error && result.data != null) {
        return EnsResolutionResult.success(
          address: result.data as String,
          ensName: domain,
          sourceChain: 'ETH',
          protocol: DomainProtocol.ens,
        );
      }
    } catch (e) {
      debugPrint('[DomainService] ETH ENS failed: $e');
    }
    return null;
  }

  /// Unstoppable Domains 正向解析
  ///
  /// [domain]         — UD 域名（如 alice.crypto）
  /// [preferredChain] — 期望的链地址（ETH / BNB / MATIC / BTC / SOL 等）
  ///                    为 null 时后端返回默认 EVM 地址
  Future<EnsResolutionResult?> _resolveWithUd(
    String domain,
    String? preferredChain,
  ) async {
    try {
      final ticker = _coinTypeToUdTicker(preferredChain);
      final result =
          await _tokenViewApi.getUdResolve(domain, ticker: ticker);
      if (!result.error && result.data != null) {
        return EnsResolutionResult.success(
          address: result.data as String,
          ensName: domain,
          sourceChain: 'UD',
          protocol: DomainProtocol.unstoppableDomains,
        );
      }
    } catch (e) {
      debugPrint('[DomainService] Unstoppable Domains failed: $e');
    }
    return null;
  }

  /// Solana Name Service 正向解析
  ///
  /// [domain] — .sol 域名（如 alice.sol）
  Future<EnsResolutionResult?> _resolveWithSns(String domain) async {
    try {
      final result = await _tokenViewApi.getSnsResolve(domain);
      if (!result.error && result.data != null) {
        return EnsResolutionResult.success(
          address: result.data as String,
          ensName: domain,
          sourceChain: 'SNS',
          protocol: DomainProtocol.sns,
        );
      }
    } catch (e) {
      debugPrint('[DomainService] SNS failed: $e');
    }
    return null;
  }

  // ── 私有：各协议反向解析 ────────────────────────────────────────────────

  Future<String?> _reverseResolveN42(String address) async {
    try {
      final result = await _tokenViewApi.getN42ReverseResolve(address);
      if (!result.error && result.data != null) return result.data as String;
    } catch (e) {
      debugPrint('[DomainService] N42 reverse failed: $e');
    }
    return null;
  }

  Future<String?> _reverseResolveEns(String address) async {
    try {
      final result = await _tokenViewApi.getEnsReverseResolve(address);
      if (!result.error && result.data != null) return result.data as String;
    } catch (e) {
      debugPrint('[DomainService] ENS reverse failed: $e');
    }
    return null;
  }

  Future<String?> _reverseResolveUd(
      String address, String coinType) async {
    try {
      final ticker = _coinTypeToUdTicker(coinType);
      final result =
          await _tokenViewApi.getUdReverseResolve(address, ticker: ticker);
      if (!result.error && result.data != null) return result.data as String;
    } catch (e) {
      debugPrint('[DomainService] UD reverse failed: $e');
    }
    return null;
  }

  Future<String?> _reverseResolveSns(String address) async {
    try {
      final result = await _tokenViewApi.getSnsReverseResolve(address);
      if (!result.error && result.data != null) return result.data as String;
    } catch (e) {
      debugPrint('[DomainService] SNS reverse failed: $e');
    }
    return null;
  }

  // ── 私有：头像 ────────────────────────────────────────────────────────────

  Future<String?> _fetchEnsAvatar(String domainName) async {
    try {
      final result = await _tokenViewApi.getEnsAvatar(domainName);
      if (!result.error && result.data != null) return result.data as String;
    } catch (e) {
      debugPrint('[DomainService] avatar fetch failed: $e');
    }
    return null;
  }

  // ── 私有：工具 ────────────────────────────────────────────────────────────

  /// 将 N42 coinType 映射到 UD ticker 符号
  ///
  /// UD 使用标准代币 ticker 来区分多链地址记录，例如：
  ///   crypto.ETH.address / crypto.BTC.address / crypto.SOL.address
  static String? _coinTypeToUdTicker(String? coinType) {
    if (coinType == null) return null;
    const tickerMap = {
      'ETH': 'ETH',
      'N': 'ETH',    // N42 使用 EVM 地址格式
      'BNB': 'BNB',
      'MATIC': 'MATIC',
      'AVAX': 'AVAX',
      'FTM': 'FTM',
      'OP': 'ETH',   // Optimism 使用 ETH 地址
      'ARB': 'ETH',  // Arbitrum 使用 ETH 地址
      'SOL': 'SOL',
      'BTC': 'BTC',
      'TRX': 'TRX',
      'XRP': 'XRP',
      'CELO': 'CELO',
      'ONE': 'ONE',
      'CRO': 'CRO',
      'MOVR': 'MOVR',
      'GLMR': 'GLMR',
    };
    return tickerMap[coinType.toUpperCase()];
  }

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

  static EnsService get instance {
    _instance ??= EnsService();
    return _instance!;
  }

  /// 重置实例（用于测试）
  static void reset() {
    _instance = null;
  }
}
