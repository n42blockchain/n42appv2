import 'package:equatable/equatable.dart';

/// State of a governance proposal
enum ProposalState {
  pending,
  active,
  closed,

  /// Proposal has been executed
  executed,
}

/// Voting system type
enum VotingType {
  /// Single choice voting
  singleChoice,

  /// Approval voting (vote for multiple)
  approval,

  /// Quadratic voting
  quadratic,

  /// Ranked choice
  rankedChoice,

  /// Weighted voting
  weighted,
}

/// A governance proposal entity
class ProposalEntity extends Equatable {
  final String id;
  final String spaceId;
  final String title;
  final String body;
  final String author;
  final ProposalState state;
  final VotingType votingType;
  final List<String> choices;
  final DateTime startTime;
  final DateTime endTime;
  final int snapshot;
  final Map<String, double> scores;
  final double scoresTotal;
  final int votesCount;
  final String? link;

  const ProposalEntity({
    required this.id,
    required this.spaceId,
    required this.title,
    required this.body,
    required this.author,
    required this.state,
    this.votingType = VotingType.singleChoice,
    required this.choices,
    required this.startTime,
    required this.endTime,
    this.snapshot = 0,
    this.scores = const {},
    this.scoresTotal = 0,
    this.votesCount = 0,
    this.link,
  });

  /// Whether the proposal is currently active for voting
  bool get isActive => state == ProposalState.active;

  /// Whether the proposal has been closed
  bool get isClosed => state == ProposalState.closed;

  /// Time remaining until the proposal ends
  Duration get timeRemaining => endTime.difference(DateTime.now());

  /// Whether the proposal end time has passed
  bool get hasEnded => DateTime.now().isAfter(endTime);

  /// Get the winning choice (highest score)
  String? get winningChoice {
    if (scores.isEmpty) return null;
    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  ProposalEntity copyWith({
    String? id,
    String? spaceId,
    String? title,
    String? body,
    String? author,
    ProposalState? state,
    VotingType? votingType,
    List<String>? choices,
    DateTime? startTime,
    DateTime? endTime,
    int? snapshot,
    Map<String, double>? scores,
    double? scoresTotal,
    int? votesCount,
    String? link,
  }) {
    return ProposalEntity(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      title: title ?? this.title,
      body: body ?? this.body,
      author: author ?? this.author,
      state: state ?? this.state,
      votingType: votingType ?? this.votingType,
      choices: choices ?? this.choices,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      snapshot: snapshot ?? this.snapshot,
      scores: scores ?? this.scores,
      scoresTotal: scoresTotal ?? this.scoresTotal,
      votesCount: votesCount ?? this.votesCount,
      link: link ?? this.link,
    );
  }

  @override
  List<Object?> get props => [
        id,
        spaceId,
        title,
        body,
        author,
        state,
        votingType,
        choices,
        startTime,
        endTime,
        scores,
        scoresTotal,
        votesCount,
        link,
      ];
}
