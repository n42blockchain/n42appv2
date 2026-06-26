import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/social_graph_repository.dart';
import 'social_graph_event.dart';
import 'social_graph_state.dart';

/// BLoC that manages on-chain social graph state.
///
/// Delegates all data operations to [ISocialGraphRepository] and maps
/// events to states following the standard loading / loaded / error
/// lifecycle.
class SocialGraphBloc extends Bloc<SocialGraphEvent, SocialGraphState> {
  final ISocialGraphRepository _repository;

  SocialGraphBloc({required ISocialGraphRepository repository})
      : _repository = repository,
        super(const SocialGraphState()) {
    on<SocialGraphLoadProfile>(_onLoadProfile);
    on<SocialGraphLoadRecommendations>(_onLoadRecommendations);
    on<SocialGraphCalculateSimilarity>(_onCalculateSimilarity);
    on<SocialGraphSearchProfiles>(_onSearchProfiles);
  }

  Future<void> _onLoadProfile(
    SocialGraphLoadProfile event,
    Emitter<SocialGraphState> emit,
  ) async {
    emit(state.copyWith(
      profileStatus: SocialGraphStatus.loading,
      clearProfileError: true,
    ));
    try {
      final profile = await _repository.getProfile(event.address);
      emit(state.copyWith(
        profileStatus: SocialGraphStatus.loaded,
        profile: profile,
      ));
    } catch (e) {
      emit(state.copyWith(
        profileStatus: SocialGraphStatus.error,
        profileErrorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadRecommendations(
    SocialGraphLoadRecommendations event,
    Emitter<SocialGraphState> emit,
  ) async {
    emit(state.copyWith(
      recommendationsStatus: SocialGraphStatus.loading,
      clearRecommendationsError: true,
    ));
    try {
      final recommendations = await _repository.getRecommendations(
        event.address,
        limit: event.limit,
      );
      emit(state.copyWith(
        recommendationsStatus: SocialGraphStatus.loaded,
        recommendations: recommendations,
      ));
    } catch (e) {
      emit(state.copyWith(
        recommendationsStatus: SocialGraphStatus.error,
        recommendationsErrorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCalculateSimilarity(
    SocialGraphCalculateSimilarity event,
    Emitter<SocialGraphState> emit,
  ) async {
    emit(state.copyWith(
      similarityStatus: SocialGraphStatus.loading,
      clearSimilarityError: true,
    ));
    try {
      final similarity = await _repository.calculateSimilarity(
        event.addressA,
        event.addressB,
      );
      emit(state.copyWith(
        similarityStatus: SocialGraphStatus.loaded,
        similarity: similarity,
      ));
    } catch (e) {
      emit(state.copyWith(
        similarityStatus: SocialGraphStatus.error,
        similarityErrorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSearchProfiles(
    SocialGraphSearchProfiles event,
    Emitter<SocialGraphState> emit,
  ) async {
    emit(state.copyWith(
      searchStatus: SocialGraphStatus.loading,
      clearSearchError: true,
    ));
    try {
      final results = await _repository.searchProfiles(event.query);
      emit(state.copyWith(
        searchStatus: SocialGraphStatus.loaded,
        searchResults: results,
      ));
    } catch (e) {
      emit(state.copyWith(
        searchStatus: SocialGraphStatus.error,
        searchErrorMessage: e.toString(),
      ));
    }
  }
}
