import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/integration/bridge/bridge_bot_service.dart';
import 'package:n42_chat/src/integration/bridge/bridge_platform.dart';
import 'package:n42_chat/src/integration/bridge/bridge_state.dart';

class _MockClient extends Mock implements matrix.Client {}

class _MockRoom extends Mock implements matrix.Room {}

void main() {
  late _MockClient client;
  late _MockRoom room;
  late BridgeBotService service;

  const roomId = '!bridge:example.com';

  setUp(() {
    client = _MockClient();
    room = _MockRoom();
    when(() => client.homeserver).thenReturn(Uri.parse('https://example.com'));
    when(() => client.getRoomById(roomId)).thenReturn(room);
    when(() => room.sendTextEvent(any())).thenAnswer((_) async => '\$event');

    service = BridgeBotService(client: client);
    service.registerManagementRoomForTest(BridgePlatform.discord, roomId);
  });

  tearDown(() async {
    await service.dispose();
  });

  test(
    'rejects a second concurrent command for the same management room',
    () async {
      final first = service.sendCommand(
        BridgePlatform.discord,
        BridgeBotCommand.status,
        timeout: const Duration(milliseconds: 300),
      );

      final second = await service.sendCommand(
        BridgePlatform.discord,
        BridgeBotCommand.login,
      );

      expect(second.isSuccess, isFalse);
      expect(second.text, contains('already in progress'));

      service.injectResponseForTest(roomId: roomId, text: 'Logged in as alice');
      final firstResponse = await first;

      expect(firstResponse.detectedStatus, BridgeConnectionStatus.connected);
      expect(firstResponse.remoteUsername, 'alice');
      verify(() => room.sendTextEvent('status')).called(1);
      verifyNever(() => room.sendTextEvent('login'));
    },
  );

  test(
    'disposing the service completes pending commands with a failure response',
    () async {
      final pending = service.sendCommand(
        BridgePlatform.discord,
        BridgeBotCommand.status,
        timeout: const Duration(seconds: 5),
      );

      await Future<void>.delayed(Duration.zero);
      await service.dispose();

      final response = await pending;
      expect(response.isSuccess, isFalse);
      expect(response.text, 'Bridge service disposed');
    },
  );
}
