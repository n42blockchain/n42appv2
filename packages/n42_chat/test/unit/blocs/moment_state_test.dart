// Tests for MomentState — pure data class in moment_state.dart.
// MomentEntity-dependent getters (myMoments, friendMoments) are not covered
// here as they require domain entity construction.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/blocs/moment/moment_state.dart';

void main() {
  // ─────────────────────────────────────────────────
  // Constructor defaults
  // ─────────────────────────────────────────────────

  group('MomentState constructor defaults', () {
    const s = MomentState();

    test('moments defaults to empty list', () {
      expect(s.moments, isEmpty);
    });

    test('isLoading defaults to false', () {
      expect(s.isLoading, isFalse);
    });

    test('isLoadingMore defaults to false', () {
      expect(s.isLoadingMore, isFalse);
    });

    test('hasMore defaults to true', () {
      expect(s.hasMore, isTrue);
    });

    test('isPosting defaults to false', () {
      expect(s.isPosting, isFalse);
    });

    test('postingProgress defaults to 0.0', () {
      expect(s.postingProgress, 0.0);
    });

    test('errorMessage defaults to null', () {
      expect(s.errorMessage, isNull);
    });

    test('unreadCount defaults to 0', () {
      expect(s.unreadCount, 0);
    });

    test('lastMomentId defaults to null', () {
      expect(s.lastMomentId, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // Named factories
  // ─────────────────────────────────────────────────

  group('MomentState.initial()', () {
    test('is identical to default constructor state', () {
      expect(MomentState.initial(), equals(const MomentState()));
    });

    test('isLoading is false', () {
      expect(MomentState.initial().isLoading, isFalse);
    });
  });

  group('MomentState.loading()', () {
    test('isLoading is true', () {
      expect(MomentState.loading().isLoading, isTrue);
    });

    test('moments is empty', () {
      expect(MomentState.loading().moments, isEmpty);
    });
  });

  // ─────────────────────────────────────────────────
  // Computed getters
  // ─────────────────────────────────────────────────

  group('MomentState.isEmpty', () {
    test('true when moments is empty', () {
      expect(const MomentState().isEmpty, isTrue);
    });
  });

  group('MomentState.hasError', () {
    test('false when errorMessage is null', () {
      expect(const MomentState().hasError, isFalse);
    });

    test('true when errorMessage is set', () {
      const s = MomentState(errorMessage: 'something went wrong');
      expect(s.hasError, isTrue);
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — scalar overrides
  // ─────────────────────────────────────────────────

  group('MomentState.copyWith', () {
    const base = MomentState(
      isLoading: true,
      unreadCount: 3,
      errorMessage: 'net error',
    );

    test('no overrides preserves all fields', () {
      final copy = base.copyWith();
      expect(copy.isLoading, isTrue);
      expect(copy.unreadCount, 3);
    });

    test('overrides isLoading', () {
      final copy = base.copyWith(isLoading: false);
      expect(copy.isLoading, isFalse);
      expect(copy.unreadCount, 3); // unchanged
    });

    test('overrides isLoadingMore', () {
      final copy = base.copyWith(isLoadingMore: true);
      expect(copy.isLoadingMore, isTrue);
    });

    test('overrides hasMore', () {
      final copy = const MomentState(hasMore: true).copyWith(hasMore: false);
      expect(copy.hasMore, isFalse);
    });

    test('overrides isPosting', () {
      final copy = base.copyWith(isPosting: true);
      expect(copy.isPosting, isTrue);
    });

    test('overrides postingProgress', () {
      final copy = base.copyWith(postingProgress: 0.5);
      expect(copy.postingProgress, closeTo(0.5, 1e-10));
    });

    test('overrides unreadCount', () {
      final copy = base.copyWith(unreadCount: 10);
      expect(copy.unreadCount, 10);
    });

    test('overrides lastMomentId', () {
      final copy = base.copyWith(lastMomentId: 'moment999');
      expect(copy.lastMomentId, 'moment999');
    });

    test('overrides errorMessage', () {
      final copy = base.copyWith(errorMessage: 'new error');
      expect(copy.errorMessage, 'new error');
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — clearError flag
  // ─────────────────────────────────────────────────

  group('MomentState.copyWith clearError', () {
    const withError = MomentState(errorMessage: 'some error');

    test('clearError=true sets errorMessage to null', () {
      final copy = withError.copyWith(clearError: true);
      expect(copy.errorMessage, isNull);
    });

    test('clearError=false without new value preserves errorMessage', () {
      final copy = withError.copyWith(clearError: false);
      expect(copy.errorMessage, 'some error');
    });

    test('clearError=true overrides any provided errorMessage', () {
      final copy = withError.copyWith(clearError: true, errorMessage: 'ignored');
      expect(copy.errorMessage, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // Equatable equality
  // ─────────────────────────────────────────────────

  group('MomentState Equatable equality', () {
    test('two default instances are equal', () {
      expect(const MomentState(), equals(const MomentState()));
    });

    test('states with different isLoading are not equal', () {
      expect(
        const MomentState(isLoading: true),
        isNot(equals(const MomentState())),
      );
    });

    test('states with different unreadCount are not equal', () {
      expect(
        const MomentState(unreadCount: 5),
        isNot(equals(const MomentState())),
      );
    });

    test('states with different postingProgress are not equal', () {
      expect(
        const MomentState(postingProgress: 0.5),
        isNot(equals(const MomentState())),
      );
    });

    test('states with different errorMessage are not equal', () {
      expect(
        const MomentState(errorMessage: 'err'),
        isNot(equals(const MomentState())),
      );
    });
  });
}
