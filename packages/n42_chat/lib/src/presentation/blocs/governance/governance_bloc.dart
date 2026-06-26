import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/governance/proposal_entity.dart';
import '../../../domain/repositories/governance_repository.dart';
import 'governance_event.dart';
import 'governance_state.dart';
import '../../../core/utils/debug_log.dart';

/// BLoC for governance/voting operations.
///
/// Manages the lifecycle of proposals, votes, and governance spaces
/// through the [IGovernanceRepository] interface.
class GovernanceBloc extends Bloc<GovernanceEvent, GovernanceState> {
  final IGovernanceRepository _repository;

  static final _exceptionPrefixRe = RegExp(r'^Exception:\s*');
  static final _stateErrorPrefixRe = RegExp(r'^StateError:\s*');
  static final _longHexRe = RegExp(r'[a-fA-F0-9]{20,}');

  GovernanceBloc({required IGovernanceRepository repository})
      : _repository = repository,
        super(const GovernanceState()) {
    on<GovernanceLoadSpace>(_onLoadSpace);
    on<GovernanceLoadProposals>(_onLoadProposals);
    on<GovernanceLoadMoreProposals>(_onLoadMoreProposals);
    on<GovernanceLoadProposalDetail>(_onLoadProposalDetail);
    on<GovernanceCastVote>(_onCastVote);
    on<GovernanceCreateProposal>(_onCreateProposal);
  }

  Future<void> _onLoadSpace(
    GovernanceLoadSpace event,
    Emitter<GovernanceState> emit,
  ) async {
    emit(state.copyWith(status: GovernanceStatus.loading));
    try {
      final space = await _repository.getSpace(event.spaceId);
      emit(state.copyWith(status: GovernanceStatus.loaded, space: space));
    } catch (e, stackTrace) {
      debugLog('Failed to load space: $e\n$stackTrace');
      emit(state.copyWith(
        status: GovernanceStatus.error,
        errorMessage: _formatError(e),
      ));
    }
  }

  Future<void> _onLoadProposals(
    GovernanceLoadProposals event,
    Emitter<GovernanceState> emit,
  ) async {
    emit(state.copyWith(
      status: GovernanceStatus.loading,
      filterState: event.filterState,
      isLoadingMoreProposals: false,
    ));
    try {
      final proposals = await _repository.getProposals(
        event.spaceId,
        state: event.filterState,
      );
      emit(state.copyWith(
        status: GovernanceStatus.loaded,
        proposals: proposals,
        hasMoreProposals: proposals.length >= 20,
        isLoadingMoreProposals: false,
      ));
    } catch (e, stackTrace) {
      debugLog('Failed to load proposals: $e\n$stackTrace');
      emit(state.copyWith(
        status: GovernanceStatus.error,
        errorMessage: _formatError(e),
        isLoadingMoreProposals: false,
      ));
    }
  }

  Future<void> _onLoadMoreProposals(
    GovernanceLoadMoreProposals event,
    Emitter<GovernanceState> emit,
  ) async {
    if (!state.hasMoreProposals || state.isLoadingMoreProposals) return;

    emit(state.copyWith(isLoadingMoreProposals: true));

    try {
      final moreProposals = await _repository.getProposals(
        event.spaceId,
        state: state.filterState,
        skip: state.proposals.length,
      );
      emit(state.copyWith(
        proposals: [...state.proposals, ...moreProposals],
        hasMoreProposals: moreProposals.length >= 20,
        isLoadingMoreProposals: false,
      ));
    } catch (e) {
      debugLog('Failed to load more proposals: $e');
      emit(state.copyWith(isLoadingMoreProposals: false));
    }
  }

  Future<void> _onLoadProposalDetail(
    GovernanceLoadProposalDetail event,
    Emitter<GovernanceState> emit,
  ) async {
    emit(state.copyWith(status: GovernanceStatus.loading));
    try {
      final proposal = await _repository.getProposal(event.proposalId);
      final votes = await _repository.getVotes(event.proposalId);
      emit(state.copyWith(
        status: GovernanceStatus.loaded,
        proposals: _mergeProposalIntoList(state.proposals, proposal),
        selectedProposal: proposal,
        votes: votes,
      ));
    } catch (e, stackTrace) {
      debugLog('Failed to load proposal detail: $e\n$stackTrace');
      emit(state.copyWith(
        status: GovernanceStatus.error,
        errorMessage: _formatError(e),
      ));
    }
  }

  Future<void> _onCastVote(
    GovernanceCastVote event,
    Emitter<GovernanceState> emit,
  ) async {
    emit(state.copyWith(status: GovernanceStatus.voting));
    try {
      await _repository.castVote(
        spaceId: event.spaceId,
        proposalId: event.proposalId,
        choice: event.choice,
        reason: event.reason,
      );
      // Reload proposal to get updated scores
      final proposal = await _repository.getProposal(event.proposalId);
      final votes = await _repository.getVotes(event.proposalId);
      emit(state.copyWith(
        status: GovernanceStatus.voted,
        proposals: _mergeProposalIntoList(state.proposals, proposal),
        selectedProposal: proposal,
        votes: votes,
      ));
    } catch (e, stackTrace) {
      debugLog('Failed to cast vote: $e\n$stackTrace');
      emit(state.copyWith(
        status: GovernanceStatus.error,
        errorMessage: _formatError(e),
      ));
    }
  }

  Future<void> _onCreateProposal(
    GovernanceCreateProposal event,
    Emitter<GovernanceState> emit,
  ) async {
    emit(state.copyWith(status: GovernanceStatus.creating));
    try {
      await _repository.createProposal(
        spaceId: event.spaceId,
        title: event.title,
        body: event.body,
        choices: event.choices,
        startTime: event.startTime,
        endTime: event.endTime,
      );
      emit(state.copyWith(status: GovernanceStatus.created));
    } catch (e, stackTrace) {
      debugLog('Failed to create proposal: $e\n$stackTrace');
      emit(state.copyWith(
        status: GovernanceStatus.error,
        errorMessage: _formatError(e),
      ));
    }
  }

  /// Sanitize error messages for display, stripping sensitive details
  /// such as URLs, API keys, or internal stack information.
  String _formatError(Object error) {
    final message = error.toString();
    // Remove Exception/Error prefix for cleaner display
    final cleaned = message
        .replaceAll(_exceptionPrefixRe, '')
        .replaceAll(_stateErrorPrefixRe, '');
    // Strip potential API keys or tokens (hex strings > 20 chars)
    final sanitized =
        cleaned.replaceAll(_longHexRe, '[redacted]');
    // Cap length to prevent overly verbose error messages in UI
    if (sanitized.length > 200) {
      return '${sanitized.substring(0, 200)}...';
    }
    return sanitized;
  }

  List<ProposalEntity> _mergeProposalIntoList(
    List<ProposalEntity> proposals,
    ProposalEntity proposal,
  ) {
    final index = proposals.indexWhere((item) => item.id == proposal.id);
    if (index == -1) {
      return proposals;
    }

    final updated = List<ProposalEntity>.from(proposals);
    updated[index] = proposal;
    return updated;
  }
}
