// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// 优化的列表组件
///
/// 提供自动回收、预加载等优化
class OptimizedListView extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final double? itemExtent;
  final double? cacheExtent;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;

  const OptimizedListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.itemExtent,
    this.cacheExtent,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemExtent: itemExtent,
      // 增加缓存区域，减少快速滚动时的抖动
      cacheExtent: cacheExtent ?? 500.0,
      itemCount: itemCount,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
      itemBuilder: (context, index) {
        // 包装 RepaintBoundary 减少重绘范围
        if (addRepaintBoundaries) {
          return RepaintBoundary(
            child: itemBuilder(context, index),
          );
        }
        return itemBuilder(context, index);
      },
    );
  }
}

/// 优化的网格组件
class OptimizedGridView extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final SliverGridDelegate gridDelegate;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final double? cacheExtent;
  final bool addRepaintBoundaries;

  const OptimizedGridView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.gridDelegate,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.cacheExtent,
    this.addRepaintBoundaries = true,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      cacheExtent: cacheExtent ?? 500.0,
      gridDelegate: gridDelegate,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (addRepaintBoundaries) {
          return RepaintBoundary(
            child: itemBuilder(context, index),
          );
        }
        return itemBuilder(context, index);
      },
    );
  }
}

/// 优化的图片组件
///
/// 自动处理缓存、占位符和错误状态
class OptimizedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final int? memCacheWidth;
  final int? memCacheHeight;

  const OptimizedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.memCacheWidth,
    this.memCacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      // 内存缓存优化
      cacheWidth: memCacheWidth ?? (width != null ? (width! * 2).toInt() : null),
      cacheHeight: memCacheHeight ?? (height != null ? (height! * 2).toInt() : null),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? _buildPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? _buildErrorWidget();
      },
      // 使用低质量过滤器提升性能
      filterQuality: FilterQuality.low,
    );

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    // 使用 RepaintBoundary 隔离重绘
    return RepaintBoundary(child: image);
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Icon(Icons.broken_image, color: Colors.grey),
    );
  }
}

/// 懒加载组件
///
/// 只在进入视口时构建子组件
class LazyLoadWidget extends StatefulWidget {
  final Widget child;
  final Widget? placeholder;
  final Duration delay;

  const LazyLoadWidget({
    super.key,
    required this.child,
    this.placeholder,
    this.delay = Duration.zero,
  });

  @override
  State<LazyLoadWidget> createState() => _LazyLoadWidgetState();
}

class _LazyLoadWidgetState extends State<LazyLoadWidget> {
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _isLoaded = true);
      });
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) setState(() => _isLoaded = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded) {
      return widget.child;
    }
    return widget.placeholder ?? const SizedBox.shrink();
  }
}

/// 防抖按钮
///
/// 防止快速重复点击
class DebouncedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Duration debounceDuration;
  final ButtonStyle? style;

  const DebouncedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.style,
  });

  @override
  State<DebouncedButton> createState() => _DebouncedButtonState();
}

class _DebouncedButtonState extends State<DebouncedButton> {
  bool _isProcessing = false;

  void _handlePress() async {
    if (_isProcessing || widget.onPressed == null) return;
    
    setState(() => _isProcessing = true);
    
    try {
      widget.onPressed!();
    } finally {
      await Future.delayed(widget.debounceDuration);
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isProcessing ? null : _handlePress,
      style: widget.style,
      child: widget.child,
    );
  }
}

/// 选择性重建组件
///
/// 只在特定条件下重建
class SelectiveBuilder<T> extends StatefulWidget {
  final T value;
  final Widget Function(BuildContext context, T value) builder;
  final bool Function(T previous, T current)? shouldRebuild;

  const SelectiveBuilder({
    super.key,
    required this.value,
    required this.builder,
    this.shouldRebuild,
  });

  @override
  State<SelectiveBuilder<T>> createState() => _SelectiveBuilderState<T>();
}

class _SelectiveBuilderState<T> extends State<SelectiveBuilder<T>> {
  late T _previousValue;
  Widget? _cachedWidget;

  @override
  void initState() {
    super.initState();
    _previousValue = widget.value;
  }

  @override
  void didUpdateWidget(SelectiveBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    final shouldRebuild = widget.shouldRebuild?.call(_previousValue, widget.value) 
        ?? (_previousValue != widget.value);
    
    if (shouldRebuild) {
      _previousValue = widget.value;
      _cachedWidget = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    _cachedWidget ??= widget.builder(context, widget.value);
    return _cachedWidget!;
  }
}

/// 帧调度器
///
/// 将重计算分散到多帧执行
class FrameScheduler {
  static final List<VoidCallback> _pendingTasks = [];
  static bool _isProcessing = false;

  /// 调度任务在下一帧执行
  static void scheduleTask(VoidCallback task) {
    _pendingTasks.add(task);
    _processNextFrame();
  }

  /// 调度任务在空闲时执行
  static void scheduleIdleTask(VoidCallback task) {
    WidgetsBinding.instance.scheduleFrameCallback((_) {
      task();
    });
  }

  static void _processNextFrame() {
    if (_isProcessing || _pendingTasks.isEmpty) return;
    _isProcessing = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pendingTasks.isNotEmpty) {
        final task = _pendingTasks.removeAt(0);
        task();
      }
      _isProcessing = false;
      
      if (_pendingTasks.isNotEmpty) {
        _processNextFrame();
      }
    });
  }

  /// 清除所有待处理任务
  static void clearTasks() {
    _pendingTasks.clear();
    _isProcessing = false;
  }
}

