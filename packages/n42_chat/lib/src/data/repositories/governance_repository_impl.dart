import '../../core/utils/debug_log.dart';
import '../../domain/entities/governance/governance_space.dart';
import '../../domain/entities/governance/proposal_entity.dart';
import '../../domain/entities/governance/vote_entity.dart';
import '../../domain/repositories/governance_repository.dart';
import '../datasources/governance/snapshot_graphql_datasource.dart';
import '../datasources/governance/snapshot_hub_datasource.dart';

/// Implementation of [IGovernanceRepository] using Snapshot protocol.
///
/// Reads governance data via [SnapshotGraphQLDatasource] and submits
/// votes/proposals via [SnapshotHubDatasource] using EIP-712 signatures.
class GovernanceRepositoryImpl implements IGovernanceRepository {
  final SnapshotGraphQLDatasource _graphql;
  final SnapshotHubDatasource _hub;

  GovernanceRepositoryImpl({
    required SnapshotGraphQLDatasource graphql,
    required SnapshotHubDatasource hub,
  }) : _graphql = graphql,
       _hub = hub;

  @override
  Future<GovernanceSpace> getSpace(String spaceId) async {
    final data = await _graphql.getSpace(spaceId);
    final rawStrategies = data['strategies'] as List<dynamic>? ?? const [];
    return GovernanceSpace(
      id: data['id'] as String,
      name: data['name'] as String? ?? '',
      about: data['about'] as String?,
      avatar: data['avatar'] as String?,
      website: data['website'] as String?,
      network: data['network'] as String? ?? '1',
      admins: (data['admins'] as List<dynamic>?)?.cast<String>() ?? [],
      members: (data['members'] as List<dynamic>?)?.cast<String>() ?? [],
      proposalsCount: data['proposals_count'] as int? ?? 0,
      followersCount: data['followers_count'] as int? ?? 0,
      strategies: rawStrategies.whereType<Map<String, dynamic>>().toList(
        growable: false,
      ),
      filters: data['filters'] as Map<String, dynamic>?,
    );
  }

  @override
  Future<List<ProposalEntity>> getProposals(
    String spaceId, {
    ProposalState? state,
    int first = 20,
    int skip = 0,
  }) async {
    final stateStr = state?.name;
    final models = await _graphql.getProposals(
      spaceId,
      state: stateStr,
      first: first,
      skip: skip,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ProposalEntity> getProposal(String proposalId) async {
    final model = await _graphql.getProposal(proposalId);
    return model.toEntity();
  }

  @override
  Future<List<VoteEntity>> getVotes(
    String proposalId, {
    String? voter,
    int first = 100,
    int skip = 0,
  }) async {
    final models = await _graphql.getVotes(
      proposalId,
      voter: voter,
      first: first,
      skip: skip,
    );
    return models.map((m) => m.toEntity(proposalId)).toList();
  }

  @override
  Future<double> getVotingPower(
    String spaceId,
    String voter,
    int blockNumber,
  ) async {
    try {
      final space = await _graphql.getSpace(spaceId);
      final strategies = space['strategies'] as List<dynamic>?;
      final network = space['network'] as String? ?? '1';

      if (strategies == null || strategies.isEmpty) return 0;

      final scores = await _graphql.getScores(
        spaceId: spaceId,
        network: network,
        strategies: strategies,
        addresses: [voter],
        snapshot: blockNumber,
      );

      if (scores.isEmpty) return 0;
      return (scores[voter] as num?)?.toDouble() ?? 0;
    } catch (e) {
      debugLog(
        'GovernanceRepository: getVotingPower failed for $voter in $spaceId: $e',
      );
      return 0;
    }
  }

  @override
  Future<void> castVote({
    required String spaceId,
    required String proposalId,
    required int choice,
    String? reason,
  }) async {
    await _hub.submitVote(
      spaceId: spaceId,
      proposalId: proposalId,
      choice: choice,
      reason: reason,
    );
  }

  @override
  Future<String> createProposal({
    required String spaceId,
    required String title,
    required String body,
    required List<String> choices,
    required DateTime startTime,
    required DateTime endTime,
    int? snapshot,
  }) async {
    return _hub.createProposal(
      spaceId: spaceId,
      title: title,
      body: body,
      choices: choices,
      start: startTime.millisecondsSinceEpoch ~/ 1000,
      end: endTime.millisecondsSinceEpoch ~/ 1000,
      snapshot: snapshot,
    );
  }
}
