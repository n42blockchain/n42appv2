import 'package:equatable/equatable.dart';

/// A vote cast on a proposal
class VoteEntity extends Equatable {
  final String id;
  final String voter;
  final String proposalId;

  /// Choice index (1-based for single choice) or map for weighted
  final Object choice;
  final double votingPower;
  final DateTime created;
  final String? reason;

  const VoteEntity({
    required this.id,
    required this.voter,
    required this.proposalId,
    required this.choice,
    this.votingPower = 0,
    required this.created,
    this.reason,
  });

  VoteEntity copyWith({
    String? id,
    String? voter,
    String? proposalId,
    Object? choice,
    double? votingPower,
    DateTime? created,
    String? reason,
  }) {
    return VoteEntity(
      id: id ?? this.id,
      voter: voter ?? this.voter,
      proposalId: proposalId ?? this.proposalId,
      choice: choice ?? this.choice,
      votingPower: votingPower ?? this.votingPower,
      created: created ?? this.created,
      reason: reason ?? this.reason,
    );
  }

  @override
  List<Object?> get props => [
        id,
        voter,
        proposalId,
        choice,
        votingPower,
        created,
        reason,
      ];
}
