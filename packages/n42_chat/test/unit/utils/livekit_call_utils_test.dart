import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/utils/livekit_call_utils.dart';

const _jwt = 'header_payload.body.sig-123';

void main() {
  group('buildLiveKitRoomName', () {
    test('trims and sanitizes matrix room ids', () {
      expect(buildLiveKitRoomName(' !abc:server '), 'mx__abc_server');
    });

    test('falls back for blank ids', () {
      expect(buildLiveKitRoomName('   '), 'mx_group_call');
    });
  });

  group('extractLiveKitToken', () {
    test('accepts raw jwt responses', () {
      expect(extractLiveKitToken(' $_jwt '), _jwt);
    });

    test('accepts nested json token responses', () {
      final body = jsonEncode({
        'data': {'access_token': _jwt},
      });
      expect(extractLiveKitToken(body), _jwt);
    });

    test('rejects non-jwt success bodies', () {
      expect(extractLiveKitToken('OK'), isNull);
      expect(extractLiveKitToken('<html>not a token</html>'), isNull);
      expect(extractLiveKitToken(jsonEncode({'token': 'not-a-jwt'})), isNull);
    });
  });

  group('extractLiveKitConnectionCredentials', () {
    test('accepts the MatrixRTC authorization service response', () {
      final credentials = extractLiveKitConnectionCredentials(
        jsonEncode({'url': 'wss://m.si46.world/livekit/sfu', 'jwt': _jwt}),
      );

      expect(credentials?.token, _jwt);
      expect(credentials?.serverUrl, 'wss://m.si46.world/livekit/sfu');
    });

    test('does not trust an invalid server URL', () {
      final credentials = extractLiveKitConnectionCredentials(
        jsonEncode({'url': 'https://invalid-sfu.example', 'jwt': _jwt}),
      );

      expect(credentials?.token, _jwt);
      expect(credentials?.serverUrl, isNull);
    });
  });

  group('buildMatrixRtcTokenUri', () {
    test('appends the legacy MatrixRTC token route to the focus URL', () {
      expect(
        buildMatrixRtcTokenUri(
          'https://m.si46.world/livekit/jwt?source=well-known',
        ).toString(),
        'https://m.si46.world/livekit/jwt/sfu/get?source=well-known',
      );
    });

    test('keeps an explicit token endpoint unchanged', () {
      expect(
        buildMatrixRtcTokenUri(
          'https://m.si46.world/livekit/jwt/sfu/get',
        ).toString(),
        'https://m.si46.world/livekit/jwt/sfu/get',
      );
    });
  });

  group('buildLiveKitTokenUri', () {
    test('preserves base query and trims values', () {
      final uri = buildLiveKitTokenUri(
        ' https://m.si46.world/livekit/jwt?via=app ',
        roomName: ' room ',
        participantId: ' @u:s ',
        participantName: ' Alice ',
        enableVideo: true,
        conversationId: ' !r:s ',
      );

      expect(
        uri.toString(),
        'https://m.si46.world/livekit/jwt?via=app&room=room&identity=%40u%3As&name=Alice&video=1&conversation_id=%21r%3As',
      );
    });
  });

  group('normalizeLiveKitHttpUrl', () {
    test('accepts http urls and strips fragments', () {
      expect(
        normalizeLiveKitHttpUrl(' https://m.si46.world/livekit/jwt#x '),
        'https://m.si46.world/livekit/jwt',
      );
    });

    test('rejects ws and invalid urls', () {
      expect(normalizeLiveKitHttpUrl('wss://m.si46.world/livekit/sfu'), isNull);
      expect(normalizeLiveKitHttpUrl('not a url'), isNull);
    });
  });

  group('deriveLiveKitWsUrl', () {
    test('maps https jwt endpoint to wss sfu endpoint', () {
      expect(
        deriveLiveKitWsUrl('https://m.si46.world/livekit/jwt'),
        'wss://m.si46.world/livekit/sfu',
      );
    });

    test('preserves port and maps http to ws', () {
      expect(
        deriveLiveKitWsUrl('http://127.0.0.1:7880/livekit/jwt/'),
        'ws://127.0.0.1:7880/livekit/sfu',
      );
    });

    test('falls back to default livekit sfu path', () {
      expect(
        deriveLiveKitWsUrl('https://m.si46.world/rtc/token'),
        'wss://m.si46.world/livekit/sfu',
      );
    });
  });
}
