// Tests for ThreadState in thread_state.dart.
// MessageEntity-typed fields (rootMessage, replies, replyTarget) are kept
// null / empty — only scalar and flag behaviour is covered.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/blocs/thread/thread_state.dart';

void main() {
  // ─────────────────────────────────────────────────
  // Constructor defaults
  // ─────────────────────────────────────────────────

  group('ThreadState constructor defaults', () {
    const s = ThreadState();

    test('rootMessage defaults to null', () {
      expect(s.rootMessage, isNull);
    });

    test('replies defaults to empty list', () {
      expect(s.replies, isEmpty);
    });

    test('isLoading defaults to false', () {
      expect(s.isLoading, isFalse);
    });

    test('hasMore defaults to false', () {
      expect(s.hasMore, isFalse);
    });

    test('replyTarget defaults to null', () {
      expect(s.replyTarget, isNull);
    });

    test('participantCount defaults to 0', () {
      expect(s.participantCount, 0);
    });

    test('roomId defaults to null', () {
      expect(s.roomId, isNull);
    });

    test('threadRootEventId defaults to null', () {
      expect(s.threadRootEventId, isNull);
    });

    test('error defaults to null', () {
      expect(s.error, isNull);
    });

    test('isSending defaults to false', () {
      expect(s.isSending, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // ThreadState.initial()
  // ─────────────────────────────────────────────────

  group('ThreadState.initial()', () {
    test('is identical to default constructor state', () {
      expect(ThreadState.initial(), equals(const ThreadState()));
    });

    test('isLoading is false', () {
      expect(ThreadState.initial().isLoading, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // totalCount getter
  // ─────────────────────────────────────────────────

  group('ThreadState.totalCount', () {
    test('0 when rootMessage is null and replies is empty', () {
      expect(const ThreadState().totalCount, 0);
    });

    test('equals replies.length when rootMessage is null', () {
      // replies is empty so totalCount = 0 + 0 = 0
      const s = ThreadState(participantCount: 3);
      expect(s.totalCount, 0);
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — scalar overrides
  // ─────────────────────────────────────────────────

  group('ThreadState.copyWith scalar', () {
    const base = ThreadState(
      isLoading: true,
      hasMore: true,
      participantCount: 5,
      roomId: '!room:server',
      threadRootEventId: '\$event123',
      error: 'net error',
      isSending: false,
    );

    test('no overrides preserves all fields', () {
      final copy = base.copyWith();
      expect(copy.isLoading, isTrue);
      expect(copy.participantCount, 5);
      expect(copy.roomId, '!room:server');
      expect(copy.error, 'net error');
    });

    test('overrides isLoading', () {
      final copy = base.copyWith(isLoading: false);
      expect(copy.isLoading, isFalse);
    });

    test('overrides hasMore', () {
      final copy = base.copyWith(hasMore: false);
      expect(copy.hasMore, isFalse);
    });

    test('overrides participantCount', () {
      final copy = base.copyWith(participantCount: 10);
      expect(copy.participantCount, 10);
    });

    test('overrides roomId', () {
      final copy = base.copyWith(roomId: '!other:server');
      expect(copy.roomId, '!other:server');
    });

    test('overrides threadRootEventId', () {
      final copy = base.copyWith(threadRootEventId: '\$evt456');
      expect(copy.threadRootEventId, '\$evt456');
    });

    test('overrides isSending', () {
      final copy = base.copyWith(isSending: true);
      expect(copy.isSending, isTrue);
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — clearReplyTarget flag
  // ─────────────────────────────────────────────────

  group('ThreadState.copyWith clearReplyTarget', () {
    test('clearReplyTarget=true sets replyTarget to null (starts null)', () {
      const s = ThreadState();
      final copy = s.copyWith(clearReplyTarget: true);
      expect(copy.replyTarget, isNull);
    });

    test('clearReplyTarget=false preserves null replyTarget', () {
      const s = ThreadState();
      final copy = s.copyWith(clearReplyTarget: false);
      expect(copy.replyTarget, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — clearError flag
  // ─────────────────────────────────────────────────

  group('ThreadState.copyWith clearError', () {
    const withError = ThreadState(error: 'load replies failed');

    test('clearError=true sets error to null', () {
      final copy = withError.copyWith(clearError: true);
      expect(copy.error, isNull);
    });

    test('clearError=false preserves error', () {
      final copy = withError.copyWith(clearError: false);
      expect(copy.error, 'load replies failed');
    });

    test('clearError=true overrides provided error', () {
      final copy = withError.copyWith(clearError: true, error: 'ignored');
      expect(copy.error, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // Equatable equality
  // ─────────────────────────────────────────────────

  group('ThreadState Equatable equality', () {
    test('two default instances are equal', () {
      expect(const ThreadState(), equals(const ThreadState()));
    });

    test('different isLoading → not equal', () {
      expect(
        const ThreadState(isLoading: true),
        isNot(equals(const ThreadState())),
      );
    });

    test('different participantCount → not equal', () {
      expect(
        const ThreadState(participantCount: 3),
        isNot(equals(const ThreadState())),
      );
    });

    test('different roomId → not equal', () {
      expect(
        const ThreadState(roomId: '!r:s'),
        isNot(equals(const ThreadState())),
      );
    });

    test('different error → not equal', () {
      expect(
        const ThreadState(error: 'err'),
        isNot(equals(const ThreadState())),
      );
    });

    test('same fields → equal', () {
      expect(
        const ThreadState(participantCount: 2, roomId: '!r:s'),
        equals(const ThreadState(participantCount: 2, roomId: '!r:s')),
      );
    });
  });
}
