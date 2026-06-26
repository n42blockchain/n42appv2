import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/live/presentation/widgets/online_badge.dart';

/// 直播间顶部栏：主播头像 + 标题 + 关注 + 在线人数 + 关闭。
class LiveTopBar extends StatelessWidget {
  const LiveTopBar({
    super.key,
    required this.title,
    required this.onlineCount,
    required this.onClose,
    this.onFollow,
    this.showFollow = true,
  });

  final String title;
  final int onlineCount;
  final VoidCallback onClose;
  final VoidCallback? onFollow;
  final bool showFollow;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space2,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.space2,
                AppSpacing.space2,
                AppSpacing.space4,
                AppSpacing.space2,
              ),
              decoration: const BoxDecoration(
                color: AppColorTokens.overlay,
                borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColorTokens.overlayStrong,
                    child: Icon(
                      Icons.person,
                      size: 16,
                      color: AppColorTokens.onOverlayPrimary,
                    ),
                  ),
                  SizedBox(width: AppSpacing.space2),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 120),
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: AppColorTokens.onOverlayPrimary,
                      ),
                    ),
                  ),
                  if (showFollow) ...[
                    SizedBox(width: AppSpacing.space2),
                    _FollowButton(onFollow: onFollow),
                  ],
                ],
              ),
            ),
            const Spacer(),
            OnlineBadge(count: onlineCount),
            IconButton(
              icon: const Icon(
                Icons.close,
                color: AppColorTokens.onOverlayPrimary,
              ),
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}

/// 关注按钮（品牌底 + 按压态）。
class _FollowButton extends StatelessWidget {
  const _FollowButton({this.onFollow});
  final VoidCallback? onFollow;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.primary,
      borderRadius: AppRadius.brPill,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap:
            onFollow ??
            () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.of(context).g_live_follow_wip)),
            ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space2,
          ),
          child: Text(
            S.of(context).g_live_follow,
            style: AppTypography.captionSm.copyWith(
              color: AppColorTokens.onOverlayPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

