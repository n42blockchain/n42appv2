import 'package:equatable/equatable.dart';

import '../../../data/models/social/social_similarity_model.dart';
import '../../../domain/entities/social/social_profile.dart';
import '../../../domain/entities/social/social_recommendation.dart';

/// The loading lifecycle of the social graph feature.
enum SocialGraphStatus {
  /// No data has been requested yet.
  initial,

  /// A request is in flight.
  loading,

  /// Data has been successfully loaded.
  loaded,

  /// An error occurred during the last request.
  error,
}

/// Immutable state for the [SocialGraphBloc].
class SocialGraphState extends Equatable {
  /// Profile load status.
  final SocialGraphStatus profileStatus;

  /// Recommendation load status.
  final SocialGraphStatus recommendationsStatus;

  /// Search load status.
  final SocialGraphStatus searchStatus;

  /// Similarity load status.
  final SocialGraphStatus similarityStatus;

  /// The loaded social profile (null until [SocialGraphLoadProfile] succeeds).
  final SocialProfile? profile;

  /// List of recommended connections.
  final List<SocialRecommendation> recommendations;

  /// Search results from [SocialGraphSearchProfiles].
  final List<SocialProfile> searchResults;

  /// Full similarity result from [SocialGraphCalculateSimilarity].
  final SocialSimilarityModel? similarity;

  /// Human-readable error message for profile loading.
  final String? profileErrorMessage;

  /// Human-readable error message for recommendation loading.
  final String? recommendationsErrorMessage;

  /// Human-readable error message for search loading.
  final String? searchErrorMessage;

  /// Human-readable error message for similarity loading.
  final String? similarityErrorMessage;

  const SocialGraphState({
    this.profileStatus = SocialGraphStatus.initial,
    this.recommendationsStatus = SocialGraphStatus.initial,
    this.searchStatus = SocialGraphStatus.initial,
    this.similarityStatus = SocialGraphStatus.initial,
    this.profile,
    this.recommendations = const [],
    this.searchResults = const [],
    this.similarity,
    this.profileErrorMessage,
    this.recommendationsErrorMessage,
    this.searchErrorMessage,
    this.similarityErrorMessage,
  });

  bool get isProfileLoading => profileStatus == SocialGraphStatus.loading;
  bool get isRecommendationsLoading =>
      recommendationsStatus == SocialGraphStatus.loading;
  bool get isSearchLoading => searchStatus == SocialGraphStatus.loading;
  bool get isSimilarityLoading => similarityStatus == SocialGraphStatus.loading;

  bool get hasProfileError =>
      profileStatus == SocialGraphStatus.error && profileErrorMessage != null;
  bool get hasRecommendationsError =>
      recommendationsStatus == SocialGraphStatus.error &&
      recommendationsErrorMessage != null;
  bool get hasSearchError =>
      searchStatus == SocialGraphStatus.error && searchErrorMessage != null;
  bool get hasSimilarityError =>
      similarityStatus == SocialGraphStatus.error &&
      similarityErrorMessage != null;

  SocialGraphState copyWith({
    SocialGraphStatus? profileStatus,
    SocialGraphStatus? recommendationsStatus,
    SocialGraphStatus? searchStatus,
    SocialGraphStatus? similarityStatus,
    SocialProfile? profile,
    List<SocialRecommendation>? recommendations,
    List<SocialProfile>? searchResults,
    SocialSimilarityModel? similarity,
    String? profileErrorMessage,
    String? recommendationsErrorMessage,
    String? searchErrorMessage,
    String? similarityErrorMessage,
    bool clearProfileError = false,
    bool clearRecommendationsError = false,
    bool clearSearchError = false,
    bool clearSimilarityError = false,
  }) {
    return SocialGraphState(
      profileStatus: profileStatus ?? this.profileStatus,
      recommendationsStatus:
          recommendationsStatus ?? this.recommendationsStatus,
      searchStatus: searchStatus ?? this.searchStatus,
      similarityStatus: similarityStatus ?? this.similarityStatus,
      profile: profile ?? this.profile,
      recommendations: recommendations ?? this.recommendations,
      searchResults: searchResults ?? this.searchResults,
      similarity: similarity ?? this.similarity,
      profileErrorMessage: clearProfileError
          ? null
          : (profileErrorMessage ?? this.profileErrorMessage),
      recommendationsErrorMessage: clearRecommendationsError
          ? null
          : (recommendationsErrorMessage ?? this.recommendationsErrorMessage),
      searchErrorMessage: clearSearchError
          ? null
          : (searchErrorMessage ?? this.searchErrorMessage),
      similarityErrorMessage: clearSimilarityError
          ? null
          : (similarityErrorMessage ?? this.similarityErrorMessage),
    );
  }

  @override
  List<Object?> get props => [
        profileStatus,
        recommendationsStatus,
        searchStatus,
        similarityStatus,
        profile,
        recommendations,
        searchResults,
        similarity,
        profileErrorMessage,
        recommendationsErrorMessage,
        searchErrorMessage,
        similarityErrorMessage,
      ];
}
