import 'package:equatable/equatable.dart';

/// 备份事件
abstract class BackupEvent extends Equatable {
  const BackupEvent();

  @override
  List<Object?> get props => [];
}

/// 加载备份列表
class LoadBackupList extends BackupEvent {
  const LoadBackupList();
}

/// 创建备份
class CreateBackup extends BackupEvent {
  final List<String>? roomIds;
  final bool includeMedia;
  final bool includeKeys;
  final String? password;

  const CreateBackup({
    this.roomIds,
    this.includeMedia = false,
    this.includeKeys = false,
    this.password,
  });

  @override
  List<Object?> get props => [roomIds, includeMedia, includeKeys, password];
}

/// 删除备份
class DeleteBackup extends BackupEvent {
  final String backupId;

  const DeleteBackup(this.backupId);

  @override
  List<Object?> get props => [backupId];
}

/// 预览备份
class PreviewBackup extends BackupEvent {
  final String filePath;
  final String? password;

  const PreviewBackup({required this.filePath, this.password});

  @override
  List<Object?> get props => [filePath, password];
}

/// 从备份恢复
class RestoreFromBackup extends BackupEvent {
  final String backupFilePath;
  final String? password;
  final List<String>? roomIds;
  final bool restoreSettings;
  final bool restoreKeys;

  const RestoreFromBackup({
    required this.backupFilePath,
    this.password,
    this.roomIds,
    this.restoreSettings = true,
    this.restoreKeys = false,
  });

  @override
  List<Object?> get props =>
      [backupFilePath, password, roomIds, restoreSettings, restoreKeys];
}

/// 估算备份大小
class EstimateBackupSize extends BackupEvent {
  final List<String>? roomIds;
  final bool includeMedia;

  const EstimateBackupSize({this.roomIds, this.includeMedia = false});

  @override
  List<Object?> get props => [roomIds, includeMedia];
}
