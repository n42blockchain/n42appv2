// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/wallet/api/token_view_api.dart';
import 'package:n42appv2/src/models/message_model.dart';

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

  /// 来源链 (N42, ETH, etc.)
  final String? sourceChain;

  const EnsResolutionResult({
    required this.success,
    this.address,
    this.ensName,
    this.avatar,
    this.error,
    this.sourceChain,
  });

  factory EnsResolutionResult.success({
    required String address,
    String? ensName,
    String? avatar,
    String? sourceChain,
  }) {
    return EnsResolutionResult(
      success: true,
      address: address,
      ensName: ensName,
      avatar: avatar,
      sourceChain: sourceChain,
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

/// ENS 服务 - 提供完整的 ENS 功能
///
/// 功能特性（对标 MetaMask、Rainbow 等主流钱包）:
/// - 正向解析 (ENS name -> address)
/// - 反向解析 (address -> ENS name)
/// - 头像解析
/// - 文本记录解析
/// - 多链支持 (N42 优先，ETH 主网回退)
/// - 缓存机制
class EnsService {
  final TokenViewApi _tokenViewApi;

  /// 正向解析缓存 (name -> address)
  final Map<String, _CacheEntry<EnsResolutionResult>> _forwardCache = {};

  /// 反向解析缓存 (address -> name)
  final Map<String, _CacheEntry<String?>> _reverseCache = {};

  /// 头像缓存
  final Map<String, _CacheEntry<String?>> _avatarCache = {};

  /// 缓存有效期 (5 分钟)
  static const _cacheDuration = Duration(minutes: 5);

  /// 支持的 ENS 后缀
  static const ensSuffixes = [
    '.n42', // N42 Name Service (优先)
    '.eth', // Ethereum Name Service
    '.xyz', // ENS 支持的通用域名
    '.app', // ENS 支持的应用域名
    '.luxe', // ENS 支持的奢侈品域名
    '.kred', // ENS 支持的信用域名
    '.art', // ENS 支持的艺术域名
  ];

  EnsService({TokenViewApi? tokenViewApi})
      : _tokenViewApi = tokenViewApi ?? TokenViewApi();

  /// 检查字符串是否是 ENS 名称
  static bool isEnsName(String input) {
    final lowercaseInput = input.toLowerCase().trim();
    for (final suffix in ensSuffixes) {
      if (lowercaseInput.endsWith(suffix)) {
        return true;
      }
    }
    return false;
  }

  /// 检查链是否支持 ENS
  static bool chainSupportsEns(String coinType) {
    // N42 链优先支持
    if (coinType == CoinType.N.name) return true;
    // ETH 主网
    if (coinType == CoinType.ETH.name) return true;
    // 其他 EVM 兼容链
    const evmChains = [
      'BNB', 'MATIC', 'AVAX', 'FTM', 'OP', 'ARB',
      'CELO', 'ONE', 'CRO', 'MOVR', 'GLMR',
    ];
    return evmChains.contains(coinType);
  }

  /// 正向解析 - 将 ENS 名称解析为地址
  ///
  /// [ensName] - ENS 名称 (如 vitalik.eth 或 user.n42)
  /// [preferredChain] - 优先使用的链 (默认 N42 优先)
  /// [useCache] - 是否使用缓存
  Future<EnsResolutionResult> resolveName(
    String ensName, {
    String? preferredChain,
    bool useCache = true,
  }) async {
    final normalizedName = ensName.toLowerCase().trim();

    // 检查缓存
    if (useCache) {
      final cached = _getFromCache(_forwardCache, normalizedName);
      if (cached != null) {
        return cached;
      }
    }

    try {
      String? resolvedAddress;
      String? sourceChain;

      // N42 名称 (.n42) 或在 N42 链上请求时，优先使用 N42 解析
      if (normalizedName.endsWith('.n42') ||
          preferredChain == CoinType.N.name) {
        final n42Result = await _resolveN42(normalizedName);
        if (n42Result != null) {
          resolvedAddress = n42Result;
          sourceChain = 'N42';
        }
      }

      // 如果 N42 解析失败，回退到 ETH ENS
      if (resolvedAddress == null) {
        final ethResult = await _resolveEth(normalizedName);
        if (ethResult != null) {
          resolvedAddress = ethResult;
          sourceChain = 'ETH';
        }
      }

      if (resolvedAddress != null) {
        final result = EnsResolutionResult.success(
          address: resolvedAddress,
          ensName: normalizedName,
          sourceChain: sourceChain,
        );

        // 更新缓存
        _addToCache(_forwardCache, normalizedName, result);

        return result;
      }

      return EnsResolutionResult.failure('ENS name not found');
    } catch (e) {
      debugPrint('ENS resolution error: $e');
      return EnsResolutionResult.failure('Resolution failed: $e');
    }
  }

  /// 反向解析 - 将地址解析为 ENS 名称
  ///
  /// [address] - 以太坊地址
  /// [coinType] - 链类型
  /// [useCache] - 是否使用缓存
  Future<String?> resolveAddress(
    String address, {
    String coinType = 'ETH',
    bool useCache = true,
  }) async {
    final normalizedAddress = address.toLowerCase();

    // 检查缓存（使用 containsKey 区分"已缓存 null"与"缓存未命中"）
    if (useCache && _isInReverseCache(normalizedAddress)) {
      return _reverseCache[normalizedAddress]!.value;
    }

    try {
      String? ensName;

      // N42 链优先
      if (coinType == CoinType.N.name) {
        ensName = await _reverseResolveN42(normalizedAddress);
      }

      // ETH 回退
      ensName ??= await _reverseResolveEth(normalizedAddress);

      // 更新缓存（即使为 null 也缓存，避免对同一地址重复查询）
      _addToCache(_reverseCache, normalizedAddress, ensName);

      return ensName;
    } catch (e) {
      debugPrint('Reverse ENS resolution error: $e');
      return null;
    }
  }

  /// 获取 ENS 头像
  ///
  /// [ensName] - ENS 名称
  /// [useCache] - 是否使用缓存
  Future<String?> getAvatar(String ensName, {bool useCache = true}) async {
    final normalizedName = ensName.toLowerCase().trim();

    // 检查缓存
    if (useCache) {
      final cached = _getFromCache(_avatarCache, normalizedName);
      if (cached != null) {
        return cached;
      }
    }

    try {
      final avatar = await _fetchAvatar(normalizedName);

      // 更新缓存
      _addToCache(_avatarCache, normalizedName, avatar);

      return avatar;
    } catch (e) {
      debugPrint('ENS avatar fetch error: $e');
      return null;
    }
  }

  /// 获取 ENS 文本记录
  Future<EnsTextRecords?> getTextRecords(String ensName) async {
    try {
      final result = await _tokenViewApi.getEnsTextRecords(ensName);
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
      debugPrint('ENS text records fetch error: $e');
    }
    return null;
  }

  /// 批量解析多个 ENS 名称
  Future<Map<String, EnsResolutionResult>> resolveNames(
    List<String> ensNames, {
    String? preferredChain,
  }) async {
    final results = <String, EnsResolutionResult>{};

    // 并行解析
    final futures = ensNames.map((name) async {
      final result = await resolveName(name, preferredChain: preferredChain);
      return MapEntry(name, result);
    });

    final entries = await Future.wait(futures);
    for (final entry in entries) {
      results[entry.key] = entry.value;
    }

    return results;
  }

  /// 批量反向解析多个地址
  Future<Map<String, String?>> resolveAddresses(
    List<String> addresses, {
    String coinType = 'ETH',
  }) async {
    final results = <String, String?>{};

    // 并行解析
    final futures = addresses.map((addr) async {
      final result = await resolveAddress(addr, coinType: coinType);
      return MapEntry(addr, result);
    });

    final entries = await Future.wait(futures);
    for (final entry in entries) {
      results[entry.key] = entry.value;
    }

    return results;
  }

  /// 清除缓存
  void clearCache() {
    _forwardCache.clear();
    _reverseCache.clear();
    _avatarCache.clear();
  }

  // ============ Private Methods ============

  /// N42 ENS 解析
  Future<String?> _resolveN42(String ensName) async {
    try {
      MessageModel result = await _tokenViewApi.getN42EnsResolve(ensName);
      if (!result.error && result.data != null) {
        return result.data as String;
      }
    } catch (e) {
      debugPrint('N42 ENS resolution failed: $e');
    }
    return null;
  }

  /// ETH ENS 解析
  Future<String?> _resolveEth(String ensName) async {
    try {
      MessageModel result = await _tokenViewApi.getEnsResolve(ensName);
      if (!result.error && result.data != null) {
        return result.data as String;
      }
    } catch (e) {
      debugPrint('ETH ENS resolution failed: $e');
    }
    return null;
  }

  /// N42 反向解析
  Future<String?> _reverseResolveN42(String address) async {
    try {
      MessageModel result = await _tokenViewApi.getN42ReverseResolve(address);
      if (!result.error && result.data != null) {
        return result.data as String;
      }
    } catch (e) {
      debugPrint('N42 reverse resolution failed: $e');
    }
    return null;
  }

  /// ETH 反向解析
  Future<String?> _reverseResolveEth(String address) async {
    try {
      MessageModel result = await _tokenViewApi.getEnsReverseResolve(address);
      if (!result.error && result.data != null) {
        return result.data as String;
      }
    } catch (e) {
      debugPrint('ETH reverse resolution failed: $e');
    }
    return null;
  }

  /// 获取头像
  Future<String?> _fetchAvatar(String ensName) async {
    try {
      MessageModel result = await _tokenViewApi.getEnsAvatar(ensName);
      if (!result.error && result.data != null) {
        return result.data as String;
      }
    } catch (e) {
      debugPrint('ENS avatar fetch failed: $e');
    }
    return null;
  }

  /// 从缓存获取（仅适用于非空值类型；nullable 类型请用 [_isInReverseCache]）
  T? _getFromCache<T>(Map<String, _CacheEntry<T>> cache, String key) {
    final entry = cache[key];
    if (entry != null && !entry.isExpired) {
      return entry.value;
    }
    // 清除过期条目
    if (entry != null) {
      cache.remove(key);
    }
    return null;
  }

  /// 检查反向解析缓存中是否存在有效条目（可区分"已缓存 null"与"缓存未命中"）
  bool _isInReverseCache(String key) {
    final entry = _reverseCache[key];
    if (entry == null) return false;
    if (entry.isExpired) {
      _reverseCache.remove(key);
      return false;
    }
    return true;
  }

  /// 添加到缓存
  void _addToCache<T>(Map<String, _CacheEntry<T>> cache, String key, T value) {
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

/// ENS 服务单例
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
