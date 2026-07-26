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

  test('plaintext Hub URL is rejected before an auth request is sent', () {
    final client = _FailingClient();
    expect(
      () => IdHubApi(baseUrl: 'http://id.n42.ai', client: client),
      throwsArgumentError,
    );
    expect(client.requested, isFalse);
  });

  test(
    'wallet challenge binds the Chat audience and N42 mainnet chain',
    () async {
      late http.Request request;
      final api = IdHubApi(
        baseUrl: 'https://id.n42.ai',
        client: MockClient((received) async {
          request = received;
          return http.Response(
            jsonEncode({
              'challenge_id': '123e4567-e89b-42d3-a456-426614174000',
              'message': 'N42 ID v1 ...',
            }),
            200,
          );
        }),
      );

      await api.createWalletChallenge(
        address: '0x0000000000000000000000000000000000000000',
      );

      expect(jsonDecode(request.body)['aud'], 'chat');
      expect(jsonDecode(request.body)['chain'], 'eip155:94');
    },
  );
}
