// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:convert';

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
/// 存储格式（SharedPreferences key = recentSendAddresses）：
/// ```json
/// {
///   "ETH": [{"address":"0x…","name":"Alice","time":"2026-02-20T10:00:00Z"}],
///   "SOL": [{"address":"So1…","time":"2026-02-19T08:00:00Z"}]
/// }
/// ```
class RecentAddressService {
  static const int _maxPerChain = 10;

  /// 读取底层存储（完整 map，key = coinType）
  static Future<Map<String, List<RecentAddressEntry>>> _readAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(SPkey.recentSendAddresses.name);
    if (raw == null || raw.isEmpty) return {};

    try {
      final decoded = json.decode(raw) as Map<String, dynamic>;
      return decoded.map((coinType, listRaw) {
        final entries = (listRaw as List<dynamic>)
            .map((e) =>
                RecentAddressEntry.fromJson(e as Map<String, dynamic>))
            .toList();
        return MapEntry(coinType, entries);
      });
    } catch (_) {
      return {};
    }
  }

  /// 写入底层存储
  static Future<void> _writeAll(
      Map<String, List<RecentAddressEntry>> data) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(
      data.map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList())),
    );
    await prefs.setString(SPkey.recentSendAddresses.name, encoded);
  }

  /// 保存地址：插到头部、按地址去重、截断至 [_maxPerChain]
  ///
  /// 若地址已存在，则更新其时间和名称（移到头部）。
  static Future<void> save(
    String coinType,
    String address, {
    String? name,
  }) async {
    if (address.isEmpty) return;

    final all = await _readAll();
    final list = List<RecentAddressEntry>.from(all[coinType] ?? []);

    // 去重：移除旧条目（不区分大小写比对）
    list.removeWhere(
        (e) => e.address.toLowerCase() == address.toLowerCase());

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
    await _writeAll(all);
  }

  /// 读取指定链最近 [maxCount] 条地址（按时间倒序，默认 5 条）
  static Future<List<RecentAddressEntry>> load(
    String coinType, {
    int maxCount = 5,
  }) async {
    final all = await _readAll();
    final list = all[coinType] ?? [];
    // 存储时已按时间倒序排列（save 总是插到头部），直接截取
    return list.take(maxCount).toList();
  }

  /// 清除指定链历史，其他链不受影响
  static Future<void> clear(String coinType) async {
    final all = await _readAll();
    all.remove(coinType);
    await _writeAll(all);
  }
}
