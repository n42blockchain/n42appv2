import 'dart:async';

import 'package:matrix/matrix.dart' as matrix;

import '../../data/datasources/matrix/matrix_client_manager.dart';
import '../../integration/wallet_bridge.dart';
import '../utils/debug_log.dart';

/// ENS 缓存服务
///
/// 缓存策略：内存缓存（TTL 1h）+ Matrix 账户数据持久化。
class EnsCacheService {
  final MatrixClientManager _clientManager;
  final IWalletBridge _walletBridge;

  static const String _accountDataKey = 'n42.ens_cache';
  static const Duration _cacheTtl = Duration(hours: 1);

  /// 内存缓存：address → (ensName, timestamp)
  final Map<String, _CacheEntry> _addressToEns = {};
  /// 内存缓存：ensName → (address, timestamp)
  final Map<String, _CacheEntry> _ensToAddress = {};

  matrix.Client? get _client => _clientManager.client;

  EnsCacheService({
    required MatrixClientManager clientManager,
    required IWalletBridge walletBridge,
  })  : _clientManager = clientManager,
        _walletBridge = walletBridge;

  /// 正向解析 ENS 域名 → 地址（带缓存）
  Future<String?> resolveEnsName(String ensName) async {
    // 检查内存缓存
    final cached = _ensToAddress[ensName.toLowerCase()];
    if (cached != null && !cached.isExpired) {
      return cached.value;
    }

    // 调用 WalletBridge 解析
    try {
      final address = await _walletBridge.resolveEnsName(ensName);
      if (address != null) {
        _ensToAddress[ensName.toLowerCase()] = _CacheEntry(address);
        _addressToEns[address.toLowerCase()] = _CacheEntry(ensName);
        _persistCache();
      }
      return address;
    } catch (e) {
      debugLog('EnsCacheService: Failed to resolve ENS: $e');
      return null;
    }
  }

  /// 反向解析 地址 → ENS 域名（带缓存）
  Future<String?> lookupEnsName(String address) async {
    // 检查内存缓存
    final cached = _addressToEns[address.toLowerCase()];
    if (cached != null && !cached.isExpired) {
      return cached.value;
    }

    try {
      final ensName = await _walletBridge.lookupEnsName(address);
      if (ensName != null) {
        _addressToEns[address.toLowerCase()] = _CacheEntry(ensName);
        _ensToAddress[ensName.toLowerCase()] = _CacheEntry(address);
        _persistCache();
      }
      return ensName;
    } catch (e) {
      debugLog('EnsCacheService: Failed to lookup ENS: $e');
      return null;
    }
  }

  /// 批量反向解析
  Future<Map<String, String?>> batchLookupEnsNames(List<String> addresses) async {
    final results = <String, String?>{};
    final uncached = <String>[];

    // 先检查缓存
    for (final addr in addresses) {
      final cached = _addressToEns[addr.toLowerCase()];
      if (cached != null && !cached.isExpired) {
        results[addr] = cached.value;
      } else {
        uncached.add(addr);
      }
    }

    // 批量查询未缓存的
    if (uncached.isNotEmpty) {
      final batchResults = await _walletBridge.batchLookupEnsNames(uncached);
      for (final entry in batchResults.entries) {
        results[entry.key] = entry.value;
        if (entry.value != null) {
          _addressToEns[entry.key.toLowerCase()] = _CacheEntry(entry.value!);
          _ensToAddress[entry.value!.toLowerCase()] = _CacheEntry(entry.key);
        }
      }
      _persistCache();
    }

    return results;
  }

  /// 获取 ENS 头像
  Future<String?> getEnsAvatar(String ensName) async {
    return _walletBridge.getEnsAvatar(ensName);
  }

  /// 从 Matrix 账户数据恢复缓存
  Future<void> restoreCache() async {
    if (_client == null) return;

    try {
      final data = _client!.accountData[_accountDataKey]?.content;
      if (data == null) return;

      final addressMap = data['address_to_ens'] as Map<String, dynamic>?;
      if (addressMap != null) {
        for (final entry in addressMap.entries) {
          _addressToEns[entry.key] = _CacheEntry(entry.value as String);
        }
      }

      final ensMap = data['ens_to_address'] as Map<String, dynamic>?;
      if (ensMap != null) {
        for (final entry in ensMap.entries) {
          _ensToAddress[entry.key] = _CacheEntry(entry.value as String);
        }
      }
    } catch (e) {
      debugLog('EnsCacheService: Failed to restore cache: $e');
    }
  }

  /// 持久化缓存到 Matrix 账户数据
  void _persistCache() {
    if (_client == null) return;

    try {
      final addressMap = <String, String>{};
      for (final entry in _addressToEns.entries) {
        if (!entry.value.isExpired) {
          addressMap[entry.key] = entry.value.value;
        }
      }

      final ensMap = <String, String>{};
      for (final entry in _ensToAddress.entries) {
        if (!entry.value.isExpired) {
          ensMap[entry.key] = entry.value.value;
        }
      }

      _client!.setAccountData(
        _client!.userID!,
        _accountDataKey,
        {
          'address_to_ens': addressMap,
          'ens_to_address': ensMap,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
      );
    } catch (e) {
      debugLog('EnsCacheService: Failed to persist cache: $e');
    }
  }
}

class _CacheEntry {
  final String value;
  final DateTime createdAt;

  _CacheEntry(this.value) : createdAt = DateTime.now();

  bool get isExpired =>
      DateTime.now().difference(createdAt) > EnsCacheService._cacheTtl;
}
