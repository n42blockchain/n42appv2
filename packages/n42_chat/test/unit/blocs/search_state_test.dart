// Tests for simple pure-Dart state classes in search_state.dart:
//   SearchInitial, SearchLoading, SearchError.
// SearchLoaded (needs SearchResults domain object) and
// ChatSearchState (needs ChatSearchResults) are not covered here.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/blocs/search/search_state.dart';

void main() {
  // ─────────────────────────────────────────────────
  // SearchInitial
  // ─────────────────────────────────────────────────

  group('SearchInitial', () {
    test('can be constructed with default empty recentSearches', () {
      const s = SearchInitial();
      expect(s.recentSearches, isEmpty);
    });

    test('stores recentSearches when provided', () {
      const s = SearchInitial(recentSearches: ['bitcoin', 'ethereum']);
      expect(s.recentSearches, ['bitcoin', 'ethereum']);
    });

    test('is a SearchState', () {
      expect(const SearchInitial(), isA<SearchState>());
    });

    test('props contains recentSearches', () {
      const s = SearchInitial(recentSearches: ['x']);
      expect(s.props.first, ['x']);
    });

    test('two default instances are equal', () {
      expect(const SearchInitial(), equals(const SearchInitial()));
    });

    test('instances with same recentSearches are equal', () {
      expect(
        const SearchInitial(recentSearches: ['a', 'b']),
        equals(const SearchInitial(recentSearches: ['a', 'b'])),
      );
    });

    test('instances with different recentSearches are not equal', () {
      expect(
        const SearchInitial(recentSearches: ['a']),
        isNot(equals(const SearchInitial(recentSearches: ['b']))),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // SearchLoading
  // ─────────────────────────────────────────────────

  group('SearchLoading', () {
    test('stores query', () {
      const s = SearchLoading('flutter tutorial');
      expect(s.query, 'flutter tutorial');
    });

    test('type defaults to null', () {
      const s = SearchLoading('query');
      expect(s.type, isNull);
    });

    test('is a SearchState', () {
      expect(const SearchLoading('x'), isA<SearchState>());
    });

    test('props contains query', () {
      const s = SearchLoading('hello');
      expect(s.props, contains('hello'));
    });

    test('two instances with same query and null type are equal', () {
      expect(
        const SearchLoading('abc'),
        equals(const SearchLoading('abc')),
      );
    });

    test('instances with different queries are not equal', () {
      expect(
        const SearchLoading('x'),
        isNot(equals(const SearchLoading('y'))),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // SearchError
  // ─────────────────────────────────────────────────

  group('SearchError', () {
    test('stores message', () {
      const s = SearchError('Network timeout');
      expect(s.message, 'Network timeout');
    });

    test('is a SearchState', () {
      expect(const SearchError('err'), isA<SearchState>());
    });

    test('props contains message', () {
      const s = SearchError('oops');
      expect(s.props, contains('oops'));
    });

    test('two instances with same message are equal', () {
      expect(
        const SearchError('err1'),
        equals(const SearchError('err1')),
      );
    });

    test('instances with different messages are not equal', () {
      expect(
        const SearchError('err1'),
        isNot(equals(const SearchError('err2'))),
      );
    });
  });
}
