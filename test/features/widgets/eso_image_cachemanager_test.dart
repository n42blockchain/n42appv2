import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/widgets/eso_image_cachemanager.dart';

void main() {
  test('image file service preserves response cache metadata', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));

    server.listen((request) async {
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType('image', 'png')
        ..headers.set(HttpHeaders.cacheControlHeader, 'public, max-age=120')
        ..headers.set(HttpHeaders.etagHeader, 'image-v1')
        ..contentLength = 4
        ..add([0x89, 0x50, 0x4e, 0x47]);
      await request.response.close();
    });

    final beforeRequest = DateTime.now();
    final response = await EsoHttpFileService().get(
      'http://${server.address.host}:${server.port}/coin.png',
    );
    final bytes = await response.content.expand((chunk) => chunk).toList();

    expect(response.statusCode, HttpStatus.ok);
    expect(response.contentLength, 4);
    expect(response.eTag, 'image-v1');
    expect(response.fileExtension, '.png');
    expect(
      response.validTill.isAfter(
        beforeRequest.add(const Duration(seconds: 119)),
      ),
      isTrue,
    );
    expect(bytes, [0x89, 0x50, 0x4e, 0x47]);
  });

  test('image file service forwards conditional request headers', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    late String? receivedETag;

    server.listen((request) async {
      receivedETag = request.headers.value(HttpHeaders.ifNoneMatchHeader);
      request.response.statusCode = HttpStatus.notModified;
      await request.response.close();
    });

    final response = await EsoHttpFileService().get(
      'http://${server.address.host}:${server.port}/coin.png',
      headers: {HttpHeaders.ifNoneMatchHeader: 'image-v1'},
    );
    await response.content.drain<void>();

    expect(response.statusCode, HttpStatus.notModified);
    expect(receivedETag, 'image-v1');
  });
}
