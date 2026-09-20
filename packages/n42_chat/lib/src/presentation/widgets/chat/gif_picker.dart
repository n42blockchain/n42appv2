import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/services/giphy_service.dart';
import '../../../core/services/gif_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/a11y_l10n.dart';
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
  GifService? _gifService;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<GiphyGif> _gifs = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  String _currentQuery = '';
  Timer? _debounceTimer;
  bool _serviceAvailable = false;
  bool _hasError = false;
  int _generation = 0;
  String? _nextCursor;
  String? _provider;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    _initializeService();
  }

  void _initializeService() {
    try {
      _gifService = GetIt.instance.isRegistered<GifService>()
          ? GetIt.instance<GifService>()
          : null;
      _serviceAvailable = _gifService?.isAvailable ?? false;
    } catch (_) {
      _gifService = null;
      _serviceAvailable = false;
    }
    if (_serviceAvailable) unawaited(_loadPage(reset: true));
  }

  @override
  void dispose() {
    _generation++;
    _debounceTimer?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasError &&
        _hasMore &&
        _scrollController.hasClients &&
        _scrollController.position.extentAfter < 200) {
      unawaited(_loadPage());
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query == _currentQuery) {
      setState(() {});
      return;
    }
    _debounceTimer?.cancel();
    _currentQuery = query;
    // Invalidate before the debounce: an older response must not flash back.
    _generation++;
    setState(() {
      _gifs = [];
      _isLoading = true;
      _hasError = false;
    });
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      unawaited(_loadPage(reset: true));
    });
  }

  Future<void> _loadPage({bool reset = false}) async {
    final service = _gifService;
    if (!_serviceAvailable || service == null || (_isLoading && !reset)) return;
    if (reset) {
      _generation++;
      _gifs = [];
      _offset = 0;
      _nextCursor = null;
      _provider = null;
      _hasMore = true;
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
    }
    final generation = _generation;
    final query = _currentQuery;
    final cursor = _nextCursor;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final result = query.isEmpty
          ? await service
                .getTrendingGifs(offset: _offset, cursor: cursor)
                .timeout(const Duration(seconds: 20))
          : await service
                .searchGifs(
                  query: query,
                  offset: _offset,
                  cursor: cursor,
                  lang:
                      Localizations.maybeLocaleOf(context)?.languageCode ??
                      'en',
                )
                .timeout(const Duration(seconds: 20));
      if (!mounted || generation != _generation) return;
      setState(() {
        _isLoading = false;
        _hasError = result.isError;
        if (result.isError) return;
        _provider = result.provider;
        final ids = _gifs.map((gif) => gif.id).toSet();
        final fresh = result.gifs.where((gif) => ids.add(gif.id)).toList();
        _gifs.addAll(fresh);
        _offset = result.offset + result.gifs.length;
        _nextCursor = result.nextCursor;
        _hasMore =
            result.hasMore &&
            fresh.isNotEmpty &&
            (cursor == null || result.nextCursor != cursor);
      });
    } catch (_) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _retry() {
    if (!_serviceAvailable) {
      setState(_initializeService);
    } else {
      unawaited(_loadPage(reset: _gifs.isEmpty));
    }
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
          top: BorderSide(color: context.dividerColor, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // 搜索栏
            _buildSearchBar(),

            // GIF 网格
            Expanded(child: _buildGifGrid(isDark)),

            if (_provider != null)
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  'Powered by $_provider',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          controller: _searchController,
          enabled: _serviceAvailable,
          style: TextStyle(fontSize: 14, color: context.textPrimary),
          decoration: InputDecoration(
            hintText: '${S.of(context)?.commonSearch ?? 'Search'} GIF',
            hintStyle: TextStyle(fontSize: 14, color: context.textTertiary),
            prefixIcon: Icon(
              Icons.search,
              size: 20,
              color: context.textSecondary,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    tooltip: A11yL10n.of(context).clearSearch,
                    onPressed: () {
                      _searchController.clear();
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
    if (!_serviceAvailable || (_gifs.isEmpty && _hasError)) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.gif_box_outlined, size: 36),
              const SizedBox(height: 8),
              Text(
                _serviceAvailable
                    ? (S.of(context)?.commonLoadFailed ?? 'Failed to load')
                    : 'GIF · ${S.of(context)?.aiAssistantUnavailable ?? 'Unavailable'}',
                textAlign: TextAlign.center,
              ),
              TextButton.icon(
                onPressed: _retry,
                icon: const Icon(Icons.refresh),
                label: Text(S.of(context)?.commonRetry ?? 'Retry'),
              ),
            ],
          ),
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
            const Icon(
              Icons.gif_box_outlined,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 8),
            Text(
              S.of(context)?.searchNoResults ?? 'No Results',
              style: const TextStyle(color: AppColors.textTertiary),
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
      itemCount: _gifs.length + (_hasMore || _hasError ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _gifs.length) {
          if (_hasError) {
            return TextButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh),
              label: Text(S.of(context)?.commonRetry ?? 'Retry'),
            );
          }
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
          color: AppColors.placeholderOf(isDark),
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
        color: context.inputBarColor,
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
              color: AppColors.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 标题栏
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Text(
                  'GIF',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: S.of(context)?.commonClose ?? 'Close',
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
