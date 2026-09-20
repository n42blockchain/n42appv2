import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:n42_chat/src/domain/entities/conversation_entity.dart';
import 'package:n42_chat/src/presentation/pages/chat/chat_detail_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/core/di/injection.dart';
import 'package:n42_chat/src/core/services/remark_service.dart';
import 'package:n42_chat/src/data/datasources/local/preferences_datasource.dart';
import 'package:n42_chat/src/domain/entities/contact_entity.dart';
import 'package:n42_chat/src/domain/repositories/contact_repository.dart';
import 'package:n42_chat/src/presentation/blocs/contact/contact_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/contact/contact_state.dart';
import 'package:n42_chat/src/presentation/pages/contact/contact_detail_page.dart';

class MockContactRepository extends Mock implements IContactRepository {}

class MockContactBloc extends Mock implements ContactBloc {}

class MockPreferencesDataSource extends Mock implements PreferencesDataSource {}

Widget _buildTestWidget(Widget child, {ContactBloc? contactBloc}) {
  final app = MaterialApp(
    localizationsDelegates: S.localizationsDelegates,
    supportedLocales: S.supportedLocales,
    locale: const Locale('en'),
    home: child,
  );

  if (contactBloc == null) {
    return app;
  }

  return BlocProvider<ContactBloc>.value(value: contactBloc, child: app);
}

void main() {
  late MockContactBloc mockContactBloc;
  late StreamController<ContactState> contactStateController;
  late MockPreferencesDataSource mockPreferencesDataSource;

  const userId = '@alice:server.com';
  const contact = ContactEntity(
    userId: userId,
    displayName: 'Alice',
    isFriend: true,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockContactBloc = MockContactBloc();
    contactStateController = StreamController<ContactState>.broadcast();
    mockPreferencesDataSource = MockPreferencesDataSource();

    when(() => mockContactBloc.state).thenReturn(
      const ContactState(status: ContactStatus.loaded, contacts: [contact]),
    );
    when(
      () => mockContactBloc.stream,
    ).thenAnswer((_) => contactStateController.stream);
    when(
      () => mockPreferencesDataSource.setContactRemark(any(), any()),
    ).thenAnswer((_) async {});
    when(
      () => mockPreferencesDataSource.getContactRemarks(),
    ).thenAnswer((_) async => <String, String>{});

    if (getIt.isRegistered<PreferencesDataSource>()) {
      getIt.unregister<PreferencesDataSource>();
    }
    getIt.registerSingleton<PreferencesDataSource>(mockPreferencesDataSource);
    await RemarkService.instance.refresh();
  });

  tearDown(() async {
    await contactStateController.close();
    if (getIt.isRegistered<PreferencesDataSource>()) {
      getIt.unregister<PreferencesDataSource>();
    }
  });

  testWidgets(
    'shared card resolves existing friendship before contacts hydrate',
    (tester) async {
      final repository = MockContactRepository();
      when(
        () => repository.getContactById(userId),
      ).thenAnswer((_) async => contact);
      when(() => mockContactBloc.state).thenReturn(const ContactState());
      getIt.registerSingleton<IContactRepository>(repository);
      addTearDown(() async {
        await getIt.unregister<IContactRepository>();
      });
      await tester.pumpWidget(
        _buildTestWidget(
          const ContactDetailPage(userId: userId, displayName: 'Alice'),
          contactBloc: mockContactBloc,
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('contact_relationship_action')),
        findsNothing,
      );
      verify(() => repository.getContactById(userId)).called(1);
      expect(tester.takeException(), isNull);
    },
  );

  for (final deleted in [false, true]) {
    testWidgets(
      'late relationship lookup respects bloc update (deleted: $deleted)',
      (tester) async {
        final repository = MockContactRepository();
        final lookup = Completer<ContactEntity?>();
        when(
          () => repository.getContactById(userId),
        ).thenAnswer((_) => lookup.future);
        when(
          () => repository.getPendingFriendRequests(),
        ).thenAnswer((_) async => []);
        when(() => mockContactBloc.state).thenReturn(const ContactState());
        getIt.registerSingleton<IContactRepository>(repository);
        addTearDown(() async => getIt.unregister<IContactRepository>());
        await tester.pumpWidget(
          _buildTestWidget(
            const ContactDetailPage(userId: userId, displayName: 'Alice'),
            contactBloc: mockContactBloc,
          ),
        );
        await tester.pump();
        final updated = deleted
            ? const ContactState(
                status: ContactStatus.deleted,
                deletedUserId: userId,
              )
            : const ContactState(
                status: ContactStatus.loaded,
                contacts: [contact],
              );
        when(() => mockContactBloc.state).thenReturn(updated);
        contactStateController.add(updated);
        await tester.pump();
        // Return the opposite relationship after the newer Bloc update.
        lookup.complete(deleted ? contact : contact.copyWith(isFriend: false));
        await tester.pumpAndSettle();
        expect(
          find.text('Add to Contacts'),
          deleted ? findsOneWidget : findsNothing,
        );
        if (!deleted) {
          final label = S
              .of(tester.element(find.byType(ContactDetailPage)))!
              .commonSendMessage;
          expect(find.text(label), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'standalone relationship failure offers retry and resolves existing friend',
    (tester) async {
      final repository = MockContactRepository();
      when(
        () => repository.getContactById(userId),
      ).thenThrow(StateError('offline'));
      getIt.registerSingleton<IContactRepository>(repository);
      addTearDown(() async {
        await getIt.unregister<IContactRepository>();
      });
      await tester.pumpWidget(
        _buildTestWidget(
          const ContactDetailPage(userId: userId, displayName: 'Alice'),
        ),
      );
      await tester.pumpAndSettle();
      final action = find.byKey(const ValueKey('contact_relationship_action'));
      await tester.ensureVisible(action);
      expect(find.text('Retry'), findsOneWidget);
      when(
        () => repository.getContactById(userId),
      ).thenAnswer((_) async => contact);
      await tester.tap(action);
      await tester.pumpAndSettle();
      expect(action, findsNothing);
      verify(() => repository.getContactById(userId)).called(2);
      verifyNever(() => repository.startDirectChat(any()));
      expect(tester.takeException(), isNull);
    },
  );

  for (final outgoing in [true, false]) {
    testWidgets(
      'profile shows pending request direction (outgoing: $outgoing)',
      (tester) async {
        when(() => mockContactBloc.state).thenReturn(
          ContactState(
            status: ContactStatus.loaded,
            friendRequests: [
              FriendRequest(
                id: '!request:server.com',
                userId: userId,
                userName: 'Alice',
                isOutgoing: outgoing,
              ),
            ],
          ),
        );
        await tester.pumpWidget(
          _buildTestWidget(
            const ContactDetailPage(userId: userId, displayName: 'Alice'),
            contactBloc: mockContactBloc,
          ),
        );
        await tester.pumpAndSettle();
        final button = find.byKey(
          const ValueKey('contact_relationship_action'),
        );
        await tester.ensureVisible(button);
        expect(tester.widget<FilledButton>(button).onPressed == null, outgoing);
        expect(
          find.text(outgoing ? 'Request sent' : 'New Friends'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final hasPeer in [true, false]) {
    testWidgets(
      'chat details never use a room ID as a user ID (peer: $hasPeer)',
      (tester) async {
        const peer = '@navigation:server.com';
        when(() => mockContactBloc.state).thenReturn(
          const ContactState(
            status: ContactStatus.loaded,
            contacts: [
              ContactEntity(
                userId: peer,
                displayName: 'Navigation',
                isFriend: true,
              ),
            ],
          ),
        );
        await tester.pumpWidget(
          _buildTestWidget(
            ChatDetailPage(
              conversation: ConversationEntity(
                id: '!room:server.com',
                name: 'Navigation',
                type: ConversationType.direct,
                directUserId: hasPeer ? peer : null,
              ),
            ),
            contactBloc: mockContactBloc,
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Navigation').first);
        await tester.pumpAndSettle();
        if (hasPeer) {
          final page = tester.widget<ContactDetailPage>(
            find.byType(ContactDetailPage),
          );
          expect(page.userId, peer);
          expect(find.text('Add to Contacts'), findsNothing);
        } else {
          expect(find.byType(ContactDetailPage), findsNothing);
          expect(find.text('Failed to load'), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final status in [
    ContactStatus.chatStarted,
    ContactStatus.remarkUpdated,
    ContactStatus.loading,
  ]) {
    testWidgets('known friend keeps message actions during $status', (
      tester,
    ) async {
      when(
        () => mockContactBloc.state,
      ).thenReturn(ContactState(status: status, contacts: [contact]));
      await tester.pumpWidget(
        _buildTestWidget(
          const ContactDetailPage(userId: userId, displayName: 'Alice'),
          contactBloc: mockContactBloc,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Add to Contacts'), findsNothing);
      expect(
        find.text(
          S
              .of(tester.element(find.byType(ContactDetailPage)))!
              .commonSendMessage,
        ),
        findsOneWidget,
      );
    });
  }

  testWidgets('deleted friend returns to add action', (tester) async {
    await tester.pumpWidget(
      _buildTestWidget(
        const ContactDetailPage(userId: userId, displayName: 'Alice'),
        contactBloc: mockContactBloc,
      ),
    );
    await tester.pumpAndSettle();
    const deleted = ContactState(
      status: ContactStatus.deleted,
      deletedUserId: userId,
    );
    when(() => mockContactBloc.state).thenReturn(deleted);
    contactStateController.add(deleted);
    await tester.pumpAndSettle();
    expect(find.text('Add to Contacts'), findsOneWidget);
  });

  testWidgets(
    'ContactDetailPage updates display name when bloc remark updates',
    (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(
          const ContactDetailPage(userId: userId, displayName: 'Alice'),
          contactBloc: mockContactBloc,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsWidgets);

      contactStateController.add(
        const ContactState(
          status: ContactStatus.remarkUpdated,
          updatedRemarkUserId: userId,
          updatedRemark: 'Buddy',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Buddy'), findsWidgets);
    },
  );

  testWidgets(
    'ContactDetailPage updates display name from RemarkService without bloc',
    (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(
          const ContactDetailPage(
            userId: '@remark-only:server.com',
            displayName: 'RemarkOnly',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('RemarkOnly'), findsWidgets);

      await RemarkService.instance.setRemark(
        '@remark-only:server.com',
        'Cached Remark',
      );
      await tester.pumpAndSettle();

      expect(find.text('Cached Remark'), findsWidgets);
    },
  );
}
