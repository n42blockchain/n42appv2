import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/core/services/bot_webhook_service.dart';
import 'package:n42_chat/src/domain/entities/bot_config_entity.dart';
import 'package:n42_chat/src/domain/entities/channel_entity.dart';
import 'package:n42_chat/src/domain/entities/group_entity.dart';
import 'package:n42_chat/src/domain/entities/token_gate_entity.dart';
import 'package:n42_chat/src/domain/repositories/group_repository.dart';
import 'package:n42_chat/src/presentation/blocs/bloc_message_keys.dart';
import 'package:n42_chat/src/presentation/blocs/group/group_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/group/group_event.dart';
import 'package:n42_chat/src/presentation/blocs/group/group_state.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockGroupRepository extends Mock implements IGroupRepository {}

class MockBotWebhookService extends Mock implements BotWebhookService {}

class FakeTokenGateConfig extends Fake implements TokenGateConfig {}

class FakeBotConfig extends Fake implements BotConfig {}

class FakeBotWebhookEventPayload extends Fake
    implements BotWebhookEventPayload {}

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

const _roomId1 = '!room1:server.com';
const _roomId2 = '!room2:server.com';
const _channelRoomId = '!channel1:server.com';

const _testGroup1 = GroupEntity(
  roomId: _roomId1,
  name: 'Test Group 1',
  memberCount: 5,
  topic: 'A test group',
);

const _testGroup2 = GroupEntity(
  roomId: _roomId2,
  name: 'Test Group 2',
  memberCount: 3,
);

const _testMember1 = GroupMember(
  userId: '@alice:server.com',
  displayName: 'Alice',
  role: GroupRole.owner,
  powerLevel: 100,
);

const _testMember2 = GroupMember(
  userId: '@bob:server.com',
  displayName: 'Bob',
  role: GroupRole.member,
  powerLevel: 0,
);

const _testMembers = [_testMember1, _testMember2];

const _testInvite = GroupEntity(
  roomId: '!invite1:server.com',
  name: 'Invite Group',
);

const _testChannel = ChannelEntity(
  roomId: _channelRoomId,
  parentRoomId: _roomId1,
  name: 'Announcements',
  topic: 'Read-only updates',
);

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

void main() {
  late MockGroupRepository mockRepository;
  late MockBotWebhookService mockBotWebhookService;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(FakeTokenGateConfig());
    registerFallbackValue(FakeBotConfig());
    registerFallbackValue(FakeBotWebhookEventPayload());
  });

  setUp(() {
    mockRepository = MockGroupRepository();
    mockBotWebhookService = MockBotWebhookService();

    // Default stub for watchGroups - returns an empty stream that never emits
    // so LoadGroups won't trigger GroupsUpdated during tests.
    when(
      () => mockRepository.watchGroups(),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockBotWebhookService.dispatch(
        config: any(named: 'config'),
        payload: any(named: 'payload'),
      ),
    ).thenAnswer((_) async => BotWebhookDispatchResult.sent(200));
  });

  // =========================================================================
  // Initial state
  // =========================================================================

  group('initial state', () {
    test('should be GroupState.initial with GroupStatus.initial', () {
      final bloc = GroupBloc(mockRepository);
      addTearDown(bloc.close);

      expect(bloc.state, const GroupState.initial());
      expect(bloc.state.status, GroupStatus.initial);
      expect(bloc.state.groups, isEmpty);
      expect(bloc.state.invites, isEmpty);
      expect(bloc.state.currentGroup, isNull);
      expect(bloc.state.members, isEmpty);
      expect(bloc.state.createdRoomId, isNull);
      expect(bloc.state.successMessage, isNull);
      expect(bloc.state.errorMessage, isNull);
      expect(bloc.state.tokenGateResult, isNull);
      expect(bloc.state.tokenGateRoomId, isNull);
    });

    test('convenience getters reflect initial state', () {
      const state = GroupState.initial();

      expect(state.isLoading, isFalse);
      expect(state.isLoaded, isFalse);
      expect(state.hasError, isFalse);
    });
  });

  // =========================================================================
  // GroupState copyWith & convenience getters
  // =========================================================================

  group('GroupState', () {
    test('copyWith preserves existing fields when not overridden', () {
      final state = const GroupState.initial().copyWith(
        status: GroupStatus.loaded,
        groups: [_testGroup1],
      );

      final next = state.copyWith(status: GroupStatus.loading);

      expect(next.status, GroupStatus.loading);
      expect(next.groups, [_testGroup1], reason: 'groups should be preserved');
      expect(next.invites, isEmpty);
    });

    test(
      'copyWith clears transient fields (createdRoomId, successMessage, errorMessage) when not provided',
      () {
        final state = const GroupState.initial().copyWith(
          status: GroupStatus.created,
          createdRoomId: _roomId1,
          successMessage: 'ok',
          errorMessage: 'err',
        );

        // Now copyWith without those fields -> they reset to null
        final next = state.copyWith(status: GroupStatus.loaded);

        expect(next.createdRoomId, isNull);
        expect(next.successMessage, isNull);
        expect(next.errorMessage, isNull);
      },
    );

    test('isLoading returns true only when status is loading', () {
      final state = const GroupState.initial().copyWith(
        status: GroupStatus.loading,
      );
      expect(state.isLoading, isTrue);
    });

    test('isLoaded returns true when status is loaded', () {
      final state = const GroupState.initial().copyWith(
        status: GroupStatus.loaded,
      );
      expect(state.isLoaded, isTrue);
    });

    test(
      'isLoaded returns true when groups is non-empty regardless of status',
      () {
        final state = const GroupState.initial().copyWith(
          status: GroupStatus.initial,
          groups: [_testGroup1],
        );
        expect(state.isLoaded, isTrue);
      },
    );

    test(
      'hasError returns true only when status is error AND errorMessage is set',
      () {
        final withBoth = const GroupState.initial().copyWith(
          status: GroupStatus.error,
          errorMessage: 'something went wrong',
        );
        expect(withBoth.hasError, isTrue);

        final withoutMessage = const GroupState.initial().copyWith(
          status: GroupStatus.error,
        );
        expect(withoutMessage.hasError, isFalse);
      },
    );

    test('Equatable: two states with same props are equal', () {
      final a = const GroupState.initial().copyWith(
        status: GroupStatus.loaded,
        groups: [_testGroup1],
      );
      final b = const GroupState.initial().copyWith(
        status: GroupStatus.loaded,
        groups: [_testGroup1],
      );
      expect(a, equals(b));
    });

    test('Equatable: two states with different props are not equal', () {
      final a = const GroupState.initial().copyWith(
        status: GroupStatus.loaded,
        groups: [_testGroup1],
      );
      final b = const GroupState.initial().copyWith(
        status: GroupStatus.loaded,
        groups: [_testGroup2],
      );
      expect(a, isNot(equals(b)));
    });
  });

  // =========================================================================
  // LoadGroups
  // =========================================================================

  group('LoadGroups', () {
    blocTest<GroupBloc, GroupState>(
      'emits [loading, loaded] with groups and invites on success',
      build: () {
        when(
          () => mockRepository.getGroups(),
        ).thenAnswer((_) async => [_testGroup1, _testGroup2]);
        when(
          () => mockRepository.getPendingGroupInvites(),
        ).thenAnswer((_) async => [_testInvite]);
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const LoadGroups()),
      expect: () => [
        isA<GroupState>().having(
          (s) => s.status,
          'status',
          GroupStatus.loading,
        ),
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.loaded)
            .having((s) => s.groups, 'groups', [_testGroup1, _testGroup2])
            .having((s) => s.invites, 'invites', [_testInvite]),
      ],
      verify: (_) {
        verify(() => mockRepository.watchGroups()).called(1);
        verify(() => mockRepository.getGroups()).called(1);
        verify(() => mockRepository.getPendingGroupInvites()).called(1);
      },
    );

    blocTest<GroupBloc, GroupState>(
      'emits [loading, error] when getGroups throws',
      build: () {
        when(
          () => mockRepository.getGroups(),
        ).thenThrow(Exception('network error'));
        when(
          () => mockRepository.getPendingGroupInvites(),
        ).thenAnswer((_) async => []);
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const LoadGroups()),
      expect: () => [
        isA<GroupState>().having(
          (s) => s.status,
          'status',
          GroupStatus.loading,
        ),
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.error)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('network error'),
            ),
      ],
    );

    blocTest<GroupBloc, GroupState>(
      'preserves existing groups in state during loading',
      build: () {
        when(
          () => mockRepository.getGroups(),
        ).thenAnswer((_) async => [_testGroup1]);
        when(
          () => mockRepository.getPendingGroupInvites(),
        ).thenAnswer((_) async => []);
        return GroupBloc(mockRepository);
      },
      seed: () => const GroupState.initial().copyWith(
        status: GroupStatus.loaded,
        groups: [_testGroup2],
      ),
      act: (bloc) => bloc.add(const LoadGroups()),
      expect: () => [
        // loading state preserves existing groups
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.loading)
            .having((s) => s.groups, 'groups', [_testGroup2]),
        // loaded state replaces with new groups
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.loaded)
            .having((s) => s.groups, 'groups', [_testGroup1]),
      ],
    );
  });

  // =========================================================================
  // RefreshGroups
  // =========================================================================

  group('RefreshGroups', () {
    blocTest<GroupBloc, GroupState>(
      'emits [loaded] without a loading intermediate on success',
      build: () {
        when(
          () => mockRepository.getGroups(),
        ).thenAnswer((_) async => [_testGroup1]);
        when(
          () => mockRepository.getPendingGroupInvites(),
        ).thenAnswer((_) async => []);
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const RefreshGroups()),
      expect: () => [
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.loaded)
            .having((s) => s.groups, 'groups', [_testGroup1]),
      ],
    );

    blocTest<GroupBloc, GroupState>(
      'emits [error] when refresh fails',
      build: () {
        when(
          () => mockRepository.getGroups(),
        ).thenThrow(Exception('refresh failed'));
        when(
          () => mockRepository.getPendingGroupInvites(),
        ).thenAnswer((_) async => []);
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const RefreshGroups()),
      expect: () => [
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.error)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('refresh failed'),
            ),
      ],
    );
  });

  // =========================================================================
  // LoadGroupDetails
  // =========================================================================

  group('LoadGroupDetails', () {
    blocTest<GroupBloc, GroupState>(
      'emits [loading, loaded] with currentGroup and members on success',
      build: () {
        when(
          () => mockRepository.getGroup(_roomId1),
        ).thenAnswer((_) async => _testGroup1);
        when(
          () => mockRepository.getGroupMembers(_roomId1),
        ).thenAnswer((_) async => _testMembers);
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const LoadGroupDetails(_roomId1)),
      expect: () => [
        isA<GroupState>().having(
          (s) => s.status,
          'status',
          GroupStatus.loading,
        ),
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.loaded)
            .having((s) => s.currentGroup, 'currentGroup', _testGroup1)
            .having((s) => s.members, 'members', _testMembers),
      ],
    );

    blocTest<GroupBloc, GroupState>(
      'emits [loading, error] when group not found (null)',
      build: () {
        when(
          () => mockRepository.getGroup(_roomId1),
        ).thenAnswer((_) async => null);
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const LoadGroupDetails(_roomId1)),
      expect: () => [
        isA<GroupState>().having(
          (s) => s.status,
          'status',
          GroupStatus.loading,
        ),
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.error)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              BlocMessageKeys.groupNotFound,
            ),
      ],
    );

    blocTest<GroupBloc, GroupState>(
      'emits [loading, error] when getGroup throws',
      build: () {
        when(
          () => mockRepository.getGroup(_roomId1),
        ).thenThrow(Exception('server error'));
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const LoadGroupDetails(_roomId1)),
      expect: () => [
        isA<GroupState>().having(
          (s) => s.status,
          'status',
          GroupStatus.loading,
        ),
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.error)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('server error'),
            ),
      ],
    );

    blocTest<GroupBloc, GroupState>(
      'preserves groups list when loading group details',
      build: () {
        when(
          () => mockRepository.getGroup(_roomId1),
        ).thenAnswer((_) async => _testGroup1);
        when(
          () => mockRepository.getGroupMembers(_roomId1),
        ).thenAnswer((_) async => _testMembers);
        return GroupBloc(mockRepository);
      },
      seed: () => const GroupState.initial().copyWith(
        status: GroupStatus.loaded,
        groups: [_testGroup1, _testGroup2],
      ),
      act: (bloc) => bloc.add(const LoadGroupDetails(_roomId1)),
      expect: () => [
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.loading)
            .having((s) => s.groups.length, 'groups.length', 2),
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.loaded)
            .having((s) => s.groups.length, 'groups.length', 2)
            .having((s) => s.currentGroup, 'currentGroup', _testGroup1),
      ],
    );
  });

  // =========================================================================
  // LoadGroupMembers
  // =========================================================================

  group('LoadGroupMembers', () {
    blocTest<GroupBloc, GroupState>(
      'emits state with updated members on success (no status change)',
      build: () {
        when(
          () => mockRepository.getGroupMembers(_roomId1),
        ).thenAnswer((_) async => _testMembers);
        return GroupBloc(mockRepository);
      },
      seed: () =>
          const GroupState.initial().copyWith(status: GroupStatus.loaded),
      act: (bloc) => bloc.add(const LoadGroupMembers(_roomId1)),
      expect: () => [
        isA<GroupState>()
            .having((s) => s.members, 'members', _testMembers)
            .having((s) => s.status, 'status', GroupStatus.loaded),
      ],
    );

    blocTest<GroupBloc, GroupState>(
      'emits error when getGroupMembers throws',
      build: () {
        when(
          () => mockRepository.getGroupMembers(_roomId1),
        ).thenThrow(Exception('cannot load members'));
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const LoadGroupMembers(_roomId1)),
      expect: () => [
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.error)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('cannot load members'),
            ),
      ],
    );
  });

  // =========================================================================
  // CreateGroup
  // =========================================================================

  group('CreateGroup', () {
    blocTest<GroupBloc, GroupState>(
      'emits [loading, created] with createdRoomId on success',
      build: () {
        when(
          () => mockRepository.createGroup(
            name: 'New Group',
            inviteUserIds: ['@alice:server.com'],
            topic: 'New topic',
            isPublic: false,
            enableEncryption: false,
            avatar: null,
          ),
        ).thenAnswer((_) async => _roomId1);
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(
        const CreateGroup(
          name: 'New Group',
          inviteUserIds: ['@alice:server.com'],
          topic: 'New topic',
        ),
      ),
      expect: () => [
        isA<GroupState>().having(
          (s) => s.status,
          'status',
          GroupStatus.loading,
        ),
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.created)
            .having((s) => s.createdRoomId, 'createdRoomId', _roomId1),
      ],
    );

    blocTest<GroupBloc, GroupState>(
      'preserves existing groups list after creation',
      build: () {
        when(
          () => mockRepository.createGroup(
            name: 'New Group',
            inviteUserIds: const [],
            topic: null,
            isPublic: false,
            enableEncryption: false,
            avatar: null,
          ),
        ).thenAnswer((_) async => _roomId2);
        return GroupBloc(mockRepository);
      },
      seed: () => const GroupState.initial().copyWith(
        status: GroupStatus.loaded,
        groups: [_testGroup1],
      ),
      act: (bloc) => bloc.add(const CreateGroup(name: 'New Group')),
      expect: () => [
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.loading)
            .having((s) => s.groups, 'groups', [_testGroup1]),
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.created)
            .having((s) => s.createdRoomId, 'createdRoomId', _roomId2)
            .having((s) => s.groups, 'groups', [_testGroup1]),
      ],
    );

    blocTest<GroupBloc, GroupState>(
      'emits [loading, error] when createGroup throws',
      build: () {
        when(
          () => mockRepository.createGroup(
            name: 'New Group',
            inviteUserIds: const [],
            topic: null,
            isPublic: false,
            enableEncryption: false,
            avatar: null,
          ),
        ).thenThrow(Exception('create failed'));
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const CreateGroup(name: 'New Group')),
      expect: () => [
        isA<GroupState>().having(
          (s) => s.status,
          'status',
          GroupStatus.loading,
        ),
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.error)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('create failed'),
            ),
      ],
    );
  });

  // =========================================================================
  // InviteMembers
  // =========================================================================

  group('InviteMembers', () {
    blocTest<GroupBloc, GroupState>(
      'emits [success] with successMessage on success',
      build: () {
        when(
          () => mockRepository.inviteUsers(_roomId1, [
            '@bob:server.com',
            '@charlie:server.com',
          ]),
        ).thenAnswer((_) async {});
        // LoadGroupMembers will be triggered via add()
        when(
          () => mockRepository.getGroupMembers(_roomId1),
        ).thenAnswer((_) async => _testMembers);
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(
        const InviteMembers(_roomId1, [
          '@bob:server.com',
          '@charlie:server.com',
        ]),
      ),
      expect: () => [
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.success)
            .having(
              (s) => s.successMessage,
              'successMessage',
              '${BlocMessageKeys.groupMembersInvited}:2',
            ),
        // Second emission from the add(LoadGroupMembers) side-effect
        isA<GroupState>().having((s) => s.members, 'members', _testMembers),
      ],
    );

    blocTest<GroupBloc, GroupState>(
      'preserves groups list on successful invite',
      build: () {
        when(
          () => mockRepository.inviteUsers(_roomId1, ['@bob:server.com']),
        ).thenAnswer((_) async {});
        when(
          () => mockRepository.getGroupMembers(_roomId1),
        ).thenAnswer((_) async => _testMembers);
        return GroupBloc(mockRepository);
      },
      seed: () => const GroupState.initial().copyWith(
        status: GroupStatus.loaded,
        groups: [_testGroup1, _testGroup2],
      ),
      act: (bloc) =>
          bloc.add(const InviteMembers(_roomId1, ['@bob:server.com'])),
      expect: () => [
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.success)
            .having((s) => s.groups.length, 'groups.length', 2),
        isA<GroupState>().having((s) => s.groups.length, 'groups.length', 2),
      ],
    );

    blocTest<GroupBloc, GroupState>(
      'emits [error] when inviteUsers throws',
      build: () {
        when(
          () => mockRepository.inviteUsers(_roomId1, ['@bob:server.com']),
        ).thenThrow(Exception('invite failed'));
        return GroupBloc(mockRepository);
      },
      act: (bloc) =>
          bloc.add(const InviteMembers(_roomId1, ['@bob:server.com'])),
      expect: () => [
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.error)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('invite failed'),
            ),
      ],
    );
  });

  // =========================================================================
  // KickMember
  // =========================================================================

  group('KickMember', () {
    blocTest<GroupBloc, GroupState>(
      'emits [success] with "Member removed" on success',
      build: () {
        when(
          () => mockRepository.kickMember(_roomId1, '@bob:server.com'),
        ).thenAnswer((_) async {});
        when(
          () => mockRepository.getGroupMembers(_roomId1),
        ).thenAnswer((_) async => [_testMember1]);
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const KickMember(_roomId1, '@bob:server.com')),
      expect: () => [
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.success)
            .having(
              (s) => s.successMessage,
              'successMessage',
              BlocMessageKeys.groupMemberRemoved,
            ),
        // LoadGroupMembers side-effect
        isA<GroupState>().having((s) => s.members, 'members', [_testMember1]),
      ],
    );

    blocTest<GroupBloc, GroupState>(
      'emits [error] when kickMember throws',
      build: () {
        when(
          () => mockRepository.kickMember(_roomId1, '@bob:server.com'),
        ).thenThrow(Exception('kick failed'));
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const KickMember(_roomId1, '@bob:server.com')),
      expect: () => [
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.error)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('kick failed'),
            ),
      ],
    );
  });

  // =========================================================================
  // SetAsAdmin
  // =========================================================================

  group('SetAsAdmin', () {
    blocTest<GroupBloc, GroupState>(
      'emits [success] with "Set as admin" on success',
      build: () {
        when(
          () => mockRepository.setAsAdmin(_roomId1, '@bob:server.com'),
        ).thenAnswer((_) async {});
        when(
          () => mockRepository.getGroupMembers(_roomId1),
        ).thenAnswer((_) async => _testMembers);
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const SetAsAdmin(_roomId1, '@bob:server.com')),
      expect: () => [
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.success)
            .having(
              (s) => s.successMessage,
              'successMessage',
              BlocMessageKeys.groupSetAsAdmin,
            ),
        isA<GroupState>().having((s) => s.members, 'members', _testMembers),
      ],
    );

    blocTest<GroupBloc, GroupState>(
      'emits [error] when setAsAdmin throws',
      build: () {
        when(
          () => mockRepository.setAsAdmin(_roomId1, '@bob:server.com'),
        ).thenThrow(Exception('permission denied'));
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const SetAsAdmin(_roomId1, '@bob:server.com')),
      expect: () => [
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.error)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('permission denied'),
            ),
      ],
    );
  });

  // =========================================================================
  // RemoveAdmin
  // =========================================================================

  group('RemoveAdmin', () {
    blocTest<GroupBloc, GroupState>(
      'emits [success] with "Admin removed" on success',
      build: () {
        when(
          () => mockRepository.removeAdmin(_roomId1, '@bob:server.com'),
        ).thenAnswer((_) async {});
        when(
          () => mockRepository.getGroupMembers(_roomId1),
        ).thenAnswer((_) async => _testMembers);
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const RemoveAdmin(_roomId1, '@bob:server.com')),
      expect: () => [
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.success)
            .having(
              (s) => s.successMessage,
              'successMessage',
              BlocMessageKeys.groupAdminRemoved,
            ),
        isA<GroupState>().having((s) => s.members, 'members', _testMembers),
      ],
    );

    blocTest<GroupBloc, GroupState>(
      'emits [error] when removeAdmin throws',
      build: () {
        when(
          () => mockRepository.removeAdmin(_roomId1, '@bob:server.com'),
        ).thenThrow(Exception('cannot demote'));
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const RemoveAdmin(_roomId1, '@bob:server.com')),
      expect: () => [
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.error)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('cannot demote'),
            ),
      ],
    );
  });

  // =========================================================================
  // UpdateGroupName
  // =========================================================================

  group('UpdateGroupName', () {
    blocTest<GroupBloc, GroupState>(
      'emits states with currentGroup updated and then success',
      build: () {
        when(
          () => mockRepository.setGroupName(_roomId1, 'New Name'),
        ).thenAnswer((_) async {});
        when(
          () => mockRepository.getGroup(_roomId1),
        ).thenAnswer((_) async => _testGroup1.copyWith(name: 'New Name'));
        when(
          () => mockRepository.getGroupMembers(_roomId1),
        ).thenAnswer((_) async => _testMembers);
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const UpdateGroupName(_roomId1, 'New Name')),
      expect: () => [
        // First emission: currentGroup & members updated
        isA<GroupState>()
            .having(
              (s) => s.currentGroup?.name,
              'currentGroup.name',
              'New Name',
            )
            .having((s) => s.members, 'members', _testMembers),
        // Second emission: status becomes success
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.success)
            .having(
              (s) => s.successMessage,
              'successMessage',
              BlocMessageKeys.groupNameUpdated,
            ),
      ],
    );

    blocTest<GroupBloc, GroupState>(
      'emits [error] when setGroupName throws',
      build: () {
        when(
          () => mockRepository.setGroupName(_roomId1, 'New Name'),
        ).thenThrow(Exception('Failed to update group name'));
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const UpdateGroupName(_roomId1, 'New Name')),
      expect: () => [
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );
  });

  // =========================================================================
  // UpdateGroupTopic
  // =========================================================================

  group('UpdateGroupTopic', () {
    blocTest<GroupBloc, GroupState>(
      'emits states with success message "Group description updated"',
      build: () {
        when(
          () => mockRepository.setGroupTopic(_roomId1, 'New Topic'),
        ).thenAnswer((_) async {});
        when(
          () => mockRepository.getGroup(_roomId1),
        ).thenAnswer((_) async => _testGroup1.copyWith(topic: 'New Topic'));
        when(
          () => mockRepository.getGroupMembers(_roomId1),
        ).thenAnswer((_) async => _testMembers);
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const UpdateGroupTopic(_roomId1, 'New Topic')),
      expect: () => [
        isA<GroupState>().having(
          (s) => s.currentGroup?.topic,
          'currentGroup.topic',
          'New Topic',
        ),
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.success)
            .having(
              (s) => s.successMessage,
              'successMessage',
              BlocMessageKeys.groupDescriptionUpdated,
            ),
      ],
    );
  });

  // =========================================================================
  // UpdateGroupAvatar
  // =========================================================================

  group('UpdateGroupAvatar', () {
    blocTest<GroupBloc, GroupState>(
      'emits states with success message "Group avatar updated"',
      build: () {
        when(
          () => mockRepository.setGroupAvatar(_roomId1, any()),
        ).thenAnswer((_) async {});
        when(
          () => mockRepository.getGroup(_roomId1),
        ).thenAnswer((_) async => _testGroup1);
        when(
          () => mockRepository.getGroupMembers(_roomId1),
        ).thenAnswer((_) async => _testMembers);
        return GroupBloc(mockRepository);
      },
      act: (bloc) =>
          bloc.add(UpdateGroupAvatar(_roomId1, Uint8List.fromList([1, 2, 3]))),
      expect: () => [
        isA<GroupState>().having(
          (s) => s.currentGroup,
          'currentGroup',
          _testGroup1,
        ),
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.success)
            .having(
              (s) => s.successMessage,
              'successMessage',
              BlocMessageKeys.groupAvatarUpdated,
            ),
      ],
    );
  });

  // =========================================================================
  // UpdateGroupVisibility
  // =========================================================================

  group('UpdateGroupVisibility', () {
    blocTest<GroupBloc, GroupState>(
      'emits states with updated public visibility and success message',
      build: () {
        when(
          () => mockRepository.setGroupVisibility(_roomId1, true),
        ).thenAnswer((_) async {});
        when(
          () => mockRepository.getGroup(_roomId1),
        ).thenAnswer((_) async => _testGroup1.copyWith(isPublic: true));
        when(
          () => mockRepository.getGroupMembers(_roomId1),
        ).thenAnswer((_) async => _testMembers);
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const UpdateGroupVisibility(_roomId1, true)),
      expect: () => [
        isA<GroupState>().having(
          (s) => s.currentGroup?.isPublic,
          'currentGroup.isPublic',
          true,
        ),
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.success)
            .having(
              (s) => s.successMessage,
              'successMessage',
              BlocMessageKeys.groupVisibilityUpdated,
            ),
      ],
    );
  });

  // =========================================================================
  // Channel management
  // =========================================================================

  group('CreateChannel', () {
    blocTest<GroupBloc, GroupState>(
      'emits updated channels and localized success key',
      build: () {
        when(
          () => mockRepository.createChannel(
            _roomId1,
            name: 'Announcements',
            topic: 'Read-only updates',
            category: null,
          ),
        ).thenAnswer((_) async => _testChannel.roomId);
        when(
          () => mockRepository.getChannels(_roomId1),
        ).thenAnswer((_) async => [_testChannel]);
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(
        const CreateChannel(
          parentRoomId: _roomId1,
          name: 'Announcements',
          topic: 'Read-only updates',
        ),
      ),
      expect: () => [
        isA<GroupState>()
            .having((s) => s.channels, 'channels', [_testChannel])
            .having((s) => s.status, 'status', GroupStatus.success)
            .having(
              (s) => s.successMessage,
              'successMessage',
              BlocMessageKeys.groupChannelCreated,
            ),
      ],
    );

    blocTest<GroupBloc, GroupState>(
      'passes category when creating a channel',
      build: () {
        when(
          () => mockRepository.createChannel(
            _roomId1,
            name: 'Roadmap',
            topic: 'Planning',
            category: 'Product',
          ),
        ).thenAnswer((_) async => _testChannel.roomId);
        when(() => mockRepository.getChannels(_roomId1)).thenAnswer(
          (_) async => [
            _testChannel.copyWith(
              name: 'Roadmap',
              topic: 'Planning',
              category: 'Product',
            ),
          ],
        );
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(
        const CreateChannel(
          parentRoomId: _roomId1,
          name: 'Roadmap',
          topic: 'Planning',
          category: 'Product',
        ),
      ),
      expect: () => [
        isA<GroupState>().having(
          (s) => s.channels.first.category,
          'channels.first.category',
          'Product',
        ),
      ],
    );
  });

  group('UpdateChannel', () {
    blocTest<GroupBloc, GroupState>(
      'emits updated channels and localized success key',
      build: () {
        when(
          () => mockRepository.updateChannel(
            _roomId1,
            _testChannel.roomId,
            name: 'Release Notes',
            topic: 'Official updates',
            category: null,
          ),
        ).thenAnswer((_) async {});
        when(() => mockRepository.getChannels(_roomId1)).thenAnswer(
          (_) async => [
            _testChannel.copyWith(
              name: 'Release Notes',
              topic: 'Official updates',
            ),
          ],
        );
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(
        const UpdateChannel(
          parentRoomId: _roomId1,
          channelRoomId: _channelRoomId,
          name: 'Release Notes',
          topic: 'Official updates',
        ),
      ),
      expect: () => [
        isA<GroupState>()
            .having(
              (s) => s.channels.first.name,
              'channels.first.name',
              'Release Notes',
            )
            .having((s) => s.status, 'status', GroupStatus.success)
            .having(
              (s) => s.successMessage,
              'successMessage',
              BlocMessageKeys.groupChannelUpdated,
            ),
      ],
    );

    blocTest<GroupBloc, GroupState>(
      'allows clearing an existing category',
      build: () {
        when(
          () => mockRepository.updateChannel(
            _roomId1,
            _testChannel.roomId,
            name: 'Release Notes',
            topic: 'Official updates',
            category: null,
          ),
        ).thenAnswer((_) async {});
        when(() => mockRepository.getChannels(_roomId1)).thenAnswer(
          (_) async => [
            _testChannel.copyWith(
              name: 'Release Notes',
              topic: 'Official updates',
              category: null,
            ),
          ],
        );
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(
        const UpdateChannel(
          parentRoomId: _roomId1,
          channelRoomId: _channelRoomId,
          name: 'Release Notes',
          topic: 'Official updates',
          category: null,
        ),
      ),
      expect: () => [
        isA<GroupState>().having(
          (s) => s.channels.first.category,
          'channels.first.category',
          isNull,
        ),
      ],
    );
  });

  group('DeleteChannel', () {
    blocTest<GroupBloc, GroupState>(
      'emits remaining channels and localized success key',
      build: () {
        when(
          () => mockRepository.deleteChannel(_roomId1, _testChannel.roomId),
        ).thenAnswer((_) async {});
        when(
          () => mockRepository.getChannels(_roomId1),
        ).thenAnswer((_) async => const []);
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(
        const DeleteChannel(
          parentRoomId: _roomId1,
          channelRoomId: _channelRoomId,
        ),
      ),
      expect: () => [
        isA<GroupState>()
            .having((s) => s.channels, 'channels', isEmpty)
            .having((s) => s.status, 'status', GroupStatus.success)
            .having(
              (s) => s.successMessage,
              'successMessage',
              BlocMessageKeys.groupChannelDeleted,
            ),
      ],
    );
  });

  // =========================================================================
  // LeaveGroup
  // =========================================================================

  group('LeaveGroup', () {
    blocTest<GroupBloc, GroupState>(
      'emits [success] with "Left the group" and triggers RefreshGroups',
      build: () {
        when(
          () => mockRepository.leaveGroup(_roomId1),
        ).thenAnswer((_) async {});
        // RefreshGroups side-effect
        when(
          () => mockRepository.getGroups(),
        ).thenAnswer((_) async => [_testGroup2]);
        when(
          () => mockRepository.getPendingGroupInvites(),
        ).thenAnswer((_) async => []);
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const LeaveGroup(_roomId1)),
      expect: () => [
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.success)
            .having(
              (s) => s.successMessage,
              'successMessage',
              BlocMessageKeys.groupLeft,
            ),
        // RefreshGroups side-effect
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.loaded)
            .having((s) => s.groups, 'groups', [_testGroup2]),
      ],
    );

    blocTest<GroupBloc, GroupState>(
      'emits [error] when leaveGroup throws',
      build: () {
        when(
          () => mockRepository.leaveGroup(_roomId1),
        ).thenThrow(Exception('leave failed'));
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const LeaveGroup(_roomId1)),
      expect: () => [
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.error)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('leave failed'),
            ),
      ],
    );
  });

  // =========================================================================
  // DeleteGroup
  // =========================================================================

  group('DeleteGroup', () {
    blocTest<GroupBloc, GroupState>(
      'emits [success] with "Group disbanded" and triggers RefreshGroups',
      build: () {
        when(
          () => mockRepository.deleteGroup(_roomId1),
        ).thenAnswer((_) async {});
        when(() => mockRepository.getGroups()).thenAnswer((_) async => []);
        when(
          () => mockRepository.getPendingGroupInvites(),
        ).thenAnswer((_) async => []);
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const DeleteGroup(_roomId1)),
      expect: () => [
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.success)
            .having(
              (s) => s.successMessage,
              'successMessage',
              BlocMessageKeys.groupDisbanded,
            ),
        // RefreshGroups side-effect
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.loaded)
            .having((s) => s.groups, 'groups', isEmpty),
      ],
    );

    blocTest<GroupBloc, GroupState>(
      'emits [error] when deleteGroup throws',
      build: () {
        when(
          () => mockRepository.deleteGroup(_roomId1),
        ).thenThrow(Exception('delete failed'));
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const DeleteGroup(_roomId1)),
      expect: () => [
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.error)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('delete failed'),
            ),
      ],
    );
  });

  // =========================================================================
  // LoadGroupInvites
  // =========================================================================

  group('LoadGroupInvites', () {
    blocTest<GroupBloc, GroupState>(
      'emits state with updated invites on success',
      build: () {
        when(
          () => mockRepository.getPendingGroupInvites(),
        ).thenAnswer((_) async => [_testInvite]);
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const LoadGroupInvites()),
      expect: () => [
        isA<GroupState>().having((s) => s.invites, 'invites', [_testInvite]),
      ],
    );

    blocTest<GroupBloc, GroupState>(
      'emits [error] when getPendingGroupInvites throws',
      build: () {
        when(
          () => mockRepository.getPendingGroupInvites(),
        ).thenThrow(Exception('invites error'));
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const LoadGroupInvites()),
      expect: () => [
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.error)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('invites error'),
            ),
      ],
    );
  });

  // =========================================================================
  // AcceptGroupInvite
  // =========================================================================

  group('AcceptGroupInvite', () {
    blocTest<GroupBloc, GroupState>(
      'emits [success] with "Joined the group" when no token gate',
      build: () {
        when(
          () => mockRepository.getTokenGate(_roomId1),
        ).thenAnswer((_) async => null);
        when(
          () => mockRepository.acceptGroupInvite(_roomId1),
        ).thenAnswer((_) async {});
        // RefreshGroups side-effect
        when(
          () => mockRepository.getGroups(),
        ).thenAnswer((_) async => [_testGroup1]);
        when(
          () => mockRepository.getPendingGroupInvites(),
        ).thenAnswer((_) async => []);
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const AcceptGroupInvite(_roomId1)),
      expect: () => [
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.success)
            .having(
              (s) => s.successMessage,
              'successMessage',
              BlocMessageKeys.groupJoined,
            ),
        // RefreshGroups side-effect
        isA<GroupState>().having((s) => s.status, 'status', GroupStatus.loaded),
      ],
    );

    blocTest<GroupBloc, GroupState>(
      'emits [tokenGateVerified] when token gate check fails',
      build: () {
        final tokenGateConfig = TokenGateConfig(
          enabled: true,
          rules: [
            TokenGateRule(
              id: 'rule1',
              tokenStandard: TokenStandard.erc20,
              chainId: 1,
              contractAddress: '0x123',
              minBalance: BigInt.from(100),
            ),
          ],
        );
        const verificationResult = TokenGateVerificationResult(
          passed: false,
          errorMessage: 'Insufficient balance',
        );
        when(
          () => mockRepository.getTokenGate(_roomId1),
        ).thenAnswer((_) async => tokenGateConfig);
        when(
          () => mockRepository.verifyTokenGate(_roomId1),
        ).thenAnswer((_) async => verificationResult);
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const AcceptGroupInvite(_roomId1)),
      expect: () => [
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.tokenGateVerified)
            .having((s) => s.tokenGateRoomId, 'tokenGateRoomId', _roomId1)
            .having(
              (s) => s.tokenGateResult?.passed,
              'tokenGateResult.passed',
              false,
            ),
      ],
      verify: (_) {
        verifyNever(() => mockRepository.acceptGroupInvite(any()));
      },
    );

    blocTest<GroupBloc, GroupState>(
      'accepts invite when token gate passes',
      build: () {
        final tokenGateConfig = TokenGateConfig(
          enabled: true,
          rules: [
            TokenGateRule(
              id: 'rule1',
              tokenStandard: TokenStandard.erc20,
              chainId: 1,
              contractAddress: '0x123',
              minBalance: BigInt.from(100),
            ),
          ],
        );
        const verificationResult = TokenGateVerificationResult(passed: true);
        when(
          () => mockRepository.getTokenGate(_roomId1),
        ).thenAnswer((_) async => tokenGateConfig);
        when(
          () => mockRepository.verifyTokenGate(_roomId1),
        ).thenAnswer((_) async => verificationResult);
        when(
          () => mockRepository.acceptGroupInvite(_roomId1),
        ).thenAnswer((_) async {});
        when(
          () => mockRepository.getGroups(),
        ).thenAnswer((_) async => [_testGroup1]);
        when(
          () => mockRepository.getPendingGroupInvites(),
        ).thenAnswer((_) async => []);
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const AcceptGroupInvite(_roomId1)),
      expect: () => [
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.success)
            .having(
              (s) => s.successMessage,
              'successMessage',
              BlocMessageKeys.groupJoined,
            ),
        isA<GroupState>().having((s) => s.status, 'status', GroupStatus.loaded),
      ],
      verify: (_) {
        verify(() => mockRepository.acceptGroupInvite(_roomId1)).called(1);
      },
    );

    blocTest<GroupBloc, GroupState>(
      'skips token gate verification when config is disabled',
      build: () {
        const tokenGateConfig = TokenGateConfig(enabled: false, rules: []);
        when(
          () => mockRepository.getTokenGate(_roomId1),
        ).thenAnswer((_) async => tokenGateConfig);
        when(
          () => mockRepository.acceptGroupInvite(_roomId1),
        ).thenAnswer((_) async {});
        when(
          () => mockRepository.getGroups(),
        ).thenAnswer((_) async => [_testGroup1]);
        when(
          () => mockRepository.getPendingGroupInvites(),
        ).thenAnswer((_) async => []);
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const AcceptGroupInvite(_roomId1)),
      expect: () => [
        isA<GroupState>().having(
          (s) => s.status,
          'status',
          GroupStatus.success,
        ),
        isA<GroupState>().having((s) => s.status, 'status', GroupStatus.loaded),
      ],
      verify: (_) {
        verifyNever(() => mockRepository.verifyTokenGate(any()));
        verify(() => mockRepository.acceptGroupInvite(_roomId1)).called(1);
      },
    );

    blocTest<GroupBloc, GroupState>(
      'emits [error] when acceptGroupInvite throws',
      build: () {
        when(
          () => mockRepository.getTokenGate(_roomId1),
        ).thenAnswer((_) async => null);
        when(
          () => mockRepository.acceptGroupInvite(_roomId1),
        ).thenThrow(Exception('accept failed'));
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const AcceptGroupInvite(_roomId1)),
      expect: () => [
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.error)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('accept failed'),
            ),
      ],
    );
  });

  // =========================================================================
  // RejectGroupInvite
  // =========================================================================

  group('RejectGroupInvite', () {
    blocTest<GroupBloc, GroupState>(
      'emits [success] with "Invitation declined" and triggers LoadGroupInvites',
      build: () {
        when(
          () => mockRepository.rejectGroupInvite(_roomId1),
        ).thenAnswer((_) async {});
        // LoadGroupInvites side-effect
        when(
          () => mockRepository.getPendingGroupInvites(),
        ).thenAnswer((_) async => []);
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const RejectGroupInvite(_roomId1)),
      expect: () => [
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.success)
            .having(
              (s) => s.successMessage,
              'successMessage',
              BlocMessageKeys.groupInviteDeclined,
            ),
        // LoadGroupInvites side-effect
        isA<GroupState>().having((s) => s.invites, 'invites', isEmpty),
      ],
    );

    blocTest<GroupBloc, GroupState>(
      'emits [error] when rejectGroupInvite throws',
      build: () {
        when(
          () => mockRepository.rejectGroupInvite(_roomId1),
        ).thenThrow(Exception('reject failed'));
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const RejectGroupInvite(_roomId1)),
      expect: () => [
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.error)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('reject failed'),
            ),
      ],
    );
  });

  // =========================================================================
  // SetTokenGate
  // =========================================================================

  group('SetTokenGate', () {
    final tokenGateConfig = TokenGateConfig(
      enabled: true,
      rules: [
        TokenGateRule(
          id: 'rule1',
          tokenStandard: TokenStandard.erc20,
          chainId: 1,
          contractAddress: '0x123',
          minBalance: BigInt.from(1000),
        ),
      ],
    );

    blocTest<GroupBloc, GroupState>(
      'emits [success] with "Token gate updated" and triggers LoadGroupDetails',
      build: () {
        when(
          () => mockRepository.setTokenGate(_roomId1, any()),
        ).thenAnswer((_) async {});
        // LoadGroupDetails side-effect
        when(
          () => mockRepository.getGroup(_roomId1),
        ).thenAnswer((_) async => _testGroup1);
        when(
          () => mockRepository.getGroupMembers(_roomId1),
        ).thenAnswer((_) async => _testMembers);
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(SetTokenGate(_roomId1, tokenGateConfig)),
      expect: () => [
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.success)
            .having(
              (s) => s.successMessage,
              'successMessage',
              BlocMessageKeys.groupTokenGateUpdated,
            ),
        // LoadGroupDetails side-effect: loading
        isA<GroupState>().having(
          (s) => s.status,
          'status',
          GroupStatus.loading,
        ),
        // LoadGroupDetails side-effect: loaded
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.loaded)
            .having((s) => s.currentGroup, 'currentGroup', _testGroup1),
      ],
    );

    blocTest<GroupBloc, GroupState>(
      'emits [error] when setTokenGate throws',
      build: () {
        when(
          () => mockRepository.setTokenGate(_roomId1, any()),
        ).thenThrow(Exception('token gate error'));
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(SetTokenGate(_roomId1, tokenGateConfig)),
      expect: () => [
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.error)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('token gate error'),
            ),
      ],
    );
  });

  // =========================================================================
  // VerifyTokenGate
  // =========================================================================

  group('VerifyTokenGate', () {
    blocTest<GroupBloc, GroupState>(
      'emits [loading, tokenGateVerified] with verification result',
      build: () {
        const result = TokenGateVerificationResult(passed: true);
        when(
          () => mockRepository.verifyTokenGate(_roomId1),
        ).thenAnswer((_) async => result);
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const VerifyTokenGate(_roomId1)),
      expect: () => [
        isA<GroupState>().having(
          (s) => s.status,
          'status',
          GroupStatus.loading,
        ),
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.tokenGateVerified)
            .having((s) => s.tokenGateRoomId, 'tokenGateRoomId', _roomId1)
            .having(
              (s) => s.tokenGateResult?.passed,
              'tokenGateResult.passed',
              true,
            ),
      ],
    );

    blocTest<GroupBloc, GroupState>(
      'emits [loading, error] when verifyTokenGate throws',
      build: () {
        when(
          () => mockRepository.verifyTokenGate(_roomId1),
        ).thenThrow(Exception('verify error'));
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const VerifyTokenGate(_roomId1)),
      expect: () => [
        isA<GroupState>().having(
          (s) => s.status,
          'status',
          GroupStatus.loading,
        ),
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.error)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('verify error'),
            ),
      ],
    );
  });

  // =========================================================================
  // GroupsUpdated (delegates to RefreshGroups)
  // =========================================================================

  group('GroupsUpdated', () {
    blocTest<GroupBloc, GroupState>(
      'delegates to RefreshGroups by calling add(RefreshGroups)',
      build: () {
        when(
          () => mockRepository.getGroups(),
        ).thenAnswer((_) async => [_testGroup1]);
        when(
          () => mockRepository.getPendingGroupInvites(),
        ).thenAnswer((_) async => []);
        return GroupBloc(mockRepository);
      },
      act: (bloc) => bloc.add(const GroupsUpdated()),
      expect: () => [
        // RefreshGroups result
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.loaded)
            .having((s) => s.groups, 'groups', [_testGroup1]),
      ],
    );
  });

  // =========================================================================
  // State preservation across operations
  // =========================================================================

  group('state preservation', () {
    blocTest<GroupBloc, GroupState>(
      'groups list survives a CreateGroup cycle',
      build: () {
        when(
          () => mockRepository.createGroup(
            name: 'New',
            inviteUserIds: const [],
            topic: null,
            isPublic: false,
            enableEncryption: false,
            avatar: null,
          ),
        ).thenAnswer((_) async => '!new:server.com');
        return GroupBloc(mockRepository);
      },
      seed: () => const GroupState.initial().copyWith(
        status: GroupStatus.loaded,
        groups: [_testGroup1, _testGroup2],
        invites: [_testInvite],
      ),
      act: (bloc) => bloc.add(const CreateGroup(name: 'New')),
      expect: () => [
        // loading: groups and invites preserved
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.loading)
            .having((s) => s.groups.length, 'groups.length', 2)
            .having((s) => s.invites.length, 'invites.length', 1),
        // created: groups and invites still preserved
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.created)
            .having((s) => s.groups.length, 'groups.length', 2)
            .having((s) => s.invites.length, 'invites.length', 1)
            .having((s) => s.createdRoomId, 'createdRoomId', '!new:server.com'),
      ],
    );

    blocTest<GroupBloc, GroupState>(
      'error state does not clear existing groups',
      build: () {
        when(
          () => mockRepository.createGroup(
            name: 'Fail',
            inviteUserIds: const [],
            topic: null,
            isPublic: false,
            enableEncryption: false,
            avatar: null,
          ),
        ).thenThrow(Exception('boom'));
        return GroupBloc(mockRepository);
      },
      seed: () => const GroupState.initial().copyWith(
        status: GroupStatus.loaded,
        groups: [_testGroup1],
      ),
      act: (bloc) => bloc.add(const CreateGroup(name: 'Fail')),
      expect: () => [
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.loading)
            .having((s) => s.groups, 'groups', [_testGroup1]),
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.error)
            .having((s) => s.groups, 'groups (must survive error)', [
              _testGroup1,
            ]),
      ],
    );

    blocTest<GroupBloc, GroupState>(
      'currentGroup and members survive a transient success operation',
      build: () {
        when(
          () => mockRepository.inviteUsers(_roomId1, ['@carol:server.com']),
        ).thenAnswer((_) async {});
        when(() => mockRepository.getGroupMembers(_roomId1)).thenAnswer(
          (_) async => [
            ..._testMembers,
            const GroupMember(
              userId: '@carol:server.com',
              displayName: 'Carol',
            ),
          ],
        );
        return GroupBloc(mockRepository);
      },
      seed: () => const GroupState.initial().copyWith(
        status: GroupStatus.loaded,
        groups: [_testGroup1],
        currentGroup: _testGroup1,
        members: _testMembers,
      ),
      act: (bloc) =>
          bloc.add(const InviteMembers(_roomId1, ['@carol:server.com'])),
      expect: () => [
        // success state: currentGroup preserved, groups preserved
        isA<GroupState>()
            .having((s) => s.status, 'status', GroupStatus.success)
            .having((s) => s.currentGroup, 'currentGroup', _testGroup1)
            .having((s) => s.groups, 'groups', [_testGroup1]),
        // LoadGroupMembers side-effect: members updated
        isA<GroupState>().having((s) => s.members.length, 'members.length', 3),
      ],
    );
  });

  group('bot automation', () {
    blocTest<GroupBloc, GroupState>(
      'SubscribeToMemberJoins subscribes when webhook automation is enabled without welcome text',
      build: () {
        when(() => mockRepository.getBotConfig(_roomId1)).thenAnswer(
          (_) async => const BotConfig(
            enabled: true,
            webhookUrl: 'https://example.com/webhook',
            webhookEvents: {BotAutomationEventType.memberJoined},
          ),
        );
        when(
          () => mockRepository.watchMemberJoinEvents(_roomId1),
        ).thenAnswer((_) => const Stream.empty());
        return GroupBloc(
          mockRepository,
          botWebhookService: mockBotWebhookService,
        );
      },
      act: (bloc) => bloc.add(const SubscribeToMemberJoins(_roomId1)),
      expect: () => <GroupState>[],
      verify: (_) {
        verify(() => mockRepository.getBotConfig(_roomId1)).called(1);
        verify(() => mockRepository.watchMemberJoinEvents(_roomId1)).called(1);
      },
    );

    blocTest<GroupBloc, GroupState>(
      'MemberJoined sends welcome notice and dispatches both webhook events',
      build: () {
        when(() => mockRepository.getBotConfig(_roomId1)).thenAnswer(
          (_) async => const BotConfig(
            enabled: true,
            welcomeMessage: 'Welcome, {name}!',
            webhookUrl: 'https://example.com/webhook',
            webhookEvents: {
              BotAutomationEventType.memberJoined,
              BotAutomationEventType.welcomeMessageSent,
            },
          ),
        );
        when(
          () => mockRepository.getGroupMembers(_roomId1),
        ).thenAnswer((_) async => _testMembers);
        when(
          () => mockRepository.sendBotNotice(_roomId1, 'Welcome, Bob!'),
        ).thenAnswer((_) async {});
        return GroupBloc(
          mockRepository,
          botWebhookService: mockBotWebhookService,
        );
      },
      seed: () =>
          const GroupState.initial().copyWith(currentGroup: _testGroup1),
      act: (bloc) => bloc.add(const MemberJoined(_roomId1, '@bob:server.com')),
      expect: () => <GroupState>[],
      verify: (_) {
        verify(
          () => mockRepository.sendBotNotice(_roomId1, 'Welcome, Bob!'),
        ).called(1);
        verify(
          () => mockBotWebhookService.dispatch(
            config: any(named: 'config'),
            payload: any(named: 'payload'),
          ),
        ).called(2);
      },
    );
  });

  // =========================================================================
  // Event equatable tests
  // =========================================================================

  group('event equality', () {
    test('LoadGroups instances are equal', () {
      expect(const LoadGroups(), equals(const LoadGroups()));
    });

    test('CreateGroup with same props are equal', () {
      const a = CreateGroup(name: 'Test', inviteUserIds: ['@a:s']);
      const b = CreateGroup(name: 'Test', inviteUserIds: ['@a:s']);
      expect(a, equals(b));
    });

    test('CreateGroup with different props are not equal', () {
      const a = CreateGroup(name: 'Test');
      const b = CreateGroup(name: 'Other');
      expect(a, isNot(equals(b)));
    });

    test('LoadGroupDetails with same roomId are equal', () {
      expect(
        const LoadGroupDetails(_roomId1),
        equals(const LoadGroupDetails(_roomId1)),
      );
    });

    test('InviteMembers with same props are equal', () {
      expect(
        const InviteMembers(_roomId1, ['@bob:server.com']),
        equals(const InviteMembers(_roomId1, ['@bob:server.com'])),
      );
    });

    test('KickMember with reason included in props', () {
      const event = KickMember(_roomId1, '@bob:server.com', reason: 'spam');
      expect(event.props, equals([_roomId1, '@bob:server.com', 'spam']));
    });
  });

  // =========================================================================
  // Bloc close / cleanup
  // =========================================================================

  group('cleanup', () {
    test('close cancels stream subscription without error', () async {
      when(
        () => mockRepository.getGroups(),
      ).thenAnswer((_) async => [_testGroup1]);
      when(
        () => mockRepository.getPendingGroupInvites(),
      ).thenAnswer((_) async => []);

      final bloc = GroupBloc(mockRepository);
      bloc.add(const LoadGroups());

      // Wait for events to process
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // close() should not throw
      await expectLater(bloc.close(), completes);
    });

    test('close works even without any events fired', () async {
      final bloc = GroupBloc(mockRepository);
      await expectLater(bloc.close(), completes);
    });
  });
}
