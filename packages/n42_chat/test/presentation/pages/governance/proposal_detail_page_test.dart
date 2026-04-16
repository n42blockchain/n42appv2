import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/domain/entities/governance/proposal_entity.dart';
import 'package:n42_chat/src/presentation/blocs/governance/governance_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/governance/governance_event.dart';
import 'package:n42_chat/src/presentation/blocs/governance/governance_state.dart';
import 'package:n42_chat/src/presentation/pages/governance/proposal_detail_page.dart';

class MockGovernanceBloc extends Mock implements GovernanceBloc {}

class FakeGovernanceEvent extends Fake implements GovernanceEvent {}

void main() {
  late MockGovernanceBloc mockGovernanceBloc;
  late StreamController<GovernanceState> stateController;

  final staleProposal = ProposalEntity(
    id: 'proposal-old',
    spaceId: 'space-1',
    title: 'Old proposal',
    body: 'Old body',
    author: '0xabc',
    state: ProposalState.active,
    choices: const ['Yes', 'No'],
    startTime: DateTime(2026, 1, 1, 10),
    endTime: DateTime(2026, 1, 4, 10),
  );

  setUpAll(() {
    registerFallbackValue(FakeGovernanceEvent());
  });

  setUp(() {
    mockGovernanceBloc = MockGovernanceBloc();
    stateController = StreamController<GovernanceState>.broadcast();

    when(
      () => mockGovernanceBloc.state,
    ).thenReturn(
      GovernanceState(
        status: GovernanceStatus.loaded,
        selectedProposal: staleProposal,
      ),
    );
    when(() => mockGovernanceBloc.stream).thenAnswer((_) => stateController.stream);
    when(() => mockGovernanceBloc.add(any())).thenReturn(null);
  });

  tearDown(() async {
    await stateController.close();
  });

  testWidgets('does not render stale proposal content from another detail page',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<GovernanceBloc>.value(
          value: mockGovernanceBloc,
          child: const ProposalDetailPage(
            proposalId: 'proposal-new',
            spaceId: 'space-1',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Old proposal'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    verify(
      () => mockGovernanceBloc.add(
        const GovernanceLoadProposalDetail('proposal-new'),
      ),
    ).called(1);
  });
}
