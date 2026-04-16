import 'package:equatable/equatable.dart';

/// Base event for the social graph BLoC.
abstract class SocialGraphEvent extends Equatable {
  const SocialGraphEvent();

  @override
  List<Object?> get props => [];
}

/// Load the on-chain social profile for a given [address].
class SocialGraphLoadProfile extends SocialGraphEvent {
  final String address;

  const SocialGraphLoadProfile(this.address);

  @override
  List<Object?> get props => [address];
}

/// Load recommended social connections for [address].
class SocialGraphLoadRecommendations extends SocialGraphEvent {
  final String address;
  final int limit;

  const SocialGraphLoadRecommendations(this.address, {this.limit = 20});

  @override
  List<Object?> get props => [address, limit];
}

/// Calculate the similarity score between [addressA] and [addressB].
class SocialGraphCalculateSimilarity extends SocialGraphEvent {
  final String addressA;
  final String addressB;

  const SocialGraphCalculateSimilarity(this.addressA, this.addressB);

  @override
  List<Object?> get props => [addressA, addressB];
}

/// Search for profiles by ENS name, Lens handle, or Farcaster username.
class SocialGraphSearchProfiles extends SocialGraphEvent {
  final String query;

  const SocialGraphSearchProfiles(this.query);

  @override
  List<Object?> get props => [query];
}
