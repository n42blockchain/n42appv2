import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

import '../../services/live_chat_service.dart';
import 'gift_catalog.dart';
import 'gift_providers.dart';

/// 礼物动画层：订阅 [LiveGiftEconomy.watchNewValidGifts]（仅播放**通过确定性
/// 重放校验**的礼物——伪造/超额送礼不会出现在此流），每收到一份礼物就在屏幕上
/// 飘一个放大上浮的 emoji，并在左下角滚动一条"X 送出 🌹玫瑰"提示。
///
/// 铺在视频层之上、不拦截手势。
class GiftOverlay extends ConsumerStatefulWidget {
  const GiftOverlay({super.key, required this.roomId});

  final String roomId;

  @override
  ConsumerState<GiftOverlay> createState() => _GiftOverlayState();
}

class _GiftOverlayState extends ConsumerState<GiftOverlay> {
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
    _sub = ref
        .read(giftEconomyProvider)
        .watchNewValidGifts(widget.roomId)
        .listen(_onGift);
  }

  void _onGift(LiveEvent e) {
    if (!mounted) return;
    // 理论不可达：watchNewValidGifts 已在重放层过滤掉未知礼物，这里防御性
    // 兜底，避免万一出现空值时崩溃。
    final gift = giftById(e.data['g'] as String? ?? '');
    if (gift == null) return;

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
  const _GiftFlight({super.key, required this.emoji, required this.onDone});

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
        final scale = t < 0.2
            ? (0.4 + 3.0 * t)
            : (1.4 - 0.4 * ((t - 0.2) / 0.8));
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.space12,
            bottom: 120 + 360 * t,
          ),
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
