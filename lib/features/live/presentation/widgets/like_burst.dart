import 'dart:math';

import 'package:flutter/material.dart';

/// 点赞飘心控制器：调用 [burst] 触发一颗上浮爱心。
class LikeBurstController extends ChangeNotifier {
  int _seq = 0;
  int get seq => _seq;

  void burst() {
    _seq++;
    notifyListeners();
  }
}

/// 飘心层：监听 [LikeBurstController]，每次 burst 生成一颗自上浮并淡出的爱心
/// （抖音式双击点赞）。铺在视频层之上，右下角发射。
class LikeBurstLayer extends StatefulWidget {
  const LikeBurstLayer({super.key, required this.controller});

  final LikeBurstController controller;

  @override
  State<LikeBurstLayer> createState() => _LikeBurstLayerState();
}

class _LikeBurstLayerState extends State<LikeBurstLayer> {
  final List<Widget> _hearts = [];
  final Random _rand = Random();
  int _lastSeq = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onBurst);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onBurst);
    super.dispose();
  }

  void _onBurst() {
    if (widget.controller.seq == _lastSeq) return;
    _lastSeq = widget.controller.seq;
    final key = UniqueKey();
    final hue = _rand.nextDouble();
    final drift = (_rand.nextDouble() - 0.5) * 60;
    final heart = _FloatingHeart(
      key: key,
      color: HSVColor.fromAHSV(1, hue * 360, 0.7, 1).toColor(),
      drift: drift,
      onDone: () {
        if (!mounted) return;
        setState(() => _hearts.removeWhere((w) => w.key == key));
      },
    );
    setState(() => _hearts.add(heart));
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(alignment: Alignment.bottomRight, children: _hearts),
    );
  }
}

class _FloatingHeart extends StatefulWidget {
  const _FloatingHeart({
    super.key,
    required this.color,
    required this.drift,
    required this.onDone,
  });

  final Color color;
  final double drift;
  final VoidCallback onDone;

  @override
  State<_FloatingHeart> createState() => _FloatingHeartState();
}

class _FloatingHeartState extends State<_FloatingHeart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void initState() {
    super.initState();
    _ctrl.forward();
    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onDone();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value;
        final opacity = t < 0.15 ? t / 0.15 : (1 - (t - 0.15) / 0.85);
        return Padding(
          padding: EdgeInsets.only(
            right: 24 + widget.drift * t,
            bottom: 90 + 220 * t,
          ),
          child: Opacity(
            opacity: opacity.clamp(0, 1),
            child: Transform.scale(
              scale: 0.6 + 0.6 * t,
              child: Icon(Icons.favorite, color: widget.color, size: 32),
            ),
          ),
        );
      },
    );
  }
}
