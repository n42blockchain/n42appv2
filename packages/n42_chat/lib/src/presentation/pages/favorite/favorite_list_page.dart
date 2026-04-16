import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/message_entity.dart';
import '../../../domain/repositories/message_action_repository.dart';
import '../../blocs/favorite/favorite_bloc.dart';
import '../../blocs/favorite/favorite_event.dart';
import '../../blocs/favorite/favorite_state.dart';
import '../../widgets/common/common_widgets.dart';

/// 收藏列表页面
class FavoriteListPage extends StatelessWidget {
  const FavoriteListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          FavoriteBloc(repository: GetIt.instance<IMessageActionRepository>())
            ..add(const LoadFavorites()),
      child: const _FavoriteListView(),
    );
  }
}

class _FavoriteListView extends StatelessWidget {
  const _FavoriteListView();

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.background;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: N42AppBar(
        title: S.of(context)?.commonFavorites ?? 'Favorites',
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 类型筛选
          _buildFilterBar(context, isDark),

          // 收藏列表
          Expanded(
            child: BlocBuilder<FavoriteBloc, FavoriteState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: N42Loading());
                }

                if (state.error != null) {
                  return Center(
                    child: N42EmptyState.error(
                      title: S.of(context)?.commonLoadFailed ?? 'Load failed',
                      description: state.error,
                      buttonText: S.of(context)?.commonRetry ?? 'Retry',
                      onButtonPressed: () {
                        context.read<FavoriteBloc>().add(const LoadFavorites());
                      },
                    ),
                  );
                }

                final favorites = state.filteredFavorites;
                if (favorites.isEmpty) {
                  return _buildEmptyState(context, isDark);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<FavoriteBloc>().add(const LoadFavorites());
                  },
                  child: ListView.builder(
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      return _buildFavoriteItem(
                        context,
                        favorites[index],
                        isDark,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, bool isDark) {
    final filters = [
      (null, S.of(context)?.commonAll ?? 'All'),
      ('text', S.of(context)?.favoriteText ?? 'Text'),
      ('image', S.of(context)?.commonImage ?? 'Image'),
      ('link', S.of(context)?.favoriteLinkLabel ?? 'Link'),
      ('file', S.of(context)?.commonFile ?? 'File'),
      ('video', 'Video'),
    ];

    return BlocBuilder<FavoriteBloc, FavoriteState>(
      buildWhen: (prev, curr) => prev.filterType != curr.filterType,
      builder: (context, state) {
        return Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppColors.dividerDark : AppColors.divider,
                width: 0.5,
              ),
            ),
          ),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final (type, label) = filters[index];
              final isSelected = state.filterType == type;

              return GestureDetector(
                onTap: () {
                  context.read<FavoriteBloc>().add(ChangeFavoriteFilter(type));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary),
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFavoriteItem(
    BuildContext context,
    MessageEntity favorite,
    bool isDark,
  ) {
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtitleColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onLongPress: () => _showFavoriteOptions(context, favorite),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 内容
                Text(
                  favorite.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: textColor, height: 1.4),
                ),

                const SizedBox(height: 8),

                // 来源和时间
                Row(
                  children: [
                    Icon(
                      _getTypeIcon(favorite.type),
                      size: 14,
                      color: subtitleColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      favorite.senderName,
                      style: TextStyle(fontSize: 12, color: subtitleColor),
                    ),
                    const Spacer(),
                    Text(
                      _formatTime(context, favorite.timestamp),
                      style: TextStyle(fontSize: 12, color: subtitleColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(MessageType type) {
    switch (type) {
      case MessageType.text:
        return Icons.text_fields;
      case MessageType.image:
        return Icons.image;
      case MessageType.video:
        return Icons.videocam;
      case MessageType.file:
        return Icons.insert_drive_file;
      case MessageType.voice:
      case MessageType.audio:
        return Icons.mic;
      default:
        return Icons.star;
    }
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_border,
            size: 64,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            S.of(context)?.favoriteNoFavorites ?? 'No favorites yet',
            style: TextStyle(
              fontSize: 16,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            S.of(context)?.favoriteLongPressToFavorite ??
                'Long press message to favorite',
            style: const TextStyle(fontSize: 14, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  void _showSearch(BuildContext context) {
    // 通过 BLoC 搜索
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(S.of(context)?.commonSearch ?? 'Search'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: S.of(context)?.commonSearch ?? 'Search',
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<FavoriteBloc>().add(
                  SearchFavorites(controller.text),
                );
              },
              child: Text(S.of(context)?.commonConfirm ?? 'OK'),
            ),
          ],
        );
      },
    ).whenComplete(controller.dispose);
  }

  void _showFavoriteOptions(BuildContext context, MessageEntity favorite) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: Text(S.of(context)?.commonForward ?? 'Forward'),
              onTap: () {
                Navigator.pop(sheetContext);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(
                S.of(context)?.commonDelete ?? 'Delete',
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                context.read<FavoriteBloc>().add(DeleteFavorite(favorite.id));
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(BuildContext context, DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays == 0) {
      return S.of(context)?.favoriteToday ?? 'Today';
    } else if (diff.inDays == 1) {
      return S.of(context)?.favoriteYesterday ?? 'Yesterday';
    } else if (diff.inDays < 7) {
      return S.of(context)?.favoriteDaysAgoText(diff.inDays) ??
          '${diff.inDays} days ago';
    } else {
      return S.of(context)?.favoriteDateFormat(time.month, time.day) ??
          '${time.month}/${time.day}';
    }
  }
}
