import '../entities/governance/governance_space.dart';
import '../entities/governance/proposal_entity.dart';
import '../entities/governance/vote_entity.dart';

/// Repository interface for governance/voting operations
abstract class IGovernanceRepository {
  /// Get a governance space by ID
  Future<GovernanceSpace> getSpace(String spaceId);

  /// Get proposals for a space
  Future<List<ProposalEntity>> getProposals(
    String spaceId, {
    ProposalState? state,
    int first = 20,
    int skip = 0,
  });

  /// Get a single proposal by ID
  Future<ProposalEntity> getProposal(String proposalId);

  /// Get votes for a proposal
  Future<List<VoteEntity>> getVotes(
    String proposalId, {
    String? voter,
    int first = 100,
    int skip = 0,
  });

  /// Get voting power for a user in a space
  Future<double> getVotingPower(
    String spaceId,
    String voter,
    int blockNumber,
  );

  /// Cast a vote on a proposal (gasless via EIP-712)
  Future<void> castVote({
    required String spaceId,
    required String proposalId,
    required int choice,
    String? reason,
  });

  /// Create a new proposal
  Future<String> createProposal({
    required String spaceId,
    required String title,
    required String body,
    required List<String> choices,
    required DateTime startTime,
    required DateTime endTime,
    int? snapshot,
  });
}
