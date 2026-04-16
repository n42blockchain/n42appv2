import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

import 'package:n42_chat/src/core/services/giphy_service.dart';

void main() {
  group('GiphyService', () {
    late GiphyService service;
    late MockClient mockClient;

    const mockGifResponse = {
      'data': [
        {
          'id': 'test-gif-1',
          'title': 'Test GIF 1',
          'images': {
            'original': {
              'url': 'https://giphy.com/test1.gif',
              'width': '480',
              'height': '360',
            },
            'fixed_width': {
              'url': 'https://giphy.com/test1_preview.gif',
              'width': '200',
              'height': '150',
            },
            'original_mp4': {
              'mp4': 'https://giphy.com/test1.mp4',
            },
          },
        },
        {
          'id': 'test-gif-2',
          'title': 'Test GIF 2',
          'images': {
            'original': {
              'url': 'https://giphy.com/test2.gif',
              'width': '640',
              'height': '480',
            },
            'fixed_width': {
              'url': 'https://giphy.com/test2_preview.gif',
              'width': '200',
              'height': '150',
            },
          },
        },
      ],
      'pagination': {
        'total_count': 100,
        'count': 2,
        'offset': 0,
      },
    };

    setUp(() {
      mockClient = MockClient((request) async {
        final uri = request.url;

        if (uri.path.contains('/search')) {
          return http.Response(
            jsonEncode(mockGifResponse),
            200,
          );
        } else if (uri.path.contains('/trending')) {
          return http.Response(
            jsonEncode(mockGifResponse),
            200,
          );
        } else if (uri.path.contains('/random')) {
          final dataList = mockGifResponse['data'] as List;
          return http.Response(
            jsonEncode({
              'data': dataList[0],
            }),
            200,
          );
        }

        return http.Response('Not Found', 404);
      });

      service = GiphyService(
        config: const GiphyConfig(apiKey: 'test-api-key'),
        client: mockClient,
      );
    });

    tearDown(() {
      service.dispose();
    });

    group('GiphyGif', () {
      test('fromJson parses GIF data correctly', () {
        final json = (mockGifResponse['data'] as List)[0] as Map<String, dynamic>;
        final gif = GiphyGif.fromJson(json);

        expect(gif.id, equals('test-gif-1'));
        expect(gif.title, equals('Test GIF 1'));
        expect(gif.originalUrl, equals('https://giphy.com/test1.gif'));
        expect(gif.previewUrl, equals('https://giphy.com/test1_preview.gif'));
        expect(gif.width, equals(480));
        expect(gif.height, equals(360));
        expect(gif.mp4Url, equals('https://giphy.com/test1.mp4'));
      });

      test('aspectRatio calculates correctly', () {
        final json = (mockGifResponse['data'] as List)[0] as Map<String, dynamic>;
        final gif = GiphyGif.fromJson(json);

        expect(gif.aspectRatio, closeTo(480 / 360, 0.01));
      });

      test('aspectRatio returns 1.0 when height is 0', () {
        const gif = GiphyGif(
          id: 'test',
          title: 'test',
          originalUrl: 'url',
          previewUrl: 'url',
          width: 100,
          height: 0,
          previewWidth: 100,
          previewHeight: 0,
        );

        expect(gif.aspectRatio, equals(1.0));
      });
    });

    group('searchGifs', () {
      test('returns empty result for empty query', () async {
        final result = await service.searchGifs(query: '');

        expect(result.gifs, isEmpty);
        expect(result.totalCount, equals(0));
      });

      test('returns empty result for whitespace query', () async {
        final result = await service.searchGifs(query: '   ');

        expect(result.gifs, isEmpty);
        expect(result.totalCount, equals(0));
      });

      test('parses search results correctly', () async {
        final result = await service.searchGifs(query: 'test');

        expect(result.gifs.length, equals(2));
        expect(result.totalCount, equals(100));
        expect(result.offset, equals(0));
        expect(result.hasMore, isTrue);
      });

      test('first GIF has correct data', () async {
        final result = await service.searchGifs(query: 'test');

        final gif = result.gifs.first;
        expect(gif.id, equals('test-gif-1'));
        expect(gif.title, equals('Test GIF 1'));
      });
    });

    group('getTrendingGifs', () {
      test('returns trending GIFs', () async {
        final result = await service.getTrendingGifs();

        expect(result.gifs.length, equals(2));
        expect(result.totalCount, equals(100));
      });

      test('supports pagination', () async {
        final result = await service.getTrendingGifs(offset: 25);

        expect(result.offset, equals(25));
      });

      test('supports proxy endpoints with bearer auth', () async {
        final proxyClient = MockClient((request) async {
          expect(request.url.toString(), contains('/v1/giphy/trending'));
          expect(request.url.queryParameters['offset'], '25');
          expect(request.headers['authorization'], 'Bearer proxy-token');
          return http.Response(jsonEncode(mockGifResponse), 200);
        });

        final proxyService = GiphyService(
          config: const GiphyConfig(
            apiKey: '',
            baseUrl: 'https://api.n42.ai/proxy/v1/giphy',
            authToken: 'proxy-token',
            useProxyEndpoint: true,
          ),
          client: proxyClient,
        );

        final result = await proxyService.getTrendingGifs(offset: 25);

        expect(result.gifs.length, equals(2));
        expect(result.offset, equals(25));
        proxyService.dispose();
      });
    });

    group('getRandomGif', () {
      test('returns a random GIF', () async {
        final gif = await service.getRandomGif();

        expect(gif, isNotNull);
        expect(gif!.id, equals('test-gif-1'));
      });

      test('supports tag parameter', () async {
        final gif = await service.getRandomGif(tag: 'happy');

        expect(gif, isNotNull);
      });
    });

    group('GiphySearchResult', () {
      test('hasMore returns true when more results available', () {
        const result = GiphySearchResult(
          gifs: [],
          totalCount: 100,
          offset: 0,
        );

        expect(result.hasMore, isTrue);
      });

      test('hasMore returns false when at end of results', () {
        final result = GiphySearchResult(
          gifs: List.generate(25, (i) => GiphyGif(
            id: 'gif-$i',
            title: 'GIF $i',
            originalUrl: 'url',
            previewUrl: 'url',
            width: 100,
            height: 100,
            previewWidth: 50,
            previewHeight: 50,
          )),
          totalCount: 25,
          offset: 0,
        );

        expect(result.hasMore, isFalse);
      });
    });

    group('error handling', () {
      test('returns empty result on HTTP error', () async {
        final errorClient = MockClient((_) async {
          return http.Response('Server Error', 500);
        });

        final errorService = GiphyService(
          config: const GiphyConfig(apiKey: 'test-api-key'),
          client: errorClient,
        );

        final result = await errorService.searchGifs(query: 'test');

        expect(result.gifs, isEmpty);
        expect(result.totalCount, equals(0));

        errorService.dispose();
      });

      test('returns empty result on network error', () async {
        final errorClient = MockClient((_) async {
          throw Exception('Network error');
        });

        final errorService = GiphyService(
          config: const GiphyConfig(apiKey: 'test-api-key'),
          client: errorClient,
        );

        final result = await errorService.searchGifs(query: 'test');

        expect(result.gifs, isEmpty);

        errorService.dispose();
      });
    });
  });
}
