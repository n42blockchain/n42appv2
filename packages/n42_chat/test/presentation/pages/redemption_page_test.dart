import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/domain/entities/points/points_balance.dart';
import 'package:n42_chat/src/domain/entities/points/points_config.dart';
import 'package:n42_chat/src/domain/entities/points/redemption_item.dart';
import 'package:n42_chat/src/presentation/blocs/points/points_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/points/points_event.dart';
import 'package:n42_chat/src/presentation/blocs/points/points_state.dart';
import 'package:n42_chat/src/presentation/pages/points/redemption_page.dart';

class MockPointsBloc extends Mock implements PointsBloc {}

void main() {
  late MockPointsBloc mockPointsBloc;
  late StreamController<PointsState> stateController;

  const initialState = PointsState(
    status: PointsStatus.loaded,
    balance: PointsBalance(
      userId: '@alice:server',
      roomId: '!room:server',
      availablePoints: 120,
    ),
    redemptionItems: [
      RedemptionItem(
        id: 'item-1',
        name: 'VIP Badge',
        description: 'A shiny badge',
        cost: 50,
      ),
    ],
  );

  setUpAll(() {
    registerFallbackValue(const PointsLoadRedemptionItems(roomId: '!room:server'));
  });

  setUp(() {
    mockPointsBloc = MockPointsBloc();
    stateController = StreamController<PointsState>.broadcast();

    when(() => mockPointsBloc.state).thenReturn(initialState);
    when(() => mockPointsBloc.stream).thenAnswer((_) => stateController.stream);
    when(() => mockPointsBloc.add(any())).thenReturn(null);
  });

  tearDown(() async {
    await stateController.close();
  });

  Widget buildPage() {
    return MaterialApp(
      home: BlocProvider<PointsBloc>.value(
        value: mockPointsBloc,
        child: const RedemptionPage(
          userId: '@alice:server',
          roomId: '!room:server',
        ),
      ),
    );
  }

  testWidgets('load errors do not show redemption failure snackbar', (
    tester,
  ) async {
    await tester.pumpWidget(buildPage());
    await tester.pump();

    stateController.add(
      initialState.copyWith(
        status: PointsStatus.error,
        errorMessage: 'load failed',
      ),
    );
    await tester.pump();

    expect(find.text('load failed'), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
    verify(
      () => mockPointsBloc.add(const PointsLoadConfig(roomId: '!room:server')),
    ).called(1);
  });

  testWidgets('redemption action failure shows snackbar and clears feedback', (
    tester,
  ) async {
    await tester.pumpWidget(buildPage());
    await tester.pump();

    stateController.add(
      initialState.copyWith(
        redemptionStatus: PointsRedemptionStatus.failed,
        redemptionErrorMessage: 'redeem failed',
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('redeem failed'), findsOneWidget);
    verify(
      () => mockPointsBloc.add(const PointsClearRedemptionFeedback()),
    ).called(1);
  });

  testWidgets('shows unavailable message when points are disabled in the room',
      (tester) async {
    when(
      () => mockPointsBloc.state,
    ).thenReturn(
      const PointsState(
        config: PointsConfig(
          roomId: '!room:server',
          isEnabled: false,
        ),
      ),
    );

    await tester.pumpWidget(buildPage());
    await tester.pump();

    expect(find.text('Points are disabled in this room.'), findsOneWidget);
    expect(find.text('VIP Badge'), findsNothing);
  });
}
