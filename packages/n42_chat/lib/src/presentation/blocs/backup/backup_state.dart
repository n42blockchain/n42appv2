import 'package:equatable/equatable.dart';

import '../../../core/services/chat_backup_service.dart';

/// 备份状态
class BackupState extends Equatable {
  final List<BackupInfo> backups;
  final BackupPreview? preview;
  final BackupSizeEstimate? sizeEstimate;
  final bool isLoading;
  final bool isCreating;
  final bool isRestoring;
  final double progress;
  final String? error;
  final String? successMessage;

  const BackupState({
    this.backups = const [],
    this.preview,
    this.sizeEstimate,
    this.isLoading = false,
    this.isCreating = false,
    this.isRestoring = false,
    this.progress = 0,
    this.error,
    this.successMessage,
  });

  factory BackupState.initial() {
    return const BackupState(isLoading: true);
  }

  BackupState copyWith({
    List<BackupInfo>? backups,
    BackupPreview? preview,
    BackupSizeEstimate? sizeEstimate,
    bool? isLoading,
    bool? isCreating,
    bool? isRestoring,
    double? progress,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearPreview = false,
  }) {
    return BackupState(
      backups: backups ?? this.backups,
      preview: clearPreview ? null : (preview ?? this.preview),
      sizeEstimate: sizeEstimate ?? this.sizeEstimate,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isRestoring: isRestoring ?? this.isRestoring,
      progress: progress ?? this.progress,
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        backups,
        preview,
        sizeEstimate,
        isLoading,
        isCreating,
        isRestoring,
        progress,
        error,
        successMessage,
      ];
}
