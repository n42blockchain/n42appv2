import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/space_entity.dart';

void main() {
  final testCreatedAt = DateTime(2024, 1, 1, 12, 0);

  SpaceEntity createTestSpace({
    String id = '!space:example.com',
    String name = 'Test Space',
    String? description,
    String? avatarUrl,
    SpaceType type = SpaceType.public,
    String creatorId = '@creator:example.com',
    int memberCount = 0,
    List<SpaceChild> children = const [],
    bool isJoined = false,
    List<String> topics = const [],
    DateTime? createdAt,
    String? parentSpaceId,
  }) {
    return SpaceEntity(
      id: id,
      name: name,
      description: description,
      avatarUrl: avatarUrl,
      type: type,
      creatorId: creatorId,
      memberCount: memberCount,
      children: children,
      isJoined: isJoined,
      topics: topics,
      createdAt: createdAt ?? testCreatedAt,
      parentSpaceId: parentSpaceId,
    );
  }

  group('SpaceEntity', () {
    group('creation', () {
      test('should create with required parameters', () {
        final space = createTestSpace();

        expect(space.id, '!space:example.com');
        expect(space.name, 'Test Space');
        expect(space.creatorId, '@creator:example.com');
        expect(space.createdAt, testCreatedAt);
      });

      test('should have correct default values', () {
        final space = createTestSpace();

        expect(space.description, null);
        expect(space.avatarUrl, null);
        expect(space.type, SpaceType.public);
        expect(space.memberCount, 0);
        expect(space.children, isEmpty);
        expect(space.isJoined, false);
        expect(space.topics, isEmpty);
        expect(space.parentSpaceId, null);
      });

      test('should create with all parameters', () {
        final space = createTestSpace(
          description: 'A test space',
          avatarUrl: 'mxc://example.com/avatar',
          type: SpaceType.private,
          memberCount: 42,
          isJoined: true,
          topics: ['tech', 'flutter'],
          parentSpaceId: '!parent:example.com',
        );

        expect(space.description, 'A test space');
        expect(space.avatarUrl, 'mxc://example.com/avatar');
        expect(space.type, SpaceType.private);
        expect(space.memberCount, 42);
        expect(space.isJoined, true);
        expect(space.topics, ['tech', 'flutter']);
        expect(space.parentSpaceId, '!parent:example.com');
      });
    });

    group('channelCount', () {
      test('should return 0 when no children', () {
        final space = createTestSpace();
        expect(space.channelCount, 0);
      });

      test('should count only channel type children', () {
        final space = createTestSpace(
          children: const [
            SpaceChild(
              roomId: '!channel1:example.com',
              name: 'Channel 1',
              type: SpaceChildType.channel,
            ),
            SpaceChild(
              roomId: '!channel2:example.com',
              name: 'Channel 2',
              type: SpaceChildType.channel,
            ),
            SpaceChild(
              roomId: '!sub:example.com',
              name: 'Sub Space',
              type: SpaceChildType.subSpace,
            ),
          ],
        );

        expect(space.channelCount, 2);
      });

      test('should return 0 when only subSpaces exist', () {
        final space = createTestSpace(
          children: const [
            SpaceChild(
              roomId: '!sub:example.com',
              name: 'Sub Space',
              type: SpaceChildType.subSpace,
            ),
          ],
        );

        expect(space.channelCount, 0);
      });
    });

    group('subSpaceCount', () {
      test('should return 0 when no children', () {
        final space = createTestSpace();
        expect(space.subSpaceCount, 0);
      });

      test('should count only subSpace type children', () {
        final space = createTestSpace(
          children: const [
            SpaceChild(
              roomId: '!channel1:example.com',
              name: 'Channel 1',
              type: SpaceChildType.channel,
            ),
            SpaceChild(
              roomId: '!sub1:example.com',
              name: 'Sub Space 1',
              type: SpaceChildType.subSpace,
            ),
            SpaceChild(
              roomId: '!sub2:example.com',
              name: 'Sub Space 2',
              type: SpaceChildType.subSpace,
            ),
          ],
        );

        expect(space.subSpaceCount, 2);
      });

      test('should return 0 when only channels exist', () {
        final space = createTestSpace(
          children: const [
            SpaceChild(
              roomId: '!channel1:example.com',
              name: 'Channel',
              type: SpaceChildType.channel,
            ),
          ],
        );

        expect(space.subSpaceCount, 0);
      });
    });

    group('isSubSpace', () {
      test('should return false when parentSpaceId is null', () {
        final space = createTestSpace();
        expect(space.isSubSpace, false);
      });

      test('should return true when parentSpaceId is set', () {
        final space = createTestSpace(parentSpaceId: '!parent:example.com');
        expect(space.isSubSpace, true);
      });
    });

    group('copyWith', () {
      test('should create copy with updated name', () {
        final original = createTestSpace(name: 'Original');
        final copy = original.copyWith(name: 'Updated');

        expect(copy.name, 'Updated');
        expect(copy.id, original.id);
        expect(copy.creatorId, original.creatorId);
        expect(copy.createdAt, original.createdAt);
      });

      test('should create copy with updated memberCount', () {
        final original = createTestSpace(memberCount: 10);
        final copy = original.copyWith(memberCount: 20);

        expect(copy.memberCount, 20);
        expect(copy.name, original.name);
      });

      test('should create copy with updated type', () {
        final original = createTestSpace(type: SpaceType.public);
        final copy = original.copyWith(type: SpaceType.private);

        expect(copy.type, SpaceType.private);
      });

      test('should create copy with updated isJoined', () {
        final original = createTestSpace(isJoined: false);
        final copy = original.copyWith(isJoined: true);

        expect(copy.isJoined, true);
      });

      test('should create copy with updated children', () {
        final original = createTestSpace();
        const newChildren = [
          SpaceChild(
            roomId: '!new:example.com',
            name: 'New Channel',
            type: SpaceChildType.channel,
          ),
        ];
        final copy = original.copyWith(children: newChildren);

        expect(copy.children.length, 1);
        expect(copy.children.first.name, 'New Channel');
      });

      test('should create copy with updated topics', () {
        final original = createTestSpace(topics: ['old']);
        final copy = original.copyWith(topics: ['new', 'topics']);

        expect(copy.topics, ['new', 'topics']);
      });

      test('should preserve id, creatorId, createdAt, parentSpaceId', () {
        final original = createTestSpace(
          id: '!keep:example.com',
          creatorId: '@keepCreator:example.com',
          parentSpaceId: '!parent:example.com',
        );
        final copy = original.copyWith(name: 'Changed');

        expect(copy.id, '!keep:example.com');
        expect(copy.creatorId, '@keepCreator:example.com');
        expect(copy.parentSpaceId, '!parent:example.com');
        expect(copy.createdAt, testCreatedAt);
      });

      test('should keep original values when not overridden', () {
        final original = createTestSpace(
          name: 'Keep',
          description: 'Keep desc',
          memberCount: 42,
          isJoined: true,
          topics: ['keep'],
        );
        final copy = original.copyWith();

        expect(copy.name, 'Keep');
        expect(copy.description, 'Keep desc');
        expect(copy.memberCount, 42);
        expect(copy.isJoined, true);
        expect(copy.topics, ['keep']);
      });
    });

    group('Equatable', () {
      test('should be equal with same properties', () {
        final space1 = createTestSpace(name: 'Same');
        final space2 = createTestSpace(name: 'Same');

        expect(space1, equals(space2));
      });

      test('should not be equal with different properties', () {
        final space1 = createTestSpace(name: 'One');
        final space2 = createTestSpace(name: 'Two');

        expect(space1, isNot(equals(space2)));
      });

      test('should not be equal with different id', () {
        final space1 = createTestSpace(id: '!a:example.com');
        final space2 = createTestSpace(id: '!b:example.com');

        expect(space1, isNot(equals(space2)));
      });
    });
  });

  group('SpaceChild', () {
    group('creation', () {
      test('should create with required parameters', () {
        const child = SpaceChild(
          roomId: '!room:example.com',
          name: 'Test Channel',
          type: SpaceChildType.channel,
        );

        expect(child.roomId, '!room:example.com');
        expect(child.name, 'Test Channel');
        expect(child.type, SpaceChildType.channel);
      });

      test('should have correct default values', () {
        const child = SpaceChild(
          roomId: '!room:example.com',
          name: 'Test',
          type: SpaceChildType.channel,
        );

        expect(child.avatarUrl, null);
        expect(child.description, null);
        expect(child.memberCount, 0);
        expect(child.order, 0);
        expect(child.isSuggested, false);
      });

      test('should create with all parameters', () {
        const child = SpaceChild(
          roomId: '!room:example.com',
          name: 'Full Channel',
          avatarUrl: 'mxc://example.com/avatar',
          type: SpaceChildType.channel,
          description: 'A channel description',
          memberCount: 150,
          order: 5,
          isSuggested: true,
        );

        expect(child.avatarUrl, 'mxc://example.com/avatar');
        expect(child.description, 'A channel description');
        expect(child.memberCount, 150);
        expect(child.order, 5);
        expect(child.isSuggested, true);
      });
    });

    group('SpaceChildType', () {
      test('should create channel type', () {
        const child = SpaceChild(
          roomId: '!room:example.com',
          name: 'Channel',
          type: SpaceChildType.channel,
        );
        expect(child.type, SpaceChildType.channel);
      });

      test('should create subSpace type', () {
        const child = SpaceChild(
          roomId: '!room:example.com',
          name: 'Sub Space',
          type: SpaceChildType.subSpace,
        );
        expect(child.type, SpaceChildType.subSpace);
      });
    });

    group('Equatable', () {
      test('should be equal with same properties', () {
        const child1 = SpaceChild(
          roomId: '!room:example.com',
          name: 'Same',
          type: SpaceChildType.channel,
        );
        const child2 = SpaceChild(
          roomId: '!room:example.com',
          name: 'Same',
          type: SpaceChildType.channel,
        );

        expect(child1, equals(child2));
      });

      test('should not be equal with different roomId', () {
        const child1 = SpaceChild(
          roomId: '!room1:example.com',
          name: 'Same',
          type: SpaceChildType.channel,
        );
        const child2 = SpaceChild(
          roomId: '!room2:example.com',
          name: 'Same',
          type: SpaceChildType.channel,
        );

        expect(child1, isNot(equals(child2)));
      });

      test('should not be equal with different type', () {
        const child1 = SpaceChild(
          roomId: '!room:example.com',
          name: 'Same',
          type: SpaceChildType.channel,
        );
        const child2 = SpaceChild(
          roomId: '!room:example.com',
          name: 'Same',
          type: SpaceChildType.subSpace,
        );

        expect(child1, isNot(equals(child2)));
      });

      test('should not be equal with different order', () {
        const child1 = SpaceChild(
          roomId: '!room:example.com',
          name: 'Same',
          type: SpaceChildType.channel,
          order: 1,
        );
        const child2 = SpaceChild(
          roomId: '!room:example.com',
          name: 'Same',
          type: SpaceChildType.channel,
          order: 2,
        );

        expect(child1, isNot(equals(child2)));
      });
    });
  });

  group('SpaceType', () {
    test('should have public and private types', () {
      expect(SpaceType.values, contains(SpaceType.public));
      expect(SpaceType.values, contains(SpaceType.private));
      expect(SpaceType.values.length, 2);
    });
  });

  group('SpaceChildType', () {
    test('should have channel and subSpace types', () {
      expect(SpaceChildType.values, contains(SpaceChildType.channel));
      expect(SpaceChildType.values, contains(SpaceChildType.subSpace));
      expect(SpaceChildType.values.length, 2);
    });
  });
}
