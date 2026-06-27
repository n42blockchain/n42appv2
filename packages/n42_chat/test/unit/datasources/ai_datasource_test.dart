import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/core/services/ai_service.dart';
import 'package:n42_chat/src/data/datasources/ai_datasource.dart';

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
  });

  group('AiDatasource', () {
    late MockDio mockDio;
    late AiDatasource datasource;

    setUp(() {
      mockDio = MockDio();
      datasource = AiDatasource(
        baseUrl: 'https://api.openai.com',
        apiKey: 'test-api-key',
        defaultModel: 'gpt-4o-mini',
        dio: mockDio,
      );
    });

    group('isAvailable', () {
      test('should return true when apiKey and baseUrl are non-empty', () {
        expect(datasource.isAvailable, isTrue);
      });

      test('should return false when apiKey is empty', () {
        final ds = AiDatasource(
          baseUrl: 'https://api.openai.com',
          apiKey: '',
          dio: mockDio,
        );
        expect(ds.isAvailable, isFalse);
      });

      test('should return false when baseUrl is empty', () {
        final ds = AiDatasource(
          baseUrl: '',
          apiKey: 'test-api-key',
          dio: mockDio,
        );
        expect(ds.isAvailable, isFalse);
      });

      test('should allow proxy endpoint mode without apiKey', () {
        final ds = AiDatasource(
          baseUrl: 'https://api.n42.ai/proxy/v1/ai/chat',
          apiKey: '',
          useProxyEndpoint: true,
          dio: mockDio,
        );

        expect(ds.isAvailable, isTrue);
      });
    });

    group('completion', () {
      test(
        'should throw AiServiceException when response data is null',
        () async {
          when(
            () => mockDio.post<Map<String, dynamic>>(
              any(),
              data: any(named: 'data'),
              options: any(named: 'options'),
            ),
          ).thenAnswer(
            (_) async => Response<Map<String, dynamic>>(
              data: null,
              statusCode: 200,
              requestOptions: RequestOptions(path: '/v1/chat/completions'),
            ),
          );

          expect(
            () => datasource.completion([
              const AiMessage(role: AiRole.user, content: 'Hello'),
            ]),
            throwsA(
              isA<AiServiceException>().having(
                (e) => e.message,
                'message',
                'Empty response from server',
              ),
            ),
          );
        },
      );

      test('should throw AiServiceException when choices is empty', () async {
        when(
          () => mockDio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response<Map<String, dynamic>>(
            data: {
              'choices': <dynamic>[],
              'usage': {'prompt_tokens': 0, 'completion_tokens': 0},
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: '/v1/chat/completions'),
          ),
        );

        expect(
          () => datasource.completion([
            const AiMessage(role: AiRole.user, content: 'Hello'),
          ]),
          throwsA(
            isA<AiServiceException>().having(
              (e) => e.message,
              'message',
              'No choices in response',
            ),
          ),
        );
      });

      test('should return AiCompletionResult on success', () async {
        when(
          () => mockDio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response<Map<String, dynamic>>(
            data: {
              'choices': [
                {
                  'message': {
                    'role': 'assistant',
                    'content': 'Hello! How can I help you?',
                  },
                },
              ],
              'usage': {'prompt_tokens': 10, 'completion_tokens': 8},
              'model': 'gpt-4o-mini',
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: '/v1/chat/completions'),
          ),
        );

        final result = await datasource.completion([
          const AiMessage(role: AiRole.user, content: 'Hello'),
        ]);

        expect(result.text, equals('Hello! How can I help you?'));
        expect(result.promptTokens, equals(10));
        expect(result.completionTokens, equals(8));
        expect(result.model, equals('gpt-4o-mini'));
      });

      test(
        'should support content-part arrays in completion responses',
        () async {
          when(
            () => mockDio.post<Map<String, dynamic>>(
              any(),
              data: any(named: 'data'),
              options: any(named: 'options'),
            ),
          ).thenAnswer(
            (_) async => Response<Map<String, dynamic>>(
              data: {
                'choices': [
                  {
                    'message': {
                      'role': 'assistant',
                      'content': [
                        {'type': 'text', 'text': 'Hello '},
                        {'type': 'text', 'text': 'world'},
                      ],
                    },
                  },
                ],
                'usage': {'prompt_tokens': 4, 'completion_tokens': 2},
                'model': 'gpt-4o-mini',
              },
              statusCode: 200,
              requestOptions: RequestOptions(path: '/v1/chat/completions'),
            ),
          );

          final result = await datasource.completion([
            const AiMessage(role: AiRole.user, content: 'Hello'),
          ]);

          expect(result.text, equals('Hello world'));
        },
      );

      test('should throw AiServiceException on DioException', () async {
        when(
          () => mockDio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenThrow(
          DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: '/v1/chat/completions'),
            message: 'Connection timeout',
          ),
        );

        expect(
          () => datasource.completion([
            const AiMessage(role: AiRole.user, content: 'Hello'),
          ]),
          throwsA(
            isA<AiServiceException>().having(
              (e) => e.message,
              'message',
              'Connection timeout',
            ),
          ),
        );
      });

      test('should throw AiServiceException when choices is null', () async {
        when(
          () => mockDio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response<Map<String, dynamic>>(
            data: {
              'usage': {'prompt_tokens': 0, 'completion_tokens': 0},
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: '/v1/chat/completions'),
          ),
        );

        expect(
          () => datasource.completion([
            const AiMessage(role: AiRole.user, content: 'Hello'),
          ]),
          throwsA(
            isA<AiServiceException>().having(
              (e) => e.message,
              'message',
              'No choices in response',
            ),
          ),
        );
      });
    });

    group('streamCompletion', () {
      test(
        'should throw AiServiceException when messages exceed length limit',
        () {
          // Create a message that exceeds 128000 characters
          final longContent = 'A' * 130000;
          final messages = [AiMessage(role: AiRole.user, content: longContent)];

          expect(
            () => datasource.streamCompletion(messages).toList(),
            throwsA(
              isA<AiServiceException>().having(
                (e) => e.message,
                'message',
                contains('exceeds limit'),
              ),
            ),
          );
        },
      );

      test('should validate message length including systemPrompt', () {
        // systemPrompt (64000) + message (65000) = 129000 > 128000
        final systemPrompt = 'S' * 64000;
        final messages = [AiMessage(role: AiRole.user, content: 'U' * 65000)];

        expect(
          () => datasource
              .streamCompletion(messages, systemPrompt: systemPrompt)
              .toList(),
          throwsA(
            isA<AiServiceException>().having(
              (e) => e.message,
              'message',
              contains('exceeds limit'),
            ),
          ),
        );
      });

      test('should parse utf8 content split across chunks', () async {
        final fullResponse = utf8.encode(
          'data: {"choices":[{"delta":{"content":"你"}}]}\n'
          'data: {"choices":[{"delta":{"content":"好"}}]}',
        );
        final firstChunk = Uint8List.fromList(fullResponse.sublist(0, 38));
        final secondChunk = Uint8List.fromList(fullResponse.sublist(38));

        when(
          () => mockDio.post<ResponseBody>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response<ResponseBody>(
            data: ResponseBody(
              Stream<Uint8List>.fromIterable([firstChunk, secondChunk]),
              200,
            ),
            statusCode: 200,
            requestOptions: RequestOptions(path: '/v1/chat/completions'),
          ),
        );

        final chunks = await datasource.streamCompletion([
          const AiMessage(role: AiRole.user, content: 'Hello'),
        ]).toList();

        expect(chunks, ['你', '好']);
      });

      test('should parse streamed content-part arrays', () async {
        final fullResponse = utf8.encode(
          'data: {"choices":[{"delta":{"content":[{"type":"text","text":"Hello "}]}}]}\n'
          'data: {"choices":[{"delta":{"content":[{"type":"text","text":"world"}]}}]}\n'
          'data: [DONE]\n',
        );

        when(
          () => mockDio.post<ResponseBody>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response<ResponseBody>(
            data: ResponseBody(
              Stream<Uint8List>.value(Uint8List.fromList(fullResponse)),
              200,
            ),
            statusCode: 200,
            requestOptions: RequestOptions(path: '/v1/chat/completions'),
          ),
        );

        final chunks = await datasource.streamCompletion([
          const AiMessage(role: AiRole.user, content: 'Hello'),
        ]).toList();

        expect(chunks, ['Hello ', 'world']);
      });

      test('should surface inline stream error payloads', () async {
        final fullResponse = utf8.encode(
          'data: {"error":{"message":"Model overloaded"}}\n',
        );

        when(
          () => mockDio.post<ResponseBody>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response<ResponseBody>(
            data: ResponseBody(
              Stream<Uint8List>.value(Uint8List.fromList(fullResponse)),
              200,
            ),
            statusCode: 200,
            requestOptions: RequestOptions(path: '/v1/chat/completions'),
          ),
        );

        expect(
          () => datasource.streamCompletion([
            const AiMessage(role: AiRole.user, content: 'Hello'),
          ]).toList(),
          throwsA(
            isA<AiServiceException>().having(
              (e) => e.message,
              'message',
              'Model overloaded',
            ),
          ),
        );
      });
    });

    group('summarizeUrl', () {
      test('should handle content truncation for long page content', () async {
        // Setup: mock the Dio post call for the underlying completion
        final longContent = 'B' * 5000; // Exceeds 4000 char truncation limit

        when(
          () => mockDio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenAnswer((invocation) async {
          // Verify the content was truncated in the request payload
          final data = invocation.namedArguments[#data] as Map<String, dynamic>;
          final messages = data['messages'] as List<dynamic>;
          // The last message (user message) should contain the truncated content
          final userMessage = messages.last as Map<String, String>;
          final content = userMessage['content']!;
          // URL prefix + truncated content should be less than original
          expect(content.length, lessThan(longContent.length + 50));

          return Response<Map<String, dynamic>>(
            data: {
              'choices': [
                {
                  'message': {
                    'role': 'assistant',
                    'content': 'This is a summary.',
                  },
                },
              ],
              'usage': {'prompt_tokens': 100, 'completion_tokens': 20},
              'model': 'gpt-4o-mini',
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: '/v1/chat/completions'),
          );
        });

        final result = await datasource.summarizeUrl(
          'https://example.com',
          longContent,
        );

        expect(result, equals('This is a summary.'));
        verify(
          () => mockDio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).called(1);
      });

      test('should not truncate short content', () async {
        const shortContent = 'Short page content';

        when(
          () => mockDio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenAnswer((invocation) async {
          final data = invocation.namedArguments[#data] as Map<String, dynamic>;
          final messages = data['messages'] as List<dynamic>;
          final userMessage = messages.last as Map<String, String>;
          final content = userMessage['content']!;
          // Short content should be fully included
          expect(content, contains(shortContent));

          return Response<Map<String, dynamic>>(
            data: {
              'choices': [
                {
                  'message': {'role': 'assistant', 'content': 'Brief summary.'},
                },
              ],
              'usage': {'prompt_tokens': 50, 'completion_tokens': 10},
              'model': 'gpt-4o-mini',
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: '/v1/chat/completions'),
          );
        });

        final result = await datasource.summarizeUrl(
          'https://example.com',
          shortContent,
        );

        expect(result, equals('Brief summary.'));
      });
    });

    group('dispose', () {
      test('should close Dio', () {
        when(
          () => mockDio.close(force: any(named: 'force')),
        ).thenAnswer((_) {});

        datasource.dispose();

        verify(() => mockDio.close()).called(1);
      });
    });

    group('message length validation', () {
      test('should accept messages within length limit', () async {
        // Total length just under limit: should not throw
        final messages = [AiMessage(role: AiRole.user, content: 'A' * 127999)];

        when(
          () => mockDio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response<Map<String, dynamic>>(
            data: {
              'choices': [
                {
                  'message': {'role': 'assistant', 'content': 'OK'},
                },
              ],
              'usage': {'prompt_tokens': 0, 'completion_tokens': 0},
              'model': 'gpt-4o-mini',
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: '/v1/chat/completions'),
          ),
        );

        final result = await datasource.completion(messages);
        expect(result.text, equals('OK'));
      });

      test(
        'should throw when total of multiple messages exceeds limit',
        () async {
          final messages = [
            AiMessage(role: AiRole.user, content: 'A' * 65000),
            AiMessage(role: AiRole.assistant, content: 'B' * 65000),
          ];

          expect(
            () => datasource.completion(messages),
            throwsA(
              isA<AiServiceException>().having(
                (e) => e.message,
                'message',
                contains('exceeds limit'),
              ),
            ),
          );
        },
      );
    });

    group('constructor', () {
      test('should strip trailing slash from baseUrl', () {
        final ds = AiDatasource(
          baseUrl: 'https://api.openai.com/',
          apiKey: 'key',
          dio: mockDio,
        );
        // The datasource should still be available (baseUrl becomes
        // 'https://api.openai.com' which is non-empty)
        expect(ds.isAvailable, isTrue);
      });

      test('should use default model gpt-4o-mini', () async {
        when(
          () => mockDio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenAnswer((invocation) async {
          final data = invocation.namedArguments[#data] as Map<String, dynamic>;
          expect(data['model'], equals('gpt-4o-mini'));

          return Response<Map<String, dynamic>>(
            data: {
              'choices': [
                {
                  'message': {'role': 'assistant', 'content': 'test'},
                },
              ],
              'usage': {'prompt_tokens': 0, 'completion_tokens': 0},
              'model': 'gpt-4o-mini',
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: '/v1/chat/completions'),
          );
        });

        await datasource.completion([
          const AiMessage(role: AiRole.user, content: 'Hi'),
        ]);

        verify(
          () => mockDio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).called(1);
      });

      test('should post directly to proxy endpoint in proxy mode', () async {
        final ds = AiDatasource(
          baseUrl: 'https://api.n42.ai/proxy/v1/ai/chat',
          apiKey: '',
          useProxyEndpoint: true,
          dio: mockDio,
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
              'choices': [
                {
                  'message': {'role': 'assistant', 'content': 'proxy-ok'},
                },
              ],
              'usage': {'prompt_tokens': 0, 'completion_tokens': 0},
              'model': 'proxy-model',
            },
            statusCode: 200,
            requestOptions: RequestOptions(
              path: 'https://api.n42.ai/proxy/v1/ai/chat',
            ),
          ),
        );

        final result = await ds.completion([
          const AiMessage(role: AiRole.user, content: 'Hi'),
        ]);

        expect(result.text, 'proxy-ok');
        verify(
          () => mockDio.post<Map<String, dynamic>>(
            'https://api.n42.ai/proxy/v1/ai/chat',
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).called(1);
      });

      test(
        'should append v1/chat/completions for root OpenAI-compatible baseUrl',
        () async {
          final ds = AiDatasource(
            baseUrl: 'https://api.openai.com',
            apiKey: 'key',
            dio: mockDio,
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
                'choices': [
                  {
                    'message': {'role': 'assistant', 'content': 'ok'},
                  },
                ],
                'usage': {'prompt_tokens': 0, 'completion_tokens': 0},
                'model': 'gpt-4o-mini',
              },
              statusCode: 200,
              requestOptions: RequestOptions(
                path: 'https://api.openai.com/v1/chat/completions',
              ),
            ),
          );

          await ds.completion([
            const AiMessage(role: AiRole.user, content: 'Hi'),
          ]);

          verify(
            () => mockDio.post<Map<String, dynamic>>(
              'https://api.openai.com/v1/chat/completions',
              data: any(named: 'data'),
              options: any(named: 'options'),
            ),
          ).called(1);
        },
      );

      test(
        'should preserve provider path prefixes when building chat endpoint',
        () async {
          final ds = AiDatasource(
            baseUrl: 'https://api.groq.com/openai',
            apiKey: 'key',
            dio: mockDio,
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
                'choices': [
                  {
                    'message': {'role': 'assistant', 'content': 'ok'},
                  },
                ],
                'usage': {'prompt_tokens': 0, 'completion_tokens': 0},
                'model': 'llama',
              },
              statusCode: 200,
              requestOptions: RequestOptions(
                path: 'https://api.groq.com/openai/v1/chat/completions',
              ),
            ),
          );

          await ds.completion([
            const AiMessage(role: AiRole.user, content: 'Hi'),
          ]);

          verify(
            () => mockDio.post<Map<String, dynamic>>(
              'https://api.groq.com/openai/v1/chat/completions',
              data: any(named: 'data'),
              options: any(named: 'options'),
            ),
          ).called(1);
        },
      );
    });

    group('suggestReplies', () {
      test('should parse JSON array suggestions', () async {
        when(
          () => mockDio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response<Map<String, dynamic>>(
            data: {
              'choices': [
                {
                  'message': {
                    'role': 'assistant',
                    'content':
                        '["Sounds good","I can do that","Let me check"]',
                  },
                },
              ],
              'usage': {'prompt_tokens': 10, 'completion_tokens': 8},
              'model': 'gpt-4o-mini',
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: '/v1/chat/completions'),
          ),
        );

        final result = await datasource.suggestReplies([
          const AiMessage(
            role: AiRole.assistant,
            content: 'Can you review this?',
          ),
        ]);

        expect(result, ['Sounds good', 'I can do that', 'Let me check']);
      });

      test('should fall back to newline parsing when model returns plain text',
          () async {
        when(
          () => mockDio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response<Map<String, dynamic>>(
            data: {
              'choices': [
                {
                  'message': {
                    'role': 'assistant',
                    'content': '1. Sure\n2. Give me a minute\n3. Thanks!',
                  },
                },
              ],
              'usage': {'prompt_tokens': 10, 'completion_tokens': 8},
              'model': 'gpt-4o-mini',
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: '/v1/chat/completions'),
          ),
        );

        final result = await datasource.suggestReplies([
          const AiMessage(role: AiRole.assistant, content: 'Need this today'),
        ]);

        expect(result, ['Sure', 'Give me a minute', 'Thanks!']);
      });
    });
  });

  group('AiServiceException', () {
    test('should store message', () {
      const exception = AiServiceException('Something went wrong');
      expect(exception.message, equals('Something went wrong'));
    });

    test('toString should include class name and message', () {
      const exception = AiServiceException('API rate limited');
      expect(
        exception.toString(),
        equals('AiServiceException: API rate limited'),
      );
    });

    test('should implement Exception', () {
      const exception = AiServiceException('error');
      expect(exception, isA<Exception>());
    });
  });

  group('AiDatasource.generateImage', () {
    late MockDio mockDio;
    late AiDatasource datasource;

    setUp(() {
      mockDio = MockDio();
      datasource = AiDatasource(
        baseUrl: 'https://api.openai.com',
        apiKey: 'test-api-key',
        imageModel: 'dall-e-3',
        dio: mockDio,
      );
    });

    test('supportsImageGeneration reflects availability', () {
      expect(datasource.supportsImageGeneration, isTrue);
      final unavailable = AiDatasource(baseUrl: '', apiKey: '', dio: mockDio);
      expect(unavailable.supportsImageGeneration, isFalse);
    });

    test('empty prompt throws', () {
      expect(
        () => datasource.generateImage('  '),
        throwsA(isA<AiServiceException>()),
      );
    });

    test('decodes b64_json into bytes', () async {
      final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final b64 = base64Encode(bytes);
      when(
        () => mockDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: {
            'model': 'dall-e-3',
            'data': [
              {'b64_json': b64},
            ],
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/v1/images/generations'),
        ),
      );

      final result = await datasource.generateImage('a happy cat');
      expect(result.bytes, equals(bytes));
      expect(result.model, 'dall-e-3');
    });

    test('falls back to url when no b64_json', () async {
      final bytes = Uint8List.fromList([9, 8, 7]);
      when(
        () => mockDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: {
            'data': [
              {'url': 'https://img.example/sticker.png'},
            ],
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/v1/images/generations'),
        ),
      );
      when(
        () => mockDio.get<List<int>>(
          any(),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response<List<int>>(
          data: bytes,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/sticker.png'),
        ),
      );

      final result = await datasource.generateImage('a dog');
      expect(result.bytes, equals(bytes));
    });

    test('throws when data list is empty', () {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: {'data': <dynamic>[]},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/v1/images/generations'),
        ),
      );
      expect(
        () => datasource.generateImage('x'),
        throwsA(isA<AiServiceException>()),
      );
    });
  });

  group('AiDatasource.describeImage', () {
    late MockDio mockDio;
    late AiDatasource datasource;

    setUp(() {
      mockDio = MockDio();
      datasource = AiDatasource(
        baseUrl: 'https://api.openai.com',
        apiKey: 'test-api-key',
        visionModel: 'gpt-4o',
        dio: mockDio,
      );
    });

    test('supportsVision reflects availability', () {
      expect(datasource.supportsVision, isTrue);
      final unavailable = AiDatasource(baseUrl: '', apiKey: '', dio: mockDio);
      expect(unavailable.supportsVision, isFalse);
    });

    test('empty image throws', () {
      expect(
        () => datasource.describeImage(Uint8List(0)),
        throwsA(isA<AiServiceException>()),
      );
    });

    test('returns model text content for the image', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: {
            'choices': [
              {
                'message': {'content': 'A cat wearing sunglasses.'},
              },
            ],
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/v1/chat/completions'),
        ),
      );

      final text = await datasource.describeImage(
        Uint8List.fromList([1, 2, 3]),
      );
      expect(text, 'A cat wearing sunglasses.');
    });

    test('throws when choices empty', () {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: {'choices': <dynamic>[]},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/v1/chat/completions'),
        ),
      );
      expect(
        () => datasource.describeImage(Uint8List.fromList([1])),
        throwsA(isA<AiServiceException>()),
      );
    });
  });
}
