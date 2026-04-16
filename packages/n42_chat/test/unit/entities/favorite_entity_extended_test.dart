// Extended tests for favorite_entity — covers methods NOT in existing tests:
//   RedPacketEntity (props equality, isEmpty, isExpired, canClaim)

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/favorite_entity.dart';

RedPacketEntity _packet({
  RedPacketEntityStatus status = RedPacketEntityStatus.pending,
  DateTime? expiredAt,
}) =>
    RedPacketEntity(
      id: 'rp1',
      senderId: '@alice:server',
      senderName: 'Alice',
      amount: '0.01',
      token: 'ETH',
      status: status,
      expiredAt: expiredAt,
      createdAt: DateTime(2025, 6, 1),
    );

void main() {
  // ─────────────────────────────────────────────────
  // RedPacketEntity.props equality
  // ─────────────────────────────────────────────────

  group('RedPacketEntity.props', () {
    test('two identical instances are equal', () {
      final ts = DateTime(2025, 6, 1);
      final a = RedPacketEntity(
        id: 'rp1',
        senderId: '@alice:s',
        senderName: 'Alice',
        amount: '0.01',
        token: 'ETH',
        createdAt: ts,
      );
      final b = RedPacketEntity(
        id: 'rp1',
        senderId: '@alice:s',
        senderName: 'Alice',
        amount: '0.01',
        token: 'ETH',
        createdAt: ts,
      );
      expect(a, equals(b));
    });

    test('different id → not equal', () {
      final ts = DateTime(2025, 6, 1);
      final a = RedPacketEntity(
        id: 'rp1',
        senderId: '@alice:s',
        senderName: 'Alice',
        amount: '0.01',
        token: 'ETH',
        createdAt: ts,
      );
      final b = RedPacketEntity(
        id: 'rp2',
        senderId: '@alice:s',
        senderName: 'Alice',
        amount: '0.01',
        token: 'ETH',
        createdAt: ts,
      );
      expect(a, isNot(equals(b)));
    });
  });

  // ─────────────────────────────────────────────────
  // RedPacketEntity.isEmpty
  // ─────────────────────────────────────────────────

  group('RedPacketEntity.isEmpty', () {
    test('returns false for pending status', () {
      expect(_packet(status: RedPacketEntityStatus.pending).isEmpty, isFalse);
    });

    test('returns true for empty status', () {
      expect(_packet(status: RedPacketEntityStatus.empty).isEmpty, isTrue);
    });

    test('returns false for expired status', () {
      expect(_packet(status: RedPacketEntityStatus.expired).isEmpty, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // RedPacketEntity.isExpired
  // ─────────────────────────────────────────────────

  group('RedPacketEntity.isExpired', () {
    test('returns false for pending without expiredAt', () {
      expect(_packet(status: RedPacketEntityStatus.pending).isExpired, isFalse);
    });

    test('returns true for expired status', () {
      expect(_packet(status: RedPacketEntityStatus.expired).isExpired, isTrue);
    });

    test('returns true when expiredAt is in the past', () {
      final past = DateTime.now().subtract(const Duration(hours: 1));
      expect(
        _packet(status: RedPacketEntityStatus.pending, expiredAt: past).isExpired,
        isTrue,
      );
    });

    test('returns false when expiredAt is in the future', () {
      final future = DateTime.now().add(const Duration(hours: 1));
      expect(
        _packet(status: RedPacketEntityStatus.pending, expiredAt: future).isExpired,
        isFalse,
      );
    });
  });

  // ─────────────────────────────────────────────────
  // RedPacketEntity.canClaim
  // ─────────────────────────────────────────────────

  group('RedPacketEntity.canClaim', () {
    test('returns true for pending non-expired packet', () {
      expect(_packet(status: RedPacketEntityStatus.pending).canClaim, isTrue);
    });

    test('returns false for expired-status packet', () {
      expect(_packet(status: RedPacketEntityStatus.expired).canClaim, isFalse);
    });

    test('returns false for empty packet', () {
      expect(_packet(status: RedPacketEntityStatus.empty).canClaim, isFalse);
    });

    test('returns false when expiredAt is in the past', () {
      final past = DateTime.now().subtract(const Duration(hours: 1));
      expect(
        _packet(status: RedPacketEntityStatus.pending, expiredAt: past).canClaim,
        isFalse,
      );
    });
  });
}
