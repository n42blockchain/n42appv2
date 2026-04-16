// Tests for SearchEvent subclasses in search_event.dart.
// Pure Dart Equatable event classes — uses SearchResultType enum.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/search_result_entity.dart';
import 'package:n42_chat/src/presentation/blocs/search/search_event.dart';

void main() {
  // ─────────────────────────────────────────────────
  // Parameterless events
  // ─────────────────────────────────────────────────

  group('ClearSearch', () {
    test('is a SearchEvent', () => expect(const ClearSearch(), isA<SearchEvent>()));
    test('two instances are equal', () => expect(const ClearSearch(), equals(const ClearSearch())));
  });

  group('LoadSearchHistory', () {
    test('is a SearchEvent', () => expect(const LoadSearchHistory(), isA<SearchEvent>()));
    test('two instances are equal', () => expect(const LoadSearchHistory(), equals(const LoadSearchHistory())));
  });

  group('ClearSearchHistory', () {
    test('is a SearchEvent', () => expect(const ClearSearchHistory(), isA<SearchEvent>()));
    test('two instances are equal', () => expect(const ClearSearchHistory(), equals(const ClearSearchHistory())));
  });

  group('NavigateToNextResult', () {
    test('two instances are equal', () => expect(const NavigateToNextResult(), equals(const NavigateToNextResult())));
  });

  group('NavigateToPreviousResult', () {
    test('two instances are equal', () => expect(const NavigateToPreviousResult(), equals(const NavigateToPreviousResult())));
  });

  group('LoadMoreChatResults', () {
    test('two instances are equal', () => expect(const LoadMoreChatResults(), equals(const LoadMoreChatResults())));
  });

  // ─────────────────────────────────────────────────
  // PerformSearch
  // ─────────────────────────────────────────────────

  group('PerformSearch', () {
    test('stores query', () {
      const e = PerformSearch('matrix');
      expect(e.query, 'matrix');
    });

    test('type defaults to null', () {
      const e = PerformSearch('query');
      expect(e.type, isNull);
    });

    test('stores type when provided', () {
      const e = PerformSearch('alice', type: SearchResultType.contact);
      expect(e.type, SearchResultType.contact);
    });

    test('same fields → equal', () {
      expect(
        const PerformSearch('q', type: SearchResultType.message),
        equals(const PerformSearch('q', type: SearchResultType.message)),
      );
    });

    test('different query → not equal', () {
      expect(const PerformSearch('a'), isNot(equals(const PerformSearch('b'))));
    });

    test('different type → not equal', () {
      expect(
        const PerformSearch('q', type: SearchResultType.contact),
        isNot(equals(const PerformSearch('q', type: SearchResultType.group))),
      );
    });

    test('is a SearchEvent', () {
      expect(const PerformSearch('q'), isA<SearchEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // SearchContacts / SearchGroups / SearchMessages
  // ─────────────────────────────────────────────────

  group('SearchContacts', () {
    test('stores query', () {
      const e = SearchContacts('alice');
      expect(e.query, 'alice');
    });

    test('same query → equal', () {
      expect(const SearchContacts('q'), equals(const SearchContacts('q')));
    });

    test('different query → not equal', () {
      expect(const SearchContacts('a'), isNot(equals(const SearchContacts('b'))));
    });

    test('is a SearchEvent', () => expect(const SearchContacts('q'), isA<SearchEvent>()));
  });

  group('SearchGroups', () {
    test('stores query', () {
      expect(const SearchGroups('devs').query, 'devs');
    });

    test('same query → equal', () {
      expect(const SearchGroups('g'), equals(const SearchGroups('g')));
    });

    test('is a SearchEvent', () => expect(const SearchGroups('q'), isA<SearchEvent>()));
  });

  group('SearchMessages', () {
    test('stores query', () {
      const e = SearchMessages('hello');
      expect(e.query, 'hello');
    });

    test('roomId defaults to null', () {
      expect(const SearchMessages('q').roomId, isNull);
    });

    test('stores roomId when provided', () {
      const e = SearchMessages('q', roomId: '!r:s');
      expect(e.roomId, '!r:s');
    });

    test('same fields → equal', () {
      expect(
        const SearchMessages('q', roomId: '!r:s'),
        equals(const SearchMessages('q', roomId: '!r:s')),
      );
    });

    test('different roomId → not equal', () {
      expect(
        const SearchMessages('q', roomId: '!a:s'),
        isNot(equals(const SearchMessages('q', roomId: '!b:s'))),
      );
    });

    test('is a SearchEvent', () => expect(const SearchMessages('q'), isA<SearchEvent>()));
  });

  // ─────────────────────────────────────────────────
  // DeleteSearchHistoryItem
  // ─────────────────────────────────────────────────

  group('DeleteSearchHistoryItem', () {
    test('stores query', () {
      const e = DeleteSearchHistoryItem('old query');
      expect(e.query, 'old query');
    });

    test('same query → equal', () {
      expect(
        const DeleteSearchHistoryItem('q'),
        equals(const DeleteSearchHistoryItem('q')),
      );
    });

    test('is a SearchEvent', () {
      expect(const DeleteSearchHistoryItem('q'), isA<SearchEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // ChangeSearchType
  // ─────────────────────────────────────────────────

  group('ChangeSearchType', () {
    test('stores type', () {
      const e = ChangeSearchType(SearchResultType.message);
      expect(e.type, SearchResultType.message);
    });

    test('same type → equal', () {
      expect(
        const ChangeSearchType(SearchResultType.contact),
        equals(const ChangeSearchType(SearchResultType.contact)),
      );
    });

    test('different type → not equal', () {
      expect(
        const ChangeSearchType(SearchResultType.contact),
        isNot(equals(const ChangeSearchType(SearchResultType.group))),
      );
    });

    test('is a SearchEvent', () {
      expect(const ChangeSearchType(SearchResultType.all), isA<SearchEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // SearchInChat / NavigateToResultIndex
  // ─────────────────────────────────────────────────

  group('SearchInChat', () {
    test('stores roomId and query', () {
      const e = SearchInChat('!room:server', 'hello');
      expect(e.roomId, '!room:server');
      expect(e.query, 'hello');
    });

    test('same fields → equal', () {
      expect(
        const SearchInChat('!r:s', 'q'),
        equals(const SearchInChat('!r:s', 'q')),
      );
    });

    test('is a SearchEvent', () {
      expect(const SearchInChat('!r:s', 'q'), isA<SearchEvent>());
    });
  });

  group('NavigateToResultIndex', () {
    test('stores index', () {
      const e = NavigateToResultIndex(3);
      expect(e.index, 3);
    });

    test('same index → equal', () {
      expect(const NavigateToResultIndex(0), equals(const NavigateToResultIndex(0)));
    });

    test('different index → not equal', () {
      expect(
        const NavigateToResultIndex(1),
        isNot(equals(const NavigateToResultIndex(2))),
      );
    });

    test('is a SearchEvent', () {
      expect(const NavigateToResultIndex(0), isA<SearchEvent>());
    });
  });
}
