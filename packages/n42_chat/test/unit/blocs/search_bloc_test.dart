import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/domain/entities/search_result_entity.dart';
import 'package:n42_chat/src/domain/repositories/search_repository.dart';
import 'package:n42_chat/src/presentation/blocs/search/search_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/search/search_event.dart';
import 'package:n42_chat/src/presentation/blocs/search/search_state.dart';

class MockSearchRepository extends Mock implements ISearchRepository {}

void main() {
  late MockSearchRepository mockRepo;

  setUp(() {
    mockRepo = MockSearchRepository();
  });

  SearchBloc buildBloc() => SearchBloc(mockRepo);

  group('initial state', () {
    test('is SearchInitial with empty recentSearches', () {
      final bloc = buildBloc();
      expect(bloc.state, isA<SearchInitial>());
      expect((bloc.state as SearchInitial).recentSearches, isEmpty);
    });
  });

  group('ClearSearch', () {
    blocTest<SearchBloc, SearchState>(
      'emits SearchInitial with history from repository',
      build: buildBloc,
      setUp: () {
        when(
          () => mockRepo.getRecentSearches(),
        ).thenAnswer((_) async => ['alice', 'bob']);
      },
      act: (bloc) => bloc.add(const ClearSearch()),
      expect: () => [
        isA<SearchInitial>().having((s) => s.recentSearches, 'recentSearches', [
          'alice',
          'bob',
        ]),
      ],
    );
  });

  group('LoadSearchHistory', () {
    blocTest<SearchBloc, SearchState>(
      'emits SearchInitial with history',
      build: buildBloc,
      setUp: () {
        when(
          () => mockRepo.getRecentSearches(),
        ).thenAnswer((_) async => ['term1', 'term2']);
      },
      act: (bloc) => bloc.add(const LoadSearchHistory()),
      expect: () => [
        isA<SearchInitial>().having((s) => s.recentSearches, 'recentSearches', [
          'term1',
          'term2',
        ]),
      ],
    );
  });

  group('ClearSearchHistory', () {
    blocTest<SearchBloc, SearchState>(
      'clears history when in SearchInitial state',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.clearSearchHistory()).thenAnswer((_) async {});
      },
      seed: () => const SearchInitial(recentSearches: ['a', 'b']),
      act: (bloc) => bloc.add(const ClearSearchHistory()),
      expect: () => [
        isA<SearchInitial>().having(
          (s) => s.recentSearches,
          'recentSearches',
          isEmpty,
        ),
      ],
    );
  });

  group('PerformSearch', () {
    blocTest<SearchBloc, SearchState>(
      'emits SearchInitial with history when query is empty',
      build: buildBloc,
      setUp: () {
        when(
          () => mockRepo.getRecentSearches(),
        ).thenAnswer((_) async => ['prev']);
      },
      act: (bloc) => bloc.add(const PerformSearch('')),
      wait: const Duration(milliseconds: 400),
      expect: () => [
        isA<SearchInitial>().having((s) => s.recentSearches, 'recentSearches', [
          'prev',
        ]),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'emits [SearchLoading, SearchLoaded] on success',
      build: buildBloc,
      setUp: () {
        when(
          () => mockRepo.searchGlobal(any(), type: any(named: 'type')),
        ).thenAnswer((_) async => const SearchResults(query: 'alice'));
        when(() => mockRepo.getRecentSearches()).thenAnswer((_) async => []);
      },
      act: (bloc) => bloc.add(const PerformSearch('alice')),
      wait: const Duration(milliseconds: 400),
      expect: () => [
        isA<SearchLoading>().having((s) => s.query, 'query', 'alice'),
        isA<SearchLoaded>(),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'emits [SearchLoading, SearchError] on failure',
      build: buildBloc,
      setUp: () {
        when(
          () => mockRepo.searchGlobal(any(), type: any(named: 'type')),
        ).thenThrow(Exception('Search failed'));
      },
      act: (bloc) => bloc.add(const PerformSearch('query')),
      wait: const Duration(milliseconds: 400),
      expect: () => [isA<SearchLoading>(), isA<SearchError>()],
    );

    blocTest<SearchBloc, SearchState>(
      'debounces multiple rapid searches',
      build: buildBloc,
      setUp: () {
        when(
          () => mockRepo.searchGlobal(any(), type: any(named: 'type')),
        ).thenAnswer((_) async => const SearchResults());
        when(() => mockRepo.getRecentSearches()).thenAnswer((_) async => []);
      },
      act: (bloc) {
        bloc.add(const PerformSearch('a'));
        bloc.add(const PerformSearch('al'));
        bloc.add(const PerformSearch('alice'));
      },
      wait: const Duration(milliseconds: 500),
      verify: (_) {
        // Only 1 actual search call (debounced)
        verify(
          () => mockRepo.searchGlobal('alice', type: any(named: 'type')),
        ).called(1);
      },
    );

    test(
      'keeps the latest results when an older request finishes later',
      () async {
        final oldCompleter = Completer<SearchResults>();
        final newCompleter = Completer<SearchResults>();

        when(
          () => mockRepo.searchGlobal('old', type: any(named: 'type')),
        ).thenAnswer((_) => oldCompleter.future);
        when(
          () => mockRepo.searchGlobal('new', type: any(named: 'type')),
        ).thenAnswer((_) => newCompleter.future);
        when(() => mockRepo.getRecentSearches()).thenAnswer((_) async => []);

        final bloc = buildBloc();

        bloc.add(const PerformSearch('old'));
        await Future<void>.delayed(const Duration(milliseconds: 350));

        bloc.add(const PerformSearch('new'));
        await Future<void>.delayed(const Duration(milliseconds: 350));

        newCompleter.complete(const SearchResults(query: 'new'));
        await pumpEventQueue();

        expect(
          bloc.state,
          isA<SearchLoaded>().having(
            (s) => s.results.query,
            'results.query',
            'new',
          ),
        );

        oldCompleter.complete(const SearchResults(query: 'old'));
        await pumpEventQueue();

        expect(
          bloc.state,
          isA<SearchLoaded>().having(
            (s) => s.results.query,
            'results.query',
            'new',
          ),
        );

        await bloc.close();
      },
    );
  });

  group('ChangeSearchType', () {
    blocTest<SearchBloc, SearchState>(
      'updates selectedType when state is SearchLoaded',
      build: buildBloc,
      seed: () => const SearchLoaded(
        results: SearchResults(),
        selectedType: SearchResultType.all,
      ),
      act: (bloc) => bloc.add(const ChangeSearchType(SearchResultType.contact)),
      expect: () => [
        isA<SearchLoaded>().having(
          (s) => s.selectedType,
          'selectedType',
          SearchResultType.contact,
        ),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'does nothing when state is not SearchLoaded',
      build: buildBloc,
      act: (bloc) => bloc.add(const ChangeSearchType(SearchResultType.message)),
      expect: () => <SearchState>[],
    );
  });

  group('DeleteSearchHistoryItem', () {
    blocTest<SearchBloc, SearchState>(
      'removes item and emits updated SearchInitial',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.deleteSearchQuery(any())).thenAnswer((_) async {});
        when(
          () => mockRepo.getRecentSearches(),
        ).thenAnswer((_) async => ['bob']);
      },
      seed: () => const SearchInitial(recentSearches: ['alice', 'bob']),
      act: (bloc) => bloc.add(const DeleteSearchHistoryItem('alice')),
      expect: () => [
        isA<SearchInitial>().having((s) => s.recentSearches, 'recentSearches', [
          'bob',
        ]),
      ],
    );
  });
}
