import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/identity/api/id_hub_api.dart';
import 'package:n42_wallet/features/identity/models/id_hub_models.dart';

const _did = 'did:plc:aaaaaaaaaaaaaaaaaaaaaaaa';
const _sessionId = '11111111-1111-4111-8111-111111111111';

String _hubToken({String aud = 'wallet-api', String sub = _did}) {
  String encode(Object value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  return '${encode({'alg': 'ES256', 'typ': 'JWT'})}.'
      '${encode({'iss': 'did:web:id.n42.ai', 'sub': sub, 'aud': aud, 'exp': DateTime.now().millisecondsSinceEpoch ~/ 1000 + 900})}.signature';
}

class _QueuedResponse {
  const _QueuedResponse(this.statusCode, this.data);

  final int statusCode;
  final Object? data;
}

class _RecordingAdapter implements HttpClientAdapter {
  final List<_QueuedResponse> responses = [];
  final List<RequestOptions> requests = [];

  void enqueue(int statusCode, [Object? data]) {
    responses.add(_QueuedResponse(statusCode, data));
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (responses.isEmpty) throw StateError('No queued ID Hub response');
    final response = responses.removeAt(0);
    final body = response.data == null ? '' : jsonEncode(response.data);
    return ResponseBody.fromString(
      body,
      response.statusCode,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

({IdHubApi api, _RecordingAdapter adapter}) _client({
  String baseUrl = 'https://id-test.n42.ai/',
}) {
  final dio = Dio();
  final adapter = _RecordingAdapter();
  dio.httpClientAdapter = adapter;
  return (api: IdHubApi(baseUrl: baseUrl, dio: dio), adapter: adapter);
}

void main() {
  test('disabled client fails locally before making a request', () async {
    final (:api, :adapter) = _client(baseUrl: 'not-a-url');

    expect(api.isEnabled, isFalse);
    await expectLater(
      api.createWalletChallenge(address: '0xABC'),
      throwsA(
        isA<IdHubException>().having(
          (error) => error.code,
          'code',
          'not-configured',
        ),
      ),
    );
    expect(adapter.requests, isEmpty);
  });

  test('client rejects a plaintext Hub URL before making a request', () async {
    final (:api, :adapter) = _client(baseUrl: 'http://id-test.n42.ai');

    expect(api.isEnabled, isFalse);
    await expectLater(
      api.createWalletChallenge(address: '0xABC'),
      throwsA(isA<IdHubException>()),
    );
    expect(adapter.requests, isEmpty);
  });

  test('client allows plaintext http only for dev loopback hosts', () {
    for (final url in const [
      'http://localhost:8080',
      'http://127.0.0.1:8080',
      'http://10.0.2.2:8080',
    ]) {
      expect(_client(baseUrl: url).api.isEnabled, isTrue, reason: url);
    }
  });

  test('client rejects non-canonical Hub URLs', () {
    for (final url in const [
      'https://user:pw@id.n42.ai', // credentials smuggled into every request
      'https://id.n42.ai:8443', // non-default port
      'https://id.n42.ai/v2', // path prefix
      'https://id.n42.ai?x=1', // query
      'https://id.n42.ai#f', // fragment
      'ftp://id.n42.ai',
      'not a url',
    ]) {
      expect(_client(baseUrl: url).api.isEnabled, isFalse, reason: url);
    }
  });

  test(
    'wallet challenge normalizes address and decodes the response',
    () async {
      final (:api, :adapter) = _client();
      adapter.enqueue(200, {
        'challenge_id': 'challenge-1',
        'message': 'N42 ID challenge',
        'expires_at': '2099-01-01T00:00:00Z',
      });

      final result = await api.createWalletChallenge(
        address: '0xAaBb',
        aud: 'wallet-api',
      );

      expect(result.challengeId, 'challenge-1');
      expect(result.message, 'N42 ID challenge');
      expect(
        adapter.requests.single.uri.toString(),
        'https://id-test.n42.ai/v1/auth/wallet/challenge',
      );
      expect(adapter.requests.single.data, {
        'address': '0xaabb',
        'chain': IdHubApi.defaultChainCaip2,
        'aud': 'wallet-api',
      });
    },
  );

  test(
    'wallet verification sends signer metadata and decodes token fields',
    () async {
      final (:api, :adapter) = _client();
      adapter.enqueue(200, {
        'access_token': _hubToken(),
        'token_type': 'Bearer',
        'expires_in': 900,
        'refresh_token': 'refresh-token',
        'scope': 'openid',
        'sub': _did,
        'sid': 'session-1',
        'did_created': true,
      });

      final result = await api.verifyWalletLogin(
        challengeId: 'challenge-1',
        signature: '0xsignature',
        signerType: 'eoa',
        chainId: 1142,
      );

      expect(result.didCreated, isTrue);
      expect(result.token.accessToken, startsWith('ey'));
      expect(result.token.refreshToken, 'refresh-token');
      expect(result.token.sub, _did);
      expect(adapter.requests.single.data, {
        'challenge_id': 'challenge-1',
        'signature': '0xsignature',
        'signer_type': 'eoa',
        'chain_id': 1142,
        'aud': 'wallet-api',
      });
    },
  );

  test(
    'bind session get, prepare, and empty completion use canonical paths',
    () async {
      final (:api, :adapter) = _client();
      adapter
        ..enqueue(200, {
          'session_id': _sessionId,
          'type': 'wallet-binding',
          'status': 'pending',
          'message': 'Bind this wallet',
          'expires_at': '2099-01-01T00:00:00Z',
        })
        ..enqueue(200, {
          'challenge_id': 'challenge-2',
          'message': 'N42 ID bind challenge',
          'expires_at': '2099-01-01T00:00:00Z',
        })
        ..enqueue(204);

      final session = await api.getBindSession(_sessionId);
      final challenge = await api.prepareBindSession(
        sessionId: _sessionId,
        address: '0xAABB',
      );
      await api.completeBindSession(
        sessionId: _sessionId,
        challengeId: challenge.challengeId,
        signature: '0xsig',
      );

      expect(session.status, 'pending');
      expect(session.message, 'Bind this wallet');
      expect(challenge.challengeId, 'challenge-2');
      expect(adapter.requests.map((request) => request.uri.path), [
        '/v1/bind-sessions/$_sessionId',
        '/v1/bind-sessions/$_sessionId/prepare',
        '/v1/bind-sessions/$_sessionId/complete',
      ]);
      expect(adapter.requests[1].data, {
        'address': '0xaabb',
        'chain': IdHubApi.defaultChainCaip2,
      });
    },
  );

  test(
    'refresh uses form encoding and revoke uses bearer authorization',
    () async {
      final (:api, :adapter) = _client();
      adapter
        ..enqueue(200, {
          'access_token': _hubToken(),
          'token_type': 'Bearer',
          'expires_in': 900,
          'refresh_token': 'next-refresh',
          'sub': _did,
        })
        ..enqueue(204);

      final refreshed = await api.refresh('current-refresh', expectedDid: _did);
      await api.revoke(
        accessToken: 'current-access',
        refreshToken: 'next-refresh',
      );

      expect(refreshed.accessToken, startsWith('ey'));
      expect(
        adapter.requests[0].contentType,
        Headers.formUrlEncodedContentType,
      );
      expect(adapter.requests[0].data, {
        'grant_type': 'refresh_token',
        'refresh_token': 'current-refresh',
      });
      expect(
        adapter.requests[1].headers['Authorization'],
        'Bearer current-access',
      );
      expect(adapter.requests[1].data, {'refresh_token': 'next-refresh'});
    },
  );

  test(
    'problem+json errors preserve status, stable code, and detail',
    () async {
      final (:api, :adapter) = _client();
      adapter.enqueue(409, {
        'type': 'https://id.n42.ai/problems/binding-conflict',
        'title': 'Conflict',
        'detail': 'Wallet already linked',
      });

      await expectLater(
        api.prepareBindSession(sessionId: _sessionId, address: '0xAABB'),
        throwsA(
          isA<IdHubException>()
              .having((error) => error.statusCode, 'status', 409)
              .having((error) => error.code, 'code', 'binding-conflict')
              .having(
                (error) => error.message,
                'message',
                'Wallet already linked',
              ),
        ),
      );
    },
  );

  test('unexpected non-object success response is rejected', () async {
    final (:api, :adapter) = _client();
    adapter.enqueue(200, ['unexpected']);

    await expectLater(
      api.getBindSession(_sessionId),
      throwsA(
        isA<IdHubException>().having(
          (error) => error.message,
          'message',
          'Unexpected ID Hub response',
        ),
      ),
    );
  });
}
