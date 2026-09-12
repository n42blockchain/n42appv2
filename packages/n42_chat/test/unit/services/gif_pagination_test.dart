import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:n42_chat/src/core/services/gif_service.dart';
import 'package:n42_chat/src/core/services/giphy_service.dart';
import 'package:n42_chat/src/core/services/tenor_service.dart';

Map<String, dynamic> page(String id, String next) => {
  'next': next,
  'results': [
    {
      'id': id,
      'media_formats': {
        'gif': {
          'url': 'https://example.com/$id.gif',
          'dims': [100, 80],
        },
      },
    },
  ],
};

void main() {
  test('Tenor forwards opaque cursors and stops at end of results', () async {
    final requests = <Uri>[];
    final service = TenorService(
      config: const TenorConfig(apiKey: 'fixture'),
      client: MockClient((request) async {
        requests.add(request.url);
        return http.Response(
          jsonEncode(
            page(
              '${requests.length}',
              requests.length == 1 ? 'cursor+/=:opaque' : '0',
            ),
          ),
          200,
        );
      }),
    );
    final first = await service.searchGifs(query: 'cat', lang: 'ar');
    expect(requests.first.queryParameters['pos'], isNull);
    expect(first.nextCursor, 'cursor+/=:opaque');
    expect(first.hasMore, isTrue);
    final second = await service.searchGifs(
      query: 'cat',
      lang: 'ar',
      offset: 1,
      cursor: first.nextCursor,
    );
    expect(requests.last.queryParameters['pos'], first.nextCursor);
    expect(requests.last.queryParameters['locale'], 'ar');
    expect(second.hasMore, isFalse);
    expect(second.provider, 'Tenor');
    expect(second.offset, 1);
    service.dispose();
  });

  test(
    'fallback selects a provider and pins continuation and retry to it',
    () async {
      var primaryRequests = 0;
      var fallbackRequests = 0;
      final positions = <String?>[];
      final primary = GiphyService(
        config: const GiphyConfig(apiKey: 'fixture'),
        client: MockClient((_) async {
          primaryRequests++;
          return http.Response('unavailable', 503);
        }),
      );
      final fallback = TenorService(
        config: const TenorConfig(apiKey: 'fixture'),
        client: MockClient((request) async {
          fallbackRequests++;
          positions.add(request.url.queryParameters['pos']);
          if (fallbackRequests == 2) return http.Response('retry', 429);
          return http.Response(
            jsonEncode(page('gif', fallbackRequests == 1 ? 'a:b' : '')),
            200,
          );
        }),
      );
      final composite = CompositeGifService([primary, fallback]);
      final first = await composite.getTrendingGifs();
      expect(first.nextCursor, '1:a:b');
      expect(first.provider, 'Tenor');
      final failed = await composite.getTrendingGifs(
        offset: 1,
        cursor: first.nextCursor,
      );
      expect(failed.isError, isTrue);
      final retry = await composite.getTrendingGifs(
        offset: 1,
        cursor: first.nextCursor,
      );
      expect(retry.isError, isFalse);
      expect(retry.hasMore, isFalse);
      expect(primaryRequests, 1);
      expect(positions, [null, 'a:b', 'a:b']);
      primary.dispose();
      fallback.dispose();
    },
  );

  test('malformed cursors fail without issuing requests', () async {
    var requests = 0;
    final provider = TenorService(
      config: const TenorConfig(apiKey: 'fixture'),
      client: MockClient((_) async {
        requests++;
        return http.Response('{}', 200);
      }),
    );
    final service = CompositeGifService([provider]);
    for (final cursor in ['invalid', '-1:next', '4:next']) {
      expect(
        (await service.getTrendingGifs(offset: 1, cursor: cursor)).isError,
        isTrue,
      );
    }
    expect(requests, 0);
    provider.dispose();
  });

  test('empty results remain distinguishable from network failures', () async {
    for (final status in [200, 503]) {
      final provider = TenorService(
        config: const TenorConfig(apiKey: 'fixture'),
        client: MockClient(
          (_) async => http.Response('{"results":[],"next":""}', status),
        ),
      );
      final result = await CompositeGifService([
        provider,
      ]).searchGifs(query: 'none');
      expect(result.gifs, isEmpty);
      expect(result.isError, status != 200);
      expect(result.hasMore, isFalse);
      provider.dispose();
    }
  });
}
