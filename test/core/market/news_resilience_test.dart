import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/api_hub/aggregators/news_aggregator.dart';
import 'package:n42_wallet/core/api_hub/datasources/messari_datasource.dart';
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
    test('CryptoNewsService keeps fallback articles when response is invalid', () {
      final fallback = [_article(id: 'cached', url: 'https://cached', minutesAgo: 5)];

      final result = CryptoNewsService.parseLatestResponse(
        {'unexpected': []},
        fallback: fallback,
      );

      expect(result, same(fallback));
    });

    test('MessariDatasource keeps fallback news when parsed articles are empty', () {
      final fallback = [_article(id: 'cached', url: 'https://cached', minutesAgo: 5)];

      final result = MessariDatasource.parseNewsResponse(
        {
          'data': [
            {'title': '', 'url': ''},
          ],
        },
        fallback: fallback,
      );

      expect(result, same(fallback));
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
      final fallback = [_article(id: 'cached', url: 'https://cached', minutesAgo: 5)];

      final merged = NewsAggregator.mergeArticles(
        const [[], []],
        fallback: fallback,
      );

      expect(merged, same(fallback));
    });

    test('FearGreedService keeps fallback value when response is invalid', () {
      final fallback = FearGreedData(
        value: 72,
        classification: 'Greed',
        updatedAt: DateTime.now(),
      );

      final result = FearGreedService.parseResponse(
        {'unexpected': []},
        fallback: fallback,
      );

      expect(result, same(fallback));
    });
  });
}
