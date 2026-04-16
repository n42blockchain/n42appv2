// Tests for group_entity.dart — enums, GroupMember and GroupEntity.
// Pure Equatable domain classes — no platform dependencies.
// Covers: GroupRole/MembershipStatus/GroupType/JoinRule enums,
// GroupMember (username, initials, isOwner/isAdmin, copyWith, equality),
// GroupEntity (isChannel, hasPinnedMessages, owner/admins/normalMembers,
// factory constructors, copyWith, equality).

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/group_entity.dart';

void main() {
  // ─────────────────────────────────────────────────
  // Enums
  // ─────────────────────────────────────────────────

  group('GroupRole enum', () {
    test('has owner, admin, member values', () {
      expect(GroupRole.values, containsAll([
        GroupRole.owner, GroupRole.admin, GroupRole.member,
      ]));
    });

    test('three values total', () {
      expect(GroupRole.values.length, 3);
    });
  });

  group('MembershipStatus enum', () {
    test('has joined and invited values', () {
      expect(MembershipStatus.values, containsAll([
        MembershipStatus.joined, MembershipStatus.invited,
      ]));
    });

    test('two values total', () {
      expect(MembershipStatus.values.length, 2);
    });
  });

  group('GroupType enum', () {
    test('has group, channel, superGroup values', () {
      expect(GroupType.values, containsAll([
        GroupType.group, GroupType.channel, GroupType.superGroup,
      ]));
    });

    test('three values total', () {
      expect(GroupType.values.length, 3);
    });
  });

  group('JoinRule enum', () {
    test('has public, invite, knock, restricted', () {
      expect(JoinRule.values, containsAll([
        JoinRule.public, JoinRule.invite, JoinRule.knock, JoinRule.restricted,
      ]));
    });

    test('four values total', () {
      expect(JoinRule.values.length, 4);
    });
  });

  // ─────────────────────────────────────────────────
  // GroupMember
  // ─────────────────────────────────────────────────

  group('GroupMember constructor', () {
    const m = GroupMember(userId: '@alice:server', displayName: 'Alice');

    test('stores userId and displayName', () {
      expect(m.userId, '@alice:server');
      expect(m.displayName, 'Alice');
    });

    test('avatarUrl defaults to null', () {
      expect(m.avatarUrl, isNull);
    });

    test('role defaults to member', () {
      expect(m.role, GroupRole.member);
    });

    test('powerLevel defaults to 0', () {
      expect(m.powerLevel, 0);
    });

    test('isOnline defaults to false', () {
      expect(m.isOnline, isFalse);
    });

    test('joinedAt defaults to null', () {
      expect(m.joinedAt, isNull);
    });

    test('membershipStatus defaults to joined', () {
      expect(m.membershipStatus, MembershipStatus.joined);
    });
  });

  group('GroupMember.username', () {
    test('extracts local part from @user:server format', () {
      const m = GroupMember(userId: '@alice:matrix.org', displayName: 'Alice');
      expect(m.username, 'alice');
    });

    test('strips @ without server', () {
      const m = GroupMember(userId: '@bob', displayName: 'Bob');
      expect(m.username, 'bob');
    });

    test('returns userId unchanged when no @ prefix', () {
      const m = GroupMember(userId: 'plainuser', displayName: 'P');
      expect(m.username, 'plainuser');
    });
  });

  group('GroupMember.initials', () {
    test('returns ? for empty displayName', () {
      const m = GroupMember(userId: '@u:s', displayName: '');
      expect(m.initials, '?');
    });

    test('returns first two chars (uppercase) for single word', () {
      const m = GroupMember(userId: '@u:s', displayName: 'alice');
      expect(m.initials, 'AL');
    });

    test('returns first letter of each of first two words', () {
      const m = GroupMember(userId: '@u:s', displayName: 'Alice Bob');
      expect(m.initials, 'AB');
    });

    test('single char name returns single char', () {
      const m = GroupMember(userId: '@u:s', displayName: 'X');
      expect(m.initials, 'X');
    });

    test('three-word name takes first two words only', () {
      const m = GroupMember(userId: '@u:s', displayName: 'John Paul Smith');
      expect(m.initials, 'JP');
    });
  });

  group('GroupMember.isOwner and isAdmin', () {
    test('isOwner is true when role is owner', () {
      const m = GroupMember(userId: '@u:s', displayName: 'U', role: GroupRole.owner);
      expect(m.isOwner, isTrue);
    });

    test('isOwner is true when powerLevel >= 100', () {
      const m = GroupMember(userId: '@u:s', displayName: 'U', powerLevel: 100);
      expect(m.isOwner, isTrue);
    });

    test('isOwner is false for regular member', () {
      const m = GroupMember(userId: '@u:s', displayName: 'U');
      expect(m.isOwner, isFalse);
    });

    test('isAdmin is true when role is admin', () {
      const m = GroupMember(userId: '@u:s', displayName: 'U', role: GroupRole.admin);
      expect(m.isAdmin, isTrue);
    });

    test('isAdmin is true when powerLevel >= 50', () {
      const m = GroupMember(userId: '@u:s', displayName: 'U', powerLevel: 50);
      expect(m.isAdmin, isTrue);
    });

    // GroupMember.isAdmin = role == GroupRole.admin || powerLevel >= 50.
    // An owner-role member with default powerLevel=0 does NOT satisfy isAdmin.
    test('isAdmin is false for owner-role member with default powerLevel', () {
      const m = GroupMember(userId: '@u:s', displayName: 'U', role: GroupRole.owner);
      expect(m.isAdmin, isFalse);
    });

    test('isAdmin is true for owner-role member with powerLevel >= 50', () {
      const m = GroupMember(userId: '@u:s', displayName: 'U', role: GroupRole.owner, powerLevel: 50);
      expect(m.isAdmin, isTrue);
    });

    test('isAdmin is false for regular member with power < 50', () {
      const m = GroupMember(userId: '@u:s', displayName: 'U', powerLevel: 0);
      expect(m.isAdmin, isFalse);
    });
  });

  group('GroupMember.isInvited', () {
    test('true when membershipStatus is invited', () {
      const m = GroupMember(
        userId: '@u:s', displayName: 'U',
        membershipStatus: MembershipStatus.invited,
      );
      expect(m.isInvited, isTrue);
    });

    test('false when membershipStatus is joined', () {
      const m = GroupMember(userId: '@u:s', displayName: 'U');
      expect(m.isInvited, isFalse);
    });
  });

  group('GroupMember.copyWith', () {
    const base = GroupMember(userId: '@alice:s', displayName: 'Alice');

    test('replaces displayName', () {
      expect(base.copyWith(displayName: 'Alicia').displayName, 'Alicia');
    });

    test('replaces role', () {
      expect(base.copyWith(role: GroupRole.admin).role, GroupRole.admin);
    });

    test('replaces isOnline', () {
      expect(base.copyWith(isOnline: true).isOnline, isTrue);
    });

    test('replaces powerLevel', () {
      expect(base.copyWith(powerLevel: 75).powerLevel, 75);
    });

    test('original unchanged after copyWith', () {
      base.copyWith(role: GroupRole.owner);
      expect(base.role, GroupRole.member);
    });
  });

  group('GroupMember equality', () {
    test('same fields → equal', () {
      const a = GroupMember(userId: '@u:s', displayName: 'U');
      const b = GroupMember(userId: '@u:s', displayName: 'U');
      expect(a, equals(b));
    });

    test('different userId → not equal', () {
      const a = GroupMember(userId: '@a:s', displayName: 'A');
      const b = GroupMember(userId: '@b:s', displayName: 'A');
      expect(a, isNot(equals(b)));
    });

    test('different role → not equal', () {
      const a = GroupMember(userId: '@u:s', displayName: 'U', role: GroupRole.admin);
      const b = GroupMember(userId: '@u:s', displayName: 'U', role: GroupRole.member);
      expect(a, isNot(equals(b)));
    });
  });

  // ─────────────────────────────────────────────────
  // GroupEntity
  // ─────────────────────────────────────────────────

  group('GroupEntity constructor defaults', () {
    const g = GroupEntity(roomId: '!room:s', name: 'Dev Team');

    test('stores roomId and name', () {
      expect(g.roomId, '!room:s');
      expect(g.name, 'Dev Team');
    });

    test('avatarUrl defaults to null', () {
      expect(g.avatarUrl, isNull);
    });

    test('topic defaults to null', () {
      expect(g.topic, isNull);
    });

    test('pinnedEventIds defaults to empty', () {
      expect(g.pinnedEventIds, isEmpty);
    });

    test('memberCount defaults to 0', () {
      expect(g.memberCount, 0);
    });

    test('members defaults to empty', () {
      expect(g.members, isEmpty);
    });

    test('isEncrypted defaults to false', () {
      expect(g.isEncrypted, isFalse);
    });

    test('isPublic defaults to false', () {
      expect(g.isPublic, isFalse);
    });

    test('myRole defaults to member', () {
      expect(g.myRole, GroupRole.member);
    });

    test('groupType defaults to group', () {
      expect(g.groupType, GroupType.group);
    });

    test('joinRule defaults to invite', () {
      expect(g.joinRule, JoinRule.invite);
    });

    test('slowModeInterval defaults to 0', () {
      expect(g.slowModeInterval, 0);
    });

    test('isVerified defaults to false', () {
      expect(g.isVerified, isFalse);
    });
  });

  group('GroupEntity computed getters', () {
    test('isChannel is true when groupType is channel', () {
      const g = GroupEntity(
        roomId: '!r:s', name: 'N', groupType: GroupType.channel);
      expect(g.isChannel, isTrue);
    });

    test('isSuperGroup is true when groupType is superGroup', () {
      const g = GroupEntity(
        roomId: '!r:s', name: 'N', groupType: GroupType.superGroup);
      expect(g.isSuperGroup, isTrue);
    });

    test('isChannel is false for regular group', () {
      const g = GroupEntity(roomId: '!r:s', name: 'N');
      expect(g.isChannel, isFalse);
    });

    test('isOwner is true when myRole is owner', () {
      const g = GroupEntity(
        roomId: '!r:s', name: 'N', myRole: GroupRole.owner);
      expect(g.isOwner, isTrue);
    });

    test('isAdmin is true when myRole is admin or owner', () {
      const admin = GroupEntity(
        roomId: '!r:s', name: 'N', myRole: GroupRole.admin);
      const owner = GroupEntity(
        roomId: '!r:s', name: 'N', myRole: GroupRole.owner);
      expect(admin.isAdmin, isTrue);
      expect(owner.isAdmin, isTrue);
    });

    test('isAdmin is false for member', () {
      const g = GroupEntity(roomId: '!r:s', name: 'N');
      expect(g.isAdmin, isFalse);
    });

    test('hasPinnedMessages is true when pinnedEventIds not empty', () {
      const g = GroupEntity(
        roomId: '!r:s', name: 'N',
        pinnedEventIds: [r'$event1', r'$event2'],
      );
      expect(g.hasPinnedMessages, isTrue);
      expect(g.pinnedMessageCount, 2);
    });

    test('hasPinnedMessages is false when pinnedEventIds empty', () {
      const g = GroupEntity(roomId: '!r:s', name: 'N');
      expect(g.hasPinnedMessages, isFalse);
      expect(g.pinnedMessageCount, 0);
    });

    test('channelLink includes channelUsername', () {
      const g = GroupEntity(
        roomId: '!r:s', name: 'N', channelUsername: 'mychannel');
      expect(g.channelLink, 'https://n42.app/mychannel');
    });

    test('channelLink is null when channelUsername is null', () {
      const g = GroupEntity(roomId: '!r:s', name: 'N');
      expect(g.channelLink, isNull);
    });
  });

  group('GroupEntity.owner, admins, normalMembers', () {
    const ownerMember = GroupMember(
      userId: '@owner:s', displayName: 'Owner', role: GroupRole.owner);
    const adminMember = GroupMember(
      userId: '@admin:s', displayName: 'Admin', role: GroupRole.admin);
    const memberA = GroupMember(
      userId: '@memberA:s', displayName: 'MemberA');
    const memberB = GroupMember(
      userId: '@memberB:s', displayName: 'MemberB');

    const g = GroupEntity(
      roomId: '!r:s',
      name: 'Team',
      members: [ownerMember, adminMember, memberA, memberB],
    );

    test('owner returns first GroupRole.owner member', () {
      expect(g.owner?.userId, '@owner:s');
    });

    test('admins excludes the owner', () {
      final admins = g.admins;
      expect(admins.length, 1);
      expect(admins.first.userId, '@admin:s');
    });

    test('normalMembers excludes admin-role members', () {
      // normalMembers = members where !isAdmin (role != admin && powerLevel < 50)
      // ownerMember (role=owner, powerLevel=0) has isAdmin=false → included in normalMembers
      final normals = g.normalMembers;
      expect(normals.length, 3); // ownerMember + memberA + memberB
      expect(normals.map((m) => m.userId),
          containsAll(['@owner:s', '@memberA:s', '@memberB:s']));
    });

    test('owner is null when no owner member', () {
      const g2 = GroupEntity(
        roomId: '!r:s', name: 'N', members: [memberA]);
      expect(g2.owner, isNull);
    });
  });

  group('GroupEntity.channel factory', () {
    final ch = GroupEntity.channel(
      roomId: '!ch:s',
      name: 'News Channel',
      channelUsername: 'news',
      subscriberCount: 500,
    );

    test('sets groupType to channel', () {
      expect(ch.groupType, GroupType.channel);
    });

    test('sets joinRule to public', () {
      expect(ch.joinRule, JoinRule.public);
    });

    test('membersCanSpeak is false', () {
      expect(ch.membersCanSpeak, isFalse);
    });

    test('showMemberList is false', () {
      expect(ch.showMemberList, isFalse);
    });

    test('stores channelUsername', () {
      expect(ch.channelUsername, 'news');
    });

    test('stores subscriberCount', () {
      expect(ch.subscriberCount, 500);
    });
  });

  group('GroupEntity.superGroup factory', () {
    final sg = GroupEntity.superGroup(
      roomId: '!sg:s',
      name: 'Super Group',
      memberCount: 1000,
      slowModeInterval: 10,
    );

    test('sets groupType to superGroup', () {
      expect(sg.groupType, GroupType.superGroup);
    });

    test('joinRule is public', () {
      expect(sg.joinRule, JoinRule.public);
    });

    test('membersCanSpeak is true', () {
      expect(sg.membersCanSpeak, isTrue);
    });

    test('stores memberCount', () {
      expect(sg.memberCount, 1000);
    });

    test('stores slowModeInterval', () {
      expect(sg.slowModeInterval, 10);
    });
  });

  group('GroupEntity.copyWith', () {
    const base = GroupEntity(roomId: '!r:s', name: 'Original');

    test('replaces name', () {
      expect(base.copyWith(name: 'Updated').name, 'Updated');
    });

    test('replaces memberCount', () {
      expect(base.copyWith(memberCount: 42).memberCount, 42);
    });

    test('replaces isEncrypted', () {
      expect(base.copyWith(isEncrypted: true).isEncrypted, isTrue);
    });

    test('replaces myRole', () {
      expect(base.copyWith(myRole: GroupRole.admin).myRole, GroupRole.admin);
    });

    test('original unchanged after copyWith', () {
      base.copyWith(name: 'Changed');
      expect(base.name, 'Original');
    });
  });

  group('GroupEntity equality', () {
    test('same fields → equal', () {
      const a = GroupEntity(roomId: '!r:s', name: 'N');
      const b = GroupEntity(roomId: '!r:s', name: 'N');
      expect(a, equals(b));
    });

    test('different roomId → not equal', () {
      const a = GroupEntity(roomId: '!a:s', name: 'N');
      const b = GroupEntity(roomId: '!b:s', name: 'N');
      expect(a, isNot(equals(b)));
    });

    test('different name → not equal', () {
      const a = GroupEntity(roomId: '!r:s', name: 'A');
      const b = GroupEntity(roomId: '!r:s', name: 'B');
      expect(a, isNot(equals(b)));
    });

    test('different groupType → not equal', () {
      const a = GroupEntity(roomId: '!r:s', name: 'N', groupType: GroupType.group);
      const b = GroupEntity(roomId: '!r:s', name: 'N', groupType: GroupType.channel);
      expect(a, isNot(equals(b)));
    });
  });
}
