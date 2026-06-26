import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/governance/snapshot_proposal_model.dart';
import '../../models/governance/snapshot_vote_model.dart';
import '../../../core/utils/debug_log.dart';

/// Snapshot GraphQL API datasource for querying proposals and votes.
///
/// Connects to the Snapshot Hub GraphQL endpoint to read governance data
/// including spaces, proposals, and votes.
class SnapshotGraphQLDatasource {
  final String _endpoint;
  final http.Client _httpClient;

  SnapshotGraphQLDatasource({
    String? endpoint,
    http.Client? httpClient,
  })  : _endpoint = endpoint ?? 'https://hub.snapshot.org/graphql',
        _httpClient = httpClient ?? http.Client();

  /// Execute a GraphQL query against the Snapshot API
  Future<Map<String, dynamic>> _query(
    String query, {
    Map<String, dynamic>? variables,
  }) async {
    final response = await _httpClient
        .post(
          Uri.parse(_endpoint),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'query': query,
            'variables': ?variables,
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Snapshot GraphQL error: ${response.statusCode}');
    }

    final Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Snapshot returned malformed JSON response');
    }

    if (data.containsKey('errors')) {
      final errors = data['errors'];
      debugLog('Snapshot GraphQL errors: $errors');
      throw Exception('GraphQL errors: $errors');
    }

    final result = data['data'] as Map<String, dynamic>?;
    if (result == null) {
      throw Exception('Snapshot returned null data');
    }
    return result;
  }

  /// Query proposals for a space
  Future<List<SnapshotProposalModel>> getProposals(
    String spaceId, {
    String? state,
    int first = 20,
    int skip = 0,
  }) async {
    const query = r'''
      query Proposals($spaceId: String!, $first: Int!, $skip: Int!, $state: String) {
        proposals(
          first: $first,
          skip: $skip,
          where: { space_in: [$spaceId], state: $state },
          orderBy: "created",
          orderDirection: desc
        ) {
          id
          title
          body
          choices
          start
          end
          snapshot
          state
          author
          type
          scores
          scores_total
          votes
          link
          space {
            id
            name
          }
        }
      }
    ''';

    final data = await _query(query, variables: {
      'spaceId': spaceId,
      'first': first,
      'skip': skip,
      'state': ?state,
    });

    final proposals = data['proposals'] as List<dynamic>;
    return proposals
        .map(
          (json) =>
              SnapshotProposalModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  /// Query a single proposal by ID
  Future<SnapshotProposalModel> getProposal(String proposalId) async {
    const query = r'''
      query Proposal($id: String!) {
        proposal(id: $id) {
          id
          title
          body
          choices
          start
          end
          snapshot
          state
          author
          type
          scores
          scores_total
          votes
          link
          space {
            id
            name
          }
        }
      }
    ''';

    final data = await _query(query, variables: {'id': proposalId});
    return SnapshotProposalModel.fromJson(
      data['proposal'] as Map<String, dynamic>,
    );
  }

  /// Query votes for a proposal
  Future<List<SnapshotVoteModel>> getVotes(
    String proposalId, {
    String? voter,
    int first = 100,
    int skip = 0,
  }) async {
    const query = r'''
      query Votes($proposalId: String!, $first: Int!, $skip: Int!, $voter: String) {
        votes(
          first: $first,
          skip: $skip,
          where: { proposal: $proposalId, voter: $voter },
          orderBy: "vp",
          orderDirection: desc
        ) {
          id
          voter
          vp
          choice
          created
          reason
        }
      }
    ''';

    final data = await _query(query, variables: {
      'proposalId': proposalId,
      'first': first,
      'skip': skip,
      'voter': ?voter,
    });

    final votes = data['votes'] as List<dynamic>;
    return votes
        .map(
          (json) => SnapshotVoteModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  /// Query a governance space by ID
  Future<Map<String, dynamic>> getSpace(String spaceId) async {
    const query = r'''
      query Space($id: String!) {
        space(id: $id) {
          id
          name
          about
          avatar
          website
          network
          admins
          members
          proposals_count
          followers_count
          strategies {
            name
            params
          }
          filters {
            minScore
            onlyMembers
          }
        }
      }
    ''';

    final data = await _query(query, variables: {'id': spaceId});
    return data['space'] as Map<String, dynamic>;
  }

  /// Query voting power scores via Snapshot score API.
  ///
  /// Returns a map of address → score.
  Future<Map<String, double>> getScores({
    required String spaceId,
    required String network,
    required List<dynamic> strategies,
    required List<String> addresses,
    int? snapshot,
  }) async {
    const scoreEndpoint = 'https://score.snapshot.org/api/scores';
    final response = await _httpClient
        .post(
          Uri.parse(scoreEndpoint),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'params': {
              'space': spaceId,
              'network': network,
              'snapshot': snapshot ?? 'latest',
              'strategies': strategies,
              'addresses': addresses,
            },
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Snapshot score API error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final result = data['result'] as Map<String, dynamic>?;
    if (result == null) return {};

    final scores = <String, double>{};
    final scoresList = result['scores'] as List<dynamic>? ?? [];
    for (final scoreMap in scoresList) {
      if (scoreMap is Map<String, dynamic>) {
        for (final entry in scoreMap.entries) {
          scores[entry.key] = (scores[entry.key] ?? 0) +
              (entry.value as num).toDouble();
        }
      }
    }
    return scores;
  }

  /// Release resources
  void dispose() {
    _httpClient.close();
  }
}
