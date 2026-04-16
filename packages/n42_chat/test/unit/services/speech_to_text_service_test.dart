import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/core/services/speech_to_text_service.dart';

class MockDio extends Mock implements Dio {
  final BaseOptions _options = BaseOptions();

  @override
  BaseOptions get options => _options;

  @override
  set options(BaseOptions value) {}
}

void main() {
  setUpAll(() {
    registerFallbackValue(Options());
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(<int>[]);
  });

  group('SpeechToTextService', () {
    late SpeechToTextService service;
    late MockDio mockDio;
    late File tempFile;

    setUp(() async {
      service = SpeechToTextService();
      service.resetConfiguration();
      mockDio = MockDio();
      service.replaceDio(mockDio);

      tempFile = File(
        '${Directory.systemTemp.path}/speech_to_text_service_test.wav',
      );
      await tempFile.writeAsBytes(<int>[1, 2, 3, 4]);
    });

    tearDown(() async {
      service.resetConfiguration();
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    });

    test('configureGoogleProxy posts JSON to the proxy endpoint', () async {
      service.configureGoogleProxy(
        baseUrl: 'https://api.n42.ai/proxy/v1/speech/google',
        authToken: 'proxy-token',
      );

      when(
        () => mockDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: {
            'results': [
              {
                'alternatives': [
                  {'transcript': 'hello world'},
                ],
              },
            ],
          },
          statusCode: 200,
          requestOptions: RequestOptions(
            path: 'https://api.n42.ai/proxy/v1/speech/google',
          ),
        ),
      );

      final result = await service.transcribe(
        tempFile.path,
        language: 'en-US',
      );

      expect(result, 'hello world');
      verify(
        () => mockDio.post<Map<String, dynamic>>(
          'https://api.n42.ai/proxy/v1/speech/google',
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).called(1);
    });

    test('configureAzureProxy sends audio bytes with accept-language header', () async {
      service.configureAzureProxy(
        baseUrl: 'https://api.n42.ai/proxy/v1/speech/azure',
        authToken: 'proxy-token',
      );

      when(
        () => mockDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: {'DisplayText': 'ni hao'},
          statusCode: 200,
          requestOptions: RequestOptions(
            path: 'https://api.n42.ai/proxy/v1/speech/azure',
          ),
        ),
      );

      final result = await service.transcribe(
        tempFile.path,
        language: 'zh-CN',
      );

      expect(result, 'ni hao');
      verify(
        () => mockDio.post<Map<String, dynamic>>(
          'https://api.n42.ai/proxy/v1/speech/azure',
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).called(1);
    });

    test('resetConfiguration clears the active provider', () {
      service.configureGoogleProxy(
        baseUrl: 'https://api.n42.ai/proxy/v1/speech/google',
      );

      expect(service.isConfigured, isTrue);

      service.resetConfiguration();

      expect(service.isConfigured, isFalse);
      expect(service.currentProvider, SpeechProvider.none);
    });
  });
}
