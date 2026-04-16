// Extended tests for SearchBloc — covers handlers NOT exercised by
// search_bloc_test.dart:
//   SearchContacts, SearchGroups, SearchMessages,
//   SearchInChat, NavigateToNextResult, NavigateToPreviousResult,
//   NavigateToResultIndex, LoadMoreChatResults

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';
import 'package:n42_chat/src/domain/entities/search_result_entity.dart';
import 'package:n42_chat/src/domain/repositories/search_repository.dart';
import 'package:n42_chat/src/presentation/blocs/search/search_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/search/search_event.dart';
import 'package:n42_chat/src/presentation/blocs/search/search_state.dart';

class _MockSearchRepository extends Mock implements ISearchRepository {}

MessageEntity _makeMsg(String id) => MessageEntity(
  id: id,
  roomId: '!r:s',
  senderId: '@alice:s',
  senderName: 'Alice',
  content: 'text',
  timestamp: DateTime(2025),
  type: MessageType.text,
  status: MessageStatus.sent,
);

void main() {
  late _MockSearchRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(const ChatSearchResults());
    registerFallbackValue(SearchResultType.all);
  });

  setUp(() {
    mockRepo = _MockSearchRepository();
  });

  SearchBloc buildBloc() => SearchBloc(mockRepo);

  // ─────────────────────────────────────────────────
  // SearchContacts
  // ─────────────────────────────────────────────────

  group('SearchContacts', () {
    blocTest<SearchBloc, SearchState>(
      'delegates to PerformSearch with type=contact and emits results',
      build: buildBloc,
      setUp: () {
        when(
          () => mockRepo.searchGlobal(any(), type: any(named: 'type')),
        ).thenAnswer((_) async => const SearchResults(query: 'alice'));
        when(() => mockRepo.getRecentSearches()).thenAnswer((_) async => []);
      },
      act: (bloc) => bloc.add(const SearchContacts('alice')),
      wait: const Duration(milliseconds: 400),
      expect: () => [
        isA<SearchLoading>()
            .having((s) => s.query, 'query', 'alice')
            .having((s) => s.type, 'type', SearchResultType.contact),
        isA<SearchLoaded>(),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // SearchGroups
  // ─────────────────────────────────────────────────

  group('SearchGroups', () {
    blocTest<SearchBloc, SearchState>(
      'delegates to PerformSearch with type=group and emits results',
      build: buildBloc,
      setUp: () {
        when(
          () => mockRepo.searchGlobal(any(), type: any(named: 'type')),
        ).thenAnswer((_) async => const SearchResults(query: 'devs'));
        when(() => mockRepo.getRecentSearches()).thenAnswer((_) async => []);
      },
      act: (bloc) => bloc.add(const SearchGroups('devs')),
      wait: const Duration(milliseconds: 400),
      expect: () => [
        isA<SearchLoading>()
            .having((s) => s.query, 'query', 'devs')
            .having((s) => s.type, 'type', SearchResultType.group),
        isA<SearchLoaded>(),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // SearchMessages
  // ─────────────────────────────────────────────────

  group('SearchMessages', () {
    blocTest<SearchBloc, SearchState>(
      'without roomId — delegates to PerformSearch with type=message',
      build: buildBloc,
      setUp: () {
        when(
          () => mockRepo.searchGlobal(any(), type: any(named: 'type')),
        ).thenAnswer((_) async => const SearchResults(query: 'hello'));
        when(() => mockRepo.getRecentSearches()).thenAnswer((_) async => []);
      },
      act: (bloc) => bloc.add(const SearchMessages('hello')),
      wait: const Duration(milliseconds: 400),
      expect: () => [
        isA<SearchLoading>().having(
          (s) => s.type,
          'type',
          SearchResultType.message,
        ),
        isA<SearchLoaded>(),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'with roomId — delegates to SearchInChat and emits ChatSearchState',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.searchInChat(any(), any())).thenAnswer(
          (_) async => const ChatSearchResults(roomId: '!r:s', query: 'hello'),
        );
      },
      act: (bloc) => bloc.add(const SearchMessages('hello', roomId: '!r:s')),
      wait: const Duration(milliseconds: 400),
      expect: () => [
        isA<ChatSearchState>().having(
          (s) => s.isSearching,
          'isSearching',
          isTrue,
        ),
        isA<ChatSearchState>().having(
          (s) => s.isSearching,
          'isSearching',
          isFalse,
        ),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // SearchInChat
  // ─────────────────────────────────────────────────

  group('SearchInChat', () {
    blocTest<SearchBloc, SearchState>(
      'empty query — emits ChatSearchState with empty results (no isSearching)',
      build: buildBloc,
      act: (bloc) => bloc.add(const SearchInChat('!r:s', '')),
      wait: const Duration(milliseconds: 400),
      expect: () => [
        isA<ChatSearchState>()
            .having((s) => s.isSearching, 'isSearching', isFalse)
            .having((s) => s.results.roomId, 'roomId', '!r:s'),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'non-empty query — emits [loading=true, results]',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.searchInChat(any(), any())).thenAnswer(
          (_) async => ChatSearchResults(
            roomId: '!r:s',
            query: 'hello',
            messages: [_makeMsg(r'$msg1')],
          ),
        );
      },
      act: (bloc) => bloc.add(const SearchInChat('!r:s', 'hello')),
      wait: const Duration(milliseconds: 400),
      expect: () => [
        isA<ChatSearchState>().having(
          (s) => s.isSearching,
          'isSearching',
          isTrue,
        ),
        isA<ChatSearchState>()
            .having((s) => s.isSearching, 'isSearching', isFalse)
            .having((s) => s.results.messages.length, 'messages.length', 1),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'repository error — emits SearchError',
      build: buildBloc,
      setUp: () {
        when(
          () => mockRepo.searchInChat(any(), any()),
        ).thenThrow(Exception('connection error'));
      },
      act: (bloc) => bloc.add(const SearchInChat('!r:s', 'fail')),
      wait: const Duration(milliseconds: 400),
      expect: () => [
        isA<ChatSearchState>().having(
          (s) => s.isSearching,
          'isSearching',
          isTrue,
        ),
        isA<SearchError>(),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // NavigateToNextResult
  // ─────────────────────────────────────────────────

  group('NavigateToNextResult', () {
    final msgs = [_makeMsg(r'$m1'), _makeMsg(r'$m2')];

    blocTest<SearchBloc, SearchState>(
      'increments currentIndex when hasNext is true',
      build: buildBloc,
      seed: () => ChatSearchState(
        results: ChatSearchResults(
          messages: msgs,
          roomId: '!r:s',
          currentIndex: 0,
        ),
      ),
      act: (bloc) => bloc.add(const NavigateToNextResult()),
      expect: () => [
        isA<ChatSearchState>().having(
          (s) => s.results.currentIndex,
          'currentIndex',
          1,
        ),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'does nothing when already at last result',
      build: buildBloc,
      seed: () => ChatSearchState(
        results: ChatSearchResults(
          messages: msgs,
          roomId: '!r:s',
          currentIndex: 1, // last index
        ),
      ),
      act: (bloc) => bloc.add(const NavigateToNextResult()),
      expect: () => <SearchState>[],
    );

    blocTest<SearchBloc, SearchState>(
      'does nothing when state is not ChatSearchState',
      build: buildBloc,
      act: (bloc) => bloc.add(const NavigateToNextResult()),
      expect: () => <SearchState>[],
    );
  });

  // ─────────────────────────────────────────────────
  // NavigateToPreviousResult
  // ─────────────────────────────────────────────────

  group('NavigateToPreviousResult', () {
    final msgs = [_makeMsg(r'$m1'), _makeMsg(r'$m2')];

    blocTest<SearchBloc, SearchState>(
      'decrements currentIndex when hasPrevious is true',
      build: buildBloc,
      seed: () => ChatSearchState(
        results: ChatSearchResults(
          messages: msgs,
          roomId: '!r:s',
          currentIndex: 1,
        ),
      ),
      act: (bloc) => bloc.add(const NavigateToPreviousResult()),
      expect: () => [
        isA<ChatSearchState>().having(
          (s) => s.results.currentIndex,
          'currentIndex',
          0,
        ),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'does nothing when already at first result',
      build: buildBloc,
      seed: () => ChatSearchState(
        results: ChatSearchResults(
          messages: msgs,
          roomId: '!r:s',
          currentIndex: 0, // first index
        ),
      ),
      act: (bloc) => bloc.add(const NavigateToPreviousResult()),
      expect: () => <SearchState>[],
    );

    blocTest<SearchBloc, SearchState>(
      'does nothing when state is not ChatSearchState',
      build: buildBloc,
      act: (bloc) => bloc.add(const NavigateToPreviousResult()),
      expect: () => <SearchState>[],
    );
  });

  // ─────────────────────────────────────────────────
  // NavigateToResultIndex
  // ─────────────────────────────────────────────────

  group('NavigateToResultIndex', () {
    final msgs = [_makeMsg(r'$m1'), _makeMsg(r'$m2'), _makeMsg(r'$m3')];

    blocTest<SearchBloc, SearchState>(
      'jumps to valid index',
      build: buildBloc,
      seed: () => ChatSearchState(
        results: ChatSearchResults(
          messages: msgs,
          roomId: '!r:s',
          currentIndex: 0,
        ),
      ),
      act: (bloc) => bloc.add(const NavigateToResultIndex(2)),
      expect: () => [
        isA<ChatSearchState>().having(
          (s) => s.results.currentIndex,
          'currentIndex',
          2,
        ),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'ignores out-of-bounds index',
      build: buildBloc,
      seed: () => ChatSearchState(
        results: ChatSearchResults(
          messages: msgs,
          roomId: '!r:s',
          currentIndex: 0,
        ),
      ),
      act: (bloc) => bloc.add(const NavigateToResultIndex(10)),
      expect: () => <SearchState>[],
    );

    blocTest<SearchBloc, SearchState>(
      'ignores negative index',
      build: buildBloc,
      seed: () => ChatSearchState(
        results: ChatSearchResults(
          messages: msgs,
          roomId: '!r:s',
          currentIndex: 1,
        ),
      ),
      act: (bloc) => bloc.add(const NavigateToResultIndex(-1)),
      expect: () => <SearchState>[],
    );

    blocTest<SearchBloc, SearchState>(
      'does nothing when state is not ChatSearchState',
      build: buildBloc,
      act: (bloc) => bloc.add(const NavigateToResultIndex(0)),
      expect: () => <SearchState>[],
    );
  });

  // ─────────────────────────────────────────────────
  // LoadMoreChatResults
  // ─────────────────────────────────────────────────

  group('LoadMoreChatResults', () {
    blocTest<SearchBloc, SearchState>(
      'does nothing when state is not ChatSearchState',
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadMoreChatResults()),
      expect: () => <SearchState>[],
    );

    blocTest<SearchBloc, SearchState>(
      'does nothing when hasMore is false',
      build: buildBloc,
      seed: () => const ChatSearchState(
        results: ChatSearchResults(roomId: '!r:s', hasMore: false),
      ),
      act: (bloc) => bloc.add(const LoadMoreChatResults()),
      expect: () => <SearchState>[],
    );

    blocTest<SearchBloc, SearchState>(
      'emits [isSearching=true, results] on success',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.loadMoreChatSearchResults(any())).thenAnswer(
          (_) async => ChatSearchResults(
            roomId: '!r:s',
            query: 'hello',
            messages: [_makeMsg(r'$extra1'), _makeMsg(r'$extra2')],
            hasMore: false,
          ),
        );
      },
      seed: () => const ChatSearchState(
        results: ChatSearchResults(
          roomId: '!r:s',
          query: 'hello',
          hasMore: true,
        ),
      ),
      act: (bloc) => bloc.add(const LoadMoreChatResults()),
      expect: () => [
        isA<ChatSearchState>().having(
          (s) => s.isSearching,
          'isSearching',
          isTrue,
        ),
        isA<ChatSearchState>()
            .having((s) => s.isSearching, 'isSearching', isFalse)
            .having((s) => s.results.messages.length, 'messages.length', 2),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'resets isSearching to false on repository failure',
      build: buildBloc,
      setUp: () {
        when(
          () => mockRepo.loadMoreChatSearchResults(any()),
        ).thenThrow(Exception('network error'));
      },
      seed: () => const ChatSearchState(
        results: ChatSearchResults(
          roomId: '!r:s',
          query: 'hello',
          hasMore: true,
        ),
      ),
      act: (bloc) => bloc.add(const LoadMoreChatResults()),
      expect: () => [
        isA<ChatSearchState>().having(
          (s) => s.isSearching,
          'isSearching',
          isTrue,
        ),
        isA<ChatSearchState>().having(
          (s) => s.isSearching,
          'isSearching',
          isFalse,
        ),
      ],
    );
  });
}
