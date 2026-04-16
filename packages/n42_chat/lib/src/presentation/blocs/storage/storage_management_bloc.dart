import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/media_lifecycle_service.dart';
import '../../../core/services/storage_cleanup_service.dart';
import '../../../core/services/storage_manager_service.dart';
import '../../../core/services/storage_monitor_service.dart';
import 'storage_management_event.dart';
import 'storage_management_state.dart';

/// 存储管理 BLoC
class StorageManagementBloc
    extends Bloc<StorageManagementEvent, StorageManagementState> {
  final StorageManagerService _storageManager;
  final MediaLifecycleService _lifecycleService;
  final StorageCleanupService _cleanupService;
  final StorageMonitorService _monitorService;

  StorageManagementBloc({
    required StorageManagerService storageManager,
    required MediaLifecycleService lifecycleService,
    required StorageCleanupService cleanupService,
    required StorageMonitorService monitorService,
  })  : _storageManager = storageManager,
        _lifecycleService = lifecycleService,
        _cleanupService = cleanupService,
        _monitorService = monitorService,
        super(StorageManagementState.initial()) {
    on<LoadStorageInfo>(_onLoadStorageInfo);
    on<LoadRoomStorageList>(_onLoadRoomStorageList);
    on<LoadRecommendations>(_onLoadRecommendations);
    on<ExecuteCleanup>(_onExecuteCleanup);
    on<CleanupByRoom>(_onCleanupByRoom);
    on<ClearCache>(_onClearCache);
    on<UpdateStorageConfig>(_onUpdateStorageConfig);
    on<LoadRoomMediaDetail>(_onLoadRoomMediaDetail);
    on<DeleteSelectedFiles>(_onDeleteSelectedFiles);
    on<ToggleFilePinned>(_onToggleFilePinned);
  }

  Future<void> _onLoadStorageInfo(
    LoadStorageInfo event,
    Emitter<StorageManagementState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final storageInfo = await _storageManager.getStorageUsage();
      final status = await _monitorService.checkStorageStatus();
      final config = await _monitorService.getStorageConfig();
      final recommendations = await _cleanupService.getRecommendations(
        preserveThumbnails: config.preserveThumbnails,
      );

      // 加载房间排行
      final roomRanking = await _storageManager.getRoomStorageRanking();
      final roomStats = await _lifecycleService.getAllRoomStats();

      final roomItems = roomRanking.map((r) {
        final stats = roomStats
            .where((s) => s.roomId == r.roomId)
            .firstOrNull;
        return RoomStorageRankItem(
          roomId: r.roomId,
          roomName: r.roomName,
          totalSize: r.totalSize,
          mediaCount: r.mediaCount,
          imageSize: stats?.imageSize ?? 0,
          videoSize: stats?.videoSize ?? 0,
          audioSize: stats?.audioSize ?? 0,
          documentSize: stats?.documentSize ?? 0,
        );
      }).toList();

      emit(state.copyWith(
        storageInfo: storageInfo,
        storageStatus: status,
        storageConfig: config,
        recommendations: recommendations,
        roomStorageList: roomItems,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onLoadRoomStorageList(
    LoadRoomStorageList event,
    Emitter<StorageManagementState> emit,
  ) async {
    try {
      final roomRanking = await _storageManager.getRoomStorageRanking();
      final roomItems = roomRanking
          .map((r) => RoomStorageRankItem(
                roomId: r.roomId,
                roomName: r.roomName,
                totalSize: r.totalSize,
                mediaCount: r.mediaCount,
              ))
          .toList();
      emit(state.copyWith(roomStorageList: roomItems));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to load room storage list: $e'));
    }
  }

  Future<void> _onLoadRecommendations(
    LoadRecommendations event,
    Emitter<StorageManagementState> emit,
  ) async {
    try {
      final recommendations = await _cleanupService.getRecommendations(
        preserveThumbnails: state.storageConfig?.preserveThumbnails ?? true,
      );
      emit(state.copyWith(recommendations: recommendations));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to load recommendations: $e'));
    }
  }

  Future<void> _onExecuteCleanup(
    ExecuteCleanup event,
    Emitter<StorageManagementState> emit,
  ) async {
    emit(state.copyWith(isCleaning: true));
    try {
      final result = await _cleanupService.executeRecommendation(
        event.recommendation,
        preserveThumbnails: state.storageConfig?.preserveThumbnails ?? true,
      );
      emit(state.copyWith(
        isCleaning: false,
        lastCleanupResult: result,
      ));
      // 清理后刷新数据
      add(const LoadStorageInfo());
    } catch (e) {
      emit(state.copyWith(
        isCleaning: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onCleanupByRoom(
    CleanupByRoom event,
    Emitter<StorageManagementState> emit,
  ) async {
    emit(state.copyWith(isCleaning: true));
    try {
      final result = await _cleanupService.cleanupByRoom(
        roomId: event.roomId,
        fileCategories: event.fileCategories,
        preserveThumbnails: state.storageConfig?.preserveThumbnails ?? true,
      );
      emit(state.copyWith(
        isCleaning: false,
        lastCleanupResult: result,
      ));
      add(const LoadStorageInfo());
    } catch (e) {
      emit(state.copyWith(
        isCleaning: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onClearCache(
    ClearCache event,
    Emitter<StorageManagementState> emit,
  ) async {
    emit(state.copyWith(isCleaning: true));
    try {
      await _storageManager.clearCache();
      emit(state.copyWith(isCleaning: false));
      add(const LoadStorageInfo());
    } catch (e) {
      emit(state.copyWith(
        isCleaning: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateStorageConfig(
    UpdateStorageConfig event,
    Emitter<StorageManagementState> emit,
  ) async {
    try {
      final current =
          state.storageConfig ?? const StorageConfig();
      final updated = current.copyWith(
        autoCleanupDays: event.autoCleanupDays,
        autoCleanupEnabled: event.autoCleanupEnabled,
        warningThresholdMB: event.warningThresholdMB,
        criticalThresholdMB: event.criticalThresholdMB,
        preserveThumbnails: event.preserveThumbnails,
      );
      await _monitorService.saveStorageConfig(updated);
      emit(state.copyWith(storageConfig: updated));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to update storage config: $e'));
    }
  }

  Future<void> _onLoadRoomMediaDetail(
    LoadRoomMediaDetail event,
    Emitter<StorageManagementState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final stats =
          await _lifecycleService.getRoomMediaStats(event.roomId);
      final files = await _lifecycleService.getRoomMediaFiles(
        roomId: event.roomId,
        fileCategory: event.filterCategory,
      );
      emit(state.copyWith(
        roomMediaStats: stats,
        roomMediaFiles: files,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteSelectedFiles(
    DeleteSelectedFiles event,
    Emitter<StorageManagementState> emit,
  ) async {
    emit(state.copyWith(isCleaning: true));
    try {
      final result = await _lifecycleService.cleanupFiles(event.filePaths);
      if (result.filesDeleted > 0 || result.bytesFreed > 0) {
        _storageManager.invalidateCache();
      }
      emit(state.copyWith(
        isCleaning: false,
        lastCleanupResult: result,
      ));
      if (event.roomId != null) {
        add(
          LoadRoomMediaDetail(
            roomId: event.roomId!,
            filterCategory: event.filterCategory,
          ),
        );
      }
      // 删除后刷新存储信息，与 _onCleanupByRoom / _onClearCache 保持一致
      add(const LoadStorageInfo());
    } catch (e) {
      emit(state.copyWith(
        isCleaning: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onToggleFilePinned(
    ToggleFilePinned event,
    Emitter<StorageManagementState> emit,
  ) async {
    try {
      await _lifecycleService.togglePinned(event.filePath, event.pinned);
    } catch (e) {
      emit(state.copyWith(error: 'Failed to toggle pinned: $e'));
    }
  }
}
