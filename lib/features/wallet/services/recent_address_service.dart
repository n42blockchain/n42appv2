// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:convert';

import 'package:n42_wallet/features/wallet/utils/chain/chain_url_registry.dart';

import 'package:n42_wallet/core/app/app_globals.dart';

import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 最近转账地址条目
class RecentAddressEntry {
  final String address;
  final String? name; // 地址簿别名（选填，如 ENS 解析名）
  final DateTime time; // 最近使用时间

  const RecentAddressEntry({
    required this.address,
    this.name,
    required this.time,
  });

  factory RecentAddressEntry.fromJson(Map<String, dynamic> json) {
    return RecentAddressEntry(
      address: json['address'] as String,
      name: json['name'] as String?,
      time: DateTime.parse(json['time'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'address': address,
    if (name != null) 'name': name,
    'time': time.toUtc().toIso8601String(),
  };
}

/// 最近转账地址服务
///
/// Storage is partitioned by the wallet identity namespace. Legacy unscoped
/// recentSendAddresses data is retained but never assigned to a new identity.
/// Each namespace stores:
/// ```json
/// {
///   "ETH": [{"address":"0x…","name":"Alice","time":"2026-02-20T10:00:00Z"}],
///   "SOL": [{"address":"So1…","time":"2026-02-19T08:00:00Z"}]
/// }
/// ```
class RecentAddressService {
  static const int _maxPerChain = 10;
  static String get currentUser => AppGlobals.walletStorageUuid;
  static Future<void>? _pending;
  static String _key(String user) =>
      '${SPkey.recentSendAddresses.name}.v2.${base64Url.encode(utf8.encode(user))}';
  static Future<T> _mutate<T>(Future<T> Function() operation) {
    final previous = _pending;
    final next = previous == null
        ? Future<T>.sync(operation)
        : previous.then((_) => operation());
    final settled = next.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    _pending = settled;
    settled.then((_) {
      if (identical(_pending, settled)) _pending = null;
    });
    return next;
  }

  /// 读取底层存储（完整 map，key = coinType）
  static Future<Map<String, List<RecentAddressEntry>>> _readAll(
    String user, {
    bool strict = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(user));
    if (raw == null) return {};

    try {
      final decoded = json.decode(raw) as Map<String, dynamic>;
      return decoded.map((coinType, listRaw) {
        final entries = (listRaw as List<dynamic>)
            .map((e) => RecentAddressEntry.fromJson(e as Map<String, dynamic>))
            .toList();
        return MapEntry(coinType, entries);
      });
    } catch (_) {
      if (strict) {
        throw const FormatException('Recent address storage is damaged');
      }
      return {};
    }
  }

  /// 写入底层存储
  static Future<void> _writeAll(
    String user,
    Map<String, List<RecentAddressEntry>> data,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(
      data.map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList())),
    );
    if (!await prefs.setString(_key(user), encoded)) {
      throw StateError('Recent addresses were not saved');
    }
  }

  /// 保存地址：插到头部、按地址去重、截断至 [_maxPerChain]
  ///
  /// 若地址已存在，则更新其时间和名称（移到头部）。
  /// Returns false if history cannot be saved; this does not undo a transfer.
  static Future<bool> save(
    String coinType,
    String address, {
    String? name,
    String? userUuid,
  }) {
    final user = userUuid ?? currentUser;
    if (address.isEmpty || user.isEmpty) return Future.value(false);
    return _mutate(() async {
      try {
        await _save(user, coinType, address, name);
        return true;
      } catch (_) {
        // Ancillary history failure must not turn an accepted transfer into a
        // retryable payment error. Keep the original stored bytes untouched.
        return false;
      }
    });
  }

  static Future<void> _save(
    String user,
    String coinType,
    String address,
    String? name,
  ) async {
    final all = await _readAll(user, strict: true);
    final list = List<RecentAddressEntry>.from(all[coinType] ?? []);

    // Only known EVM families have case-insensitive recipient identity.
    // Base58 and unknown/custom chains must preserve exact address bytes.
    final isEvm =
        allChainUrlMap[coinType]?['baseInfo']?['blockchainType'] == 'Ethereum';
    list.removeWhere(
      (e) => isEvm
          ? e.address.toLowerCase() == address.toLowerCase()
          : e.address == address,
    );

    // 插到头部
    list.insert(
      0,
      RecentAddressEntry(
        address: address,
        name: name,
        time: DateTime.now().toUtc(),
      ),
    );

    // 截断至上限
    if (list.length > _maxPerChain) {
      list.removeRange(_maxPerChain, list.length);
    }

    all[coinType] = list;
    await _writeAll(user, all);
  }

  /// 读取指定链最近 [maxCount] 条地址（按时间倒序，默认 5 条）
  static Future<List<RecentAddressEntry>> load(
    String coinType, {
    int maxCount = 5,
    String? userUuid,
    bool reportReadErrors = false,
  }) async {
    final user = userUuid ?? currentUser;
    if (user.isEmpty) return [];
    final pending = _pending;
    if (pending != null) await pending;
    final all = await _readAll(user, strict: reportReadErrors);
    if (userUuid == null && user != currentUser) return [];
    final list = all[coinType] ?? [];
    // 存储时已按时间倒序排列（save 总是插到头部），直接截取
    return list.take(maxCount).toList();
  }

  /// 清除指定链历史，其他链不受影响
  static Future<void> clear(String coinType, {String? userUuid}) {
    final user = userUuid ?? currentUser;
    if (user.isEmpty) return Future.value();
    return _mutate(() async {
      final all = await _readAll(user, strict: true);
      all.remove(coinType);
      await _writeAll(user, all);
    });
  }
}
