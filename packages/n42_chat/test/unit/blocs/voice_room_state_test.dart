// Tests for VoiceRoomState in voice_room_state.dart.
// VoiceRoomEntity-typed fields (room, activeRooms) are kept null/empty.
// VoiceRoomRole enum is imported to verify isHost / canSpeak logic.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/voice_room_entity.dart';
import 'package:n42_chat/src/presentation/blocs/voice_room/voice_room_state.dart';

void main() {
  // ─────────────────────────────────────────────────
  // Constructor defaults
  // ─────────────────────────────────────────────────

  group('VoiceRoomState constructor defaults', () {
    const s = VoiceRoomState();

    test('room defaults to null', () {
      expect(s.room, isNull);
    });

    test('activeRooms defaults to empty list', () {
      expect(s.activeRooms, isEmpty);
    });

    test('myRole defaults to VoiceRoomRole.listener', () {
      expect(s.myRole, VoiceRoomRole.listener);
    });

    test('isHandRaised defaults to false', () {
      expect(s.isHandRaised, isFalse);
    });

    test('isMuted defaults to true', () {
      expect(s.isMuted, isTrue);
    });

    test('isConnected defaults to false', () {
      expect(s.isConnected, isFalse);
    });

    test('duration defaults to 0', () {
      expect(s.duration, 0);
    });

    test('isLoading defaults to false', () {
      expect(s.isLoading, isFalse);
    });

    test('error defaults to null', () {
      expect(s.error, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // VoiceRoomState.initial()
  // ─────────────────────────────────────────────────

  group('VoiceRoomState.initial()', () {
    test('is identical to default constructor state', () {
      expect(VoiceRoomState.initial(), equals(const VoiceRoomState()));
    });

    test('myRole is listener', () {
      expect(VoiceRoomState.initial().myRole, VoiceRoomRole.listener);
    });
  });

  // ─────────────────────────────────────────────────
  // isHost getter
  // ─────────────────────────────────────────────────

  group('VoiceRoomState.isHost', () {
    test('true when myRole == host', () {
      const s = VoiceRoomState(myRole: VoiceRoomRole.host);
      expect(s.isHost, isTrue);
    });

    test('true when myRole == coHost', () {
      const s = VoiceRoomState(myRole: VoiceRoomRole.coHost);
      expect(s.isHost, isTrue);
    });

    test('false when myRole == speaker', () {
      const s = VoiceRoomState(myRole: VoiceRoomRole.speaker);
      expect(s.isHost, isFalse);
    });

    test('false when myRole == listener', () {
      expect(const VoiceRoomState().isHost, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // canSpeak getter
  // ─────────────────────────────────────────────────

  group('VoiceRoomState.canSpeak', () {
    test('true when myRole == host', () {
      const s = VoiceRoomState(myRole: VoiceRoomRole.host);
      expect(s.canSpeak, isTrue);
    });

    test('true when myRole == coHost', () {
      const s = VoiceRoomState(myRole: VoiceRoomRole.coHost);
      expect(s.canSpeak, isTrue);
    });

    test('true when myRole == speaker', () {
      const s = VoiceRoomState(myRole: VoiceRoomRole.speaker);
      expect(s.canSpeak, isTrue);
    });

    test('false when myRole == listener', () {
      expect(const VoiceRoomState().canSpeak, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — scalar overrides
  // ─────────────────────────────────────────────────

  group('VoiceRoomState.copyWith scalar', () {
    const base = VoiceRoomState(
      myRole: VoiceRoomRole.speaker,
      isHandRaised: false,
      isMuted: true,
      isConnected: false,
      duration: 120,
      isLoading: false,
      error: 'conn error',
    );

    test('no overrides preserves all fields', () {
      final copy = base.copyWith();
      expect(copy.myRole, VoiceRoomRole.speaker);
      expect(copy.duration, 120);
      expect(copy.error, 'conn error');
    });

    test('overrides myRole', () {
      final copy = base.copyWith(myRole: VoiceRoomRole.host);
      expect(copy.myRole, VoiceRoomRole.host);
    });

    test('overrides isHandRaised', () {
      final copy = base.copyWith(isHandRaised: true);
      expect(copy.isHandRaised, isTrue);
    });

    test('overrides isMuted', () {
      final copy = base.copyWith(isMuted: false);
      expect(copy.isMuted, isFalse);
    });

    test('overrides isConnected', () {
      final copy = base.copyWith(isConnected: true);
      expect(copy.isConnected, isTrue);
    });

    test('overrides duration', () {
      final copy = base.copyWith(duration: 300);
      expect(copy.duration, 300);
    });

    test('overrides isLoading', () {
      final copy = base.copyWith(isLoading: true);
      expect(copy.isLoading, isTrue);
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — clearRoom flag
  // ─────────────────────────────────────────────────

  group('VoiceRoomState.copyWith clearRoom', () {
    test('clearRoom=true sets room to null (starts null)', () {
      const s = VoiceRoomState();
      final copy = s.copyWith(clearRoom: true);
      expect(copy.room, isNull);
    });

    test('clearRoom=false preserves null room', () {
      const s = VoiceRoomState();
      final copy = s.copyWith(clearRoom: false);
      expect(copy.room, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — clearError flag
  // ─────────────────────────────────────────────────

  group('VoiceRoomState.copyWith clearError', () {
    const withError = VoiceRoomState(error: 'mic unavailable');

    test('clearError=true sets error to null', () {
      final copy = withError.copyWith(clearError: true);
      expect(copy.error, isNull);
    });

    test('clearError=false preserves error', () {
      final copy = withError.copyWith(clearError: false);
      expect(copy.error, 'mic unavailable');
    });

    test('clearError=true overrides provided error', () {
      final copy = withError.copyWith(clearError: true, error: 'ignored');
      expect(copy.error, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // Equatable equality
  // ─────────────────────────────────────────────────

  group('VoiceRoomState Equatable equality', () {
    test('two default instances are equal', () {
      expect(const VoiceRoomState(), equals(const VoiceRoomState()));
    });

    test('different myRole → not equal', () {
      expect(
        const VoiceRoomState(myRole: VoiceRoomRole.host),
        isNot(equals(const VoiceRoomState())),
      );
    });

    test('different isMuted → not equal', () {
      expect(
        const VoiceRoomState(isMuted: false),
        isNot(equals(const VoiceRoomState())),
      );
    });

    test('different duration → not equal', () {
      expect(
        const VoiceRoomState(duration: 60),
        isNot(equals(const VoiceRoomState())),
      );
    });

    test('same fields → equal', () {
      expect(
        const VoiceRoomState(myRole: VoiceRoomRole.speaker, duration: 90),
        equals(const VoiceRoomState(myRole: VoiceRoomRole.speaker, duration: 90)),
      );
    });
  });
}
