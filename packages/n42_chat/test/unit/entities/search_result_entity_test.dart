import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';
import 'package:n42_chat/src/domain/entities/search_result_entity.dart';

void main() {
  group('SearchResultType', () {
    test('has 5 values', () {
      expect(SearchResultType.values.length, 5);
      expect(
        SearchResultType.values,
        containsAll([
          SearchResultType.contact,
          SearchResultType.group,
          SearchResultType.conversation,
          SearchResultType.message,
          SearchResultType.all,
        ]),
      );
    });
  });

  group('MessageSearchFilter', () {
    test('isEmpty is true for default filter', () {
      const filter = MessageSearchFilter();

      expect(filter.isEmpty, isTrue);
      expect(filter.activeCount, 0);
    });

    test('tracks active filters and supports copyWith clearing', () {
      const filter = MessageSearchFilter(
        senderId: '@alice:server.test',
        messageType: MessageType.file,
        onlyFromMe: true,
      );
      final cleared = filter.copyWith(
        senderId: null,
        messageType: null,
        onlyFromMe: false,
      );

      expect(filter.activeCount, 3);
      expect(cleared.senderId, isNull);
      expect(cleared.messageType, isNull);
      expect(cleared.onlyFromMe, isFalse);
    });
  });

  group('SearchResultItem', () {
    test('constructs with required fields', () {
      const item = SearchResultItem(
        type: SearchResultType.contact,
        id: 'user-1',
        title: 'Alice',
      );

      expect(item.type, SearchResultType.contact);
      expect(item.id, 'user-1');
      expect(item.title, 'Alice');
      expect(item.subtitle, isNull);
      expect(item.avatarUrl, isNull);
      expect(item.matchedKeyword, isNull);
      expect(item.matchedContent, isNull);
      expect(item.timestamp, isNull);
      expect(item.roomId, isNull);
      expect(item.rawData, isNull);
    });

    test('constructs with all fields', () {
      final ts = DateTime(2025, 6, 1);
      const rawData = {'key': 'value'};

      final item = SearchResultItem(
        type: SearchResultType.message,
        id: 'msg-1',
        title: 'Room Name',
        subtitle: 'Alice',
        avatarUrl: 'https://example.com/avatar.jpg',
        matchedKeyword: 'hello',
        matchedContent: 'Hello, world!',
        timestamp: ts,
        roomId: '!room:server.com',
        rawData: rawData,
      );

      expect(item.subtitle, 'Alice');
      expect(item.avatarUrl, 'https://example.com/avatar.jpg');
      expect(item.matchedKeyword, 'hello');
      expect(item.matchedContent, 'Hello, world!');
      expect(item.timestamp, ts);
      expect(item.roomId, '!room:server.com');
      expect(item.rawData, rawData);
    });

    group('props equality', () {
      test('equal items with same core fields', () {
        final ts = DateTime(2025, 1, 1);
        final a = SearchResultItem(
          type: SearchResultType.contact,
          id: 'u1',
          title: 'Alice',
          timestamp: ts,
        );
        final b = SearchResultItem(
          type: SearchResultType.contact,
          id: 'u1',
          title: 'Alice',
          timestamp: ts,
        );

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('different ids produce different items', () {
        const a = SearchResultItem(
          type: SearchResultType.contact,
          id: 'u1',
          title: 'Alice',
        );
        const b = SearchResultItem(
          type: SearchResultType.contact,
          id: 'u2',
          title: 'Alice',
        );

        expect(a, isNot(equals(b)));
      });

      test('rawData is excluded from props', () {
        // rawData is NOT in props list, so same core fields with different rawData → equal
        const a = SearchResultItem(
          type: SearchResultType.contact,
          id: 'u1',
          title: 'Alice',
          rawData: 'dataA',
        );
        const b = SearchResultItem(
          type: SearchResultType.contact,
          id: 'u1',
          title: 'Alice',
          rawData: 'dataB',
        );

        expect(a, equals(b));
      });
    });
  });

  group('SearchResults', () {
    const emptyResults = SearchResults();

    test('defaults are empty', () {
      expect(emptyResults.contacts, isEmpty);
      expect(emptyResults.groups, isEmpty);
      expect(emptyResults.conversations, isEmpty);
      expect(emptyResults.messages, isEmpty);
      expect(emptyResults.query, '');
      expect(emptyResults.isSearching, isFalse);
      expect(emptyResults.hasMore, isFalse);
      expect(emptyResults.messageFilter, isNull);
    });

    test('isEmpty is true when no results', () {
      expect(emptyResults.isEmpty, isTrue);
    });

    test('totalCount sums all categories', () {
      const item = SearchResultItem(
        type: SearchResultType.contact,
        id: 'x',
        title: 'X',
      );
      const results = SearchResults(
        contacts: [item],
        groups: [item],
        conversations: [item, item],
        messages: [item],
      );
      expect(results.totalCount, 5);
      expect(results.isEmpty, isFalse);
    });

    test('allResults combines all categories in order', () {
      const c = SearchResultItem(
        type: SearchResultType.contact,
        id: 'c',
        title: 'C',
      );
      const g = SearchResultItem(
        type: SearchResultType.group,
        id: 'g',
        title: 'G',
      );
      const conv = SearchResultItem(
        type: SearchResultType.conversation,
        id: 'cv',
        title: 'CV',
      );
      const m = SearchResultItem(
        type: SearchResultType.message,
        id: 'm',
        title: 'M',
      );

      const results = SearchResults(
        contacts: [c],
        groups: [g],
        conversations: [conv],
        messages: [m],
      );

      expect(results.allResults, [c, g, conv, m]);
    });

    test('has* getters reflect presence of items', () {
      const item = SearchResultItem(
        type: SearchResultType.contact,
        id: 'x',
        title: 'X',
      );
      const results = SearchResults(contacts: [item]);

      expect(results.hasContacts, isTrue);
      expect(results.hasGroups, isFalse);
      expect(results.hasConversations, isFalse);
      expect(results.hasMessages, isFalse);
    });

    test('copyWith replaces fields', () {
      const original = SearchResults(query: 'hello');
      const item = SearchResultItem(
        type: SearchResultType.contact,
        id: 'x',
        title: 'X',
      );
      const filter = MessageSearchFilter(onlyFromMe: true);
      final updated = original.copyWith(
        contacts: [item],
        isSearching: true,
        messageFilter: filter,
      );

      expect(updated.query, 'hello');
      expect(updated.contacts, [item]);
      expect(updated.isSearching, isTrue);
      expect(updated.messageFilter, filter);
    });
  });

  group('ChatSearchResults', () {
    test('defaults are correct', () {
      const results = ChatSearchResults();

      expect(results.messages, isEmpty);
      expect(results.query, '');
      expect(results.roomId, '');
      expect(results.currentIndex, 0);
      expect(results.isSearching, isFalse);
      expect(results.hasMore, isFalse);
      expect(results.filter, isNull);
      expect(results.isEmpty, isTrue);
      expect(results.totalCount, 0);
      expect(results.currentMessage, isNull);
      expect(results.hasPrevious, isFalse);
      expect(results.hasNext, isFalse);
    });
  });
}
