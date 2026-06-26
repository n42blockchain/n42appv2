import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/governance/proposal_entity.dart';
import '../../../domain/entities/governance/vote_entity.dart';
import '../../blocs/governance/governance_bloc.dart';
import '../../blocs/governance/governance_event.dart';
import '../../blocs/governance/governance_state.dart';
import '../../widgets/governance/vote_progress_bar.dart';

/// Page displaying detailed information about a single governance proposal.
///
/// Shows:
/// - Proposal title, body, and author
/// - Vote progress bars for each choice
/// - Choice selection for voting (radio buttons for single choice)
/// - "Cast Vote" button with confirmation
/// - List of recent votes
/// - Time remaining indicator
class ProposalDetailPage extends StatefulWidget {
  final String proposalId;
  final String spaceId;

  const ProposalDetailPage({
    super.key,
    required this.proposalId,
    required this.spaceId,
  });

  @override
  State<ProposalDetailPage> createState() => _ProposalDetailPageState();
}

class _ProposalDetailPageState extends State<ProposalDetailPage> {
  int? _selectedChoice;
  bool _isLoadingDetail = false;
  bool _voteInFlight = false;

  @override
  void initState() {
    super.initState();
    _isLoadingDetail = true;
    context.read<GovernanceBloc>().add(
          GovernanceLoadProposalDetail(widget.proposalId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: AppBar(
        title: const Text('Proposal'),
        backgroundColor: context.navBarColor,
        elevation: 0.5,
      ),
      body: BlocConsumer<GovernanceBloc, GovernanceState>(
        listenWhen: (previous, current) =>
            previous.status != current.status ||
            previous.selectedProposal != current.selectedProposal,
        listener: (context, state) {
          final matchesCurrentProposal =
              state.selectedProposal?.id == widget.proposalId;

          if (_isLoadingDetail &&
              state.status == GovernanceStatus.loaded &&
              matchesCurrentProposal) {
            if (mounted) {
              setState(() => _isLoadingDetail = false);
            }
          }

          if (_voteInFlight &&
              state.status == GovernanceStatus.voted &&
              matchesCurrentProposal) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Vote submitted successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
            setState(() {
              _voteInFlight = false;
              _selectedChoice = null;
            });
          } else if ((state.status == GovernanceStatus.error &&
                  (_voteInFlight || _isLoadingDetail)) &&
              state.errorMessage != null) {
            final wasVoting = _voteInFlight;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
            if (mounted) {
              setState(() {
                _voteInFlight = false;
                if (!wasVoting) {
                  _isLoadingDetail = false;
                }
              });
            }
          }
        },
        builder: (context, state) {
          final proposal = state.selectedProposal?.id == widget.proposalId
              ? state.selectedProposal
              : null;

          if (_isLoadingDetail && proposal == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (proposal == null) {
            return Center(
              child: Text(
                'Proposal not found',
                style: TextStyle(
                  color: context.textSecondary,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(proposal),
                const SizedBox(height: 16),
                _buildBody(proposal),
                const SizedBox(height: 24),
                _buildVoteResults(proposal),
                const SizedBox(height: 24),
                if (proposal.isActive) ...[
                  _buildVotingSection(proposal, state),
                  const SizedBox(height: 24),
                ],
                _buildRecentVotes(state.votes, proposal),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  // -- Header: title, state badge, time, author --

  Widget _buildHeader(ProposalEntity proposal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // State badge and time remaining
          Row(
            children: [
              _buildStateBadge(proposal),
              const Spacer(),
              _buildTimeIndicator(proposal),
            ],
          ),
          const SizedBox(height: 12),
          // Title
          Text(
            proposal.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 20,
              height: 1.3,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          // Author
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 16,
                color: context.textTertiary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'by ${_shortenAddress(proposal.author)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.3,
                    color: context.textSecondary,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.how_to_vote_outlined,
                size: 16,
                color: context.textTertiary,
              ),
              const SizedBox(width: 4),
              Text(
                '${proposal.votesCount} votes',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.3,
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStateBadge(ProposalEntity proposal) {
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          height: 1.3,
          fontWeight: FontWeight.w600,
          color: badgeColor,
        ),
      ),
    );
  }

  Widget _buildTimeIndicator(ProposalEntity proposal) {
    final text = proposal.hasEnded
        ? 'Ended'
        : _formatDuration(proposal.timeRemaining);
    final color = proposal.isActive
        ? AppColors.success
        : context.textTertiary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.schedule, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13, height: 1.3, color: color),
        ),
      ],
    );
  }

  // -- Body: proposal description --

  Widget _buildBody(ProposalEntity proposal) {
    if (proposal.body.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            proposal.body,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // -- Vote results: progress bars --

  Widget _buildVoteResults(ProposalEntity proposal) {
    final winningChoice = proposal.winningChoice;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Results',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${proposal.scoresTotal.toStringAsFixed(0)} total VP',
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
          const SizedBox(height: 12),
          ...proposal.choices.map((choice) {
            final score = proposal.scores[choice] ?? 0;
            return VoteProgressBar(
              choiceName: choice,
              voteCount: score,
              totalVotes: proposal.scoresTotal,
              isWinner: choice == winningChoice,
              isSelected: _selectedChoice != null &&
                  proposal.choices.indexOf(choice) + 1 == _selectedChoice,
            );
          }),
        ],
      ),
    );
  }

  // -- Voting section: choice selection + cast vote button --

  Widget _buildVotingSection(
    ProposalEntity proposal,
    GovernanceState state,
  ) {
    final isDark = context.isDarkMode;
    final isVoting = _voteInFlight && state.status == GovernanceStatus.voting;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cast Your Vote',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          // Radio buttons for each choice
          IgnorePointer(
            ignoring: isVoting,
            child: RadioGroup<int>(
              groupValue: _selectedChoice ?? -1,
              onChanged: (value) => setState(() => _selectedChoice = value),
              child: Column(
                children: proposal.choices.asMap().entries.map((entry) {
                  final index = entry.key;
                  final choice = entry.value;
                  // Snapshot uses 1-based choice index
                  final choiceValue = index + 1;

                  return ListTile(
                    leading: Radio<int>(value: choiceValue),
                    title: Text(
                      choice,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.3,
                        color: context.textPrimary,
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    onTap: isVoting
                        ? null
                        : () => setState(() => _selectedChoice = choiceValue),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Cast Vote button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _selectedChoice != null && !isVoting
                  ? () => _castVote(proposal)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: isDark
                    ? AppColors.dividerDark
                    : const Color(0xFFE0E0E0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isVoting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Cast Vote',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _castVote(ProposalEntity proposal) {
    final choice = _selectedChoice;
    if (choice == null) return;

    // Show confirmation dialog
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Vote'),
        content: Text(
          'Vote for "${proposal.choices[choice - 1]}"?\n\n'
          'This action requires a wallet signature and cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        setState(() => _voteInFlight = true);
        context.read<GovernanceBloc>().add(
              GovernanceCastVote(
                spaceId: widget.spaceId,
                proposalId: proposal.id,
                choice: choice,
              ),
            );
      }
    });
  }

  // -- Recent votes list --

  Widget _buildRecentVotes(
    List<VoteEntity> votes,
    ProposalEntity proposal,
  ) {
    if (votes.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Votes (${votes.length})',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...votes.take(20).map((vote) {
            final choiceName = _resolveChoiceName(vote.choice, proposal);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  // Voter address
                  Expanded(
                    flex: 3,
                    child: Text(
                      _shortenAddress(vote.voter),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.3,
                        color: context.textPrimary,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  // Choice
                  Expanded(
                    flex: 3,
                    child: Text(
                      choiceName,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.3,
                        color: context.textSecondary,
                      ),
                    ),
                  ),
                  // Voting power
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${vote.votingPower.toStringAsFixed(vote.votingPower == vote.votingPower.roundToDouble() ? 0 : 2)} VP',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                        color: context.textPrimary,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // -- Helper methods --

  String _resolveChoiceName(dynamic choice, ProposalEntity proposal) {
    if (choice is int && choice >= 1 && choice <= proposal.choices.length) {
      return proposal.choices[choice - 1];
    }
    return choice.toString();
  }

  String _shortenAddress(String address) {
    if (address.length <= 12) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return 'Ended';
    if (duration.inDays > 0) return '${duration.inDays}d left';
    if (duration.inHours > 0) return '${duration.inHours}h left';
    if (duration.inMinutes > 0) return '${duration.inMinutes}m left';
    return 'Ending soon';
  }
}
