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

  setUp(() {
    clientManager = _MockMatrixClientManager();
    client = _MockClient();
    room = _MockRoom();
    dataSource = MatrixGroupDataSource(clientManager);

    when(() => clientManager.client).thenReturn(client);
    when(() => client.getRoomById(roomId)).thenReturn(room);
  });

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
