import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/domain/entities/moment_entity.dart';
import 'package:n42_chat/src/presentation/blocs/moment/moment_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/moment/moment_event.dart';
import 'package:n42_chat/src/presentation/blocs/moment/moment_state.dart';
import 'package:n42_chat/src/presentation/pages/moment/moment_detail_page.dart';

class MockMomentBloc extends Mock implements MomentBloc {}

class FakeMomentEvent extends Fake implements MomentEvent {}

Widget _buildTestWidget({
  required MomentBloc momentBloc,
  required MomentEntity moment,
}) {
  return MaterialApp(
    localizationsDelegates: S.localizationsDelegates,
    supportedLocales: S.supportedLocales,
    locale: const Locale('en'),
    home: BlocProvider<MomentBloc>.value(
      value: momentBloc,
      child: MomentDetailPage(moment: moment),
    ),
  );
}

MomentEntity _buildMoment() {
  return MomentEntity(
    id: 'm-1',
    userId: '@author:server.com',
    userName: 'Author',
    content: 'Test moment',
    timestamp: DateTime(2025, 6, 1),
    comments: [
      MomentComment(
        id: 'c-1',
        userId: '@author:server.com',
        userName: 'Author',
        content: 'Existing comment',
        timestamp: DateTime(2025, 6, 1, 0, 1),
      ),
    ],
  );
}

void main() {
  late MockMomentBloc mockMomentBloc;
  late StreamController<MomentState> momentStateController;
  late MomentEntity moment;
  late MomentState currentState;

  setUpAll(() {
    registerFallbackValue(FakeMomentEvent());
  });

  setUp(() {
    mockMomentBloc = MockMomentBloc();
    momentStateController = StreamController<MomentState>.broadcast();
    moment = _buildMoment();
    currentState = MomentState(moments: [moment]);

    when(() => mockMomentBloc.state).thenAnswer((_) => currentState);
    when(() => mockMomentBloc.stream)
        .thenAnswer((_) => momentStateController.stream);
    when(() => mockMomentBloc.add(any())).thenReturn(null);
    when(() => mockMomentBloc.close()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await momentStateController.close();
  });

  testWidgets('failed comment submission keeps draft text and reply target',
      (tester) async {
    await tester.pumpWidget(
      _buildTestWidget(momentBloc: mockMomentBloc, moment: moment),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Existing comment'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.close), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Draft reply');
    await tester.pump();

    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();

    verify(
      () => mockMomentBloc.add(
        const CommentMoment(
          momentId: 'm-1',
          content: 'Draft reply',
          replyToCommentId: 'c-1',
          replyToUserId: '@author:server.com',
        ),
      ),
    ).called(1);

    currentState = currentState.copyWith(
      errorMessage: 'comment failed',
      commentSubmissionVersion: 1,
      commentSubmissionMomentId: 'm-1',
      commentSubmissionStatus: MomentCommentSubmissionStatus.failure,
    );
    momentStateController.add(currentState);
    await tester.pumpAndSettle();

    expect(find.text('Draft reply'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.text('comment failed'), findsOneWidget);
  });

  testWidgets('successful comment submission clears draft and reply target',
      (tester) async {
    await tester.pumpWidget(
      _buildTestWidget(momentBloc: mockMomentBloc, moment: moment),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Existing comment'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.close), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Draft to clear');
    await tester.pump();

    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();

    currentState = currentState.copyWith(
      moments: [
        moment.addComment(
          MomentComment(
            id: 'c-2',
            userId: '@me:server.com',
            userName: 'Me',
            content: 'Server saved comment',
            timestamp: DateTime(2025, 6, 1, 0, 2),
          ),
        ),
      ],
      clearError: true,
      commentSubmissionVersion: 1,
      commentSubmissionMomentId: 'm-1',
      commentSubmissionStatus: MomentCommentSubmissionStatus.success,
    );
    momentStateController.add(currentState);
    await tester.pumpAndSettle();

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.controller?.text, isEmpty);
    expect(find.byIcon(Icons.close), findsNothing);
  });
}
