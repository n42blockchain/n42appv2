// Tests for GroupRepositoryImpl — group creation, member management.

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/core/utils/room_metadata_utils.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_group_datasource.dart';
import 'package:n42_chat/src/data/repositories/group_repository_impl.dart';
import 'package:n42_chat/src/domain/entities/group_entity.dart';

class MockMatrixGroupDataSource extends Mock implements MatrixGroupDataSource {}

class MockMatrixClientManager extends Mock implements MatrixClientManager {}

class MockClient extends Mock implements matrix.Client {}

class MockRoom extends Mock implements matrix.Room {}

class MockUser extends Mock implements matrix.User {}

class MockEvent extends Mock implements matrix.Event {}

void main() {
  late GroupRepositoryImpl repository;
  late MockMatrixGroupDataSource mockGroupDS;
  late MockMatrixClientManager mockClientMgr;
  late MockClient mockClient;
  late MockRoom mockRoom;
  late MockEvent mockChannelMetaEvent;
  late MockEvent mockPowerLevelsEvent;

  const testRoomId = '!group1:matrix.org';

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    mockGroupDS = MockMatrixGroupDataSource();
    mockClientMgr = MockMatrixClientManager();
    mockClient = MockClient();
    mockRoom = MockRoom();
    mockChannelMetaEvent = MockEvent();
    mockPowerLevelsEvent = MockEvent();
    repository = GroupRepositoryImpl(mockGroupDS, mockClientMgr);

    when(() => mockClientMgr.client).thenReturn(mockClient);
    when(() => mockClient.userID).thenReturn('@me:matrix.org');
  });

  void stubBaseRoom({
    required matrix.JoinRules joinRules,
    Map<String, Object?>? channelMeta,
    Map<String, Object?>? powerLevels,
    String canonicalAlias = '',
    String? announcement,
    int joinedCount = 12,
    int invitedCount = 3,
    int? maxMembers,
  }) {
    when(() => mockGroupDS.getGroup(testRoomId)).thenReturn(mockRoom);
    when(
      () => mockGroupDS.getGroupMembers(testRoomId),
    ).thenAnswer((_) async => []);
    when(() => mockGroupDS.getGroupAvatarUrl(testRoomId)).thenReturn(null);
    when(
      () => mockGroupDS.getGroupAnnouncement(testRoomId),
    ).thenReturn(announcement ?? 'Pinned notice');
    when(() => mockGroupDS.isGroupOwner(testRoomId, any())).thenReturn(false);
    when(() => mockGroupDS.isGroupAdmin(testRoomId, any())).thenReturn(false);
    when(() => mockGroupDS.getPinnedEventIds(testRoomId)).thenReturn([]);
    when(() => mockGroupDS.getTokenGateConfig(testRoomId)).thenReturn(null);
    when(() => mockGroupDS.getMaxMembers(testRoomId)).thenReturn(maxMembers);
    when(() => mockGroupDS.canInviteMembers(testRoomId)).thenReturn(false);
    when(() => mockGroupDS.canKickMembers(testRoomId)).thenReturn(false);
    when(() => mockGroupDS.canChangeSettings(testRoomId)).thenReturn(true);
    when(
      () => mockGroupDS.canSendStateEvent(
        any(),
        any(),
        fallbackMinPowerLevel: any(named: 'fallbackMinPowerLevel'),
      ),
    ).thenReturn(false);

    when(() => mockRoom.id).thenReturn(testRoomId);
    when(() => mockRoom.getLocalizedDisplayname()).thenReturn('Announcements');
    when(() => mockRoom.topic).thenReturn('Read-only updates');
    when(() => mockRoom.canonicalAlias).thenReturn(canonicalAlias);
    when(() => mockRoom.encrypted).thenReturn(false);
    when(() => mockRoom.joinRules).thenReturn(joinRules);
    when(() => mockRoom.summary).thenReturn(
      matrix.RoomSummary.fromJson({
        'm.joined_member_count': joinedCount,
        'm.invited_member_count': invitedCount,
      }),
    );

    when(
      () => mockRoom.getState('n42.room.channel_meta'),
    ).thenReturn(channelMeta == null ? null : mockChannelMetaEvent);
    if (channelMeta != null) {
      when(() => mockChannelMetaEvent.content).thenReturn(channelMeta);
    }

    when(
      () => mockRoom.getState(matrix.EventTypes.RoomPowerLevels),
    ).thenReturn(powerLevels == null ? null : mockPowerLevelsEvent);
    if (powerLevels != null) {
      when(() => mockPowerLevelsEvent.content).thenReturn(powerLevels);
    }
  }

  group('createGroup', () {
    test('creates group and returns roomId', () async {
      const name = 'Test Group';
      final inviteIds = ['@alice:matrix.org', '@bob:matrix.org'];

      when(
        () => mockGroupDS.createGroup(name: name, inviteUserIds: inviteIds),
      ).thenAnswer((_) async => testRoomId);

      final result = await repository.createGroup(
        name: name,
        inviteUserIds: inviteIds,
      );

      expect(result, testRoomId);
      verify(
        () => mockGroupDS.createGroup(name: name, inviteUserIds: inviteIds),
      ).called(1);
    });

    test('propagates exception on failure', () async {
      when(
        () => mockGroupDS.createGroup(
          name: any(named: 'name'),
          inviteUserIds: any(named: 'inviteUserIds'),
        ),
      ).thenThrow(Exception('Server error'));

      expect(() => repository.createGroup(name: 'Fail Group'), throwsException);
    });
  });

  group('getGroupMembers', () {
    test('returns mapped member list', () async {
      final mockUser1 = MockUser();
      final mockUser2 = MockUser();

      when(() => mockUser1.id).thenReturn('@alice:matrix.org');
      when(() => mockUser1.displayName).thenReturn('Alice');
      when(() => mockUser1.calcDisplayname()).thenReturn('Alice');
      when(() => mockUser1.avatarUrl).thenReturn(null);
      when(() => mockUser1.powerLevel).thenReturn(100);
      when(() => mockUser1.membership).thenReturn(matrix.Membership.join);
      when(
        () => mockGroupDS.getUserPowerLevel(testRoomId, '@alice:matrix.org'),
      ).thenReturn(100);
      when(() => mockGroupDS.getGroupAvatarUrl(testRoomId)).thenReturn(null);

      when(() => mockUser2.id).thenReturn('@bob:matrix.org');
      when(() => mockUser2.displayName).thenReturn('Bob');
      when(() => mockUser2.calcDisplayname()).thenReturn('Bob');
      when(() => mockUser2.avatarUrl).thenReturn(null);
      when(() => mockUser2.powerLevel).thenReturn(0);
      when(() => mockUser2.membership).thenReturn(matrix.Membership.join);
      when(
        () => mockGroupDS.getUserPowerLevel(testRoomId, '@bob:matrix.org'),
      ).thenReturn(0);

      when(
        () => mockGroupDS.getGroupMembers(testRoomId),
      ).thenAnswer((_) async => [mockUser1, mockUser2]);

      final members = await repository.getGroupMembers(testRoomId);

      expect(members, hasLength(2));
      expect(members[0].userId, '@alice:matrix.org');
      expect(members[1].userId, '@bob:matrix.org');
    });

    test('returns empty list for empty group', () async {
      when(
        () => mockGroupDS.getGroupMembers(testRoomId),
      ).thenAnswer((_) async => []);

      final members = await repository.getGroupMembers(testRoomId);

      expect(members, isEmpty);
    });
  });

  group('getGroups', () {
    test('returns empty list when no groups exist', () async {
      when(() => mockGroupDS.getAllGroups()).thenReturn([]);

      final groups = await repository.getGroups();

      expect(groups, isEmpty);
    });
  });

  group('getGroup', () {
    test('maps channel metadata to channel entity fields', () async {
      stubBaseRoom(
        joinRules: matrix.JoinRules.invite,
        canonicalAlias: '#announcements:matrix.org',
        channelMeta: const {
          'parent_room_id': '!parent:matrix.org',
          'members_can_speak': false,
          'show_member_list': false,
          'slow_mode_interval': 30,
        },
      );

      final group = await repository.getGroup(testRoomId);

      expect(group, isNotNull);
      expect(group!.isChannel, isTrue);
      expect(group.subscriberCount, 15);
      expect(group.joinRule, JoinRule.invite);
      expect(group.membersCanSpeak, isFalse);
      expect(group.showMemberList, isFalse);
      expect(group.slowModeInterval, 30);
      expect(group.announcement, 'Pinned notice');
      expect(group.channelUsername, 'announcements');
    });

    test(
      'falls back to room power levels when channel meta omits speak flag',
      () async {
        stubBaseRoom(
          joinRules: matrix.JoinRules.public,
          channelMeta: const {'parent_room_id': '!parent:matrix.org'},
          powerLevels: const {'events_default': 50},
        );

        final group = await repository.getGroup(testRoomId);

        expect(group, isNotNull);
        expect(group!.isChannel, isTrue);
        expect(group.joinRule, JoinRule.public);
        expect(group.membersCanSpeak, isFalse);
        expect(group.showMemberList, isFalse);
        expect(group.slowModeInterval, 0);
      },
    );

    test('classifies rooms larger than 1000 members as super groups', () async {
      stubBaseRoom(
        joinRules: matrix.JoinRules.public,
        joinedCount: 1001,
        invitedCount: 10,
      );

      final group = await repository.getGroup(testRoomId);

      expect(group, isNotNull);
      expect(group!.groupType, GroupType.superGroup);
      expect(group.isSuperGroup, isTrue);
    });
  });

  group('getGroupInviteLink', () {
    test('delegates to datasource', () async {
      final link = buildMatrixToRoomLink(
        roomId: testRoomId,
        canonicalAlias: '#announcements:matrix.org',
      );
      when(() => mockGroupDS.getGroupInviteLink(testRoomId)).thenReturn(link);

      final result = await repository.getGroupInviteLink(testRoomId);

      expect(result, link);
      verify(() => mockGroupDS.getGroupInviteLink(testRoomId)).called(1);
    });
  });

  group('leaveGroup', () {
    test('delegates to datasource', () async {
      when(() => mockGroupDS.leaveGroup(testRoomId)).thenAnswer((_) async {});

      await repository.leaveGroup(testRoomId);

      verify(() => mockGroupDS.leaveGroup(testRoomId)).called(1);
    });
  });
}
