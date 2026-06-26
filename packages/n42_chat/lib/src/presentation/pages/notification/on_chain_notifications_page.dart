import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/on_chain_notification_entity.dart';
import '../../blocs/on_chain_notification/on_chain_notification_bloc.dart';
import '../../blocs/on_chain_notification/on_chain_notification_event.dart';
import '../../blocs/on_chain_notification/on_chain_notification_state.dart';
import '../../widgets/common/common_widgets.dart';

/// 链上事件通知列表页面
///
/// 展示来自 Push Protocol 的链上事件通知，支持分页、刷新和已读管理。
/// 需要在父级注入 [OnChainNotificationBloc]。
class OnChainNotificationsPage extends StatefulWidget {
  const OnChainNotificationsPage({super.key});

  @override
  State<OnChainNotificationsPage> createState() =>
      _OnChainNotificationsPageState();
}

class _OnChainNotificationsPageState extends State<OnChainNotificationsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<OnChainNotificationBloc>().add(const LoadOnChainNotifications());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context
          .read<OnChainNotificationBloc>()
          .add(const LoadMoreOnChainNotifications());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final l10n = S.of(context);

    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: N42AppBar(
        title: l10n?.onChainNotificationsTitle ?? 'On-chain Events',
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
        actions: [
          BlocBuilder<OnChainNotificationBloc, OnChainNotificationState>(
            buildWhen: (prev, curr) => prev.unreadCount != curr.unreadCount,
            builder: (context, state) {
              if (state.unreadCount == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => context
                    .read<OnChainNotificationBloc>()
                    .add(const MarkAllOnChainNotificationsRead()),
                child: Text(
                  l10n?.onChainMarkAllRead ?? 'Mark all read',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<OnChainNotificationBloc, OnChainNotificationState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == OnChainNotificationStatus.failure &&
              state.notifications.isEmpty) {
            return _buildError(context, state.errorMessage, isDark);
          }

          if (state.notifications.isEmpty) {
            return _buildEmpty(context, isDark);
          }

          return RefreshIndicator(
            onRefresh: () async {
              context
                  .read<OnChainNotificationBloc>()
                  .add(const RefreshOnChainNotifications());
            },
            child: ListView.separated(
              controller: _scrollController,
              itemCount: state.notifications.length +
                  (state.hasMore || state.isLoadingMore ? 1 : 0),
              separatorBuilder: (context, index) => Divider(
                height: 1,
                indent: 72,
                color: context.dividerColor,
              ),
              itemBuilder: (context, index) {
                if (index == state.notifications.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return _OnChainNotificationItem(
                  notification: state.notifications[index],
                  isDark: isDark,
                  onTap: () {
                    final notif = state.notifications[index];
                    if (!notif.isRead) {
                      context
                          .read<OnChainNotificationBloc>()
                          .add(MarkOnChainNotificationRead(notif.id));
                    }
                    if (notif.ctaUrl != null) {
                      final uri = Uri.tryParse(notif.ctaUrl!);
                      if (uri != null &&
                          (uri.scheme == 'https' || uri.scheme == 'http')) {
                        launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, bool isDark) {
    final l10n = S.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 64,
            color: context.dividerColor,
          ),
          const SizedBox(height: 16),
          Text(
            l10n?.onChainNoNotifications ?? 'No on-chain events yet',
            style: TextStyle(
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n?.onChainNoNotificationsDesc ??
                'Events from subscribed channels will appear here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String? message, bool isDark) {
    final l10n = S.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 64,
            color: context.dividerColor,
          ),
          const SizedBox(height: 16),
          Text(
            message ?? (l10n?.commonLoadFailed ?? 'Failed to load'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => context
                .read<OnChainNotificationBloc>()
                .add(const LoadOnChainNotifications()),
            child: Text(l10n?.commonRetry ?? 'Retry'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 单条通知列表项
// ─────────────────────────────────────────────

class _OnChainNotificationItem extends StatelessWidget {
  final OnChainNotificationEntity notification;
  final bool isDark;
  final VoidCallback onTap;

  const _OnChainNotificationItem({
    required this.notification,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unread = !notification.isRead;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: unread
            ? (isDark
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.primary.withValues(alpha: 0.04))
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 频道图标 / 类型图标
            _buildTypeIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 频道名 + 时间
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.channelName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: unread
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: context.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTime(notification.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // 标题
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          unread ? FontWeight.w600 : FontWeight.w500,
                      color: context.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // 正文
                  if (notification.body.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  // CTA 链接标识
                  if (notification.ctaUrl != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.open_in_new,
                          size: 12,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          S.of(context)?.onChainViewDetails ?? 'View details',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // 未读小圆点
            if (unread) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypeIcon() {
    final (icon, color) = switch (notification.type) {
      OnChainNotificationType.transfer => (Icons.swap_horiz, Colors.blue),
      OnChainNotificationType.nft =>
        (Icons.image_outlined, Colors.deepPurple),
      OnChainNotificationType.defi =>
        (Icons.account_balance_outlined, Colors.teal),
      OnChainNotificationType.governance =>
        (Icons.how_to_vote_outlined, Colors.orange),
      OnChainNotificationType.security =>
        (Icons.security_outlined, Colors.red),
      OnChainNotificationType.general =>
        (Icons.notifications_outlined, Colors.grey),
    };

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 22, color: color),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.month}/${time.day}';
  }
}
