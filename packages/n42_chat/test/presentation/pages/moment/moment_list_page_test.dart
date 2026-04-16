import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/core/di/injection.dart';
import 'package:n42_chat/src/domain/entities/moment_entity.dart';
import 'package:n42_chat/src/presentation/blocs/contact/contact_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/contact/contact_state.dart';
import 'package:n42_chat/src/presentation/blocs/moment/moment_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/moment/moment_event.dart';
import 'package:n42_chat/src/presentation/blocs/moment/moment_state.dart';
import 'package:n42_chat/src/presentation/pages/moment/moment_list_page.dart';

class MockMomentBloc extends Mock implements MomentBloc {}

class MockContactBloc extends Mock implements ContactBloc {}

class FakeMomentEvent extends Fake implements MomentEvent {}

Widget _buildTestWidget({required ContactBloc contactBloc}) {
  return MaterialApp(
    localizationsDelegates: S.localizationsDelegates,
    supportedLocales: S.supportedLocales,
    locale: const Locale('en'),
    home: BlocProvider<ContactBloc>.value(
      value: contactBloc,
      child: const MomentListPage(),
    ),
  );
}

MomentEntity _buildMoment() {
  return MomentEntity(
    id: 'moment-1',
    userId: '@me:server.com',
    userName: 'Me',
    content: 'hello',
    timestamp: DateTime(2025, 6, 1),
    isFromMe: true,
  );
}

void main() {
  late MockMomentBloc mockMomentBloc;
  late MockContactBloc mockContactBloc;
  late StreamController<MomentState> momentStateController;
  late MomentState currentMomentState;

  setUpAll(() {
    registerFallbackValue(FakeMomentEvent());
  });

  setUp(() async {
    await getIt.reset();

    mockMomentBloc = MockMomentBloc();
    mockContactBloc = MockContactBloc();
    momentStateController = StreamController<MomentState>.broadcast();
    currentMomentState = MomentState(moments: [_buildMoment()], hasMore: false);

    when(() => mockMomentBloc.state).thenAnswer((_) => currentMomentState);
    when(
      () => mockMomentBloc.stream,
    ).thenAnswer((_) => momentStateController.stream);
    when(() => mockMomentBloc.add(any())).thenReturn(null);
    when(() => mockMomentBloc.close()).thenAnswer((_) async {});

    when(() => mockContactBloc.state).thenReturn(const ContactState.initial());
    when(
      () => mockContactBloc.stream,
    ).thenAnswer((_) => const Stream<ContactState>.empty());
    when(() => mockContactBloc.close()).thenAnswer((_) async {});

    getIt.registerFactory<MomentBloc>(() => mockMomentBloc);
  });

  tearDown(() async {
    await momentStateController.close();
    await getIt.reset();
  });

  testWidgets(
    'action popup anchors to the more button and hides FAB while visible',
    (tester) async {
      await tester.pumpWidget(_buildTestWidget(contactBloc: mockContactBloc));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);

      final moreButtonFinder = find.byIcon(Icons.more_horiz).first;
      final moreButtonRect = tester.getRect(moreButtonFinder);

      await tester.tap(moreButtonFinder);
      await tester.pumpAndSettle();

      expect(find.text('Comment'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing);

      final commentRect = tester.getRect(find.text('Comment'));
      expect(commentRect.left, lessThan(moreButtonRect.right));
      expect(commentRect.top, greaterThanOrEqualTo(moreButtonRect.top - 24));
      expect(commentRect.top, lessThanOrEqualTo(moreButtonRect.bottom + 24));

      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();

      expect(find.text('Comment'), findsNothing);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    },
  );

  testWidgets('delete dialog can read MomentBloc from the page route', (
    tester,
  ) async {
    await tester.pumpWidget(_buildTestWidget(contactBloc: mockContactBloc));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_horiz).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Delete Moment'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
