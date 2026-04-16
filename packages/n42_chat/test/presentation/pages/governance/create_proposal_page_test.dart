import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/presentation/blocs/governance/governance_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/governance/governance_event.dart';
import 'package:n42_chat/src/presentation/blocs/governance/governance_state.dart';
import 'package:n42_chat/src/presentation/pages/governance/create_proposal_page.dart';

class MockGovernanceBloc extends Mock implements GovernanceBloc {}

class FakeGovernanceEvent extends Fake implements GovernanceEvent {}

void main() {
  late MockGovernanceBloc mockGovernanceBloc;
  late StreamController<GovernanceState> stateController;

  setUpAll(() {
    registerFallbackValue(FakeGovernanceEvent());
  });

  setUp(() {
    mockGovernanceBloc = MockGovernanceBloc();
    stateController = StreamController<GovernanceState>.broadcast();

    when(
      () => mockGovernanceBloc.state,
    ).thenReturn(
      const GovernanceState(status: GovernanceStatus.loaded),
    );
    when(() => mockGovernanceBloc.stream).thenAnswer((_) => stateController.stream);
    when(() => mockGovernanceBloc.add(any())).thenReturn(null);
  });

  tearDown(() async {
    await stateController.close();
  });

  testWidgets('ignores unrelated governance errors before submit starts',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<GovernanceBloc>.value(
          value: mockGovernanceBloc,
          child: const CreateProposalPage(spaceId: 'space-1'),
        ),
      ),
    );
    await tester.pump();

    stateController.add(
      const GovernanceState(
        status: GovernanceStatus.error,
        errorMessage: 'background failure',
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('background failure'), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
  });
}
