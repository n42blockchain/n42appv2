import 'package:flutter/material.dart';

import 'package:n42_wallet/core/design_system/design_system.dart';

/// 直播间在线 / 观看人数徽章。
///
/// 永远浮在视频叠层上（强制深色语境），故用**固定叠层色**
/// （`overlay` / `onOverlayPrimary` / `onOverlaySecondary`），
/// 不用随主题的 [AppBadge]（见 `docs/DESIGN_SYSTEM.md` §2.7 边界）。
/// 收敛原 `live_top_bar` 与 `go_live_page` 各一份的 `_OnlineBadge`。
class OnlineBadge extends StatelessWidget {
  const OnlineBadge({super.key, required this.count, this.margin});

  final int count;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space6,
        vertical: AppSpacing.space2,
      ),
      decoration: const BoxDecoration(
        color: AppColorTokens.overlay,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.remove_red_eye,
            color: AppColorTokens.onOverlaySecondary,
            size: 14,
          ),
          SizedBox(width: AppSpacing.space2),
          Text(
            '$count',
            style: AppTypography.caption.copyWith(
              color: AppColorTokens.onOverlayPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
