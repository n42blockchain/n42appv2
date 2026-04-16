import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/core/services/remark_service.dart';
import 'package:n42_chat/src/data/datasources/local/preferences_datasource.dart';
import 'package:n42_chat/src/core/di/injection.dart';
import 'package:n42_chat/src/domain/entities/contact_entity.dart';
import 'package:n42_chat/src/domain/repositories/contact_repository.dart';
import 'package:n42_chat/src/presentation/blocs/contact/contact_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/contact/contact_event.dart';
import 'package:n42_chat/src/presentation/blocs/contact/contact_state.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockContactRepository extends Mock implements IContactRepository {}

class MockPreferencesDataSource extends Mock implements PreferencesDataSource {}

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

const _userId1 = '@alice:server.com';
const _userId2 = '@bob:server.com';
const _userId3 = '@carol:server.com';
const _roomId1 = '!dm1:server.com';

const _contact1 = ContactEntity(
  userId: _userId1,
  displayName: 'Alice',
  isFriend: true,
  directRoomId: _roomId1,
);

const _contact2 = ContactEntity(
  userId: _userId2,
  displayName: 'Bob',
  isFriend: true,
);

const _contact3 = ContactEntity(
  userId: _userId3,
  displayName: 'Carol',
);

final _friendRequest1 = FriendRequest(
  id: '!req1:server.com',
  userId: _userId3,
  userName: 'Carol',
  requestTime: DateTime(2024, 1, 1),
);

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

void main() {
  late MockContactRepository mockRepository;
  late MockPreferencesDataSource mockPreferences;

  setUpAll(() {
    // Register PreferencesDataSource in GetIt for RemarkService
    if (!getIt.isRegistered<PreferencesDataSource>()) {
      getIt.registerSingleton<PreferencesDataSource>(MockPreferencesDataSource());
    }
  });

  setUp(() {
    mockRepository = MockContactRepository();
    mockPreferences = getIt<PreferencesDataSource>() as MockPreferencesDataSource;

    // Default stubs
    when(() => mockRepository.watchContacts())
        .thenAnswer((_) => const Stream.empty());
    when(() => mockRepository.watchOnlineStatus())
        .thenAnswer((_) => const Stream.empty());

    // RemarkService stubs
    when(() => mockPreferences.getContactRemarks())
        .thenAnswer((_) async => {});
    when(() => mockPreferences.setContactRemark(any(), any()))
        .thenAnswer((_) async {});
    when(() => mockPreferences.getContactRemark(any()))
        .thenAnswer((_) async => null);
  });

  // =========================================================================
  // Initial state
  // =========================================================================

  group('initial state', () {
    test('should be ContactState.initial with ContactStatus.initial', () {
      final bloc = ContactBloc(mockRepository);
      addTearDown(bloc.close);

      expect(bloc.state, const ContactState.initial());
      expect(bloc.state.status, ContactStatus.initial);
      expect(bloc.state.contacts, isEmpty);
      expect(bloc.state.filteredContacts, isEmpty);
      expect(bloc.state.searchResults, isEmpty);
      expect(bloc.state.friendRequests, isEmpty);
      expect(bloc.state.searchQuery, isEmpty);
      expect(bloc.state.isSearching, isFalse);
      expect(bloc.state.isGlobalSearching, isFalse);
      expect(bloc.state.startedChatRoomId, isNull);
      expect(bloc.state.errorMessage, isNull);
    });

    test('convenience getters reflect initial state', () {
      const state = ContactState.initial();

      expect(state.isLoading, isFalse);
      expect(state.isLoaded, isFalse);
      expect(state.hasError, isFalse);
    });
  });

  // =========================================================================
  // ContactState copyWith & getters
  // =========================================================================

  group('ContactState', () {
    test('copyWith preserves existing fields when not overridden', () {
      final state = const ContactState.initial().copyWith(
        status: ContactStatus.loaded,
        contacts: [_contact1],
      );

      final next = state.copyWith(status: ContactStatus.loading);

      expect(next.status, ContactStatus.loading);
      expect(next.contacts, [_contact1], reason: 'contacts should be preserved');
    });

    test('copyWith clears transient fields when not provided', () {
      final state = const ContactState.initial().copyWith(
        status: ContactStatus.chatStarted,
        startedChatRoomId: _roomId1,
        startedChatUserId: _userId1,
        errorMessage: 'err',
      );

      final next = state.copyWith(status: ContactStatus.loaded);

      expect(next.startedChatRoomId, isNull);
      expect(next.startedChatUserId, isNull);
      expect(next.errorMessage, isNull);
    });

    test('isLoading returns true only when status is loading', () {
      final state = const ContactState.initial().copyWith(status: ContactStatus.loading);
      expect(state.isLoading, isTrue);
    });

    test('isLoaded returns true when contacts is non-empty', () {
      final state = const ContactState.initial().copyWith(
        status: ContactStatus.initial,
        contacts: [_contact1],
      );
      expect(state.isLoaded, isTrue);
    });

    test('hasError returns true only when status is error AND errorMessage is set', () {
      final withBoth = const ContactState.initial().copyWith(
        status: ContactStatus.error,
        errorMessage: 'something went wrong',
      );
      expect(withBoth.hasError, isTrue);

      final withoutMessage = const ContactState.initial().copyWith(
        status: ContactStatus.error,
      );
      expect(withoutMessage.hasError, isFalse);
    });

    test('Equatable: two states with same props are equal', () {
      final a = const ContactState.initial().copyWith(
        status: ContactStatus.loaded,
        contacts: [_contact1],
      );
      final b = const ContactState.initial().copyWith(
        status: ContactStatus.loaded,
        contacts: [_contact1],
      );
      expect(a, equals(b));
    });
  });

  // =========================================================================
  // LoadContacts
  // =========================================================================

  group('LoadContacts', () {
    blocTest<ContactBloc, ContactState>(
      'emits [loading, loaded] with contacts and friend requests on success',
      build: () {
        when(() => mockRepository.getContacts())
            .thenAnswer((_) async => [_contact1, _contact2]);
        when(() => mockRepository.getPendingFriendRequests())
            .thenAnswer((_) async => [_friendRequest1]);
        return ContactBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const LoadContacts()),
      expect: () => [
        isA<ContactState>()
            .having((s) => s.status, 'status', ContactStatus.loading),
        isA<ContactState>()
            .having((s) => s.status, 'status', ContactStatus.loaded)
            .having((s) => s.contacts.length, 'contacts.length', 2)
            .having((s) => s.filteredContacts.length, 'filteredContacts.length', 2)
            .having((s) => s.friendRequests.length, 'friendRequests.length', 1),
      ],
      verify: (_) {
        verify(() => mockRepository.watchContacts()).called(1);
        verify(() => mockRepository.watchOnlineStatus()).called(1);
        verify(() => mockRepository.getContacts()).called(1);
        verify(() => mockRepository.getPendingFriendRequests()).called(1);
      },
    );

    blocTest<ContactBloc, ContactState>(
      'emits [loading, error] when getContacts throws',
      build: () {
        when(() => mockRepository.getContacts())
            .thenThrow(Exception('network error'));
        when(() => mockRepository.getPendingFriendRequests())
            .thenAnswer((_) async => []);
        return ContactBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const LoadContacts()),
      expect: () => [
        isA<ContactState>()
            .having((s) => s.status, 'status', ContactStatus.loading),
        isA<ContactState>()
            .having((s) => s.status, 'status', ContactStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', contains('network error')),
      ],
    );

    blocTest<ContactBloc, ContactState>(
      'populates groupedContacts and indexLetters',
      build: () {
        when(() => mockRepository.getContacts())
            .thenAnswer((_) async => [_contact1, _contact2]);
        when(() => mockRepository.getPendingFriendRequests())
            .thenAnswer((_) async => []);
        return ContactBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const LoadContacts()),
      expect: () => [
        isA<ContactState>()
            .having((s) => s.status, 'status', ContactStatus.loading),
        isA<ContactState>()
            .having((s) => s.groupedContacts.isNotEmpty, 'groupedContacts.isNotEmpty', true)
            .having((s) => s.indexLetters.contains('A'), 'contains A', true)
            .having((s) => s.indexLetters.contains('B'), 'contains B', true),
      ],
    );
  });

  // =========================================================================
  // RefreshContacts
  // =========================================================================

  group('RefreshContacts', () {
    blocTest<ContactBloc, ContactState>(
      'delegates to LoadContacts when status is initial',
      build: () {
        when(() => mockRepository.getContacts())
            .thenAnswer((_) async => [_contact1]);
        when(() => mockRepository.getPendingFriendRequests())
            .thenAnswer((_) async => []);
        return ContactBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const RefreshContacts()),
      expect: () => [
        // LoadContacts: loading
        isA<ContactState>()
            .having((s) => s.status, 'status', ContactStatus.loading),
        // LoadContacts: loaded
        isA<ContactState>()
            .having((s) => s.status, 'status', ContactStatus.loaded),
      ],
    );

    blocTest<ContactBloc, ContactState>(
      'emits [loaded] without loading intermediate when already loaded',
      build: () {
        when(() => mockRepository.getContacts())
            .thenAnswer((_) async => [_contact1, _contact2]);
        when(() => mockRepository.getPendingFriendRequests())
            .thenAnswer((_) async => []);
        return ContactBloc(mockRepository);
      },
      seed: () => const ContactState.initial().copyWith(
        status: ContactStatus.loaded,
        contacts: [_contact1],
      ),
      act: (bloc) => bloc.add(const RefreshContacts()),
      expect: () => [
        isA<ContactState>()
            .having((s) => s.status, 'status', ContactStatus.loaded)
            .having((s) => s.contacts.length, 'contacts.length', 2),
      ],
    );

    blocTest<ContactBloc, ContactState>(
      'emits [error] when refresh fails',
      build: () {
        when(() => mockRepository.getContacts())
            .thenThrow(Exception('refresh failed'));
        when(() => mockRepository.getPendingFriendRequests())
            .thenAnswer((_) async => []);
        return ContactBloc(mockRepository);
      },
      seed: () => const ContactState.initial().copyWith(
        status: ContactStatus.loaded,
      ),
      act: (bloc) => bloc.add(const RefreshContacts()),
      expect: () => [
        isA<ContactState>()
            .having((s) => s.status, 'status', ContactStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', contains('refresh failed')),
      ],
    );

    blocTest<ContactBloc, ContactState>(
      'preserves search query and filteredContacts during refresh if searching',
      build: () {
        when(() => mockRepository.getContacts())
            .thenAnswer((_) async => [_contact1, _contact2]);
        when(() => mockRepository.getPendingFriendRequests())
            .thenAnswer((_) async => []);
        return ContactBloc(mockRepository);
      },
      seed: () => const ContactState.initial().copyWith(
        status: ContactStatus.loaded,
        contacts: [_contact1, _contact2],
        filteredContacts: [_contact1],
        searchQuery: 'Alice',
      ),
      act: (bloc) => bloc.add(const RefreshContacts()),
      expect: () => [
        isA<ContactState>()
            .having((s) => s.status, 'status', ContactStatus.loaded)
            .having((s) => s.contacts.length, 'contacts.length', 2)
            // When searchQuery is non-empty, filteredContacts should be preserved
            .having((s) => s.filteredContacts.length, 'filteredContacts.length', 1),
      ],
    );
  });

  // =========================================================================
  // SearchContacts
  // =========================================================================

  group('SearchContacts', () {
    blocTest<ContactBloc, ContactState>(
      'resets filteredContacts to all contacts when query is empty',
      build: () => ContactBloc(mockRepository),
      seed: () => const ContactState.initial().copyWith(
        status: ContactStatus.loaded,
        contacts: [_contact1, _contact2],
        filteredContacts: [_contact1],
        searchQuery: 'Alice',
      ),
      act: (bloc) => bloc.add(const SearchContacts('')),
      expect: () => [
        isA<ContactState>()
            .having((s) => s.filteredContacts.length, 'filteredContacts.length', 2)
            .having((s) => s.searchQuery, 'searchQuery', '')
            .having((s) => s.isSearching, 'isSearching', false),
      ],
    );

    blocTest<ContactBloc, ContactState>(
      'emits searching state then results',
      build: () {
        when(() => mockRepository.searchContacts('Alice'))
            .thenAnswer((_) async => [_contact1]);
        return ContactBloc(mockRepository);
      },
      seed: () => const ContactState.initial().copyWith(
        status: ContactStatus.loaded,
        contacts: [_contact1, _contact2],
      ),
      act: (bloc) => bloc.add(const SearchContacts('Alice')),
      expect: () => [
        isA<ContactState>()
            .having((s) => s.isSearching, 'isSearching', true)
            .having((s) => s.searchQuery, 'searchQuery', 'Alice'),
        isA<ContactState>()
            .having((s) => s.isSearching, 'isSearching', false)
            .having((s) => s.filteredContacts, 'filteredContacts', [_contact1])
            .having((s) => s.searchQuery, 'searchQuery', 'Alice'),
      ],
    );

    blocTest<ContactBloc, ContactState>(
      'handles search error gracefully',
      build: () {
        when(() => mockRepository.searchContacts('fail'))
            .thenThrow(Exception('search error'));
        return ContactBloc(mockRepository);
      },
      seed: () => const ContactState.initial().copyWith(
        status: ContactStatus.loaded,
        contacts: [_contact1],
      ),
      act: (bloc) => bloc.add(const SearchContacts('fail')),
      expect: () => [
        isA<ContactState>()
            .having((s) => s.isSearching, 'isSearching', true),
        isA<ContactState>()
            .having((s) => s.isSearching, 'isSearching', false),
      ],
    );
  });

  // =========================================================================
  // SearchUsers (global search)
  // =========================================================================

  group('SearchUsers', () {
    blocTest<ContactBloc, ContactState>(
      'clears search results when query is empty',
      build: () => ContactBloc(mockRepository),
      act: (bloc) => bloc.add(const SearchUsers('')),
      expect: () => [
        isA<ContactState>()
            .having((s) => s.searchResults, 'searchResults', isEmpty)
            .having((s) => s.isGlobalSearching, 'isGlobalSearching', false),
      ],
    );

    blocTest<ContactBloc, ContactState>(
      'emits global searching state then results',
      build: () {
        when(() => mockRepository.searchUsers('Carol', limit: 20))
            .thenAnswer((_) async => [_contact3]);
        return ContactBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const SearchUsers('Carol')),
      expect: () => [
        isA<ContactState>()
            .having((s) => s.isGlobalSearching, 'isGlobalSearching', true),
        isA<ContactState>()
            .having((s) => s.isGlobalSearching, 'isGlobalSearching', false)
            .having((s) => s.searchResults, 'searchResults', [_contact3]),
      ],
    );

    blocTest<ContactBloc, ContactState>(
      'handles global search error gracefully',
      build: () {
        when(() => mockRepository.searchUsers('fail', limit: 20))
            .thenThrow(Exception('global search error'));
        return ContactBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const SearchUsers('fail')),
      expect: () => [
        isA<ContactState>()
            .having((s) => s.isGlobalSearching, 'isGlobalSearching', true),
        isA<ContactState>()
            .having((s) => s.isGlobalSearching, 'isGlobalSearching', false),
      ],
    );
  });

  // =========================================================================
  // ClearSearch
  // =========================================================================

  group('ClearSearch', () {
    blocTest<ContactBloc, ContactState>(
      'resets all search state',
      build: () => ContactBloc(mockRepository),
      seed: () => const ContactState.initial().copyWith(
        status: ContactStatus.loaded,
        contacts: [_contact1, _contact2],
        filteredContacts: [_contact1],
        searchResults: [_contact3],
        searchQuery: 'test',
        isSearching: true,
        isGlobalSearching: true,
      ),
      act: (bloc) => bloc.add(const ClearSearch()),
      expect: () => [
        isA<ContactState>()
            .having((s) => s.filteredContacts.length, 'filteredContacts.length', 2)
            .having((s) => s.searchResults, 'searchResults', isEmpty)
            .having((s) => s.searchQuery, 'searchQuery', '')
            .having((s) => s.isSearching, 'isSearching', false)
            .having((s) => s.isGlobalSearching, 'isGlobalSearching', false),
      ],
    );
  });

  // =========================================================================
  // StartChat
  // =========================================================================

  group('StartChat', () {
    blocTest<ContactBloc, ContactState>(
      'emits [chatStarted] with roomId on success',
      build: () {
        when(() => mockRepository.startDirectChat(_userId2))
            .thenAnswer((_) async => '!newdm:server.com');
        return ContactBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const StartChat(_userId2)),
      expect: () => [
        isA<ContactState>()
            .having((s) => s.status, 'status', ContactStatus.chatStarted)
            .having((s) => s.startedChatRoomId, 'startedChatRoomId', '!newdm:server.com')
            .having((s) => s.startedChatUserId, 'startedChatUserId', _userId2),
      ],
    );

    blocTest<ContactBloc, ContactState>(
      'emits [error] when startDirectChat throws',
      build: () {
        when(() => mockRepository.startDirectChat(_userId2))
            .thenThrow(Exception('chat failed'));
        return ContactBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const StartChat(_userId2)),
      expect: () => [
        isA<ContactState>()
            .having((s) => s.status, 'status', ContactStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', contains('chat failed')),
      ],
    );

    blocTest<ContactBloc, ContactState>(
      'preserves contacts list on chatStarted',
      build: () {
        when(() => mockRepository.startDirectChat(_userId2))
            .thenAnswer((_) async => '!newdm:server.com');
        return ContactBloc(mockRepository);
      },
      seed: () => const ContactState.initial().copyWith(
        status: ContactStatus.loaded,
        contacts: [_contact1, _contact2],
      ),
      act: (bloc) => bloc.add(const StartChat(_userId2)),
      expect: () => [
        isA<ContactState>()
            .having((s) => s.status, 'status', ContactStatus.chatStarted)
            .having((s) => s.contacts.length, 'contacts.length', 2),
      ],
    );
  });

  // =========================================================================
  // IgnoreUser
  // =========================================================================

  group('IgnoreUser', () {
    blocTest<ContactBloc, ContactState>(
      'calls ignoreUser and triggers RefreshContacts on success',
      build: () {
        when(() => mockRepository.ignoreUser(_userId2))
            .thenAnswer((_) async {});
        when(() => mockRepository.getContacts())
            .thenAnswer((_) async => [_contact1]);
        when(() => mockRepository.getPendingFriendRequests())
            .thenAnswer((_) async => []);
        return ContactBloc(mockRepository);
      },
      seed: () => const ContactState.initial().copyWith(
        status: ContactStatus.loaded,
        contacts: [_contact1, _contact2],
      ),
      act: (bloc) => bloc.add(const IgnoreUser(_userId2)),
      expect: () => [
        // RefreshContacts result
        isA<ContactState>()
            .having((s) => s.status, 'status', ContactStatus.loaded)
            .having((s) => s.contacts.length, 'contacts.length', 1),
      ],
      verify: (_) {
        verify(() => mockRepository.ignoreUser(_userId2)).called(1);
      },
    );

    blocTest<ContactBloc, ContactState>(
      'emits [error] when ignoreUser throws',
      build: () {
        when(() => mockRepository.ignoreUser(_userId2))
            .thenThrow(Exception('ignore failed'));
        return ContactBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const IgnoreUser(_userId2)),
      expect: () => [
        isA<ContactState>()
            .having((s) => s.status, 'status', ContactStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', contains('ignore failed')),
      ],
    );
  });

  // =========================================================================
  // UnignoreUser
  // =========================================================================

  group('UnignoreUser', () {
    blocTest<ContactBloc, ContactState>(
      'calls unignoreUser and triggers RefreshContacts on success',
      build: () {
        when(() => mockRepository.unignoreUser(_userId2))
            .thenAnswer((_) async {});
        when(() => mockRepository.getContacts())
            .thenAnswer((_) async => [_contact1, _contact2]);
        when(() => mockRepository.getPendingFriendRequests())
            .thenAnswer((_) async => []);
        return ContactBloc(mockRepository);
      },
      seed: () => const ContactState.initial().copyWith(
        status: ContactStatus.loaded,
        contacts: [_contact1],
      ),
      act: (bloc) => bloc.add(const UnignoreUser(_userId2)),
      expect: () => [
        isA<ContactState>()
            .having((s) => s.status, 'status', ContactStatus.loaded)
            .having((s) => s.contacts.length, 'contacts.length', 2),
      ],
      verify: (_) {
        verify(() => mockRepository.unignoreUser(_userId2)).called(1);
      },
    );

    blocTest<ContactBloc, ContactState>(
      'emits [error] when unignoreUser throws',
      build: () {
        when(() => mockRepository.unignoreUser(_userId2))
            .thenThrow(Exception('unignore failed'));
        return ContactBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const UnignoreUser(_userId2)),
      expect: () => [
        isA<ContactState>()
            .having((s) => s.status, 'status', ContactStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', contains('unignore failed')),
      ],
    );
  });

  // =========================================================================
  // LoadFriendRequests
  // =========================================================================

  group('LoadFriendRequests', () {
    blocTest<ContactBloc, ContactState>(
      'emits state with updated friendRequests on success',
      build: () {
        when(() => mockRepository.getPendingFriendRequests())
            .thenAnswer((_) async => [_friendRequest1]);
        return ContactBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const LoadFriendRequests()),
      expect: () => [
        isA<ContactState>()
            .having((s) => s.friendRequests.length, 'friendRequests.length', 1),
      ],
    );

    blocTest<ContactBloc, ContactState>(
      'emits [error] when getPendingFriendRequests throws',
      build: () {
        when(() => mockRepository.getPendingFriendRequests())
            .thenThrow(Exception('load requests failed'));
        return ContactBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const LoadFriendRequests()),
      expect: () => [
        isA<ContactState>()
            .having((s) => s.status, 'status', ContactStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', contains('load requests failed')),
      ],
    );

    blocTest<ContactBloc, ContactState>(
      'preserves contacts list when loading friend requests',
      build: () {
        when(() => mockRepository.getPendingFriendRequests())
            .thenAnswer((_) async => [_friendRequest1]);
        return ContactBloc(mockRepository);
      },
      seed: () => const ContactState.initial().copyWith(
        status: ContactStatus.loaded,
        contacts: [_contact1, _contact2],
      ),
      act: (bloc) => bloc.add(const LoadFriendRequests()),
      expect: () => [
        isA<ContactState>()
            .having((s) => s.contacts.length, 'contacts.length', 2)
            .having((s) => s.friendRequests.length, 'friendRequests.length', 1),
      ],
    );
  });

  // =========================================================================
  // AcceptFriendRequest
  // =========================================================================

  group('AcceptFriendRequest', () {
    blocTest<ContactBloc, ContactState>(
      'calls acceptFriendRequest and triggers RefreshContacts',
      build: () {
        when(() => mockRepository.acceptFriendRequest('!req1:server.com'))
            .thenAnswer((_) async {});
        when(() => mockRepository.getContacts())
            .thenAnswer((_) async => [_contact1, _contact2, _contact3]);
        when(() => mockRepository.getPendingFriendRequests())
            .thenAnswer((_) async => []);
        return ContactBloc(mockRepository);
      },
      seed: () => const ContactState.initial().copyWith(
        status: ContactStatus.loaded,
        contacts: [_contact1, _contact2],
      ),
      act: (bloc) => bloc.add(const AcceptFriendRequest('!req1:server.com')),
      expect: () => [
        // RefreshContacts result
        isA<ContactState>()
            .having((s) => s.status, 'status', ContactStatus.loaded)
            .having((s) => s.contacts.length, 'contacts.length', 3),
      ],
      verify: (_) {
        verify(() => mockRepository.acceptFriendRequest('!req1:server.com')).called(1);
      },
    );

    blocTest<ContactBloc, ContactState>(
      'emits [error] when acceptFriendRequest throws',
      build: () {
        when(() => mockRepository.acceptFriendRequest('!req1:server.com'))
            .thenThrow(Exception('accept failed'));
        return ContactBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const AcceptFriendRequest('!req1:server.com')),
      expect: () => [
        isA<ContactState>()
            .having((s) => s.status, 'status', ContactStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', contains('accept failed')),
      ],
    );
  });

  // =========================================================================
  // RejectFriendRequest
  // =========================================================================

  group('RejectFriendRequest', () {
    blocTest<ContactBloc, ContactState>(
      'calls rejectFriendRequest and triggers RefreshContacts',
      build: () {
        when(() => mockRepository.rejectFriendRequest('!req1:server.com'))
            .thenAnswer((_) async {});
        when(() => mockRepository.getContacts())
            .thenAnswer((_) async => [_contact1, _contact2]);
        when(() => mockRepository.getPendingFriendRequests())
            .thenAnswer((_) async => []);
        return ContactBloc(mockRepository);
      },
      seed: () => const ContactState.initial().copyWith(
        status: ContactStatus.loaded,
        contacts: [_contact1, _contact2],
        friendRequests: [_friendRequest1],
      ),
      act: (bloc) => bloc.add(const RejectFriendRequest('!req1:server.com')),
      expect: () => [
        // RefreshContacts result
        isA<ContactState>()
            .having((s) => s.status, 'status', ContactStatus.loaded)
            .having((s) => s.friendRequests, 'friendRequests', isEmpty),
      ],
      verify: (_) {
        verify(() => mockRepository.rejectFriendRequest('!req1:server.com')).called(1);
      },
    );

    blocTest<ContactBloc, ContactState>(
      'emits [error] when rejectFriendRequest throws',
      build: () {
        when(() => mockRepository.rejectFriendRequest('!req1:server.com'))
            .thenThrow(Exception('reject failed'));
        return ContactBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const RejectFriendRequest('!req1:server.com')),
      expect: () => [
        isA<ContactState>()
            .having((s) => s.status, 'status', ContactStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', contains('reject failed')),
      ],
    );
  });

  // =========================================================================
  // SetContactRemark
  // =========================================================================

  group('SetContactRemark', () {
    blocTest<ContactBloc, ContactState>(
      'emits [remarkUpdated] and triggers RefreshContacts on success',
      build: () {
        when(() => mockRepository.setContactRemark(_userId1, 'Ally'))
            .thenAnswer((_) async {});
        when(() => mockRepository.getContacts())
            .thenAnswer((_) async => [
              _contact1.copyWith(remark: 'Ally'),
              _contact2,
            ]);
        when(() => mockRepository.getPendingFriendRequests())
            .thenAnswer((_) async => []);
        return ContactBloc(mockRepository);
      },
      seed: () => const ContactState.initial().copyWith(
        status: ContactStatus.loaded,
        contacts: [_contact1, _contact2],
      ),
      act: (bloc) => bloc.add(const SetContactRemark(_userId1, 'Ally')),
      expect: () => [
        isA<ContactState>()
            .having((s) => s.status, 'status', ContactStatus.remarkUpdated)
            .having((s) => s.updatedRemarkUserId, 'updatedRemarkUserId', _userId1)
            .having((s) => s.updatedRemark, 'updatedRemark', 'Ally'),
        // RefreshContacts result
        isA<ContactState>()
            .having((s) => s.status, 'status', ContactStatus.loaded),
      ],
      verify: (_) {
        verify(() => mockRepository.setContactRemark(_userId1, 'Ally')).called(1);
      },
    );

    blocTest<ContactBloc, ContactState>(
      'emits [error] when setContactRemark throws',
      build: () {
        when(() => mockRepository.setContactRemark(_userId1, 'Ally'))
            .thenThrow(Exception('remark failed'));
        return ContactBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const SetContactRemark(_userId1, 'Ally')),
      expect: () => [
        isA<ContactState>()
            .having((s) => s.status, 'status', ContactStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', contains('remark failed')),
      ],
    );
  });

  // =========================================================================
  // DeleteContact
  // =========================================================================

  group('DeleteContact', () {
    blocTest<ContactBloc, ContactState>(
      'emits [deleted] and triggers RefreshContacts on success',
      build: () {
        when(() => mockRepository.deleteContact(_userId2))
            .thenAnswer((_) async {});
        when(() => mockRepository.getContacts())
            .thenAnswer((_) async => [_contact1]);
        when(() => mockRepository.getPendingFriendRequests())
            .thenAnswer((_) async => []);
        return ContactBloc(mockRepository);
      },
      seed: () => const ContactState.initial().copyWith(
        status: ContactStatus.loaded,
        contacts: [_contact1, _contact2],
      ),
      act: (bloc) => bloc.add(const DeleteContact(_userId2)),
      expect: () => [
        isA<ContactState>()
            .having((s) => s.status, 'status', ContactStatus.deleted)
            .having((s) => s.deletedUserId, 'deletedUserId', _userId2),
        // RefreshContacts result
        isA<ContactState>()
            .having((s) => s.status, 'status', ContactStatus.loaded)
            .having((s) => s.contacts.length, 'contacts.length', 1),
      ],
      verify: (_) {
        verify(() => mockRepository.deleteContact(_userId2)).called(1);
      },
    );

    blocTest<ContactBloc, ContactState>(
      'emits [error] when deleteContact throws',
      build: () {
        when(() => mockRepository.deleteContact(_userId2))
            .thenThrow(Exception('delete failed'));
        return ContactBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const DeleteContact(_userId2)),
      expect: () => [
        isA<ContactState>()
            .having((s) => s.status, 'status', ContactStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', contains('delete failed')),
      ],
    );

    blocTest<ContactBloc, ContactState>(
      'preserves remaining contacts after deletion',
      build: () {
        when(() => mockRepository.deleteContact(_userId2))
            .thenAnswer((_) async {});
        when(() => mockRepository.getContacts())
            .thenAnswer((_) async => [_contact1]);
        when(() => mockRepository.getPendingFriendRequests())
            .thenAnswer((_) async => []);
        return ContactBloc(mockRepository);
      },
      seed: () => const ContactState.initial().copyWith(
        status: ContactStatus.loaded,
        contacts: [_contact1, _contact2],
      ),
      act: (bloc) => bloc.add(const DeleteContact(_userId2)),
      expect: () => [
        isA<ContactState>()
            .having((s) => s.status, 'status', ContactStatus.deleted)
            .having((s) => s.contacts.length, 'contacts pre-refresh', 2),
        isA<ContactState>()
            .having((s) => s.contacts, 'contacts after refresh', [_contact1]),
      ],
    );
  });

  // =========================================================================
  // OnlineStatusUpdated
  // =========================================================================

  group('OnlineStatusUpdated', () {
    blocTest<ContactBloc, ContactState>(
      'updates contact presence based on status map',
      build: () => ContactBloc(mockRepository),
      seed: () => const ContactState.initial().copyWith(
        status: ContactStatus.loaded,
        contacts: [_contact1, _contact2],
        filteredContacts: [_contact1, _contact2],
      ),
      act: (bloc) => bloc.add(OnlineStatusUpdated({
        _userId1: true,
        _userId2: false,
      })),
      expect: () => [
        isA<ContactState>()
            .having(
              (s) => s.contacts.firstWhere((c) => c.userId == _userId1).presence,
              'alice presence',
              PresenceStatus.online,
            )
            .having(
              (s) => s.contacts.firstWhere((c) => c.userId == _userId2).presence,
              'bob presence',
              PresenceStatus.offline,
            ),
      ],
    );

    blocTest<ContactBloc, ContactState>(
      'preserves filteredContacts when search query is active',
      build: () => ContactBloc(mockRepository),
      seed: () => const ContactState.initial().copyWith(
        status: ContactStatus.loaded,
        contacts: [_contact1, _contact2],
        filteredContacts: [_contact1],
        searchQuery: 'Alice',
      ),
      act: (bloc) => bloc.add(OnlineStatusUpdated({_userId1: true})),
      expect: () => [
        isA<ContactState>()
            .having((s) => s.filteredContacts.length, 'filteredContacts preserved', 1),
      ],
    );

    blocTest<ContactBloc, ContactState>(
      'updates filteredContacts when no search query',
      build: () => ContactBloc(mockRepository),
      seed: () => const ContactState.initial().copyWith(
        status: ContactStatus.loaded,
        contacts: [_contact1, _contact2],
        filteredContacts: [_contact1, _contact2],
        searchQuery: '',
      ),
      act: (bloc) => bloc.add(OnlineStatusUpdated({_userId1: true})),
      expect: () => [
        isA<ContactState>()
            .having((s) => s.filteredContacts.length, 'filteredContacts updated', 2)
            .having(
              (s) => s.filteredContacts.firstWhere((c) => c.userId == _userId1).presence,
              'alice filtered presence',
              PresenceStatus.online,
            ),
      ],
    );
  });

  // =========================================================================
  // ContactsUpdated (delegates to RefreshContacts)
  // =========================================================================

  group('ContactsUpdated', () {
    blocTest<ContactBloc, ContactState>(
      'delegates to RefreshContacts',
      build: () {
        when(() => mockRepository.getContacts())
            .thenAnswer((_) async => [_contact1]);
        when(() => mockRepository.getPendingFriendRequests())
            .thenAnswer((_) async => []);
        return ContactBloc(mockRepository);
      },
      seed: () => const ContactState.initial().copyWith(
        status: ContactStatus.loaded,
      ),
      act: (bloc) => bloc.add(const ContactsUpdated()),
      expect: () => [
        isA<ContactState>()
            .having((s) => s.status, 'status', ContactStatus.loaded)
            .having((s) => s.contacts, 'contacts', [_contact1]),
      ],
    );
  });

  // =========================================================================
  // State preservation across operations
  // =========================================================================

  group('state preservation', () {
    blocTest<ContactBloc, ContactState>(
      'contacts list survives error state',
      build: () {
        when(() => mockRepository.startDirectChat(_userId3))
            .thenThrow(Exception('failed'));
        return ContactBloc(mockRepository);
      },
      seed: () => const ContactState.initial().copyWith(
        status: ContactStatus.loaded,
        contacts: [_contact1, _contact2],
      ),
      act: (bloc) => bloc.add(const StartChat(_userId3)),
      expect: () => [
        isA<ContactState>()
            .having((s) => s.status, 'status', ContactStatus.error)
            .having((s) => s.contacts, 'contacts survived error', [_contact1, _contact2]),
      ],
    );

    blocTest<ContactBloc, ContactState>(
      'friendRequests list survives operations',
      build: () {
        when(() => mockRepository.startDirectChat(_userId2))
            .thenAnswer((_) async => '!dm:server.com');
        return ContactBloc(mockRepository);
      },
      seed: () => const ContactState.initial().copyWith(
        status: ContactStatus.loaded,
        contacts: [_contact1],
        friendRequests: [_friendRequest1],
      ),
      act: (bloc) => bloc.add(const StartChat(_userId2)),
      expect: () => [
        isA<ContactState>()
            .having((s) => s.status, 'status', ContactStatus.chatStarted)
            .having((s) => s.friendRequests.length, 'friendRequests.length', 1),
      ],
    );

    blocTest<ContactBloc, ContactState>(
      'error after retry clears previous errorMessage',
      build: () {
        when(() => mockRepository.startDirectChat(_userId2))
            .thenAnswer((_) async => '!dm:server.com');
        return ContactBloc(mockRepository);
      },
      seed: () => const ContactState.initial().copyWith(
        status: ContactStatus.error,
        errorMessage: 'previous error',
        contacts: [_contact1],
      ),
      act: (bloc) => bloc.add(const StartChat(_userId2)),
      expect: () => [
        isA<ContactState>()
            .having((s) => s.status, 'status', ContactStatus.chatStarted)
            .having((s) => s.errorMessage, 'errorMessage cleared', isNull),
      ],
    );
  });

  // =========================================================================
  // Event equatable tests
  // =========================================================================

  group('event equality', () {
    test('LoadContacts instances are equal', () {
      expect(const LoadContacts(), equals(const LoadContacts()));
    });

    test('SearchContacts with same query are equal', () {
      expect(const SearchContacts('test'), equals(const SearchContacts('test')));
    });

    test('SearchContacts with different query are not equal', () {
      expect(const SearchContacts('a'), isNot(equals(const SearchContacts('b'))));
    });

    test('StartChat with same userId are equal', () {
      expect(const StartChat(_userId1), equals(const StartChat(_userId1)));
    });

    test('SetContactRemark includes both userId and remark in props', () {
      const event = SetContactRemark(_userId1, 'Ally');
      expect(event.props, equals([_userId1, 'Ally']));
    });

    test('DeleteContact with same userId are equal', () {
      expect(const DeleteContact(_userId1), equals(const DeleteContact(_userId1)));
    });

    test('OnlineStatusUpdated with same map are equal', () {
      expect(
        const OnlineStatusUpdated({_userId1: true}),
        equals(const OnlineStatusUpdated({_userId1: true})),
      );
    });
  });

  // =========================================================================
  // Bloc close / cleanup
  // =========================================================================

  group('cleanup', () {
    test('close cancels stream subscriptions without error', () async {
      when(() => mockRepository.getContacts())
          .thenAnswer((_) async => [_contact1]);
      when(() => mockRepository.getPendingFriendRequests())
          .thenAnswer((_) async => []);

      final bloc = ContactBloc(mockRepository);
      bloc.add(const LoadContacts());

      await Future<void>.delayed(const Duration(milliseconds: 50));

      await expectLater(bloc.close(), completes);
    });

    test('close works even without any events fired', () async {
      final bloc = ContactBloc(mockRepository);
      await expectLater(bloc.close(), completes);
    });
  });
}
