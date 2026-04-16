import 'package:equatable/equatable.dart';

import '../../../domain/entities/chat_folder_entity.dart';

/// 聊天文件夹事件
abstract class ChatFolderEvent extends Equatable {
  const ChatFolderEvent();

  @override
  List<Object?> get props => [];
}

/// 加载文件夹列表
class LoadChatFolders extends ChatFolderEvent {
  const LoadChatFolders();
}

/// 切换当前文件夹
class SelectChatFolder extends ChatFolderEvent {
  final String folderId;

  const SelectChatFolder(this.folderId);

  @override
  List<Object?> get props => [folderId];
}

/// 创建自定义文件夹
class CreateChatFolder extends ChatFolderEvent {
  final String name;
  final String? icon;
  final ChatFolderFilter filter;
  final List<String> includedRoomIds;

  const CreateChatFolder({
    required this.name,
    this.icon,
    this.filter = const ChatFolderFilter(),
    this.includedRoomIds = const [],
  });

  @override
  List<Object?> get props => [name, icon, filter, includedRoomIds];
}

/// 更新文件夹
class UpdateChatFolder extends ChatFolderEvent {
  final ChatFolderEntity folder;

  const UpdateChatFolder(this.folder);

  @override
  List<Object?> get props => [folder];
}

/// 删除文件夹
class DeleteChatFolder extends ChatFolderEvent {
  final String folderId;

  const DeleteChatFolder(this.folderId);

  @override
  List<Object?> get props => [folderId];
}

/// 重排序文件夹
class ReorderChatFolders extends ChatFolderEvent {
  final List<ChatFolderEntity> folders;

  const ReorderChatFolders(this.folders);

  @override
  List<Object?> get props => [folders];
}
