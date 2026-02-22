import 'package:flutter/foundation.dart';
import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/src/https/base_api.dart';
// [FIX A1] Import OhlcPoint from the model layer, NOT from the UI widget layer.
import 'package:n42appv2/src/wallet/models/ohlc_point.dart';

class MarketApi {
  // [FIX] Use final for fields that are never reassigned after construction.
  final String _url;
  final Map<String, String> _header;

  MarketApi()
      : _url = AppConfig.getApiUrlOnline('marketHost'),
        _header = const {'content-type': 'application/json'};

  // [FIX] Single location for the CoinGecko base URL so both methods stay in
  // sync with the config value.
  static String get _geckoBase =>
      (AppConfig.apiUrl['coinGeckoApi'] as String?) ??
      'https://api.coingecko.com/api/v3';

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

      final requestUrl = '$_url/r/targetCoinMarketsList?coin=$cleanedCoins';
      // [FIX M5] Keep only essential log; remove per-item data dumps.
      debugPrint('MarketApi.getWalletCoinsInfo: $cleanedCoins');

      final data = await BaseApi.requestEmptyH.get<dynamic>(
        requestUrl,
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
      // [FIX S1] URI-encode geckoId to prevent path injection.
      final encodedId = Uri.encodeComponent(geckoId);
      final requestUrl =
          '$_geckoBase/coins/$encodedId/ohlc?vs_currency=usd&days=$days';
      debugPrint('MarketApi.getOhlcvData: $encodedId days=$days');

      final raw = await BaseApi.requestEmptyH.get<dynamic>(
        requestUrl,
        params: {},
        header: _header,
      );

      if (raw == null || raw is! List) return [];

      // [FIX M3] Validate OHLC constraints via OhlcPoint.isValid.
      final result = <OhlcPoint>[];
      for (final item in raw) {
        if (item is! List || item.length < 5) continue;
        final point = OhlcPoint(
          open: _toDouble(item[1]),
          high: _toDouble(item[2]),
          low: _toDouble(item[3]),
          close: _toDouble(item[4]),
        );
        if (point.isValid) result.add(point);
      }
      return result;
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
      // [FIX S1] URI-encode geckoId.
      final encodedId = Uri.encodeComponent(geckoId);
      final requestUrl =
          '$_geckoBase/coins/$encodedId/market_chart?vs_currency=usd&days=$days';
      debugPrint('MarketApi.getMarketChart: $encodedId days=$days');

      final raw = await BaseApi.requestEmptyH.get<dynamic>(
        requestUrl,
        params: {},
        header: _header,
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

  /// 获取币的基本详情信息（N42 market API → CoinGecko proxy）
  Future<Map<String, dynamic>> getWalletCoinsBaseInfo(String coinName) async {
    if (coinName.isEmpty) return {'error': true, 'data': '未找到该币'};
    try {
      final data = await BaseApi.requestEmptyH.get<dynamic>(
        '$_url/r/coinDetail/${Uri.encodeComponent(coinName)}',
        params: {},
        header: _header,
      );

      if (data == null || (data is Map && data['data'] == null)) {
        return {'error': true, 'data': '未找到该币'};
      }
      return {'error': false, 'data': data['data']};
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
