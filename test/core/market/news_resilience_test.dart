import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/api_hub/aggregators/news_aggregator.dart';
import 'package:n42_wallet/core/market/crypto_news_service.dart';
import 'package:n42_wallet/core/market/fear_greed_service.dart';

NewsArticle _article({
  required String id,
  required String url,
  required int minutesAgo,
}) {
  return NewsArticle(
    id: id,
    title: 'Title $id',
    url: url,
    sourceName: 'test',
    publishedAt: DateTime.now().subtract(Duration(minutes: minutesAgo)),
  );
}

void main() {
  group('news and market resilience helpers', () {
    test('CryptoNewsService keeps fallback when RSS body is invalid', () {
      final fallback = [
        _article(id: 'cached', url: 'https://cached', minutesAgo: 5),
      ];

      final result = CryptoNewsService.parseRssArticles(
        'not-xml',
        fallback: fallback,
      );

      expect(result, same(fallback));
    });

    test('CryptoNewsService parses RSS items into NewsArticles', () {
      const rss = '''
<rss version="2.0">
  <channel>
    <title>Cointelegraph</title>
    <item>
      <title>BTC hits new high</title>
      <link>https://example.com/a</link>
      <pubDate>Mon, 15 Jun 2026 12:00:00 GMT</pubDate>
      <media:content url="https://img/a.jpg" xmlns:media="http://x"/>
    </item>
    <item>
      <title>Missing link is skipped</title>
      <link></link>
    </item>
  </channel>
</rss>''';

      final result = CryptoNewsService.parseRssArticles(rss);

      expect(result.length, 1);
      expect(result.first.title, 'BTC hits new high');
      expect(result.first.url, 'https://example.com/a');
      expect(result.first.imageUrl, 'https://img/a.jpg');
      expect(result.first.sourceName, 'Cointelegraph');
    });

    test('CryptoNewsService prefers item source over channel source', () {
      const rss = '''
<rss version="2.0">
  <channel>
    <title>Aggregated Crypto News</title>
    <item>
      <title>BTC update</title>
      <link>https://example.com/btc</link>
      <pubDate>Mon, 15 Jun 2026 12:00:00 GMT</pubDate>
      <source url="https://example.com">Example Wire</source>
    </item>
  </channel>
</rss>''';

      final result = CryptoNewsService.parseRssArticles(rss);

      expect(result, hasLength(1));
      expect(result.first.sourceName, 'Example Wire');
    });

    test('NewsAggregator deduplicates and sorts newest first', () {
      final older = _article(id: '1', url: 'https://same', minutesAgo: 10);
      final newer = _article(id: '2', url: 'https://same', minutesAgo: 1);
      final another = _article(id: '3', url: 'https://other', minutesAgo: 3);

      final merged = NewsAggregator.mergeArticles([
        [older, another],
        [newer],
      ]);

      expect(merged.length, 2);
      expect(merged.first.url, 'https://same');
      expect(merged.last.url, 'https://other');
    });

    test('NewsAggregator returns fallback when all sources are empty', () {
      final fallback = [
        _article(id: 'cached', url: 'https://cached', minutesAgo: 5),
      ];

      final merged = NewsAggregator.mergeArticles(const [
        [],
        [],
      ], fallback: fallback);

      expect(merged, same(fallback));
    });

    test('FearGreedService keeps fallback value when response is invalid', () {
      final fallback = FearGreedData(
        value: 72,
        classification: 'Greed',
        updatedAt: DateTime.now(),
      );

      final result = FearGreedService.parseResponse({
        'unexpected': [],
      }, fallback: fallback);

      expect(result, same(fallback));
    });
  });
}
