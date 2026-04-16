import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import 'media_lifecycle_service.dart';
import 'storage_manager_service.dart';
import '../utils/debug_log.dart';

/// 存储级别
enum StorageLevel { normal, warning, critical }

/// 存储状态
class StorageStatus {
  /// 总已用空间（字节）
  final int totalUsedBytes;

  /// 媒体文件空间
  final int mediaBytes;

  /// 可清理空间
  final int cleanableBytes;

  /// 缓存空间
  final int cacheBytes;

  /// 存储级别
  final StorageLevel level;

  /// 设备剩余空间
  final int? deviceFreeBytes;

  const StorageStatus({
    this.totalUsedBytes = 0,
    this.mediaBytes = 0,
    this.cleanableBytes = 0,
    this.cacheBytes = 0,
    this.level = StorageLevel.normal,
    this.deviceFreeBytes,
  });

  String get formattedTotal => StorageInfo.formatSize(totalUsedBytes);
  String get formattedMedia => StorageInfo.formatSize(mediaBytes);
  String get formattedCleanable => StorageInfo.formatSize(cleanableBytes);
  String get formattedCache => StorageInfo.formatSize(cacheBytes);
}

/// 存储管理配置
class StorageConfig {
  /// 预警阈值 (MB)
  final int warningThresholdMB;

  /// 严重阈值 (MB)
  final int criticalThresholdMB;

  /// 自动清理天数
  final int autoCleanupDays;

  /// 是否启用自动清理
  final bool autoCleanupEnabled;

  /// 是否保留缩略图
  final bool preserveThumbnails;

  const StorageConfig({
    this.warningThresholdMB = 500,
    this.criticalThresholdMB = 1000,
    this.autoCleanupDays = 90,
    this.autoCleanupEnabled = false,
    this.preserveThumbnails = true,
  });

  StorageConfig copyWith({
    int? warningThresholdMB,
    int? criticalThresholdMB,
    int? autoCleanupDays,
    bool? autoCleanupEnabled,
    bool? preserveThumbnails,
  }) {
    return StorageConfig(
      warningThresholdMB: warningThresholdMB ?? this.warningThresholdMB,
      criticalThresholdMB: criticalThresholdMB ?? this.criticalThresholdMB,
      autoCleanupDays: autoCleanupDays ?? this.autoCleanupDays,
      autoCleanupEnabled: autoCleanupEnabled ?? this.autoCleanupEnabled,
      preserveThumbnails: preserveThumbnails ?? this.preserveThumbnails,
    );
  }
}

/// 存储监控与预警服务
class StorageMonitorService {
  final StorageManagerService _storageManager;
  final MediaLifecycleService _lifecycleService;
  final StreamController<StorageStatus> _statusController =
      StreamController<StorageStatus>.broadcast();
  Timer? _monitorTimer;

  StorageMonitorService({
    required StorageManagerService storageManager,
    required MediaLifecycleService lifecycleService,
  })  : _storageManager = storageManager,
        _lifecycleService = lifecycleService;

  /// 检查存储状态
  Future<StorageStatus> checkStorageStatus() async {
    try {
      final storageInfo = await _storageManager.getStorageUsage();
      final config = await getStorageConfig();
      final mediaStats = await _lifecycleService.getTotalStats(
        preserveThumbnails: config.preserveThumbnails,
      );

      // 获取设备剩余空间
      int? deviceFree;
      try {
        deviceFree = await _getDeviceFreeSpace();
      } catch (e) {
        debugLog('StorageMonitorService: Failed to get device free space: $e');
      }

      // 优先基于设备剩余空间判断，回退到 app 占用大小
      StorageLevel level;
      if (deviceFree != null) {
        final freeGB = deviceFree / (1024 * 1024 * 1024);
        if (freeGB < 0.5) {
          // 设备剩余空间 < 500MB → critical
          level = StorageLevel.critical;
        } else if (freeGB < 2.0) {
          // 设备剩余空间 < 2GB → warning
          level = StorageLevel.warning;
        } else {
          level = StorageLevel.normal;
        }
      } else {
        // 无法获取设备空间时回退到 app 占用判断
        final totalMB = storageInfo.totalSize / (1024 * 1024);
        if (totalMB >= config.criticalThresholdMB) {
          level = StorageLevel.critical;
        } else if (totalMB >= config.warningThresholdMB) {
          level = StorageLevel.warning;
        } else {
          level = StorageLevel.normal;
        }
      }

      final status = StorageStatus(
        totalUsedBytes: storageInfo.totalSize,
        mediaBytes: mediaStats.totalSize,
        cleanableBytes: mediaStats.cleanableSize,
        cacheBytes: storageInfo.cacheSize,
        level: level,
        deviceFreeBytes: deviceFree,
      );

      _statusController.add(status);
      return status;
    } catch (e) {
      debugLog('StorageMonitorService: Failed to check status: $e');
      return const StorageStatus();
    }
  }

  /// 获取存储配置
  Future<StorageConfig> getStorageConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return StorageConfig(
        warningThresholdMB: prefs.getInt('storage_warning_mb') ??
            StorageConstants.defaultWarningThresholdMB,
        criticalThresholdMB: prefs.getInt('storage_critical_mb') ??
            StorageConstants.defaultCriticalThresholdMB,
        autoCleanupDays: prefs.getInt('storage_cleanup_days') ??
            StorageConstants.defaultCleanupDays,
        autoCleanupEnabled:
            prefs.getBool('storage_auto_cleanup') ?? false,
        preserveThumbnails:
            prefs.getBool('storage_preserve_thumbs') ?? true,
      );
    } catch (e) {
      debugLog('StorageMonitorService: Failed to get config: $e');
      return const StorageConfig();
    }
  }

  /// 保存存储配置
  Future<void> saveStorageConfig(StorageConfig config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('storage_warning_mb', config.warningThresholdMB);
      await prefs.setInt(
          'storage_critical_mb', config.criticalThresholdMB);
      await prefs.setInt('storage_cleanup_days', config.autoCleanupDays);
      await prefs.setBool(
          'storage_auto_cleanup', config.autoCleanupEnabled);
      await prefs.setBool(
          'storage_preserve_thumbs', config.preserveThumbnails);
    } catch (e) {
      debugLog('StorageMonitorService: Failed to save config: $e');
    }
  }

  /// 是否需要显示预警
  Future<bool> shouldShowWarning() async {
    final status = await checkStorageStatus();
    return status.level != StorageLevel.normal;
  }

  /// 监听存储状态变化
  Stream<StorageStatus> watchStorageStatus() => _statusController.stream;

  /// 启动定时监控（每小时检查一次）
  void startMonitoring({Duration interval = const Duration(hours: 1)}) {
    stopMonitoring();
    _monitorTimer = Timer.periodic(interval, (_) => checkStorageStatus());
  }

  /// 停止定时监控
  void stopMonitoring() {
    _monitorTimer?.cancel();
    _monitorTimer = null;
  }

  /// 释放资源
  void dispose() {
    stopMonitoring();
    _statusController.close();
  }

  /// 获取设备剩余空间（字节）
  ///
  /// 通过查询应用文档目录所在卷的可用空间实现。
  /// iOS/macOS/Android 均使用 `df` 命令解析可用空间。
  Future<int?> _getDeviceFreeSpace() async {
    try {
      if (!Platform.isIOS && !Platform.isMacOS && !Platform.isAndroid) {
        return null;
      }

      final appDir = await getApplicationDocumentsDirectory();
      final args = Platform.isIOS || Platform.isMacOS
          ? ['-k', appDir.path]
          : [appDir.path];
      final result = await Process.run('df', args);
      if (result.exitCode != 0) return null;

      final lines = (result.stdout as String).trim().split('\n');
      if (lines.length < 2) return null;

      final parts = lines[1].split(RegExp(r'\s+'));
      if (parts.length < 4) return null;

      final availableKB = int.tryParse(parts[3]);
      return availableKB != null ? availableKB * 1024 : null;
    } catch (e) {
      debugLog('StorageMonitorService: Failed to get device free space: $e');
    }
    return null;
  }
}
