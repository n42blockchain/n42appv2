import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/models/social/social_similarity_model.dart';
import 'package:n42_chat/src/presentation/blocs/social/social_graph_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/social/social_graph_event.dart';
import 'package:n42_chat/src/presentation/blocs/social/social_graph_state.dart';
import 'package:n42_chat/src/presentation/pages/social/user_similarity_page.dart';

class MockSocialGraphBloc extends Mock implements SocialGraphBloc {}

class FakeSocialGraphEvent extends Fake implements SocialGraphEvent {}

const _similarity = SocialSimilarityModel(
  addressA: '0xabc0000000000000000000000000000000000000',
  addressB: '0xdef0000000000000000000000000000000000000',
  tokenOverlap: 0.6,
  nftOverlap: 0.4,
  chainUsage: 0.2,
  totalScore: 0.42,
  commonTokens: ['ETH', 'USDC'],
  commonNftCollections: ['0xnft1'],
  commonChains: ['eth', 'base'],
);

void main() {
  late MockSocialGraphBloc mockSocialGraphBloc;
  late StreamController<SocialGraphState> stateController;

  setUpAll(() {
    registerFallbackValue(FakeSocialGraphEvent());
  });

  setUp(() {
    mockSocialGraphBloc = MockSocialGraphBloc();
    stateController = StreamController<SocialGraphState>.broadcast();
    when(() => mockSocialGraphBloc.stream)
        .thenAnswer((_) => stateController.stream);
    when(() => mockSocialGraphBloc.add(any())).thenReturn(null);
  });

  tearDown(() async {
    await stateController.close();
  });

  testWidgets('ignores unrelated recommendation errors when similarity is loaded',
      (tester) async {
    when(
      () => mockSocialGraphBloc.state,
    ).thenReturn(
      const SocialGraphState(
        recommendationsStatus: SocialGraphStatus.error,
        recommendationsErrorMessage: 'recommendations failed',
        similarityStatus: SocialGraphStatus.loaded,
        similarity: _similarity,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<SocialGraphBloc>.value(
          value: mockSocialGraphBloc,
          child: const UserSimilarityPage(
            addressA: '0xabc0000000000000000000000000000000000000',
            addressB: '0xdef0000000000000000000000000000000000000',
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));

    expect(find.text('42%'), findsOneWidget);
    expect(find.textContaining('ETH, USDC'), findsOneWidget);
    expect(find.text('Failed to calculate similarity'), findsNothing);
    verify(
      () => mockSocialGraphBloc.add(
        const SocialGraphCalculateSimilarity(
          '0xabc0000000000000000000000000000000000000',
          '0xdef0000000000000000000000000000000000000',
        ),
      ),
    ).called(1);
  });

  testWidgets('shows error only for similarity-specific failures', (tester) async {
    when(
      () => mockSocialGraphBloc.state,
    ).thenReturn(
      const SocialGraphState(
        similarityStatus: SocialGraphStatus.error,
        similarityErrorMessage: 'similarity failed',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<SocialGraphBloc>.value(
          value: mockSocialGraphBloc,
          child: const UserSimilarityPage(
            addressA: '0xabc0000000000000000000000000000000000000',
            addressB: '0xdef0000000000000000000000000000000000000',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Failed to calculate similarity'), findsOneWidget);
    expect(find.textContaining('similarity failed'), findsOneWidget);
  });

  testWidgets('renders breakdown and common items from similarity model',
      (tester) async {
    when(
      () => mockSocialGraphBloc.state,
    ).thenReturn(
      const SocialGraphState(
        similarityStatus: SocialGraphStatus.loaded,
        similarity: _similarity,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<SocialGraphBloc>.value(
          value: mockSocialGraphBloc,
          child: const UserSimilarityPage(
            addressA: '0xabc0000000000000000000000000000000000000',
            addressB: '0xdef0000000000000000000000000000000000000',
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));

    expect(find.text('60% (weight: 43%)'), findsOneWidget);
    expect(find.text('40% (weight: 36%)'), findsOneWidget);
    expect(find.text('20% (weight: 21%)'), findsOneWidget);
    expect(find.textContaining('ETH, USDC'), findsOneWidget);
    expect(find.textContaining('0xnft1'), findsOneWidget);
    expect(find.textContaining('eth, base'), findsOneWidget);
  });
}
