import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/domain/entities/points/points_config.dart';
import 'package:n42_chat/src/presentation/blocs/points/points_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/points/points_event.dart';
import 'package:n42_chat/src/presentation/blocs/points/points_state.dart';
import 'package:n42_chat/src/presentation/pages/points/leaderboard_page.dart';

class MockPointsBloc extends Mock implements PointsBloc {}

class FakePointsEvent extends Fake implements PointsEvent {}

void main() {
  late MockPointsBloc mockPointsBloc;
  late StreamController<PointsState> stateController;

  setUpAll(() {
    registerFallbackValue(FakePointsEvent());
  });

  setUp(() {
    mockPointsBloc = MockPointsBloc();
    stateController = StreamController<PointsState>.broadcast();

    when(
      () => mockPointsBloc.state,
    ).thenReturn(
      const PointsState(
        status: PointsStatus.error,
        errorMessage: 'balance load failed',
        leaderboardStatus: PointsLoadStatus.initial,
      ),
    );
    when(() => mockPointsBloc.stream).thenAnswer((_) => stateController.stream);
    when(() => mockPointsBloc.add(any())).thenReturn(null);
  });

  tearDown(() async {
    await stateController.close();
  });

  testWidgets('ignores unrelated points error state while leaderboard has no own error',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<PointsBloc>.value(
          value: mockPointsBloc,
          child: const LeaderboardPage(
            roomId: '!room:server',
            currentUserId: '@alice:server',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Failed to load leaderboard'), findsNothing);
    expect(find.text('No rankings yet'), findsOneWidget);
    verify(
      () => mockPointsBloc.add(const PointsLoadLeaderboard(roomId: '!room:server')),
    ).called(1);
    verify(
      () => mockPointsBloc.add(const PointsLoadConfig(roomId: '!room:server')),
    ).called(1);
  });

  testWidgets('shows unavailable message when leaderboard is disabled by config',
      (tester) async {
    when(
      () => mockPointsBloc.state,
    ).thenReturn(
      const PointsState(
        config: PointsConfig(
          roomId: '!room:server',
          isEnabled: true,
          showLeaderboard: false,
        ),
        leaderboardStatus: PointsLoadStatus.loaded,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<PointsBloc>.value(
          value: mockPointsBloc,
          child: const LeaderboardPage(
            roomId: '!room:server',
            currentUserId: '@alice:server',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Leaderboard is disabled in this room.'), findsOneWidget);
  });
}
