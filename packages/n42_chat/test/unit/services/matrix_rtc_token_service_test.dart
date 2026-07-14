import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/services/voip/matrix_rtc_token_service.dart';

class _MockMatrixClient extends Mock implements matrix.Client {}

const _jwt = 'header_payload.body.sig-123';

void main() {
  test('uses Matrix OpenID and the discovered MatrixRTC token route', () async {
    final client = _MockMatrixClient();
    final openId = matrix.OpenIdCredentials(
      accessToken: 'short-lived-openid-token',
      expiresIn: 3600,
      matrixServerName: 'm.example',
      tokenType: 'Bearer',
    );
    when(() => client.userID).thenReturn('@alice:m.example');
    when(() => client.deviceID).thenReturn('DEVICE');
    when(
      () => client.requestOpenIdToken('@alice:m.example', const {}),
    ).thenAnswer((_) async => openId);
    when(() => client.httpClient).thenReturn(
      MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.toString(), 'https://m.example/livekit/jwt/sfu/get');
        expect(request.headers['authorization'], isNull);
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['room'], '!room:m.example');
        expect(body['device_id'], 'DEVICE');
        expect(body['openid_token'], openId.toJson());
        return http.Response(
          jsonEncode({'url': 'wss://m.example/livekit/sfu', 'jwt': _jwt}),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final credentials = await const MatrixRtcTokenService().fetch(
      client: client,
      serviceUrl: 'https://m.example/livekit/jwt',
      roomId: '!room:m.example',
      legacyRoomName: 'mx__room_m_example',
      participantName: 'Alice',
      enableVideo: true,
    );

    expect(credentials.token, _jwt);
    expect(credentials.serverUrl, 'wss://m.example/livekit/sfu');
    verify(
      () => client.requestOpenIdToken('@alice:m.example', const {}),
    ).called(1);
  });

  test('rejects an official success response without an SFU URL', () async {
    final client = _clientWithOpenId(
      MockClient((_) async => http.Response(jsonEncode({'jwt': _jwt}), 200)),
    );

    await expectLater(
      const MatrixRtcTokenService().fetch(
        client: client,
        serviceUrl: 'https://m.example/livekit/jwt',
        roomId: '!room:m.example',
        legacyRoomName: 'mx__room_m_example',
        participantName: 'Alice',
        enableVideo: true,
      ),
      throwsA(
        isA<MatrixRtcTokenException>()
            .having((error) => error.code, 'code', 'livekit_token_fetch_failed')
            .having((error) => error.statusCode, 'statusCode', 200),
      ),
    );
  });

  test('does not bypass an official authorization rejection', () async {
    var requestCount = 0;
    final client = _clientWithOpenId(
      MockClient((_) async {
        requestCount++;
        return http.Response('{}', 401);
      }),
    );

    await expectLater(
      const MatrixRtcTokenService().fetch(
        client: client,
        serviceUrl: 'https://m.example/livekit/jwt',
        roomId: '!room:m.example',
        legacyRoomName: 'mx__room_m_example',
        participantName: 'Alice',
        enableVideo: false,
      ),
      throwsA(
        isA<MatrixRtcTokenException>().having(
          (error) => error.statusCode,
          'statusCode',
          401,
        ),
      ),
    );
    expect(requestCount, 1);
  });

  test(
    'does not expose the Matrix token when OpenID exchange is unreachable',
    () async {
      var requestCount = 0;
      final client = _clientWithOpenId(
        MockClient((request) async {
          requestCount++;
          expect(request.headers['authorization'], isNull);
          throw http.ClientException('offline');
        }),
        accessToken: 'matrix-access-token',
      );

      await expectLater(
        const MatrixRtcTokenService().fetch(
          client: client,
          serviceUrl: 'https://m.example/livekit/jwt',
          roomId: '!room:m.example',
          legacyRoomName: 'mx__room_m_example',
          participantName: 'Alice',
          enableVideo: false,
        ),
        throwsA(isA<MatrixRtcTokenException>()),
      );
      expect(requestCount, 1);
    },
  );

  test('falls back to the legacy service only when route is absent', () async {
    var requestCount = 0;
    final client = _clientWithOpenId(
      MockClient((request) async {
        requestCount++;
        if (request.url.path.endsWith('/sfu/get')) {
          return http.Response('{}', 404);
        }
        expect(request.url.path, '/livekit/jwt');
        expect(request.headers['authorization'], 'Bearer matrix-access-token');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['room'], 'mx__room_m_example');
        return http.Response(jsonEncode({'token': _jwt}), 200);
      }),
      accessToken: 'matrix-access-token',
    );

    final credentials = await const MatrixRtcTokenService().fetch(
      client: client,
      serviceUrl: 'https://m.example/livekit/jwt',
      roomId: '!room:m.example',
      legacyRoomName: 'mx__room_m_example',
      participantName: 'Alice',
      enableVideo: false,
    );

    expect(credentials.token, _jwt);
    expect(credentials.serverUrl, isNull);
    expect(requestCount, 2);
  });
}

_MockMatrixClient _clientWithOpenId(
  http.Client httpClient, {
  String? accessToken,
}) {
  final client = _MockMatrixClient();
  final openId = matrix.OpenIdCredentials(
    accessToken: 'short-lived-openid-token',
    expiresIn: 3600,
    matrixServerName: 'm.example',
    tokenType: 'Bearer',
  );
  when(() => client.userID).thenReturn('@alice:m.example');
  when(() => client.deviceID).thenReturn('DEVICE');
  when(() => client.accessToken).thenReturn(accessToken);
  when(
    () => client.requestOpenIdToken('@alice:m.example', const {}),
  ).thenAnswer((_) async => openId);
  when(() => client.httpClient).thenReturn(httpClient);
  return client;
}
