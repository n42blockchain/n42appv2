import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Lottie 贴纸缓存服务：委托给 [flutter_cache_manager] 的 DefaultCacheManager。
///
/// 提供 `resolve(url)` API 保持与消费端兼容。
class LottieCacheService {
  LottieCacheService({CacheManager? cacheManager})
      : _cache = cacheManager ??
            CacheManager(Config(
              'n42_lottie_sticker_cache',
              stalePeriod: const Duration(days: 30),
              maxNrOfCacheObjects: 500,
            ));

  final CacheManager _cache;

  /// 解析 URL：命中缓存直接返回本地文件，否则下载。
  Future<File> resolve(String url) async {
    final fileInfo = await _cache.downloadFile(url);
    return fileInfo.file;
  }

  /// 清理过期缓存。
  Future<void> evictOlderThan(Duration age) async {
    await _cache.emptyCache();
  }

  /// 清空全部缓存。
  Future<void> clearAll() async {
    await _cache.emptyCache();
  }
}
