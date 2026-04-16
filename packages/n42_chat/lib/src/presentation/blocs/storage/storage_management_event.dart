import 'package:equatable/equatable.dart';

import '../../../core/services/storage_cleanup_service.dart';

/// 存储管理事件
abstract class StorageManagementEvent extends Equatable {
  const StorageManagementEvent();

  @override
  List<Object?> get props => [];
}

/// 加载存储信息
class LoadStorageInfo extends StorageManagementEvent {
  const LoadStorageInfo();
}

/// 加载房间存储排行
class LoadRoomStorageList extends StorageManagementEvent {
  const LoadRoomStorageList();
}

/// 加载清理建议
class LoadRecommendations extends StorageManagementEvent {
  const LoadRecommendations();
}

/// 执行清理建议
class ExecuteCleanup extends StorageManagementEvent {
  final CleanupRecommendation recommendation;

  const ExecuteCleanup(this.recommendation);

  @override
  List<Object?> get props => [recommendation];
}

/// 按房间清理
class CleanupByRoom extends StorageManagementEvent {
  final String roomId;
  final List<String>? fileCategories;

  const CleanupByRoom({
    required this.roomId,
    this.fileCategories,
  });

  @override
  List<Object?> get props => [roomId, fileCategories];
}

/// 清除缓存
class ClearCache extends StorageManagementEvent {
  const ClearCache();
}

/// 更新存储配置
class UpdateStorageConfig extends StorageManagementEvent {
  final int? autoCleanupDays;
  final bool? autoCleanupEnabled;
  final int? warningThresholdMB;
  final int? criticalThresholdMB;
  final bool? preserveThumbnails;

  const UpdateStorageConfig({
    this.autoCleanupDays,
    this.autoCleanupEnabled,
    this.warningThresholdMB,
    this.criticalThresholdMB,
    this.preserveThumbnails,
  });

  @override
  List<Object?> get props => [
        autoCleanupDays,
        autoCleanupEnabled,
        warningThresholdMB,
        criticalThresholdMB,
        preserveThumbnails,
      ];
}

/// 加载房间媒体详情
class LoadRoomMediaDetail extends StorageManagementEvent {
  final String roomId;
  final String? filterCategory;

  const LoadRoomMediaDetail({
    required this.roomId,
    this.filterCategory,
  });

  @override
  List<Object?> get props => [roomId, filterCategory];
}

/// 删除选中的文件
class DeleteSelectedFiles extends StorageManagementEvent {
  final List<String> filePaths;
  final String? roomId;
  final String? filterCategory;

  const DeleteSelectedFiles(
    this.filePaths, {
    this.roomId,
    this.filterCategory,
  });

  @override
  List<Object?> get props => [filePaths, roomId, filterCategory];
}

/// 切换文件保留状态
class ToggleFilePinned extends StorageManagementEvent {
  final String filePath;
  final bool pinned;

  const ToggleFilePinned({required this.filePath, required this.pinned});

  @override
  List<Object?> get props => [filePath, pinned];
}
