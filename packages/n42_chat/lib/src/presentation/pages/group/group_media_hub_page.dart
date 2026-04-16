import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/services/url_preview_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import 'group_album_page.dart';
import 'group_files_page.dart';
import '../../../core/utils/debug_log.dart';

/// 群媒体中心页面
///
/// 统一入口：相册 | 文件 | 链接
class GroupMediaHubPage extends StatefulWidget {
  final String roomId;
  final String groupName;
  final int initialTab;

  const GroupMediaHubPage({
    super.key,
    required this.roomId,
    required this.groupName,
    this.initialTab = 0,
  });

  @override
  State<GroupMediaHubPage> createState() => _GroupMediaHubPageState();
}

class _GroupMediaHubPageState extends State<GroupMediaHubPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab,
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
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.background;
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        title: Text(
          S.of(context)?.groupChatFiles ?? 'Chat Files',
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor:
              isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: S.of(context)?.groupAlbum ?? 'Album'),
            Tab(text: S.of(context)?.groupFiles ?? 'Files'),
            Tab(text: S.of(context)?.groupLinks ?? 'Links'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 相册 Tab
          GroupAlbumPage(
            roomId: widget.roomId,
            groupName: widget.groupName,
            embedded: true,
          ),
          // 文件 Tab
          GroupFilesPage(
            roomId: widget.roomId,
            groupName: widget.groupName,
            embedded: true,
          ),
          // 链接 Tab
          _LinksTab(roomId: widget.roomId),
        ],
      ),
    );
  }
}

/// 链接 Tab
class _LinksTab extends StatefulWidget {
  final String roomId;

  const _LinksTab({required this.roomId});

  @override
  State<_LinksTab> createState() => _LinksTabState();
}

class _LinksTabState extends State<_LinksTab> {
  List<_LinkItem> _links = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLinks();
  }

  Future<void> _loadLinks() async {
    try {
      final clientManager = GetIt.instance<MatrixClientManager>();
      final client = clientManager.client;
      final room = client?.getRoomById(widget.roomId);
      if (room == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final timeline = await room.getTimeline();
      final links = <_LinkItem>[];
      final seenUrls = <String>{};

      for (final event in timeline.events) {
        if (event.type != matrix.EventTypes.Message) continue;
        final msgType = event.messageType;
        if (msgType != matrix.MessageTypes.Text) continue;

        final body = event.body;
        final url = UrlPreviewService.extractFirstUrl(body);
        if (url != null && seenUrls.add(url)) {
          final sender = event.senderFromMemoryOrFallback;
          links.add(_LinkItem(
            url: url,
            title: null,
            senderName: sender.calcDisplayname(),
            sentAt: event.originServerTs,
          ));
        }

        if (links.length >= 100) break;
      }

      if (mounted) {
        setState(() {
          _links = links;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugLog('LinksTab: Failed to load links: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_links.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.link,
              size: 48,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              S.of(context)?.groupNoLinks ?? 'No links',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _links.length,
      itemBuilder: (context, index) {
        final link = _links[index];
        return _buildLinkItem(context, link, isDark);
      },
    );
  }

  Widget _buildLinkItem(BuildContext context, _LinkItem link, bool isDark) {
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.link, color: AppColors.primary, size: 20),
      ),
      title: Text(
        link.title ?? link.url,
        style: TextStyle(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Uri.tryParse(link.url)?.host ?? link.url,
            style: TextStyle(color: secondaryColor, fontSize: 12),
          ),
          if (link.senderName != null)
            Text(
              '${link.senderName} · ${_formatDate(link.sentAt)}',
              style: TextStyle(color: secondaryColor, fontSize: 11),
            ),
        ],
      ),
      onTap: () async {
        final uri = Uri.tryParse(link.url);
        if (uri != null) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: link.url));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context)?.linksCopied ?? 'Link copied'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.month}/${date.day}';
  }
}

class _LinkItem {
  final String url;
  final String? title;
  final String? senderName;
  final DateTime? sentAt;

  const _LinkItem({
    required this.url,
    this.title,
    this.senderName,
    this.sentAt,
  });
}
