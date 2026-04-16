// Tests for SearchRepositoryImpl — focuses on persistent search history
// delegation (saveSearchQuery, getRecentSearches, deleteSearchQuery,
// clearSearchHistory)
// and lightweight delegation tests that require no Matrix connection.
//
// Matrix-dependent paths (searchGlobal with results, searchContacts via Matrix,
// etc.) are out of scope here — they live in integration tests.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_search_datasource.dart';
import 'package:n42_chat/src/data/repositories/search_repository_impl.dart';

class MockMatrixSearchDataSource extends Mock
    implements MatrixSearchDataSource {}

class MockMatrixClientManager extends Mock implements MatrixClientManager {}

void main() {
  late SearchRepositoryImpl repository;
  late MockMatrixSearchDataSource mockDataSource;
  late MockMatrixClientManager mockClientManager;
  late List<String> persistedHistory;

  setUp(() {
    mockDataSource = MockMatrixSearchDataSource();
    mockClientManager = MockMatrixClientManager();
    persistedHistory = <String>[];

    when(
      () => mockDataSource.getRecentSearches(limit: any(named: 'limit')),
    ).thenAnswer((invocation) async {
      final limit = invocation.namedArguments[#limit] as int? ?? 10;
      return persistedHistory.take(limit).toList();
    });
    when(() => mockDataSource.saveSearchQuery(any())).thenAnswer((
      invocation,
    ) async {
      final query = (invocation.positionalArguments.first as String).trim();
      if (query.isEmpty) return;

      persistedHistory.remove(query);
      persistedHistory.insert(0, query);
      if (persistedHistory.length > 20) {
        persistedHistory.removeRange(20, persistedHistory.length);
      }
    });
    when(() => mockDataSource.deleteSearchQuery(any())).thenAnswer((
      invocation,
    ) async {
      final query = invocation.positionalArguments.first as String;
      persistedHistory.remove(query);
    });
    when(() => mockDataSource.clearSearchHistory()).thenAnswer((_) async {
      persistedHistory.clear();
    });

    repository = SearchRepositoryImpl(
      mockDataSource,
      mockClientManager,
      // EnsCacheService and UsernameService intentionally omitted (null) —
      // these optional integrations are not exercised in pure unit tests.
    );
  });

  // ─────────────────────────────────────────────────
  // searchGlobal — empty query short-circuit
  // ─────────────────────────────────────────────────

  group('searchGlobal — empty query', () {
    test('returns empty SearchResults without touching datasource', () async {
      final result = await repository.searchGlobal('');

      expect(result.totalCount, 0);
      expect(result.isEmpty, isTrue);
      expect(result.query, '');
      // None of the datasource methods should have been called.
      verifyNever(() => mockDataSource.searchLocalContacts(any()));
    });

    test('returns empty SearchResults for whitespace-only query', () async {
      final result = await repository.searchGlobal('   ');

      expect(result.isEmpty, isTrue);
      verifyNever(() => mockDataSource.searchLocalContacts(any()));
    });
  });

  // ─────────────────────────────────────────────────
  // Persistent search history delegation
  // ─────────────────────────────────────────────────

  group('getRecentSearches — initial state', () {
    test('returns empty list when no history', () async {
      final result = await repository.getRecentSearches();
      expect(result, isEmpty);
    });

    test('limit parameter respected on empty list', () async {
      final result = await repository.getRecentSearches(limit: 5);
      expect(result, isEmpty);
    });
  });

  group('saveSearchQuery', () {
    test('adds query to history', () async {
      await repository.saveSearchQuery('bitcoin');

      final history = await repository.getRecentSearches();
      expect(history, contains('bitcoin'));
      verify(() => mockDataSource.saveSearchQuery('bitcoin')).called(1);
    });

    test('most recent query appears first', () async {
      await repository.saveSearchQuery('first');
      await repository.saveSearchQuery('second');

      final history = await repository.getRecentSearches();
      expect(history.first, 'second');
      expect(history[1], 'first');
    });

    test('duplicate query is moved to front instead of duplicated', () async {
      await repository.saveSearchQuery('eth');
      await repository.saveSearchQuery('btc');
      await repository.saveSearchQuery('eth'); // re-add

      final history = await repository.getRecentSearches();
      expect(history.first, 'eth');
      expect(history.where((q) => q == 'eth').length, 1); // only one instance
    });

    test('empty or whitespace-only query is not saved', () async {
      await repository.saveSearchQuery('');
      await repository.saveSearchQuery('   ');

      final history = await repository.getRecentSearches();
      expect(history, isEmpty);
      verify(() => mockDataSource.saveSearchQuery('')).called(2);
    });

    test('caps history at 20 entries (oldest entry is dropped)', () async {
      // Insert 21 unique queries.
      for (var i = 1; i <= 21; i++) {
        await repository.saveSearchQuery('query$i');
      }

      final history = await repository.getRecentSearches(limit: 100);
      expect(history.length, 20);
      // 'query1' (the oldest) should have been dropped.
      expect(history, isNot(contains('query1')));
      // 'query21' (the newest) should be at the front.
      expect(history.first, 'query21');
    });

    test('limit parameter limits results returned', () async {
      for (var i = 1; i <= 10; i++) {
        await repository.saveSearchQuery('q$i');
      }

      final result = await repository.getRecentSearches(limit: 3);
      expect(result.length, 3);
    });
  });

  group('deleteSearchQuery', () {
    test('removes matching query from history', () async {
      await repository.saveSearchQuery('alpha');
      await repository.saveSearchQuery('beta');
      await repository.saveSearchQuery('gamma');

      await repository.deleteSearchQuery('beta');

      final history = await repository.getRecentSearches();
      expect(history, isNot(contains('beta')));
      expect(history, containsAll(['alpha', 'gamma']));
      verify(() => mockDataSource.deleteSearchQuery('beta')).called(1);
    });

    test('is a no-op when query not in history', () async {
      await repository.saveSearchQuery('alpha');

      // Should not throw.
      await repository.deleteSearchQuery('nonexistent');

      final history = await repository.getRecentSearches();
      expect(history, ['alpha']);
    });

    test('preserves order of remaining entries', () async {
      for (final q in ['a', 'b', 'c', 'd']) {
        await repository.saveSearchQuery(q);
      }

      await repository.deleteSearchQuery('b');

      final history = await repository.getRecentSearches();
      // Recent-first: d, c, a (b removed).
      expect(history, ['d', 'c', 'a']);
    });
  });

  group('clearSearchHistory', () {
    test('removes all entries', () async {
      await repository.saveSearchQuery('one');
      await repository.saveSearchQuery('two');
      await repository.saveSearchQuery('three');

      await repository.clearSearchHistory();

      final history = await repository.getRecentSearches();
      expect(history, isEmpty);
      verify(() => mockDataSource.clearSearchHistory()).called(1);
    });

    test('subsequent saves work normally after clear', () async {
      await repository.saveSearchQuery('old');
      await repository.clearSearchHistory();
      await repository.saveSearchQuery('new');

      final history = await repository.getRecentSearches();
      expect(history, ['new']);
    });

    test('clearing empty history does not throw', () async {
      // History is already empty — should be a safe no-op.
      await expectLater(repository.clearSearchHistory(), completes);
    });
  });

  // ─────────────────────────────────────────────────
  // searchInChat — empty query short-circuit
  // ─────────────────────────────────────────────────

  group('searchInChat — empty query', () {
    test(
      'returns empty ChatSearchResults without calling datasource',
      () async {
        // Stub necessary Matrix calls to return empty lists.
        when(
          () => mockDataSource.searchMessagesInRoom(
            any(),
            any(),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => []);

        final result = await repository.searchInChat('!room:server', '');

        expect(result.isEmpty, isTrue);
        expect(result.roomId, '!room:server');
        expect(result.messages, isEmpty);
        // Empty query short-circuits before calling datasource.
        verifyNever(() => mockDataSource.searchMessagesInRoom(any(), any()));
      },
    );
  });
}
