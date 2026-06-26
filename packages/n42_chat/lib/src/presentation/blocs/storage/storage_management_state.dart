import 'package:equatable/equatable.dart';

import '../../../core/services/media_lifecycle_service.dart';
import '../../../core/services/storage_cleanup_service.dart';
import '../../../core/services/storage_manager_service.dart';
import '../../../core/services/storage_monitor_service.dart';
import '../../../data/datasources/local/media_metadata_database.dart';

/// 存储管理状态
class StorageManagementState extends Equatable {
  /// 存储使用信息
  final StorageInfo? storageInfo;

  /// 存储状态（级别 + 详情）
  final StorageStatus? storageStatus;

  /// 房间存储排行
  final List<RoomStorageRankItem> roomStorageList;

  /// 清理建议
  final List<CleanupRecommendation> recommendations;

  /// 存储配置
  final StorageConfig? storageConfig;

  /// 房间媒体文件列表
  final List<MediaFile> roomMediaFiles;

  /// 当前查看的房间媒体统计
  final RoomMediaStatsResult? roomMediaStats;

  /// 是否正在加载
  final bool isLoading;

  /// 是否正在清理
  final bool isCleaning;

  /// 错误信息
  final String? error;

  /// 最近清理结果
  final CleanupResult? lastCleanupResult;

  const StorageManagementState({
    this.storageInfo,
    this.storageStatus,
    this.roomStorageList = const [],
    this.recommendations = const [],
    this.storageConfig,
    this.roomMediaFiles = const [],
    this.roomMediaStats,
    this.isLoading = false,
    this.isCleaning = false,
    this.error,
    this.lastCleanupResult,
  });

  factory StorageManagementState.initial() {
    return const StorageManagementState(isLoading: true);
  }

  StorageManagementState copyWith({
    StorageInfo? storageInfo,
    StorageStatus? storageStatus,
    List<RoomStorageRankItem>? roomStorageList,
    List<CleanupRecommendation>? recommendations,
    StorageConfig? storageConfig,
    List<MediaFile>? roomMediaFiles,
    RoomMediaStatsResult? roomMediaStats,
    bool? isLoading,
    bool? isCleaning,
    String? error,
    CleanupResult? lastCleanupResult,
    bool clearError = false,
    bool clearCleanupResult = false,
  }) {
    return StorageManagementState(
      storageInfo: storageInfo ?? this.storageInfo,
      storageStatus: storageStatus ?? this.storageStatus,
      roomStorageList: roomStorageList ?? this.roomStorageList,
      recommendations: recommendations ?? this.recommendations,
      storageConfig: storageConfig ?? this.storageConfig,
      roomMediaFiles: roomMediaFiles ?? this.roomMediaFiles,
      roomMediaStats: roomMediaStats ?? this.roomMediaStats,
      isLoading: isLoading ?? this.isLoading,
      isCleaning: isCleaning ?? this.isCleaning,
      error: clearError ? null : (error ?? this.error),
      lastCleanupResult: clearCleanupResult
          ? null
          : (lastCleanupResult ?? this.lastCleanupResult),
    );
  }

  @override
  List<Object?> get props => [
        storageInfo,
        storageStatus,
        roomStorageList,
        recommendations,
        storageConfig,
        roomMediaFiles,
        roomMediaStats,
        isLoading,
        isCleaning,
        error,
        lastCleanupResult,
      ];
}

/// 房间存储排行项
class RoomStorageRankItem {
  final String roomId;
  final String roomName;
  final int totalSize;
  final int mediaCount;
  final int imageSize;
  final int videoSize;
  final int audioSize;
  final int documentSize;

  const RoomStorageRankItem({
    required this.roomId,
    required this.roomName,
    this.totalSize = 0,
    this.mediaCount = 0,
    this.imageSize = 0,
    this.videoSize = 0,
    this.audioSize = 0,
    this.documentSize = 0,
  });

  String get formattedSize => StorageInfo.formatSize(totalSize);
}
