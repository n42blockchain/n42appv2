import 'package:flutter/material.dart';

/// 淡入动画组件
class FadeInAnimation extends StatefulWidget {
  /// 子组件
  final Widget child;

  /// 动画时长
  final Duration duration;

  /// 延迟
  final Duration delay;

  /// 曲线
  final Curve curve;

  /// 是否自动播放
  final bool autoPlay;

  const FadeInAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.delay = Duration.zero,
    this.curve = Curves.easeOut,
    this.autoPlay = true,
  });

  @override
  State<FadeInAnimation> createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<FadeInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    if (widget.autoPlay) {
      if (widget.delay == Duration.zero) {
        _controller.forward();
      } else {
        Future.delayed(widget.delay, () {
          if (mounted) _controller.forward();
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

/// 淡入 + 上滑动画组件
class FadeSlideAnimation extends StatefulWidget {
  /// 子组件
  final Widget child;

  /// 动画时长
  final Duration duration;

  /// 延迟
  final Duration delay;

  /// 曲线
  final Curve curve;

  /// 滑动方向
  final SlideDirection direction;

  /// 滑动距离
  final double offset;

  /// 是否自动播放
  final bool autoPlay;

  const FadeSlideAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.delay = Duration.zero,
    this.curve = Curves.easeOut,
    this.direction = SlideDirection.up,
    this.offset = 20,
    this.autoPlay = true,
  });

  @override
  State<FadeSlideAnimation> createState() => _FadeSlideAnimationState();
}

class _FadeSlideAnimationState extends State<FadeSlideAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    final beginOffset = _getBeginOffset();
    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    if (widget.autoPlay) {
      if (widget.delay == Duration.zero) {
        _controller.forward();
      } else {
        Future.delayed(widget.delay, () {
          if (mounted) _controller.forward();
        });
      }
    }
  }

  Offset _getBeginOffset() {
    switch (widget.direction) {
      case SlideDirection.up:
        return Offset(0, widget.offset / 100);
      case SlideDirection.down:
        return Offset(0, -widget.offset / 100);
      case SlideDirection.left:
        return Offset(widget.offset / 100, 0);
      case SlideDirection.right:
        return Offset(-widget.offset / 100, 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

/// 滑动方向
enum SlideDirection {
  up,
  down,
  left,
  right,
}

/// 列表项动画包装器
class ListItemAnimation extends StatelessWidget {
  /// 子组件
  final Widget child;

  /// 索引（用于计算延迟）
  final int index;

  /// 基础延迟
  final Duration baseDelay;

  /// 每项延迟增量
  final Duration delayIncrement;

  /// 动画时长
  final Duration duration;

  const ListItemAnimation({
    super.key,
    required this.child,
    required this.index,
    this.baseDelay = Duration.zero,
    this.delayIncrement = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return FadeSlideAnimation(
      duration: duration,
      delay: baseDelay + (delayIncrement * index),
      direction: SlideDirection.up,
      offset: 15,
      child: child,
    );
  }
}

