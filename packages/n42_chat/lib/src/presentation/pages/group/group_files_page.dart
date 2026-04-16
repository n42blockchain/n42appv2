import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/services/download_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/matrix_utils.dart' as mx_utils;
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../../domain/entities/group_file_entity.dart';
import '../../../domain/repositories/message_repository.dart';
import '../../widgets/common/common_widgets.dart';

/// 群文件页面
class GroupFilesPage extends StatefulWidget {
  final String roomId;
  final String groupName;

  /// 嵌入模式：为 true 时不显示 Scaffold+AppBar，仅返回内容部分
  final bool embedded;

  const GroupFilesPage({
    super.key,
    required this.roomId,
    required this.groupName,
    this.embedded = false,
  });

  @override
  State<GroupFilesPage> createState() => _GroupFilesPageState();
}

class _GroupFilesPageState extends State<GroupFilesPage>
    with SingleTickerProviderStateMixin {
  final IMessageRepository _messageRepository =
      GetIt.instance<IMessageRepository>();
  final DownloadService _downloadService = GetIt.instance<DownloadService>();

  late TabController _tabController;
  List<GroupFileEntity> _files = [];
  bool _isLoading = true;
  String? _error;
  GroupFileType? _currentFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadFiles();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _currentFilter = null;
          case 1:
            _currentFilter = GroupFileType.document;
          case 2:
            _currentFilter = GroupFileType.image;
          case 3:
            _currentFilter = GroupFileType.video;
        }
      });
    }
  }

  Future<void> _loadFiles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final files = await _messageRepository.getRoomFiles(
        widget.roomId,
        type: _currentFilter,
      );
      if (mounted) {
        setState(() {
          _files = files;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<GroupFileEntity> get _filteredFiles {
    if (_currentFilter == null) return _files;
    return _files.where((f) => f.fileType == _currentFilter).toList();
  }

  Map<String, String> _buildAuthHeaders(String? url) {
    return mx_utils.MatrixUtils.buildAuthenticatedMediaHeaders(
      url,
      client: MatrixClientManager.instance.client,
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final isDark = context.isDarkMode;
    return TabBar(
      controller: _tabController,
      labelColor: AppColors.primary,
      unselectedLabelColor: isDark
          ? AppColors.textSecondaryDark
          : AppColors.textSecondary,
      indicatorColor: AppColors.primary,
      tabs: [
        Tab(text: S.of(context)?.commonAll ?? 'All'),
        Tab(text: S.of(context)?.groupDocuments ?? 'Docs'),
        Tab(text: S.of(context)?.groupImages ?? 'Images'),
        Tab(text: S.of(context)?.groupVideos ?? 'Videos'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.background;
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;

    // 嵌入模式：不显示 Scaffold+AppBar，仅返回 TabBar + body
    if (widget.embedded) {
      return Column(
        children: [
          Material(color: cardColor, child: _buildTabBar(context)),
          Expanded(child: _buildBody(cardColor, textColor)),
        ],
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        title: Text(
          S.of(context)?.groupFiles ?? 'Group Files',
          style: TextStyle(
            color: textColor,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(46),
          child: _buildTabBar(context),
        ),
      ),
      body: _buildBody(cardColor, textColor),
    );
  }

  Widget _buildBody(Color cardColor, Color textColor) {
    if (_isLoading) {
      return Center(
        child: N42Loading(
          message: S.of(context)?.commonLoading ?? 'Loading...',
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: N42EmptyState.error(
          title: S.of(context)?.commonLoadFailed ?? 'Load failed',
          description: _error,
          buttonText: S.of(context)?.commonRetry ?? 'Retry',
          onButtonPressed: _loadFiles,
        ),
      );
    }

    final files = _filteredFiles;
    if (files.isEmpty) {
      return Center(
        child: N42EmptyState.noData(
          title: S.of(context)?.groupNoFiles ?? 'No files',
          description:
              S.of(context)?.groupNoFilesDescription ??
              'No files in this group yet',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFiles,
      child: ListView.builder(
        itemCount: files.length,
        itemBuilder: (context, index) {
          final file = files[index];
          return _buildFileItem(file, cardColor, textColor);
        },
      ),
    );
  }

  Widget _buildFileItem(
    GroupFileEntity file,
    Color cardColor,
    Color textColor,
  ) {
    final isDark = context.isDarkMode;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

    return Container(
      color: cardColor,
      child: ListTile(
        leading: _buildFileIcon(file),
        title: Text(
          file.name,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Text(
              file.formattedSize,
              style: TextStyle(color: secondaryTextColor, fontSize: 12),
            ),
            const SizedBox(width: 8),
            Text(
              _formatDate(file.sentAt),
              style: TextStyle(color: secondaryTextColor, fontSize: 12),
            ),
            if (file.senderName != null) ...[
              const SizedBox(width: 8),
              Text(
                file.senderName!,
                style: TextStyle(color: secondaryTextColor, fontSize: 12),
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.download, color: AppColors.primary),
          onPressed: () => _downloadFile(file),
        ),
        onTap: () => _openFile(file),
      ),
    );
  }

  Widget _buildFileIcon(GroupFileEntity file) {
    final (IconData icon, Color color) = switch (file.fileType) {
      GroupFileType.image => (Icons.image, Colors.blue),
      GroupFileType.video => (Icons.videocam, Colors.red),
      GroupFileType.audio => (Icons.audiotrack, Colors.purple),
      GroupFileType.document => (Icons.description, Colors.orange),
      GroupFileType.archive => (Icons.folder_zip, Colors.brown),
      GroupFileType.other => (Icons.insert_drive_file, Colors.grey),
    };

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    if (date.year == now.year) {
      return '${date.month}/${date.day}';
    }
    return '${date.year}/${date.month}/${date.day}';
  }

  void _openFile(GroupFileEntity file) {
    if (file.httpUrl != null) {
      // 对于图片和视频，可以使用媒体预览
      if (file.isImage || file.isVideo) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => Scaffold(
              appBar: AppBar(title: Text(file.name)),
              body: Center(
                child: file.isImage
                    ? InteractiveViewer(child: Image.network(file.httpUrl!))
                    : const Icon(Icons.videocam, size: 64),
              ),
            ),
          ),
        );
      }
    }
  }

  void _downloadFile(GroupFileEntity file) async {
    if (file.httpUrl == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          S.of(context)?.groupDownloadStarted(file.name) ??
              'Downloading ${file.name}...',
        ),
      ),
    );

    try {
      final downloadDir = await DownloadService.getDownloadDirectory();
      final savePath = '$downloadDir/${file.name}';
      final taskId = await _downloadService.download(
        url: file.httpUrl!,
        savePath: savePath,
        fileName: file.name,
        headers: _buildAuthHeaders(file.httpUrl),
      );
      final task = await _downloadService.waitForTaskCompletion(taskId);
      if (task.status != DownloadStatus.completed) {
        throw Exception(task.error ?? 'Download failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${S.of(context)?.downloadFailed ?? 'Download failed'}: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
