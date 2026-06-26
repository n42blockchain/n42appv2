/// API Hub 桥接接口
///
/// 在主应用中实现此接口以向聊天模块提供市场数据、新闻和 URL 安全检测功能。
///
/// ## 使用示例
///
/// ```dart
/// class MyApiHubBridge implements IApiHubBridge {
///   @override
///   Future<Map<String, double>> getPrices(List<String> symbols) async {
///     return MarketDataAggregator.getPriceMap(symbols);
///   }
/// }
///
/// N42Chat.initialize(N42ChatConfig(
///   apiHubBridge: MyApiHubBridge(),
/// ));
/// ```
abstract class IApiHubBridge {
  /// Fetch USD prices for the given coin symbols (e.g. ['BTC', 'ETH']).
  ///
  /// Returns a map of uppercase symbol → USD price.
  /// Missing symbols are omitted from the result.
  Future<Map<String, double>> getPrices(List<String> symbols);

  /// Check whether a URL is malicious.
  ///
  /// When [useRemote] is true, also queries remote malware databases.
  /// Returns true if the URL is considered malicious, false otherwise.
  Future<bool> isUrlMalicious(String url, {bool useRemote = true});

  /// Fetch latest crypto news items.
  Future<List<BridgeNewsItem>> getLatestNews({int limit = 10});
}

/// Lightweight news item for bridge transport.
class BridgeNewsItem {
  final String title;
  final String url;
  final String sourceName;
  final DateTime publishedAt;

  const BridgeNewsItem({
    required this.title,
    required this.url,
    required this.sourceName,
    required this.publishedAt,
  });
}

/// Mock implementation for testing / when no bridge is configured.
class MockApiHubBridge implements IApiHubBridge {
  @override
  Future<Map<String, double>> getPrices(List<String> symbols) async => {};

  @override
  Future<bool> isUrlMalicious(String url, {bool useRemote = true}) async =>
      false;

  @override
  Future<List<BridgeNewsItem>> getLatestNews({int limit = 10}) async => [];
}
