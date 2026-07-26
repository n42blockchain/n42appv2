import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/services/chat_backup_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/backup/backup_bloc.dart';
import '../../blocs/backup/backup_event.dart';
import '../../blocs/backup/backup_state.dart';
import '../../widgets/common/common_widgets.dart';

/// 备份与恢复页面
class BackupRestorePage extends StatelessWidget {
  const BackupRestorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BackupBloc(
        backupService: GetIt.instance<ChatBackupService>(),
      )..add(const LoadBackupList()),
      child: const _BackupRestoreView(),
    );
  }
}

class _BackupRestoreView extends StatelessWidget {
  const _BackupRestoreView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: N42AppBar(
        title: 'Backup & Restore',
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: BlocConsumer<BackupBloc, BackupState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: AppColors.success,
              ),
            );
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return ListView(
            children: [
              _BackupSection(state: state),
              const SizedBox(height: 16),
              _BackupHistorySection(state: state),
              const SizedBox(height: 16),
              _RestoreSection(state: state),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}

/// 创建备份区域
class _BackupSection extends StatefulWidget {
  final BackupState state;

  const _BackupSection({required this.state});

  @override
  State<_BackupSection> createState() => _BackupSectionState();
}

class _BackupSectionState extends State<_BackupSection> {
  bool _usePassword = false;
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = context.surfaceColor;
    final textColor = context.textPrimary;
    final secondaryColor = context.textSecondary;

    return Container(
      color: cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.backup, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Create Backup',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Backup your local chat settings. '
              'Messages will be restored from server after re-login.',
              style: TextStyle(fontSize: 13, height: 1.4, color: secondaryColor),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.key_outlined, color: AppColors.warning),
            title: Text(
              'Encryption keys are managed separately',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 15, height: 1.3, color: textColor),
            ),
            subtitle: Text(
              'Use Security > Recovery Key to back up encrypted message access.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, height: 1.4, color: secondaryColor),
            ),
          ),
          CheckboxListTile(
            title: Text(
              'Password protect',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 15, height: 1.3, color: textColor),
            ),
            value: _usePassword,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _usePassword = v ?? false),
          ),
          if (_usePassword)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Enter backup password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.state.isCreating
                    ? null
                    : () {
                        context.read<BackupBloc>().add(CreateBackup(
                              password: _usePassword
                                  ? _passwordController.text
                                  : null,
                            ));
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: widget.state.isCreating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Create Backup'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 历史备份列表
class _BackupHistorySection extends StatelessWidget {
  final BackupState state;

  const _BackupHistorySection({required this.state});

  @override
  Widget build(BuildContext context) {
    final cardColor = context.surfaceColor;
    final textColor = context.textPrimary;
    final secondaryColor = context.textSecondary;

    return Container(
      color: cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Backup History',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                height: 1.3,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          if (state.backups.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No backups yet',
                style: TextStyle(fontSize: 14, height: 1.3, color: secondaryColor),
              ),
            )
          else
            ...state.backups.map((backup) => ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.archive,
                        color: AppColors.info, size: 22),
                  ),
                  title: Text(
                    backup.formattedDate,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 15, height: 1.3, color: textColor),
                  ),
                  subtitle: Text(
                    '${backup.roomCount} rooms  ${backup.formattedSize}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, height: 1.3, color: secondaryColor),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (action) {
                      if (action == 'delete') {
                        _confirmDelete(context, backup);
                      } else if (action == 'restore') {
                        context.read<BackupBloc>().add(
                              RestoreFromBackup(
                                  backupFilePath: backup.filePath),
                            );
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'restore',
                        child: Row(
                          children: [
                            Icon(Icons.restore, size: 18),
                            SizedBox(width: 8),
                            Text('Restore'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Delete',
                                style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, BackupInfo backup) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Backup'),
        content: const Text(
          'Are you sure you want to delete this backup? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context
                  .read<BackupBloc>()
                  .add(DeleteBackup(backup.backupId));
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// 恢复区域
class _RestoreSection extends StatelessWidget {
  final BackupState state;

  const _RestoreSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final cardColor = context.surfaceColor;
    final textColor = context.textPrimary;
    final secondaryColor = context.textSecondary;

    return Container(
      color: cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.restore, color: AppColors.warning, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Restore from File',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Import a .n42backup file from another device or previous backup. '
              'Encryption keys are restored separately with your Recovery Key.',
              style: TextStyle(fontSize: 13, height: 1.4, color: secondaryColor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: state.isRestoring
                    ? null
                    : () => _pickAndRestore(context),
                icon: state.isRestoring
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.file_open),
                label: Text(
                    state.isRestoring ? 'Restoring...' : 'Choose Backup File'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndRestore(BuildContext context) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final filePath = result.files.first.path;
        if (filePath != null && context.mounted) {
          context.read<BackupBloc>().add(
                RestoreFromBackup(backupFilePath: filePath),
              );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick file: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
