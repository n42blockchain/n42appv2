import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_reaction_datasource.dart';

class _MockClientManager extends Mock implements MatrixClientManager {}

class _MockClient extends Mock implements matrix.Client {}

class _MockRoom extends Mock implements matrix.Room {}

class _MockEvent extends Mock implements matrix.Event {}

class _FakeTimeline extends Fake implements matrix.Timeline {}

void main() {
  late _MockClientManager clientManager;
  late _MockClient client;
  late _MockRoom room;
  late _MockEvent event;
  late MatrixReactionDataSource datasource;

  setUpAll(() {
    registerFallbackValue(_MockEvent());
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(_FakeTimeline());
  });

  setUp(() {
    clientManager = _MockClientManager();
    client = _MockClient();
    room = _MockRoom();
    event = _MockEvent();
    datasource = MatrixReactionDataSource(clientManager);

    when(() => clientManager.client).thenReturn(client);
    when(() => client.getRoomById('!room:server.test')).thenReturn(room);
  });

  test('sendReply uses getEventById before timeline fallback', () async {
    when(() => room.getEventById(r'$original')).thenAnswer((_) async => event);
    when(
      () => room.sendEvent(any(), inReplyTo: any(named: 'inReplyTo')),
    ).thenAnswer((_) async => r'$reply');

    final result = await datasource.sendReply(
      '!room:server.test',
      r'$original',
      '回复内容',
    );

    expect(result, r'$reply');
    verify(() => room.getEventById(r'$original')).called(1);
    verifyNever(() => room.getTimeline());
    verify(
      () => room.sendEvent(
        any(
          that: predicate<Map<String, dynamic>>(
            (content) => content['body'] == '回复内容',
          ),
        ),
        inReplyTo: event,
      ),
    ).called(1);
  });
}
