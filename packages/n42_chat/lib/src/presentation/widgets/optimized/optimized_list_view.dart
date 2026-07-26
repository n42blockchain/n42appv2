import 'package:flutter/material.dart';
// ScrollCacheExtent（scrollCacheExtent 的参数类型，Flutter 3.44 起取代
// 裸 double 的 cacheExtent）由 rendering 库导出，material 未转出。
import 'package:flutter/rendering.dart';

/// 优化的消息列表视图
///
/// 针对聊天消息列表进行了性能优化
class OptimizedMessageListView extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final ScrollController? controller;
  final bool reverse;
  final EdgeInsetsGeometry? padding;
  final void Function()? onLoadMore;
  final bool hasMore;
  final Widget? loadingIndicator;
  final double? cacheExtent;

  const OptimizedMessageListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.reverse = true,
    this.padding,
    this.onLoadMore,
    this.hasMore = false,
    this.loadingIndicator,
    this.cacheExtent,
  });

  @override
  State<OptimizedMessageListView> createState() =>
      _OptimizedMessageListViewState();
}

class _OptimizedMessageListViewState extends State<OptimizedMessageListView> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (!widget.hasMore || _isLoadingMore) return;

    // 对于反向列表，检查是否滚动到顶部
    if (widget.reverse) {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    } else {
      // 对于正常列表，检查是否滚动到底部
      if (_scrollController.position.pixels <=
          _scrollController.position.minScrollExtent + 200) {
        _loadMore();
      }
    }
  }

  void _loadMore() {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    widget.onLoadMore?.call();

    // 延迟重置加载状态
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      reverse: widget.reverse,
      scrollCacheExtent: ScrollCacheExtent.pixels(widget.cacheExtent ?? 500),
      slivers: [
        SliverPadding(
          padding: widget.padding ?? EdgeInsets.zero,
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // 如果有更多内容且正在加载，显示加载指示器
                if (widget.hasMore && index == widget.itemCount) {
                  return widget.loadingIndicator ??
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                }

                return _OptimizedListItem(
                  key: ValueKey<int>(index),
                  builder: () => widget.itemBuilder(context, index),
                );
              },
              childCount: widget.itemCount + (widget.hasMore ? 1 : 0),
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: true,
            ),
          ),
        ),
      ],
    );
  }
}

/// 优化的列表项
///
/// 使用 RepaintBoundary 隔离重绘区域
class _OptimizedListItem extends StatelessWidget {
  final Widget Function() builder;

  const _OptimizedListItem({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: builder());
  }
}

/// 虚拟化列表视图
///
/// 只渲染可见区域的项目
class VirtualizedListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final double estimatedItemHeight;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;

  const VirtualizedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.estimatedItemHeight = 60,
    this.controller,
    this.padding,
  });

  @override
  State<VirtualizedListView<T>> createState() => _VirtualizedListViewState<T>();
}

class _VirtualizedListViewState<T> extends State<VirtualizedListView<T>> {
  late ScrollController _scrollController;
  final Map<int, double> _itemHeights = {};

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        return _MeasuredItem(
          onMeasured: (height) {
            if (_itemHeights[index] != height) {
              _itemHeights[index] = height;
            }
          },
          child: widget.itemBuilder(context, widget.items[index], index),
        );
      },
    );
  }
}

/// 测量高度的组件
class _MeasuredItem extends StatefulWidget {
  final Widget child;
  final void Function(double height) onMeasured;

  const _MeasuredItem({required this.child, required this.onMeasured});

  @override
  State<_MeasuredItem> createState() => _MeasuredItemState();
}

class _MeasuredItemState extends State<_MeasuredItem> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_measureHeight);
  }

  void _measureHeight(_) {
    if (!mounted) return;
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      widget.onMeasured(renderBox.size.height);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// 平滑滚动到指定位置
extension SmoothScrollExtension on ScrollController {
  /// 平滑滚动到底部
  Future<void> smoothScrollToBottom({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOutCubic,
  }) async {
    if (!hasClients) return;

    await animateTo(0, duration: duration, curve: curve);
  }

  /// 平滑滚动到顶部
  Future<void> smoothScrollToTop({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOutCubic,
  }) async {
    if (!hasClients) return;

    await animateTo(position.maxScrollExtent, duration: duration, curve: curve);
  }

  /// 检查是否在底部附近
  bool isNearBottom({double threshold = 100}) {
    if (!hasClients) return false;
    return position.pixels <= threshold;
  }

  /// 检查是否在顶部附近
  bool isNearTop({double threshold = 100}) {
    if (!hasClients) return false;
    return position.pixels >= position.maxScrollExtent - threshold;
  }
}
