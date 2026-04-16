import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/services/storage_manager_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/local/media_metadata_database.dart';
import '../../blocs/storage/storage_management_bloc.dart';
import '../../blocs/storage/storage_management_event.dart';
import '../../blocs/storage/storage_management_state.dart';

/// 房间存储详情页
class RoomStorageDetailPage extends StatefulWidget {
  final String roomId;
  final String roomName;

  const RoomStorageDetailPage({
    super.key,
    required this.roomId,
    required this.roomName,
  });

  @override
  State<RoomStorageDetailPage> createState() => _RoomStorageDetailPageState();
}

class _RoomStorageDetailPageState extends State<RoomStorageDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final Set<String> _selectedFiles = {};
  String? _currentCategory;
  bool _deleteRequested = false;

  static const _tabs = ['All', 'Images', 'Videos', 'Files'];
  static const _categories = [null, 'image', 'video', 'document'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    context.read<StorageManagementBloc>().add(
          LoadRoomMediaDetail(roomId: widget.roomId),
        );
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      _currentCategory = _categories[_tabController.index];
      _selectedFiles.clear();
    });
    context.read<StorageManagementBloc>().add(
          LoadRoomMediaDetail(
            roomId: widget.roomId,
            filterCategory: _currentCategory,
          ),
        );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        elevation: 0,
        title: Text(
          widget.roomName,
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor:
              isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: BlocConsumer<StorageManagementBloc, StorageManagementState>(
        listenWhen: (previous, current) =>
            _deleteRequested &&
            (previous.isCleaning != current.isCleaning ||
                previous.lastCleanupResult != current.lastCleanupResult ||
                previous.error != current.error),
        listener: (context, state) {
          if (!_deleteRequested || state.isCleaning) return;
          setState(() {
            _deleteRequested = false;
            if (state.error == null && state.lastCleanupResult != null) {
              _selectedFiles.clear();
            }
          });
        },
        builder: (context, state) {
          return Column(
            children: [
              // 房间存储头部
              _RoomStorageHeader(state: state),
              // 文件列表
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _MediaFileList(
                        files: state.roomMediaFiles,
                        selectedFiles: _selectedFiles,
                        onSelectionChanged: (paths) {
                          setState(() {
                            _selectedFiles.clear();
                            _selectedFiles.addAll(paths);
                          });
                        },
                      ),
              ),
              // 选择操作栏
              if (_selectedFiles.isNotEmpty)
                _SelectionActionBar(
                  selectedCount: _selectedFiles.length,
                  isCleaning: state.isCleaning,
                  onDelete: () => _deleteSelected(context),
                  onClearSelection: () {
                    setState(() => _selectedFiles.clear());
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  void _deleteSelected(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(context)?.commonDelete ?? 'Delete'),
        content: Text(
          'Delete ${_selectedFiles.length} selected files? '
          'They can be re-downloaded from the server.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              setState(() => _deleteRequested = true);
              context.read<StorageManagementBloc>().add(
                    DeleteSelectedFiles(
                      _selectedFiles.toList(),
                      roomId: widget.roomId,
                      filterCategory: _currentCategory,
                    ),
                  );
            },
            child: Text(
              S.of(context)?.commonDelete ?? 'Delete',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

/// 房间存储头部
class _RoomStorageHeader extends StatelessWidget {
  final StorageManagementState state;

  const _RoomStorageHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final stats = state.roomMediaStats;
    if (stats == null) return const SizedBox.shrink();

    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surface;

    return Container(
      color: cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            label: 'Total',
            value: StorageInfo.formatSize(stats.totalSize),
          ),
          _StatItem(
            label: 'Images',
            value: StorageInfo.formatSize(stats.imageSize),
          ),
          _StatItem(
            label: 'Videos',
            value: StorageInfo.formatSize(stats.videoSize),
          ),
          _StatItem(
            label: 'Files',
            value: StorageInfo.formatSize(stats.documentSize),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// 媒体文件列表
class _MediaFileList extends StatelessWidget {
  final List<MediaFile> files;
  final Set<String> selectedFiles;
  final ValueChanged<Set<String>> onSelectionChanged;

  const _MediaFileList({
    required this.files,
    required this.selectedFiles,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    if (files.isEmpty) {
      return Center(
        child: Text(
          'No files found',
          style: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        final isSelected = selectedFiles.contains(file.filePath);

        return _MediaFileTile(
          file: file,
          isSelected: isSelected,
          onTap: () {
            final updated = Set<String>.from(selectedFiles);
            if (isSelected) {
              updated.remove(file.filePath);
            } else {
              updated.add(file.filePath);
            }
            onSelectionChanged(updated);
          },
        );
      },
    );
  }
}

class _MediaFileTile extends StatelessWidget {
  final MediaFile file;
  final bool isSelected;
  final VoidCallback onTap;

  const _MediaFileTile({
    required this.file,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    IconData icon;
    Color color;
    switch (file.fileCategory) {
      case 'image':
        icon = Icons.image;
        color = Colors.blue;
        break;
      case 'video':
        icon = Icons.videocam;
        color = Colors.purple;
        break;
      case 'audio':
        icon = Icons.audiotrack;
        color = Colors.orange;
        break;
      case 'document':
        icon = Icons.description;
        color = Colors.teal;
        break;
      default:
        icon = Icons.insert_drive_file;
        color = Colors.grey;
    }

    final fileName = file.filePath.split('/').last;
    final fileSize = StorageInfo.formatSize(file.fileSize);

    return ListTile(
      leading: Stack(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          if (isSelected)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 12),
              ),
            ),
        ],
      ),
      title: Text(
        fileName,
        style: TextStyle(fontSize: 14, color: textColor),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '$fileSize  ${_formatDate(file.downloadedAt)}'
        '${file.isPinned ? '  Pinned' : ''}',
        style: TextStyle(fontSize: 12, color: secondaryColor),
      ),
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.black.withValues(alpha: 0.03),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// 选择操作栏
class _SelectionActionBar extends StatelessWidget {
  final int selectedCount;
  final bool isCleaning;
  final VoidCallback onDelete;
  final VoidCallback onClearSelection;

  const _SelectionActionBar({
    required this.selectedCount,
    required this.isCleaning,
    required this.onDelete,
    required this.onClearSelection,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        child: Row(
          children: [
            TextButton(
              onPressed: onClearSelection,
              child: Text('Cancel ($selectedCount)'),
            ),
            const Spacer(),
            if (isCleaning)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              ElevatedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Delete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
