// Tests for ChatState — pure data class in chat_state.dart.
// Tests cover constructor defaults, factory, computed getters,
// copyWith (including clearError/clearReplyTarget/clearEditingMessage flags),
// and translation map helpers.
// MessageEntity-dependent paths (replyTarget, editingMessage, pinnedMessages
// with actual entries) are not covered here.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/blocs/chat/chat_state.dart';

void main() {
  // ─────────────────────────────────────────────────
  // Constructor defaults
  // ─────────────────────────────────────────────────

  group('ChatState constructor defaults', () {
    const state = ChatState();

    test('roomId defaults to null', () {
      expect(state.roomId, isNull);
    });

    test('messages defaults to empty list', () {
      expect(state.messages, isEmpty);
    });

    test('isLoading defaults to false', () {
      expect(state.isLoading, isFalse);
    });

    test('isLoadingMore defaults to false', () {
      expect(state.isLoadingMore, isFalse);
    });

    test('hasMore defaults to true', () {
      expect(state.hasMore, isTrue);
    });

    test('isSending defaults to false', () {
      expect(state.isSending, isFalse);
    });

    test('error defaults to null', () {
      expect(state.error, isNull);
    });

    test('replyTarget defaults to null', () {
      expect(state.replyTarget, isNull);
    });

    test('editingMessage defaults to null', () {
      expect(state.editingMessage, isNull);
    });

    test('typingUsers defaults to empty list', () {
      expect(state.typingUsers, isEmpty);
    });

    test('draft defaults to null', () {
      expect(state.draft, isNull);
    });

    test('pinnedMessages defaults to empty list', () {
      expect(state.pinnedMessages, isEmpty);
    });

    test('currentPinnedIndex defaults to 0', () {
      expect(state.currentPinnedIndex, 0);
    });

    test('canPinMessages defaults to false', () {
      expect(state.canPinMessages, isFalse);
    });

    test('translatedMessages defaults to empty map', () {
      expect(state.translatedMessages, isEmpty);
    });

    test('translatingMessageIds defaults to empty set', () {
      expect(state.translatingMessageIds, isEmpty);
    });

    test('detectedSourceLanguages defaults to empty map', () {
      expect(state.detectedSourceLanguages, isEmpty);
    });
  });

  // ─────────────────────────────────────────────────
  // ChatState.initial() factory
  // ─────────────────────────────────────────────────

  group('ChatState.initial()', () {
    test('sets isLoading to true', () {
      expect(ChatState.initial().isLoading, isTrue);
    });

    test('all other fields remain at defaults', () {
      final s = ChatState.initial();
      expect(s.messages, isEmpty);
      expect(s.roomId, isNull);
      expect(s.error, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // Computed getters — no MessageEntity needed
  // ─────────────────────────────────────────────────

  group('ChatState.isEmpty', () {
    test('true when messages is empty', () {
      expect(const ChatState().isEmpty, isTrue);
    });
  });

  group('ChatState.hasReplyTarget', () {
    test('false when replyTarget is null', () {
      expect(const ChatState().hasReplyTarget, isFalse);
    });
  });

  group('ChatState.isEditing', () {
    test('false when editingMessage is null', () {
      expect(const ChatState().isEditing, isFalse);
    });
  });

  group('ChatState.hasTypingUsers', () {
    test('false when typingUsers is empty', () {
      expect(const ChatState().hasTypingUsers, isFalse);
    });

    test('true when typingUsers has one entry', () {
      const s = ChatState(typingUsers: ['@alice:server']);
      expect(s.hasTypingUsers, isTrue);
    });
  });

  group('ChatState.hasPinnedMessages', () {
    test('false when pinnedMessages is empty', () {
      expect(const ChatState().hasPinnedMessages, isFalse);
    });
  });

  group('ChatState.currentPinnedMessage', () {
    test('null when pinnedMessages is empty', () {
      expect(const ChatState().currentPinnedMessage, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // typingText getter
  // ─────────────────────────────────────────────────

  group('ChatState.typingText', () {
    test('empty string when no users typing', () {
      expect(const ChatState().typingText, '');
    });

    test('single user → "<user> is typing..."', () {
      const s = ChatState(typingUsers: ['Alice']);
      expect(s.typingText, 'Alice is typing...');
    });

    test('two users → "2 people typing..."', () {
      const s = ChatState(typingUsers: ['Alice', 'Bob']);
      expect(s.typingText, '2 people typing...');
    });

    test('three users → "3 people typing..."', () {
      const s = ChatState(typingUsers: ['A', 'B', 'C']);
      expect(s.typingText, '3 people typing...');
    });
  });

  // ─────────────────────────────────────────────────
  // Translation helpers
  // ─────────────────────────────────────────────────

  group('ChatState.isTranslating', () {
    test('false when set is empty', () {
      expect(const ChatState().isTranslating('msg1'), isFalse);
    });

    test('true when id is in translatingMessageIds', () {
      const s = ChatState(translatingMessageIds: {'msg1', 'msg2'});
      expect(s.isTranslating('msg1'), isTrue);
    });

    test('false when id is not in translatingMessageIds', () {
      const s = ChatState(translatingMessageIds: {'msg2'});
      expect(s.isTranslating('msg1'), isFalse);
    });
  });

  group('ChatState.getTranslation', () {
    test('null when translatedMessages is empty', () {
      expect(const ChatState().getTranslation('msg1'), isNull);
    });

    test('returns translated text when present', () {
      const s = ChatState(translatedMessages: {'msg1': 'Hola'});
      expect(s.getTranslation('msg1'), 'Hola');
    });

    test('null when id not present', () {
      const s = ChatState(translatedMessages: {'msg2': 'Hello'});
      expect(s.getTranslation('msg1'), isNull);
    });
  });

  group('ChatState.getDetectedLanguage', () {
    test('null when detectedSourceLanguages is empty', () {
      expect(const ChatState().getDetectedLanguage('msg1'), isNull);
    });

    test('returns language code when present', () {
      const s = ChatState(detectedSourceLanguages: {'msg1': 'es'});
      expect(s.getDetectedLanguage('msg1'), 'es');
    });

    test('null when id not present', () {
      const s = ChatState(detectedSourceLanguages: {'msg2': 'fr'});
      expect(s.getDetectedLanguage('msg1'), isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — scalar field overrides
  // ─────────────────────────────────────────────────

  group('ChatState.copyWith', () {
    const base = ChatState(roomId: 'room1', isLoading: true, error: 'oops');

    test('no overrides preserves all fields', () {
      final copy = base.copyWith();
      expect(copy.roomId, 'room1');
      expect(copy.isLoading, isTrue);
      expect(copy.error, 'oops');
    });

    test('overrides roomId', () {
      final copy = base.copyWith(roomId: 'room2');
      expect(copy.roomId, 'room2');
      expect(copy.isLoading, isTrue); // unchanged
    });

    test('overrides isLoading', () {
      final copy = base.copyWith(isLoading: false);
      expect(copy.isLoading, isFalse);
      expect(copy.roomId, 'room1'); // unchanged
    });

    test('overrides isSending', () {
      final copy = base.copyWith(isSending: true);
      expect(copy.isSending, isTrue);
    });

    test('overrides hasMore', () {
      final copy = const ChatState(hasMore: true).copyWith(hasMore: false);
      expect(copy.hasMore, isFalse);
    });

    test('overrides draft', () {
      final copy = base.copyWith(draft: 'Hello world');
      expect(copy.draft, 'Hello world');
    });

    test('overrides typingUsers', () {
      final copy = base.copyWith(typingUsers: ['@bob:server']);
      expect(copy.typingUsers, ['@bob:server']);
    });

    test('overrides currentPinnedIndex', () {
      final copy = base.copyWith(currentPinnedIndex: 3);
      expect(copy.currentPinnedIndex, 3);
    });

    test('overrides canPinMessages', () {
      final copy = base.copyWith(canPinMessages: true);
      expect(copy.canPinMessages, isTrue);
    });

    test('overrides translatedMessages', () {
      final copy = base.copyWith(translatedMessages: {'m1': 'translated'});
      expect(copy.translatedMessages, {'m1': 'translated'});
    });

    test('overrides translatingMessageIds', () {
      final copy = base.copyWith(translatingMessageIds: {'m1'});
      expect(copy.translatingMessageIds, {'m1'});
    });

    test('overrides detectedSourceLanguages', () {
      final copy = base.copyWith(detectedSourceLanguages: {'m1': 'zh'});
      expect(copy.detectedSourceLanguages, {'m1': 'zh'});
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — clear flags
  // ─────────────────────────────────────────────────

  group('ChatState.copyWith clear flags', () {
    const withError = ChatState(error: 'some error');

    test('clearError=true sets error to null', () {
      final copy = withError.copyWith(clearError: true);
      expect(copy.error, isNull);
    });

    test('clearError=false preserves error when no new value given', () {
      final copy = withError.copyWith(clearError: false);
      expect(copy.error, 'some error');
    });

    test('clearError=true overrides provided error value', () {
      // clearError takes priority, error param is ignored
      final copy = withError.copyWith(clearError: true, error: 'new error');
      expect(copy.error, isNull);
    });

    test('clearReplyTarget=true sets replyTarget to null', () {
      // replyTarget starts null; remains null after clear
      const s = ChatState();
      final copy = s.copyWith(clearReplyTarget: true);
      expect(copy.replyTarget, isNull);
    });

    test('clearEditingMessage=true sets editingMessage to null', () {
      const s = ChatState();
      final copy = s.copyWith(clearEditingMessage: true);
      expect(copy.editingMessage, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // Equatable props (equality)
  // ─────────────────────────────────────────────────

  group('ChatState Equatable equality', () {
    test('two default instances are equal', () {
      expect(const ChatState(), equals(const ChatState()));
    });

    test('states with different roomId are not equal', () {
      expect(
        const ChatState(roomId: 'r1'),
        isNot(equals(const ChatState(roomId: 'r2'))),
      );
    });

    test('states with different isLoading are not equal', () {
      expect(
        const ChatState(isLoading: true),
        isNot(equals(const ChatState(isLoading: false))),
      );
    });

    test('states with different error are not equal', () {
      expect(
        const ChatState(error: 'err'),
        isNot(equals(const ChatState())),
      );
    });
  });
}
