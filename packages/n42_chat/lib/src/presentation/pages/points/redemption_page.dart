import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/points/redemption_item.dart';
import '../../blocs/points/points_bloc.dart';
import '../../blocs/points/points_event.dart';
import '../../blocs/points/points_state.dart';

/// Redemption store page where users spend points on items.
///
/// Features:
/// - Grid display of redemption items
/// - Available points shown at top
/// - Redeem button with stock / affordability checks
/// - Confirmation dialog before redeeming
class RedemptionPage extends StatefulWidget {
  final String userId;
  final String roomId;

  const RedemptionPage({
    super.key,
    required this.userId,
    required this.roomId,
  });

  @override
  State<RedemptionPage> createState() => _RedemptionPageState();
}

class _RedemptionPageState extends State<RedemptionPage> {
  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() {
    final bloc = context.read<PointsBloc>();
    bloc.add(PointsLoadRedemptionItems(roomId: widget.roomId));
    bloc.add(PointsLoadBalance(userId: widget.userId, roomId: widget.roomId));
    bloc.add(PointsLoadConfig(roomId: widget.roomId));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: const Text('Redeem Points'),
        backgroundColor: isDark ? AppColors.navBarDark : AppColors.navBar,
        elevation: 0.5,
      ),
      body: BlocConsumer<PointsBloc, PointsState>(
        listenWhen: (previous, current) =>
            previous.redemptionStatus != current.redemptionStatus,
        listener: (context, state) {
          if (state.redemptionStatus == PointsRedemptionStatus.succeeded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Item redeemed successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
            context
                .read<PointsBloc>()
                .add(const PointsClearRedemptionFeedback());
          } else if (state.redemptionStatus == PointsRedemptionStatus.failed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.redemptionErrorMessage ?? 'Redemption failed',
                ),
                backgroundColor: AppColors.error,
              ),
            );
            context
                .read<PointsBloc>()
                .add(const PointsClearRedemptionFeedback());
          }
        },
        builder: (context, state) {
          final config = state.config;
          if (config != null && !config.isEnabled) {
            return _buildUnavailableState(
              isDark,
              message: 'Points are disabled in this room.',
            );
          }

          if (state.redemptionItemsStatus == PointsLoadStatus.loading &&
              state.redemptionItems.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.redemptionItemsStatus == PointsLoadStatus.error &&
              state.redemptionItems.isEmpty) {
            return _buildErrorState(state.redemptionItemsErrorMessage, isDark);
          }

          return RefreshIndicator(
            onRefresh: () async => _loadItems(),
            color: AppColors.primary,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildPointsHeader(state, isDark),
                ),
                if (state.redemptionItems.isEmpty)
                  SliverFillRemaining(
                    child: _buildEmptyState(isDark),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.75,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = state.redemptionItems[index];
                          final canAfford =
                              (state.balance?.availablePoints ?? 0) >= item.cost;
                          return _RedemptionCard(
                            item: item,
                            canAfford: canAfford,
                            isRedeeming:
                                state.redemptionStatus ==
                                        PointsRedemptionStatus.inProgress &&
                                    state.redeemingItemId == item.id,
                            isBusy: state.redemptionStatus ==
                                PointsRedemptionStatus.inProgress,
                            isDark: isDark,
                            onRedeem: () =>
                                _showRedeemConfirmation(context, item, canAfford),
                          );
                        },
                        childCount: state.redemptionItems.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPointsHeader(PointsState state, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars_outlined, color: AppColors.warning, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available Points',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
              Text(
                '${state.balance?.availablePoints ?? 0}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.storefront_outlined,
            size: 64,
            color:
                isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No items available',
            style: TextStyle(
              fontSize: 16,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new rewards',
            style: TextStyle(
              fontSize: 14,
              color:
                  isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String? errorMessage, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Failed to load rewards',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color:
                    isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: _loadItems,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnavailableState(bool isDark, {required String message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.block_outlined, size: 48, color: AppColors.warning),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color:
                    isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRedeemConfirmation(
    BuildContext context,
    RedemptionItem item,
    bool canAfford,
  ) {
    if (!item.canRedeem || !canAfford) return;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor:
              isDark ? AppColors.surfaceDark : AppColors.surface,
          title: const Text('Confirm Redemption'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Redeem "${item.name}" for ${item.cost} points?'),
              const SizedBox(height: 8),
              Text(
                item.description,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<PointsBloc>().add(PointsRedeemItem(
                      userId: widget.userId,
                      roomId: widget.roomId,
                      itemId: item.id,
                    ));
              },
              child: const Text('Redeem'),
            ),
          ],
        );
      },
    );
  }
}

// =============================================================================
// Private widgets
// =============================================================================

class _RedemptionCard extends StatelessWidget {
  final RedemptionItem item;
  final bool canAfford;
  final bool isRedeeming;
  final bool isBusy;
  final bool isDark;
  final VoidCallback onRedeem;

  const _RedemptionCard({
    required this.item,
    required this.canAfford,
    required this.isRedeeming,
    required this.isBusy,
    required this.isDark,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = !item.canRedeem || !canAfford || isBusy;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image placeholder
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: _categoryColor.withValues(alpha: 0.12),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Icon(
                  _categoryIcon,
                  size: 40,
                  color: _categoryColor,
                ),
              ),
            ),
          ),
          // Info section
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // Cost and stock
                  Row(
                    children: [
                      Text(
                        '${item.cost} pts',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: canAfford
                              ? AppColors.primary
                              : AppColors.error,
                        ),
                      ),
                      const Spacer(),
                      if (item.stock != null)
                        Text(
                          '${item.stock} left',
                          style: TextStyle(
                            fontSize: 11,
                            color: item.isInStock
                                ? (isDark
                                    ? AppColors.textTertiaryDark
                                    : AppColors.textTertiary)
                                : AppColors.error,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Redeem button
                  SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDisabled
                            ? (isDark
                                ? const Color(0xFF333333)
                                : const Color(0xFFE0E0E0))
                            : AppColors.primary,
                        foregroundColor: isDisabled
                            ? AppColors.textDisabled
                            : Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: isDisabled ? null : onRedeem,
                      child: Text(
                        _buttonLabel,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _buttonLabel {
    if (isRedeeming) return 'Redeeming...';
    if (!item.isAvailable) return 'Unavailable';
    if (!item.isInStock) return 'Out of stock';
    if (!canAfford) return 'Not enough pts';
    return 'Redeem';
  }

  IconData get _categoryIcon {
    switch (item.category) {
      case RedemptionCategory.role:
        return Icons.shield_outlined;
      case RedemptionCategory.badge:
        return Icons.military_tech_outlined;
      case RedemptionCategory.feature:
        return Icons.auto_awesome_outlined;
      case RedemptionCategory.custom:
        return Icons.card_giftcard_outlined;
    }
  }

  Color get _categoryColor {
    switch (item.category) {
      case RedemptionCategory.role:
        return AppColors.info;
      case RedemptionCategory.badge:
        return AppColors.warning;
      case RedemptionCategory.feature:
        return AppColors.primary;
      case RedemptionCategory.custom:
        return const Color(0xFF9C27B0);
    }
  }
}
