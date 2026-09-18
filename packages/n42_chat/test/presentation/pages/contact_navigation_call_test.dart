import 'package:matrix/matrix.dart' as matrix;
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';
import 'package:n42_chat/src/data/datasources/matrix/contact_privacy_service.dart';
import 'package:n42_chat/src/presentation/pages/contact/chat_only_friends_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/core/di/injection.dart';
import 'package:n42_chat/src/core/services/contact_call_service.dart';
import 'package:n42_chat/src/domain/entities/contact_entity.dart';
import 'package:n42_chat/src/domain/repositories/contact_repository.dart';
import 'package:n42_chat/src/presentation/blocs/contact/contact_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/contact/contact_state.dart';
import 'package:n42_chat/src/presentation/blocs/group/group_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/group/group_state.dart';
import 'package:n42_chat/src/presentation/pages/contact/contact_detail_page.dart';
import 'package:n42_chat/src/presentation/pages/contact/contact_list_page.dart';
import 'package:n42_chat/src/services/voip/call_manager.dart';

class _Contacts extends Mock implements ContactBloc {}

class _Manager extends Mock implements MatrixClientManager {}

class _MatrixClient extends Mock implements matrix.Client {}

class _Groups extends Mock implements GroupBloc {}

class _Repository extends Mock implements IContactRepository {}

class _Calls extends Mock implements CallManager {}

class _Launcher extends Mock implements ContactCallService {}

void main() {
  const friend = ContactEntity(
    userId: '@alice:hs',
    displayName: 'Alice',
    isFriend: true,
  );
  late _Contacts contacts;
  late _Repository repository;
  late _Calls calls;
  setUp(() async {
    await getIt.reset();
    contacts = _Contacts();
    repository = _Repository();
    calls = _Calls();
    final groups = _Groups();
    when(() => contacts.state).thenReturn(
      const ContactState(
        status: ContactStatus.loaded,
        contacts: [friend],
        groupedContacts: {
          'A': [friend],
        },
        indexLetters: ['A'],
      ),
    );
    when(() => contacts.stream).thenAnswer((_) => const Stream.empty());
    when(() => groups.state).thenReturn(const GroupState());
    when(() => groups.stream).thenAnswer((_) => const Stream.empty());
    when(() => groups.close()).thenAnswer((_) async {});
    getIt.registerSingleton<GroupBloc>(groups);
    getIt.registerSingleton<IContactRepository>(repository);
    when(
      () => repository.startDirectChat(any()),
    ).thenAnswer((_) async => '!direct:hs');
    when(() => calls.isInitialized).thenReturn(true);
    when(
      () => calls.startVideoCall(
        roomId: any(named: 'roomId'),
        peerId: any(named: 'peerId'),
        peerName: any(named: 'peerName'),
        peerAvatarUrl: any(named: 'peerAvatarUrl'),
      ),
    ).thenAnswer((_) async => true);
    when(
      () => calls.startVoiceCall(
        roomId: any(named: 'roomId'),
        peerId: any(named: 'peerId'),
        peerName: any(named: 'peerName'),
        peerAvatarUrl: any(named: 'peerAvatarUrl'),
      ),
    ).thenAnswer((_) async => true);
  });
  tearDown(() async => getIt.reset());
  Widget app(Widget page) => MaterialApp(
    localizationsDelegates: S.localizationsDelegates,
    supportedLocales: S.supportedLocales,
    home: BlocProvider<ContactBloc>.value(value: contacts, child: page),
  );

  testWidgets('chat-only row opens friend details and refreshes on return', (
    tester,
  ) async {
    final manager = _Manager();
    final client = _MatrixClient();
    when(() => manager.client).thenReturn(client);
    when(() => client.userID).thenReturn('@me:hs');
    when(() => client.accountData).thenReturn(<String, matrix.BasicEvent>{});
    var privacy = <String, dynamic>{
      friend.userId: {'chatOnly': true},
    };
    when(
      () => client.getAccountData('@me:hs', ContactPrivacyService.accountType),
    ).thenAnswer((_) async => privacy);
    when(() => repository.getContacts()).thenAnswer((_) async => [friend]);
    getIt.registerSingleton<MatrixClientManager>(manager);
    await tester.pumpWidget(app(const ContactListPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chat-only Friends'));
    await tester.pumpAndSettle();
    expect(find.byType(ChatOnlyFriendsPage), findsOneWidget);
    await tester.tap(find.text('Alice'));
    await tester.pumpAndSettle();
    expect(find.byType(ContactDetailPage), findsOneWidget);
    expect(
      tester.widget<ContactDetailPage>(find.byType(ContactDetailPage)).userId,
      friend.userId,
    );
    privacy = {};
    Navigator.of(tester.element(find.byType(ContactDetailPage))).pop();
    await tester.pumpAndSettle();
    expect(find.byType(ChatOnlyFriendsPage), findsOneWidget);
    expect(find.text('Alice'), findsNothing);
  });

  testWidgets('incoming request stays accessible when contacts fail to load', (
    tester,
  ) async {
    when(() => contacts.state).thenReturn(
      ContactState(
        status: ContactStatus.error,
        errorMessage: 'Membership unavailable',
        friendRequests: [
          FriendRequest(id: '!request:hs', userId: '@bob:hs', userName: 'Bob'),
        ],
      ),
    );
    await tester.pumpWidget(app(const ContactListPage()));
    await tester.pumpAndSettle();
    expect(find.text('New Friends'), findsOneWidget);
    await tester.tap(find.text('New Friends'));
    await tester.pumpAndSettle();
    expect(find.text('Bob'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final status in [
    ContactStatus.loading,
    ContactStatus.error,
    ContactStatus.chatStarted,
  ]) {
    testWidgets('cached contacts remain visible during $status', (
      tester,
    ) async {
      when(() => contacts.state).thenReturn(
        ContactState(
          status: status,
          contacts: const [friend],
          groupedContacts: const {
            'A': [friend],
          },
          indexLetters: const ['A'],
        ),
      );
      await tester.pumpWidget(app(const ContactListPage()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Alice'),
        250,
        scrollable: find
            .descendant(
              of: find.byType(CustomScrollView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('No contacts'), findsNothing);
    });
  }

  testWidgets('tapping a contact opens their profile without creating a chat', (
    tester,
  ) async {
    await tester.pumpWidget(app(const ContactListPage()));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Alice'),
      250,
      scrollable: find
          .descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.text('Alice'));
    await tester.pumpAndSettle();
    expect(find.byType(ContactDetailPage), findsOneWidget);
    final page = tester.widget<ContactDetailPage>(
      find.byType(ContactDetailPage),
    );
    expect(page.userId, friend.userId);
    expect(page.onSendMessage, isNotNull);
    verifyNever(() => repository.startDirectChat(any()));
  });

  testWidgets('outgoing requests show pending without acceptance controls', (
    tester,
  ) async {
    when(() => contacts.state).thenReturn(
      ContactState(
        status: ContactStatus.loaded,
        friendRequests: [
          FriendRequest(
            id: '!pending:hs',
            userId: '@alice:hs',
            userName: 'Alice',
            requestTime: DateTime(2026),
            isOutgoing: true,
          ),
        ],
      ),
    );
    await tester.pumpWidget(app(const ContactListPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New Friends'));
    await tester.pumpAndSettle();
    expect(find.text('Awaiting acceptance'), findsOneWidget);
    expect(find.text('Accept'), findsNothing);
    expect(find.text('Reject'), findsNothing);
  });

  testWidgets('acceptance does not report success when the server fails', (
    tester,
  ) async {
    when(() => contacts.state).thenReturn(
      const ContactState(
        status: ContactStatus.loaded,
        friendRequests: [
          FriendRequest(
            id: '!pending:hs',
            userId: '@alice:hs',
            userName: 'Alice',
          ),
        ],
      ),
    );
    when(
      () => repository.acceptFriendRequest('!pending:hs'),
    ).thenThrow(StateError('offline'));
    await tester.pumpWidget(app(const ContactListPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New Friends'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();
    expect(find.text('Save failed'), findsOneWidget);
    expect(find.textContaining('Accepted Alice'), findsNothing);
    expect(find.text('Accept'), findsOneWidget);
    verify(() => repository.acceptFriendRequest('!pending:hs')).called(1);
  });

  for (final video in [false, true]) {
    test(
      'call launcher resolves direct room and starts ${video ? 'video' : 'voice'} call',
      () async {
        final launcher = ContactCallService(repository, () async => calls);
        expect(
          await launcher.start(
            userId: friend.userId,
            name: 'Alice',
            video: video,
          ),
          isTrue,
        );
        verify(() => repository.startDirectChat(friend.userId)).called(1);
        if (video) {
          verify(
            () => calls.startVideoCall(
              roomId: '!direct:hs',
              peerId: friend.userId,
              peerName: 'Alice',
            ),
          ).called(1);
        } else {
          verify(
            () => calls.startVoiceCall(
              roomId: '!direct:hs',
              peerId: friend.userId,
              peerName: 'Alice',
            ),
          ).called(1);
        }
      },
    );
    testWidgets(
      'profile call sheet selects ${video ? 'video' : 'voice'} and starts once',
      (tester) async {
        final launcher = _Launcher();
        when(
          () => launcher.start(
            userId: any(named: 'userId'),
            name: any(named: 'name'),
            avatarUrl: any(named: 'avatarUrl'),
            video: any(named: 'video'),
          ),
        ).thenAnswer((_) async => true);
        await tester.pumpWidget(
          app(
            ContactDetailPage(
              userId: friend.userId,
              displayName: 'Alice',
              callService: launcher,
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Audio/Video Call'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(video ? 'Video Call' : 'Voice Call'));
        await tester.pumpAndSettle();
        verify(
          () => launcher.start(
            userId: friend.userId,
            name: 'Alice',
            avatarUrl: null,
            video: video,
          ),
        ).called(1);
      },
    );
  }
  testWidgets('call cancellation does not dial and failures are visible', (
    tester,
  ) async {
    final launcher = _Launcher();
    when(
      () => launcher.start(
        userId: any(named: 'userId'),
        name: any(named: 'name'),
        avatarUrl: any(named: 'avatarUrl'),
        video: any(named: 'video'),
      ),
    ).thenAnswer((_) async => false);
    await tester.pumpWidget(
      app(
        ContactDetailPage(
          userId: friend.userId,
          displayName: 'Alice',
          callService: launcher,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Audio/Video Call'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    verifyNever(
      () => launcher.start(
        userId: any(named: 'userId'),
        name: any(named: 'name'),
        avatarUrl: any(named: 'avatarUrl'),
        video: any(named: 'video'),
      ),
    );
    await tester.tap(find.text('Audio/Video Call'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Voice Call'));
    await tester.pumpAndSettle();
    expect(find.text('Call failed'), findsOneWidget);
  });
  test('missing call service does not create a direct room', () async {
    final launcher = ContactCallService(repository, () async => null);
    await expectLater(
      launcher.start(userId: friend.userId, name: 'Alice', video: false),
      throwsStateError,
    );
    verifyNever(() => repository.startDirectChat(any()));
  });
}
