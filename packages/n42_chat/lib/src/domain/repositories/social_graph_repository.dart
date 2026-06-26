import '../../data/models/social/social_similarity_model.dart';
import '../entities/social/social_connection.dart';
import '../entities/social/social_profile.dart';
import '../entities/social/social_recommendation.dart';

/// Repository interface for on-chain social graph operations.
///
/// Provides address-level social discovery: profile resolution,
/// connection enumeration, recommendation generation, and similarity
/// calculation across multiple chains and protocols.
abstract class ISocialGraphRepository {
  /// Get the on-chain social profile for [address].
  ///
  /// Resolves ENS/Lens/Farcaster identities and aggregates portfolio data.
  Future<SocialProfile> getProfile(String address);

  /// Get social connections for [address].
  ///
  /// Returns all known connections ordered by strength descending.
  Future<List<SocialConnection>> getConnections(String address);

  /// Get recommended connections based on on-chain similarity.
  ///
  /// Returns up to [limit] recommendations sorted by similarity score.
  Future<List<SocialRecommendation>> getRecommendations(
    String address, {
    int limit = 20,
  });

  /// Calculate the full similarity result between [addressA] and [addressB].
  ///
  /// Includes the total score and the underlying common tokens/NFTs/chains.
  Future<SocialSimilarityModel> calculateSimilarity(
    String addressA,
    String addressB,
  );

  /// Search for profiles by ENS name, Lens handle, or Farcaster username.
  Future<List<SocialProfile>> searchProfiles(String query);
}
