import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/models/social/social_similarity_model.dart';
import 'package:n42_chat/src/domain/entities/social/social_profile.dart';
import 'package:n42_chat/src/domain/entities/social/social_recommendation.dart';
import 'package:n42_chat/src/domain/repositories/social_graph_repository.dart';
import 'package:n42_chat/src/presentation/blocs/social/social_graph_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/social/social_graph_event.dart';
import 'package:n42_chat/src/presentation/blocs/social/social_graph_state.dart';

class MockSocialGraphRepository extends Mock implements ISocialGraphRepository {}

void main() {
  late MockSocialGraphRepository mockRepository;

  const profile = SocialProfile(
    address: '0xabc0000000000000000000000000000000000000',
    chains: ['eth'],
    portfolioValueUsd: 42,
  );

  const recommendation = SocialRecommendation(
    profile: SocialProfile(
      address: '0xdef0000000000000000000000000000000000000',
    ),
    similarityScore: 0.8,
    reason: 'shared holdings',
  );

  const similarity = SocialSimilarityModel(
    addressA: '0xabc0000000000000000000000000000000000000',
    addressB: '0xdef0000000000000000000000000000000000000',
    tokenOverlap: 0.5,
    nftOverlap: 0.4,
    chainUsage: 0.3,
    totalScore: 0.42,
    commonTokens: ['ETH'],
    commonNftCollections: ['0xnft'],
    commonChains: ['eth'],
  );

  setUp(() {
    mockRepository = MockSocialGraphRepository();
  });

  blocTest<SocialGraphBloc, SocialGraphState>(
    'profile failure does not wipe loaded recommendations',
    build: () {
      when(() => mockRepository.getProfile(any()))
          .thenThrow(Exception('profile failed'));
      return SocialGraphBloc(repository: mockRepository);
    },
    seed: () => const SocialGraphState(
      recommendationsStatus: SocialGraphStatus.loaded,
      recommendations: [recommendation],
    ),
    act: (bloc) => bloc.add(
      const SocialGraphLoadProfile('0xabc0000000000000000000000000000000000000'),
    ),
    expect: () => [
      isA<SocialGraphState>()
          .having((s) => s.profileStatus, 'profileStatus',
              SocialGraphStatus.loading)
          .having((s) => s.recommendations, 'recommendations',
              const [recommendation]),
      isA<SocialGraphState>()
          .having((s) => s.profileStatus, 'profileStatus',
              SocialGraphStatus.error)
          .having((s) => s.profileErrorMessage, 'profileErrorMessage',
              contains('profile failed'))
          .having((s) => s.recommendations, 'recommendations',
              const [recommendation]),
    ],
  );

  blocTest<SocialGraphBloc, SocialGraphState>(
    'recommendations failure does not wipe loaded profile',
    build: () {
      when(() => mockRepository.getRecommendations(any(), limit: any(named: 'limit')))
          .thenThrow(Exception('recommendation failed'));
      return SocialGraphBloc(repository: mockRepository);
    },
    seed: () => const SocialGraphState(
      profileStatus: SocialGraphStatus.loaded,
      profile: profile,
    ),
    act: (bloc) => bloc.add(
      const SocialGraphLoadRecommendations(
        '0xabc0000000000000000000000000000000000000',
      ),
    ),
    expect: () => [
      isA<SocialGraphState>()
          .having((s) => s.recommendationsStatus, 'recommendationsStatus',
              SocialGraphStatus.loading)
          .having((s) => s.profile, 'profile', profile),
      isA<SocialGraphState>()
          .having((s) => s.recommendationsStatus, 'recommendationsStatus',
              SocialGraphStatus.error)
          .having(
              (s) => s.recommendationsErrorMessage,
              'recommendationsErrorMessage',
              contains('recommendation failed'))
          .having((s) => s.profile, 'profile', profile),
    ],
  );

  blocTest<SocialGraphBloc, SocialGraphState>(
    'similarity failure does not overwrite loaded recommendation state',
    build: () {
      when(() => mockRepository.calculateSimilarity(any(), any()))
          .thenThrow(Exception('similarity failed'));
      return SocialGraphBloc(repository: mockRepository);
    },
    seed: () => const SocialGraphState(
      recommendationsStatus: SocialGraphStatus.loaded,
      recommendations: [recommendation],
    ),
    act: (bloc) => bloc.add(
      const SocialGraphCalculateSimilarity(
        '0xabc0000000000000000000000000000000000000',
        '0xdef0000000000000000000000000000000000000',
      ),
    ),
    expect: () => [
      isA<SocialGraphState>()
          .having((s) => s.similarityStatus, 'similarityStatus',
              SocialGraphStatus.loading)
          .having((s) => s.recommendations, 'recommendations',
              const [recommendation]),
      isA<SocialGraphState>()
          .having((s) => s.similarityStatus, 'similarityStatus',
              SocialGraphStatus.error)
          .having((s) => s.similarityErrorMessage, 'similarityErrorMessage',
              contains('similarity failed'))
          .having((s) => s.recommendations, 'recommendations',
              const [recommendation]),
    ],
  );

  blocTest<SocialGraphBloc, SocialGraphState>(
    'similarity success stores the full similarity model',
    build: () {
      when(() => mockRepository.calculateSimilarity(any(), any()))
          .thenAnswer((_) async => similarity);
      return SocialGraphBloc(repository: mockRepository);
    },
    act: (bloc) => bloc.add(
      const SocialGraphCalculateSimilarity(
        '0xabc0000000000000000000000000000000000000',
        '0xdef0000000000000000000000000000000000000',
      ),
    ),
    expect: () => [
      isA<SocialGraphState>().having(
        (s) => s.similarityStatus,
        'similarityStatus',
        SocialGraphStatus.loading,
      ),
      isA<SocialGraphState>()
          .having((s) => s.similarityStatus, 'similarityStatus',
              SocialGraphStatus.loaded)
          .having((s) => s.similarity, 'similarity', similarity),
    ],
  );
}
