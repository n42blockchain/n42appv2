import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';

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
  });

  @override
  State<ChatMorePanel> createState() => _ChatMorePanelState();
}

class _ChatMorePanelState extends State<ChatMorePanel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onPageChanged);
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
    // 获取底部安全区域高度
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    // 内容高度（两行图标 + 页面指示器）- 增加高度避免溢出
    const contentHeight = 210.0;

    final pages = _paginate(_buildAllItems(context));

    return Container(
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
            Expanded(
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
              padding: const EdgeInsets.only(bottom: 8),
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
        icon: Icons.videocam_outlined,
        label: S.of(context)?.chatVideoCall ?? 'Video Call',
        onTap: widget.onVideoCallPressed,
      ),
      _MoreItem(
        icon: Icons.location_on_outlined,
        label: S.of(context)?.commonLocationLabel ?? 'Location',
        onTap: widget.onLocationPressed,
      ),
      _MoreItem(
        icon: Icons.card_giftcard,
        label: S.of(context)?.profileRedPacket ?? 'Red Packet',
        onTap: widget.onRedPacketPressed,
        iconColor: AppColors.redPacket,
      ),
      _MoreItem(
        icon: Icons.swap_horiz,
        label: S.of(context)?.commonTransfer ?? 'Transfer',
        onTap: widget.onTransferPressed,
      ),
      _MoreItem(
        icon: Icons.apps_rounded,
        label: S.of(context)?.chatMiniApps ?? 'Apps',
        onTap: widget.onMiniAppsPressed,
        iconColor: Colors.indigo,
      ),
      _MoreItem(
        icon: Icons.folder_outlined,
        label: S.of(context)?.commonFileLabel ?? 'File',
        onTap: widget.onFilePressed,
        onLongPress: widget.onFileLongPress,
      ),
      _MoreItem(
        icon: Icons.person_outline,
        label: S.of(context)?.searchContactLabel ?? 'Contact',
        onTap: widget.onContactCardPressed,
      ),
      _MoreItem(icon: Icons.code, label: 'Code', onTap: widget.onCodePressed),
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
      if (widget.onAiAssistantPressed != null)
        _MoreItem(
          icon: Icons.auto_awesome,
          label: S.of(context)?.aiAssistant ?? 'AI',
          onTap: widget.onAiAssistantPressed,
          iconColor: Colors.deepPurple,
        ),
    ];
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
