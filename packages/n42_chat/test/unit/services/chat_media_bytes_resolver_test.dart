import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:n42_chat/src/core/services/chat_media_bytes_resolver.dart';

void main() {
  final pngBytes = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
  );

  test('downloads plaintext image and detects its MIME type', () async {
    final resolver = ChatMediaBytesResolver(
      httpClient: MockClient((_) async => http.Response.bytes(pngBytes, 200)),
    );
    addTearDown(resolver.dispose);

    final media = await resolver.resolve(httpUrl: 'https://example.test/a');

    expect(media.bytes, pngBytes);
    expect(media.mimeType, 'image/png');
  });

  test('rejects incomplete encrypted media metadata', () async {
    final resolver = ChatMediaBytesResolver(
      httpClient: MockClient((_) async => http.Response.bytes(pngBytes, 200)),
    );
    addTearDown(resolver.dispose);

    await expectLater(
      resolver.resolve(
        httpUrl: 'https://example.test/a',
        encryptKey: 'key-without-iv-or-hash',
      ),
      throwsA(
        isA<ChatMediaResolveException>().having(
          (error) => error.message,
          'message',
          contains('incomplete'),
        ),
      ),
    );
  });

  test('rejects non-image response bytes', () async {
    final resolver = ChatMediaBytesResolver(
      httpClient: MockClient((_) async => http.Response('plain text', 200)),
    );
    addTearDown(resolver.dispose);

    await expectLater(
      resolver.resolve(
        httpUrl: 'https://example.test/a',
        declaredMimeType: 'text/plain',
      ),
      throwsA(isA<ChatMediaResolveException>()),
    );
  });
}
