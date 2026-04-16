// Tests for LiveLocationEvent subclasses in live_location_event.dart.
// LiveLocationEntity requires DateTime (non-const): tested via runtime reference.
// All other events are pure const.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/live_location_entity.dart';
import 'package:n42_chat/src/presentation/blocs/live_location/live_location_event.dart';

void main() {
  group('ObserveLiveLocationRoom', () {
    test('stores roomId', () {
      const e = ObserveLiveLocationRoom(roomId: '!room:server');
      expect(e.roomId, '!room:server');
    });

    test('same roomId → equal', () {
      expect(
        const ObserveLiveLocationRoom(roomId: '!r:s'),
        equals(const ObserveLiveLocationRoom(roomId: '!r:s')),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // StartLiveLocation
  // ─────────────────────────────────────────────────

  group('StartLiveLocation', () {
    test('stores roomId and durationMinutes', () {
      const e = StartLiveLocation(
        roomId: '!room:server',
        durationMinutes: 60,
      );
      expect(e.roomId, '!room:server');
      expect(e.durationMinutes, 60);
    });

    test('same fields → equal', () {
      expect(
        const StartLiveLocation(roomId: '!r:s', durationMinutes: 30),
        equals(const StartLiveLocation(roomId: '!r:s', durationMinutes: 30)),
      );
    });

    test('different durationMinutes → not equal', () {
      expect(
        const StartLiveLocation(roomId: '!r:s', durationMinutes: 30),
        isNot(equals(const StartLiveLocation(roomId: '!r:s', durationMinutes: 60))),
      );
    });

    test('different roomId → not equal', () {
      expect(
        const StartLiveLocation(roomId: '!a:s', durationMinutes: 30),
        isNot(equals(const StartLiveLocation(roomId: '!b:s', durationMinutes: 30))),
      );
    });

    test('is a LiveLocationEvent', () {
      expect(
        const StartLiveLocation(roomId: '!r:s', durationMinutes: 15),
        isA<LiveLocationEvent>(),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // StopLiveLocation
  // ─────────────────────────────────────────────────

  group('StopLiveLocation', () {
    test('stores roomId', () {
      const e = StopLiveLocation(roomId: '!room:server');
      expect(e.roomId, '!room:server');
    });

    test('same roomId → equal', () {
      expect(
        const StopLiveLocation(roomId: '!r:s'),
        equals(const StopLiveLocation(roomId: '!r:s')),
      );
    });

    test('different roomId → not equal', () {
      expect(
        const StopLiveLocation(roomId: '!a:s'),
        isNot(equals(const StopLiveLocation(roomId: '!b:s'))),
      );
    });

    test('is a LiveLocationEvent', () {
      expect(const StopLiveLocation(roomId: '!r:s'), isA<LiveLocationEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // UpdateMyLocation
  // ─────────────────────────────────────────────────

  group('UpdateMyLocation', () {
    test('stores latitude and longitude', () {
      const e = UpdateMyLocation(latitude: 37.7749, longitude: -122.4194);
      expect(e.latitude, 37.7749);
      expect(e.longitude, -122.4194);
    });

    test('accuracy defaults to null', () {
      expect(const UpdateMyLocation(latitude: 0.0, longitude: 0.0).accuracy, isNull);
    });

    test('stores accuracy when provided', () {
      const e = UpdateMyLocation(
        latitude: 37.7749, longitude: -122.4194, accuracy: 5.0);
      expect(e.accuracy, 5.0);
    });

    test('same fields → equal', () {
      expect(
        const UpdateMyLocation(latitude: 1.0, longitude: 2.0, accuracy: 3.0),
        equals(const UpdateMyLocation(latitude: 1.0, longitude: 2.0, accuracy: 3.0)),
      );
    });

    test('different latitude → not equal', () {
      expect(
        const UpdateMyLocation(latitude: 1.0, longitude: 0.0),
        isNot(equals(const UpdateMyLocation(latitude: 2.0, longitude: 0.0))),
      );
    });

    test('is a LiveLocationEvent', () {
      expect(
        const UpdateMyLocation(latitude: 0.0, longitude: 0.0),
        isA<LiveLocationEvent>(),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // LiveLocationUpdated (requires LiveLocationEntity with DateTime)
  // ─────────────────────────────────────────────────

  group('LiveLocationUpdated', () {
    test('stores location fields', () {
      final now = DateTime.utc(2024, 1, 1, 12);
      final expires = DateTime.utc(2024, 1, 1, 13);
      final loc = LiveLocationEntity(
        userId: '@alice:s',
        displayName: 'Alice',
        latitude: 37.7749,
        longitude: -122.4194,
        updatedAt: now,
        expiresAt: expires,
        durationMinutes: 60,
      );
      final e = LiveLocationUpdated(loc);
      expect(e.location.userId, '@alice:s');
      expect(e.location.displayName, 'Alice');
      expect(e.location.latitude, 37.7749);
      expect(e.location.longitude, -122.4194);
      expect(e.location.durationMinutes, 60);
    });

    test('is a LiveLocationEvent', () {
      final loc = LiveLocationEntity(
        userId: '@u:s',
        displayName: 'User',
        latitude: 0.0,
        longitude: 0.0,
        updatedAt: DateTime.utc(2024, 1, 1),
        expiresAt: DateTime.utc(2024, 1, 1, 1),
        durationMinutes: 60,
      );
      expect(LiveLocationUpdated(loc), isA<LiveLocationEvent>());
    });
  });

  group('LiveLocationSnapshotReceived', () {
    test('stores roomId and locations', () {
      final loc = LiveLocationEntity(
        userId: '@u:s',
        displayName: 'User',
        latitude: 1,
        longitude: 2,
        updatedAt: DateTime.utc(2024, 1, 1),
        expiresAt: DateTime.utc(2024, 1, 1, 1),
        durationMinutes: 60,
      );
      final e = LiveLocationSnapshotReceived(
        roomId: '!room:server',
        locations: [loc],
      );
      expect(e.roomId, '!room:server');
      expect(e.locations, [loc]);
    });
  });

  // ─────────────────────────────────────────────────
  // LiveLocationExpired
  // ─────────────────────────────────────────────────

  group('LiveLocationExpired', () {
    test('stores userId', () {
      const e = LiveLocationExpired('@alice:server');
      expect(e.userId, '@alice:server');
    });

    test('same userId → equal', () {
      expect(
        const LiveLocationExpired('@u:s'),
        equals(const LiveLocationExpired('@u:s')),
      );
    });

    test('different userId → not equal', () {
      expect(
        const LiveLocationExpired('@a:s'),
        isNot(equals(const LiveLocationExpired('@b:s'))),
      );
    });

    test('is a LiveLocationEvent', () {
      expect(const LiveLocationExpired('@u:s'), isA<LiveLocationEvent>());
    });
  });
}
