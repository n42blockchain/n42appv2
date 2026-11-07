import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
// ignore: depend_on_referenced_packages
import 'package:matrix/matrix.dart';
import 'package:n42_wallet/features/live/services/live_chat_service.dart';
import 'package:n42_wallet/features/live/services/live_room_factory.dart';

class _Database extends Mock implements DatabaseApi {}

void main() {
  test(
    'creates inactive broadcast marker atomically with a public room',
    () async {
      Map<String, dynamic>? request;
      final database = _Database();
      when(() => database.close()).thenAnswer((_) async {});
      final client = Client(
        'live-room-creation',
        database: database,
        httpClient: MockClient((req) async {
          expect(req.method, 'POST');
          expect(req.url.path, endsWith('/createRoom'));
          request = jsonDecode(req.body) as Map<String, dynamic>;
          return http.Response(
            '{"room_id":"!live:example"}',
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      client.homeserver = Uri.parse('https://matrix.example');
      client.accessToken = 'synthetic-qa-token';
      addTearDown(client.dispose);
      expect(
        await createLiveBroadcastRoom(client, name: '  Meeting  '),
        '!live:example',
      );
      expect(request!['name'], 'Meeting');
      expect(request!['preset'], 'public_chat');
      expect(request!['visibility'], 'public');
      final states = request!['initial_state'] as List;
      final marker = states.single as Map<String, dynamic>;
      expect(marker['type'], 'n42.live.status');
      expect(marker['state_key'], '');
      expect(marker['content'], {'live': false});
      expect(
        LiveChatService.isLiveState(
          Map<String, dynamic>.from(marker['content'] as Map),
        ),
        isFalse,
      );
    },
  );
}
