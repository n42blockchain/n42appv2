// Tests for BlocMessageKeys in bloc_message_keys.dart.
// All constants are pure Dart strings — no deps needed.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/blocs/bloc_message_keys.dart';

void main() {
  // ─────────────────────────────────────────────────
  // Group keys
  // ─────────────────────────────────────────────────

  group('BlocMessageKeys — group', () {
    test('groupNotFound value', () {
      expect(BlocMessageKeys.groupNotFound, 'group_not_found');
    });

    test('groupNameUpdated value', () {
      expect(BlocMessageKeys.groupNameUpdated, 'group_name_updated');
    });

    test('groupDescriptionUpdated value', () {
      expect(BlocMessageKeys.groupDescriptionUpdated, 'group_description_updated');
    });

    test('groupAvatarUpdated value', () {
      expect(BlocMessageKeys.groupAvatarUpdated, 'group_avatar_updated');
    });

    test('groupMembersInvited value', () {
      expect(BlocMessageKeys.groupMembersInvited, 'group_members_invited');
    });

    test('groupMemberRemoved value', () {
      expect(BlocMessageKeys.groupMemberRemoved, 'group_member_removed');
    });

    test('groupSetAsAdmin value', () {
      expect(BlocMessageKeys.groupSetAsAdmin, 'group_set_as_admin');
    });

    test('groupAdminRemoved value', () {
      expect(BlocMessageKeys.groupAdminRemoved, 'group_admin_removed');
    });

    test('groupLeft value', () {
      expect(BlocMessageKeys.groupLeft, 'group_left');
    });

    test('groupDisbanded value', () {
      expect(BlocMessageKeys.groupDisbanded, 'group_disbanded');
    });

    test('groupJoined value', () {
      expect(BlocMessageKeys.groupJoined, 'group_joined');
    });

    test('groupInviteDeclined value', () {
      expect(BlocMessageKeys.groupInviteDeclined, 'group_invite_declined');
    });

    test('groupTokenGateUpdated value', () {
      expect(BlocMessageKeys.groupTokenGateUpdated, 'group_token_gate_updated');
    });
  });

  // ─────────────────────────────────────────────────
  // Transfer keys
  // ─────────────────────────────────────────────────

  group('BlocMessageKeys — transfer', () {
    test('transferProcessing value', () {
      expect(BlocMessageKeys.transferProcessing, 'transfer_processing');
    });

    test('transferCancelled value', () {
      expect(BlocMessageKeys.transferCancelled, 'transfer_cancelled');
    });

    test('transferFailed value', () {
      expect(BlocMessageKeys.transferFailed, 'transfer_failed');
    });

    test('paymentProcessing value', () {
      expect(BlocMessageKeys.paymentProcessing, 'payment_processing');
    });

    test('paymentFailed value', () {
      expect(BlocMessageKeys.paymentFailed, 'payment_failed');
    });
  });

  // ─────────────────────────────────────────────────
  // All keys are unique
  // ─────────────────────────────────────────────────

  group('BlocMessageKeys uniqueness', () {
    test('all group keys are unique strings', () {
      final groupKeys = [
        BlocMessageKeys.groupNotFound,
        BlocMessageKeys.groupNameUpdated,
        BlocMessageKeys.groupDescriptionUpdated,
        BlocMessageKeys.groupAvatarUpdated,
        BlocMessageKeys.groupMembersInvited,
        BlocMessageKeys.groupMemberRemoved,
        BlocMessageKeys.groupSetAsAdmin,
        BlocMessageKeys.groupAdminRemoved,
        BlocMessageKeys.groupLeft,
        BlocMessageKeys.groupDisbanded,
        BlocMessageKeys.groupJoined,
        BlocMessageKeys.groupInviteDeclined,
        BlocMessageKeys.groupTokenGateUpdated,
      ];
      expect(groupKeys.toSet().length, groupKeys.length);
    });

    test('all transfer keys are unique strings', () {
      final transferKeys = [
        BlocMessageKeys.transferProcessing,
        BlocMessageKeys.transferCancelled,
        BlocMessageKeys.transferFailed,
        BlocMessageKeys.paymentProcessing,
        BlocMessageKeys.paymentFailed,
      ];
      expect(transferKeys.toSet().length, transferKeys.length);
    });
  });
}
