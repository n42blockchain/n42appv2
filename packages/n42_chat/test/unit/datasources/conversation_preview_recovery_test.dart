import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:matrix/encryption/encryption.dart';
import 'package:matrix/src/utils/cached_stream_controller.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_room_datasource.dart';

class _Manager extends Mock implements MatrixClientManager {}

class _Client extends Mock implements matrix.Client {}

class _Room extends Mock implements matrix.Room {}

class _Encryption extends Mock implements Encryption {}

void main() {
  late _Manager manager;
  late _Client client;
  late _Room room;
  late MatrixRoomDataSource source;
  late CachedStreamController<matrix.SyncUpdate> sync;
  late CachedStreamController<matrix.EventUpdate> events;
  late CachedStreamController<String> keys;
  setUp(() {
    manager = _Manager();
    client = _Client();
    room = _Room();
    sync = CachedStreamController();
    events = CachedStreamController();
    keys = CachedStreamController();
    when(() => manager.client).thenReturn(client);
    when(() => client.rooms).thenReturn([room]);
    when(() => client.onSync).thenReturn(sync);
    when(() => client.onEvent).thenReturn(events);
    when(() => room.id).thenReturn('!room:hs');
    when(() => room.tags).thenReturn({});
    when(() => room.membership).thenReturn(matrix.Membership.join);
    when(() => room.client).thenReturn(client);
    when(() => room.onSessionKeyReceived).thenReturn(keys);
    source = MatrixRoomDataSource(manager);
  });
  tearDown(() async {
    await sync.close();
    await events.close();
    await keys.close();
  });

  test(
    'key arrival refreshes the conversation preview without a new sync',
    () async {
      final encrypted = matrix.Event(
        type: matrix.EventTypes.Encrypted,
        content: {'msgtype': matrix.MessageTypes.BadEncrypted},
        senderId: '@peer:hs',
        eventId: r'$fixture',
        room: room,
        originServerTs: DateTime(2026),
      );
      final decrypted = matrix.Event(
        type: matrix.EventTypes.Message,
        content: {'msgtype': matrix.MessageTypes.Text, 'body': 'Hello'},
        senderId: '@peer:hs',
        eventId: r'$fixture',
        room: room,
        originServerTs: DateTime(2026),
      );
      final crypto = _Encryption();
      var received = false;
      when(() => room.lastEvent).thenReturn(encrypted);
      when(() => client.encryption).thenReturn(crypto);
      when(
        () => crypto.decryptRoomEventSync(encrypted),
      ).thenAnswer((_) => received ? decrypted : encrypted);
      expect(source.getLastMessagePreview(room), '[Encrypted]');
      final preview = source.onRoomsChanged!
          .map((rooms) => source.getLastMessagePreview(rooms.single))
          .first;
      received = true;
      keys.add('session');
      expect(await preview.timeout(const Duration(seconds: 2)), 'Hello');
    },
  );

  test(
    'same room and timestamp never reuse a previous account room object',
    () {
      expect(source.getSortedRooms().single, same(room));
      final otherClient = _Client();
      final otherRoom = _Room();
      when(() => otherRoom.id).thenReturn('!room:hs');
      when(() => otherRoom.tags).thenReturn({});
      when(() => otherRoom.membership).thenReturn(matrix.Membership.join);
      when(() => otherClient.rooms).thenReturn([otherRoom]);
      when(() => manager.client).thenReturn(otherClient);
      expect(source.getSortedRooms().single, same(otherRoom));
    },
  );
}
