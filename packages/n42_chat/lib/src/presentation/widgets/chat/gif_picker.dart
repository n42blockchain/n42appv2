import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/services/giphy_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/debug_log.dart';
import 'scheduled_send_picker.dart';

/// GIF 选择回调
typedef GifSelectedCallback = void Function(GiphyGif gif);
typedef GifLongPressedCallback = Future<void> Function(GiphyGif gif);

class GifPickerResult {
  final GiphyGif gif;
  final DateTime? scheduledAt;

  const GifPickerResult({required this.gif, this.scheduledAt});

  String get title => gif.title;

  Map<String, dynamic> get scheduledPayload => {
    'gifUrl': gif.originalUrl,
    'previewUrl': gif.previewUrl,
    'width': gif.width,
    'height': gif.height,
  };
}

/// GIF 选择器面板
///
/// 提供 GIF 搜索和选择功能：
/// - 热门 GIF 展示
/// - 搜索 GIF
/// - 瀑布流布局
/// - 无限滚动加载
class GifPicker extends StatefulWidget {
  /// 选择 GIF 回调
  final GifSelectedCallback onGifSelected;

  /// 长按 GIF 回调
  final GifLongPressedCallback? onGifLongPressed;

  /// 面板高度
  final double height;

  const GifPicker({
    super.key,
    required this.onGifSelected,
    this.onGifLongPressed,
    this.height = 300,
  });

  @override
  State<GifPicker> createState() => _GifPickerState();
}

class _GifPickerState extends State<GifPicker> {
  GiphyService? _giphyService;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<GiphyGif> _gifs = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  String _currentQuery = '';
  Timer? _debounceTimer;
  bool _serviceAvailable = false;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  void _initializeService() {
    try {
      if (GetIt.instance.isRegistered<GiphyService>()) {
        _giphyService = GetIt.instance<GiphyService>();
        _serviceAvailable = true;
        _loadTrendingGifs();
        _scrollController.addListener(_onScroll);
        _searchController.addListener(_onSearchChanged);
      }
    } catch (e) {
      debugLog('GifPicker: GiphyService not available: $e');
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    // 不要 dispose _giphyService，因为它是单例
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreGifs();
    }
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      if (query != _currentQuery) {
        _currentQuery = query;
        _resetAndLoad();
      }
    });
  }

  void _resetAndLoad() {
    setState(() {
      _gifs = [];
      _offset = 0;
      _hasMore = true;
    });

    if (_currentQuery.isEmpty) {
      _loadTrendingGifs();
    } else {
      _searchGifs();
    }
  }

  Future<void> _loadTrendingGifs() async {
    if (_isLoading || _giphyService == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _giphyService!.getTrendingGifs(offset: _offset);
      if (mounted) {
        setState(() {
          _gifs.addAll(result.gifs);
          _offset = result.offset + result.gifs.length;
          _hasMore = result.hasMore;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _searchGifs() async {
    if (_isLoading || _currentQuery.isEmpty || _giphyService == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _giphyService!.searchGifs(
        query: _currentQuery,
        offset: _offset,
      );
      if (mounted) {
        setState(() {
          _gifs.addAll(result.gifs);
          _offset = result.offset + result.gifs.length;
          _hasMore = result.hasMore;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreGifs() async {
    if (_isLoading || !_hasMore) return;

    if (_currentQuery.isEmpty) {
      await _loadTrendingGifs();
    } else {
      await _searchGifs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: widget.height + bottomPadding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.inputBarDark : AppColors.inputBar,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.divider,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // 搜索栏
            _buildSearchBar(isDark),

            // GIF 网格
            Expanded(child: _buildGifGrid(isDark)),

            // Giphy 署名
            _buildGiphyAttribution(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          controller: _searchController,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Search GIFs...',
            hintStyle: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiary,
            ),
            prefixIcon: Icon(
              Icons.search,
              size: 20,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      _currentQuery = '';
                      _resetAndLoad();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ),
    );
  }

  Widget _buildGifGrid(bool isDark) {
    // 服务不可用时显示提示
    if (!_serviceAvailable) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_outlined,
              size: 48,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'GIF service not configured',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Please configure Giphy API key',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[500] : Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    if (_gifs.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_gifs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.gif_box_outlined,
              size: 48,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              _currentQuery.isEmpty ? 'No trending GIFs' : 'No GIFs found',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: _gifs.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _gifs.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final gif = _gifs[index];
        return _buildGifItem(gif, isDark);
      },
    );
  }

  Widget _buildGifItem(GiphyGif gif, bool isDark) {
    return GestureDetector(
      onTap: () => widget.onGifSelected(gif),
      onLongPress: widget.onGifLongPressed == null
          ? null
          : () => widget.onGifLongPressed!(gif),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: isDark ? Colors.grey[800] : Colors.grey[200],
          child: Image.network(
            gif.previewUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (_, _, _) =>
                const Icon(Icons.broken_image_outlined, size: 32),
          ),
        ),
      ),
    );
  }

  Widget _buildGiphyAttribution(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Powered by ',
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
          Image.network(
            'https://giphy.com/static/img/giphy_logo_small.png',
            height: 12,
            errorBuilder: (_, _, _) => Text(
              'GIPHY',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// GIF 选择对话框
///
/// 以底部弹出的方式显示 GIF 选择器
Future<GifPickerResult?> showGifPicker(BuildContext context) async {
  GifPickerResult? selectedGif;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.inputBarDark
            : AppColors.inputBar,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // 拖动条
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 标题栏
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Text(
                  'Choose a GIF',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // GIF 选择器
          Expanded(
            child: GifPicker(
              height: double.infinity,
              onGifSelected: (gif) {
                selectedGif = GifPickerResult(gif: gif);
                Navigator.pop(context);
              },
              onGifLongPressed: (gif) async {
                final scheduledAt = await showScheduledSendPicker(context);
                if (!context.mounted || scheduledAt == null) {
                  return;
                }
                selectedGif = GifPickerResult(
                  gif: gif,
                  scheduledAt: scheduledAt,
                );
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    ),
  );

  return selectedGif;
}
