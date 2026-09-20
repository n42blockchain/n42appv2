import 'dart:convert';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/services/ai_service.dart';
import 'package:n42_chat/src/data/datasources/ai_datasource.dart';

void main() {
  test(
    'vision compresses a large source to bounded JPEG with current authorization',
    () async {
      final dio = Dio();
      final service = AiDatasource(
        baseUrl: 'https://example.org/ai',
        apiKey: '',
        useProxyEndpoint: true,
        getAccessToken: () => 'vision-account',
        dio: dio,
      );
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            expect(request.headers['Authorization'], 'Bearer vision-account');
            final data = request.data as Map;
            final messages = data['messages'] as List;
            final content = (messages.last as Map)['content'] as List;
            final url =
                ((content.last as Map)['image_url'] as Map)['url'] as String;
            expect(url, startsWith('data:image/jpeg;base64,'));
            final bytes = base64Decode(url.split(',').last);
            final decoded = img.decodeJpg(bytes)!;
            expect(decoded.width, lessThanOrEqualTo(1280));
            expect(decoded.height, lessThanOrEqualTo(1280));
            expect(bytes.length, lessThanOrEqualTo(2 * 1024 * 1024));
            handler.resolve(
              Response(
                requestOptions: request,
                statusCode: 200,
                data: {
                  'choices': [
                    {
                      'message': {'content': 'A test image'},
                    },
                  ],
                },
              ),
            );
          },
        ),
      );
      final input = Uint8List.fromList(
        img.encodePng(img.Image(width: 1600, height: 800)),
      );
      expect(await service.describeImage(input), 'A test image');
      service.dispose();
    },
  );

  test(
    'proxy resolves active account token for every call and rejects logout',
    () async {
      String? token = 'account-a';
      final headers = <Object?>[];
      final dio = Dio();
      final service = AiDatasource(
        baseUrl: 'https://example.org/ai',
        apiKey: '',
        useProxyEndpoint: true,
        getAccessToken: () => token,
        dio: dio,
      );
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            headers.add(request.headers['Authorization']);
            handler.resolve(
              Response(
                requestOptions: request,
                statusCode: 200,
                data: {
                  'choices': [
                    {
                      'message': {'content': 'summary'},
                    },
                  ],
                },
              ),
            );
          },
        ),
      );
      expect(
        (await service.completion([
          const AiMessage(role: AiRole.user, content: 'test'),
        ])).text,
        'summary',
      );
      token = 'account-b';
      expect(
        await service.streamCompletion([
          const AiMessage(role: AiRole.user, content: 'test'),
        ]).toList(),
        ['summary'],
      );
      expect(headers, ['Bearer account-a', 'Bearer account-b']);
      token = null;
      await expectLater(
        service.completion([
          const AiMessage(role: AiRole.user, content: 'test'),
        ]),
        throwsA(isA<AiServiceException>()),
      );
      expect(headers.length, 2);
      service.dispose();
    },
  );
}
