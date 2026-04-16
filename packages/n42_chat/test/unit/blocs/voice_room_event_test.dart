// Tests for VoiceRoomEvent subclasses in voice_room_event.dart.
// VoiceRoomEntity has all-optional DateTime fields, so it is const-constructible.
// Pure Dart — no platform deps.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/voice_room_entity.dart';
import 'package:n42_chat/src/presentation/blocs/voice_room/voice_room_event.dart';

void main() {
  // Minimal const VoiceRoomEntity (all DateTime fields are optional).
  const room = VoiceRoomEntity(
    roomId: '!room:server',
    name: 'Dev Standup',
    creatorId: '@host:server',
  );

  // ─────────────────────────────────────────────────
  // Parameterless events
  // ─────────────────────────────────────────────────

  group('LoadActiveVoiceRooms', () {
    test('is a VoiceRoomEvent', () {
      expect(const LoadActiveVoiceRooms(), isA<VoiceRoomEvent>());
    });

    test('two instances are equal', () {
      expect(const LoadActiveVoiceRooms(), equals(const LoadActiveVoiceRooms()));
    });
  });

  group('LeaveVoiceRoom', () {
    test('is a VoiceRoomEvent', () {
      expect(const LeaveVoiceRoom(), isA<VoiceRoomEvent>());
    });

    test('two instances are equal', () {
      expect(const LeaveVoiceRoom(), equals(const LeaveVoiceRoom()));
    });
  });

  group('RaiseHand', () {
    test('is a VoiceRoomEvent', () {
      expect(const RaiseHand(), isA<VoiceRoomEvent>());
    });

    test('two instances are equal', () {
      expect(const RaiseHand(), equals(const RaiseHand()));
    });
  });

  group('LowerHand', () {
    test('is a VoiceRoomEvent', () {
      expect(const LowerHand(), isA<VoiceRoomEvent>());
    });

    test('two instances are equal', () {
      expect(const LowerHand(), equals(const LowerHand()));
    });
  });

  group('ToggleMute', () {
    test('is a VoiceRoomEvent', () {
      expect(const ToggleMute(), isA<VoiceRoomEvent>());
    });

    test('two instances are equal', () {
      expect(const ToggleMute(), equals(const ToggleMute()));
    });
  });

  group('EndVoiceRoom', () {
    test('is a VoiceRoomEvent', () {
      expect(const EndVoiceRoom(), isA<VoiceRoomEvent>());
    });

    test('two instances are equal', () {
      expect(const EndVoiceRoom(), equals(const EndVoiceRoom()));
    });
  });

  group('DurationTick', () {
    test('is a VoiceRoomEvent', () {
      expect(const DurationTick(), isA<VoiceRoomEvent>());
    });

    test('two instances are equal', () {
      expect(const DurationTick(), equals(const DurationTick()));
    });
  });

  // ─────────────────────────────────────────────────
  // CreateVoiceRoom
  // ─────────────────────────────────────────────────

  group('CreateVoiceRoom', () {
    test('stores name', () {
      const e = CreateVoiceRoom(name: 'Weekly Sync');
      expect(e.name, 'Weekly Sync');
    });

    test('topic defaults to null', () {
      expect(const CreateVoiceRoom(name: 'Room').topic, isNull);
    });

    test('stores topic when provided', () {
      const e = CreateVoiceRoom(name: 'Room', topic: 'Q4 planning');
      expect(e.topic, 'Q4 planning');
    });

    test('same fields → equal', () {
      expect(
        const CreateVoiceRoom(name: 'Room', topic: 'Topic'),
        equals(const CreateVoiceRoom(name: 'Room', topic: 'Topic')),
      );
    });

    test('different name → not equal', () {
      expect(
        const CreateVoiceRoom(name: 'A'),
        isNot(equals(const CreateVoiceRoom(name: 'B'))),
      );
    });

    test('different topic → not equal', () {
      expect(
        const CreateVoiceRoom(name: 'R', topic: 'T1'),
        isNot(equals(const CreateVoiceRoom(name: 'R', topic: 'T2'))),
      );
    });

    test('is a VoiceRoomEvent', () {
      expect(const CreateVoiceRoom(name: 'R'), isA<VoiceRoomEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // JoinVoiceRoom
  // ─────────────────────────────────────────────────

  group('JoinVoiceRoom', () {
    test('stores roomId', () {
      const e = JoinVoiceRoom('!room:server');
      expect(e.roomId, '!room:server');
    });

    test('same roomId → equal', () {
      expect(const JoinVoiceRoom('!r:s'), equals(const JoinVoiceRoom('!r:s')));
    });

    test('different roomId → not equal', () {
      expect(
        const JoinVoiceRoom('!a:s'),
        isNot(equals(const JoinVoiceRoom('!b:s'))),
      );
    });

    test('is a VoiceRoomEvent', () {
      expect(const JoinVoiceRoom('!r:s'), isA<VoiceRoomEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // ApproveSpeaker / DemoteToListener
  // ─────────────────────────────────────────────────

  group('ApproveSpeaker', () {
    test('stores userId', () {
      expect(const ApproveSpeaker('@alice:s').userId, '@alice:s');
    });

    test('same userId → equal', () {
      expect(
        const ApproveSpeaker('@u:s'),
        equals(const ApproveSpeaker('@u:s')),
      );
    });

    test('different userId → not equal', () {
      expect(
        const ApproveSpeaker('@a:s'),
        isNot(equals(const ApproveSpeaker('@b:s'))),
      );
    });

    test('is a VoiceRoomEvent', () {
      expect(const ApproveSpeaker('@u:s'), isA<VoiceRoomEvent>());
    });
  });

  group('DemoteToListener', () {
    test('stores userId', () {
      expect(const DemoteToListener('@bob:s').userId, '@bob:s');
    });

    test('same userId → equal', () {
      expect(
        const DemoteToListener('@u:s'),
        equals(const DemoteToListener('@u:s')),
      );
    });

    test('is a VoiceRoomEvent', () {
      expect(const DemoteToListener('@u:s'), isA<VoiceRoomEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // VoiceRoomUpdated
  // ─────────────────────────────────────────────────

  group('VoiceRoomUpdated', () {
    test('stores room fields', () {
      const e = VoiceRoomUpdated(room);
      expect(e.room.roomId, '!room:server');
      expect(e.room.name, 'Dev Standup');
      expect(e.room.creatorId, '@host:server');
    });

    test('same room → equal', () {
      expect(const VoiceRoomUpdated(room), equals(const VoiceRoomUpdated(room)));
    });

    test('is a VoiceRoomEvent', () {
      expect(const VoiceRoomUpdated(room), isA<VoiceRoomEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // ActiveVoiceRoomsUpdated
  // ─────────────────────────────────────────────────

  group('ActiveVoiceRoomsUpdated', () {
    test('stores empty rooms list', () {
      const e = ActiveVoiceRoomsUpdated([]);
      expect(e.rooms, isEmpty);
    });

    test('stores room in list', () {
      const e = ActiveVoiceRoomsUpdated([room]);
      expect(e.rooms.length, 1);
      expect(e.rooms.first.roomId, '!room:server');
    });

    test('same rooms → equal', () {
      expect(
        const ActiveVoiceRoomsUpdated([room]),
        equals(const ActiveVoiceRoomsUpdated([room])),
      );
    });

    test('empty rooms → equal', () {
      expect(
        const ActiveVoiceRoomsUpdated([]),
        equals(const ActiveVoiceRoomsUpdated([])),
      );
    });

    test('is a VoiceRoomEvent', () {
      expect(const ActiveVoiceRoomsUpdated([]), isA<VoiceRoomEvent>());
    });
  });
}
