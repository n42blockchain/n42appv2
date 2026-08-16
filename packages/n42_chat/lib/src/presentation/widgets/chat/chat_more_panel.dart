import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';

enum ChatRecentMediaAccess { available, limited, denied, unsupported }

@immutable
class ChatRecentMediaItem {
  final String id;
  final Uint8List thumbnailBytes;
  final bool isVideo;
  final Duration duration;

  const ChatRecentMediaItem({
    required this.id,
    required this.thumbnailBytes,
    this.isVideo = false,
    this.duration = Duration.zero,
  });
}

@immutable
class ChatRecentMediaSnapshot {
  final ChatRecentMediaAccess access;
  final List<ChatRecentMediaItem> items;

  const ChatRecentMediaSnapshot({required this.access, this.items = const []});

  bool get hasAccess =>
      access == ChatRecentMediaAccess.available ||
      access == ChatRecentMediaAccess.limited;
}

typedef ChatRecentMediaLoader = Future<ChatRecentMediaSnapshot> Function();
typedef ChatRecentMediaSender = Future<void> Function(List<String> assetIds);

/// 聊天更多功能面板
///
/// 微信风格的底部功能面板，包含：
/// - 照片、拍摄、视频通话、位置
/// - 红包、转账、文件、名片
/// - 收藏、音乐、收款、商店等（可滑动）
class ChatMorePanel extends StatefulWidget {
  /// 选择照片回调
  final VoidCallback? onPhotoPressed;

  /// 长按照片回调
  final VoidCallback? onPhotoLongPress;

  /// 拍摄回调
  final VoidCallback? onCameraPressed;

  /// 视频通话回调
  final VoidCallback? onVideoCallPressed;

  /// 位置回调
  final VoidCallback? onLocationPressed;

  /// 实时位置回调
  final VoidCallback? onLiveLocationPressed;

  /// 红包回调
  final VoidCallback? onRedPacketPressed;

  /// 转账回调
  final VoidCallback? onTransferPressed;

  /// 文件回调
  final VoidCallback? onFilePressed;

  /// 长按文件回调
  final VoidCallback? onFileLongPress;

  /// 名片回调
  final VoidCallback? onContactCardPressed;

  /// 收藏回调
  final VoidCallback? onFavoritePressed;

  /// 音乐回调
  final VoidCallback? onMusicPressed;

  /// 收款回调
  final VoidCallback? onReceivePressed;

  /// 商店回调
  final VoidCallback? onShopPressed;

  /// 商店标签
  final String? shopLabel;

  /// 投票回调
  final VoidCallback? onPollPressed;

  /// 日程/事件回调
  final VoidCallback? onEventPressed;

  /// GIF 回调
  final VoidCallback? onGifPressed;

  /// 贴纸回调
  final VoidCallback? onStickerPressed;

  /// View Once（阅后即焚）回调
  final VoidCallback? onViewOncePressed;

  /// 是否处于 View Once 模式
  final bool isViewOnce;

  /// 人脸模糊回调
  final VoidCallback? onFaceBlurPressed;

  /// 是否启用人脸模糊
  final bool isFaceBlur;

  /// AI 助手回调
  final VoidCallback? onAiAssistantPressed;

  /// 阅后即焚定时器回调
  final VoidCallback? onSelfDestructTimerPressed;

  /// 定时发送回调
  final VoidCallback? onScheduledPressed;

  /// 当前阅后即焚定时器（秒，null 表示关闭）
  final int? selfDestructAfter;

  /// Mini Apps 回调
  final VoidCallback? onMiniAppsPressed;

  /// 代码块
  final VoidCallback? onCodePressed;

  /// 打赏
  final VoidCallback? onTipPressed;

  /// 白板 / 涂鸦
  final VoidCallback? onWhiteboardPressed;

  /// 圆形视频留言（Video Note）
  final VoidCallback? onVideoNotePressed;

  /// 加载系统相册中的最近照片/视频。为空时保持传统紧凑面板。
  final ChatRecentMediaLoader? recentMediaLoader;

  /// 发送用户在最近媒体区选中的资源。
  final ChatRecentMediaSender? onRecentMediaSend;

  /// 管理有限照片授权或打开系统设置。
  final Future<void> Function()? onManageRecentMediaAccess;

  /// 最近媒体一次最多选择数量；阅后即焚模式应传 1。
  final int maxRecentMediaSelection;

  const ChatMorePanel({
    super.key,
    this.onPhotoPressed,
    this.onPhotoLongPress,
    this.onCameraPressed,
    this.onVideoCallPressed,
    this.onLocationPressed,
    this.onLiveLocationPressed,
    this.onRedPacketPressed,
    this.onTransferPressed,
    this.onFilePressed,
    this.onFileLongPress,
    this.onContactCardPressed,
    this.onFavoritePressed,
    this.onMusicPressed,
    this.onReceivePressed,
    this.onShopPressed,
    this.shopLabel,
    this.onPollPressed,
    this.onEventPressed,
    this.onGifPressed,
    this.onStickerPressed,
    this.onViewOncePressed,
    this.isViewOnce = false,
    this.onFaceBlurPressed,
    this.isFaceBlur = false,
    this.onAiAssistantPressed,
    this.onSelfDestructTimerPressed,
    this.onScheduledPressed,
    this.selfDestructAfter,
    this.onMiniAppsPressed,
    this.onCodePressed,
    this.onTipPressed,
    this.onWhiteboardPressed,
    this.onVideoNotePressed,
    this.recentMediaLoader,
    this.onRecentMediaSend,
    this.onManageRecentMediaAccess,
    this.maxRecentMediaSelection = 9,
  });

  @override
  State<ChatMorePanel> createState() => _ChatMorePanelState();
}

class _ChatMorePanelState extends State<ChatMorePanel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  ChatRecentMediaSnapshot? _recentMedia;
  Object? _recentMediaError;
  bool _loadingRecentMedia = false;
  bool _sendingRecentMedia = false;
  bool _expanded = false;
  final List<String> _selectedRecentMediaIds = [];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onPageChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRecentMedia());
  }

  @override
  void didUpdateWidget(covariant ChatMorePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recentMediaLoader != widget.recentMediaLoader) {
      _selectedRecentMediaIds.clear();
      _loadRecentMedia();
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged() {
    final page = _pageController.page?.round() ?? 0;
    if (page != _currentPage) {
      setState(() {
        _currentPage = page;
      });
    }
  }

  Future<void> _loadRecentMedia() async {
    final loader = widget.recentMediaLoader;
    if (loader == null || _loadingRecentMedia) return;
    setState(() {
      _loadingRecentMedia = true;
      _recentMediaError = null;
    });
    try {
      final snapshot = await loader();
      if (!mounted) return;
      setState(() {
        _recentMedia = snapshot;
        _selectedRecentMediaIds.removeWhere(
          (id) => !snapshot.items.any((item) => item.id == id),
        );
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _recentMediaError = error);
    } finally {
      if (mounted) setState(() => _loadingRecentMedia = false);
    }
  }

  void _toggleRecentMedia(ChatRecentMediaItem item) {
    if (_sendingRecentMedia) return;
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedRecentMediaIds.remove(item.id)) return;
      final maxSelection = widget.maxRecentMediaSelection.clamp(1, 30);
      if (_selectedRecentMediaIds.length >= maxSelection) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Select up to $maxSelection items')),
        );
        return;
      }
      _selectedRecentMediaIds.add(item.id);
    });
  }

  Future<void> _sendRecentMedia() async {
    final sender = widget.onRecentMediaSend;
    if (sender == null || _selectedRecentMediaIds.isEmpty) return;
    setState(() => _sendingRecentMedia = true);
    try {
      await sender(List<String>.unmodifiable(_selectedRecentMediaIds));
      if (mounted) setState(_selectedRecentMediaIds.clear);
    } finally {
      if (mounted) setState(() => _sendingRecentMedia = false);
    }
  }

  Future<void> _manageRecentMediaAccess() async {
    await widget.onManageRecentMediaAccess?.call();
    if (mounted) await _loadRecentMedia();
  }

  /// 每页两行 × 每行 4 个 = 8 个条目。
  static const int _itemsPerPage = 8;

  /// 把全部条目按每页 [_itemsPerPage] 个自动分页。
  ///
  /// ⚠️ 历史 bug：此前是三个手工分组的"逻辑页"，而 `_buildPage` 只渲染
  /// 每页前 8 项——第一页实际塞了 11 项、第二页 9 项，超出的条目
  /// （Contact 名片 / Code 代码块 / Tip 打赏 / View Once 阅后即焚）被
  /// **静默丢弃**，用户完全不可达，表现为"功能消失"。自动分页后所有
  /// 条目必然可达，未来加项也不会再丢。
  List<List<_MoreItem>> _paginate(List<_MoreItem> items) {
    final pages = <List<_MoreItem>>[];
    for (var i = 0; i < items.length; i += _itemsPerPage) {
      pages.add(
        items.sublist(
          i,
          (i + _itemsPerPage) > items.length ? items.length : i + _itemsPerPage,
        ),
      );
    }
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final recentMediaSupported =
        widget.recentMediaLoader != null &&
        _recentMedia?.access != ChatRecentMediaAccess.unsupported;
    final contentHeight = recentMediaSupported
        ? (_expanded ? screenHeight * 0.68 : screenHeight * 0.48).clamp(
            360.0,
            _expanded ? 620.0 : 430.0,
          )
        : 225.0;

    final pages = _paginate(_buildAllItems(context));

    return Container(
      key: const ValueKey<String>('chat_more_panel'),
      // 固定高度 = 内容高度 + 底部安全区域
      height: contentHeight + bottomPadding,
      decoration: BoxDecoration(
        color: context.inputBarColor,
        border: Border(
          top: BorderSide(color: context.dividerColor, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;
                if (velocity < -120 && !_expanded) {
                  setState(() => _expanded = true);
                } else if (velocity > 120 && _expanded) {
                  setState(() => _expanded = false);
                }
              },
              onTap: recentMediaSupported
                  ? () => setState(() => _expanded = !_expanded)
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.textTertiary.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 176,
              child: PageView(
                controller: _pageController,
                children: [
                  for (final pageItems in pages)
                    _buildPage(context, isDark, pageItems),
                ],
              ),
            ),
            // 页面指示器（移到 PageView 外部）
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (index) => Padding(
                    padding: EdgeInsets.only(left: index > 0 ? 6 : 0),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppColors.textSecondary
                            : AppColors.textTertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (recentMediaSupported)
              Expanded(child: _buildRecentMediaSection(context)),
          ],
        ),
      ),
    );
  }

  /// 全部条目（按产品期望的展示顺序）。条件项用 collection-if 保留原语义。
  List<_MoreItem> _buildAllItems(BuildContext context) {
    return [
      _MoreItem(
        icon: Icons.photo_library_outlined,
        label: S.of(context)?.contactPhotos ?? 'Photos',
        onTap: widget.onPhotoPressed,
        onLongPress: widget.onPhotoLongPress,
      ),
      _MoreItem(
        icon: Icons.camera_alt_outlined,
        label: S.of(context)?.commonTakePhoto ?? 'Camera',
        onTap: widget.onCameraPressed,
      ),
      _MoreItem(
        icon: Icons.location_on_outlined,
        label: S.of(context)?.commonLocationLabel ?? 'Location',
        onTap: widget.onLocationPressed,
      ),
      _MoreItem(
        icon: Icons.person_outline,
        label: S.of(context)?.searchContactLabel ?? 'Contact',
        onTap: widget.onContactCardPressed,
      ),
      _MoreItem(
        icon: Icons.folder_outlined,
        label: S.of(context)?.commonFileLabel ?? 'File',
        onTap: widget.onFilePressed,
        onLongPress: widget.onFileLongPress,
      ),
      _MoreItem(
        icon: Icons.poll_outlined,
        label: S.of(context)?.commonPoll ?? 'Poll',
        onTap: widget.onPollPressed,
        iconColor: AppColors.primary,
      ),
      _MoreItem(
        icon: Icons.event_outlined,
        label: 'Event',
        onTap: widget.onEventPressed,
        iconColor: AppColors.info,
      ),
      _MoreItem(
        icon: Icons.apps_rounded,
        label: S.of(context)?.chatMiniApps ?? 'Apps',
        onTap: widget.onMiniAppsPressed,
        iconColor: Colors.indigo,
      ),
      // 钱包与应用
      _MoreItem(
        icon: Icons.swap_horiz,
        label: S.of(context)?.commonTransfer ?? 'Transfer',
        onTap: widget.onTransferPressed,
      ),
      _MoreItem(
        icon: Icons.card_giftcard,
        label: S.of(context)?.profileRedPacket ?? 'Red Packet',
        onTap: widget.onRedPacketPressed,
        iconColor: AppColors.redPacket,
      ),
      _MoreItem(
        icon: Icons.volunteer_activism_outlined,
        label: 'Tip',
        onTap: widget.onTipPressed,
        iconColor: const Color(0xFFFF6B9D),
      ),
      _MoreItem(
        icon: Icons.star_outline,
        label: S.of(context)?.commonFavorites ?? 'Favorites',
        onTap: widget.onFavoritePressed,
      ),
      _MoreItem(
        icon: Icons.music_note_outlined,
        label: S.of(context)?.commonMusic ?? 'Music',
        onTap: widget.onMusicPressed,
      ),
      _MoreItem(
        icon: Icons.request_quote_outlined,
        label: S.of(context)?.transferReceive ?? 'Receive',
        onTap: widget.onReceivePressed,
        iconColor: AppColors.success,
      ),
      _MoreItem(
        icon: Icons.storefront_outlined,
        label: widget.shopLabel ?? 'Shop',
        onTap: widget.onShopPressed,
        iconColor: AppColors.warning,
      ),
      _MoreItem(
        icon: Icons.videocam_outlined,
        label: S.of(context)?.chatVideoCall ?? 'Video Call',
        onTap: widget.onVideoCallPressed,
      ),
      // 创作与消息工具
      _MoreItem(
        icon: Icons.gif_box_outlined,
        label: 'GIF',
        onTap: widget.onGifPressed,
        iconColor: AppColors.textLink,
      ),
      _MoreItem(
        icon: Icons.emoji_emotions_outlined,
        label: S.of(context)?.profileStickers ?? 'Stickers',
        onTap: widget.onStickerPressed,
        iconColor: AppColors.warning,
      ),
      _MoreItem(
        icon: Icons.draw_outlined,
        label: 'Whiteboard',
        onTap: widget.onWhiteboardPressed,
        iconColor: Colors.brown,
      ),
      _MoreItem(
        icon: Icons.video_camera_front_outlined,
        label: 'Video note',
        onTap: widget.onVideoNotePressed,
        iconColor: Colors.pinkAccent,
      ),
      _MoreItem(icon: Icons.code, label: 'Code', onTap: widget.onCodePressed),
      if (widget.onAiAssistantPressed != null)
        _MoreItem(
          icon: Icons.auto_awesome,
          label: S.of(context)?.aiAssistant ?? 'AI',
          onTap: widget.onAiAssistantPressed,
          iconColor: Colors.deepPurple,
        ),
      // 会话发送模式
      _MoreItem(
        icon: widget.isViewOnce ? Icons.timer : Icons.timer_outlined,
        label: S.of(context)?.chatViewOnce ?? 'View Once',
        onTap: widget.onViewOncePressed,
        iconColor: widget.isViewOnce ? AppColors.primary : null,
      ),
      _MoreItem(
        icon: widget.isFaceBlur ? Icons.face_retouching_natural : Icons.face,
        label: S.of(context)?.chatAutoFaceBlur ?? 'Face Blur',
        onTap: widget.onFaceBlurPressed,
        iconColor: widget.isFaceBlur ? AppColors.primary : null,
      ),
      _MoreItem(
        icon: Icons.share_location,
        label: S.of(context)?.liveLocation ?? 'Live Location',
        onTap: widget.onLiveLocationPressed,
        iconColor: Colors.teal,
      ),
      _MoreItem(
        icon: widget.selfDestructAfter != null
            ? Icons.timer
            : Icons.timer_outlined,
        label: S.of(context)?.chatSelfDestructTimer ?? 'Timer',
        onTap: widget.onSelfDestructTimerPressed,
        iconColor: widget.selfDestructAfter != null ? AppColors.warning : null,
      ),
      _MoreItem(
        icon: Icons.schedule_outlined,
        label: S.of(context)?.scheduledMessageLabel ?? 'Scheduled',
        onTap: widget.onScheduledPressed,
        iconColor: AppColors.primary,
      ),
    ];
  }

  Widget _buildRecentMediaSection(BuildContext context) {
    final l10n = S.of(context);
    final snapshot = _recentMedia;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.surfaceColor.withValues(alpha: 0.45),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 8, 4),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 360;
                final photosLabel = l10n?.contactPhotos ?? 'Photos';
                final manageLabel = l10n?.commonSettings ?? 'Manage';
                final sendLabel =
                    l10n?.commonSendCount(_selectedRecentMediaIds.length) ??
                    'Send (${_selectedRecentMediaIds.length})';
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n?.chatRecentPlayed ?? 'Recent',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (snapshot?.access == ChatRecentMediaAccess.limited)
                      compact
                          ? IconButton(
                              visualDensity: VisualDensity.compact,
                              tooltip: manageLabel,
                              onPressed: _manageRecentMediaAccess,
                              icon: const Icon(Icons.tune, size: 20),
                            )
                          : TextButton(
                              onPressed: _manageRecentMediaAccess,
                              child: Text(manageLabel),
                            ),
                    compact
                        ? IconButton(
                            visualDensity: VisualDensity.compact,
                            tooltip: photosLabel,
                            onPressed: widget.onPhotoPressed,
                            icon: const Icon(
                              Icons.photo_library_outlined,
                              size: 20,
                            ),
                          )
                        : TextButton(
                            onPressed: widget.onPhotoPressed,
                            child: Text(photosLabel),
                          ),
                    if (_selectedRecentMediaIds.isNotEmpty)
                      compact
                          ? IconButton.filled(
                              visualDensity: VisualDensity.compact,
                              tooltip: sendLabel,
                              onPressed: _sendingRecentMedia
                                  ? null
                                  : _sendRecentMedia,
                              icon: _sendingRecentMedia
                                  ? const SizedBox.square(
                                      dimension: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Badge(
                                      label: Text(
                                        '${_selectedRecentMediaIds.length}',
                                      ),
                                      child: const Icon(Icons.send, size: 18),
                                    ),
                            )
                          : FilledButton(
                              onPressed: _sendingRecentMedia
                                  ? null
                                  : _sendRecentMedia,
                              child: _sendingRecentMedia
                                  ? const SizedBox.square(
                                      dimension: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(sendLabel),
                            ),
                  ],
                );
              },
            ),
          ),
          Expanded(child: _buildRecentMediaBody(context)),
        ],
      ),
    );
  }

  Widget _buildRecentMediaBody(BuildContext context) {
    if (_loadingRecentMedia && _recentMedia == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_recentMediaError != null) {
      return _buildRecentMediaMessage(
        context,
        icon: Icons.broken_image_outlined,
        message: 'Could not load recent media',
        actionLabel: S.of(context)?.commonRetry ?? 'Retry',
        onAction: _loadRecentMedia,
      );
    }
    final snapshot = _recentMedia;
    if (snapshot == null) return const SizedBox.shrink();
    if (!snapshot.hasAccess) {
      return _buildRecentMediaMessage(
        context,
        icon: Icons.photo_library_outlined,
        message: 'Photo access is needed to show recent media',
        actionLabel: S.of(context)?.contactPhotos ?? 'Open Photos',
        onAction: widget.onPhotoPressed,
        secondaryLabel: S.of(context)?.commonSettings ?? 'Settings',
        onSecondary: widget.onManageRecentMediaAccess == null
            ? null
            : _manageRecentMediaAccess,
      );
    }
    if (snapshot.items.isEmpty) {
      return _buildRecentMediaMessage(
        context,
        icon: Icons.photo_library_outlined,
        message: 'No recent photos or videos',
        actionLabel: S.of(context)?.contactPhotos ?? 'Open Photos',
        onAction: widget.onPhotoPressed,
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 110,
        mainAxisExtent: 92,
        crossAxisSpacing: 3,
        mainAxisSpacing: 3,
      ),
      itemCount: snapshot.items.length,
      itemBuilder: (context, index) =>
          _buildRecentMediaTile(context, snapshot.items[index]),
    );
  }

  Widget _buildRecentMediaTile(BuildContext context, ChatRecentMediaItem item) {
    final selectionIndex = _selectedRecentMediaIds.indexOf(item.id);
    final selected = selectionIndex >= 0;
    return Semantics(
      button: true,
      selected: selected,
      label: item.isVideo ? 'Recent video' : 'Recent photo',
      child: GestureDetector(
        onTap: () => _toggleRecentMedia(item),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.memory(
                item.thumbnailBytes,
                fit: BoxFit.cover,
                gaplessPlayback: true,
              ),
            ),
            if (selected)
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 3),
                  borderRadius: BorderRadius.circular(5),
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
              ),
            if (item.isVideo)
              Positioned(
                left: 4,
                bottom: 4,
                child: Row(
                  children: [
                    const Icon(Icons.videocam, color: Colors.white, size: 14),
                    const SizedBox(width: 2),
                    Text(
                      _formatDuration(item.duration),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        shadows: [Shadow(blurRadius: 3)],
                      ),
                    ),
                  ],
                ),
              ),
            Positioned(
              right: 5,
              top: 5,
              child: Container(
                width: 23,
                height: 23,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary
                      : Colors.black.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: selected
                    ? Text(
                        '${selectionIndex + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentMediaMessage(
    BuildContext context, {
    required IconData icon,
    required String message,
    required String actionLabel,
    required VoidCallback? onAction,
    String? secondaryLabel,
    VoidCallback? onSecondary,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: context.textTertiary),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: context.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: TextButton(
                    style: _compactMediaActionStyle,
                    onPressed: onAction,
                    child: Text(
                      actionLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if (secondaryLabel != null)
                  Flexible(
                    child: TextButton(
                      style: _compactMediaActionStyle,
                      onPressed: onSecondary,
                      child: Text(
                        secondaryLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ButtonStyle get _compactMediaActionStyle => TextButton.styleFrom(
    minimumSize: const Size(0, 34),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildPage(BuildContext context, bool isDark, List<_MoreItem> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 第一行
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (int i = 0; i < 4; i++)
                    if (i < items.length)
                      _buildItem(context, items[i], isDark)
                    else
                      const SizedBox(width: 70),
                ],
              ),
            ),
          ),
          // 第二行
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (int i = 4; i < 8; i++)
                    if (i < items.length)
                      _buildItem(context, items[i], isDark)
                    else
                      const SizedBox(width: 70),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, _MoreItem item, bool isDark) {
    final bgColor = context.surfaceColor;
    final defaultIconColor = context.textSecondary;

    return Semantics(
      button: true,
      label: item.label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: item.onTap,
        onLongPress: item.onLongPress,
        child: SizedBox(
          width: 70,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  size: 28,
                  color: item.iconColor ?? defaultIconColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.label,
                style: TextStyle(fontSize: 11, color: context.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreItem {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? iconColor;

  const _MoreItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.onLongPress,
    this.iconColor,
  });
}
