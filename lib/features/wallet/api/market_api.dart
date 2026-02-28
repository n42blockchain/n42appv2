import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/config/api_keys_config.dart';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/features/wallet/models/ohlc_point.dart';

class MarketApi {
  final String _url;
  final Map<String, String> _header;

  MarketApi()
      : _url = AppConfig.getApiUrlOnline('marketHost'),
        _header = const {'content-type': 'application/json'};

  // 有 API key 时使用 Pro endpoint（更高限额），否则用免费 endpoint。
  static String get _geckoBase {
    final key = ApiKeysConfig.coinGeckoApiKey;
    if (key.isNotEmpty) return 'https://pro-api.coingecko.com/api/v3';
    return (AppConfig.apiUrl['coinGeckoApi'] as String?) ??
        'https://api.coingecko.com/api/v3';
  }

  /// CoinGecko 请求头：有 key 时加上认证头。
  Map<String, String> get _geckoHeader {
    final key = ApiKeysConfig.coinGeckoApiKey;
    if (key.isEmpty) return {'content-type': 'application/json'};
    return {
      'content-type': 'application/json',
      'x-cg-demo-api-key': key,
    };
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// 获取币的信息，根据币的 symbol 查询
  /// [coins] 币种 symbol 列表，逗号分隔，如 'BNB,eth,btc'
  Future<Map<String, dynamic>> getWalletCoinsInfo(String coins) async {
    try {
      final cleanedCoins = coins
          .split(',')
          .where((c) => c.trim().isNotEmpty)
          .map((c) => c.trim().toLowerCase())
          .toSet()
          .join(',');

      if (cleanedCoins.isEmpty) {
        debugPrint('MarketApi: No valid coins to query');
        return {'error': true, 'data': 'No coins specified'};
      }

      debugPrint('MarketApi.getWalletCoinsInfo: $cleanedCoins');

      final data = await BaseApi.requestEmptyH.get<dynamic>(
        '$_url/r/targetCoinMarketsList?coin=$cleanedCoins',
        params: {},
        header: _header,
      );

      if (data == null) return {'error': true, 'data': 'Null response'};
      return {'error': false, 'data': data};
    } catch (e, st) {
      debugPrint('MarketApi.getWalletCoinsInfo error: $e\n$st');
      return {'error': true, 'data': e.toString()};
    }
  }

  /// 获取 OHLCV K 线数据（CoinGecko /coins/{id}/ohlc）
  ///
  /// [geckoId] – CoinGecko 币种 ID（例如 'bitcoin'）
  /// [days]    – 时间跨度（1, 7, 14, 30, 90, 180, 365）
  ///
  /// 只返回通过 [OhlcPoint.isValid] 校验的数据点；无效或格式异常的条目静默丢弃。
  Future<List<OhlcPoint>> getOhlcvData(String geckoId, {int days = 1}) async {
    if (geckoId.isEmpty) return [];
    try {
      final encodedId = Uri.encodeComponent(geckoId);
      debugPrint('MarketApi.getOhlcvData: $encodedId days=$days');

      final raw = await BaseApi.requestEmptyH.get<dynamic>(
        '$_geckoBase/coins/$encodedId/ohlc?vs_currency=usd&days=$days',
        params: {},
        header: _geckoHeader,
      );

      if (raw == null || raw is! List) return [];

      return raw
          .whereType<List>()
          .where((item) => item.length >= 5)
          .map((item) => OhlcPoint(
                open: _toDouble(item[1]),
                high: _toDouble(item[2]),
                low: _toDouble(item[3]),
                close: _toDouble(item[4]),
              ))
          .where((p) => p.isValid)
          .toList();
    } catch (e, st) {
      debugPrint('MarketApi.getOhlcvData error: $e\n$st');
      return [];
    }
  }

  /// 获取市场图表数据（价格 + 交易量时序，CoinGecko /coins/{id}/market_chart）
  ///
  /// 返回 `{'prices': [double], 'volumes': [double]}` 两个等长列表。
  Future<Map<String, List<double>>> getMarketChart(
    String geckoId, {
    int days = 1,
  }) async {
    const empty = {'prices': <double>[], 'volumes': <double>[]};
    if (geckoId.isEmpty) return empty;
    try {
      final encodedId = Uri.encodeComponent(geckoId);
      debugPrint('MarketApi.getMarketChart: $encodedId days=$days');

      final raw = await BaseApi.requestEmptyH.get<dynamic>(
        '$_geckoBase/coins/$encodedId/market_chart?vs_currency=usd&days=$days',
        params: {},
        header: _geckoHeader,
      );

      if (raw == null || raw is! Map) return empty;

      return {
        'prices': _extractDoubleValues(raw['prices']),
        'volumes': _extractDoubleValues(raw['total_volumes']),
      };
    } catch (e, st) {
      debugPrint('MarketApi.getMarketChart error: $e\n$st');
      return empty;
    }
  }

  /// 获取 CoinGecko Trending 币种列表（/search/trending）
  ///
  /// 返回 trending coins 的 item 列表，每项包含 id, name, symbol, thumb, large,
  /// market_cap_rank, data 等字段。网络异常或解析失败返回空列表。
  ///
  /// 无 API key 时直接返回空列表，由调用方切换至 N42 后端 fallback。
  /// 免费端点在中国大陆不可访问，不应浪费 60s 超时。
  Future<List<Map<String, dynamic>>> getTrendingCoins() async {
    if (ApiKeysConfig.coinGeckoApiKey.isEmpty) return [];
    try {
      debugPrint('MarketApi.getTrendingCoins');

      final raw = await BaseApi.requestEmptyH.get<dynamic>(
        '$_geckoBase/search/trending',
        params: {},
        header: _geckoHeader,
      );

      if (raw == null || raw is! Map) return [];
      final coins = raw['coins'];
      if (coins is! List) return [];

      return coins
          .whereType<Map<dynamic, dynamic>>()
          .map((c) {
            final item = c['item'];
            if (item is! Map) return null;
            return Map<String, dynamic>.from(item);
          })
          .whereType<Map<String, dynamic>>()
          .toList();
    } catch (e, st) {
      debugPrint('MarketApi.getTrendingCoins error: $e\n$st');
      return [];
    }
  }

  /// 搜索币种（CoinGecko /search?q={query}）
  ///
  /// [query] 为空时直接返回 `[]`。
  /// 返回搜索结果 coins 列表，每项包含 id, name, symbol, thumb, large,
  /// market_cap_rank 等字段。网络异常返回空列表。
  Future<List<Map<String, dynamic>>> searchCoins(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      debugPrint('MarketApi.searchCoins: $query');

      final raw = await BaseApi.requestEmptyH.get<dynamic>(
        '$_geckoBase/search?q=${Uri.encodeQueryComponent(query.trim())}',
        params: {},
        header: _geckoHeader,
      );

      if (raw == null || raw is! Map) return [];
      final coins = raw['coins'];
      if (coins is! List) return [];

      return coins
          .whereType<Map<dynamic, dynamic>>()
          .map((c) => Map<String, dynamic>.from(c))
          .toList();
    } catch (e, st) {
      debugPrint('MarketApi.searchCoins error: $e\n$st');
      return [];
    }
  }

  /// 硬编码热门币列表，当 CoinGecko trending 不可用时作为 fallback。
  static const String _fallbackTrendingSymbols =
      'btc,eth,sol,bnb,xrp,ada,avax,doge,dot,link';

  /// 从 N42 后端获取 fallback trending 数据。
  ///
  /// 返回格式与 watchlist 一致（`coin`, `name`, `price`, `price_change_per_24h`,
  /// `image`, `coin_gecko_id`, `market_cap_rank`），调用方可直接以
  /// [_CoinSource.watchlist] 方式渲染。
  Future<List<Map<String, dynamic>>> getFallbackTrendingCoins() async {
    try {
      debugPrint('MarketApi.getFallbackTrendingCoins');

      final resp = await getWalletCoinsInfo(_fallbackTrendingSymbols);
      if (resp['error'] != false) return [];

      final rawData = resp['data'];
      final coins = (rawData is List)
          ? rawData
          : (rawData is Map ? rawData['data'] : null);
      if (coins is! List) return [];

      return coins
          .whereType<Map<dynamic, dynamic>>()
          .map((c) => Map<String, dynamic>.from(c))
          .toList();
    } catch (e, st) {
      debugPrint('MarketApi.getFallbackTrendingCoins error: $e\n$st');
      return [];
    }
  }

  /// 获取币的基本详情信息（N42 market API → CoinGecko proxy）
  Future<Map<String, dynamic>> getWalletCoinsBaseInfo(String coinName) async {
    if (coinName.isEmpty) return {'error': true, 'data': '未找到该币'};
    try {
      final data = await BaseApi.requestEmptyH.get<dynamic>(
        '$_url/r/coinDetail/${Uri.encodeComponent(coinName)}',
        params: {},
        header: _header,
      );

      final d = (data is Map) ? data['data'] : null;
      if (d == null) return {'error': true, 'data': '未找到该币'};
      return {'error': false, 'data': d};
    } catch (e, st) {
      debugPrint('MarketApi.getWalletCoinsBaseInfo error: $e\n$st');
      return {'error': true, 'data': e.toString()};
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Safely extract a double from an API value that may be num or String.
  static double _toDouble(dynamic v, [double fallback = 0.0]) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  /// Extract the second element from each `[timestamp, value]` pair.
  static List<double> _extractDoubleValues(dynamic series) {
    if (series is! List) return [];
    final result = <double>[];
    for (final item in series) {
      if (item is List && item.length >= 2) {
        result.add(_toDouble(item[1]));
      }
    }
    return result;
  }
}
