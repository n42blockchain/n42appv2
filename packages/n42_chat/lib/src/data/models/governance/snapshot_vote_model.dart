import '../../../domain/entities/governance/vote_entity.dart';

/// Snapshot API vote data model
///
/// Maps between the Snapshot GraphQL API JSON format and
/// the domain [VoteEntity].
class SnapshotVoteModel {
  final String id;
  final String voter;
  final double vp;
  final dynamic choice;
  final int created;
  final String? reason;

  const SnapshotVoteModel({
    required this.id,
    required this.voter,
    this.vp = 0,
    required this.choice,
    required this.created,
    this.reason,
  });

  /// Parse from Snapshot GraphQL JSON response
  factory SnapshotVoteModel.fromJson(Map<String, dynamic> json) {
    return SnapshotVoteModel(
      id: json['id'] as String,
      voter: json['voter'] as String,
      vp: (json['vp'] as num?)?.toDouble() ?? 0,
      choice: json['choice'],
      created: json['created'] as int? ?? 0,
      reason: json['reason'] as String?,
    );
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'voter': voter,
        'vp': vp,
        'choice': choice,
        'created': created,
        'reason': reason,
      };

  /// Convert to domain entity
  VoteEntity toEntity(String proposalId) {
    return VoteEntity(
      id: id,
      voter: voter,
      proposalId: proposalId,
      choice: choice as Object,
      votingPower: vp,
      created: DateTime.fromMillisecondsSinceEpoch(created * 1000),
      reason: reason,
    );
  }
}
