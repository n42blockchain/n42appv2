import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/points/points_balance.dart';
import '../../blocs/points/points_bloc.dart';
import '../../blocs/points/points_event.dart';
import '../../blocs/points/points_state.dart';

/// Leaderboard page showing room-wide points rankings.
///
/// Features:
/// - Top-3 podium with medal icons
/// - Remaining users in a ranked list
/// - Current user highlighted
/// - Pull-to-refresh
class LeaderboardPage extends StatefulWidget {
  final String roomId;
  final String currentUserId;

  const LeaderboardPage({
    super.key,
    required this.roomId,
    required this.currentUserId,
  });

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  void _loadLeaderboard() {
    final bloc = context.read<PointsBloc>();
    bloc.add(PointsLoadLeaderboard(roomId: widget.roomId));
    bloc.add(PointsLoadConfig(roomId: widget.roomId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: context.navBarColor,
        elevation: 0.5,
      ),
      body: BlocBuilder<PointsBloc, PointsState>(
        builder: (context, state) {
          final config = state.config;
          if (config != null && !config.isEnabled) {
            return _buildUnavailableState(
              message: 'Points are disabled in this room.',
            );
          }

          if (config != null && !config.showLeaderboard) {
            return _buildUnavailableState(
              message: 'Leaderboard is disabled in this room.',
            );
          }

          if (state.leaderboardStatus == PointsLoadStatus.loading &&
              state.leaderboard.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.leaderboardStatus == PointsLoadStatus.error &&
              state.leaderboard.isEmpty) {
            return _buildErrorState(state.leaderboardErrorMessage);
          }

          if (state.leaderboard.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async => _loadLeaderboard(),
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (state.leaderboard.length >= 3) ...[
                  _buildPodium(state.leaderboard.take(3).toList()),
                  const SizedBox(height: 24),
                ],
                ...state.leaderboard
                    .skip(state.leaderboard.length >= 3 ? 3 : 0)
                    .toList()
                    .asMap()
                    .entries
                    .map((entry) {
                  final rank =
                      entry.key + (state.leaderboard.length >= 3 ? 4 : 1);
                  return _LeaderboardTile(
                    balance: entry.value,
                    rank: rank,
                    isCurrentUser:
                        entry.value.userId == widget.currentUserId,
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Podium (top 3)
  // ---------------------------------------------------------------------------

  Widget _buildPodium(List<PointsBalance> top3) {
    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          if (top3.length > 1)
            Expanded(
              child: _PodiumItem(
                balance: top3[1],
                rank: 2,
                height: 130,
                medalColor: const Color(0xFFC0C0C0),
                isCurrentUser: top3[1].userId == widget.currentUserId,
              ),
            ),
          const SizedBox(width: 8),
          // 1st place
          Expanded(
            child: _PodiumItem(
              balance: top3[0],
              rank: 1,
              height: 170,
              medalColor: const Color(0xFFFFD700),
              isCurrentUser: top3[0].userId == widget.currentUserId,
            ),
          ),
          const SizedBox(width: 8),
          // 3rd place
          if (top3.length > 2)
            Expanded(
              child: _PodiumItem(
                balance: top3[2],
                rank: 3,
                height: 110,
                medalColor: const Color(0xFFCD7F32),
                isCurrentUser: top3[2].userId == widget.currentUserId,
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Empty / Error states
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 64,
            color: context.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No rankings yet',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              height: 1.3,
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start earning points to appear on the leaderboard',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: context.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnavailableState({required String message}) {
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
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                fontWeight: FontWeight.w500,
                color: context.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
              'Failed to load leaderboard',
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
              onPressed: _loadLeaderboard,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Private widgets
// =============================================================================

class _PodiumItem extends StatelessWidget {
  final PointsBalance balance;
  final int rank;
  final double height;
  final Color medalColor;
  final bool isCurrentUser;

  const _PodiumItem({
    required this.balance,
    required this.rank,
    required this.height,
    required this.medalColor,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Avatar
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CircleAvatar(
              radius: rank == 1 ? 28 : 22,
              backgroundColor:
                  isCurrentUser ? AppColors.primary : medalColor,
              child: Text(
                _shortName(balance.userId),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            Positioned(
              bottom: -4,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: medalColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '#$rank',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Pedestal
        Container(
          height: height - 80,
          decoration: BoxDecoration(
            color: medalColor.withValues(alpha: 0.2),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${balance.totalPoints}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                  Text(
                    'pts',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.3,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _shortName(String userId) {
    if (userId.length <= 2) return userId.toUpperCase();
    // Extract the local part before any domain
    final local = userId.replaceFirst('@', '').split(':').first;
    if (local.length <= 2) return local.toUpperCase();
    return local.substring(0, 2).toUpperCase();
  }
}

class _LeaderboardTile extends StatelessWidget {
  final PointsBalance balance;
  final int rank;
  final bool isCurrentUser;

  const _LeaderboardTile({
    required this.balance,
    required this.rank,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.primary.withValues(alpha: 0.08)
            : context.surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: isCurrentUser
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '#$rank',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                height: 1.3,
                fontWeight: FontWeight.w600,
                color: context.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 18,
            backgroundColor:
                isCurrentUser ? AppColors.primary : AppColors.textTertiary,
            child: Text(
              _shortName(balance.userId),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  balance.userId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.3,
                    fontWeight:
                        isCurrentUser ? FontWeight.w600 : FontWeight.w400,
                    color: context.textPrimary,
                  ),
                ),
                if (balance.streakDays > 0)
                  Text(
                    '${balance.streakDays} day streak',
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
            '${balance.totalPoints}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              height: 1.3,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
          Text(
            ' pts',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              height: 1.3,
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _shortName(String userId) {
    if (userId.length <= 2) return userId.toUpperCase();
    final local = userId.replaceFirst('@', '').split(':').first;
    if (local.length <= 2) return local.toUpperCase();
    return local.substring(0, 2).toUpperCase();
  }
}
