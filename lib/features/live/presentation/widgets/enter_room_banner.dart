import 'dart:async';

import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

/// 进场横幅："xxx 来了"。监听进场事件流，逐条淡入淡出显示。
class EnterRoomBanner extends StatefulWidget {
  const EnterRoomBanner({super.key, required this.enterStream});

  /// 新加入成员的 userId 流。
  final Stream<String> enterStream;

  @override
  State<EnterRoomBanner> createState() => _EnterRoomBannerState();
}

class _EnterRoomBannerState extends State<EnterRoomBanner> {
  StreamSubscription<String>? _sub;
  String? _text;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _sub = widget.enterStream.listen(_onEnter);
  }

  void _onEnter(String userId) {
    if (!mounted) return;
    setState(() => _text = '${_shortName(userId)} 来了');
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _text = null);
    });
  }

  /// 取 Matrix userId 的本地名（@local:server → local）。
  String _shortName(String userId) {
    var s = userId;
    if (s.startsWith('@')) s = s.substring(1);
    final colon = s.indexOf(':');
    if (colon > 0) s = s.substring(0, colon);
    return s.length > 16 ? '${s.substring(0, 16)}…' : s;
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.base,
      child: _text == null
          ? const SizedBox.shrink()
          : Container(
              key: ValueKey(_text),
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.space6,
                vertical: AppSpacing.space2,
              ),
              decoration: BoxDecoration(
                // 单一品牌强调：品牌蓝 → 半透，替换原紫色渐变。
                gradient: LinearGradient(
                  colors: [
                    AppColorTokens.brandOnOverlay,
                    AppColorTokens.brandOnOverlay.withValues(alpha: 0.4),
                  ],
                ),
                borderRadius: AppRadius.brMd,
              ),
              child: Text(
                _text!,
                style: AppTypography.caption.copyWith(
                  color: AppColorTokens.onOverlayPrimary,
                ),
              ),
            ),
    );
  }
}
