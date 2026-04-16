import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/domain/entities/points/points_balance.dart';
import 'package:n42_chat/src/domain/entities/points/points_config.dart';
import 'package:n42_chat/src/presentation/blocs/points/points_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/points/points_event.dart';
import 'package:n42_chat/src/presentation/blocs/points/points_state.dart';
import 'package:n42_chat/src/presentation/pages/points/points_dashboard_page.dart';

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
        balance: PointsBalance(
          userId: '@alice:server',
          roomId: '!room:server',
          totalPoints: 120,
          availablePoints: 80,
          redeemedPoints: 40,
          rank: 2,
        ),
        balanceStatus: PointsLoadStatus.loaded,
        transactionsStatus: PointsLoadStatus.error,
        transactionsErrorMessage: 'transaction load failed',
      ),
    );
    when(() => mockPointsBloc.stream).thenAnswer((_) => stateController.stream);
    when(() => mockPointsBloc.add(any())).thenReturn(null);
  });

  tearDown(() async {
    await stateController.close();
  });

  testWidgets('shows transaction error section without replacing loaded balance view',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<PointsBloc>.value(
          value: mockPointsBloc,
          child: const PointsDashboardPage(
            userId: '@alice:server',
            roomId: '!room:server',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Total Points'), findsOneWidget);
    expect(find.text('Failed to load recent activity'), findsOneWidget);
    expect(find.text('Failed to load points'), findsNothing);
    verify(
      () => mockPointsBloc.add(
        const PointsLoadBalance(
          userId: '@alice:server',
          roomId: '!room:server',
        ),
      ),
    ).called(1);
    verify(
      () => mockPointsBloc.add(
        const PointsLoadTransactions(
          userId: '@alice:server',
          roomId: '!room:server',
        ),
      ),
    ).called(1);
    verify(
      () => mockPointsBloc.add(
        const PointsLoadConfig(roomId: '!room:server'),
      ),
    ).called(1);
  });

  testWidgets('hides leaderboard action when room config disables it',
      (tester) async {
    when(
      () => mockPointsBloc.state,
    ).thenReturn(
      const PointsState(
        balance: PointsBalance(
          userId: '@alice:server',
          roomId: '!room:server',
          totalPoints: 120,
          availablePoints: 80,
          redeemedPoints: 40,
          rank: 2,
        ),
        balanceStatus: PointsLoadStatus.loaded,
        transactionsStatus: PointsLoadStatus.loaded,
        config: PointsConfig(
          roomId: '!room:server',
          isEnabled: true,
          showLeaderboard: false,
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<PointsBloc>.value(
          value: mockPointsBloc,
          child: const PointsDashboardPage(
            userId: '@alice:server',
            roomId: '!room:server',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Leaderboard'), findsNothing);
    expect(find.text('Redeem'), findsOneWidget);
  });

  testWidgets('shows disabled message when points are turned off for the room',
      (tester) async {
    when(
      () => mockPointsBloc.state,
    ).thenReturn(
      const PointsState(
        balance: PointsBalance(
          userId: '@alice:server',
          roomId: '!room:server',
          totalPoints: 120,
          availablePoints: 80,
        ),
        balanceStatus: PointsLoadStatus.loaded,
        transactionsStatus: PointsLoadStatus.loaded,
        config: PointsConfig(
          roomId: '!room:server',
          isEnabled: false,
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<PointsBloc>.value(
          value: mockPointsBloc,
          child: const PointsDashboardPage(
            userId: '@alice:server',
            roomId: '!room:server',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Points are disabled in this room.'), findsOneWidget);
    expect(find.text('Leaderboard'), findsNothing);
    expect(find.text('Redeem'), findsNothing);
  });
}
