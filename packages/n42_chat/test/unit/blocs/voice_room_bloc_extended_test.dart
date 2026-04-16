// Extended tests for VoiceRoomBloc — covers handlers NOT in existing tests:
//   RaiseHand (success, failure),
//   LowerHand (success, failure),
//   ApproveSpeaker (success, failure),
//   DemoteToListener (success, failure),
//   ToggleMute,
//   EndVoiceRoom (success with room, no room),
//   VoiceRoomUpdated, ActiveVoiceRoomsUpdated, DurationTick

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/domain/entities/voice_room_entity.dart';
import 'package:n42_chat/src/domain/repositories/voice_room_repository.dart';
import 'package:n42_chat/src/presentation/blocs/voice_room/voice_room_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/voice_room/voice_room_event.dart';
import 'package:n42_chat/src/presentation/blocs/voice_room/voice_room_state.dart';
import 'package:n42_chat/src/services/voip/voice_room_service.dart';

class MockVoiceRoomRepository extends Mock implements IVoiceRoomRepository {}

class MockVoiceRoomService extends Mock implements VoiceRoomService {}

VoiceRoomEntity _makeRoom({String roomId = '!vc:server'}) => VoiceRoomEntity(
      roomId: roomId,
      name: 'Test Room',
      status: VoiceRoomStatus.live,
      creatorId: '@alice:server',
      createdAt: DateTime(2025, 6, 1),
    );

void main() {
  late MockVoiceRoomRepository mockRepo;
  late MockVoiceRoomService mockService;

  setUp(() {
    mockRepo = MockVoiceRoomRepository();
    mockService = MockVoiceRoomService();

    // stubs needed to build VoiceRoomBloc (constructor subscribes to streams)
    when(() => mockService.stateStream).thenAnswer(
      (_) => const Stream.empty(),
    );
    when(() => mockRepo.watchActiveVoiceRooms())
        .thenAnswer((_) => const Stream.empty());
  });

  setUpAll(() {
    registerFallbackValue(_makeRoom());
    registerFallbackValue(<VoiceRoomEntity>[]);
  });

  VoiceRoomBloc buildBloc() => VoiceRoomBloc(
        repository: mockRepo,
        voiceRoomService: mockService,
      );

  // ─────────────────────────────────────────────────
  // RaiseHand
  // ─────────────────────────────────────────────────

  group('RaiseHand', () {
    blocTest<VoiceRoomBloc, VoiceRoomState>(
      'emits isHandRaised=true on success',
      build: () {
        when(() => mockService.raiseHand()).thenAnswer((_) async => true);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const RaiseHand()),
      expect: () => [
        isA<VoiceRoomState>()
            .having((s) => s.isHandRaised, 'isHandRaised', isTrue),
      ],
    );

    blocTest<VoiceRoomBloc, VoiceRoomState>(
      'does not emit when raiseHand returns false',
      build: () {
        when(() => mockService.raiseHand()).thenAnswer((_) async => false);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const RaiseHand()),
      expect: () => <VoiceRoomState>[],
    );

    blocTest<VoiceRoomBloc, VoiceRoomState>(
      'emits error when raiseHand throws',
      build: () {
        when(() => mockService.raiseHand())
            .thenThrow(Exception('Permission denied'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const RaiseHand()),
      expect: () => [
        isA<VoiceRoomState>().having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // LowerHand
  // ─────────────────────────────────────────────────

  group('LowerHand', () {
    blocTest<VoiceRoomBloc, VoiceRoomState>(
      'emits isHandRaised=false on success',
      build: () {
        when(() => mockService.lowerHand()).thenAnswer((_) async => true);
        return buildBloc();
      },
      seed: () => const VoiceRoomState(isHandRaised: true),
      act: (bloc) => bloc.add(const LowerHand()),
      expect: () => [
        isA<VoiceRoomState>()
            .having((s) => s.isHandRaised, 'isHandRaised', isFalse),
      ],
    );

    blocTest<VoiceRoomBloc, VoiceRoomState>(
      'emits error when lowerHand throws',
      build: () {
        when(() => mockService.lowerHand())
            .thenThrow(Exception('network error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LowerHand()),
      expect: () => [
        isA<VoiceRoomState>().having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // ApproveSpeaker
  // ─────────────────────────────────────────────────

  group('ApproveSpeaker', () {
    blocTest<VoiceRoomBloc, VoiceRoomState>(
      'calls approveSpeaker with userId on success',
      build: () {
        when(() => mockService.approveSpeaker(any()))
            .thenAnswer((_) async => true);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ApproveSpeaker('@bob:server')),
      expect: () => <VoiceRoomState>[],
      verify: (_) {
        verify(() => mockService.approveSpeaker('@bob:server')).called(1);
      },
    );

    blocTest<VoiceRoomBloc, VoiceRoomState>(
      'emits error when approveSpeaker throws',
      build: () {
        when(() => mockService.approveSpeaker(any()))
            .thenThrow(Exception('server error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ApproveSpeaker('@bob:server')),
      expect: () => [
        isA<VoiceRoomState>().having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // DemoteToListener
  // ─────────────────────────────────────────────────

  group('DemoteToListener', () {
    blocTest<VoiceRoomBloc, VoiceRoomState>(
      'calls demoteToListener on success',
      build: () {
        when(() => mockService.demoteToListener(any()))
            .thenAnswer((_) async => true);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const DemoteToListener('@carol:server')),
      expect: () => <VoiceRoomState>[],
      verify: (_) {
        verify(() => mockService.demoteToListener('@carol:server')).called(1);
      },
    );

    blocTest<VoiceRoomBloc, VoiceRoomState>(
      'emits error when demoteToListener throws',
      build: () {
        when(() => mockService.demoteToListener(any()))
            .thenThrow(Exception('error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const DemoteToListener('@carol:server')),
      expect: () => [
        isA<VoiceRoomState>().having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // ToggleMute
  // ─────────────────────────────────────────────────

  group('ToggleMute', () {
    blocTest<VoiceRoomBloc, VoiceRoomState>(
      'calls toggleMute and emits updated isMuted',
      build: () {
        when(() => mockService.toggleMute()).thenAnswer((_) async {});
        when(() => mockService.isMuted).thenReturn(true);
        return buildBloc();
      },
      seed: () => const VoiceRoomState(isMuted: false),
      act: (bloc) => bloc.add(const ToggleMute()),
      expect: () => [
        isA<VoiceRoomState>()
            .having((s) => s.isMuted, 'isMuted', isTrue),
      ],
      verify: (_) {
        verify(() => mockService.toggleMute()).called(1);
      },
    );

    blocTest<VoiceRoomBloc, VoiceRoomState>(
      'emits error when toggleMute fails',
      build: () {
        when(() => mockService.toggleMute())
            .thenThrow(StateError('mute failed'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ToggleMute()),
      expect: () => [
        isA<VoiceRoomState>().having((s) => s.error, 'error', contains('Failed to toggle mute')),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // EndVoiceRoom
  // ─────────────────────────────────────────────────

  group('EndVoiceRoom', () {
    blocTest<VoiceRoomBloc, VoiceRoomState>(
      'calls endVoiceRoom and triggers LeaveVoiceRoom on success',
      build: () {
        when(() => mockRepo.endVoiceRoom(any()))
            .thenAnswer((_) async => true);
        when(() => mockService.leaveRoom()).thenAnswer((_) async {});
        when(() => mockRepo.watchVoiceRoom(any()))
            .thenAnswer((_) => const Stream.empty());
        return buildBloc();
      },
      seed: () => VoiceRoomState(room: _makeRoom()),
      act: (bloc) => bloc.add(const EndVoiceRoom()),
      expect: () => [
        // LeaveVoiceRoom clears the room
        isA<VoiceRoomState>()
            .having((s) => s.room, 'room', isNull)
            .having((s) => s.isConnected, 'isConnected', isFalse),
      ],
    );

    blocTest<VoiceRoomBloc, VoiceRoomState>(
      'emits error when endVoiceRoom returns false',
      build: () {
        when(() => mockRepo.endVoiceRoom(any()))
            .thenAnswer((_) async => false);
        return buildBloc();
      },
      seed: () => VoiceRoomState(room: _makeRoom()),
      act: (bloc) => bloc.add(const EndVoiceRoom()),
      expect: () => [
        isA<VoiceRoomState>()
            .having((s) => s.room, 'room', isNotNull)
            .having((s) => s.error, 'error', 'Failed to end voice room'),
      ],
    );

    blocTest<VoiceRoomBloc, VoiceRoomState>(
      'does not emit when room is null',
      build: buildBloc,
      // Default state has no room
      act: (bloc) => bloc.add(const EndVoiceRoom()),
      expect: () => <VoiceRoomState>[],
    );
  });

  // ─────────────────────────────────────────────────
  // VoiceRoomUpdated
  // ─────────────────────────────────────────────────

  group('VoiceRoomUpdated', () {
    blocTest<VoiceRoomBloc, VoiceRoomState>(
      'emits updated room and synced local mute/role state',
      build: buildBloc,
      setUp: () {
        when(() => mockService.myRole).thenReturn(VoiceRoomRole.host);
        when(() => mockService.isMuted).thenReturn(false);
        when(() => mockService.syncFromRoom(any())).thenReturn(null);
      },
      act: (bloc) =>
          bloc.add(VoiceRoomUpdated(_makeRoom(roomId: '!new:server'))),
      expect: () => [
        isA<VoiceRoomState>()
            .having((s) => s.room?.roomId, 'room.roomId', '!new:server')
            .having((s) => s.myRole, 'myRole', VoiceRoomRole.host)
            .having((s) => s.isMuted, 'isMuted', isFalse),
      ],
      verify: (_) {
        verify(() => mockService.syncFromRoom(any())).called(1);
      },
    );
  });

  // ─────────────────────────────────────────────────
  // ActiveVoiceRoomsUpdated
  // ─────────────────────────────────────────────────

  group('ActiveVoiceRoomsUpdated', () {
    blocTest<VoiceRoomBloc, VoiceRoomState>(
      'emits updated activeRooms list',
      build: buildBloc,
      act: (bloc) => bloc.add(ActiveVoiceRoomsUpdated([
        _makeRoom(roomId: '!r1:server'),
        _makeRoom(roomId: '!r2:server'),
      ])),
      expect: () => [
        isA<VoiceRoomState>()
            .having((s) => s.activeRooms.length, 'activeRooms.length', 2),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // DurationTick
  // ─────────────────────────────────────────────────

  group('DurationTick', () {
    blocTest<VoiceRoomBloc, VoiceRoomState>(
      'increments duration when isConnected',
      build: buildBloc,
      seed: () => const VoiceRoomState(isConnected: true, duration: 5),
      act: (bloc) => bloc.add(const DurationTick()),
      expect: () => [
        isA<VoiceRoomState>().having((s) => s.duration, 'duration', 6),
      ],
    );

    blocTest<VoiceRoomBloc, VoiceRoomState>(
      'does not increment when not connected',
      build: buildBloc,
      seed: () => const VoiceRoomState(isConnected: false, duration: 5),
      act: (bloc) => bloc.add(const DurationTick()),
      expect: () => <VoiceRoomState>[],
    );
  });
}
