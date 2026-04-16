import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';
import 'package:n42_chat/src/data/datasources/matrix/message/matrix_message_operations.dart';

class _MockClientManager extends Mock implements MatrixClientManager {}

class _MockClient extends Mock implements matrix.Client {}

void main() {
  late _MockClientManager clientManager;
  late _MockClient client;
  late MatrixMessageOperations operations;

  setUp(() {
    clientManager = _MockClientManager();
    client = _MockClient();
    operations = MatrixMessageOperations(clientManager);

    when(() => clientManager.client).thenReturn(client);
    when(() => client.userID).thenReturn('@me:server.test');
    when(
      () => client.setRoomStateWithKey(any(), any(), any(), any()),
    ).thenAnswer((_) async => 'ok');
  });

  test('serializes live location coordinates as strings for Matrix state', () async {
    await operations.updateLiveLocation(
      '!room:server.test',
      43.6532,
      -79.3832,
      5.0,
    );

    final captured = verify(
      () => client.setRoomStateWithKey(captureAny(), captureAny(), captureAny(), captureAny()),
    ).captured;
    final payload = captured[3] as Map<String, dynamic>;

    expect(captured[0], '!room:server.test');
    expect(captured[1], 'n42.live_location.update');
    expect(captured[2], '@me:server.test');
    expect(payload['latitude'], '43.653200');
    expect(payload['longitude'], '-79.383200');
    expect(payload['accuracy'], '5.00');
    expect(payload['updated_at'], isA<String>());
  });
}
