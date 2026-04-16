import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/domain/entities/group_album_entity.dart';
import 'package:n42_chat/src/domain/repositories/message_repository.dart';
import 'package:n42_chat/src/presentation/blocs/group_album/group_album_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/group_album/group_album_event.dart';
import 'package:n42_chat/src/presentation/blocs/group_album/group_album_state.dart';

class MockMessageRepository extends Mock implements IMessageRepository {}

const _kRoomId = '!room:s';

AlbumMediaEntity _makeMedia({
  String eventId = 'e1',
  AlbumMediaType type = AlbumMediaType.image,
  DateTime? sentAt,
}) =>
    AlbumMediaEntity(
      eventId: eventId,
      roomId: _kRoomId,
      url: 'mxc://s/$eventId',
      type: type,
      mimeType: type == AlbumMediaType.video ? 'video/mp4' : 'image/jpeg',
      size: 1024,
      senderId: '@alice:s',
      senderName: 'Alice',
      sentAt: sentAt ?? DateTime(2025, 6, 1, 12),
    );

void main() {
  late MockMessageRepository mockRepo;

  setUp(() {
    mockRepo = MockMessageRepository();
  });

  GroupAlbumBloc buildBloc() =>
      GroupAlbumBloc(messageRepository: mockRepo);

  // ─────────────────────────────────────────────────
  // Initial state
  // ─────────────────────────────────────────────────

  group('initial state', () {
    test('GroupAlbumState.initial() has isLoading=true and empty media', () {
      final bloc = buildBloc();
      expect(bloc.state.isLoading, isTrue);
      expect(bloc.state.media, isEmpty);
      expect(bloc.state.roomId, isNull);
      expect(bloc.state.error, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // LoadGroupAlbum
  // ─────────────────────────────────────────────────

  group('LoadGroupAlbum', () {
    blocTest<GroupAlbumBloc, GroupAlbumState>(
      'emits [loading+roomId, loaded] on success with media',
      build: buildBloc,
      setUp: () {
        when(
          () => mockRepo.getRoomMedia(
            any(),
            limit: any(named: 'limit'),
            filter: any(named: 'filter'),
            beforeEventId: any(named: 'beforeEventId'),
          ),
        ).thenAnswer((_) async => [_makeMedia(), _makeMedia(eventId: 'e2')]);
      },
      act: (bloc) => bloc.add(const LoadGroupAlbum(roomId: _kRoomId)),
      expect: () => [
        isA<GroupAlbumState>()
            .having((s) => s.roomId, 'roomId', _kRoomId)
            .having((s) => s.isLoading, 'isLoading', isTrue),
        isA<GroupAlbumState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.media.length, 'media.length', 2)
            .having((s) => s.error, 'error', isNull),
      ],
    );

    blocTest<GroupAlbumBloc, GroupAlbumState>(
      'emits [loading+roomId, error] on failure',
      build: buildBloc,
      setUp: () {
        when(
          () => mockRepo.getRoomMedia(
            any(),
            limit: any(named: 'limit'),
            filter: any(named: 'filter'),
            beforeEventId: any(named: 'beforeEventId'),
          ),
        ).thenThrow(Exception('DB error'));
      },
      act: (bloc) => bloc.add(const LoadGroupAlbum(roomId: _kRoomId)),
      expect: () => [
        isA<GroupAlbumState>()
            .having((s) => s.roomId, 'roomId', _kRoomId)
            .having((s) => s.isLoading, 'isLoading', isTrue),
        isA<GroupAlbumState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.error, 'error', isNotNull)
            .having((s) => s.media, 'media', isEmpty),
      ],
    );

    blocTest<GroupAlbumBloc, GroupAlbumState>(
      'hasMore=false when returned media count < limit',
      build: buildBloc,
      setUp: () {
        when(
          () => mockRepo.getRoomMedia(
            any(),
            limit: any(named: 'limit'),
            filter: any(named: 'filter'),
            beforeEventId: any(named: 'beforeEventId'),
          ),
        ).thenAnswer((_) async => [_makeMedia()]);
      },
      act: (bloc) => bloc.add(const LoadGroupAlbum(roomId: _kRoomId)),
      expect: () => [
        isA<GroupAlbumState>().having((s) => s.isLoading, 'isLoading', isTrue),
        isA<GroupAlbumState>()
            .having((s) => s.hasMore, 'hasMore', isFalse),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // ChangeAlbumFilter
  // ─────────────────────────────────────────────────

  group('ChangeAlbumFilter', () {
    blocTest<GroupAlbumBloc, GroupAlbumState>(
      'emits state with updated filter',
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const ChangeAlbumFilter(AlbumFilter.imagesOnly)),
      expect: () => [
        isA<GroupAlbumState>().having(
          (s) => s.filter.mediaType,
          'filter.mediaType',
          AlbumMediaType.image,
        ),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // LoadMoreAlbum guard conditions
  // ─────────────────────────────────────────────────

  group('LoadMoreAlbum', () {
    blocTest<GroupAlbumBloc, GroupAlbumState>(
      'does nothing when roomId is null',
      build: buildBloc,
      // initial state has roomId=null
      act: (bloc) => bloc.add(const LoadMoreAlbum()),
      expect: () => [],
    );

    blocTest<GroupAlbumBloc, GroupAlbumState>(
      'does nothing when hasMore is false',
      build: buildBloc,
      seed: () => const GroupAlbumState(
        roomId: _kRoomId,
        hasMore: false,
      ),
      act: (bloc) => bloc.add(const LoadMoreAlbum()),
      expect: () => [],
    );

    blocTest<GroupAlbumBloc, GroupAlbumState>(
      'loads more items when conditions are met',
      build: buildBloc,
      seed: () => GroupAlbumState(
        roomId: _kRoomId,
        hasMore: true,
        media: [_makeMedia()],
      ),
      setUp: () {
        when(
          () => mockRepo.getRoomMedia(
            any(),
            limit: any(named: 'limit'),
            filter: any(named: 'filter'),
            beforeEventId: any(named: 'beforeEventId'),
          ),
        ).thenAnswer((_) async => [_makeMedia(eventId: 'e2')]);
      },
      act: (bloc) => bloc.add(const LoadMoreAlbum()),
      expect: () => [
        isA<GroupAlbumState>()
            .having((s) => s.isLoadingMore, 'isLoadingMore', isTrue),
        isA<GroupAlbumState>()
            .having((s) => s.isLoadingMore, 'isLoadingMore', isFalse)
            .having((s) => s.media.length, 'media.length', 2),
      ],
    );
  });

  // ─────────────────────────────────────────────────
  // GroupAlbumState helpers
  // ─────────────────────────────────────────────────

  group('GroupAlbumState.isEmpty / filteredMedia', () {
    test('isEmpty returns true for empty media', () {
      const state = GroupAlbumState();
      expect(state.isEmpty, isTrue);
    });

    test('filteredMedia with no filter returns all', () {
      final state = GroupAlbumState(media: [_makeMedia(), _makeMedia(eventId: 'e2')]);
      expect(state.filteredMedia.length, 2);
    });

    test('filteredMedia with imagesOnly filter returns only images', () {
      final state = GroupAlbumState(
        media: [
          _makeMedia(type: AlbumMediaType.image),
          _makeMedia(eventId: 'v1', type: AlbumMediaType.video),
        ],
        filter: AlbumFilter.imagesOnly,
      );
      expect(state.filteredMedia.length, 1);
      expect(state.filteredMedia.first.isImage, isTrue);
    });
  });
}
