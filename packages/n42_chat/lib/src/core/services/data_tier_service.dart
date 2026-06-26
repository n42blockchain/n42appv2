import 'package:matrix/matrix.dart' as matrix;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import 'media_lifecycle_service.dart';
import 'message_archive_service.dart';
import 'storage_monitor_service.dart';
import '../utils/debug_log.dart';

/// 数据层级
enum DataTier {
  /// 热数据 (30天内): 内存缓存 + 本地DB + 完整媒体
  hot,

  /// 暖数据 (30-180天): 本地DB + 缩略图，原图按需加载
  warm,

  /// 冷数据 (180天+): 本地DB保留消息，媒体自动清理
  cold,

  /// 临时数据: 缓存/temp → 低存储自动清理
  ephemeral,
}

/// 层级配置
class TierConfig {
  /// 热数据天数
  final int hotDays;

  /// 暖数据天数
  final int warmDays;

  /// 是否启用自动分级维护
  final bool autoMaintenanceEnabled;

  const TierConfig({
    this.hotDays = 30,
    this.warmDays = 180,
    this.autoMaintenanceEnabled = false,
  });

  TierConfig copyWith({
    int? hotDays,
    int? warmDays,
    bool? autoMaintenanceEnabled,
  }) {
    return TierConfig(
      hotDays: hotDays ?? this.hotDays,
      warmDays: warmDays ?? this.warmDays,
      autoMaintenanceEnabled:
          autoMaintenanceEnabled ?? this.autoMaintenanceEnabled,
    );
  }
}

/// 分级维护结果
class TierMaintenanceResult {
  final int warmFilesProcessed;
  final int coldFilesCleaned;
  final int bytesFreed;

  const TierMaintenanceResult({
    this.warmFilesProcessed = 0,
    this.coldFilesCleaned = 0,
    this.bytesFreed = 0,
  });
}

/// 数据分级服务
///
/// 根据消息/媒体的时间戳自动分级管理：
/// - Hot: 完整保留
/// - Warm: 仅保留缩略图
/// - Cold: 清理媒体文件
class DataTierService {
  final MediaLifecycleService _lifecycleService;
  final StorageMonitorService _monitorService;
  MessageArchiveService? _archiveService;
  matrix.Client? _matrixClient;
  bool _isMaintenanceRunning = false;
  bool _isEmergencyRunning = false;

  DataTierService({
    required MediaLifecycleService lifecycleService,
    required StorageMonitorService monitorService,
    MessageArchiveService? archiveService,
    matrix.Client? matrixClient,
  })  : _lifecycleService = lifecycleService,
        _monitorService = monitorService,
        _archiveService = archiveService,
        _matrixClient = matrixClient;

  /// 延迟注入归档服务（避免循环依赖）
  void setArchiveService(MessageArchiveService service) {
    _archiveService = service;
  }

  /// 设置 Matrix 客户端引用（用于获取活跃房间列表）
  void setMatrixClient(matrix.Client client) {
    _matrixClient = client;
  }

  /// 判断消息所属数据层级
  DataTier getMessageTier(DateTime timestamp) {
    final age = DateTime.now().difference(timestamp).inDays;
    if (age <= StorageConstants.hotDataDays) return DataTier.hot;
    if (age <= StorageConstants.warmDataDays) return DataTier.warm;
    return DataTier.cold;
  }

  /// 执行分级维护
  ///
  /// 1. Warm 层文件：保留缩略图，标记原图可清理
  /// 2. Cold 层文件：清理所有非 pinned 媒体
  Future<TierMaintenanceResult> performMaintenance() async {
    if (_isMaintenanceRunning) {
      debugLog('DataTierService: Maintenance already running, skipping');
      return const TierMaintenanceResult();
    }
    _isMaintenanceRunning = true;

    try {
      return await _performMaintenanceInternal();
    } finally {
      _isMaintenanceRunning = false;
    }
  }

  Future<TierMaintenanceResult> _performMaintenanceInternal() async {
    debugLog('DataTierService: Starting tier maintenance');
    final config = await getTierConfig();

    // 在清理冷数据之前，先归档消息到 archive.db
    if (_archiveService != null && config.autoMaintenanceEnabled) {
      await _archiveActiveRooms();
    }

    int warmProcessed = 0;
    int coldCleaned = 0;
    int totalFreed = 0;

    // 处理 Cold 层（超过 warmDays 的文件）
    final coldFiles = await _lifecycleService.getCleanableFiles(
      olderThanDays: config.warmDays,
    );
    if (coldFiles.isNotEmpty) {
      final result = await _lifecycleService
          .cleanupFiles(coldFiles.map((f) => f.filePath).toList());
      coldCleaned = result.filesDeleted;
      totalFreed += result.bytesFreed;
    }

    // 处理 Warm 层（hotDays 到 warmDays 之间，只清理非缩略图的大文件）
    final warmFiles = await _lifecycleService.getCleanableFiles(
      olderThanDays: config.hotDays,
      minFileSizeBytes: StorageConstants.largeFileThreshold,
    );
    // 过滤掉已在 cold 清理范围内的
    final warmOnly = warmFiles
        .where((f) =>
            DateTime.now().difference(f.lastAccessedAt).inDays <
            config.warmDays)
        .toList();
    if (warmOnly.isNotEmpty) {
      final result = await _lifecycleService
          .cleanupFiles(warmOnly.map((f) => f.filePath).toList());
      warmProcessed = result.filesDeleted;
      totalFreed += result.bytesFreed;
    }

    debugLog(
        'DataTierService: Maintenance done. Warm: $warmProcessed, Cold: $coldCleaned, Freed: $totalFreed bytes');

    return TierMaintenanceResult(
      warmFilesProcessed: warmProcessed,
      coldFilesCleaned: coldCleaned,
      bytesFreed: totalFreed,
    );
  }

  /// 紧急清理（存储严重不足时）
  ///
  /// 从最旧的文件开始清理，直到释放至少 100MB
  Future<int> emergencyCleanup() async {
    if (_isEmergencyRunning) {
      debugLog('DataTierService: Emergency cleanup already running, skipping');
      return 0;
    }
    _isEmergencyRunning = true;

    try {
      return await _emergencyCleanupInternal();
    } finally {
      _isEmergencyRunning = false;
    }
  }

  Future<int> _emergencyCleanupInternal() async {
    final status = await _monitorService.checkStorageStatus();
    debugLog(
        'DataTierService: Emergency cleanup triggered (level: ${status.level})');
    const targetFreeBytes = 100 * 1024 * 1024; // 100MB
    int totalFreed = 0;

    // 阶段1：清理所有 Cold 层
    final coldFiles = await _lifecycleService.getCleanableFiles(
      olderThanDays: StorageConstants.warmDataDays,
    );
    if (coldFiles.isNotEmpty) {
      final result = await _lifecycleService
          .cleanupFiles(coldFiles.map((f) => f.filePath).toList());
      totalFreed += result.bytesFreed;
    }

    if (totalFreed >= targetFreeBytes) return totalFreed;

    // 阶段2：清理 Warm 层大文件
    final warmLargeFiles = await _lifecycleService.getCleanableFiles(
      olderThanDays: StorageConstants.hotDataDays,
      minFileSizeBytes: 5 * 1024 * 1024, // 5MB+
    );
    if (warmLargeFiles.isNotEmpty) {
      final result = await _lifecycleService
          .cleanupFiles(warmLargeFiles.map((f) => f.filePath).toList());
      totalFreed += result.bytesFreed;
    }

    if (totalFreed >= targetFreeBytes) return totalFreed;

    // 阶段3：清理所有 Warm 层
    final allWarm = await _lifecycleService.getCleanableFiles(
      olderThanDays: StorageConstants.hotDataDays,
    );
    if (allWarm.isNotEmpty) {
      final result = await _lifecycleService
          .cleanupFiles(allWarm.map((f) => f.filePath).toList());
      totalFreed += result.bytesFreed;
    }

    debugLog('DataTierService: Emergency cleanup freed $totalFreed bytes');
    return totalFreed;
  }

  /// 获取分级配置
  Future<TierConfig> getTierConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return TierConfig(
        hotDays: prefs.getInt('tier_hot_days') ??
            StorageConstants.hotDataDays,
        warmDays: prefs.getInt('tier_warm_days') ??
            StorageConstants.warmDataDays,
        autoMaintenanceEnabled:
            prefs.getBool('tier_auto_maintenance') ?? false,
      );
    } catch (_) {
      return const TierConfig();
    }
  }

  /// 更新分级配置
  Future<void> updateTierConfig(TierConfig config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('tier_hot_days', config.hotDays);
      await prefs.setInt('tier_warm_days', config.warmDays);
      await prefs.setBool(
          'tier_auto_maintenance', config.autoMaintenanceEnabled);
    } catch (e) {
      debugLog('DataTierService: Failed to save config: $e');
    }
  }

  /// 归档所有活跃房间的消息
  Future<void> _archiveActiveRooms() async {
    final archive = _archiveService;
    if (archive == null) return;

    try {
      final rooms = _matrixClient?.rooms ?? [];
      final roomIds = rooms.map((r) => r.id).toList();

      debugLog('DataTierService: Archiving ${roomIds.length} rooms');
      for (final roomId in roomIds) {
        try {
          await archive.archiveRoom(roomId);
        } catch (e) {
          debugLog('DataTierService: Failed to archive room $roomId: $e');
        }
      }
    } catch (e) {
      debugLog('DataTierService: Archive operation failed: $e');
    }
  }
}
