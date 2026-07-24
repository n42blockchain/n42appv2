import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:n42_chat/src/data/datasources/remote/id_hub_api.dart';

class _HangingClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      Completer<http.StreamedResponse>().future;
}

class _FailingClient extends http.BaseClient {
  bool requested = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    requested = true;
    throw StateError('a request must not be sent');
  }
}

void main() {
  test(
    'wallet challenge times out instead of blocking login fallback',
    () async {
      final api = IdHubApi(
        baseUrl: 'https://id.n42.ai',
        client: _HangingClient(),
        requestTimeout: Duration.zero,
      );

      await expectLater(
        api.createWalletChallenge(
          address: '0x0000000000000000000000000000000000000000',
        ),
        throwsA(
          isA<IdHubException>().having(
            (error) => error.message,
            'message',
            'ID Hub request timed out',
          ),
        ),
      );
    },
  );

  test(
    'plaintext Hub URL is rejected before an auth request is sent',
    () async {
      final client = _FailingClient();
      final api = IdHubApi(baseUrl: 'http://id.n42.ai', client: client);

      await expectLater(
        api.createWalletChallenge(
          address: '0x0000000000000000000000000000000000000000',
        ),
        throwsA(isA<IdHubException>()),
      );
      expect(client.requested, isFalse);
    },
  );

  test(
    'wallet verification declares the Chat audience during rollout',
    () async {
      late http.Request request;
      final api = IdHubApi(
        baseUrl: 'https://id.n42.ai',
        client: MockClient((received) async {
          request = received;
          return http.Response(
            jsonEncode({
              'sub': 'did:plc:chatuser',
              'matrix_user_id': '@chatuser:si46.world',
              'matrix_access_token': 'matrix-token',
              'matrix_homeserver': 'https://m.si46.world',
            }),
            200,
          );
        }),
      );

      final response = await api.verifyWalletLogin(
        challengeId: 'challenge',
        signature: '0xsignature',
      );

      expect(jsonDecode(request.body)['aud'], 'chat');
      expect(response.hasMatrixCredentials, isTrue);
    },
  );
}
