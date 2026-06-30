import 'dart:async';

import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

import '../../services/live_chat_service.dart';
import 'gift_catalog.dart';

/// 礼物动画层：监听礼物事件流（[LiveEvent] kind=='gift'），每收到一份礼物
/// 就在屏幕上飘一个放大上浮的 emoji，并在左下角滚动一条"X 送出 🌹玫瑰"提示。
///
/// 纯视觉广播（无真实价值），铺在视频层之上、不拦截手势。
class GiftOverlay extends StatefulWidget {
  const GiftOverlay({super.key, required this.giftStream});

  /// 新到达的直播事件流（仅 gift 类型会被消费）。
  final Stream<LiveEvent> giftStream;

  @override
  State<GiftOverlay> createState() => _GiftOverlayState();
}

class _GiftOverlayState extends State<GiftOverlay> {
  StreamSubscription<LiveEvent>? _sub;
  final List<Widget> _flights = [];

  /// 左下角提示：最近一条"X 送出 Y"。
  String? _banner;
  Timer? _bannerTimer;

  /// 同时在飞的礼物上限，防刷屏导致动画堆积。
  static const int _maxConcurrent = 12;

  @override
  void initState() {
    super.initState();
    _sub = widget.giftStream.listen(_onGift);
  }

  void _onGift(LiveEvent e) {
    if (!mounted || e.kind != 'gift') return;
    final gift = giftById(e.data['g'] as String? ?? 'gift');

    final key = UniqueKey();
    final flight = _GiftFlight(
      key: key,
      emoji: gift.emoji,
      onDone: () {
        if (!mounted) return;
        setState(() => _flights.removeWhere((w) => w.key == key));
      },
    );
    setState(() {
      _flights.add(flight);
      if (_flights.length > _maxConcurrent) _flights.removeAt(0);
      _banner = '${e.senderName} 送出 ${gift.emoji}${gift.label}';
    });
    _bannerTimer?.cancel();
    _bannerTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _banner = null);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _bannerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          // 飘飞的礼物 emoji（屏幕下方偏左升起）。
          Positioned.fill(
            child: Stack(alignment: Alignment.bottomLeft, children: _flights),
          ),
          // 左下角"X 送出 Y"提示。
          Positioned(
            left: AppSpacing.space6,
            bottom: 260,
            child: AnimatedSwitcher(
              duration: AppMotion.base,
              child: _banner == null
                  ? const SizedBox.shrink()
                  : Container(
                      key: ValueKey(_banner),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.space4,
                        vertical: AppSpacing.space2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColorTokens.overlay,
                        borderRadius: AppRadius.brPill,
                      ),
                      child: Text(
                        _banner!,
                        style: AppTypography.captionSm.copyWith(
                          color: AppColorTokens.onOverlayPrimary,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 单个礼物的飞行动画：从底部偏左升起、先放大后缩、末段淡出。
class _GiftFlight extends StatefulWidget {
  const _GiftFlight({
    super.key,
    required this.emoji,
    required this.onDone,
  });

  final String emoji;
  final VoidCallback onDone;

  @override
  State<_GiftFlight> createState() => _GiftFlightState();
}

class _GiftFlightState extends State<_GiftFlight>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
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
        // 末 30% 淡出。
        final opacity = t < 0.7 ? 1.0 : (1 - (t - 0.7) / 0.3);
        // 入场快速放大到 1.4，再回落到 1.0。
        final scale = t < 0.2 ? (0.4 + 3.0 * t) : (1.4 - 0.4 * ((t - 0.2) / 0.8));
        return Padding(
          padding: EdgeInsets.only(left: AppSpacing.space12, bottom: 120 + 360 * t),
          child: Opacity(
            opacity: opacity.clamp(0, 1),
            child: Transform.scale(
              scale: scale,
              child: Text(widget.emoji, style: const TextStyle(fontSize: 44)),
            ),
          ),
        );
      },
    );
  }
}
