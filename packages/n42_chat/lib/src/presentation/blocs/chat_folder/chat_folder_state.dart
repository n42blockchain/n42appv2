import 'package:equatable/equatable.dart';

import '../../../domain/entities/chat_folder_entity.dart';

/// 聊天文件夹状态
class ChatFolderState extends Equatable {
  /// 所有文件夹
  final List<ChatFolderEntity> folders;

  /// 当前选中的文件夹 ID
  final String selectedFolderId;

  /// 是否正在加载
  final bool isLoading;

  /// 错误信息
  final String? error;

  const ChatFolderState({
    this.folders = const [],
    this.selectedFolderId = 'all',
    this.isLoading = false,
    this.error,
  });

  factory ChatFolderState.initial() => const ChatFolderState(isLoading: true);

  /// 当前选中的文件夹
  ChatFolderEntity? get selectedFolder {
    final index = folders.indexWhere((f) => f.id == selectedFolderId);
    return index >= 0 ? folders[index] : null;
  }

  /// 系统文件夹列表
  List<ChatFolderEntity> get systemFolders =>
      folders.where((f) => f.isSystem).toList();

  /// 自定义文件夹列表
  List<ChatFolderEntity> get customFolders =>
      folders.where((f) => !f.isSystem).toList();

  ChatFolderState copyWith({
    List<ChatFolderEntity>? folders,
    String? selectedFolderId,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ChatFolderState(
      folders: folders ?? this.folders,
      selectedFolderId: selectedFolderId ?? this.selectedFolderId,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [folders, selectedFolderId, isLoading, error];
}
