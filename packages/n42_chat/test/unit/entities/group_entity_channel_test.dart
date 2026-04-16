import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/group_entity.dart';

void main() {
  group('GroupType', () {
    test('should have all expected types', () {
      expect(GroupType.values, contains(GroupType.group));
      expect(GroupType.values, contains(GroupType.channel));
      expect(GroupType.values, contains(GroupType.superGroup));
      expect(GroupType.values.length, 3);
    });
  });

  group('JoinRule', () {
    test('should have all expected rules', () {
      expect(JoinRule.values, contains(JoinRule.public));
      expect(JoinRule.values, contains(JoinRule.invite));
      expect(JoinRule.values, contains(JoinRule.knock));
      expect(JoinRule.values, contains(JoinRule.restricted));
      expect(JoinRule.values.length, 4);
    });
  });

  group('GroupEntity channel features', () {
    test('should create basic group with default type', () {
      const group = GroupEntity(
        roomId: '!room:example.com',
        name: 'Test Group',
      );

      expect(group.groupType, GroupType.group);
      expect(group.isChannel, false);
      expect(group.isSuperGroup, false);
      expect(group.membersCanSpeak, true);
      expect(group.showMemberList, true);
    });

    test('should create channel with factory', () {
      final channel = GroupEntity.channel(
        roomId: '!channel:example.com',
        name: 'News Channel',
        topic: 'Breaking news updates',
        subscriberCount: 10000,
        channelUsername: 'news',
        isVerified: true,
        category: 'News',
      );

      expect(channel.groupType, GroupType.channel);
      expect(channel.isChannel, true);
      expect(channel.isSuperGroup, false);
      expect(channel.subscriberCount, 10000);
      expect(channel.channelUsername, 'news');
      expect(channel.channelLink, 'https://n42.app/news');
      expect(channel.isVerified, true);
      expect(channel.category, 'News');
      expect(channel.membersCanSpeak, false);
      expect(channel.showMemberList, false);
      expect(channel.joinRule, JoinRule.public);
    });

    test('should create super group with factory', () {
      final superGroup = GroupEntity.superGroup(
        roomId: '!supergroup:example.com',
        name: 'Large Community',
        memberCount: 50000,
        slowModeInterval: 30,
      );

      expect(superGroup.groupType, GroupType.superGroup);
      expect(superGroup.isChannel, false);
      expect(superGroup.isSuperGroup, true);
      expect(superGroup.memberCount, 50000);
      expect(superGroup.slowModeInterval, 30);
      expect(superGroup.membersCanSpeak, true);
      expect(superGroup.showMemberList, true);
    });

    test('channelLink should be null when no username', () {
      const channel = GroupEntity(
        roomId: '!channel:example.com',
        name: 'Private Channel',
        groupType: GroupType.channel,
      );

      expect(channel.channelLink, null);
    });

    test('copyWith should preserve channel properties', () {
      final channel = GroupEntity.channel(
        roomId: '!channel:example.com',
        name: 'Original',
        subscriberCount: 1000,
        channelUsername: 'original',
      );

      final updated = channel.copyWith(
        name: 'Updated',
        subscriberCount: 2000,
      );

      expect(updated.name, 'Updated');
      expect(updated.subscriberCount, 2000);
      expect(updated.channelUsername, 'original');
      expect(updated.groupType, GroupType.channel);
    });

    test('slow mode interval should work correctly', () {
      const group = GroupEntity(
        roomId: '!room:example.com',
        name: 'Slow Mode Group',
        slowModeInterval: 60,
      );

      expect(group.slowModeInterval, 60);

      final updated = group.copyWith(slowModeInterval: 0);
      expect(updated.slowModeInterval, 0);
    });

    test('join rule should be configurable', () {
      const group = GroupEntity(
        roomId: '!room:example.com',
        name: 'Knock Group',
        joinRule: JoinRule.knock,
      );

      expect(group.joinRule, JoinRule.knock);
    });
  });
}
