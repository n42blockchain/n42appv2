// Tests for StoryState in story_state.dart.
// UserStories / StoryEntity require domain construction — lists kept empty.
// Getters that depend on non-empty lists (unviewedStoriesCount sum) are
// tested only for the zero case.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/blocs/story/story_state.dart';

void main() {
  // ─────────────────────────────────────────────────
  // Constructor defaults
  // ─────────────────────────────────────────────────

  group('StoryState constructor defaults', () {
    const s = StoryState();

    test('userStories defaults to empty list', () {
      expect(s.userStories, isEmpty);
    });

    test('myStories defaults to empty list', () {
      expect(s.myStories, isEmpty);
    });

    test('isLoading defaults to false', () {
      expect(s.isLoading, isFalse);
    });

    test('isPosting defaults to false', () {
      expect(s.isPosting, isFalse);
    });

    test('error defaults to null', () {
      expect(s.error, isNull);
    });

    test('currentUserId defaults to null', () {
      expect(s.currentUserId, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // StoryState.initial()
  // ─────────────────────────────────────────────────

  group('StoryState.initial()', () {
    test('is identical to default constructor state', () {
      expect(StoryState.initial(), equals(const StoryState()));
    });

    test('isLoading is false', () {
      expect(StoryState.initial().isLoading, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // Computed getters — zero cases
  // ─────────────────────────────────────────────────

  group('StoryState.hasStories', () {
    test('false when userStories is empty', () {
      expect(const StoryState().hasStories, isFalse);
    });
  });

  group('StoryState.myStoriesCount', () {
    test('0 when myStories is empty', () {
      expect(const StoryState().myStoriesCount, 0);
    });
  });

  group('StoryState.unviewedStoriesCount', () {
    test('0 when userStories is empty', () {
      expect(const StoryState().unviewedStoriesCount, 0);
    });
  });

  group('StoryState.hasError', () {
    test('false when error is null', () {
      expect(const StoryState().hasError, isFalse);
    });

    test('true when error is set', () {
      const s = StoryState(error: 'load failed');
      expect(s.hasError, isTrue);
    });
  });

  group('StoryState.isEmpty', () {
    test('true when both lists are empty', () {
      expect(const StoryState().isEmpty, isTrue);
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — scalar overrides
  // ─────────────────────────────────────────────────

  group('StoryState.copyWith scalar', () {
    const base = StoryState(
      isLoading: true,
      isPosting: false,
      error: 'net error',
      currentUserId: 'user123',
    );

    test('no overrides preserves all fields', () {
      final copy = base.copyWith();
      expect(copy.isLoading, isTrue);
      expect(copy.currentUserId, 'user123');
    });

    test('overrides isLoading', () {
      final copy = base.copyWith(isLoading: false);
      expect(copy.isLoading, isFalse);
    });

    test('overrides isPosting', () {
      final copy = base.copyWith(isPosting: true);
      expect(copy.isPosting, isTrue);
    });

    test('overrides currentUserId', () {
      final copy = base.copyWith(currentUserId: 'user456');
      expect(copy.currentUserId, 'user456');
    });

    test('overrides error', () {
      final copy = base.copyWith(error: 'new error');
      expect(copy.error, 'new error');
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — clearError flag
  // ─────────────────────────────────────────────────

  group('StoryState.copyWith clearError', () {
    const withError = StoryState(error: 'story load failed');

    test('clearError=true sets error to null', () {
      final copy = withError.copyWith(clearError: true);
      expect(copy.error, isNull);
    });

    test('clearError=false preserves error when no new value given', () {
      final copy = withError.copyWith(clearError: false);
      expect(copy.error, 'story load failed');
    });

    test('clearError=true overrides provided error', () {
      final copy = withError.copyWith(clearError: true, error: 'ignored');
      expect(copy.error, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // Equatable equality
  // ─────────────────────────────────────────────────

  group('StoryState Equatable equality', () {
    test('two default instances are equal', () {
      expect(const StoryState(), equals(const StoryState()));
    });

    test('different isLoading → not equal', () {
      expect(
        const StoryState(isLoading: true),
        isNot(equals(const StoryState())),
      );
    });

    test('different error → not equal', () {
      expect(
        const StoryState(error: 'err'),
        isNot(equals(const StoryState())),
      );
    });

    test('different currentUserId → not equal', () {
      expect(
        const StoryState(currentUserId: 'u1'),
        isNot(equals(const StoryState())),
      );
    });

    test('same fields → equal', () {
      expect(
        const StoryState(isPosting: true, currentUserId: 'u1'),
        equals(const StoryState(isPosting: true, currentUserId: 'u1')),
      );
    });
  });
}
