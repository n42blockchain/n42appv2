// Tests for pure-Dart state classes in message_action_state.dart:
//   MessageActionInitial, MessageActionLoading, MessageActionSuccess,
//   MessageActionFailure, ForwardResult, MessageSavedStatus.
// ReactionsLoaded (needs MessageReactionEntity) and
// SavedMessagesLoaded (needs MessageEntity) are skipped.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/blocs/message_action/message_action_state.dart';

void main() {
  // ─────────────────────────────────────────────────
  // MessageActionInitial
  // ─────────────────────────────────────────────────

  group('MessageActionInitial', () {
    test('can be constructed', () {
      const state = MessageActionInitial();
      expect(state, isA<MessageActionState>());
    });

    test('props is empty', () {
      expect(const MessageActionInitial().props, isEmpty);
    });

    test('two instances are equal', () {
      expect(const MessageActionInitial(), equals(const MessageActionInitial()));
    });
  });

  // ─────────────────────────────────────────────────
  // MessageActionLoading
  // ─────────────────────────────────────────────────

  group('MessageActionLoading', () {
    test('stores action', () {
      const s = MessageActionLoading('addReaction');
      expect(s.action, 'addReaction');
    });

    test('props contains action', () {
      const s = MessageActionLoading('editMessage');
      expect(s.props, contains('editMessage'));
    });

    test('two instances with same action are equal', () {
      expect(
        const MessageActionLoading('x'),
        equals(const MessageActionLoading('x')),
      );
    });

    test('two instances with different actions are not equal', () {
      expect(
        const MessageActionLoading('a'),
        isNot(equals(const MessageActionLoading('b'))),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // MessageActionSuccess
  // ─────────────────────────────────────────────────

  group('MessageActionSuccess', () {
    test('stores action', () {
      const s = MessageActionSuccess('removeReaction');
      expect(s.action, 'removeReaction');
    });

    test('message defaults to null', () {
      const s = MessageActionSuccess('editMessage');
      expect(s.message, isNull);
    });

    test('stores optional message', () {
      const s = MessageActionSuccess('save', message: 'Saved!');
      expect(s.message, 'Saved!');
    });

    test('two instances with same fields are equal', () {
      expect(
        const MessageActionSuccess('a', message: 'm'),
        equals(const MessageActionSuccess('a', message: 'm')),
      );
    });

    test('differs when message differs', () {
      expect(
        const MessageActionSuccess('a'),
        isNot(equals(const MessageActionSuccess('a', message: 'm'))),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // MessageActionFailure
  // ─────────────────────────────────────────────────

  group('MessageActionFailure', () {
    test('stores action and error', () {
      const s = MessageActionFailure('addReaction', 'Network error');
      expect(s.action, 'addReaction');
      expect(s.error, 'Network error');
    });

    test('props contains action and error', () {
      const s = MessageActionFailure('x', 'err');
      expect(s.props, containsAll(['x', 'err']));
    });

    test('two instances with same fields are equal', () {
      expect(
        const MessageActionFailure('a', 'err'),
        equals(const MessageActionFailure('a', 'err')),
      );
    });

    test('differs when error differs', () {
      expect(
        const MessageActionFailure('a', 'err1'),
        isNot(equals(const MessageActionFailure('a', 'err2'))),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // ForwardResult — successCount / failureCount / allSuccess
  // ─────────────────────────────────────────────────

  group('ForwardResult', () {
    test('stores results map', () {
      const r = ForwardResult({'room1': true, 'room2': false});
      expect(r.results, {'room1': true, 'room2': false});
    });

    test('successCount counts true values', () {
      const r = ForwardResult({'r1': true, 'r2': true, 'r3': false});
      expect(r.successCount, 2);
    });

    test('failureCount counts false values', () {
      const r = ForwardResult({'r1': true, 'r2': false, 'r3': false});
      expect(r.failureCount, 2);
    });

    test('empty results → successCount=0 failureCount=0', () {
      const r = ForwardResult({});
      expect(r.successCount, 0);
      expect(r.failureCount, 0);
    });

    test('all true → allSuccess is true', () {
      const r = ForwardResult({'r1': true, 'r2': true});
      expect(r.allSuccess, isTrue);
    });

    test('any false → allSuccess is false', () {
      const r = ForwardResult({'r1': true, 'r2': false});
      expect(r.allSuccess, isFalse);
    });

    test('all false → allSuccess is false', () {
      const r = ForwardResult({'r1': false, 'r2': false});
      expect(r.allSuccess, isFalse);
    });

    test('empty results → allSuccess is true (no failures)', () {
      const r = ForwardResult({});
      expect(r.allSuccess, isTrue);
    });

    test('single success → successCount=1 allSuccess=true', () {
      const r = ForwardResult({'r1': true});
      expect(r.successCount, 1);
      expect(r.allSuccess, isTrue);
    });

    test('single failure → failureCount=1 allSuccess=false', () {
      const r = ForwardResult({'r1': false});
      expect(r.failureCount, 1);
      expect(r.allSuccess, isFalse);
    });

    test('successCount + failureCount = total rooms', () {
      const r = ForwardResult({'r1': true, 'r2': false, 'r3': true, 'r4': false});
      expect(r.successCount + r.failureCount, 4);
    });

    test('two instances with same results are equal', () {
      expect(
        const ForwardResult({'r1': true}),
        equals(const ForwardResult({'r1': true})),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // MessageSavedStatus
  // ─────────────────────────────────────────────────

  group('MessageSavedStatus', () {
    test('stores messageId and isSaved', () {
      const s = MessageSavedStatus('msg123', true);
      expect(s.messageId, 'msg123');
      expect(s.isSaved, isTrue);
    });

    test('isSaved can be false', () {
      const s = MessageSavedStatus('msg456', false);
      expect(s.isSaved, isFalse);
    });

    test('props contains messageId and isSaved', () {
      const s = MessageSavedStatus('id1', true);
      expect(s.props, containsAll(['id1', true]));
    });

    test('two instances with same fields are equal', () {
      expect(
        const MessageSavedStatus('x', true),
        equals(const MessageSavedStatus('x', true)),
      );
    });

    test('differs when isSaved differs', () {
      expect(
        const MessageSavedStatus('x', true),
        isNot(equals(const MessageSavedStatus('x', false))),
      );
    });
  });
}
