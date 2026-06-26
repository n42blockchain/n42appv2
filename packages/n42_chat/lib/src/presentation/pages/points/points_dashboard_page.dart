import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/points/points_transaction.dart';
import '../../blocs/points/points_bloc.dart';
import '../../blocs/points/points_event.dart';
import '../../blocs/points/points_state.dart';
import 'leaderboard_page.dart';
import 'points_admin_page.dart';
import 'redemption_page.dart';

/// Dashboard page for the SocialFi points economy.
///
/// Displays:
/// - Balance card (total points, available, streak days)
/// - Quick stats (rank, redeemed points)
/// - Recent transactions list
/// - Navigation to leaderboard, redemption store, and admin
class PointsDashboardPage extends StatefulWidget {
  final String userId;
  final String roomId;
  final bool isAdmin;

  const PointsDashboardPage({
    super.key,
    required this.userId,
    required this.roomId,
    this.isAdmin = false,
  });

  @override
  State<PointsDashboardPage> createState() => _PointsDashboardPageState();
}

class _PointsDashboardPageState extends State<PointsDashboardPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final bloc = context.read<PointsBloc>();
    bloc.add(PointsLoadBalance(userId: widget.userId, roomId: widget.roomId));
    bloc.add(
      PointsLoadTransactions(userId: widget.userId, roomId: widget.roomId),
    );
    bloc.add(PointsLoadConfig(roomId: widget.roomId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: AppBar(
        title: const Text('Points'),
        backgroundColor: context.navBarColor,
        elevation: 0.5,
        actions: [
          if (widget.isAdmin)
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => _navigateToAdmin(),
            ),
        ],
      ),
      body: BlocBuilder<PointsBloc, PointsState>(
        builder: (context, state) {
          final showInitialBalanceLoading =
              state.balanceStatus == PointsLoadStatus.loading &&
                  state.balance == null;
          if (showInitialBalanceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.balanceStatus == PointsLoadStatus.error &&
              state.balance == null) {
            return _buildErrorState(state.balanceErrorMessage);
          }

          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildBalanceCard(state),
                const SizedBox(height: 16),
                _buildQuickStats(state),
                const SizedBox(height: 16),
                _buildActionSection(state),
                const SizedBox(height: 24),
                _buildRecentTransactionsHeader(),
                const SizedBox(height: 8),
                if (state.transactionsStatus == PointsLoadStatus.loading &&
                    state.transactions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.transactionsStatus == PointsLoadStatus.error &&
                    state.transactions.isEmpty)
                  _buildTransactionsError(state.transactionsErrorMessage)
                else ...state.transactions
                    .take(10)
                    .map((tx) => _TransactionTile(
                          transaction: tx,
                        )),
                if (state.transactionsStatus != PointsLoadStatus.loading &&
                    state.transactionsStatus != PointsLoadStatus.error &&
                    state.transactions.isEmpty)
                  _buildEmptyTransactions(),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Balance card
  // ---------------------------------------------------------------------------

  Widget _buildBalanceCard(PointsState state) {
    final balance = state.balance;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Points',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              height: 1.3,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${balance?.totalPoints ?? 0}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 36,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _BalanceStat(
                label: 'Available',
                value: '${balance?.availablePoints ?? 0}',
              ),
              const SizedBox(width: 24),
              _BalanceStat(
                label: 'Streak',
                value: '${balance?.streakDays ?? 0} days',
              ),
              const Spacer(),
              if (balance?.isActiveToday ?? false)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Active today',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.3,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Quick stats
  // ---------------------------------------------------------------------------

  Widget _buildQuickStats(PointsState state) {
    final balance = state.balance;
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.leaderboard_outlined,
            label: 'Rank',
            value: '#${balance?.rank ?? '--'}',
            isDark: context.isDarkMode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.redeem_outlined,
            label: 'Redeemed',
            value: '${balance?.redeemedPoints ?? 0}',
            isDark: context.isDarkMode,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Action buttons
  // ---------------------------------------------------------------------------

  Widget _buildActionSection(PointsState state) {
    final config = state.config;
    if (config != null && !config.isEnabled) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.pause_circle_outline, color: AppColors.warning),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Points are disabled in this room.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: context.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final actions = <Widget>[
      if (config?.showLeaderboard ?? true)
        Expanded(
          child: _ActionButton(
            icon: Icons.emoji_events_outlined,
            label: 'Leaderboard',
            onTap: () => _navigateToLeaderboard(),
          ),
        ),
      Expanded(
        child: _ActionButton(
          icon: Icons.storefront_outlined,
          label: 'Redeem',
          onTap: () => _navigateToRedemption(),
        ),
      ),
    ];

    if (actions.length == 1) {
      return Row(children: actions);
    }

    return Row(
      children: [
        actions.first,
        const SizedBox(width: 12),
        actions.last,
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Transactions section
  // ---------------------------------------------------------------------------

  Widget _buildRecentTransactionsHeader() {
    return Text(
      'Recent Activity',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 16,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: context.textPrimary,
      ),
    );
  }

  Widget _buildEmptyTransactions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.history_outlined,
              size: 48,
              color: context.textTertiary,
            ),
            const SizedBox(height: 8),
            Text(
              'No activity yet',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                height: 1.3,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Start earning points by participating!',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                height: 1.3,
                color: context.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsError(String? errorMessage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 32),
            const SizedBox(height: 8),
            Text(
              'Failed to load recent activity',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                height: 1.3,
                fontWeight: FontWeight.w500,
                color: context.textPrimary,
              ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 6),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: context.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.read<PointsBloc>().add(
                    PointsLoadTransactions(
                      userId: widget.userId,
                      roomId: widget.roomId,
                    ),
                  ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Error state
  // ---------------------------------------------------------------------------

  Widget _buildErrorState(String? errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Failed to load points',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                height: 1.3,
                fontWeight: FontWeight.w500,
                color: context.textPrimary,
              ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: context.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  void _navigateToLeaderboard() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<PointsBloc>(),
          child: LeaderboardPage(
            roomId: widget.roomId,
            currentUserId: widget.userId,
          ),
        ),
      ),
    );
  }

  void _navigateToRedemption() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<PointsBloc>(),
          child: RedemptionPage(
            userId: widget.userId,
            roomId: widget.roomId,
          ),
        ),
      ),
    );
  }

  void _navigateToAdmin() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<PointsBloc>(),
          child: PointsAdminPage(roomId: widget.roomId),
        ),
      ),
    );
  }
}

// =============================================================================
// Private widgets
// =============================================================================

class _BalanceStat extends StatelessWidget {
  final String label;
  final String value;

  const _BalanceStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11, height: 1.3, color: Colors.white60),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            height: 1.3,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
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
      child: Row(
        children: [
          Icon(icon, size: 28, color: AppColors.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.3,
                  color: context.textSecondary,
                ),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.dividerColor,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                height: 1.3,
                fontWeight: FontWeight.w500,
                color: context.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final PointsTransaction transaction;

  const _TransactionTile({
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = transaction.isEarned;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (isPositive ? AppColors.success : AppColors.error)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isPositive ? Icons.add_circle_outline : Icons.remove_circle_outline,
              size: 20,
              color: isPositive ? AppColors.success : AppColors.error,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTime(transaction.createdAt),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    color: context.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isPositive ? '+' : '-'}${transaction.amount}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              height: 1.3,
              fontWeight: FontWeight.w700,
              color: isPositive ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.month}/${dateTime.day}';
  }
}
