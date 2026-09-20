import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:matrix/matrix.dart';
import 'package:matrix/encryption/encryption.dart';
import 'package:matrix/encryption/key_manager.dart';
import 'package:matrix/encryption/utils/stored_inbound_group_session.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/core/encryption/session_preserving_client.dart';

class _Database extends Mock implements DatabaseApi {}

class _Encryption extends Mock implements Encryption {}

class _Keys extends Mock implements KeyManager {}

class _Client extends SessionPreservingClient {
  _Client(DatabaseApi database, http.Client transport, this.crypto)
    : super('fixture', database: database, httpClient: transport);
  final Encryption crypto;
  @override
  Encryption get encryption => crypto;
}

void main() {
  test(
    'loads durable keys before sync and only once per encryption identity',
    () async {
      final database = _Database();
      final crypto = _Encryption();
      final keys = _Keys();
      var loaded = false;
      var requests = 0;
      final transport = MockClient((request) async {
        expect(loaded, isTrue);
        requests++;
        return http.Response('{"next_batch":"fixture"}', 200);
      });
      final client = _Client(database, transport, crypto)
        ..homeserver = Uri.parse('https://fixture.invalid')
        ..accessToken = 'fixture-token';
      when(() => crypto.keyManager).thenReturn(keys);
      when(() => database.getAllInboundGroupSessions()).thenAnswer(
        (_) async => [
          StoredInboundGroupSession(
            roomId: '!r:hs',
            sessionId: 's',
            pickle: '',
            content: '{}',
            indexes: '{}',
            allowedAtIndex: '{}',
            senderKey: '',
            senderClaimedKeys: '{}',
          ),
        ],
      );
      when(() => keys.loadInboundGroupSession('!r:hs', 's')).thenAnswer((
        _,
      ) async {
        loaded = true;
        return null;
      });
      await client.sync();
      await client.sync();
      expect(requests, 2);
      verify(() => database.getAllInboundGroupSessions()).called(1);
      verify(() => keys.loadInboundGroupSession('!r:hs', 's')).called(1);
      transport.close();
    },
  );

  test(
    'disk failure prevents sync and the next attempt retries loading',
    () async {
      final database = _Database();
      final crypto = _Encryption();
      var requests = 0;
      final transport = MockClient((request) async {
        requests++;
        return http.Response('{"next_batch":"fixture"}', 200);
      });
      final client = _Client(database, transport, crypto)
        ..homeserver = Uri.parse('https://fixture.invalid')
        ..accessToken = 'fixture-token';
      when(
        () => database.getAllInboundGroupSessions(),
      ).thenThrow(StateError('disk unavailable'));
      await expectLater(client.sync(), throwsStateError);
      expect(requests, 0);
      when(
        () => database.getAllInboundGroupSessions(),
      ).thenAnswer((_) async => []);
      await client.sync();
      expect(requests, 1);
      transport.close();
    },
  );
}
