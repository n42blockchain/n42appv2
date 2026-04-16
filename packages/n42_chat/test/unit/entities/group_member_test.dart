// Tests for GroupMember entity and GroupEntity member-management getters.
// Complements group_entity_channel_test.dart and group_entity_pinned_test.dart.
// Pure Dart / Equatable — no platform dependencies.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/group_entity.dart';

// ─── Shared test fixtures ───────────────────────────────────────────────────

const _ownerMember = GroupMember(
  userId: '@owner:server.com',
  displayName: 'Owner User',
  role: GroupRole.owner,
  powerLevel: 100,
);

const _adminMember = GroupMember(
  userId: '@admin:server.com',
  displayName: 'Admin User',
  role: GroupRole.admin,
  powerLevel: 50,
);

const _regularMember = GroupMember(
  userId: '@user:server.com',
  displayName: 'Regular User',
  role: GroupRole.member,
  powerLevel: 0,
);

// ────────────────────────────────────────────────────────────────────────────

void main() {
  // ─────────────────────────────────────────────────
  // GroupRole enum
  // ─────────────────────────────────────────────────

  group('GroupRole', () {
    test('has 3 values: owner, admin, member', () {
      expect(GroupRole.values.length, 3);
      expect(GroupRole.values, containsAll([
        GroupRole.owner, GroupRole.admin, GroupRole.member,
      ]));
    });
  });

  // ─────────────────────────────────────────────────
  // MembershipStatus enum
  // ─────────────────────────────────────────────────

  group('MembershipStatus', () {
    test('has 2 values: joined, invited', () {
      expect(MembershipStatus.values.length, 2);
      expect(MembershipStatus.values,
          containsAll([MembershipStatus.joined, MembershipStatus.invited]));
    });
  });

  // ─────────────────────────────────────────────────
  // GroupMember constructor defaults
  // ─────────────────────────────────────────────────

  group('GroupMember constructor defaults', () {
    const member = GroupMember(
      userId: '@alice:server.com',
      displayName: 'Alice',
    );

    test('role defaults to member', () {
      expect(member.role, GroupRole.member);
    });

    test('powerLevel defaults to 0', () {
      expect(member.powerLevel, 0);
    });

    test('isOnline defaults to false', () {
      expect(member.isOnline, isFalse);
    });

    test('membershipStatus defaults to joined', () {
      expect(member.membershipStatus, MembershipStatus.joined);
    });

    test('avatarUrl and joinedAt default to null', () {
      expect(member.avatarUrl, isNull);
      expect(member.joinedAt, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // GroupMember.isInvited
  // ─────────────────────────────────────────────────

  group('GroupMember.isInvited', () {
    test('joined member is not invited', () {
      const m = GroupMember(
        userId: '@u:s', displayName: 'U',
        membershipStatus: MembershipStatus.joined,
      );
      expect(m.isInvited, isFalse);
    });

    test('invited member is invited', () {
      const m = GroupMember(
        userId: '@u:s', displayName: 'U',
        membershipStatus: MembershipStatus.invited,
      );
      expect(m.isInvited, isTrue);
    });
  });

  // ─────────────────────────────────────────────────
  // GroupMember.username
  // ─────────────────────────────────────────────────

  group('GroupMember.username', () {
    test('extracts username from full Matrix ID', () {
      const m = GroupMember(userId: '@alice:server.com', displayName: 'Alice');
      expect(m.username, 'alice');
    });

    test('@ prefix without colon returns everything after @', () {
      const m = GroupMember(userId: '@alice', displayName: 'Alice');
      expect(m.username, 'alice');
    });

    test('plain userId without @ is returned as-is', () {
      const m = GroupMember(userId: 'alice', displayName: 'Alice');
      expect(m.username, 'alice');
    });

    test('preserves underscores and digits', () {
      const m = GroupMember(userId: '@user_123:server.com', displayName: 'User');
      expect(m.username, 'user_123');
    });
  });

  // ─────────────────────────────────────────────────
  // GroupMember.initials
  // ─────────────────────────────────────────────────

  group('GroupMember.initials', () {
    test('empty displayName returns ?', () {
      const m = GroupMember(userId: '@u:s', displayName: '');
      expect(m.initials, '?');
    });

    test('single-word name returns first 2 chars uppercased', () {
      const m = GroupMember(userId: '@u:s', displayName: 'alice');
      expect(m.initials, 'AL');
    });

    test('single character name returns that char uppercased', () {
      const m = GroupMember(userId: '@u:s', displayName: 'a');
      expect(m.initials, 'A');
    });

    test('two-word name returns first letter of each', () {
      const m = GroupMember(userId: '@u:s', displayName: 'Alice Bob');
      expect(m.initials, 'AB');
    });

    test('three-word name returns only first two initials', () {
      const m = GroupMember(userId: '@u:s', displayName: 'Alice Bob Charlie');
      expect(m.initials, 'AB');
    });

    test('multiple spaces handled correctly', () {
      const m = GroupMember(userId: '@u:s', displayName: 'Alice  Bob');
      expect(m.initials, 'AB');
    });
  });

  // ─────────────────────────────────────────────────
  // GroupMember.isOwner
  // ─────────────────────────────────────────────────

  group('GroupMember.isOwner', () {
    test('role=owner → isOwner=true', () {
      expect(_ownerMember.isOwner, isTrue);
    });

    test('powerLevel=100 → isOwner=true regardless of role', () {
      const m = GroupMember(
        userId: '@u:s', displayName: 'U',
        role: GroupRole.member,
        powerLevel: 100,
      );
      expect(m.isOwner, isTrue);
    });

    test('role=admin, powerLevel=0 → isOwner=false', () {
      expect(_adminMember.isOwner, isFalse);
    });

    test('role=member, powerLevel=0 → isOwner=false', () {
      expect(_regularMember.isOwner, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // GroupMember.isAdmin
  // ─────────────────────────────────────────────────

  group('GroupMember.isAdmin', () {
    test('role=admin → isAdmin=true', () {
      expect(_adminMember.isAdmin, isTrue);
    });

    test('powerLevel=50 → isAdmin=true regardless of role', () {
      const m = GroupMember(
        userId: '@u:s', displayName: 'U',
        role: GroupRole.member,
        powerLevel: 50,
      );
      expect(m.isAdmin, isTrue);
    });

    test('role=member, powerLevel=0 → isAdmin=false', () {
      expect(_regularMember.isAdmin, isFalse);
    });

    test('powerLevel=49 → isAdmin=false', () {
      const m = GroupMember(
        userId: '@u:s', displayName: 'U',
        powerLevel: 49,
      );
      expect(m.isAdmin, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // GroupMember Equatable
  // ─────────────────────────────────────────────────

  group('GroupMember equality', () {
    test('identical instances are equal', () {
      const a = GroupMember(userId: '@a:s', displayName: 'A');
      const b = GroupMember(userId: '@a:s', displayName: 'A');
      expect(a, equals(b));
    });

    test('different userId breaks equality', () {
      const a = GroupMember(userId: '@a:s', displayName: 'A');
      const b = GroupMember(userId: '@b:s', displayName: 'A');
      expect(a, isNot(equals(b)));
    });

    test('different role breaks equality', () {
      const a = GroupMember(userId: '@u:s', displayName: 'U', role: GroupRole.admin);
      const b = GroupMember(userId: '@u:s', displayName: 'U', role: GroupRole.member);
      expect(a, isNot(equals(b)));
    });
  });

  // ─────────────────────────────────────────────────
  // GroupMember.copyWith
  // ─────────────────────────────────────────────────

  group('GroupMember.copyWith', () {
    test('no overrides produces equal copy', () {
      expect(_regularMember.copyWith(), equals(_regularMember));
    });

    test('overrides role only', () {
      final promoted = _regularMember.copyWith(role: GroupRole.admin);
      expect(promoted.role, GroupRole.admin);
      expect(promoted.userId, _regularMember.userId);
    });

    test('overrides isOnline only', () {
      final online = _regularMember.copyWith(isOnline: true);
      expect(online.isOnline, isTrue);
      expect(online.displayName, _regularMember.displayName);
    });
  });

  // ─────────────────────────────────────────────────
  // GroupEntity — member-related getters
  // ─────────────────────────────────────────────────

  group('GroupEntity.owner', () {
    test('returns the member with isOwner=true', () {
      const entity = GroupEntity(
        roomId: '!r:s',
        name: 'G',
        members: [_regularMember, _ownerMember, _adminMember],
      );
      expect(entity.owner, _ownerMember);
    });

    test('returns null when no owner in member list', () {
      const entity = GroupEntity(
        roomId: '!r:s',
        name: 'G',
        members: [_regularMember, _adminMember],
      );
      expect(entity.owner, isNull);
    });
  });

  group('GroupEntity.admins', () {
    test('returns members with isAdmin=true and isOwner=false', () {
      const entity = GroupEntity(
        roomId: '!r:s',
        name: 'G',
        members: [_ownerMember, _adminMember, _regularMember],
      );
      // adminMember: role=admin → isAdmin=true, powerLevel=50 → isOwner=false
      expect(entity.admins, [_adminMember]);
    });

    test('owner is excluded from admins list', () {
      const entity = GroupEntity(
        roomId: '!r:s',
        name: 'G',
        members: [_ownerMember],
      );
      expect(entity.admins, isEmpty);
    });

    test('empty members → empty admins', () {
      const entity = GroupEntity(roomId: '!r:s', name: 'G');
      expect(entity.admins, isEmpty);
    });
  });

  group('GroupEntity.normalMembers', () {
    test('returns members that are not admin (role=member, powerLevel=0)', () {
      const entity = GroupEntity(
        roomId: '!r:s',
        name: 'G',
        members: [_ownerMember, _adminMember, _regularMember],
      );
      // regularMember: isAdmin=false → in normalMembers
      expect(entity.normalMembers, [_regularMember]);
    });

    test('empty members → empty normalMembers', () {
      const entity = GroupEntity(roomId: '!r:s', name: 'G');
      expect(entity.normalMembers, isEmpty);
    });
  });

  // ─────────────────────────────────────────────────
  // GroupEntity.isOwner / isAdmin (myRole-based)
  // ─────────────────────────────────────────────────

  group('GroupEntity.isOwner (myRole)', () {
    test('myRole=owner → isOwner=true', () {
      const entity = GroupEntity(
        roomId: '!r:s', name: 'G', myRole: GroupRole.owner,
      );
      expect(entity.isOwner, isTrue);
    });

    test('myRole=member → isOwner=false', () {
      const entity = GroupEntity(
        roomId: '!r:s', name: 'G', myRole: GroupRole.member,
      );
      expect(entity.isOwner, isFalse);
    });
  });

  group('GroupEntity.isAdmin (myRole)', () {
    test('myRole=admin → isAdmin=true', () {
      const entity = GroupEntity(
        roomId: '!r:s', name: 'G', myRole: GroupRole.admin,
      );
      expect(entity.isAdmin, isTrue);
    });

    test('myRole=owner → isAdmin=true (via isOwner)', () {
      const entity = GroupEntity(
        roomId: '!r:s', name: 'G', myRole: GroupRole.owner,
      );
      expect(entity.isAdmin, isTrue);
    });

    test('myRole=member → isAdmin=false', () {
      const entity = GroupEntity(
        roomId: '!r:s', name: 'G', myRole: GroupRole.member,
      );
      expect(entity.isAdmin, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // GroupEntity.channelLink
  // ─────────────────────────────────────────────────

  group('GroupEntity.channelLink', () {
    test('null channelUsername → null channelLink', () {
      const entity = GroupEntity(roomId: '!r:s', name: 'G');
      expect(entity.channelLink, isNull);
    });

    test('non-null channelUsername → generates link', () {
      const entity = GroupEntity(
        roomId: '!r:s',
        name: 'G',
        channelUsername: 'n42news',
      );
      expect(entity.channelLink, 'https://n42.app/n42news');
    });
  });

  // ─────────────────────────────────────────────────
  // GroupEntity.superGroup factory
  // ─────────────────────────────────────────────────

  group('GroupEntity.superGroup factory', () {
    test('sets groupType to superGroup', () {
      final sg = GroupEntity.superGroup(roomId: '!r:s', name: 'SG');
      expect(sg.groupType, GroupType.superGroup);
      expect(sg.isSuperGroup, isTrue);
    });

    test('joinRule defaults to public', () {
      final sg = GroupEntity.superGroup(roomId: '!r:s', name: 'SG');
      expect(sg.joinRule, JoinRule.public);
    });

    test('membersCanSpeak is true', () {
      final sg = GroupEntity.superGroup(roomId: '!r:s', name: 'SG');
      expect(sg.membersCanSpeak, isTrue);
    });

    test('slowModeInterval can be set', () {
      final sg = GroupEntity.superGroup(
        roomId: '!r:s', name: 'SG', slowModeInterval: 30,
      );
      expect(sg.slowModeInterval, 30);
    });
  });
}
