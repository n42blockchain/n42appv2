import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:n42_chat/src/core/services/url_preview_service.dart';

void main() {
  group('UrlPreviewData', () {
    test('required url field is set', () {
      const data = UrlPreviewData(url: 'https://example.com');
      expect(data.url, 'https://example.com');
    });

    test('optional fields default to null', () {
      const data = UrlPreviewData(url: 'https://example.com');
      expect(data.title, isNull);
      expect(data.description, isNull);
      expect(data.imageUrl, isNull);
      expect(data.siteName, isNull);
      expect(data.faviconUrl, isNull);
    });

    test('all fields can be set', () {
      const data = UrlPreviewData(
        url: 'https://example.com/article',
        title: 'Example Article',
        description: 'A description',
        imageUrl: 'https://example.com/img.png',
        siteName: 'Example Site',
        faviconUrl: 'https://example.com/favicon.ico',
      );
      expect(data.url, 'https://example.com/article');
      expect(data.title, 'Example Article');
      expect(data.description, 'A description');
      expect(data.imageUrl, 'https://example.com/img.png');
      expect(data.siteName, 'Example Site');
      expect(data.faviconUrl, 'https://example.com/favicon.ico');
    });
  });

  group('UrlPreviewService.extractFirstUrl', () {
    test('extracts http URL from text', () {
      final url = UrlPreviewService.extractFirstUrl('visit http://example.com today');
      expect(url, 'http://example.com');
    });

    test('extracts https URL from text', () {
      final url = UrlPreviewService.extractFirstUrl('check https://example.com now');
      expect(url, 'https://example.com');
    });

    test('returns first URL when multiple URLs present', () {
      final url = UrlPreviewService.extractFirstUrl(
        'https://first.com and https://second.com',
      );
      expect(url, 'https://first.com');
    });

    test('returns null when no URL present', () {
      expect(UrlPreviewService.extractFirstUrl('no links here'), isNull);
    });

    test('returns null for empty string', () {
      expect(UrlPreviewService.extractFirstUrl(''), isNull);
    });

    test('extracts URL with path', () {
      final url = UrlPreviewService.extractFirstUrl(
        'go to https://example.com/path/to/page',
      );
      expect(url, 'https://example.com/path/to/page');
    });

    test('extracts URL with query parameters', () {
      final url = UrlPreviewService.extractFirstUrl(
        'see https://example.com/search?q=test&page=1 for results',
      );
      expect(url, contains('https://example.com/search'));
    });

    test('URL stops at whitespace', () {
      final url = UrlPreviewService.extractFirstUrl('https://example.com next word');
      expect(url, 'https://example.com');
    });

    test('URL stops at Chinese character boundary', () {
      final url = UrlPreviewService.extractFirstUrl(
        'https://example.com/page 这是中文',
      );
      expect(url, 'https://example.com/page');
    });

    test('URL at start of string is extracted', () {
      final url = UrlPreviewService.extractFirstUrl(
        'https://example.com is a site',
      );
      expect(url, 'https://example.com');
    });

    test('URL at end of string is extracted', () {
      final url = UrlPreviewService.extractFirstUrl(
        'the link is https://example.com',
      );
      expect(url, 'https://example.com');
    });

    test('bare URL with no surrounding text', () {
      final url = UrlPreviewService.extractFirstUrl('https://example.com');
      expect(url, 'https://example.com');
    });

    test('non-http scheme (ftp) is not extracted', () {
      final url = UrlPreviewService.extractFirstUrl('ftp://example.com/file');
      expect(url, isNull);
    });

    test('is case-insensitive for scheme', () {
      final url = UrlPreviewService.extractFirstUrl('HTTP://example.com');
      expect(url, isNotNull);
    });
  });

  group('UrlPreviewService network surface', () {
    test('parses single-quoted meta tags', () async {
      final service = UrlPreviewService(
        clientFactory: () => MockClient((request) async {
          expect(request.url.toString(), 'https://example.com/post');
          return http.Response(
            """
            <html>
              <head>
                <meta property='og:title' content='Single Quote Title'>
                <meta property='og:description' content='Single Quote Description'>
                <meta property='og:image' content='/image.png'>
              </head>
            </html>
            """,
            200,
            headers: {'content-type': 'text/html'},
          );
        }),
      );

      final preview = await service.getPreview('https://example.com/post');

      expect(preview, isNotNull);
      expect(preview!.title, 'Single Quote Title');
      expect(preview.description, 'Single Quote Description');
      expect(preview.imageUrl, 'https://example.com/image.png');
      expect(preview.faviconUrl, 'https://example.com/favicon.ico');
    });

    test('coalesces concurrent requests for same url', () async {
      var requestCount = 0;
      final responseCompleter = Completer<http.Response>();
      final service = UrlPreviewService(
        clientFactory: () => MockClient((request) {
          requestCount++;
          return responseCompleter.future;
        }),
      );

      final firstFuture = service.getPreview('https://example.com/article');
      final secondFuture = service.getPreview('https://example.com/article');

      responseCompleter.complete(
        http.Response(
          '<html><head><meta property="og:title" content="Coalesced"></head></html>',
          200,
          headers: {'content-type': 'text/html'},
        ),
      );

      final results = await Future.wait([firstFuture, secondFuture]);

      expect(requestCount, 1);
      expect(results[0]?.title, 'Coalesced');
      expect(results[1]?.title, 'Coalesced');
    });

    test('reuses cache until ttl expires', () async {
      var requestCount = 0;
      var now = DateTime(2026, 3, 14, 12);
      final service = UrlPreviewService(
        now: () => now,
        clientFactory: () => MockClient((request) async {
          requestCount++;
          return http.Response(
            '<html><head><meta property="og:title" content="Cached"></head></html>',
            200,
            headers: {'content-type': 'text/html'},
          );
        }),
      );

      await service.getPreview('https://example.com/cache');
      await service.getPreview('https://example.com/cache');

      now = now.add(const Duration(minutes: 59));
      await service.getPreview('https://example.com/cache');

      now = now.add(const Duration(minutes: 2));
      await service.getPreview('https://example.com/cache');

      expect(requestCount, 2);
    });

    test('blocks loopback private addresses before network fetch', () async {
      var requestCount = 0;
      final service = UrlPreviewService(
        clientFactory: () => MockClient((request) async {
          requestCount++;
          return http.Response('blocked', 200);
        }),
      );

      final preview = await service.getPreview('http://127.0.0.2/secret');
      final pageText = await service.getPageTextContent('http://127.0.0.2/secret');

      expect(preview, isNull);
      expect(pageText, isNull);
      expect(requestCount, 0);
    });
  });
}
