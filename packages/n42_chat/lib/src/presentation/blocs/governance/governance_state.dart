import 'package:equatable/equatable.dart';

import '../../../domain/entities/governance/governance_space.dart';
import '../../../domain/entities/governance/proposal_entity.dart';
import '../../../domain/entities/governance/vote_entity.dart';

/// Status of the governance BLoC
enum GovernanceStatus {
  initial,
  loading,
  loaded,
  error,
  voting,
  voted,
  creating,
  created,
}

const _governanceUnset = Object();

/// State for the governance BLoC
class GovernanceState extends Equatable {
  final GovernanceStatus status;
  final GovernanceSpace? space;
  final List<ProposalEntity> proposals;
  final ProposalEntity? selectedProposal;
  final List<VoteEntity> votes;
  final double? userVotingPower;
  final String? errorMessage;
  final bool hasMoreProposals;
  final bool isLoadingMoreProposals;
  final ProposalState? filterState;

  const GovernanceState({
    this.status = GovernanceStatus.initial,
    this.space,
    this.proposals = const [],
    this.selectedProposal,
    this.votes = const [],
    this.userVotingPower,
    this.errorMessage,
    this.hasMoreProposals = true,
    this.isLoadingMoreProposals = false,
    this.filterState,
  });

  /// Whether the BLoC is currently loading or voting
  bool get isLoading =>
      status == GovernanceStatus.loading || status == GovernanceStatus.voting;

  GovernanceState copyWith({
    GovernanceStatus? status,
    GovernanceSpace? space,
    List<ProposalEntity>? proposals,
    ProposalEntity? selectedProposal,
    List<VoteEntity>? votes,
    double? userVotingPower,
    String? errorMessage,
    bool? hasMoreProposals,
    bool? isLoadingMoreProposals,
    Object? filterState = _governanceUnset,
  }) {
    return GovernanceState(
      status: status ?? this.status,
      space: space ?? this.space,
      proposals: proposals ?? this.proposals,
      selectedProposal: selectedProposal ?? this.selectedProposal,
      votes: votes ?? this.votes,
      userVotingPower: userVotingPower ?? this.userVotingPower,
      errorMessage: errorMessage,
      hasMoreProposals: hasMoreProposals ?? this.hasMoreProposals,
      isLoadingMoreProposals:
          isLoadingMoreProposals ?? this.isLoadingMoreProposals,
      filterState: filterState == _governanceUnset
          ? this.filterState
          : filterState as ProposalState?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    space,
    proposals,
    selectedProposal,
    votes,
    userVotingPower,
    errorMessage,
    hasMoreProposals,
    isLoadingMoreProposals,
    filterState,
  ];
}
