import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/news/api/news_api.dart';

void main() {
  group('NewsApi.parseRss', () {
    test('RSS 2.0 with media:content + enclosure 图片', () {
      const body = '''
<?xml version="1.0"?>
<rss version="2.0" xmlns:media="http://search.yahoo.com/mrss/">
  <channel>
    <item>
      <title>BTC hits new high</title>
      <link>https://example.com/btc</link>
      <pubDate>Tue, 22 Apr 2026 10:00:00 +0000</pubDate>
      <media:content url="https://cdn.example.com/btc.jpg" />
    </item>
    <item>
      <title>ETH upgrade ships</title>
      <link>https://example.com/eth</link>
      <pubDate>Mon, 21 Apr 2026 09:00:00 +0000</pubDate>
      <enclosure url="https://cdn.example.com/eth.png" type="image/png" />
    </item>
  </channel>
</rss>
''';

      final items = NewsApi.parseRss(body);
      expect(items, hasLength(2));
      expect(items[0]['title'], 'BTC hits new high');
      expect(items[0]['link'], 'https://example.com/btc');
      expect(items[0]['image'], 'https://cdn.example.com/btc.jpg');
      expect(items[0]['pubDate'], 'Tue, 22 Apr 2026 10:00:00 +0000');
      expect(items[1]['image'], 'https://cdn.example.com/eth.png');
    });

    test('description 里 <img> 是最后一档图片来源', () {
      const body = '''
<?xml version="1.0"?>
<rss version="2.0">
  <channel>
    <item>
      <title>Story without media tags</title>
      <link>https://example.com/x</link>
      <pubDate>Sun, 20 Apr 2026 00:00:00 +0000</pubDate>
      <description><![CDATA[Hello <img src="https://cdn.example.com/x.png" alt="x"/> world]]></description>
    </item>
  </channel>
</rss>
''';

      final items = NewsApi.parseRss(body);
      expect(items, hasLength(1));
      expect(items[0]['image'], 'https://cdn.example.com/x.png');
    });

    test('缺少 title 或 link 的 item 被跳过', () {
      const body = '''
<?xml version="1.0"?>
<rss version="2.0">
  <channel>
    <item><title>no link</title></item>
    <item><link>https://example.com</link></item>
    <item>
      <title>good</title>
      <link>https://example.com/g</link>
    </item>
  </channel>
</rss>
''';

      final items = NewsApi.parseRss(body);
      expect(items, hasLength(1));
      expect(items[0]['title'], 'good');
    });

    test('坏 XML 不抛异常，返回空列表', () {
      expect(NewsApi.parseRss('<not valid xml'), isEmpty);
    });

    test('image 字段在没有任何来源时为空字符串', () {
      const body = '''
<?xml version="1.0"?>
<rss version="2.0">
  <channel>
    <item>
      <title>No media</title>
      <link>https://example.com/n</link>
    </item>
  </channel>
</rss>
''';

      final items = NewsApi.parseRss(body);
      expect(items, hasLength(1));
      expect(items[0]['image'], '');
    });
  });
}
