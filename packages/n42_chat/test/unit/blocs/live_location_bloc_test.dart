import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_message_datasource.dart';
import 'package:n42_chat/src/domain/entities/live_location_entity.dart';
import 'package:n42_chat/src/presentation/blocs/live_location/live_location_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/live_location/live_location_event.dart';
import 'package:n42_chat/src/presentation/blocs/live_location/live_location_state.dart';

class MockMatrixMessageDataSource extends Mock
    implements MatrixMessageDataSource {}

const _kRoomId = '!room:s';

LiveLocationEntity _makeLocation({
  String userId = '@alice:s',
  bool expired = false,
}) {
  final now = DateTime.now();
  return LiveLocationEntity(
    userId: userId,
    displayName: 'Alice',
    latitude: 31.23,
    longitude: 121.47,
    updatedAt: now,
    expiresAt: expired
        ? now.subtract(const Duration(minutes: 1))
        : now.add(const Duration(hours: 1)),
    durationMinutes: 60,
  );
}

void main() {
  late MockMatrixMessageDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockMatrixMessageDataSource();
  });

  LiveLocationBloc buildBloc() =>
      LiveLocationBloc(messageDataSource: mockDataSource);

  // ─────────────────────────────────────────────────
  // Initial state
  // ─────────────────────────────────────────────────

  group('initial state', () {
    test('has correct defaults', () {
      final bloc = buildBloc();
      expect(bloc.state.isSharing, isFalse);
      expect(bloc.state.activeSharings, isEmpty);
      expect(bloc.state.currentRoomId, isNull);
      expect(bloc.state.myLatitude, isNull);
      expect(bloc.state.myLongitude, isNull);
      expect(bloc.state.error, isNull);
      bloc.close();
    });
  });

  // ─────────────────────────────────────────────────
  // UpdateMyLocation
  // ─────────────────────────────────────────────────

  group('UpdateMyLocation', () {
    blocTest<LiveLocationBloc, LiveLocationState>(
      'emits updated latitude and longitude when not sharing',
      build: buildBloc,
      act: (bloc) => bloc.add(const UpdateMyLocation(
        latitude: 31.23,
        longitude: 121.47,
      )),
      expect: () => [
        isA<LiveLocationState>()
            .having((s) => s.myLatitude, 'myLatitude', 31.23)
            .having((s) => s.myLongitude, 'myLongitude', 121.47),
      ],
    );

    blocTest<LiveLocationBloc, LiveLocationState>(
      'calls updateLiveLocation when isSharing is true',
      build: buildBloc,
      seed: () => const LiveLocationState(
        isSharing: true,
        currentRoomId: _kRoomId,
      ),
      setUp: () {
        when(
          () => mockDataSource.updateLiveLocation(
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(const UpdateMyLocation(
        latitude: 31.23,
        longitude: 121.47,
        accuracy: 5.0,
      )),
      expect: () => [
        isA<LiveLocationState>()
            .having((s) => s.myLatitude, 'myLatitude', 31.23),
      ],
      verify: (bloc) {
        verify(
          () => mockDataSource.updateLiveLocation(
            _kRoomId,
            31.23,
            121.47,
            5.0,
          ),
        ).called(1);
      },
    );
  });

  group('ObserveLiveLocationRoom', () {
    blocTest<LiveLocationBloc, LiveLocationState>(
      'subscribes to live locations and syncs snapshot into state',
      build: buildBloc,
      setUp: () {
        when(
          () => mockDataSource.watchLiveLocations(any()),
        ).thenAnswer((_) => Stream.value([_makeLocation()]));
        when(() => mockDataSource.currentUserId).thenReturn('@alice:s');
      },
      act: (bloc) => bloc.add(const ObserveLiveLocationRoom(roomId: _kRoomId)),
      expect: () => [
        isA<LiveLocationState>()
            .having((s) => s.currentRoomId, 'currentRoomId', _kRoomId),
        isA<LiveLocationState>()
            .having((s) => s.activeSharings.containsKey('@alice:s'), 'hasAlice', isTrue)
            .having((s) => s.isSharing, 'isSharing', isTrue),
      ],
      verify: (_) {
        verify(() => mockDataSource.watchLiveLocations(_kRoomId)).called(1);
      },
    );
  });

  // ─────────────────────────────────────────────────
  // LiveLocationUpdated
  // ─────────────────────────────────────────────────

  group('LiveLocationUpdated', () {
    blocTest<LiveLocationBloc, LiveLocationState>(
      'adds non-expired location to activeSharings',
      build: buildBloc,
      act: (bloc) => bloc.add(LiveLocationUpdated(_makeLocation())),
      expect: () => [
        isA<LiveLocationState>().having(
          (s) => s.activeSharings.containsKey('@alice:s'),
          'hasAlice',
          isTrue,
        ),
      ],
    );

    blocTest<LiveLocationBloc, LiveLocationState>(
      'removes expired location from activeSharings',
      build: buildBloc,
      seed: () => LiveLocationState(
        activeSharings: {'@alice:s': _makeLocation()},
      ),
      act: (bloc) =>
          bloc.add(LiveLocationUpdated(_makeLocation(expired: true))),
      expect: () => [
        isA<LiveLocationState>().having(
          (s) => s.activeSharings.containsKey('@alice:s'),
          'hasAlice',
          isFalse,
        ),
      ],
    );

    blocTest<LiveLocationBloc, LiveLocationState>(
      'updates existing location in activeSharings',
      build: buildBloc,
      seed: () => LiveLocationState(
        activeSharings: {'@alice:s': _makeLocation()},
      ),
      act: (bloc) => bloc.add(
        LiveLocationUpdated(_makeLocation(userId: '@alice:s')),
      ),
      // The location is updated (replaced); map still has the key
      expect: () => [
        isA<LiveLocationState>().having(
          (s) => s.activeSharings.length,
          'activeSharings.length',
          1,
        ),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // LiveLocationExpired
  // ─────────────────────────────────────────────────

  group('LiveLocationExpired', () {
    blocTest<LiveLocationBloc, LiveLocationState>(
      'removes userId from activeSharings',
      build: buildBloc,
      seed: () => LiveLocationState(
        activeSharings: {
          '@alice:s': _makeLocation(),
          '@bob:s': _makeLocation(userId: '@bob:s'),
        },
      ),
      act: (bloc) => bloc.add(const LiveLocationExpired('@alice:s')),
      expect: () => [
        isA<LiveLocationState>()
            .having((s) => s.activeSharings.containsKey('@alice:s'), 'hasAlice', isFalse)
            .having((s) => s.activeSharings.containsKey('@bob:s'), 'hasBob', isTrue),
      ],
    );

    blocTest<LiveLocationBloc, LiveLocationState>(
      'emits empty activeSharings when userId not present',
      build: buildBloc,
      // empty activeSharings — handler still creates a new Map instance → state emitted
      act: (bloc) => bloc.add(const LiveLocationExpired('@unknown:s')),
      expect: () => [
        isA<LiveLocationState>()
            .having((s) => s.activeSharings, 'activeSharings', isEmpty),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // StopLiveLocation
  // ─────────────────────────────────────────────────

  group('StopLiveLocation', () {
    blocTest<LiveLocationBloc, LiveLocationState>(
      'emits isSharing=false and clears currentRoomId on success',
      build: buildBloc,
      seed: () => const LiveLocationState(
        isSharing: true,
        currentRoomId: _kRoomId,
      ),
      setUp: () {
        when(
          () => mockDataSource.stopLiveLocation(any()),
        ).thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(const StopLiveLocation(roomId: _kRoomId)),
      expect: () => [
        isA<LiveLocationState>()
            .having((s) => s.isSharing, 'isSharing', isFalse)
            .having((s) => s.currentRoomId, 'currentRoomId', isNull),
      ],
      verify: (bloc) {
        verify(() => mockDataSource.stopLiveLocation(_kRoomId)).called(1);
      },
    );

    blocTest<LiveLocationBloc, LiveLocationState>(
      'emits error when stopLiveLocation throws',
      build: buildBloc,
      seed: () => const LiveLocationState(isSharing: true, currentRoomId: _kRoomId),
      setUp: () {
        when(
          () => mockDataSource.stopLiveLocation(any()),
        ).thenThrow(Exception('Network error'));
      },
      act: (bloc) => bloc.add(const StopLiveLocation(roomId: _kRoomId)),
      expect: () => [
        isA<LiveLocationState>()
            .having((s) => s.error, 'error', isNotNull),
      ],
    );
  });
}
