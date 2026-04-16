import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/voice_room_entity.dart';

void main() {
  group('VoiceRoomStatus', () {
    test('has 3 values', () {
      expect(VoiceRoomStatus.values.length, 3);
      expect(VoiceRoomStatus.values, containsAll([
        VoiceRoomStatus.scheduled,
        VoiceRoomStatus.live,
        VoiceRoomStatus.ended,
      ]));
    });
  });

  group('VoiceRoomRole', () {
    test('has 4 values', () {
      expect(VoiceRoomRole.values.length, 4);
      expect(VoiceRoomRole.values, containsAll([
        VoiceRoomRole.host,
        VoiceRoomRole.coHost,
        VoiceRoomRole.speaker,
        VoiceRoomRole.listener,
      ]));
    });
  });

  group('VoiceRoomParticipant', () {
    test('constructs with defaults', () {
      const p = VoiceRoomParticipant(
        userId: '@alice:s',
        displayName: 'Alice',
      );

      expect(p.userId, '@alice:s');
      expect(p.displayName, 'Alice');
      expect(p.avatarUrl, isNull);
      expect(p.role, VoiceRoomRole.listener);
      expect(p.isSpeaking, isFalse);
      expect(p.isMuted, isTrue); // default isMuted = true
      expect(p.isHandRaised, isFalse);
    });

    test('constructs with all fields', () {
      const p = VoiceRoomParticipant(
        userId: '@host:s',
        displayName: 'Host',
        avatarUrl: 'https://example.com/avatar.jpg',
        role: VoiceRoomRole.host,
        isSpeaking: true,
        isMuted: false,
        isHandRaised: true,
      );

      expect(p.role, VoiceRoomRole.host);
      expect(p.isSpeaking, isTrue);
      expect(p.isMuted, isFalse);
      expect(p.isHandRaised, isTrue);
    });

    group('copyWith', () {
      test('replaces specified fields', () {
        const original = VoiceRoomParticipant(
          userId: '@alice:s',
          displayName: 'Alice',
          isMuted: true,
        );

        final updated = original.copyWith(isMuted: false, isSpeaking: true);

        expect(updated.userId, '@alice:s');
        expect(updated.isMuted, isFalse);
        expect(updated.isSpeaking, isTrue);
      });
    });

    group('props equality', () {
      test('equal participants with same fields', () {
        const a = VoiceRoomParticipant(
          userId: '@alice:s',
          displayName: 'Alice',
        );
        const b = VoiceRoomParticipant(
          userId: '@alice:s',
          displayName: 'Alice',
        );

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('different userId produces different participants', () {
        const a = VoiceRoomParticipant(userId: '@alice:s', displayName: 'A');
        const b = VoiceRoomParticipant(userId: '@bob:s', displayName: 'B');

        expect(a, isNot(equals(b)));
      });
    });
  });

  group('VoiceRoomEntity', () {
    VoiceRoomParticipant _makeParticipant({
      required String userId,
      VoiceRoomRole role = VoiceRoomRole.listener,
      bool isHandRaised = false,
    }) {
      return VoiceRoomParticipant(
        userId: userId,
        displayName: userId,
        role: role,
        isHandRaised: isHandRaised,
      );
    }

    test('constructs with required fields and defaults', () {
      const room = VoiceRoomEntity(
        roomId: '!room:s',
        name: 'Test Room',
        creatorId: '@host:s',
      );

      expect(room.roomId, '!room:s');
      expect(room.name, 'Test Room');
      expect(room.topic, isNull);
      expect(room.status, VoiceRoomStatus.live); // default
      expect(room.participants, isEmpty);
      expect(room.creatorId, '@host:s');
      expect(room.createdAt, isNull);
      expect(room.scheduledAt, isNull);
      expect(room.endedAt, isNull);
    });

    test('participantCount returns participants length', () {
      final participants = [
        _makeParticipant(userId: '@a:s'),
        _makeParticipant(userId: '@b:s'),
        _makeParticipant(userId: '@c:s'),
      ];

      final room = VoiceRoomEntity(
        roomId: '!room:s',
        name: 'Room',
        creatorId: '@host:s',
        participants: participants,
      );

      expect(room.participantCount, 3);
    });

    test('hosts returns host and coHost participants', () {
      final participants = [
        _makeParticipant(userId: '@host:s', role: VoiceRoomRole.host),
        _makeParticipant(userId: '@cohost:s', role: VoiceRoomRole.coHost),
        _makeParticipant(userId: '@speaker:s', role: VoiceRoomRole.speaker),
        _makeParticipant(userId: '@listener:s', role: VoiceRoomRole.listener),
      ];

      final room = VoiceRoomEntity(
        roomId: '!room:s',
        name: 'Room',
        creatorId: '@host:s',
        participants: participants,
      );

      expect(room.hosts.length, 2);
      expect(room.speakers.length, 1);
      expect(room.listeners.length, 1);
    });

    test('raisedHands filters by isHandRaised', () {
      final participants = [
        _makeParticipant(userId: '@a:s', isHandRaised: true),
        _makeParticipant(userId: '@b:s', isHandRaised: false),
        _makeParticipant(userId: '@c:s', isHandRaised: true),
      ];

      final room = VoiceRoomEntity(
        roomId: '!room:s',
        name: 'Room',
        creatorId: '@host:s',
        participants: participants,
      );

      expect(room.raisedHands.length, 2);
    });

    group('status getters', () {
      test('isLive is true when status is live', () {
        const room = VoiceRoomEntity(
          roomId: '!r:s',
          name: 'R',
          creatorId: '@h:s',
          status: VoiceRoomStatus.live,
        );
        expect(room.isLive, isTrue);
        expect(room.isEnded, isFalse);
      });

      test('isEnded is true when status is ended', () {
        const room = VoiceRoomEntity(
          roomId: '!r:s',
          name: 'R',
          creatorId: '@h:s',
          status: VoiceRoomStatus.ended,
        );
        expect(room.isEnded, isTrue);
        expect(room.isLive, isFalse);
      });

      test('scheduled room is not live nor ended', () {
        const room = VoiceRoomEntity(
          roomId: '!r:s',
          name: 'R',
          creatorId: '@h:s',
          status: VoiceRoomStatus.scheduled,
        );
        expect(room.isLive, isFalse);
        expect(room.isEnded, isFalse);
      });
    });

    group('props equality', () {
      test('equal rooms with same fields', () {
        const a = VoiceRoomEntity(
          roomId: '!r:s',
          name: 'Room',
          creatorId: '@h:s',
        );
        const b = VoiceRoomEntity(
          roomId: '!r:s',
          name: 'Room',
          creatorId: '@h:s',
        );

        expect(a, equals(b));
      });

      test('different roomId produces different rooms', () {
        const a = VoiceRoomEntity(roomId: '!r1:s', name: 'R', creatorId: '@h:s');
        const b = VoiceRoomEntity(roomId: '!r2:s', name: 'R', creatorId: '@h:s');

        expect(a, isNot(equals(b)));
      });
    });

    group('copyWith', () {
      test('replaces status and endedAt', () {
        const original = VoiceRoomEntity(
          roomId: '!r:s',
          name: 'Room',
          creatorId: '@h:s',
        );
        final endedAt = DateTime(2025, 6, 1, 12);
        final updated = original.copyWith(
          status: VoiceRoomStatus.ended,
          endedAt: endedAt,
        );

        expect(updated.status, VoiceRoomStatus.ended);
        expect(updated.endedAt, endedAt);
        expect(updated.roomId, original.roomId);
        expect(updated.name, original.name);
      });
    });
  });
}
