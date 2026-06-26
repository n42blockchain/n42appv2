import 'package:equatable/equatable.dart';

import 'social_connection.dart';
import 'social_profile.dart';

/// A recommended social connection based on on-chain data analysis.
///
/// Aggregates multiple [SocialConnection] dimensions into a single
/// [similarityScore] to rank suggested contacts.
class SocialRecommendation extends Equatable {
  /// The recommended user's on-chain profile.
  final SocialProfile profile;

  /// Overall similarity score from 0.0 to 1.0.
  final double similarityScore;

  /// Individual connections that contribute to the score.
  final List<SocialConnection> connections;

  /// Human-readable explanation of why this user is recommended.
  final String reason;

  const SocialRecommendation({
    required this.profile,
    required this.similarityScore,
    this.connections = const [],
    required this.reason,
  });

  /// Similarity as a percentage (0-100).
  int get similarityPercent => (similarityScore * 100).round();

  /// Distinct connection types contributing to this recommendation.
  List<ConnectionType> get topConnectionTypes =>
      connections.map((c) => c.type).toSet().toList();

  @override
  List<Object?> get props => [profile, similarityScore];
}
