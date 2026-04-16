import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;

import '../../data/datasources/local/media_metadata_database.dart';
import '../../data/datasources/matrix/matrix_client_manager.dart';
import 'download_service.dart';
import '../utils/debug_log.dart';
import '../utils/matrix_utils.dart';

/// 媒体文件清理结果
class CleanupResult {
  final int filesDeleted;
  final int bytesFreed;
  final int errors;

  const CleanupResult({
    this.filesDeleted = 0,
    this.bytesFreed = 0,
    this.errors = 0,
  });

  CleanupResult operator +(CleanupResult other) => CleanupResult(
    filesDeleted: filesDeleted + other.filesDeleted,
    bytesFreed: bytesFreed + other.bytesFreed,
    errors: errors + other.errors,
  );
}

/// 媒体文件生命周期管理服务
///
/// 负责媒体文件的注册、访问追踪、自动清理与重下载。
/// 不修改 Matrix SDK 内部逻辑，通过外围元数据跟踪实现。
class MediaLifecycleService {
  final MediaMetadataDatabase _db;
  final DownloadService? _downloadService;
  Timer? _autoCleanupTimer;

  MediaLifecycleService({
    required MediaMetadataDatabase db,
    DownloadService? downloadService,
  }) : _db = db,
       _downloadService = downloadService;

  // ============================================
  // 注册与追踪
  // ============================================

  /// 注册媒体文件（下载完成后调用）
  Future<void> registerMediaFile({
    required String filePath,
    required String roomId,
    String mxcUrl = '',
    String? eventId,
    String? fileCategory,
    String? mimeType,
    int fileSize = 0,
    bool isThumbnail = false,
  }) async {
    try {
      final category = fileCategory ?? _inferCategory(filePath, mimeType);
      final now = DateTime.now();

      // 如果 fileSize 为 0，尝试读取实际文件大小
      var actualSize = fileSize;
      if (actualSize == 0) {
        try {
          final file = File(filePath);
          if (file.existsSync()) {
            actualSize = await file.length();
          }
        } catch (e) {
          debugLog('MediaLifecycleService: Failed to get file size: $e');
        }
      }

      await _db.registerFile(
        MediaFilesCompanion(
          filePath: Value(filePath),
          mxcUrl: Value(mxcUrl),
          roomId: Value(roomId),
          eventId: Value(eventId),
          fileCategory: Value(category),
          mimeType: Value(mimeType ?? lookupMimeType(filePath)),
          fileSize: Value(actualSize),
          isThumbnail: Value(isThumbnail),
          downloadedAt: Value(now),
          lastAccessedAt: Value(now),
          isCleaned: const Value(false),
          isPinned: const Value(false),
        ),
      );
    } catch (e) {
      debugLog('MediaLifecycleService: Failed to register file: $e');
    }
  }

  /// 更新访问时间（查看媒体时调用）
  Future<void> touchFile(String filePath) async {
    try {
      await _db.touchFile(filePath);
    } catch (e) {
      debugLog('MediaLifecycleService: Failed to touch file: $e');
    }
  }

  // ============================================
  // 统计查询
  // ============================================

  /// 获取房间媒体统计
  Future<RoomMediaStatsResult> getRoomMediaStats(String roomId) async {
    return _db.getRoomMediaStats(roomId);
  }

  /// 获取所有房间媒体统计
  Future<List<RoomMediaStatsResult>> getAllRoomStats() async {
    return _db.getAllRoomStats();
  }

  /// 获取总媒体统计
  Future<TotalMediaStats> getTotalStats({
    bool preserveThumbnails = true,
  }) async {
    return _db.getTotalStats(preserveThumbnails: preserveThumbnails);
  }

  /// 获取房间内的媒体文件列表
  Future<List<MediaFile>> getRoomMediaFiles({
    required String roomId,
    String? fileCategory,
    bool includeCleaned = false,
  }) async {
    return _db.getRoomMediaFiles(
      roomId: roomId,
      fileCategory: fileCategory,
      includeCleaned: includeCleaned,
    );
  }

  // ============================================
  // 清理
  // ============================================

  /// 获取可清理文件列表
  Future<List<MediaFile>> getCleanableFiles({
    int? olderThanDays,
    String? roomId,
    String? fileCategory,
    int? minFileSizeBytes,
    bool preserveThumbnails = true,
  }) async {
    return _db.getCleanableFiles(
      olderThanDays: olderThanDays,
      roomId: roomId,
      fileCategory: fileCategory,
      minFileSizeBytes: minFileSizeBytes,
      preserveThumbnails: preserveThumbnails,
    );
  }

  /// 执行清理（删物理文件，标记记录）
  Future<CleanupResult> cleanupFiles(List<String> filePaths) async {
    int deleted = 0;
    int freed = 0;
    int errors = 0;

    for (final path in filePaths) {
      try {
        final file = File(path);
        if (file.existsSync()) {
          final size = await file.length();
          await file.delete();
          freed += size;
        }
        deleted++;
      } catch (e) {
        errors++;
        debugLog('MediaLifecycleService: Failed to delete $path: $e');
      }
    }

    // 批量标记为已清理
    if (deleted > 0) {
      try {
        await _db.markCleaned(filePaths);
      } catch (e) {
        debugLog('MediaLifecycleService: Failed to mark cleaned: $e');
      }
    }

    return CleanupResult(
      filesDeleted: deleted,
      bytesFreed: freed,
      errors: errors,
    );
  }

  /// 自动清理（定时/低存储触发）
  Future<CleanupResult> autoCleanup({
    int olderThanDays = 90,
    bool preserveThumbnails = true,
  }) async {
    debugLog(
      'MediaLifecycleService: Auto cleanup started (older than $olderThanDays days)',
    );
    final files = await _db.getCleanableFiles(
      olderThanDays: olderThanDays,
      preserveThumbnails: preserveThumbnails,
    );

    if (files.isEmpty) {
      debugLog('MediaLifecycleService: No files to cleanup');
      return const CleanupResult();
    }

    final paths = files.map((f) => f.filePath).toList();
    final result = await cleanupFiles(paths);
    debugLog(
      'MediaLifecycleService: Cleaned ${result.filesDeleted} files, freed ${result.bytesFreed} bytes',
    );
    return result;
  }

  /// 重下载已清理文件
  Future<String?> redownloadFile(String filePath) async {
    try {
      final record = await _db.getCleanedFile(filePath);
      if (record == null || record.mxcUrl.isEmpty) {
        debugLog('MediaLifecycleService: No mxcUrl for redownload: $filePath');
        return null;
      }

      // 通过 DownloadService 下载，传递 metadata 以确保重新注册到生命周期管理
      if (_downloadService != null) {
        final downloadUrl = _resolveDownloadUrl(record.mxcUrl);
        if (downloadUrl == null || downloadUrl.isEmpty) {
          debugLog(
            'MediaLifecycleService: Failed to resolve download URL: ${record.mxcUrl}',
          );
          return null;
        }
        final taskId = await _downloadService.download(
          url: downloadUrl,
          savePath: filePath,
          fileName: p.basename(filePath),
          headers: _buildAuthHeaders(downloadUrl),
          metadata: {
            'roomId': record.roomId,
            if (record.eventId != null) 'eventId': record.eventId!,
            'mxcUrl': record.mxcUrl,
            'fileCategory': record.fileCategory,
            'isThumbnail': record.isThumbnail.toString(),
          },
        );
        final task = await _downloadService.waitForTaskCompletion(taskId);
        if (task.status != DownloadStatus.completed) {
          debugLog(
            'MediaLifecycleService: Redownload task failed: ${task.error ?? task.status.name}',
          );
          return null;
        }
        return filePath;
      }
      return null;
    } catch (e) {
      debugLog('MediaLifecycleService: Redownload failed: $e');
      return null;
    }
  }

  String? _resolveDownloadUrl(String url) {
    if (!url.startsWith('mxc://')) {
      return url;
    }
    return MatrixUtils.getMediaDownloadUrl(
      url,
      client: MatrixClientManager.instance.client,
    );
  }

  Map<String, String>? _buildAuthHeaders(String url) {
    final headers = MatrixUtils.buildAuthenticatedMediaHeaders(
      url,
      client: MatrixClientManager.instance.client,
    );
    return headers.isEmpty ? null : headers;
  }

  // ============================================
  // 保留标记
  // ============================================

  /// 保留/取消保留
  Future<void> togglePinned(String filePath, bool pinned) async {
    await _db.togglePinned(filePath, pinned);
  }

  // ============================================
  // 定时清理
  // ============================================

  /// 启动自动清理定时器（每24小时检查一次）
  void startAutoCleanupSchedule({int cleanupIntervalHours = 24}) {
    stopAutoCleanupSchedule();
    _autoCleanupTimer = Timer.periodic(
      Duration(hours: cleanupIntervalHours),
      (_) => autoCleanup(),
    );
    debugLog('MediaLifecycleService: Auto cleanup scheduled');
  }

  /// 停止自动清理定时器
  void stopAutoCleanupSchedule() {
    _autoCleanupTimer?.cancel();
    _autoCleanupTimer = null;
  }

  /// 释放资源
  void dispose() {
    stopAutoCleanupSchedule();
  }

  // ============================================
  // 内部辅助
  // ============================================

  /// 根据文件扩展名和 MIME 类型推断分类
  String _inferCategory(String filePath, String? mimeType) {
    final mime = mimeType ?? lookupMimeType(filePath) ?? '';
    if (mime.startsWith('image/')) return 'image';
    if (mime.startsWith('video/')) return 'video';
    if (mime.startsWith('audio/')) return 'audio';

    final ext = p.extension(filePath).toLowerCase();
    const imageExts = {
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.webp',
      '.bmp',
      '.svg',
    };
    const videoExts = {'.mp4', '.mov', '.avi', '.mkv', '.webm', '.flv'};
    const audioExts = {'.mp3', '.ogg', '.wav', '.m4a', '.aac', '.flac'};
    const docExts = {
      '.pdf',
      '.doc',
      '.docx',
      '.xls',
      '.xlsx',
      '.ppt',
      '.pptx',
      '.txt',
      '.csv',
      '.zip',
      '.rar',
    };

    if (imageExts.contains(ext)) return 'image';
    if (videoExts.contains(ext)) return 'video';
    if (audioExts.contains(ext)) return 'audio';
    if (docExts.contains(ext)) return 'document';
    return 'other';
  }
}
