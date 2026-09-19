import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:matrix/matrix.dart';
import 'package:n42_chat/src/core/encryption/token_device_session.dart';

void main() {
  for (final scenario in [
    'fresh',
    'existing',
    'wrong-user',
    'wrong-device',
    'incomplete',
    'failure',
  ]) {
    test('token bootstrap enforces device identity: $scenario', () async {
      var keyQueries = 0;
      final httpClient = MockClient((request) async {
        if (request.url.path.endsWith('/whoami')) {
          return http.Response(
            jsonEncode({
              'user_id': scenario == 'wrong-user' ? '@other:hs' : '@me:hs',
              'device_id': scenario == 'wrong-device' ? 'OTHER' : 'DEVICE',
            }),
            200,
          );
        }
        expect(request.url.path, endsWith('/keys/query'));
        keyQueries++;
        return http.Response(
          jsonEncode({
            if (scenario != 'incomplete')
              'device_keys': {
                if (scenario == 'existing')
                  '@me:hs': {
                    'DEVICE': {
                      'device_id': 'DEVICE',
                      'user_id': '@me:hs',
                      'keys': <String, dynamic>{},
                      'signatures': <String, dynamic>{},
                    },
                  },
              },
            if (scenario == 'failure')
              'failures': {
                'hs': {'errcode': 'M_UNKNOWN'},
              },
          }),
          200,
        );
      });
      final api = MatrixApi(
        homeserver: Uri.parse('https://hs.test'),
        accessToken: 'fixture',
        httpClient: httpClient,
      );
      if (scenario == 'fresh') {
        await validateFreshTokenDevice(api, '@me:hs', 'DEVICE');
      } else {
        await expectLater(
          validateFreshTokenDevice(api, '@me:hs', 'DEVICE'),
          throwsStateError,
        );
      }
      expect(keyQueries, scenario.startsWith('wrong-') ? 0 : 1);
      httpClient.close();
    });
  }
}
