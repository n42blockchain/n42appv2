import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/live_location_entity.dart';

void main() {
  final _now = DateTime.now();

  LiveLocationEntity _makeEntity({
    DateTime? expiresAt,
    int durationMinutes = 60,
  }) =>
      LiveLocationEntity(
        userId: '@alice:s',
        displayName: 'Alice',
        latitude: 31.23,
        longitude: 121.47,
        updatedAt: _now,
        expiresAt: expiresAt ?? _now.add(const Duration(hours: 1)),
        durationMinutes: durationMinutes,
      );

  // ─────────────────────────────────────────────────
  // Construction
  // ─────────────────────────────────────────────────

  group('LiveLocationEntity construction', () {
    test('creates with required fields and defaults', () {
      final entity = _makeEntity();
      expect(entity.userId, '@alice:s');
      expect(entity.displayName, 'Alice');
      expect(entity.latitude, 31.23);
      expect(entity.longitude, 121.47);
      expect(entity.accuracy, isNull);
      expect(entity.durationMinutes, 60);
    });

    test('creates with accuracy', () {
      final entity = LiveLocationEntity(
        userId: '@alice:s',
        displayName: 'Alice',
        latitude: 0,
        longitude: 0,
        accuracy: 5.0,
        updatedAt: _now,
        expiresAt: _now.add(const Duration(hours: 1)),
        durationMinutes: 30,
      );
      expect(entity.accuracy, 5.0);
    });
  });

  // ─────────────────────────────────────────────────
  // isExpired
  // ─────────────────────────────────────────────────

  group('LiveLocationEntity.isExpired', () {
    test('returns false when expiresAt is in the future', () {
      final entity = _makeEntity(
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(entity.isExpired, isFalse);
    });

    test('returns true when expiresAt is in the past', () {
      final entity = _makeEntity(
        expiresAt: DateTime.now().subtract(const Duration(seconds: 1)),
      );
      expect(entity.isExpired, isTrue);
    });
  });

  // ─────────────────────────────────────────────────
  // remainingSeconds
  // ─────────────────────────────────────────────────

  group('LiveLocationEntity.remainingSeconds', () {
    test('returns positive value when not expired', () {
      final entity = _makeEntity(
        expiresAt: DateTime.now().add(const Duration(minutes: 10)),
      );
      expect(entity.remainingSeconds, greaterThan(0));
    });

    test('returns 0 when expired', () {
      final entity = _makeEntity(
        expiresAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );
      expect(entity.remainingSeconds, 0);
    });
  });

  // ─────────────────────────────────────────────────
  // remainingTimeData
  // ─────────────────────────────────────────────────

  group('LiveLocationEntity.remainingTimeData', () {
    test('returns expired type when past expiresAt', () {
      final entity = _makeEntity(
        expiresAt: DateTime.now().subtract(const Duration(seconds: 1)),
      );
      final data = entity.remainingTimeData;
      expect(data.type, 'expired');
      expect(data.values, isEmpty);
    });

    test('returns seconds type when < 60 s remaining', () {
      final entity = _makeEntity(
        expiresAt: DateTime.now().add(const Duration(seconds: 30)),
      );
      final data = entity.remainingTimeData;
      expect(data.type, 'seconds');
      expect(data.values.length, 1);
      expect(data.values.first, greaterThan(0));
    });

    test('returns minutes type when 1–59 min remaining', () {
      final entity = _makeEntity(
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
      );
      final data = entity.remainingTimeData;
      expect(data.type, 'minutes');
      expect(data.values.length, 1);
    });

    test('returns hoursMinutes type when >= 1 h remaining', () {
      final entity = _makeEntity(
        expiresAt: DateTime.now().add(const Duration(hours: 2, minutes: 30)),
      );
      final data = entity.remainingTimeData;
      expect(data.type, 'hoursMinutes');
      expect(data.values.length, 2);
      expect(data.values[0], 2); // 2 hours
    });
  });

  // ─────────────────────────────────────────────────
  // Equatable props
  // ─────────────────────────────────────────────────

  group('LiveLocationEntity equality', () {
    test('two instances with same fields are equal', () {
      final t = DateTime(2025, 1, 1, 12);
      final e = DateTime(2025, 1, 1, 13);
      final a = LiveLocationEntity(
        userId: '@alice:s',
        displayName: 'Alice',
        latitude: 1.0,
        longitude: 2.0,
        updatedAt: t,
        expiresAt: e,
        durationMinutes: 60,
      );
      final b = LiveLocationEntity(
        userId: '@alice:s',
        displayName: 'Alice',
        latitude: 1.0,
        longitude: 2.0,
        updatedAt: t,
        expiresAt: e,
        durationMinutes: 60,
      );
      expect(a, equals(b));
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith
  // ─────────────────────────────────────────────────

  group('LiveLocationEntity.copyWith', () {
    test('replaces only latitude', () {
      final entity = _makeEntity();
      final copy = entity.copyWith(latitude: 99.0);
      expect(copy.latitude, 99.0);
      expect(copy.longitude, entity.longitude);
      expect(copy.userId, entity.userId);
    });

    test('replaces displayName', () {
      final entity = _makeEntity();
      final copy = entity.copyWith(displayName: 'Bob');
      expect(copy.displayName, 'Bob');
    });
  });
}
