import '../../../domain/entities/governance/proposal_entity.dart';

/// Snapshot API proposal data model
///
/// Maps between the Snapshot GraphQL API JSON format and
/// the domain [ProposalEntity].
class SnapshotProposalModel {
  final String id;
  final String title;
  final String body;
  final List<String> choices;
  final int start;
  final int end;
  final int snapshot;
  final String state;
  final String author;
  final String type;
  final List<double> scores;
  final double scoresTotal;
  final int votes;
  final String? link;
  final String spaceId;
  final String? spaceName;

  const SnapshotProposalModel({
    required this.id,
    required this.title,
    required this.body,
    required this.choices,
    required this.start,
    required this.end,
    this.snapshot = 0,
    required this.state,
    required this.author,
    this.type = 'single-choice',
    this.scores = const [],
    this.scoresTotal = 0,
    this.votes = 0,
    this.link,
    required this.spaceId,
    this.spaceName,
  });

  /// Parse from Snapshot GraphQL JSON response
  factory SnapshotProposalModel.fromJson(Map<String, dynamic> json) {
    final space = json['space'] as Map<String, dynamic>?;
    return SnapshotProposalModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      choices: (json['choices'] as List<dynamic>?)?.cast<String>() ?? [],
      start: json['start'] as int? ?? 0,
      end: json['end'] as int? ?? 0,
      snapshot: json['snapshot'] as int? ?? 0,
      state: json['state'] as String? ?? 'closed',
      author: json['author'] as String? ?? '',
      type: json['type'] as String? ?? 'single-choice',
      scores: (json['scores'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      scoresTotal: (json['scores_total'] as num?)?.toDouble() ?? 0,
      votes: json['votes'] as int? ?? 0,
      link: json['link'] as String?,
      spaceId: space?['id'] as String? ?? '',
      spaceName: space?['name'] as String?,
    );
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'choices': choices,
        'start': start,
        'end': end,
        'snapshot': snapshot,
        'state': state,
        'author': author,
        'type': type,
        'scores': scores,
        'scores_total': scoresTotal,
        'votes': votes,
        'link': link,
        'space': {'id': spaceId, 'name': spaceName},
      };

  /// Convert to domain entity
  ProposalEntity toEntity() {
    final scoresMap = <String, double>{};
    for (var i = 0; i < choices.length && i < scores.length; i++) {
      scoresMap[choices[i]] = scores[i];
    }

    return ProposalEntity(
      id: id,
      spaceId: spaceId,
      title: title,
      body: body,
      author: author,
      state: _mapState(state),
      votingType: _mapVotingType(type),
      choices: choices,
      startTime: DateTime.fromMillisecondsSinceEpoch(start * 1000),
      endTime: DateTime.fromMillisecondsSinceEpoch(end * 1000),
      snapshot: snapshot,
      scores: scoresMap,
      scoresTotal: scoresTotal,
      votesCount: votes,
      link: link,
    );
  }

  static ProposalState _mapState(String state) {
    switch (state) {
      case 'pending':
        return ProposalState.pending;
      case 'active':
        return ProposalState.active;
      case 'closed':
        return ProposalState.closed;
      case 'executed':
        return ProposalState.executed;
      default:
        return ProposalState.closed;
    }
  }

  static VotingType _mapVotingType(String type) {
    switch (type) {
      case 'single-choice':
        return VotingType.singleChoice;
      case 'approval':
        return VotingType.approval;
      case 'quadratic':
        return VotingType.quadratic;
      case 'ranked-choice':
        return VotingType.rankedChoice;
      case 'weighted':
        return VotingType.weighted;
      default:
        return VotingType.singleChoice;
    }
  }
}
