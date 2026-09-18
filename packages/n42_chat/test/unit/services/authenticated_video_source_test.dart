import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:n42_chat/src/core/services/authenticated_video_source.dart';

void main() {
  late Directory directory;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('n42-video-test-');
  });
  tearDown(() async {
    await directory.delete(recursive: true);
  });

  test(
    'downloads authenticated bytes and deletes them when disposed',
    () async {
      final source = AuthenticatedVideoSource(
        temporaryDirectory: () async => directory,
        client: MockClient((request) async {
          expect(request.headers['authorization'], 'Bearer test-token');
          return http.Response.bytes([1, 2, 3], 200);
        }),
      );
      final file = await source.load(Uri.parse('https://hs.test/video'), {
        'Authorization': 'Bearer test-token',
      });
      expect(await file.readAsBytes(), [1, 2, 3]);
      await source.dispose();
      expect(await file.exists(), isFalse);
    },
  );

  test('does not forward credentials to redirected media origin', () async {
    final source = AuthenticatedVideoSource(
      temporaryDirectory: () async => directory,
      client: MockClient((request) async {
        if (request.url.host == 'hs.test') {
          return http.Response(
            '',
            302,
            headers: {'location': 'https://cdn.test/video'},
          );
        }
        expect(request.headers.containsKey('authorization'), isFalse);
        return http.Response.bytes([1], 200);
      }),
    );
    await source.load(Uri.parse('https://hs.test/video'), {
      'Authorization': 'Bearer test-token',
    });
    await source.dispose();
  });

  test('rejects insecure redirects and cleans partial download', () async {
    final source = AuthenticatedVideoSource(
      temporaryDirectory: () async => directory,
      client: MockClient(
        (_) async => http.Response(
          '',
          302,
          headers: {'location': 'http://cdn.test/video'},
        ),
      ),
    );
    await expectLater(
      source.load(Uri.parse('https://hs.test/video'), {}),
      throwsStateError,
    );
    expect(await directory.list().toList(), isEmpty);
  });

  for (final status in [401, 404, 500]) {
    test('fails promptly and cleans files on HTTP $status', () async {
      final source = AuthenticatedVideoSource(
        temporaryDirectory: () async => directory,
        client: MockClient((_) async => http.Response('failure', status)),
      );
      await expectLater(
        source.load(Uri.parse('https://hs.test/video'), {}),
        throwsStateError,
      );
      expect(await directory.list().toList(), isEmpty);
    });
  }
}
