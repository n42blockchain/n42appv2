import 'package:equatable/equatable.dart';

import '../../../domain/entities/governance/proposal_entity.dart';

/// Base class for governance BLoC events
abstract class GovernanceEvent extends Equatable {
  const GovernanceEvent();

  @override
  List<Object?> get props => [];
}

/// Load governance space info
class GovernanceLoadSpace extends GovernanceEvent {
  final String spaceId;

  const GovernanceLoadSpace(this.spaceId);

  @override
  List<Object?> get props => [spaceId];
}

/// Load proposals for a space
class GovernanceLoadProposals extends GovernanceEvent {
  final String spaceId;
  final ProposalState? filterState;

  const GovernanceLoadProposals({
    required this.spaceId,
    this.filterState,
  });

  @override
  List<Object?> get props => [spaceId, filterState];
}

/// Load more proposals (pagination)
class GovernanceLoadMoreProposals extends GovernanceEvent {
  final String spaceId;

  const GovernanceLoadMoreProposals({required this.spaceId});

  @override
  List<Object?> get props => [spaceId];
}

/// Load a single proposal detail with its votes
class GovernanceLoadProposalDetail extends GovernanceEvent {
  final String proposalId;

  const GovernanceLoadProposalDetail(this.proposalId);

  @override
  List<Object?> get props => [proposalId];
}

/// Cast a vote on a proposal
class GovernanceCastVote extends GovernanceEvent {
  final String spaceId;
  final String proposalId;
  final int choice;
  final String? reason;

  const GovernanceCastVote({
    required this.spaceId,
    required this.proposalId,
    required this.choice,
    this.reason,
  });

  @override
  List<Object?> get props => [spaceId, proposalId, choice, reason];
}

/// Create a new proposal
class GovernanceCreateProposal extends GovernanceEvent {
  final String spaceId;
  final String title;
  final String body;
  final List<String> choices;
  final DateTime startTime;
  final DateTime endTime;

  const GovernanceCreateProposal({
    required this.spaceId,
    required this.title,
    required this.body,
    required this.choices,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props =>
      [spaceId, title, body, choices, startTime, endTime];
}
