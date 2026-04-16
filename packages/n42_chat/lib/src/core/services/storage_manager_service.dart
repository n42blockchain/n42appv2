import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../data/datasources/matrix/matrix_client_manager.dart';
import '../utils/debug_log.dart';

/// 存储使用信息
class StorageInfo {
  final int totalSize;
  final int mediaSize;
  final int fileSize;
  final int cacheSize;
  final int otherSize;

  const StorageInfo({
    this.totalSize = 0,
    this.mediaSize = 0,
    this.fileSize = 0,
    this.cacheSize = 0,
    this.otherSize = 0,
  });

  String get formattedTotal => formatSize(totalSize);
  String get formattedMedia => formatSize(mediaSize);
  String get formattedFile => formatSize(fileSize);
  String get formattedCache => formatSize(cacheSize);
  String get formattedOther => formatSize(otherSize);

  static String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// 房间存储使用信息
class RoomStorageInfo {
  final String roomId;
  final String roomName;
  final int totalSize;
  final int mediaCount;
  final int fileCount;

  const RoomStorageInfo({
    required this.roomId,
    required this.roomName,
    this.totalSize = 0,
    this.mediaCount = 0,
    this.fileCount = 0,
  });

  String get formattedSize => StorageInfo.formatSize(totalSize);
}

/// 媒体文件扩展名分类常量
class MediaExtensions {
  static const Set<String> image = {
    'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg'
  };
  static const Set<String> video = {
    'mp4', 'mov', 'avi', 'mkv', 'webm'
  };
  static const Set<String> audio = {
    'mp3', 'ogg', 'wav', 'm4a', 'aac'
  };
  static const Set<String> document = {
    'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'zip', 'rar'
  };
  static const Set<String> allMedia = {
    ...image, ...video, ...audio
  };

  static bool isMedia(String ext) => allMedia.contains(ext.toLowerCase());
  static bool isDocument(String ext) => document.contains(ext.toLowerCase());
}

/// 存储管理服务
class StorageManagerService {
  final MatrixClientManager? _clientManager;

  // 存储使用缓存 (TTL 5 分钟)
  StorageInfo? _cachedStorageInfo;
  DateTime? _cacheTimestamp;
  static const Duration _cacheTtl = Duration(minutes: 5);

  StorageManagerService({MatrixClientManager? clientManager})
      : _clientManager = clientManager;

  /// 获取存储使用情况
  ///
  /// 默认返回缓存结果（TTL 5 分钟），[forceRefresh] 可绕过缓存。
  Future<StorageInfo> getStorageUsage({bool forceRefresh = false}) async {
    // 缓存有效时直接返回
    if (!forceRefresh &&
        _cachedStorageInfo != null &&
        _cacheTimestamp != null &&
        DateTime.now().difference(_cacheTimestamp!) < _cacheTtl) {
      return _cachedStorageInfo!;
    }

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final cacheDir = await getTemporaryDirectory();

      int mediaSize = 0;
      int fileSize = 0;
      int otherSize = 0;
      final cacheSize = await _directorySize(cacheDir);

      // 扫描应用目录
      await for (final entity in appDir.list(recursive: true)) {
        if (entity is File) {
          final size = await entity.length();
          final ext = entity.path.split('.').last.toLowerCase();

          if (MediaExtensions.isMedia(ext)) {
            mediaSize += size;
          } else if (MediaExtensions.isDocument(ext)) {
            fileSize += size;
          } else {
            otherSize += size;
          }
        }
      }

      final info = StorageInfo(
        totalSize: mediaSize + fileSize + cacheSize + otherSize,
        mediaSize: mediaSize,
        fileSize: fileSize,
        cacheSize: cacheSize,
        otherSize: otherSize,
      );

      _cachedStorageInfo = info;
      _cacheTimestamp = DateTime.now();
      return info;
    } catch (e) {
      debugLog('StorageManagerService: Failed to get storage usage: $e');
      return const StorageInfo();
    }
  }

  /// 清除存储使用缓存（清理操作后应调用）
  void invalidateCache() {
    _cachedStorageInfo = null;
    _cacheTimestamp = null;
  }

  /// 获取房间存储排行（前 20）
  Future<List<RoomStorageInfo>> getRoomStorageRanking() async {
    final all = await _scanAllRoomStorage();
    return all.take(20).toList();
  }

  /// 清理缓存
  Future<void> clearCache() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      if (cacheDir.existsSync()) {
        await for (final entity in cacheDir.list()) {
          try {
            if (entity is File) {
              await entity.delete();
            } else if (entity is Directory) {
              await entity.delete(recursive: true);
            }
          } catch (e) {
            debugLog('StorageManagerService: Failed to delete ${entity.path}: $e');
          }
        }
      }
      invalidateCache();
    } catch (e) {
      debugLog('StorageManagerService: Failed to clear cache: $e');
    }
  }

  /// 清理指定房间的媒体缓存
  Future<void> clearRoomMedia(String roomId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final roomCacheDir = Directory('${appDir.path}/matrix_cache/$roomId');
      if (roomCacheDir.existsSync()) {
        await roomCacheDir.delete(recursive: true);
        invalidateCache();
        debugLog('StorageManagerService: Cleared media cache for $roomId');
      }
    } catch (e) {
      debugLog('StorageManagerService: Failed to clear room media for $roomId: $e');
    }
  }

  /// 获取所有房间存储信息（不限条数）
  Future<List<RoomStorageInfo>> getAllRoomStorage() async {
    return _scanAllRoomStorage();
  }

  /// 清理房间媒体（按文件类型）
  Future<void> clearRoomMediaByCategory(
    String roomId,
    List<String> categories,
  ) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final roomCacheDir =
          Directory('${appDir.path}/matrix_cache/$roomId');
      if (!roomCacheDir.existsSync()) return;

      final categoryExts = <String>{};
      for (final cat in categories) {
        switch (cat) {
          case 'image':
            categoryExts.addAll(MediaExtensions.image);
          case 'video':
            categoryExts.addAll(MediaExtensions.video);
          case 'audio':
            categoryExts.addAll(MediaExtensions.audio);
          case 'document':
            categoryExts.addAll(MediaExtensions.document);
        }
      }

      await for (final entity in roomCacheDir.list(recursive: true)) {
        if (entity is File) {
          final ext = entity.path.split('.').last.toLowerCase();
          if (categoryExts.contains(ext)) {
            try {
              await entity.delete();
            } catch (e) {
              debugLog('StorageManagerService: Failed to delete file: $e');
            }
          }
        }
      }
      invalidateCache();
    } catch (e) {
      debugLog(
          'StorageManagerService: Failed to clear room media by category: $e');
    }
  }

  /// 清理指定日期之前的媒体文件
  Future<void> clearMediaOlderThan(
    DateTime date, {
    String? roomId,
  }) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final baseDir = roomId != null
          ? Directory('${appDir.path}/matrix_cache/$roomId')
          : Directory('${appDir.path}/matrix_cache');

      if (!baseDir.existsSync()) return;

      await for (final entity in baseDir.list(recursive: true)) {
        if (entity is File) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(date)) {
            try {
              await entity.delete();
            } catch (e) {
              debugLog('StorageManagerService: Failed to delete file: $e');
            }
          }
        }
      }
      invalidateCache();
    } catch (e) {
      debugLog(
          'StorageManagerService: Failed to clear old media: $e');
    }
  }

  /// 扫描所有房间存储（共用逻辑，按大小降序）
  Future<List<RoomStorageInfo>> _scanAllRoomStorage() async {
    try {
      final client = _clientManager?.client;
      if (client == null) return [];

      final rooms = client.rooms;
      final appDir = await getApplicationDocumentsDirectory();
      final results = <RoomStorageInfo>[];

      for (final room in rooms) {
        final roomCacheDir =
            Directory('${appDir.path}/matrix_cache/${room.id}');
        int totalSize = 0;
        int mediaCount = 0;
        int fileCount = 0;

        if (roomCacheDir.existsSync()) {
          await for (final entity in roomCacheDir.list(recursive: true)) {
            if (entity is File) {
              totalSize += await entity.length();
              final ext = entity.path.split('.').last.toLowerCase();
              if (MediaExtensions.isMedia(ext)) {
                mediaCount++;
              } else {
                fileCount++;
              }
            }
          }
        }

        if (totalSize > 0) {
          results.add(RoomStorageInfo(
            roomId: room.id,
            roomName: room.getLocalizedDisplayname(),
            totalSize: totalSize,
            mediaCount: mediaCount,
            fileCount: fileCount,
          ));
        }
      }

      results.sort((a, b) => b.totalSize.compareTo(a.totalSize));
      return results;
    } catch (e) {
      debugLog('StorageManagerService: Failed to scan room storage: $e');
      return [];
    }
  }

  Future<int> _directorySize(Directory dir) async {
    int size = 0;
    try {
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          size += await entity.length();
        }
      }
    } catch (e) {
      debugLog('StorageManagerService: Failed to calculate directory size: $e');
    }
    return size;
  }
}
