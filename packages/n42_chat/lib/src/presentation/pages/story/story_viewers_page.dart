import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/story_entity.dart';
import '../../widgets/common/n42_avatar.dart';
import '../../widgets/common/n42_empty_state.dart';

/// Story viewers page
///
/// A simple page showing who viewed a Story.
class StoryViewersPage extends StatelessWidget {
  /// Story ID
  final String storyId;

  /// List of viewers
  final List<StoryViewer> viewers;

  /// Optional callback when tapping a viewer
  final void Function(String userId)? onUserTap;

  const StoryViewersPage({
    super.key,
    required this.storyId,
    required this.viewers,
    this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n?.storyViewers ?? 'Viewers'),
            if (viewers.isNotEmpty)
              Text(
                '${viewers.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
          ],
        ),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        foregroundColor:
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        elevation: 0,
      ),
      body: viewers.isEmpty
          ? N42EmptyState(
              icon: Icons.visibility_off_outlined,
              title: l10n?.storyNoViewers ?? 'No viewers yet',
            )
          : ListView.builder(
              itemCount: viewers.length,
              itemBuilder: (context, index) {
                final viewer = viewers[index];
                return _ViewerListTile(
                  viewer: viewer,
                  onTap: onUserTap != null
                      ? () => onUserTap!(viewer.userId)
                      : null,
                  isDark: isDark,
                );
              },
            ),
    );
  }
}

/// A single viewer list tile
class _ViewerListTile extends StatelessWidget {
  final StoryViewer viewer;
  final VoidCallback? onTap;
  final bool isDark;

  const _ViewerListTile({
    required this.viewer,
    this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Avatar
              N42Avatar(
                imageUrl: viewer.avatarUrl,
                name: viewer.userName,
                size: 48,
                borderRadius: 24,
              ),
              const SizedBox(width: 12),
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      viewer.userName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTimeAgo(viewer.viewedAt),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow indicator if tappable
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Format time as "X ago" format (e.g., "2h ago")
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
