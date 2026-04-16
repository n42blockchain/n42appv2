// Tests for GroupEvent subclasses in group_event.dart.
// TokenGateConfig is const-constructible (all fields optional).
// UpdateGroupAvatar / CreateGroup.avatar use Uint8List (non-const):
// tested via runtime reference without equality.

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/token_gate_entity.dart';
import 'package:n42_chat/src/presentation/blocs/group/group_event.dart';

void main() {
  // ─────────────────────────────────────────────────
  // Parameterless events
  // ─────────────────────────────────────────────────

  group('LoadGroups', () {
    test('is a GroupEvent', () {
      expect(const LoadGroups(), isA<GroupEvent>());
    });

    test('two instances are equal', () {
      expect(const LoadGroups(), equals(const LoadGroups()));
    });
  });

  group('RefreshGroups', () {
    test('is a GroupEvent', () {
      expect(const RefreshGroups(), isA<GroupEvent>());
    });

    test('two instances are equal', () {
      expect(const RefreshGroups(), equals(const RefreshGroups()));
    });
  });

  group('LoadGroupInvites', () {
    test('is a GroupEvent', () {
      expect(const LoadGroupInvites(), isA<GroupEvent>());
    });

    test('two instances are equal', () {
      expect(const LoadGroupInvites(), equals(const LoadGroupInvites()));
    });
  });

  group('GroupsUpdated', () {
    test('is a GroupEvent', () {
      expect(const GroupsUpdated(), isA<GroupEvent>());
    });

    test('two instances are equal', () {
      expect(const GroupsUpdated(), equals(const GroupsUpdated()));
    });
  });

  // ─────────────────────────────────────────────────
  // Single-roomId events
  // ─────────────────────────────────────────────────

  for (final pair in <List<dynamic>>[
    ['LoadGroupDetails', (String r) => LoadGroupDetails(r)],
    ['LoadGroupMembers', (String r) => LoadGroupMembers(r)],
    ['LeaveGroup', (String r) => LeaveGroup(r)],
    ['DeleteGroup', (String r) => DeleteGroup(r)],
    ['AcceptGroupInvite', (String r) => AcceptGroupInvite(r)],
    ['RejectGroupInvite', (String r) => RejectGroupInvite(r)],
    ['VerifyTokenGate', (String r) => VerifyTokenGate(r)],
  ]) {
    final name = pair[0] as String;
    final factory = pair[1] as GroupEvent Function(String);
    group(name, () {
      test('stores roomId', () {
        final e = factory('!room:server');
        // Access via reflection is not available; check isA and isNot equality instead.
        expect(e, isA<GroupEvent>());
      });

      test('same roomId → equal', () {
        expect(factory('!r:s'), equals(factory('!r:s')));
      });

      test('different roomId → not equal', () {
        expect(factory('!a:s'), isNot(equals(factory('!b:s'))));
      });
    });
  }

  // ─────────────────────────────────────────────────
  // CreateGroup
  // ─────────────────────────────────────────────────

  group('CreateGroup', () {
    test('stores name', () {
      expect(const CreateGroup(name: 'Dev Team').name, 'Dev Team');
    });

    test('inviteUserIds defaults to empty', () {
      expect(const CreateGroup(name: 'G').inviteUserIds, isEmpty);
    });

    test('topic defaults to null', () {
      expect(const CreateGroup(name: 'G').topic, isNull);
    });

    test('isPublic defaults to false', () {
      expect(const CreateGroup(name: 'G').isPublic, isFalse);
    });

    test('enableEncryption defaults to false', () {
      expect(const CreateGroup(name: 'G').enableEncryption, isFalse);
    });

    test('avatar defaults to null', () {
      expect(const CreateGroup(name: 'G').avatar, isNull);
    });

    test('stores inviteUserIds', () {
      const e = CreateGroup(name: 'G', inviteUserIds: ['@a:s', '@b:s']);
      expect(e.inviteUserIds, ['@a:s', '@b:s']);
    });

    test('stores avatar (runtime reference)', () {
      final avatar = Uint8List.fromList([0xFF, 0xD8]);
      final e = CreateGroup(name: 'G', avatar: avatar);
      expect(e.avatar, avatar);
    });

    test('same const fields → equal', () {
      expect(
        const CreateGroup(name: 'G', topic: 'T', isPublic: true),
        equals(const CreateGroup(name: 'G', topic: 'T', isPublic: true)),
      );
    });

    test('different name → not equal', () {
      expect(
        const CreateGroup(name: 'A'),
        isNot(equals(const CreateGroup(name: 'B'))),
      );
    });

    test('is a GroupEvent', () {
      expect(const CreateGroup(name: 'G'), isA<GroupEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // UpdateGroupName / UpdateGroupTopic
  // ─────────────────────────────────────────────────

  group('UpdateGroupName', () {
    test('stores roomId and name', () {
      const e = UpdateGroupName('!r:s', 'New Name');
      expect(e.roomId, '!r:s');
      expect(e.name, 'New Name');
    });

    test('same fields → equal', () {
      expect(
        const UpdateGroupName('!r:s', 'Name'),
        equals(const UpdateGroupName('!r:s', 'Name')),
      );
    });

    test('different name → not equal', () {
      expect(
        const UpdateGroupName('!r:s', 'A'),
        isNot(equals(const UpdateGroupName('!r:s', 'B'))),
      );
    });

    test('is a GroupEvent', () {
      expect(const UpdateGroupName('!r:s', 'N'), isA<GroupEvent>());
    });
  });

  group('UpdateGroupTopic', () {
    test('stores roomId and topic', () {
      const e = UpdateGroupTopic('!r:s', 'Engineering discussions');
      expect(e.roomId, '!r:s');
      expect(e.topic, 'Engineering discussions');
    });

    test('same fields → equal', () {
      expect(
        const UpdateGroupTopic('!r:s', 'T'),
        equals(const UpdateGroupTopic('!r:s', 'T')),
      );
    });

    test('is a GroupEvent', () {
      expect(const UpdateGroupTopic('!r:s', 'T'), isA<GroupEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // UpdateGroupAvatar (Uint8List — non-const)
  // ─────────────────────────────────────────────────

  group('UpdateGroupAvatar', () {
    test('stores roomId and avatar', () {
      final avatar = Uint8List.fromList([0xFF, 0xD8, 0xFF]);
      final e = UpdateGroupAvatar('!r:s', avatar);
      expect(e.roomId, '!r:s');
      expect(e.avatar, avatar);
    });

    test('is a GroupEvent', () {
      expect(
        UpdateGroupAvatar('!r:s', Uint8List(0)),
        isA<GroupEvent>(),
      );
    });
  });

  // ─────────────────────────────────────────────────
  // InviteMembers
  // ─────────────────────────────────────────────────

  group('InviteMembers', () {
    test('stores roomId and userIds', () {
      const e = InviteMembers('!r:s', ['@alice:s', '@bob:s']);
      expect(e.roomId, '!r:s');
      expect(e.userIds, ['@alice:s', '@bob:s']);
    });

    test('same fields → equal', () {
      expect(
        const InviteMembers('!r:s', ['@a:s']),
        equals(const InviteMembers('!r:s', ['@a:s'])),
      );
    });

    test('different userIds → not equal', () {
      expect(
        const InviteMembers('!r:s', ['@a:s']),
        isNot(equals(const InviteMembers('!r:s', ['@b:s']))),
      );
    });

    test('is a GroupEvent', () {
      expect(const InviteMembers('!r:s', []), isA<GroupEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // KickMember
  // ─────────────────────────────────────────────────

  group('KickMember', () {
    test('stores roomId and userId', () {
      const e = KickMember('!r:s', '@bad:s');
      expect(e.roomId, '!r:s');
      expect(e.userId, '@bad:s');
    });

    test('reason defaults to null', () {
      expect(const KickMember('!r:s', '@u:s').reason, isNull);
    });

    test('stores reason when provided', () {
      const e = KickMember('!r:s', '@u:s', reason: 'Spamming');
      expect(e.reason, 'Spamming');
    });

    test('same fields → equal', () {
      expect(
        const KickMember('!r:s', '@u:s', reason: 'r'),
        equals(const KickMember('!r:s', '@u:s', reason: 'r')),
      );
    });

    test('different reason → not equal', () {
      expect(
        const KickMember('!r:s', '@u:s', reason: 'a'),
        isNot(equals(const KickMember('!r:s', '@u:s', reason: 'b'))),
      );
    });

    test('is a GroupEvent', () {
      expect(const KickMember('!r:s', '@u:s'), isA<GroupEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // SetAsAdmin / RemoveAdmin
  // ─────────────────────────────────────────────────

  group('SetAsAdmin', () {
    test('stores roomId and userId', () {
      const e = SetAsAdmin('!r:s', '@alice:s');
      expect(e.roomId, '!r:s');
      expect(e.userId, '@alice:s');
    });

    test('same fields → equal', () {
      expect(
        const SetAsAdmin('!r:s', '@u:s'),
        equals(const SetAsAdmin('!r:s', '@u:s')),
      );
    });

    test('is a GroupEvent', () {
      expect(const SetAsAdmin('!r:s', '@u:s'), isA<GroupEvent>());
    });
  });

  group('RemoveAdmin', () {
    test('stores roomId and userId', () {
      const e = RemoveAdmin('!r:s', '@alice:s');
      expect(e.roomId, '!r:s');
      expect(e.userId, '@alice:s');
    });

    test('same fields → equal', () {
      expect(
        const RemoveAdmin('!r:s', '@u:s'),
        equals(const RemoveAdmin('!r:s', '@u:s')),
      );
    });

    test('is a GroupEvent', () {
      expect(const RemoveAdmin('!r:s', '@u:s'), isA<GroupEvent>());
    });
  });

  // ─────────────────────────────────────────────────
  // SetTokenGate
  // ─────────────────────────────────────────────────

  group('SetTokenGate', () {
    test('stores roomId and config', () {
      const config = TokenGateConfig(enabled: true, denialMessage: 'Members only');
      const e = SetTokenGate('!r:s', config);
      expect(e.roomId, '!r:s');
      expect(e.config.enabled, isTrue);
      expect(e.config.denialMessage, 'Members only');
    });

    test('config defaults: enabled=false, rules=[], operator=and', () {
      const config = TokenGateConfig();
      expect(config.enabled, isFalse);
      expect(config.rules, isEmpty);
      expect(config.operator, GateOperator.and);
    });

    test('same config → equal', () {
      expect(
        const SetTokenGate('!r:s', TokenGateConfig()),
        equals(const SetTokenGate('!r:s', TokenGateConfig())),
      );
    });

    test('is a GroupEvent', () {
      expect(
        const SetTokenGate('!r:s', TokenGateConfig()),
        isA<GroupEvent>(),
      );
    });
  });
}
