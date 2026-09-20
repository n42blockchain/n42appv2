import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_group_datasource.dart';

class _MockMatrixClientManager extends Mock implements MatrixClientManager {}

class _MockClient extends Mock implements matrix.Client {}

class _MockRoom extends Mock implements matrix.Room {}

class _MockEvent extends Mock implements matrix.Event {}

void main() {
  late _MockMatrixClientManager clientManager;
  late _MockClient client;
  late _MockRoom room;
  late MatrixGroupDataSource dataSource;

  const roomId = '!group:example.com';

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    clientManager = _MockMatrixClientManager();
    client = _MockClient();
    room = _MockRoom();
    dataSource = MatrixGroupDataSource(clientManager);

    when(() => clientManager.client).thenReturn(client);
    when(() => client.getRoomById(roomId)).thenReturn(room);
  });

  test(
    'group creation includes avatar and all invites before room sync',
    () async {
      when(() => client.getRoomById(roomId)).thenReturn(null);
      when(
        () => client.uploadContent(
          any(),
          filename: any(named: 'filename'),
          contentType: any(named: 'contentType'),
        ),
      ).thenAnswer((_) async => Uri.parse('mxc://hs/avatar'));
      when(
        () => client.createRoom(
          name: any(named: 'name'),
          topic: any(named: 'topic'),
          invite: any(named: 'invite'),
          preset: any(named: 'preset'),
          visibility: any(named: 'visibility'),
          initialState: any(named: 'initialState'),
        ),
      ).thenAnswer((call) async {
        expect(call.namedArguments[#invite], ['@b:hs', '@c:hs']);
        final states =
            call.namedArguments[#initialState] as List<matrix.StateEvent>;
        expect(
          states.singleWhere((s) => s.type == 'm.room.avatar').content['url'],
          'mxc://hs/avatar',
        );
        return roomId;
      });
      expect(
        await dataSource.createGroup(
          name: 'Named group',
          inviteUserIds: ['@b:hs', '@c:hs'],
          avatar: Uint8List.fromList([1, 2, 3]),
        ),
        roomId,
      );
    },
  );
  test('live directory rooms are excluded from ordinary groups', () {
    when(() => client.rooms).thenReturn([room]);
    when(() => room.isDirectChat).thenReturn(false);
    when(() => room.tags).thenReturn({});
    when(() => room.topic).thenReturn('n42.live.directory:v1:123');
    when(() => room.membership).thenReturn(matrix.Membership.join);
    expect(dataSource.getAllGroups(), isEmpty);
    when(() => room.topic).thenReturn('Normal group topic');
    expect(dataSource.getAllGroups(), [room]);
  });
  for (final reason in ['n42_moments', 'n42_stories']) {
    test('stripped $reason invitations are not ordinary group requests', () {
      when(() => client.userID).thenReturn('@me:hs');
      when(() => client.rooms).thenReturn([room]);
      when(() => room.client).thenReturn(client);
      when(() => room.tags).thenReturn({});
      when(() => room.isDirectChat).thenReturn(false);
      when(() => room.topic).thenReturn('');
      when(() => room.membership).thenReturn(matrix.Membership.invite);
      final member = _MockEvent();
      when(
        () => member.content,
      ).thenReturn({'membership': 'invite', 'reason': reason});
      when(
        () => room.getState(matrix.EventTypes.RoomMember, '@me:hs'),
      ).thenReturn(member);
      expect(dataSource.getPendingGroupInvites(), isEmpty);
      when(() => member.content).thenReturn({'membership': 'invite'});
      expect(dataSource.getPendingGroupInvites(), [room]);
    });
  }

  group('getGroupAnnouncement', () {
    test('falls back to room topic when announcement state is absent', () {
      when(() => room.getState('n42.room.announcement')).thenReturn(null);
      when(() => room.topic).thenReturn('Room topic');

      final announcement = dataSource.getGroupAnnouncement(roomId);

      expect(announcement, 'Room topic');
    });

    test('does not fall back to topic after explicit clear', () {
      final state = _MockEvent();
      when(() => room.getState('n42.room.announcement')).thenReturn(state);
      when(() => state.content).thenReturn(<String, Object?>{});
      when(() => room.topic).thenReturn('Room topic');

      final announcement = dataSource.getGroupAnnouncement(roomId);

      expect(announcement, isNull);
    });
  });
}
