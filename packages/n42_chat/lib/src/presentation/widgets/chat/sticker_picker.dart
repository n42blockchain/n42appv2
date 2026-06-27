import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import 'video_sticker_view.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/matrix_utils.dart' as mx_utils;
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../../data/datasources/bundled_sticker_packs.dart';
import '../../../domain/entities/sticker_pack_entity.dart';
import '../../../domain/repositories/sticker_repository.dart';

/// 贴纸选择回调
typedef StickerSelectedCallback = void Function(Sticker sticker, String packId);
typedef StickerLongPressedCallback =
    Future<void> Function(Sticker sticker, String packId);

/// 贴纸选择器面板
///
/// 微信风格的贴纸选择器：
/// - 顶部显示贴纸包标签
/// - 主区域显示当前选中贴纸包的贴纸
/// - 支持常用贴纸
class StickerPicker extends StatefulWidget {
  /// 选择贴纸回调
  final StickerSelectedCallback onStickerSelected;

  /// 长按贴纸回调
  final StickerLongPressedCallback? onStickerLongPressed;

  /// 打开贴纸商店回调
  final VoidCallback? onOpenStore;

  /// 面板高度
  final double height;

  const StickerPicker({
    super.key,
    required this.onStickerSelected,
    this.onStickerLongPressed,
    this.onOpenStore,
    this.height = 260,
  });

  @override
  State<StickerPicker> createState() => _StickerPickerState();
}

class _StickerPickerState extends State<StickerPicker> {
  late final IStickerRepository _repository;
  final PageController _pageController = PageController();

  List<StickerPack> _packs = [];
  List<RecentSticker> _recentStickers = [];
  int _selectedPackIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = getIt<IStickerRepository>();
    _loadStickers();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadStickers() async {
    setState(() => _isLoading = true);

    try {
      final packs = await _repository.getInstalledPacks();
      final recent = await _repository.getRecentStickers(limit: 20);

      if (!mounted) return;
      setState(() {
        _packs = packs;
        _recentStickers = recent;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _onStickerTap(Sticker sticker, String packId) {
    widget.onStickerSelected(sticker, packId);
    // 记录使用
    _repository.recordStickerUsage(packId, sticker.id);
  }

  void _onPackSelected(int index) {
    setState(() => _selectedPackIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: widget.height + bottomPadding,
      decoration: BoxDecoration(
        color: context.inputBarColor,
        border: Border(
          top: BorderSide(
            color: context.dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // 贴纸包标签栏
            _buildPackTabs(isDark),

            // 贴纸网格
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildStickerGrid(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackTabs(bool isDark) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(
          bottom: BorderSide(
            color: context.dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // 常用贴纸标签
          if (_recentStickers.isNotEmpty)
            _buildPackTab(
              icon: Icons.access_time,
              isSelected: _selectedPackIndex == -1,
              onTap: () => _onPackSelected(-1),
              isDark: isDark,
            ),

          // 贴纸包标签
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _packs.length,
              itemBuilder: (context, index) {
                final pack = _packs[index];

                return _buildPackTab(
                  emoji: pack.stickers.isNotEmpty
                      ? pack.stickers.first.emoji
                      : null,
                  label: pack.name,
                  isSelected: _selectedPackIndex == index,
                  onTap: () => _onPackSelected(index),
                  isDark: isDark,
                );
              },
            ),
          ),

          // 贴纸商店按钮
          if (widget.onOpenStore != null)
            _buildPackTab(
              icon: Icons.add,
              onTap: widget.onOpenStore,
              isDark: isDark,
            ),
        ],
      ),
    );
  }

  Widget _buildPackTab({
    IconData? icon,
    String? emoji,
    String? label,
    bool isSelected = false,
    VoidCallback? onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Center(
          child: icon != null
              ? Icon(
                  icon,
                  size: 22,
                  color: isSelected
                      ? AppColors.primary
                      : context.textSecondary,
                )
              : Text(
                  emoji ?? label?.substring(0, 1) ?? '?',
                  style: TextStyle(
                    fontSize: emoji != null ? 22 : 14,
                    color: isSelected
                        ? AppColors.primary
                        : context.textSecondary,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildStickerGrid(bool isDark) {
    // 常用贴纸
    if (_selectedPackIndex == -1 && _recentStickers.isNotEmpty) {
      return _buildRecentStickers(isDark);
    }

    // 贴纸包
    if (_packs.isEmpty) {
      return _buildEmptyState(isDark);
    }

    final packIndex = _selectedPackIndex < 0 ? 0 : _selectedPackIndex;
    if (packIndex >= _packs.length) {
      return _buildEmptyState(isDark);
    }

    final pack = _packs[packIndex];
    return _buildPackStickers(pack, isDark);
  }

  Widget _buildRecentStickers(bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _recentStickers.length,
      itemBuilder: (context, index) {
        final recent = _recentStickers[index];
        return _buildStickerItem(recent.sticker, recent.packId, isDark);
      },
    );
  }

  Widget _buildPackStickers(StickerPack pack, bool isDark) {
    if (pack.stickers.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: pack.stickers.length,
      itemBuilder: (context, index) {
        final sticker = pack.stickers[index];
        return _buildStickerItem(sticker, pack.id, isDark);
      },
    );
  }

  Widget _buildStickerItem(Sticker sticker, String packId, bool isDark) {
    return GestureDetector(
      onTap: () => _onStickerTap(sticker, packId),
      onLongPress: widget.onStickerLongPressed == null
          ? null
          : () => widget.onStickerLongPressed!(sticker, packId),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.placeholderOf(isDark),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: _buildStickerContent(sticker)),
      ),
    );
  }

  Widget _buildStickerContent(Sticker sticker) {
    // Emoji 贴纸
    if (sticker.url.startsWith('emoji:')) {
      final emoji = sticker.url.substring(6);
      return Text(emoji, style: const TextStyle(fontSize: 32));
    }

    // 内置 asset 贴纸（Lottie 动画 / SVG 静态）
    if (BundledStickerPacks.isAssetSticker(sticker.url)) {
      final path = BundledStickerPacks.assetPath(sticker.url);
      return Padding(
        padding: const EdgeInsets.all(6),
        child: BundledStickerPacks.isLottie(sticker.url)
            ? Lottie.asset(path, fit: BoxFit.contain, repeat: true)
            : SvgPicture.asset(
                path,
                fit: BoxFit.contain,
                placeholderBuilder: (_) => Text(sticker.emoji ?? '🙂',
                    style: const TextStyle(fontSize: 32)),
              ),
      );
    }

    // 图片 / 视频贴纸
    final httpUrl = sticker.httpUrl ?? sticker.url;
    if (httpUrl.startsWith('http')) {
      final client = getIt.isRegistered<MatrixClientManager>()
          ? getIt<MatrixClientManager>().client
          : null;
      final headers = mx_utils.MatrixUtils.buildAuthenticatedMediaHeaders(
        httpUrl,
        client: client,
      );
      // 视频贴纸（WebM/MP4，对齐 Telegram）：用 video_player 循环播放。
      if (VideoStickerView.isVideoSticker(
        mimeType: sticker.mimeType,
        url: httpUrl,
      )) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: VideoStickerView(url: httpUrl, headers: headers),
        );
      }
      // 静态 / 动画 WebP / GIF（Flutter Image 原生支持动画 WebP & GIF）。
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          httpUrl,
          fit: BoxFit.contain,
          headers: headers,
          errorBuilder: (_, _, _) => const Icon(Icons.image_not_supported),
        ),
      );
    }

    // 显示 emoji 或占位符
    return Text(sticker.emoji ?? '?', style: const TextStyle(fontSize: 32));
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_emotions_outlined,
            size: 48,
            color: context.textTertiary,
          ),
          const SizedBox(height: 8),
          Text(
            'No stickers yet',
            style: TextStyle(
              color: context.textTertiary,
            ),
          ),
          if (widget.onOpenStore != null) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: widget.onOpenStore,
              icon: const Icon(Icons.add),
              label: const Text('Get Stickers'),
            ),
          ],
        ],
      ),
    );
  }
}
