class GameScore {
  final String gameId;
  final int score;
  final DateTime playedAt;

  const GameScore({
    required this.gameId,
    required this.score,
    required this.playedAt,
  });

  Map<String, dynamic> toJson() => {
        'gameId': gameId,
        'score': score,
        'playedAt': playedAt.toIso8601String(),
      };

  factory GameScore.fromJson(Map<String, dynamic> json) => GameScore(
        gameId: json['gameId'] as String,
        score: json['score'] as int,
        playedAt: DateTime.parse(json['playedAt'] as String),
      );
}
