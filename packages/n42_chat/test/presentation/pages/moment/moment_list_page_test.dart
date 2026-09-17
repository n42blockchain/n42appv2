import 'package:n42_chat/src/domain/entities/contact_entity.dart';
import 'package:n42_chat/src/presentation/pages/contact/contact_detail_page.dart';
import 'package:n42_chat/src/presentation/widgets/common/n42_avatar.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
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
import 'package:n42_chat/src/presentation/pages/moment/moment_detail_page.dart';

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
    'publishing from Moments retains friends for audience selection',
    (tester) async {
      when(() => mockContactBloc.state).thenReturn(
        const ContactState(
          status: ContactStatus.loaded,
          contacts: [
            ContactEntity(
              userId: '@alice:hs',
              displayName: 'Alice',
              isFriend: true,
            ),
          ],
        ),
      );
      await tester.pumpWidget(_buildTestWidget(contactBloc: mockContactBloc));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.camera_alt_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Public'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Selected Friends'));
      await tester.pumpAndSettle();
      expect(find.text('Alice'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('author avatar opens the correct contact profile', (
    tester,
  ) async {
    await tester.pumpWidget(_buildTestWidget(contactBloc: mockContactBloc));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate((w) => w is N42Avatar && w.size == 44),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<ContactDetailPage>(find.byType(ContactDetailPage)).userId,
      '@me:server.com',
    );
    expect(tester.takeException(), isNull);
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
      final popupRect = tester.getRect(find.byType(PopupMenuItem<int>).first);
      expect(popupRect.top, lessThanOrEqualTo(moreButtonRect.bottom + 8));
      expect(
        tester.getRect(find.byType(PopupMenuItem<int>).last).bottom,
        lessThanOrEqualTo(tester.view.physicalSize.height),
      );

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
  testWidgets('right click on a post opens actions and Like dispatches once', (
    tester,
  ) async {
    await tester.pumpWidget(_buildTestWidget(contactBloc: mockContactBloc));
    await tester.pumpAndSettle();
    await tester.tap(find.text('hello'), buttons: kSecondaryMouseButton);
    await tester.pumpAndSettle();
    expect(find.text('Like'), findsOneWidget);
    await tester.tap(find.text('Like'));
    await tester.pumpAndSettle();
    verify(() => mockMomentBloc.add(const LikeMoment('moment-1'))).called(1);
    expect(find.byType(PopupMenuItem<int>), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('post details entry retains the live moment bloc', (
    tester,
  ) async {
    await tester.pumpWidget(_buildTestWidget(contactBloc: mockContactBloc));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_horiz).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('View details'));
    await tester.pumpAndSettle();
    expect(find.byType(MomentDetailPage), findsOneWidget);
    expect(find.text('hello'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
