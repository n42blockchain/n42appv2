import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../data/datasources/local/preferences_datasource.dart';
import '../../../domain/entities/chat_folder_entity.dart';
import 'chat_folder_event.dart';
import 'chat_folder_state.dart';
import '../../../core/utils/debug_log.dart';

/// 聊天文件夹 BLoC
class ChatFolderBloc extends Bloc<ChatFolderEvent, ChatFolderState> {
  final PreferencesDataSource _storage;
  final Uuid _uuid = const Uuid();

  /// 默认系统文件夹列表
  static final List<ChatFolderEntity> _systemFolders = [
    ChatFolderEntity.all,
    ChatFolderEntity.unread,
    ChatFolderEntity.personal,
    ChatFolderEntity.groups,
    ChatFolderEntity.channels,
    ChatFolderEntity.muted,
  ];

  ChatFolderBloc({
    required PreferencesDataSource storage,
  })  : _storage = storage,
        super(ChatFolderState.initial()) {
    on<LoadChatFolders>(_onLoad);
    on<SelectChatFolder>(_onSelect);
    on<CreateChatFolder>(_onCreate);
    on<UpdateChatFolder>(_onUpdate);
    on<DeleteChatFolder>(_onDelete);
    on<ReorderChatFolders>(_onReorder);
  }

  Future<void> _onLoad(
    LoadChatFolders event,
    Emitter<ChatFolderState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      // 加载自定义文件夹
      final savedFolders = await _storage.getChatFolders();
      final customFolders = savedFolders
          .map((json) => ChatFolderEntity.fromJson(json))
          .toList();

      // 合并系统文件夹和自定义文件夹
      final allFolders = [..._systemFolders, ...customFolders];
      allFolders.sort((a, b) => a.order.compareTo(b.order));

      emit(state.copyWith(
        folders: allFolders,
        isLoading: false,
      ));
    } catch (e) {
      debugLog('ChatFolderBloc: Load failed: $e');
      emit(state.copyWith(
        folders: _systemFolders,
        isLoading: false,
        error: 'Failed to load folders',
      ));
    }
  }

  void _onSelect(
    SelectChatFolder event,
    Emitter<ChatFolderState> emit,
  ) {
    emit(state.copyWith(selectedFolderId: event.folderId));
  }

  Future<void> _onCreate(
    CreateChatFolder event,
    Emitter<ChatFolderState> emit,
  ) async {
    try {
      final maxOrder = state.customFolders.isEmpty
          ? 0
          : state.customFolders
              .map((f) => f.order)
              .reduce((a, b) => a > b ? a : b);

      final newFolder = ChatFolderEntity(
        id: _uuid.v4(),
        name: event.name,
        icon: event.icon,
        order: maxOrder + 1,
        filter: event.filter,
        includedRoomIds: event.includedRoomIds,
      );

      final updatedFolders = [...state.folders, newFolder];
      emit(state.copyWith(folders: updatedFolders));

      // 持久化
      await _saveFolders(updatedFolders);
    } catch (e) {
      debugLog('ChatFolderBloc: Create failed: $e');
      emit(state.copyWith(error: 'Failed to create folder'));
    }
  }

  Future<void> _onUpdate(
    UpdateChatFolder event,
    Emitter<ChatFolderState> emit,
  ) async {
    if (event.folder.isSystem) return;

    try {
      final updatedFolders = state.folders.map((f) {
        return f.id == event.folder.id ? event.folder : f;
      }).toList();

      emit(state.copyWith(folders: updatedFolders));
      await _saveFolders(updatedFolders);
    } catch (e) {
      debugLog('ChatFolderBloc: Update failed: $e');
      emit(state.copyWith(error: 'Failed to update folder'));
    }
  }

  Future<void> _onDelete(
    DeleteChatFolder event,
    Emitter<ChatFolderState> emit,
  ) async {
    final folder = state.folders.firstWhere(
      (f) => f.id == event.folderId,
      orElse: () => ChatFolderEntity.all,
    );
    if (folder.isSystem) return;

    try {
      final updatedFolders = state.folders
          .where((f) => f.id != event.folderId)
          .toList();

      // 如果删除的是当前选中的文件夹，切换到"全部"
      final selectedId = state.selectedFolderId == event.folderId
          ? 'all'
          : state.selectedFolderId;

      emit(state.copyWith(
        folders: updatedFolders,
        selectedFolderId: selectedId,
      ));
      await _saveFolders(updatedFolders);
    } catch (e) {
      debugLog('ChatFolderBloc: Delete failed: $e');
      emit(state.copyWith(error: 'Failed to delete folder'));
    }
  }

  Future<void> _onReorder(
    ReorderChatFolders event,
    Emitter<ChatFolderState> emit,
  ) async {
    emit(state.copyWith(folders: event.folders));
    await _saveFolders(event.folders);
  }

  /// 持久化自定义文件夹
  Future<void> _saveFolders(List<ChatFolderEntity> folders) async {
    try {
      final customFolders = folders
          .where((f) => !f.isSystem)
          .map((f) => f.toJson())
          .toList();
      await _storage.saveChatFolders(customFolders);
    } catch (e) {
      debugLog('ChatFolderBloc: Save failed: $e');
    }
  }
}
