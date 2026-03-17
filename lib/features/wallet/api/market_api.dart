import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/config/proxy_config.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/core/network/external_http.dart';
import 'package:n42_wallet/features/wallet/api/market_api_payload_utils.dart';
import 'package:n42_wallet/features/wallet/models/ohlc_point.dart';

class MarketApi {
  final String _url;
  final Map<String, String> _header;

  MarketApi()
    : _url = AppConfig.getApiUrlOnline('marketHost'),
      _header = const {'content-type': 'application/json'};

  /// CoinGecko 请求头 — API key 已迁移到服务端代理。
  Map<String, String> get _geckoHeader => const {
    'content-type': 'application/json',
  };

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
        if (kDebugMode) debugPrint('MarketApi: No valid coins to query');
        return {'error': true, 'data': 'No coins specified'};
      }

      if (kDebugMode) debugPrint('MarketApi.getWalletCoinsInfo: $cleanedCoins');

      final data = await BaseApi.requestEmptyH.get<dynamic>(
        '$_url/r/targetCoinMarketsList?coin=$cleanedCoins',
        params: {},
        header: _header,
      );

      if (data == null) return {'error': true, 'data': 'Null response'};
      return {'error': false, 'data': data};
    } catch (e, st) {
      if (kDebugMode) debugPrint('MarketApi.getWalletCoinsInfo error: $e\n$st');
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
      if (kDebugMode)
        debugPrint('MarketApi.getOhlcvData: $encodedId days=$days');

      final raw = await ExternalHttp.get(
        '${ProxyConfig.marketOhlcv}?coin_id=$encodedId&vs_currency=usd&days=$days',
        headers: _geckoHeader,
      ).timeout(const Duration(seconds: 15), onTimeout: () => null);

      if (raw == null || raw is! List) return [];

      return raw
          .whereType<List>()
          .where((item) => item.length >= 5)
          .map(
            (item) => OhlcPoint(
              open: _toDouble(item[1]),
              high: _toDouble(item[2]),
              low: _toDouble(item[3]),
              close: _toDouble(item[4]),
            ),
          )
          .where((p) => p.isValid)
          .toList();
    } catch (e, st) {
      if (kDebugMode) debugPrint('MarketApi.getOhlcvData error: $e\n$st');
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
      if (kDebugMode)
        debugPrint('MarketApi.getMarketChart: $encodedId days=$days');

      final raw = await ExternalHttp.get(
        '${ProxyConfig.marketChart}?coin_id=$encodedId&vs_currency=usd&days=$days',
        headers: _geckoHeader,
      ).timeout(const Duration(seconds: 15), onTimeout: () => null);

      if (raw == null || raw is! Map) return empty;

      return {
        'prices': _extractDoubleValues(raw['prices']),
        'volumes': _extractDoubleValues(raw['total_volumes']),
      };
    } catch (e, st) {
      if (kDebugMode) debugPrint('MarketApi.getMarketChart error: $e\n$st');
      return empty;
    }
  }

  /// 获取 CoinGecko Trending 币种列表（/search/trending）
  ///
  /// 返回 trending coins 的 item 列表，每项包含 id, name, symbol, thumb, large,
  /// market_cap_rank, data 等字段。网络异常或解析失败返回空列表。
  ///
  /// 使用 8 秒 Dart 级超时：在可访问地区（如加拿大）CoinGecko 通常 ~1s 返回；
  /// 在封锁地区 8s 后返回空列表，由调用方切换至 N42 后端 fallback，
  /// 避免占用 Dio 的 60s + RetryInterceptor 的 3x 重试（总计 4 分钟）。
  Future<List<Map<String, dynamic>>> getTrendingCoins() async {
    try {
      if (kDebugMode) debugPrint('MarketApi.getTrendingCoins');

      final raw = await ExternalHttp.get(
        ProxyConfig.marketTrending,
        headers: _geckoHeader,
      ).timeout(const Duration(seconds: 8), onTimeout: () => null);

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
      if (kDebugMode) debugPrint('MarketApi.getTrendingCoins error: $e\n$st');
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
      if (kDebugMode) debugPrint('MarketApi.searchCoins: $query');

      final raw = await ExternalHttp.get(
        '${ProxyConfig.marketSearch}?q=${Uri.encodeQueryComponent(query.trim())}',
        headers: _geckoHeader,
      ).timeout(const Duration(seconds: 8), onTimeout: () => null);

      if (raw == null || raw is! Map) return [];
      final coins = raw['coins'];
      if (coins is! List) return [];

      return coins
          .whereType<Map<dynamic, dynamic>>()
          .map((c) => Map<String, dynamic>.from(c))
          .toList();
    } catch (e, st) {
      if (kDebugMode) debugPrint('MarketApi.searchCoins error: $e\n$st');
      return [];
    }
  }

  /// 硬编码热门币列表，当 CoinGecko trending 不可用时作为 fallback。
  /// 覆盖 Top 50 主流币种（按市值排序），确保 proxy 不可用时仍有丰富展示。
  static const String _fallbackTrendingSymbols =
      'btc,eth,sol,bnb,xrp,ada,avax,doge,dot,link,'
      'trx,matic,shib,ltc,atom,uni,xlm,near,apt,icp,'
      'fil,arb,op,sui,sei,inj,vet,algo,ftm,hbar,'
      'mana,sand,gala,aave,mkr,ldo,snx,crv,rune,egld,'
      'grt,ape,imx,mina,flow,kas,ton,stx,ondo,pepe';

  /// 从 N42 后端获取 fallback trending 数据。
  ///
  /// 返回格式与 watchlist 一致（`coin`, `name`, `price`, `price_change_per_24h`,
  /// `image`, `coin_gecko_id`, `market_cap_rank`），调用方可直接以
  /// [_CoinSource.watchlist] 方式渲染。
  Future<List<Map<String, dynamic>>> getFallbackTrendingCoins() async {
    try {
      if (kDebugMode) debugPrint('MarketApi.getFallbackTrendingCoins');

      final resp = await getWalletCoinsInfo(_fallbackTrendingSymbols);
      if (resp['error'] != false) return [];

      return extractMarketCoinItems(resp['data']);
    } catch (e, st) {
      if (kDebugMode)
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
      if (kDebugMode)
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
