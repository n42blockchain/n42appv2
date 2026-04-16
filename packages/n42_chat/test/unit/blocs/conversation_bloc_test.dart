import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/local/preferences_datasource.dart';
import 'package:n42_chat/src/domain/entities/conversation_entity.dart';
import 'package:n42_chat/src/domain/repositories/conversation_repository.dart';
import 'package:n42_chat/src/presentation/blocs/conversation/conversation_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/conversation/conversation_event.dart';
import 'package:n42_chat/src/presentation/blocs/conversation/conversation_state.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockConversationRepository extends Mock
    implements IConversationRepository {}

class MockStorageDataSource extends Mock implements PreferencesDataSource {}

// ---------------------------------------------------------------------------
// Test fixtures
// ---------------------------------------------------------------------------

const _testConversations = <ConversationEntity>[
  ConversationEntity(id: '!room1:server.com', name: 'Room 1', unreadCount: 5),
  ConversationEntity(id: '!room2:server.com', name: 'Room 2', isPinned: true),
  ConversationEntity(id: '!room3:server.com', name: 'Room 3', isMuted: true),
];

const _newConversation = ConversationEntity(
  id: '!newroom:server.com',
  name: 'New Chat',
);

void main() {
  late MockConversationRepository mockRepository;
  late MockStorageDataSource mockStorageDataSource;

  setUp(() {
    mockRepository = MockConversationRepository();
    mockStorageDataSource = MockStorageDataSource();

    // Default stub for hidden chats (used by _separateConversations path)
    when(
      () => mockStorageDataSource.getHiddenChatIds(),
    ).thenAnswer((_) async => <String>{});
  });

  ConversationBloc buildBloc() => ConversationBloc(
    conversationRepository: mockRepository,
    storageDataSource: mockStorageDataSource,
  );

  // =========================================================================
  // Initial state
  // =========================================================================

  group('initial state', () {
    test('should be ConversationState.initial with isLoading true', () {
      final bloc = buildBloc();
      expect(bloc.state.conversations, isEmpty);
      expect(bloc.state.isLoading, true);
      bloc.close();
    });
  });

  // =========================================================================
  // LoadConversations
  // =========================================================================

  group('LoadConversations', () {
    blocTest<ConversationBloc, ConversationState>(
      'emits [loading, loaded] on success',
      build: () {
        when(
          () => mockRepository.getConversations(),
        ).thenAnswer((_) async => _testConversations);
        when(
          () => mockRepository.getTotalUnreadCount(),
        ).thenAnswer((_) async => 5);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadConversations()),
      expect: () => [
        isA<ConversationState>().having((s) => s.isLoading, 'isLoading', true),
        isA<ConversationState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.conversations.length, 'conversations.length', 3)
            .having((s) => s.totalUnreadCount, 'totalUnreadCount', 5)
            .having((s) => s.pinnedConversations.length, 'pinned', 1)
            .having((s) => s.normalConversations.length, 'normal', 2),
      ],
    );

    blocTest<ConversationBloc, ConversationState>(
      'emits error when loading fails',
      build: () {
        when(
          () => mockRepository.getConversations(),
        ).thenThrow(Exception('Network error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadConversations()),
      expect: () => [
        isA<ConversationState>().having((s) => s.isLoading, 'isLoading', true),
        isA<ConversationState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  // =========================================================================
  // RefreshConversations
  // =========================================================================

  group('RefreshConversations', () {
    blocTest<ConversationBloc, ConversationState>(
      'emits [refreshing, refreshed] on success',
      build: () {
        when(
          () => mockRepository.getConversations(),
        ).thenAnswer((_) async => _testConversations);
        when(
          () => mockRepository.getTotalUnreadCount(),
        ).thenAnswer((_) async => 5);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const RefreshConversations()),
      expect: () => [
        isA<ConversationState>().having(
          (s) => s.isRefreshing,
          'isRefreshing',
          true,
        ),
        isA<ConversationState>()
            .having((s) => s.isRefreshing, 'isRefreshing', false)
            .having((s) => s.conversations.length, 'conversations.length', 3),
      ],
    );

    blocTest<ConversationBloc, ConversationState>(
      'emits error when refresh fails',
      build: () {
        when(
          () => mockRepository.getConversations(),
        ).thenThrow(Exception('Timeout'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const RefreshConversations()),
      expect: () => [
        isA<ConversationState>().having(
          (s) => s.isRefreshing,
          'isRefreshing',
          true,
        ),
        isA<ConversationState>()
            .having((s) => s.isRefreshing, 'isRefreshing', false)
            .having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  // =========================================================================
  // SetConversationMuted
  // =========================================================================

  group('SetConversationMuted', () {
    blocTest<ConversationBloc, ConversationState>(
      'toggles muted and updates local state on success',
      build: () {
        when(
          () => mockRepository.setMuted(any(), any()),
        ).thenAnswer((_) async {});
        return buildBloc();
      },
      seed: () => ConversationState.initial().copyWith(
        conversations: _testConversations,
        isLoading: false,
      ),
      act: (bloc) => bloc.add(
        const SetConversationMuted(
          conversationId: '!room1:server.com',
          muted: true,
        ),
      ),
      expect: () => [
        isA<ConversationState>().having(
          (s) => s.conversations
              .firstWhere((c) => c.id == '!room1:server.com')
              .isMuted,
          'room1 isMuted',
          true,
        ),
      ],
      verify: (_) {
        verify(
          () => mockRepository.setMuted('!room1:server.com', true),
        ).called(1);
      },
    );

    blocTest<ConversationBloc, ConversationState>(
      'emits error when setMuted fails',
      build: () {
        when(
          () => mockRepository.setMuted(any(), any()),
        ).thenThrow(Exception('Not allowed'));
        return buildBloc();
      },
      seed: () => ConversationState.initial().copyWith(
        conversations: _testConversations,
        isLoading: false,
      ),
      act: (bloc) => bloc.add(
        const SetConversationMuted(
          conversationId: '!room1:server.com',
          muted: true,
        ),
      ),
      expect: () => [
        isA<ConversationState>().having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  // =========================================================================
  // SetConversationPinned
  // =========================================================================

  group('SetConversationPinned', () {
    blocTest<ConversationBloc, ConversationState>(
      'pins conversation and separates into pinned list',
      build: () {
        when(
          () => mockRepository.setPinned(any(), any()),
        ).thenAnswer((_) async {});
        return buildBloc();
      },
      seed: () => ConversationState.initial().copyWith(
        conversations: _testConversations,
        isLoading: false,
      ),
      act: (bloc) => bloc.add(
        const SetConversationPinned(
          conversationId: '!room1:server.com',
          pinned: true,
        ),
      ),
      expect: () => [
        isA<ConversationState>()
            .having(
              (s) => s.conversations
                  .firstWhere((c) => c.id == '!room1:server.com')
                  .isPinned,
              'room1 isPinned',
              true,
            )
            .having(
              (s) => s.pinnedConversations.length,
              'pinned count',
              2, // room2 was already pinned + room1 now pinned
            ),
      ],
      verify: (_) {
        verify(
          () => mockRepository.setPinned('!room1:server.com', true),
        ).called(1);
      },
    );

    blocTest<ConversationBloc, ConversationState>(
      'emits error when setPinned fails',
      build: () {
        when(
          () => mockRepository.setPinned(any(), any()),
        ).thenThrow(Exception('Failed'));
        return buildBloc();
      },
      seed: () => ConversationState.initial().copyWith(
        conversations: _testConversations,
        isLoading: false,
      ),
      act: (bloc) => bloc.add(
        const SetConversationPinned(
          conversationId: '!room1:server.com',
          pinned: true,
        ),
      ),
      expect: () => [
        isA<ConversationState>().having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  // =========================================================================
  // DeleteConversation
  // =========================================================================

  group('DeleteConversation', () {
    blocTest<ConversationBloc, ConversationState>(
      'removes conversation from list on success',
      build: () {
        when(
          () => mockRepository.deleteConversation(any()),
        ).thenAnswer((_) async {});
        return buildBloc();
      },
      seed: () => ConversationState.initial().copyWith(
        conversations: _testConversations,
        isLoading: false,
      ),
      act: (bloc) => bloc.add(const DeleteConversation('!room1:server.com')),
      expect: () => [
        isA<ConversationState>()
            .having((s) => s.conversations.length, 'conversations.length', 2)
            .having(
              (s) => s.conversations.any((c) => c.id == '!room1:server.com'),
              'room1 still present',
              false,
            ),
      ],
      verify: (_) {
        verify(
          () => mockRepository.deleteConversation('!room1:server.com'),
        ).called(1);
      },
    );

    blocTest<ConversationBloc, ConversationState>(
      'emits error when delete fails',
      build: () {
        when(
          () => mockRepository.deleteConversation(any()),
        ).thenThrow(Exception('Cannot delete'));
        return buildBloc();
      },
      seed: () => ConversationState.initial().copyWith(
        conversations: _testConversations,
        isLoading: false,
      ),
      act: (bloc) => bloc.add(const DeleteConversation('!room1:server.com')),
      expect: () => [
        isA<ConversationState>().having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  // =========================================================================
  // CreateDirectChat
  // =========================================================================

  group('CreateDirectChat', () {
    blocTest<ConversationBloc, ConversationState>(
      'emits newConversationId on success and triggers refresh',
      build: () {
        when(
          () => mockRepository.createDirectChat(any()),
        ).thenAnswer((_) async => _newConversation);
        // Stub refresh path
        when(
          () => mockRepository.getConversations(),
        ).thenAnswer((_) async => [..._testConversations, _newConversation]);
        when(
          () => mockRepository.getTotalUnreadCount(),
        ).thenAnswer((_) async => 5);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const CreateDirectChat('@user:server.com')),
      expect: () => [
        // First: newConversationId set
        isA<ConversationState>()
            .having(
              (s) => s.newConversationId,
              'newConversationId',
              '!newroom:server.com',
            )
            .having(
              (s) => s.conversations.any((c) => c.id == '!newroom:server.com'),
              'new conversation inserted before refresh',
              isTrue,
            ),
        // Then: RefreshConversations triggered internally
        isA<ConversationState>().having(
          (s) => s.isRefreshing,
          'isRefreshing',
          true,
        ),
        isA<ConversationState>()
            .having((s) => s.isRefreshing, 'isRefreshing', false)
            .having((s) => s.conversations.length, 'conversations.length', 4),
      ],
      verify: (_) {
        verify(
          () => mockRepository.createDirectChat('@user:server.com'),
        ).called(1);
      },
    );

    blocTest<ConversationBloc, ConversationState>(
      'emits error when create fails',
      build: () {
        when(
          () => mockRepository.createDirectChat(any()),
        ).thenThrow(Exception('User not found'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const CreateDirectChat('@noone:server.com')),
      expect: () => [
        isA<ConversationState>().having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  // =========================================================================
  // SearchConversations
  // =========================================================================

  group('SearchConversations', () {
    blocTest<ConversationBloc, ConversationState>(
      'emits search results on success',
      build: () {
        when(
          () => mockRepository.searchConversations(any()),
        ).thenAnswer((_) async => [_testConversations.first]);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SearchConversations('Room 1')),
      expect: () => [
        // First: searching state
        isA<ConversationState>()
            .having((s) => s.isSearching, 'isSearching', true)
            .having((s) => s.searchQuery, 'searchQuery', 'Room 1'),
        // Then: results
        isA<ConversationState>().having(
          (s) => s.filteredConversations?.length,
          'filteredConversations.length',
          1,
        ),
      ],
    );

    blocTest<ConversationBloc, ConversationState>(
      'clears search when query is empty',
      build: () => buildBloc(),
      seed: () => ConversationState.initial().copyWith(
        conversations: _testConversations,
        isSearching: true,
        searchQuery: 'Room',
        filteredConversations: [_testConversations.first],
      ),
      act: (bloc) => bloc.add(const SearchConversations('  ')),
      expect: () => [
        isA<ConversationState>()
            .having((s) => s.isSearching, 'isSearching', false)
            .having(
              (s) => s.filteredConversations,
              'filteredConversations',
              isNull,
            ),
      ],
    );
  });

  // =========================================================================
  // MarkConversationAsRead
  // =========================================================================

  group('MarkConversationAsRead', () {
    blocTest<ConversationBloc, ConversationState>(
      'calls repository and updates unread count optimistically',
      build: () {
        when(() => mockRepository.markAsRead(any())).thenAnswer((_) async {});
        return buildBloc();
      },
      seed: () => ConversationState.initial().copyWith(
        conversations: _testConversations,
        totalUnreadCount: 5,
      ),
      act: (bloc) =>
          bloc.add(const MarkConversationAsRead('!room1:server.com')),
      expect: () => [
        isA<ConversationState>()
            .having(
              (s) => s.conversations
                  .firstWhere((c) => c.id == '!room1:server.com')
                  .unreadCount,
              'room1 unreadCount',
              0,
            )
            .having(
              (s) => s.totalUnreadCount,
              'totalUnreadCount',
              0, // room1 had 5 unread, now 0
            ),
      ],
      verify: (_) {
        verify(() => mockRepository.markAsRead('!room1:server.com')).called(1);
      },
    );
  });

  // =========================================================================
  // ConversationsUpdated (internal event)
  // =========================================================================

  group('ConversationsUpdated', () {
    blocTest<ConversationBloc, ConversationState>(
      'updates conversations and recalculates unread count',
      build: () => buildBloc(),
      act: (bloc) => bloc.add(const ConversationsUpdated(_testConversations)),
      expect: () => [
        isA<ConversationState>()
            .having((s) => s.conversations.length, 'conversations.length', 3)
            .having((s) => s.totalUnreadCount, 'totalUnreadCount', 5)
            .having((s) => s.pinnedConversations.length, 'pinned', 1)
            .having((s) => s.normalConversations.length, 'normal', 2),
      ],
    );
  });

  // =========================================================================
  // ConversationState helpers
  // =========================================================================

  group('ConversationState', () {
    test('initial has correct defaults', () {
      final state = ConversationState.initial();
      expect(state.isLoading, true);
      expect(state.conversations, isEmpty);
      expect(state.totalUnreadCount, 0);
      expect(state.error, isNull);
    });

    test('isEmpty returns true when no conversations', () {
      expect(ConversationState.initial().isEmpty, true);
    });

    test('displayConversations returns filtered when searching', () {
      final state = ConversationState.initial().copyWith(
        conversations: _testConversations,
        isSearching: true,
        filteredConversations: [_testConversations.first],
      );
      expect(state.displayConversations.length, 1);
    });

    test('displayConversations returns all when not searching', () {
      final state = ConversationState.initial().copyWith(
        conversations: _testConversations,
      );
      expect(state.displayConversations.length, 3);
    });

    test('hasSearchResults returns true when results exist', () {
      final state = ConversationState.initial().copyWith(
        isSearching: true,
        filteredConversations: [_testConversations.first],
      );
      expect(state.hasSearchResults, true);
    });

    test('noSearchResults returns true when no results', () {
      final state = ConversationState.initial().copyWith(
        isSearching: true,
        filteredConversations: [],
      );
      expect(state.noSearchResults, true);
    });

    test('copyWith clearError clears error', () {
      final state = ConversationState.initial().copyWith(error: 'err');
      final cleared = state.copyWith(clearError: true);
      expect(cleared.error, isNull);
    });
  });
}
