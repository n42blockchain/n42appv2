import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_space_datasource.dart';
import 'package:n42_chat/src/data/repositories/space_repository_impl.dart';
import 'package:n42_chat/src/domain/entities/space_entity.dart';

class MockMatrixSpaceDataSource extends Mock implements MatrixSpaceDataSource {}

class MockRoom extends Mock implements matrix.Room {}

class FakeSpaceRoomsChunk extends Fake implements matrix.SpaceRoomsChunk$2 {}

void main() {
  late MockMatrixSpaceDataSource mockDataSource;
  late SpaceRepositoryImpl repository;
  late MockRoom mockRoom;

  const spaceId = '!space:example.com';

  SpaceEntity buildSpace() {
    return SpaceEntity(
      id: spaceId,
      name: 'N42 Space',
      creatorId: '@creator:example.com',
      createdAt: DateTime(2026, 3, 20),
    );
  }

  matrix.GetSpaceHierarchyResponse buildHierarchy({
    String? nextBatch,
    required List<Map<String, Object?>> rooms,
  }) {
    final json = <String, Object?>{'rooms': rooms};
    if (nextBatch != null) {
      json['next_batch'] = nextBatch;
    }
    return matrix.GetSpaceHierarchyResponse.fromJson(json);
  }

  Map<String, Object?> roomChunk({
    required String roomId,
    String? name,
    String? topic,
    String? roomType,
  }) {
    return {
      'room_id': roomId,
      'name': name,
      'topic': topic,
      'room_type': roomType,
      'num_joined_members': 12,
      'guest_can_join': false,
      'world_readable': false,
      'children_state': <Object?>[],
    };
  }

  setUp(() {
    mockDataSource = MockMatrixSpaceDataSource();
    repository = SpaceRepositoryImpl(mockDataSource);
    mockRoom = MockRoom();
  });

  setUpAll(() {
    registerFallbackValue(FakeSpaceRoomsChunk());
  });

  group('getSpaceInviteLink', () {
    test('delegates to datasource', () async {
      const link = 'https://matrix.to/#/%23n42%3Aexample.com?via=example.com';
      when(() => mockDataSource.getSpaceInviteLink(spaceId)).thenReturn(link);

      final result = await repository.getSpaceInviteLink(spaceId);

      expect(result, link);
      verify(() => mockDataSource.getSpaceInviteLink(spaceId)).called(1);
    });
  });

  group('getSpaceDetail', () {
    test('paginates hierarchy until next_batch is exhausted', () async {
      when(() => mockDataSource.getSpace(spaceId)).thenReturn(mockRoom);
      when(
        () => mockDataSource.roomToSpaceEntity(mockRoom),
      ).thenReturn(buildSpace());

      final page1 = buildHierarchy(
        nextBatch: 'page-2',
        rooms: [
          roomChunk(roomId: spaceId, roomType: 'm.space', name: 'N42 Space'),
          roomChunk(roomId: '!c1:example.com', name: 'General'),
          roomChunk(roomId: '!c2:example.com', name: 'Alpha'),
        ],
      );
      final page2 = buildHierarchy(
        rooms: [
          roomChunk(roomId: spaceId, roomType: 'm.space', name: 'N42 Space'),
          roomChunk(roomId: '!c3:example.com', name: 'Research'),
        ],
      );

      when(
        () => mockDataSource.getSpaceHierarchy(
          spaceId,
          maxDepth: 1,
          limit: 50,
          from: null,
        ),
      ).thenAnswer((_) async => page1);
      when(
        () => mockDataSource.getSpaceHierarchy(
          spaceId,
          maxDepth: 1,
          limit: 50,
          from: 'page-2',
        ),
      ).thenAnswer((_) async => page2);

      when(() => mockDataSource.hierarchyRoomToChild(any())).thenAnswer((
        invocation,
      ) {
        final chunk =
            invocation.positionalArguments.first as matrix.SpaceRoomsChunk$2;
        return SpaceChild(
          roomId: chunk.roomId,
          name: chunk.name ?? chunk.roomId,
          type: chunk.roomType == 'm.space'
              ? SpaceChildType.subSpace
              : SpaceChildType.channel,
        );
      });

      final result = await repository.getSpaceDetail(spaceId);

      expect(result, isNotNull);
      expect(result!.children.map((child) => child.roomId).toList(), [
        '!c1:example.com',
        '!c2:example.com',
        '!c3:example.com',
      ]);
      verify(
        () => mockDataSource.getSpaceHierarchy(
          spaceId,
          maxDepth: 1,
          limit: 50,
          from: null,
        ),
      ).called(1);
      verify(
        () => mockDataSource.getSpaceHierarchy(
          spaceId,
          maxDepth: 1,
          limit: 50,
          from: 'page-2',
        ),
      ).called(1);
    });
  });
}
