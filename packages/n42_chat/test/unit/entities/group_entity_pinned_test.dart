import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/group_entity.dart';

void main() {
  group('GroupEntity Pinned Messages', () {
    test('should have empty pinnedEventIds by default', () {
      const group = GroupEntity(
        roomId: '!room:server.com',
        name: 'Test Group',
      );

      expect(group.pinnedEventIds, isEmpty);
      expect(group.hasPinnedMessages, isFalse);
      expect(group.pinnedMessageCount, 0);
    });

    test('should detect hasPinnedMessages when pinnedEventIds is not empty', () {
      const group = GroupEntity(
        roomId: '!room:server.com',
        name: 'Test Group',
        pinnedEventIds: ['\$event1', '\$event2'],
      );

      expect(group.hasPinnedMessages, isTrue);
      expect(group.pinnedMessageCount, 2);
    });

    test('should preserve pinnedEventIds in copyWith without changes', () {
      const original = GroupEntity(
        roomId: '!room:server.com',
        name: 'Test Group',
        pinnedEventIds: ['\$event1', '\$event2'],
      );

      final copy = original.copyWith(name: 'Updated Name');

      expect(copy.pinnedEventIds, ['\$event1', '\$event2']);
      expect(copy.name, 'Updated Name');
      expect(copy.hasPinnedMessages, isTrue);
    });

    test('should update pinnedEventIds with copyWith', () {
      const original = GroupEntity(
        roomId: '!room:server.com',
        name: 'Test Group',
        pinnedEventIds: ['\$event1'],
      );

      final updated = original.copyWith(
        pinnedEventIds: ['\$event1', '\$event2', '\$event3'],
      );

      expect(original.pinnedEventIds.length, 1);
      expect(updated.pinnedEventIds.length, 3);
      expect(updated.pinnedEventIds, ['\$event1', '\$event2', '\$event3']);
    });

    test('should clear pinnedEventIds with copyWith', () {
      const original = GroupEntity(
        roomId: '!room:server.com',
        name: 'Test Group',
        pinnedEventIds: ['\$event1', '\$event2'],
      );

      final cleared = original.copyWith(pinnedEventIds: []);

      expect(cleared.pinnedEventIds, isEmpty);
      expect(cleared.hasPinnedMessages, isFalse);
    });

    test('should include pinnedEventIds in props for equality', () {
      const group1 = GroupEntity(
        roomId: '!room:server.com',
        name: 'Test Group',
        pinnedEventIds: ['\$event1'],
      );

      const group2 = GroupEntity(
        roomId: '!room:server.com',
        name: 'Test Group',
        pinnedEventIds: ['\$event1'],
      );

      const group3 = GroupEntity(
        roomId: '!room:server.com',
        name: 'Test Group',
        pinnedEventIds: ['\$event2'],
      );

      expect(group1, equals(group2));
      expect(group1, isNot(equals(group3)));
    });

    test('should handle empty and null-like scenarios correctly', () {
      const emptyPinned = GroupEntity(
        roomId: '!room:server.com',
        name: 'Test Group',
        pinnedEventIds: [],
      );

      const defaultPinned = GroupEntity(
        roomId: '!room:server.com',
        name: 'Test Group',
      );

      expect(emptyPinned.hasPinnedMessages, isFalse);
      expect(defaultPinned.hasPinnedMessages, isFalse);
      expect(emptyPinned.pinnedEventIds, equals(defaultPinned.pinnedEventIds));
    });

    test('should count pinned messages correctly', () {
      const group = GroupEntity(
        roomId: '!room:server.com',
        name: 'Test Group',
        pinnedEventIds: [
          '\$event1',
          '\$event2',
          '\$event3',
          '\$event4',
          '\$event5',
        ],
      );

      expect(group.pinnedMessageCount, 5);
    });

    test('should maintain order of pinnedEventIds', () {
      const group = GroupEntity(
        roomId: '!room:server.com',
        name: 'Test Group',
        pinnedEventIds: ['\$first', '\$second', '\$third'],
      );

      expect(group.pinnedEventIds[0], '\$first');
      expect(group.pinnedEventIds[1], '\$second');
      expect(group.pinnedEventIds[2], '\$third');
    });

    test('should work with other group properties combined', () {
      const group = GroupEntity(
        roomId: '!room:server.com',
        name: 'Test Group',
        topic: 'Test Topic',
        announcement: 'Test Announcement',
        pinnedEventIds: ['\$pinned1', '\$pinned2'],
        memberCount: 10,
        isEncrypted: true,
        isPublic: false,
        myRole: GroupRole.admin,
        canInvite: true,
        canKick: true,
        canChangeSettings: true,
      );

      expect(group.hasPinnedMessages, isTrue);
      expect(group.pinnedMessageCount, 2);
      expect(group.topic, 'Test Topic');
      expect(group.announcement, 'Test Announcement');
      expect(group.memberCount, 10);
      expect(group.isEncrypted, isTrue);
      expect(group.isPublic, isFalse);
      expect(group.myRole, GroupRole.admin);
    });
  });
}
