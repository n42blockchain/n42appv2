// Tests for LiveLocationState in live_location_state.dart.
// LiveLocationEntity-typed fields (activeSharings map) are kept empty.
// The sentinel pattern for currentRoomId / myLatitude / myLongitude
// allows explicit null to clear values — unlike the plain error field
// which always resets to null when copyWith() is called without it.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/blocs/live_location/live_location_state.dart';

void main() {
  // ─────────────────────────────────────────────────
  // Constructor defaults
  // ─────────────────────────────────────────────────

  group('LiveLocationState constructor defaults', () {
    const s = LiveLocationState();

    test('activeSharings defaults to empty map', () {
      expect(s.activeSharings, isEmpty);
    });

    test('isSharing defaults to false', () {
      expect(s.isSharing, isFalse);
    });

    test('currentRoomId defaults to null', () {
      expect(s.currentRoomId, isNull);
    });

    test('myLatitude defaults to null', () {
      expect(s.myLatitude, isNull);
    });

    test('myLongitude defaults to null', () {
      expect(s.myLongitude, isNull);
    });

    test('error defaults to null', () {
      expect(s.error, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — scalar overrides (fields that use ??)
  // ─────────────────────────────────────────────────

  group('LiveLocationState.copyWith scalar', () {
    const base = LiveLocationState(
      isSharing: true,
      currentRoomId: '!room:server',
      myLatitude: 37.5,
      myLongitude: -122.1,
      error: 'gps error',
    );

    test('no overrides preserves isSharing via ??', () {
      final copy = base.copyWith();
      expect(copy.isSharing, isTrue);
    });

    test('overrides isSharing', () {
      final copy = base.copyWith(isSharing: false);
      expect(copy.isSharing, isFalse);
    });

    test('no override preserves currentRoomId via sentinel', () {
      final copy = base.copyWith();
      expect(copy.currentRoomId, '!room:server');
    });

    test('no override preserves myLatitude via sentinel', () {
      final copy = base.copyWith();
      expect(copy.myLatitude, closeTo(37.5, 1e-10));
    });

    test('no override preserves myLongitude via sentinel', () {
      final copy = base.copyWith();
      expect(copy.myLongitude, closeTo(-122.1, 1e-10));
    });

    test('overrides myLatitude', () {
      final copy = base.copyWith(myLatitude: 40.0);
      expect(copy.myLatitude, closeTo(40.0, 1e-10));
    });

    test('overrides myLongitude', () {
      final copy = base.copyWith(myLongitude: 0.0);
      expect(copy.myLongitude, closeTo(0.0, 1e-10));
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — sentinel allows explicit null for nullable fields
  // ─────────────────────────────────────────────────

  group('LiveLocationState.copyWith sentinel clears nullable fields', () {
    const withValues = LiveLocationState(
      currentRoomId: '!room:server',
      myLatitude: 37.5,
      myLongitude: -122.1,
    );

    test('passing null for currentRoomId clears it', () {
      final copy = withValues.copyWith(currentRoomId: null);
      expect(copy.currentRoomId, isNull);
    });

    test('passing null for myLatitude clears it', () {
      final copy = withValues.copyWith(myLatitude: null);
      expect(copy.myLatitude, isNull);
    });

    test('passing null for myLongitude clears it', () {
      final copy = withValues.copyWith(myLongitude: null);
      expect(copy.myLongitude, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — error always resets to null when not provided
  // ─────────────────────────────────────────────────

  group('LiveLocationState.copyWith error reset behaviour', () {
    const withError = LiveLocationState(error: 'location unavailable');

    test('copyWith() without error resets error to null', () {
      final copy = withError.copyWith();
      expect(copy.error, isNull);
    });

    test('copyWith with error sets new value', () {
      final copy = withError.copyWith(error: 'timeout');
      expect(copy.error, 'timeout');
    });
  });

  // ─────────────────────────────────────────────────
  // Equatable equality
  // ─────────────────────────────────────────────────

  group('LiveLocationState Equatable equality', () {
    test('two default instances are equal', () {
      expect(const LiveLocationState(), equals(const LiveLocationState()));
    });

    test('different isSharing → not equal', () {
      expect(
        const LiveLocationState(isSharing: true),
        isNot(equals(const LiveLocationState())),
      );
    });

    test('different currentRoomId → not equal', () {
      expect(
        const LiveLocationState(currentRoomId: '!r:s'),
        isNot(equals(const LiveLocationState())),
      );
    });

    test('different error → not equal', () {
      expect(
        const LiveLocationState(error: 'err'),
        isNot(equals(const LiveLocationState())),
      );
    });

    test('same fields → equal', () {
      expect(
        const LiveLocationState(isSharing: true, currentRoomId: '!r:s'),
        equals(const LiveLocationState(isSharing: true, currentRoomId: '!r:s')),
      );
    });
  });
}
