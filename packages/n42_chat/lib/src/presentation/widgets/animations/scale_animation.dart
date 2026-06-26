import 'package:flutter/material.dart';

/// 缩放动画组件
class ScaleAnimation extends StatefulWidget {
  /// 子组件
  final Widget child;

  /// 动画时长
  final Duration duration;

  /// 延迟
  final Duration delay;

  /// 曲线
  final Curve curve;

  /// 起始缩放比例
  final double beginScale;

  /// 是否自动播放
  final bool autoPlay;

  const ScaleAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    this.delay = Duration.zero,
    this.curve = Curves.easeOut,
    this.beginScale = 0.8,
    this.autoPlay = true,
  });

  @override
  State<ScaleAnimation> createState() => _ScaleAnimationState();
}

class _ScaleAnimationState extends State<ScaleAnimation>
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

    _animation = Tween<double>(
      begin: widget.beginScale,
      end: 1.0,
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}

/// 弹性动画组件
class BounceAnimation extends StatefulWidget {
  /// 子组件
  final Widget child;

  /// 动画时长
  final Duration duration;

  /// 延迟
  final Duration delay;

  /// 是否自动播放
  final bool autoPlay;

  const BounceAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.delay = Duration.zero,
    this.autoPlay = true,
  });

  @override
  State<BounceAnimation> createState() => _BounceAnimationState();
}

class _BounceAnimationState extends State<BounceAnimation>
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

    _animation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.1),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 0.95),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.0),
        weight: 20,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}

/// 按下缩放效果（按钮反馈）
class PressableScale extends StatefulWidget {
  /// 子组件
  final Widget child;

  /// 点击回调
  final VoidCallback? onPressed;

  /// 长按回调
  final VoidCallback? onLongPress;

  /// 按下时的缩放比例
  final double pressedScale;

  /// 动画时长
  final Duration duration;

  const PressableScale({
    super.key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.pressedScale = 0.95,
    this.duration = const Duration(milliseconds: 100),
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale>
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

    _animation = Tween<double>(
      begin: 1.0,
      end: widget.pressedScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onPressed,
      onLongPress: widget.onLongPress,
      child: ScaleTransition(
        scale: _animation,
        child: widget.child,
      ),
    );
  }
}

/// 心跳动画（用于强调）
class HeartbeatAnimation extends StatefulWidget {
  /// 子组件
  final Widget child;

  /// 是否播放
  final bool isAnimating;

  /// 缩放范围
  final double scaleRange;

  /// 动画时长
  final Duration duration;

  const HeartbeatAnimation({
    super.key,
    required this.child,
    this.isAnimating = false,
    this.scaleRange = 0.1,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<HeartbeatAnimation> createState() => _HeartbeatAnimationState();
}

class _HeartbeatAnimationState extends State<HeartbeatAnimation>
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

    _animation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0 + widget.scaleRange),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0 + widget.scaleRange, end: 1.0),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0 + widget.scaleRange * 0.5),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0 + widget.scaleRange * 0.5, end: 1.0),
        weight: 25,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(HeartbeatAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating != oldWidget.isAnimating) {
      if (widget.isAnimating) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.reset();
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
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}

