import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/red_packet_entity.dart';

void main() {
  // ─── Helpers ───────────────────────────────────────────────────────────────

  RedPacketClaim _claim(String userId, double amount, {int daysAgo = 0}) {
    return RedPacketClaim(
      userId: userId,
      userName: 'User $userId',
      amount: amount,
      claimedAt: DateTime.now().subtract(Duration(days: daysAgo)),
    );
  }

  RedPacketEntity _packet({
    List<RedPacketClaim> claims = const [],
    int totalCount = 5,
    double totalAmount = 100.0,
    DateTime? expiresAt,
    RedPacketType type = RedPacketType.lucky,
  }) {
    final now = DateTime.now();
    return RedPacketEntity(
      id: 'rp_001',
      roomId: '!room:server.com',
      senderId: '@alice:server.com',
      senderName: 'Alice',
      greeting: 'Happy New Year!',
      type: type,
      totalAmount: totalAmount,
      totalCount: totalCount,
      token: 'USDT',
      claims: claims,
      createdAt: now.subtract(const Duration(hours: 1)),
      expiresAt: expiresAt ?? now.add(const Duration(hours: 23)),
    );
  }

  // ─── RedPacketEntity ───────────────────────────────────────────────────────

  group('RedPacketEntity', () {
    group('construction', () {
      test('stores all required fields correctly', () {
        final packet = _packet(totalAmount: 50.0, totalCount: 3);
        expect(packet.id, 'rp_001');
        expect(packet.token, 'USDT');
        expect(packet.totalAmount, 50.0);
        expect(packet.totalCount, 3);
        expect(packet.senderName, 'Alice');
        expect(packet.greeting, 'Happy New Year!');
        expect(packet.coverColor, '#E64340'); // default
      });

      test('defaults coverColor to #E64340', () {
        final packet = _packet();
        expect(packet.coverColor, '#E64340');
      });
    });

    group('claimedAmount', () {
      test('returns 0 for empty claims', () {
        expect(_packet().claimedAmount, 0.0);
      });

      test('sums amounts across all claims', () {
        final packet = _packet(claims: [
          _claim('u1', 30.0),
          _claim('u2', 25.5),
          _claim('u3', 10.0),
        ]);
        expect(packet.claimedAmount, 65.5);
      });
    });

    group('remainingAmount', () {
      test('equals totalAmount when no claims', () {
        final packet = _packet(totalAmount: 100.0);
        expect(packet.remainingAmount, 100.0);
      });

      test('decreases as claims are added', () {
        final packet = _packet(
          totalAmount: 100.0,
          claims: [_claim('u1', 40.0), _claim('u2', 35.0)],
        );
        expect(packet.remainingAmount, closeTo(25.0, 0.001));
      });
    });

    group('claimedCount & remainingCount', () {
      test('claimedCount matches claims.length', () {
        final packet = _packet(
          totalCount: 5,
          claims: [_claim('u1', 10.0), _claim('u2', 20.0)],
        );
        expect(packet.claimedCount, 2);
        expect(packet.remainingCount, 3);
      });

      test('remainingCount is 0 when fully claimed', () {
        final packet = _packet(
          totalCount: 2,
          claims: [_claim('u1', 50.0), _claim('u2', 50.0)],
        );
        expect(packet.remainingCount, 0);
      });
    });

    group('isExpired', () {
      test('returns false when expiresAt is in the future', () {
        final packet = _packet(
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );
        expect(packet.isExpired, isFalse);
      });

      test('returns true when expiresAt is in the past', () {
        final packet = _packet(
          expiresAt: DateTime.now().subtract(const Duration(seconds: 1)),
        );
        expect(packet.isExpired, isTrue);
      });
    });

    group('isCompleted', () {
      test('returns false when slots remain', () {
        final packet = _packet(
          totalCount: 5,
          claims: [_claim('u1', 20.0)],
        );
        expect(packet.isCompleted, isFalse);
      });

      test('returns true when all slots are claimed', () {
        final packet = _packet(
          totalCount: 2,
          claims: [_claim('u1', 50.0), _claim('u2', 50.0)],
        );
        expect(packet.isCompleted, isTrue);
      });
    });

    group('lifecycle', () {
      test('is active when not expired and not completed', () {
        final packet = _packet(
          totalCount: 5,
          claims: [_claim('u1', 10.0)],
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );
        expect(packet.lifecycle, RedPacketLifecycle.active);
      });

      test('is completed when all packets claimed', () {
        final packet = _packet(
          totalCount: 2,
          claims: [_claim('u1', 50.0), _claim('u2', 50.0)],
        );
        expect(packet.lifecycle, RedPacketLifecycle.completed);
      });

      test('is expired when past expiry with remaining slots', () {
        final packet = _packet(
          totalCount: 5,
          claims: [_claim('u1', 10.0)],
          expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        );
        expect(packet.lifecycle, RedPacketLifecycle.expired);
      });

      test('completed takes priority over expired', () {
        // All claimed AND past expiry → completed wins
        final packet = _packet(
          totalCount: 2,
          claims: [_claim('u1', 50.0), _claim('u2', 50.0)],
          expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        );
        expect(packet.lifecycle, RedPacketLifecycle.completed);
      });
    });

    group('bestLuckClaim', () {
      test('returns null when no claims', () {
        expect(_packet().bestLuckClaim, isNull);
      });

      test('returns null when only one claim', () {
        final packet = _packet(claims: [_claim('u1', 50.0)]);
        expect(packet.bestLuckClaim, isNull);
      });

      test('returns claim with highest amount', () {
        final packet = _packet(claims: [
          _claim('u1', 10.0),
          _claim('u2', 45.0), // highest
          _claim('u3', 25.0),
        ]);
        expect(packet.bestLuckClaim?.userId, 'u2');
        expect(packet.bestLuckClaim?.amount, 45.0);
      });

      test('handles tied amounts — later claim wins via reduce (not strictly >)', () {
        final packet = _packet(claims: [
          _claim('u1', 50.0),
          _claim('u2', 50.0), // tie — reduce(a,b) returns b when a.amount == b.amount
        ]);
        // When amounts are equal, a > b is false, so b (u2) is returned
        expect(packet.bestLuckClaim?.userId, 'u2');
      });
    });

    group('isClaimBestLuck', () {
      test('returns false when no best luck (< 2 claims)', () {
        final packet = _packet(claims: [_claim('u1', 50.0)]);
        expect(packet.isClaimBestLuck('u1'), isFalse);
      });

      test('returns true for the best luck user', () {
        final packet = _packet(claims: [
          _claim('u1', 10.0),
          _claim('u2', 90.0), // best luck
        ]);
        expect(packet.isClaimBestLuck('u2'), isTrue);
        expect(packet.isClaimBestLuck('u1'), isFalse);
      });

      test('returns false for unknown user', () {
        final packet = _packet(claims: [
          _claim('u1', 30.0),
          _claim('u2', 70.0),
        ]);
        expect(packet.isClaimBestLuck('unknown'), isFalse);
      });
    });

    group('JSON serialization', () {
      test('round-trips via fromJson/toJson', () {
        final original = _packet(
          claims: [_claim('u1', 30.5), _claim('u2', 19.5)],
        );
        final json = original.toJson();
        final restored = RedPacketEntity.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.roomId, original.roomId);
        expect(restored.senderId, original.senderId);
        expect(restored.senderName, original.senderName);
        expect(restored.greeting, original.greeting);
        expect(restored.type, original.type);
        expect(restored.totalAmount, original.totalAmount);
        expect(restored.totalCount, original.totalCount);
        expect(restored.token, original.token);
        expect(restored.coverColor, original.coverColor);
        expect(restored.claims.length, 2);
      });

      test('fromJson defaults type to normal for unknown type string', () {
        final json = _packet().toJson();
        json['type'] = 'unknown_type';
        final restored = RedPacketEntity.fromJson(json);
        expect(restored.type, RedPacketType.normal);
      });

      test('fromJson handles missing optional fields gracefully', () {
        final json = _packet().toJson()
          ..['sender_avatar'] = null
          ..['cover_color'] = null;
        final restored = RedPacketEntity.fromJson(json);
        expect(restored.senderAvatar, isNull);
        expect(restored.coverColor, '#E64340'); // fallback default
      });

      test('toJson type field matches enum name', () {
        expect(_packet(type: RedPacketType.lucky).toJson()['type'], 'lucky');
        expect(_packet(type: RedPacketType.normal).toJson()['type'], 'normal');
      });
    });
  });

  // ─── RedPacketClaim ────────────────────────────────────────────────────────

  group('RedPacketClaim', () {
    test('stores all fields correctly', () {
      final claimedAt = DateTime(2025, 1, 15, 12, 0);
      final claim = RedPacketClaim(
        userId: '@bob:server.com',
        userName: 'Bob',
        avatarUrl: 'https://example.com/avatar.png',
        amount: 42.5,
        claimedAt: claimedAt,
      );
      expect(claim.userId, '@bob:server.com');
      expect(claim.userName, 'Bob');
      expect(claim.amount, 42.5);
      expect(claim.avatarUrl, 'https://example.com/avatar.png');
      expect(claim.claimedAt, claimedAt);
    });

    test('avatarUrl defaults to null', () {
      final claim = _claim('u1', 10.0);
      expect(claim.avatarUrl, isNull);
    });

    group('JSON round-trip', () {
      test('preserves all fields', () {
        final now = DateTime.now();
        final original = RedPacketClaim(
          userId: '@charlie:server.com',
          userName: 'Charlie',
          avatarUrl: 'https://example.com/c.png',
          amount: 77.77,
          claimedAt: now,
        );
        final json = original.toJson();
        final restored = RedPacketClaim.fromJson(json);

        expect(restored.userId, original.userId);
        expect(restored.userName, original.userName);
        expect(restored.avatarUrl, original.avatarUrl);
        expect(restored.amount, closeTo(original.amount, 0.001));
      });

      test('fromJson defaults userName to empty string when missing', () {
        final json = _claim('u1', 10.0).toJson()..remove('user_name');
        final restored = RedPacketClaim.fromJson(json);
        expect(restored.userName, '');
      });

      test('fromJson handles null avatarUrl', () {
        final json = _claim('u1', 10.0).toJson();
        json['avatar_url'] = null;
        final restored = RedPacketClaim.fromJson(json);
        expect(restored.avatarUrl, isNull);
      });
    });
  });

  // ─── RedPacketLifecycle enum ───────────────────────────────────────────────

  group('RedPacketLifecycle', () {
    test('has three values: active, completed, expired', () {
      expect(RedPacketLifecycle.values.length, 3);
      expect(RedPacketLifecycle.values, contains(RedPacketLifecycle.active));
      expect(RedPacketLifecycle.values, contains(RedPacketLifecycle.completed));
      expect(RedPacketLifecycle.values, contains(RedPacketLifecycle.expired));
    });
  });

  // ─── RedPacketType enum ────────────────────────────────────────────────────

  group('RedPacketType', () {
    test('has two values: normal and lucky', () {
      expect(RedPacketType.values.length, 2);
      expect(RedPacketType.values, contains(RedPacketType.normal));
      expect(RedPacketType.values, contains(RedPacketType.lucky));
    });
  });
}
