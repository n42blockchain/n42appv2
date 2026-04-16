// Tests for ConversationState — pure data class in conversation_state.dart.
// ConversationEntity-dependent fields are tested with empty lists;
// computed getters (displayConversations, isEmpty, hasSearchResults,
// noSearchResults) are tested purely through primitive inputs.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/blocs/conversation/conversation_state.dart';

void main() {
  // ─────────────────────────────────────────────────
  // Constructor defaults
  // ─────────────────────────────────────────────────

  group('ConversationState constructor defaults', () {
    const s = ConversationState();

    test('conversations defaults to empty list', () {
      expect(s.conversations, isEmpty);
    });

    test('filteredConversations defaults to null', () {
      expect(s.filteredConversations, isNull);
    });

    test('pinnedConversations defaults to empty list', () {
      expect(s.pinnedConversations, isEmpty);
    });

    test('normalConversations defaults to empty list', () {
      expect(s.normalConversations, isEmpty);
    });

    test('isLoading defaults to false', () {
      expect(s.isLoading, isFalse);
    });

    test('isRefreshing defaults to false', () {
      expect(s.isRefreshing, isFalse);
    });

    test('isSearching defaults to false', () {
      expect(s.isSearching, isFalse);
    });

    test('searchQuery defaults to null', () {
      expect(s.searchQuery, isNull);
    });

    test('error defaults to null', () {
      expect(s.error, isNull);
    });

    test('totalUnreadCount defaults to 0', () {
      expect(s.totalUnreadCount, 0);
    });

    test('newConversationId defaults to null', () {
      expect(s.newConversationId, isNull);
    });

    test('hiddenConversations defaults to empty list', () {
      expect(s.hiddenConversations, isEmpty);
    });

    test('isLoadingHidden defaults to false', () {
      expect(s.isLoadingHidden, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // ConversationState.initial()
  // ─────────────────────────────────────────────────

  group('ConversationState.initial()', () {
    test('isLoading is true', () {
      expect(ConversationState.initial().isLoading, isTrue);
    });

    test('conversations remain empty', () {
      expect(ConversationState.initial().conversations, isEmpty);
    });
  });

  // ─────────────────────────────────────────────────
  // isEmpty
  // ─────────────────────────────────────────────────

  group('ConversationState.isEmpty', () {
    test('true when conversations is empty (default)', () {
      expect(const ConversationState().isEmpty, isTrue);
    });
  });

  // ─────────────────────────────────────────────────
  // displayConversations
  // ─────────────────────────────────────────────────

  group('ConversationState.displayConversations', () {
    test('not searching → returns conversations (empty list)', () {
      const s = ConversationState(isSearching: false);
      expect(s.displayConversations, isEmpty);
    });

    test('searching with null filteredConversations → returns conversations', () {
      const s = ConversationState(isSearching: true);
      // filteredConversations is null → falls back to conversations (empty)
      expect(s.displayConversations, isEmpty);
    });

    test('not searching even with filteredConversations set → returns conversations', () {
      const s = ConversationState(
        isSearching: false,
        filteredConversations: [],
      );
      expect(s.displayConversations, isEmpty);
    });
  });

  // ─────────────────────────────────────────────────
  // hasSearchResults / noSearchResults
  // ─────────────────────────────────────────────────

  group('ConversationState.hasSearchResults', () {
    test('not searching → false', () {
      const s = ConversationState(isSearching: false);
      expect(s.hasSearchResults, isFalse);
    });

    test('searching with null filter → false', () {
      const s = ConversationState(isSearching: true);
      expect(s.hasSearchResults, isFalse);
    });

    test('searching with empty filter → false', () {
      const s = ConversationState(
        isSearching: true,
        filteredConversations: [],
      );
      expect(s.hasSearchResults, isFalse);
    });
  });

  group('ConversationState.noSearchResults', () {
    test('not searching → false', () {
      const s = ConversationState(isSearching: false);
      expect(s.noSearchResults, isFalse);
    });

    test('searching with null filter → true (no results)', () {
      const s = ConversationState(isSearching: true);
      expect(s.noSearchResults, isTrue);
    });

    test('searching with empty filter → true', () {
      const s = ConversationState(
        isSearching: true,
        filteredConversations: [],
      );
      expect(s.noSearchResults, isTrue);
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — scalar overrides
  // ─────────────────────────────────────────────────

  group('ConversationState.copyWith', () {
    const base = ConversationState(
      isLoading: true,
      totalUnreadCount: 5,
      searchQuery: 'hello',
      error: 'some error',
      newConversationId: 'conv123',
    );

    test('no overrides preserves all fields', () {
      final copy = base.copyWith();
      expect(copy.isLoading, isTrue);
      expect(copy.totalUnreadCount, 5);
      expect(copy.searchQuery, 'hello');
      expect(copy.newConversationId, 'conv123');
      // Note: error behaves with clearError flag
    });

    test('overrides isLoading', () {
      final copy = base.copyWith(isLoading: false);
      expect(copy.isLoading, isFalse);
    });

    test('overrides isRefreshing', () {
      final copy = base.copyWith(isRefreshing: true);
      expect(copy.isRefreshing, isTrue);
    });

    test('overrides isSearching', () {
      final copy = base.copyWith(isSearching: true);
      expect(copy.isSearching, isTrue);
    });

    test('overrides searchQuery', () {
      final copy = base.copyWith(searchQuery: 'world');
      expect(copy.searchQuery, 'world');
    });

    test('overrides totalUnreadCount', () {
      final copy = base.copyWith(totalUnreadCount: 10);
      expect(copy.totalUnreadCount, 10);
    });

    test('overrides isLoadingHidden', () {
      final copy = base.copyWith(isLoadingHidden: true);
      expect(copy.isLoadingHidden, isTrue);
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — clear flags
  // ─────────────────────────────────────────────────

  group('ConversationState.copyWith clear flags', () {
    const withData = ConversationState(
      error: 'net error',
      newConversationId: 'conv456',
      filteredConversations: [],
    );

    test('clearError=true sets error to null', () {
      final copy = withData.copyWith(clearError: true);
      expect(copy.error, isNull);
    });

    test('clearError=false without new value preserves error', () {
      final copy = withData.copyWith(clearError: false);
      expect(copy.error, 'net error');
    });

    test('clearNewConversationId=true clears it', () {
      final copy = withData.copyWith(clearNewConversationId: true);
      expect(copy.newConversationId, isNull);
    });

    test('clearNewConversationId=false preserves it', () {
      final copy = withData.copyWith(clearNewConversationId: false);
      expect(copy.newConversationId, 'conv456');
    });

    test('clearFilteredConversations=true sets filtered to null', () {
      final copy = withData.copyWith(clearFilteredConversations: true);
      expect(copy.filteredConversations, isNull);
    });

    test('clearFilteredConversations=false preserves filtered list', () {
      final copy = withData.copyWith(clearFilteredConversations: false);
      expect(copy.filteredConversations, []);
    });
  });

  // ─────────────────────────────────────────────────
  // Equatable equality
  // ─────────────────────────────────────────────────

  group('ConversationState Equatable equality', () {
    test('two default instances are equal', () {
      expect(const ConversationState(), equals(const ConversationState()));
    });

    test('states with different isLoading are not equal', () {
      expect(
        const ConversationState(isLoading: true),
        isNot(equals(const ConversationState(isLoading: false))),
      );
    });

    test('states with different totalUnreadCount are not equal', () {
      expect(
        const ConversationState(totalUnreadCount: 3),
        isNot(equals(const ConversationState(totalUnreadCount: 0))),
      );
    });

    test('states with different error are not equal', () {
      expect(
        const ConversationState(error: 'err'),
        isNot(equals(const ConversationState())),
      );
    });

    test('states with different searchQuery are not equal', () {
      expect(
        const ConversationState(searchQuery: 'abc'),
        isNot(equals(const ConversationState())),
      );
    });
  });
}
