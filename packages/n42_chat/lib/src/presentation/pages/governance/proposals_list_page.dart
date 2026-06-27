import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/governance/proposal_entity.dart';
import '../../blocs/governance/governance_bloc.dart';
import '../../blocs/governance/governance_event.dart';
import '../../blocs/governance/governance_state.dart';
import 'create_proposal_page.dart';
import 'proposal_detail_page.dart';

/// Page displaying a list of governance proposals for a Snapshot space.
///
/// Features:
/// - Filter chips for proposal states (All, Active, Closed, Pending)
/// - Pull-to-refresh
/// - Infinite scroll pagination
/// - FAB for creating new proposals
/// - Empty state handling
class ProposalsListPage extends StatefulWidget {
  final String spaceId;

  const ProposalsListPage({
    super.key,
    required this.spaceId,
  });

  @override
  State<ProposalsListPage> createState() => _ProposalsListPageState();
}

class _ProposalsListPageState extends State<ProposalsListPage> {
  final ScrollController _scrollController = ScrollController();
  ProposalState? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _loadProposals();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _loadProposals() {
    context.read<GovernanceBloc>().add(
          GovernanceLoadProposals(
            spaceId: widget.spaceId,
            filterState: _selectedFilter,
          ),
        );
  }

  void _onScroll() {
    if (_isNearBottom) {
      context.read<GovernanceBloc>().add(
            GovernanceLoadMoreProposals(spaceId: widget.spaceId),
          );
    }
  }

  bool get _isNearBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= maxScroll - 200;
  }

  void _onFilterChanged(ProposalState? filter) {
    setState(() => _selectedFilter = filter);
    _loadProposals();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: AppBar(
        title: const Text('Governance'),
        backgroundColor: context.navBarColor,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          _buildFilterChips(isDark),
          Expanded(
            child: BlocBuilder<GovernanceBloc, GovernanceState>(
              builder: (context, state) {
                if (state.status == GovernanceStatus.loading &&
                    state.proposals.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == GovernanceStatus.error &&
                    state.proposals.isEmpty) {
                  return _buildErrorState(state.errorMessage);
                }

                if (state.proposals.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async => _loadProposals(),
                  color: AppColors.primary,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: state.proposals.length +
                        (state.isLoadingMoreProposals ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= state.proposals.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      return _ProposalCard(
                        proposal: state.proposals[index],
                        isDark: isDark,
                        onTap: () => _navigateToDetail(state.proposals[index]),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreate(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: context.surfaceColor,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: 'All',
              isSelected: _selectedFilter == null,
              onTap: () => _onFilterChanged(null),
              isDark: isDark,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Active',
              isSelected: _selectedFilter == ProposalState.active,
              onTap: () => _onFilterChanged(ProposalState.active),
              isDark: isDark,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Pending',
              isSelected: _selectedFilter == ProposalState.pending,
              onTap: () => _onFilterChanged(ProposalState.pending),
              isDark: isDark,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Closed',
              isSelected: _selectedFilter == ProposalState.closed,
              onTap: () => _onFilterChanged(ProposalState.closed),
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.how_to_vote_outlined,
            size: 64,
            color: context.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No proposals found',
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
            _selectedFilter != null
                ? 'Try changing the filter'
                : 'Create the first proposal for this space',
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

  Widget _buildErrorState(String? errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load proposals',
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
              onPressed: _loadProposals,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(ProposalEntity proposal) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<GovernanceBloc>(),
          child: ProposalDetailPage(
            proposalId: proposal.id,
            spaceId: widget.spaceId,
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToCreate() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => BlocProvider.value(
          value: context.read<GovernanceBloc>(),
          child: CreateProposalPage(spaceId: widget.spaceId),
        ),
      ),
    );

    if (created == true && mounted) {
      _loadProposals();
    }
  }
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.dividerThinOf(isDark),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            height: 1.3,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? Colors.white
                : context.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ProposalCard extends StatelessWidget {
  final ProposalEntity proposal;
  final bool isDark;
  final VoidCallback onTap;

  const _ProposalCard({
    required this.proposal,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // State badge and time
            Row(
              children: [
                _buildStateBadge(),
                const Spacer(),
                Text(
                  _formatTimeRemaining(),
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
            const SizedBox(height: 10),
            // Title
            Text(
              proposal.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            // Author
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 14,
                  color: context.textTertiary,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    _shortenAddress(proposal.author),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.3,
                      color: context.textSecondary,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.how_to_vote_outlined,
                  size: 14,
                  color: context.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${proposal.votesCount} votes',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.3,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateBadge() {
    Color badgeColor;
    String label;

    switch (proposal.state) {
      case ProposalState.active:
        badgeColor = AppColors.success;
        label = 'Active';
      case ProposalState.pending:
        badgeColor = AppColors.warning;
        label = 'Pending';
      case ProposalState.closed:
        badgeColor = AppColors.textSecondary;
        label = 'Closed';
      case ProposalState.executed:
        badgeColor = AppColors.info;
        label = 'Executed';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          height: 1.3,
          fontWeight: FontWeight.w600,
          color: badgeColor,
        ),
      ),
    );
  }

  String _formatTimeRemaining() {
    if (proposal.hasEnded) return 'Ended';

    final remaining = proposal.timeRemaining;
    if (remaining.inDays > 0) {
      return '${remaining.inDays}d remaining';
    } else if (remaining.inHours > 0) {
      return '${remaining.inHours}h remaining';
    } else if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes}m remaining';
    }
    return 'Ending soon';
  }

  String _shortenAddress(String address) {
    if (address.length <= 12) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }
}
