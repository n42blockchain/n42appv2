import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';

/// Story 进度条组件
///
/// 显示在 Story 查看器顶部，用于指示当前 Story 的播放进度：
/// - 分段显示多个 Story 的进度
/// - 当前正在播放的 Story 显示动态进度
/// - 已播放的 Story 显示完整进度
/// - 未播放的 Story 显示空白进度
///
/// 使用示例：
/// ```dart
/// StoryProgressBar(
///   storyCount: 5,
///   currentIndex: 2,
///   progress: 0.6,
///   onTap: (index) => jumpToStory(index),
/// )
/// ```
class StoryProgressBar extends StatelessWidget {
  /// Story 总数
  final int storyCount;

  /// 当前播放的 Story 索引（从 0 开始）
  final int currentIndex;

  /// 当前 Story 的播放进度（0.0 - 1.0）
  final double progress;

  /// 点击进度条跳转回调
  final void Function(int index)? onTap;

  /// 进度条高度
  final double height;

  /// 分段间距
  final double segmentGap;

  /// 进度条颜色（填充部分）
  final Color? activeColor;

  /// 进度条背景颜色（未填充部分）
  final Color? inactiveColor;

  const StoryProgressBar({
    super.key,
    required this.storyCount,
    required this.currentIndex,
    required this.progress,
    this.onTap,
    this.height = 2.5,
    this.segmentGap = 4,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    if (storyCount <= 0) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // 计算每个分段的宽度
        final totalGapWidth = segmentGap * (storyCount - 1);
        final segmentWidth =
            (constraints.maxWidth - totalGapWidth) / storyCount;

        return Row(
          children: List.generate(storyCount, (index) {
            final isLast = index == storyCount - 1;
            return Padding(
              padding: EdgeInsets.only(right: isLast ? 0 : segmentGap),
              child: GestureDetector(
                onTap: () => onTap?.call(index),
                behavior: HitTestBehavior.opaque,
                child: _ProgressSegment(
                  width: segmentWidth,
                  height: height,
                  progress: _getSegmentProgress(index),
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  /// 获取指定分段的进度值
  double _getSegmentProgress(int index) {
    if (index < currentIndex) {
      // 已播放的 Story：完整进度
      return 1.0;
    } else if (index == currentIndex) {
      // 当前正在播放的 Story：实际进度
      return progress.clamp(0.0, 1.0);
    } else {
      // 未播放的 Story：空白进度
      return 0.0;
    }
  }
}

/// 单个进度分段
class _ProgressSegment extends StatelessWidget {
  final double width;
  final double height;
  final double progress;
  final Color? activeColor;
  final Color? inactiveColor;

  const _ProgressSegment({
    required this.width,
    required this.height,
    required this.progress,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;

    final bgColor = inactiveColor ??
        (isDarkMode
            ? Colors.white.withValues(alpha: 0.3)
            : Colors.black.withValues(alpha: 0.2));

    final fgColor = activeColor ?? Colors.white;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Align(
        alignment: Alignment.centerLeft,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.linear,
          width: width * progress,
          height: height,
          decoration: BoxDecoration(
            color: fgColor,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}

/// 带动画的 Story 进度条
///
/// 自动播放进度动画，适用于自动轮播场景
class AnimatedStoryProgressBar extends StatefulWidget {
  /// Story 总数
  final int storyCount;

  /// 当前播放的 Story 索引
  final int currentIndex;

  /// 每个 Story 的播放时长
  final Duration storyDuration;

  /// 是否暂停播放
  final bool isPaused;

  /// 当前 Story 播放完成回调
  final VoidCallback? onStoryComplete;

  /// 点击进度条跳转回调
  final void Function(int index)? onTap;

  /// 进度条高度
  final double height;

  /// 分段间距
  final double segmentGap;

  const AnimatedStoryProgressBar({
    super.key,
    required this.storyCount,
    required this.currentIndex,
    this.storyDuration = const Duration(seconds: 5),
    this.isPaused = false,
    this.onStoryComplete,
    this.onTap,
    this.height = 2.5,
    this.segmentGap = 4,
  });

  @override
  State<AnimatedStoryProgressBar> createState() =>
      _AnimatedStoryProgressBarState();
}

class _AnimatedStoryProgressBarState extends State<AnimatedStoryProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.storyDuration,
    );

    _controller.addStatusListener(_onAnimationStatus);

    if (!widget.isPaused) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedStoryProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 处理暂停/恢复
    if (widget.isPaused != oldWidget.isPaused) {
      if (widget.isPaused) {
        _controller.stop();
      } else {
        _controller.forward();
      }
    }

    // 处理索引变化（切换到新的 Story）
    if (widget.currentIndex != oldWidget.currentIndex) {
      _controller.reset();
      if (!widget.isPaused) {
        _controller.forward();
      }
    }

    // 处理时长变化
    if (widget.storyDuration != oldWidget.storyDuration) {
      _controller.duration = widget.storyDuration;
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onAnimationStatus);
    _controller.dispose();
    super.dispose();
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onStoryComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return StoryProgressBar(
          storyCount: widget.storyCount,
          currentIndex: widget.currentIndex,
          progress: _controller.value,
          onTap: widget.onTap,
          height: widget.height,
          segmentGap: widget.segmentGap,
        );
      },
    );
  }
}
