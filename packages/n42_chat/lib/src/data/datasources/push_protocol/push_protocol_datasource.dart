import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/debug_log.dart';

/// Push Protocol HTTP 数据源
///
/// 通过 Push Protocol REST API 获取链上通知。
/// 只需要钱包地址，无需钱包签名（只读模式）。
///
/// API 文档: https://push.org/docs/notifications/build/fetch-notifications/
class PushProtocolDatasource {
  final Dio _dio;
  final SharedPreferences _prefs;

  static const String _defaultBaseUrl = 'https://backend.epns.io/apis';

  /// SharedPreferences 中存储已读 ID 的 key
  static const String _readIdsKey = 'push_protocol_read_ids';

  PushProtocolDatasource({
    required SharedPreferences prefs,
    String? baseUrl,
    Dio? dio,
  }) : _prefs = prefs,
       _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl ?? _defaultBaseUrl,
               connectTimeout: const Duration(seconds: 15),
               receiveTimeout: const Duration(seconds: 15),
               headers: const {'Content-Type': 'application/json'},
             ),
           );

  /// 获取指定钱包地址的通知列表
  ///
  /// 使用 CAIP-10 地址格式：`eip155:{chainId}:{walletAddress}`
  Future<List<Map<String, dynamic>>> fetchNotifications({
    required String walletAddress,
    int chainId = 1,
    int page = 1,
    int limit = 20,
  }) async {
    final caip10 = 'eip155:$chainId:$walletAddress';
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/users/$caip10/feeds',
        queryParameters: {'page': page, 'limit': limit},
      );
      final results = response.data?['feeds'] ?? response.data?['results'];
      if (results is List) {
        return results
            .whereType<Map<Object?, Object?>>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // 地址在 Push Protocol 上没有历史通知（正常情况）
        return [];
      }
      debugLog(
        'PushProtocolDatasource: fetchNotifications error: ${e.message}',
      );
      rethrow;
    }
  }

  /// 获取已读通知 ID 集合
  Future<Set<String>> getReadIds() async {
    final jsonStr = _prefs.getString(_readIdsKey);
    if (jsonStr == null) return {};
    try {
      final list = jsonDecode(jsonStr) as List;
      return Set<String>.from(list.map((e) => e.toString()));
    } catch (_) {
      return {};
    }
  }

  /// 已读 ID 集合上限——只增不清会无限增长(复审 P2)。
  static const int _maxReadIds = 500;

  /// 将单条通知标记为已读
  Future<void> markAsRead(String notificationId) async {
    final ids = await getReadIds();
    if (ids.add(notificationId)) {
      await _prefs.setString(_readIdsKey, jsonEncode(_capped(ids)));
    }
  }

  /// 截断到最近 [_maxReadIds] 条(LinkedHashSet 保插入序,丢最老)。
  List<String> _capped(Set<String> ids) {
    if (ids.length <= _maxReadIds) return ids.toList();
    return ids.toList().sublist(ids.length - _maxReadIds);
  }

  /// 批量标记为已读
  Future<void> markAllAsRead(List<String> notificationIds) async {
    if (notificationIds.isEmpty) return;
    final ids = await getReadIds();
    final before = ids.length;
    ids.addAll(notificationIds);
    if (ids.length != before) {
      await _prefs.setString(_readIdsKey, jsonEncode(_capped(ids)));
    }
  }

  /// 清除所有已读状态（重置）
  Future<void> clearReadIds() async {
    await _prefs.remove(_readIdsKey);
  }
}
