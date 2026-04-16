import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/domain/entities/social/social_profile.dart';
import 'package:n42_chat/src/domain/entities/social/social_recommendation.dart';
import 'package:n42_chat/src/presentation/blocs/social/social_graph_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/social/social_graph_event.dart';
import 'package:n42_chat/src/presentation/blocs/social/social_graph_state.dart';
import 'package:n42_chat/src/presentation/pages/social/social_graph_page.dart';
import 'package:n42_chat/src/presentation/pages/social/user_similarity_page.dart';

class MockSocialGraphBloc extends Mock implements SocialGraphBloc {}

class FakeSocialGraphEvent extends Fake implements SocialGraphEvent {}

void main() {
  late MockSocialGraphBloc mockSocialGraphBloc;
  late StreamController<SocialGraphState> stateController;

  const loadedProfile = SocialProfile(
    address: '0xabc0000000000000000000000000000000000000',
    ensName: 'alice.eth',
    chains: ['eth', 'base'],
    portfolioValueUsd: 1234,
    tokenCount: 3,
    nftCount: 5,
  );

  const recommendation = SocialRecommendation(
    profile: SocialProfile(
      address: '0xdef0000000000000000000000000000000000000',
      ensName: 'bob.eth',
    ),
    similarityScore: 0.72,
    reason: 'shared holdings',
  );

  setUpAll(() {
    registerFallbackValue(FakeSocialGraphEvent());
  });

  setUp(() {
    mockSocialGraphBloc = MockSocialGraphBloc();
    stateController = StreamController<SocialGraphState>.broadcast();
    when(
      () => mockSocialGraphBloc.stream,
    ).thenAnswer((_) => stateController.stream);
    when(() => mockSocialGraphBloc.add(any())).thenReturn(null);
  });

  tearDown(() async {
    await stateController.close();
  });

  testWidgets(
    'keeps loaded profile visible when recommendations fail independently',
    (tester) async {
      when(() => mockSocialGraphBloc.state).thenReturn(
        const SocialGraphState(
          profileStatus: SocialGraphStatus.loaded,
          profile: loadedProfile,
          recommendationsStatus: SocialGraphStatus.error,
          recommendationsErrorMessage: 'recommendations failed',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SocialGraphBloc>.value(
            value: mockSocialGraphBloc,
            child: const SocialGraphPage(
              address: '0xabc0000000000000000000000000000000000000',
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('alice.eth'), findsOneWidget);
      expect(find.textContaining('recommendations failed'), findsOneWidget);
      verify(
        () => mockSocialGraphBloc.add(
          const SocialGraphLoadProfile(
            '0xabc0000000000000000000000000000000000000',
          ),
        ),
      ).called(1);
      verify(
        () => mockSocialGraphBloc.add(
          const SocialGraphLoadRecommendations(
            '0xabc0000000000000000000000000000000000000',
          ),
        ),
      ).called(1);
    },
  );

  testWidgets(
    'shows top-level error only when both profile and recommendations fail',
    (tester) async {
      when(() => mockSocialGraphBloc.state).thenReturn(
        const SocialGraphState(
          profileStatus: SocialGraphStatus.error,
          recommendationsStatus: SocialGraphStatus.error,
          profileErrorMessage: 'profile failed',
          recommendationsErrorMessage: 'recommendations failed',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SocialGraphBloc>.value(
            value: mockSocialGraphBloc,
            child: const SocialGraphPage(
              address: '0xabc0000000000000000000000000000000000000',
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Failed to load social graph'), findsOneWidget);
      expect(find.textContaining('recommendations failed'), findsOneWidget);
      expect(find.text('alice.eth'), findsNothing);
    },
  );

  testWidgets('tapping a recommendation opens the real similarity page', (
    tester,
  ) async {
    when(() => mockSocialGraphBloc.state).thenReturn(
      const SocialGraphState(
        profileStatus: SocialGraphStatus.loaded,
        profile: loadedProfile,
        recommendationsStatus: SocialGraphStatus.loaded,
        recommendations: [recommendation],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<SocialGraphBloc>.value(
          value: mockSocialGraphBloc,
          child: const SocialGraphPage(
            address: '0xabc0000000000000000000000000000000000000',
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('bob.eth'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(UserSimilarityPage), findsOneWidget);
    expect(find.text('Navigate to UserSimilarityPage'), findsNothing);
  });
}
