import 'package:flutter/material.dart';

import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/services/recent_emoji_store.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/sticker_pack_entity.dart';
import '../../../domain/repositories/sticker_repository.dart';
import 'emoji_picker.dart';
import 'sticker_picker.dart';
import 'sticker_thumb.dart';
import 'gif_picker.dart';

/// 统一表情面板分页
enum ExpressionTab { recent, emoji, sticker, gif }

/// 统一「最近 / 表情 / 贴纸 / GIF」面板
///
/// 将原先分散的入口（emoji 在输入栏表情按钮、sticker/gif 埋在"+"菜单）
/// 合并为一个分页面板（竞品标准布局：底部分页切换）。各分页直接复用既有的
/// [EmojiPicker] / [StickerPicker] / [GifPicker]，发送回调由宿主透传，
/// 用 [IndexedStack] 保活避免切页重载。「最近」聚合最近用过的 emoji（本地存储）
/// 与贴纸（IStickerRepository）。
class ExpressionPanel extends StatefulWidget {
  final double height;
  final ExpressionTab initialTab;

  // Emoji
  final ValueChanged<String> onEmojiSelected;
  final VoidCallback? onBackspace;
  final VoidCallback? onSend;

  // Sticker
  final StickerSelectedCallback onStickerSelected;
  final StickerLongPressedCallback? onStickerLongPressed;
  final VoidCallback? onOpenStickerStore;

  // GIF
  final GifSelectedCallback onGifSelected;
  final GifLongPressedCallback? onGifLongPressed;

  const ExpressionPanel({
    super.key,
    this.height = 320,
    this.initialTab = ExpressionTab.emoji,
    required this.onEmojiSelected,
    this.onBackspace,
    this.onSend,
    required this.onStickerSelected,
    this.onStickerLongPressed,
    this.onOpenStickerStore,
    required this.onGifSelected,
    this.onGifLongPressed,
  });

  @override
  State<ExpressionPanel> createState() => _ExpressionPanelState();
}

class _ExpressionPanelState extends State<ExpressionPanel> {
  late ExpressionTab _tab = widget.initialTab;
  final RecentEmojiStore _recentEmoji = RecentEmojiStore();
  int _recentReloadToken = 0;

  static const double _tabBarHeight = 44;

  @override
  void didUpdateWidget(covariant ExpressionPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      _tab = widget.initialTab;
    }
  }

  /// emoji 选中：记录最近后透传
  void _handleEmoji(String emoji) {
    _recentEmoji.record(emoji);
    widget.onEmojiSelected(emoji);
  }

  void _switchTab(ExpressionTab tab) {
    setState(() {
      _tab = tab;
      // 进入「最近」时刷新（IndexedStack 保活，靠 token 触发重载）
      if (tab == ExpressionTab.recent) _recentReloadToken++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bodyHeight = (widget.height - _tabBarHeight).clamp(0.0, widget.height);
    return Container(
      height: widget.height,
      color: context.inputBarColor,
      child: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _tab.index,
              sizing: StackFit.expand,
              children: [
                _RecentTab(
                  reloadToken: _recentReloadToken,
                  recentEmojiStore: _recentEmoji,
                  onEmojiSelected: _handleEmoji,
                  onStickerSelected: widget.onStickerSelected,
                  onGoToStickers: () => _switchTab(ExpressionTab.sticker),
                  onGoToEmojis: () => _switchTab(ExpressionTab.emoji),
                ),
                EmojiPicker(
                  height: bodyHeight,
                  onEmojiSelected: _handleEmoji,
                  onBackspace: widget.onBackspace,
                  onSend: widget.onSend,
                ),
                StickerPicker(
                  height: bodyHeight,
                  onStickerSelected: widget.onStickerSelected,
                  onStickerLongPressed: widget.onStickerLongPressed,
                  onOpenStore: widget.onOpenStickerStore,
                ),
                GifPicker(
                  height: bodyHeight,
                  onGifSelected: widget.onGifSelected,
                  onGifLongPressed: widget.onGifLongPressed,
                ),
              ],
            ),
          ),
          _buildTabBar(context),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      height: _tabBarHeight,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(
          top: BorderSide(color: context.dividerColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          _tabButton(context, ExpressionTab.recent, Icons.access_time_rounded),
          _tabButton(
              context, ExpressionTab.emoji, Icons.emoji_emotions_outlined),
          _tabButton(
              context, ExpressionTab.sticker, Icons.auto_awesome_outlined),
          _tabButton(context, ExpressionTab.gif, Icons.gif_box_outlined),
        ],
      ),
    );
  }

  Widget _tabButton(BuildContext context, ExpressionTab tab, IconData icon) {
    final selected = _tab == tab;
    return Expanded(
      child: InkWell(
        onTap: () => _switchTab(tab),
        child: Container(
          alignment: Alignment.center,
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          child: Icon(
            icon,
            size: 24,
            color: selected ? AppColors.primary : context.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// 「最近」分页：最近 emoji + 最近贴纸
class _RecentTab extends StatefulWidget {
  final int reloadToken;
  final RecentEmojiStore recentEmojiStore;
  final ValueChanged<String> onEmojiSelected;
  final StickerSelectedCallback onStickerSelected;
  final VoidCallback onGoToStickers;
  final VoidCallback onGoToEmojis;

  const _RecentTab({
    required this.reloadToken,
    required this.recentEmojiStore,
    required this.onEmojiSelected,
    required this.onStickerSelected,
    required this.onGoToStickers,
    required this.onGoToEmojis,
  });

  @override
  State<_RecentTab> createState() => _RecentTabState();
}

class _RecentTabState extends State<_RecentTab> {
  List<String> _emojis = const [];
  List<RecentSticker> _stickers = const [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _RecentTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reloadToken != widget.reloadToken) {
      _load();
    }
  }

  Future<void> _load() async {
    final emojis = await widget.recentEmojiStore.getRecent();
    var stickers = const <RecentSticker>[];
    if (getIt.isRegistered<IStickerRepository>()) {
      try {
        stickers = await getIt<IStickerRepository>().getRecentStickers(
          limit: 16,
        );
      } catch (_) {
        stickers = const [];
      }
    }
    if (mounted) {
      setState(() {
        _emojis = emojis;
        _stickers = stickers;
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (_emojis.isEmpty && _stickers.isEmpty) {
      return _buildEmpty(context);
    }
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      children: [
        if (_emojis.isNotEmpty) ...[
          _sectionIcon(context, Icons.emoji_emotions_outlined),
          Wrap(
            children: _emojis
                .map(
                  (e) => InkWell(
                    onTap: () => widget.onEmojiSelected(e),
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      child: Text(e, style: const TextStyle(fontSize: 26)),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
        if (_stickers.isNotEmpty) ...[
          const SizedBox(height: 8),
          _sectionIcon(context, Icons.auto_awesome_outlined),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: _stickers
                .map(
                  (r) => GestureDetector(
                    onTap: () =>
                        widget.onStickerSelected(r.sticker, r.packId),
                    child: _StickerThumb(sticker: r.sticker),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _sectionIcon(BuildContext context, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Icon(icon, size: 16, color: context.textTertiary),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.access_time_rounded, size: 44, color: context.textTertiary),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              TextButton.icon(
                onPressed: widget.onGoToEmojis,
                icon: const Icon(Icons.emoji_emotions_outlined, size: 18),
                label: const Text('Emoji'),
              ),
              TextButton.icon(
                onPressed: widget.onGoToStickers,
                icon: const Icon(Icons.auto_awesome_outlined, size: 18),
                label: const Text('Stickers'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 贴纸缩略图（统一渲染，见 [StickerThumb]）
class _StickerThumb extends StatelessWidget {
  final Sticker sticker;

  const _StickerThumb({required this.sticker});

  @override
  Widget build(BuildContext context) => StickerThumb(sticker: sticker);
}
