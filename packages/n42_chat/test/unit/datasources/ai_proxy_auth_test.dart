import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/services/ai_service.dart';
import 'package:n42_chat/src/data/datasources/ai_datasource.dart';

void main() {
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
