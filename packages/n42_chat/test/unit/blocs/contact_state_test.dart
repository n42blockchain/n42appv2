// Tests for ContactStatus enum and ContactState in contact_state.dart.
// ContactEntity / FriendRequest fields are kept empty in tests.
//
// copyWith behaviour:
//   Uses ??: status, contacts, filteredContacts, searchResults,
//     friendRequests, groupedContacts, indexLetters, searchQuery,
//     isSearching, isGlobalSearching
//   Resets to null on omit: startedChatRoomId, startedChatUserId,
//     updatedRemarkUserId, updatedRemark, deletedUserId, errorMessage

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/blocs/contact/contact_state.dart';

void main() {
  // ─────────────────────────────────────────────────
  // ContactStatus enum
  // ─────────────────────────────────────────────────

  group('ContactStatus enum', () {
    test('has 7 values', () {
      expect(ContactStatus.values, hasLength(7));
    });

    test('contains initial', () {
      expect(ContactStatus.values, contains(ContactStatus.initial));
    });

    test('contains loading', () {
      expect(ContactStatus.values, contains(ContactStatus.loading));
    });

    test('contains loaded', () {
      expect(ContactStatus.values, contains(ContactStatus.loaded));
    });

    test('contains chatStarted', () {
      expect(ContactStatus.values, contains(ContactStatus.chatStarted));
    });

    test('contains remarkUpdated', () {
      expect(ContactStatus.values, contains(ContactStatus.remarkUpdated));
    });

    test('contains deleted', () {
      expect(ContactStatus.values, contains(ContactStatus.deleted));
    });

    test('contains error', () {
      expect(ContactStatus.values, contains(ContactStatus.error));
    });
  });

  // ─────────────────────────────────────────────────
  // Constructor defaults
  // ─────────────────────────────────────────────────

  group('ContactState constructor defaults', () {
    const s = ContactState();

    test('status defaults to initial', () {
      expect(s.status, ContactStatus.initial);
    });

    test('contacts defaults to empty list', () {
      expect(s.contacts, isEmpty);
    });

    test('filteredContacts defaults to empty list', () {
      expect(s.filteredContacts, isEmpty);
    });

    test('searchResults defaults to empty list', () {
      expect(s.searchResults, isEmpty);
    });

    test('friendRequests defaults to empty list', () {
      expect(s.friendRequests, isEmpty);
    });

    test('groupedContacts defaults to empty map', () {
      expect(s.groupedContacts, isEmpty);
    });

    test('indexLetters defaults to empty list', () {
      expect(s.indexLetters, isEmpty);
    });

    test('searchQuery defaults to empty string', () {
      expect(s.searchQuery, '');
    });

    test('isSearching defaults to false', () {
      expect(s.isSearching, isFalse);
    });

    test('isGlobalSearching defaults to false', () {
      expect(s.isGlobalSearching, isFalse);
    });

    test('startedChatRoomId defaults to null', () {
      expect(s.startedChatRoomId, isNull);
    });

    test('startedChatUserId defaults to null', () {
      expect(s.startedChatUserId, isNull);
    });

    test('updatedRemarkUserId defaults to null', () {
      expect(s.updatedRemarkUserId, isNull);
    });

    test('updatedRemark defaults to null', () {
      expect(s.updatedRemark, isNull);
    });

    test('deletedUserId defaults to null', () {
      expect(s.deletedUserId, isNull);
    });

    test('errorMessage defaults to null', () {
      expect(s.errorMessage, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // ContactState.initial()
  // ─────────────────────────────────────────────────

  group('ContactState.initial()', () {
    test('is equal to default constructor state', () {
      expect(const ContactState.initial(), equals(const ContactState()));
    });

    test('status is initial', () {
      expect(const ContactState.initial().status, ContactStatus.initial);
    });
  });

  // ─────────────────────────────────────────────────
  // isLoading getter
  // ─────────────────────────────────────────────────

  group('ContactState.isLoading', () {
    test('true when status == loading', () {
      const s = ContactState(status: ContactStatus.loading);
      expect(s.isLoading, isTrue);
    });

    test('false when status == initial', () {
      expect(const ContactState().isLoading, isFalse);
    });

    test('false when status == loaded', () {
      const s = ContactState(status: ContactStatus.loaded);
      expect(s.isLoading, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // isLoaded getter
  // ─────────────────────────────────────────────────

  group('ContactState.isLoaded', () {
    test('true when status == loaded', () {
      const s = ContactState(status: ContactStatus.loaded);
      expect(s.isLoaded, isTrue);
    });

    test('true when contacts is non-empty (even with initial status)', () {
      // isLoaded = status==loaded || contacts.isNotEmpty
      const s = ContactState(contacts: []);
      // empty contacts with initial status → false
      expect(s.isLoaded, isFalse);
    });

    test('false when status == initial and contacts is empty', () {
      expect(const ContactState().isLoaded, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // hasError getter
  // ─────────────────────────────────────────────────

  group('ContactState.hasError', () {
    test('true when status == error and errorMessage is set', () {
      const s = ContactState(
        status: ContactStatus.error,
        errorMessage: 'network error',
      );
      expect(s.hasError, isTrue);
    });

    test('false when status == error but no errorMessage', () {
      const s = ContactState(status: ContactStatus.error);
      expect(s.hasError, isFalse);
    });

    test('false when errorMessage set but status != error', () {
      const s = ContactState(errorMessage: 'msg');
      expect(s.hasError, isFalse);
    });

    test('false in default state', () {
      expect(const ContactState().hasError, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — ?? fields (preserve when omitted)
  // ─────────────────────────────────────────────────

  group('ContactState.copyWith — ?? fields', () {
    const base = ContactState(
      status: ContactStatus.loaded,
      searchQuery: 'alice',
      isSearching: true,
      isGlobalSearching: true,
      indexLetters: ['A', 'B'],
    );

    test('no overrides preserves all ?? fields', () {
      final copy = base.copyWith();
      expect(copy.status, ContactStatus.loaded);
      expect(copy.searchQuery, 'alice');
      expect(copy.isSearching, isTrue);
      expect(copy.isGlobalSearching, isTrue);
      expect(copy.indexLetters, ['A', 'B']);
    });

    test('overrides status', () {
      final copy = base.copyWith(status: ContactStatus.loading);
      expect(copy.status, ContactStatus.loading);
    });

    test('overrides searchQuery', () {
      final copy = base.copyWith(searchQuery: 'bob');
      expect(copy.searchQuery, 'bob');
    });

    test('overrides isSearching', () {
      final copy = base.copyWith(isSearching: false);
      expect(copy.isSearching, isFalse);
    });

    test('overrides isGlobalSearching', () {
      final copy = base.copyWith(isGlobalSearching: false);
      expect(copy.isGlobalSearching, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — reset-on-omit fields
  // ─────────────────────────────────────────────────

  group('ContactState.copyWith — reset-on-omit fields', () {
    const withData = ContactState(
      startedChatRoomId: '!room:server',
      startedChatUserId: '@user:server',
      updatedRemarkUserId: '@user2:server',
      updatedRemark: 'My Friend',
      deletedUserId: '@user3:server',
      errorMessage: 'load failed',
    );

    test('copyWith() resets startedChatRoomId to null', () {
      expect(withData.copyWith().startedChatRoomId, isNull);
    });

    test('copyWith() resets startedChatUserId to null', () {
      expect(withData.copyWith().startedChatUserId, isNull);
    });

    test('copyWith() resets updatedRemarkUserId to null', () {
      expect(withData.copyWith().updatedRemarkUserId, isNull);
    });

    test('copyWith() resets updatedRemark to null', () {
      expect(withData.copyWith().updatedRemark, isNull);
    });

    test('copyWith() resets deletedUserId to null', () {
      expect(withData.copyWith().deletedUserId, isNull);
    });

    test('copyWith() resets errorMessage to null', () {
      expect(withData.copyWith().errorMessage, isNull);
    });

    test('copyWith with startedChatRoomId sets new value', () {
      final copy = withData.copyWith(startedChatRoomId: '!other:server');
      expect(copy.startedChatRoomId, '!other:server');
    });

    test('copyWith with errorMessage sets new value', () {
      final copy = withData.copyWith(errorMessage: 'network error');
      expect(copy.errorMessage, 'network error');
    });

    test('?? fields preserved while reset fields cleared', () {
      const s = ContactState(
        status: ContactStatus.chatStarted,
        errorMessage: 'old error',
      );
      final copy = s.copyWith();
      expect(copy.status, ContactStatus.chatStarted); // ?? preserved
      expect(copy.errorMessage, isNull);              // reset
    });
  });

  // ─────────────────────────────────────────────────
  // toString
  // ─────────────────────────────────────────────────

  group('ContactState.toString', () {
    test('contains status', () {
      const s = ContactState(status: ContactStatus.loading);
      expect(s.toString(), contains('loading'));
    });

    test('contains contacts count', () {
      const s = ContactState();
      expect(s.toString(), contains('0'));
    });
  });

  // ─────────────────────────────────────────────────
  // Equatable equality
  // ─────────────────────────────────────────────────

  group('ContactState Equatable equality', () {
    test('two default instances are equal', () {
      expect(const ContactState(), equals(const ContactState()));
    });

    test('different status → not equal', () {
      expect(
        const ContactState(status: ContactStatus.loading),
        isNot(equals(const ContactState())),
      );
    });

    test('different searchQuery → not equal', () {
      expect(
        const ContactState(searchQuery: 'hello'),
        isNot(equals(const ContactState())),
      );
    });

    test('different errorMessage → not equal', () {
      expect(
        const ContactState(errorMessage: 'err'),
        isNot(equals(const ContactState())),
      );
    });

    test('same fields → equal', () {
      expect(
        const ContactState(
          status: ContactStatus.loaded,
          searchQuery: 'test',
        ),
        equals(const ContactState(
          status: ContactStatus.loaded,
          searchQuery: 'test',
        )),
      );
    });
  });
}
