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

VoiceRoomEntity _makeRoom({
  String roomId = '!voice:s',
  VoiceRoomStatus status = VoiceRoomStatus.live,
}) =>
    VoiceRoomEntity(
      roomId: roomId,
      name: 'Test Room',
      creatorId: '@host:s',
      status: status,
    );

void main() {
  late MockVoiceRoomRepository mockRepo;
  late MockVoiceRoomService mockService;

  setUpAll(() {
    registerFallbackValue(_makeRoom());
  });

  setUp(() {
    mockRepo = MockVoiceRoomRepository();
    mockService = MockVoiceRoomService();

    // BLoC constructor subscribes to both streams immediately.
    // These MUST be stubbed before buildBloc() is called.
    when(() => mockService.stateStream)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockRepo.watchActiveVoiceRooms())
        .thenAnswer((_) => const Stream.empty());
  });

  VoiceRoomBloc buildBloc() => VoiceRoomBloc(
        repository: mockRepo,
        voiceRoomService: mockService,
      );

  group('initial state', () {
    test('VoiceRoomState.initial() has correct defaults', () {
      final bloc = buildBloc();
      expect(bloc.state.room, isNull);
      expect(bloc.state.activeRooms, isEmpty);
      expect(bloc.state.isConnected, isFalse);
      expect(bloc.state.isMuted, isTrue);
      expect(bloc.state.isHandRaised, isFalse);
      expect(bloc.state.myRole, VoiceRoomRole.listener);
      expect(bloc.state.error, isNull);
    });
  });

  group('LoadActiveVoiceRooms', () {
    blocTest<VoiceRoomBloc, VoiceRoomState>(
      'emits [loading, loaded] on success',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.getActiveVoiceRooms())
            .thenAnswer((_) async => [_makeRoom(), _makeRoom(roomId: '!v2:s')]);
      },
      act: (bloc) => bloc.add(const LoadActiveVoiceRooms()),
      expect: () => [
        isA<VoiceRoomState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<VoiceRoomState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.activeRooms.length, 'activeRooms.length', 2),
      ],
    );

    blocTest<VoiceRoomBloc, VoiceRoomState>(
      'emits [loading, error] on failure',
      build: buildBloc,
      setUp: () {
        when(() => mockRepo.getActiveVoiceRooms())
            .thenThrow(Exception('Network error'));
      },
      act: (bloc) => bloc.add(const LoadActiveVoiceRooms()),
      expect: () => [
        isA<VoiceRoomState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<VoiceRoomState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  group('CreateVoiceRoom', () {
    blocTest<VoiceRoomBloc, VoiceRoomState>(
      'emits loading → room set when repo returns a room',
      build: buildBloc,
      setUp: () {
        when(
          () => mockRepo.createVoiceRoom(
            name: any(named: 'name'),
            topic: any(named: 'topic'),
          ),
        ).thenAnswer((_) async => _makeRoom());
        // JoinVoiceRoom is auto-added after create
        when(() => mockService.joinRoom(any())).thenAnswer((_) async => true);
        when(() => mockRepo.getVoiceRoom(any()))
            .thenAnswer((_) async => _makeRoom());
        when(() => mockService.myRole).thenReturn(VoiceRoomRole.host);
        when(() => mockService.isMuted).thenReturn(false);
        when(() => mockRepo.watchVoiceRoom(any()))
            .thenAnswer((_) => const Stream.empty());
      },
      act: (bloc) =>
          bloc.add(const CreateVoiceRoom(name: 'My Room', topic: 'Dart talk')),
      expect: () => [
        isA<VoiceRoomState>().having((s) => s.isLoading, 'isLoading', isTrue),
        // room set after create
        isA<VoiceRoomState>()
            .having((s) => s.room, 'room', isNotNull),
        // JoinVoiceRoom loading
        isA<VoiceRoomState>().having((s) => s.isLoading, 'isLoading', isTrue),
        // JoinVoiceRoom connected
        isA<VoiceRoomState>()
            .having((s) => s.isConnected, 'isConnected', isTrue),
      ],
    );

    blocTest<VoiceRoomBloc, VoiceRoomState>(
      'emits error when createVoiceRoom throws',
      build: buildBloc,
      setUp: () {
        when(
          () => mockRepo.createVoiceRoom(
            name: any(named: 'name'),
            topic: any(named: 'topic'),
          ),
        ).thenThrow(Exception('Creation failed'));
      },
      act: (bloc) => bloc.add(const CreateVoiceRoom(name: 'My Room')),
      expect: () => [
        isA<VoiceRoomState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<VoiceRoomState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  group('LeaveVoiceRoom', () {
    blocTest<VoiceRoomBloc, VoiceRoomState>(
      'clears room and resets connection state',
      build: buildBloc,
      seed: () => VoiceRoomState(
        room: _makeRoom(),
        isConnected: true,
        isMuted: false,
        myRole: VoiceRoomRole.speaker,
        isHandRaised: true,
        duration: 30,
      ),
      setUp: () {
        when(() => mockService.leaveRoom()).thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(const LeaveVoiceRoom()),
      expect: () => [
        isA<VoiceRoomState>()
            .having((s) => s.room, 'room', isNull)
            .having((s) => s.isConnected, 'isConnected', isFalse)
            .having((s) => s.isMuted, 'isMuted', isTrue)
            .having((s) => s.isHandRaised, 'isHandRaised', isFalse)
            .having((s) => s.duration, 'duration', 0),
      ],
    );
  });

  group('RaiseHand', () {
    blocTest<VoiceRoomBloc, VoiceRoomState>(
      'emits isHandRaised=true on success',
      build: buildBloc,
      setUp: () {
        when(() => mockService.raiseHand()).thenAnswer((_) async => true);
      },
      act: (bloc) => bloc.add(const RaiseHand()),
      expect: () => [
        isA<VoiceRoomState>()
            .having((s) => s.isHandRaised, 'isHandRaised', isTrue),
      ],
    );

    blocTest<VoiceRoomBloc, VoiceRoomState>(
      'emits error when raiseHand throws',
      build: buildBloc,
      setUp: () {
        when(() => mockService.raiseHand())
            .thenThrow(Exception('Raise hand failed'));
      },
      act: (bloc) => bloc.add(const RaiseHand()),
      expect: () => [
        isA<VoiceRoomState>().having((s) => s.error, 'error', isNotNull),
      ],
    );

    blocTest<VoiceRoomBloc, VoiceRoomState>(
      'does not change state when raiseHand returns false',
      build: buildBloc,
      setUp: () {
        when(() => mockService.raiseHand()).thenAnswer((_) async => false);
      },
      act: (bloc) => bloc.add(const RaiseHand()),
      expect: () => <VoiceRoomState>[],
    );
  });

  group('LowerHand', () {
    blocTest<VoiceRoomBloc, VoiceRoomState>(
      'emits isHandRaised=false on success',
      build: buildBloc,
      seed: () => const VoiceRoomState(isHandRaised: true),
      setUp: () {
        when(() => mockService.lowerHand()).thenAnswer((_) async => true);
      },
      act: (bloc) => bloc.add(const LowerHand()),
      expect: () => [
        isA<VoiceRoomState>()
            .having((s) => s.isHandRaised, 'isHandRaised', isFalse),
      ],
    );
  });

  group('ToggleMute', () {
    blocTest<VoiceRoomBloc, VoiceRoomState>(
      'toggles isMuted based on service state',
      build: buildBloc,
      seed: () => const VoiceRoomState(isMuted: true),
      setUp: () {
        when(() => mockService.toggleMute()).thenAnswer((_) async {});
        // After toggle, service reports isMuted=false
        when(() => mockService.isMuted).thenReturn(false);
      },
      act: (bloc) => bloc.add(const ToggleMute()),
      expect: () => [
        isA<VoiceRoomState>()
            .having((s) => s.isMuted, 'isMuted', isFalse),
      ],
    );
  });

  group('VoiceRoomUpdated', () {
    blocTest<VoiceRoomBloc, VoiceRoomState>(
      'updates room entity',
      build: buildBloc,
      setUp: () {
        when(() => mockService.myRole).thenReturn(VoiceRoomRole.listener);
        when(() => mockService.isMuted).thenReturn(true);
        when(() => mockService.syncFromRoom(any())).thenReturn(null);
      },
      act: (bloc) => bloc.add(VoiceRoomUpdated(_makeRoom())),
      expect: () => [
        isA<VoiceRoomState>().having((s) => s.room, 'room', isNotNull),
      ],
    );
  });

  group('ActiveVoiceRoomsUpdated', () {
    blocTest<VoiceRoomBloc, VoiceRoomState>(
      'updates activeRooms list',
      build: buildBloc,
      act: (bloc) =>
          bloc.add(ActiveVoiceRoomsUpdated([_makeRoom(), _makeRoom(roomId: '!v2:s')])),
      expect: () => [
        isA<VoiceRoomState>()
            .having((s) => s.activeRooms.length, 'activeRooms.length', 2),
      ],
    );
  });

  group('VoiceRoomState getters', () {
    test('isHost returns true for host role', () {
      const state = VoiceRoomState(myRole: VoiceRoomRole.host);
      expect(state.isHost, isTrue);
    });

    test('isHost returns true for coHost role', () {
      const state = VoiceRoomState(myRole: VoiceRoomRole.coHost);
      expect(state.isHost, isTrue);
    });

    test('isHost returns false for listener', () {
      const state = VoiceRoomState(myRole: VoiceRoomRole.listener);
      expect(state.isHost, isFalse);
    });

    test('canSpeak returns false for listener', () {
      const state = VoiceRoomState(myRole: VoiceRoomRole.listener);
      expect(state.canSpeak, isFalse);
    });

    test('canSpeak returns true for speaker', () {
      const state = VoiceRoomState(myRole: VoiceRoomRole.speaker);
      expect(state.canSpeak, isTrue);
    });
  });
}
