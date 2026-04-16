// Tests for GroupStatus enum and GroupState in group_state.dart.
// GroupEntity / GroupMember / TokenGateVerificationResult require domain
// construction — fields using those types are left null/empty in tests.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/blocs/group/group_state.dart';

void main() {
  // ─────────────────────────────────────────────────
  // GroupStatus enum
  // ─────────────────────────────────────────────────

  group('GroupStatus enum values', () {
    test('has 7 values', () {
      expect(GroupStatus.values, hasLength(7));
    });

    test('contains initial', () {
      expect(GroupStatus.values, contains(GroupStatus.initial));
    });

    test('contains loading', () {
      expect(GroupStatus.values, contains(GroupStatus.loading));
    });

    test('contains loaded', () {
      expect(GroupStatus.values, contains(GroupStatus.loaded));
    });

    test('contains created', () {
      expect(GroupStatus.values, contains(GroupStatus.created));
    });

    test('contains success', () {
      expect(GroupStatus.values, contains(GroupStatus.success));
    });

    test('contains tokenGateVerified', () {
      expect(GroupStatus.values, contains(GroupStatus.tokenGateVerified));
    });

    test('contains error', () {
      expect(GroupStatus.values, contains(GroupStatus.error));
    });
  });

  // ─────────────────────────────────────────────────
  // GroupState constructor defaults
  // ─────────────────────────────────────────────────

  group('GroupState constructor defaults', () {
    const s = GroupState();

    test('status defaults to GroupStatus.initial', () {
      expect(s.status, GroupStatus.initial);
    });

    test('groups defaults to empty list', () {
      expect(s.groups, isEmpty);
    });

    test('invites defaults to empty list', () {
      expect(s.invites, isEmpty);
    });

    test('currentGroup defaults to null', () {
      expect(s.currentGroup, isNull);
    });

    test('members defaults to empty list', () {
      expect(s.members, isEmpty);
    });

    test('createdRoomId defaults to null', () {
      expect(s.createdRoomId, isNull);
    });

    test('successMessage defaults to null', () {
      expect(s.successMessage, isNull);
    });

    test('errorMessage defaults to null', () {
      expect(s.errorMessage, isNull);
    });

    test('tokenGateResult defaults to null', () {
      expect(s.tokenGateResult, isNull);
    });

    test('tokenGateRoomId defaults to null', () {
      expect(s.tokenGateRoomId, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // GroupState.initial()
  // ─────────────────────────────────────────────────

  group('GroupState.initial()', () {
    test('is equal to default constructor state', () {
      expect(const GroupState.initial(), equals(const GroupState()));
    });

    test('status is GroupStatus.initial', () {
      expect(const GroupState.initial().status, GroupStatus.initial);
    });
  });

  // ─────────────────────────────────────────────────
  // isLoading getter
  // ─────────────────────────────────────────────────

  group('GroupState.isLoading', () {
    test('true when status == loading', () {
      const s = GroupState(status: GroupStatus.loading);
      expect(s.isLoading, isTrue);
    });

    test('false when status == initial', () {
      expect(const GroupState().isLoading, isFalse);
    });

    test('false when status == loaded', () {
      const s = GroupState(status: GroupStatus.loaded);
      expect(s.isLoading, isFalse);
    });

    test('false when status == error', () {
      const s = GroupState(status: GroupStatus.error);
      expect(s.isLoading, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // isLoaded getter
  // ─────────────────────────────────────────────────

  group('GroupState.isLoaded', () {
    test('true when status == loaded', () {
      const s = GroupState(status: GroupStatus.loaded);
      expect(s.isLoaded, isTrue);
    });

    test('false when status == initial and groups is empty', () {
      expect(const GroupState().isLoaded, isFalse);
    });

    test('false when status == loading and groups is empty', () {
      const s = GroupState(status: GroupStatus.loading);
      expect(s.isLoaded, isFalse);
    });

    test('false when status == error and groups is empty', () {
      const s = GroupState(status: GroupStatus.error);
      expect(s.isLoaded, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // hasError getter
  // ─────────────────────────────────────────────────

  group('GroupState.hasError', () {
    test('true when status==error and errorMessage!=null', () {
      const s = GroupState(
        status: GroupStatus.error,
        errorMessage: 'something went wrong',
      );
      expect(s.hasError, isTrue);
    });

    test('false when status==error but errorMessage==null', () {
      const s = GroupState(status: GroupStatus.error);
      expect(s.hasError, isFalse);
    });

    test('false when errorMessage set but status!=error', () {
      const s = GroupState(errorMessage: 'oops');
      expect(s.hasError, isFalse);
    });

    test('false for default state', () {
      expect(const GroupState().hasError, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — fields with ?? (preserve when omitted)
  // ─────────────────────────────────────────────────

  group('GroupState.copyWith — ?? fields', () {
    const base = GroupState(
      status: GroupStatus.loaded,
      tokenGateRoomId: '!room:server',
    );

    test('no overrides preserves status', () {
      final copy = base.copyWith();
      expect(copy.status, GroupStatus.loaded);
    });

    test('overrides status', () {
      final copy = base.copyWith(status: GroupStatus.loading);
      expect(copy.status, GroupStatus.loading);
    });

    test('no override preserves tokenGateRoomId via ??', () {
      final copy = base.copyWith();
      expect(copy.tokenGateRoomId, '!room:server');
    });

    test('overrides tokenGateRoomId', () {
      final copy = base.copyWith(tokenGateRoomId: '!other:server');
      expect(copy.tokenGateRoomId, '!other:server');
    });
  });

  // ─────────────────────────────────────────────────
  // copyWith — fields WITHOUT ?? (reset to null when omitted)
  // ─────────────────────────────────────────────────

  group('GroupState.copyWith — reset-on-omit fields', () {
    const withMessages = GroupState(
      createdRoomId: '!new:server',
      successMessage: 'Group created',
      errorMessage: 'old error',
    );

    test('copyWith() without createdRoomId resets it to null', () {
      final copy = withMessages.copyWith();
      expect(copy.createdRoomId, isNull);
    });

    test('copyWith() without successMessage resets it to null', () {
      final copy = withMessages.copyWith();
      expect(copy.successMessage, isNull);
    });

    test('copyWith() without errorMessage resets it to null', () {
      final copy = withMessages.copyWith();
      expect(copy.errorMessage, isNull);
    });

    test('copyWith with createdRoomId sets new value', () {
      final copy = withMessages.copyWith(createdRoomId: '!other:server');
      expect(copy.createdRoomId, '!other:server');
    });

    test('copyWith with successMessage sets new value', () {
      final copy = withMessages.copyWith(successMessage: 'Done!');
      expect(copy.successMessage, 'Done!');
    });

    test('copyWith with errorMessage sets new value', () {
      final copy = withMessages.copyWith(errorMessage: 'new error');
      expect(copy.errorMessage, 'new error');
    });

    test('other fields are preserved across copyWith', () {
      const s = GroupState(
        status: GroupStatus.success,
        tokenGateRoomId: '!tg:server',
        createdRoomId: '!c:server',
      );
      final copy = s.copyWith(status: GroupStatus.loaded);
      expect(copy.status, GroupStatus.loaded);
      expect(copy.tokenGateRoomId, '!tg:server'); // preserved via ??
      expect(copy.createdRoomId, isNull);          // reset — no ?? in copyWith
    });
  });

  // ─────────────────────────────────────────────────
  // toString
  // ─────────────────────────────────────────────────

  group('GroupState.toString', () {
    test('contains status', () {
      const s = GroupState(status: GroupStatus.loaded);
      expect(s.toString(), contains('loaded'));
    });

    test('contains groups length 0 for empty list', () {
      const s = GroupState();
      expect(s.toString(), contains('groups: 0'));
    });

    test('contains members length 0 for empty list', () {
      const s = GroupState();
      expect(s.toString(), contains('members: 0'));
    });
  });

  // ─────────────────────────────────────────────────
  // Equatable equality
  // ─────────────────────────────────────────────────

  group('GroupState Equatable equality', () {
    test('two default instances are equal', () {
      expect(const GroupState(), equals(const GroupState()));
    });

    test('states with different status are not equal', () {
      expect(
        const GroupState(status: GroupStatus.loading),
        isNot(equals(const GroupState())),
      );
    });

    test('states with different createdRoomId are not equal', () {
      expect(
        const GroupState(createdRoomId: '!r:s'),
        isNot(equals(const GroupState())),
      );
    });

    test('states with different errorMessage are not equal', () {
      expect(
        const GroupState(errorMessage: 'err'),
        isNot(equals(const GroupState())),
      );
    });

    test('states with different successMessage are not equal', () {
      expect(
        const GroupState(successMessage: 'ok'),
        isNot(equals(const GroupState())),
      );
    });

    test('states with same fields are equal', () {
      expect(
        const GroupState(
          status: GroupStatus.error,
          errorMessage: 'fail',
          createdRoomId: '!r:s',
        ),
        equals(const GroupState(
          status: GroupStatus.error,
          errorMessage: 'fail',
          createdRoomId: '!r:s',
        )),
      );
    });
  });
}
