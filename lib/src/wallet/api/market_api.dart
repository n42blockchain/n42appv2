import 'package:flutter/foundation.dart';
import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/widgets/candlestick_chart.dart';

class MarketApi {
  late String url;
  late Map<String, String> header;
  
  MarketApi() {
    url = AppConfig.getApiUrlOnline('marketHost');
    header = {'content-type': 'application/json'};
  }
  
  /// 获取币的信息，根据币的symbol查询
  /// [coins] 币种symbol列表，逗号分隔，如 'BNB,eth,btc'
  Future<Map<String, dynamic>> getWalletCoinsInfo(String coins) async {
    try {
      // 清理和标准化请求参数
      final cleanedCoins = coins
          .split(',')
          .where((c) => c.trim().isNotEmpty)
          .map((c) => c.trim().toLowerCase())
          .toSet()  // 去重
          .join(',');
      
      if (cleanedCoins.isEmpty) {
        debugPrint('MarketApi: No valid coins to query');
        return {"error": true, "data": "No coins specified"};
      }
      
      final requestUrl = '$url/r/targetCoinMarketsList?coin=$cleanedCoins';
      debugPrint('MarketApi: Fetching coin info from: $requestUrl');
      
      var data = await BaseApi.requestEmptyH.get(
        requestUrl,
        params: {},
        header: header,
      );
      
      // 详细调试日志
      debugPrint('MarketApi: Response type: ${data?.runtimeType}');
      
      if (data == null) {
        debugPrint('MarketApi: Null response received');
        return {"error": true, "data": "Null response"};
      }
      
      if (data['data'] != null) {
        final coinData = data['data'];
        if (coinData is List) {
          debugPrint('MarketApi: Got ${coinData.length} coins');
          // 打印前3个币的信息用于调试
          for (int i = 0; i < coinData.length && i < 3; i++) {
            final coin = coinData[i];
            debugPrint('MarketApi: Coin[$i]: symbol=${coin['coin']}, price=${coin['price']}, change=${coin['price_change_per_24h']}');
          }
        } else {
          debugPrint('MarketApi: Data is not a list: ${coinData.runtimeType}');
        }
      } else {
        debugPrint('MarketApi: No data in response, full response: $data');
      }
      
      return {"error": false, "data": data};
    } catch (e, stackTrace) {
      debugPrint('MarketApi: Error fetching coin info: $e');
      debugPrint('MarketApi: Stack trace: $stackTrace');
      return {"error": true, "data": e.toString()};
    }
  }
  
  /// 获取 OHLCV K线数据（CoinGecko /coins/{id}/ohlc）
  /// [geckoId] - CoinGecko 币种 ID
  /// [days]    - 时间跨度（1, 7, 14, 30, 90, 180, 365）
  /// 返回 [open, high, low, close] 列表（CoinGecko 不含 volume）
  Future<List<OhlcPoint>> getOhlcvData(String geckoId, {int days = 1}) async {
    try {
      final base = AppConfig.apiUrl['coinGeckoApi'] as String? ??
          'https://api.coingecko.com/api/v3';
      final requestUrl = '$base/coins/$geckoId/ohlc?vs_currency=usd&days=$days';
      debugPrint('MarketApi: OHLCV → $requestUrl');
      final raw = await BaseApi.requestEmptyH.get<dynamic>(
        requestUrl,
        params: {},
        header: {'content-type': 'application/json'},
      );
      if (raw == null || raw is! List) return [];
      return raw
          .where((item) => item is List && item.length >= 5)
          .map((item) => OhlcPoint(
                open: (item[1] as num).toDouble(),
                high: (item[2] as num).toDouble(),
                low: (item[3] as num).toDouble(),
                close: (item[4] as num).toDouble(),
              ))
          .toList();
    } catch (e) {
      debugPrint('MarketApi.getOhlcvData error: $e');
      return [];
    }
  }

  /// 获取市场图表数据（价格 + 交易量时序）
  /// 返回 {'prices': [[ts,price],...], 'volumes': [[ts,vol],...]}
  Future<Map<String, List<double>>> getMarketChart(
      String geckoId, {
      int days = 1,
    }) async {
    try {
      final base = AppConfig.apiUrl['coinGeckoApi'] as String? ??
          'https://api.coingecko.com/api/v3';
      // CoinGecko free tier: interval 自动决定（1d→minutely、>1d→hourly/daily）
      final requestUrl =
          '$base/coins/$geckoId/market_chart?vs_currency=usd&days=$days';
      debugPrint('MarketApi: market_chart → $requestUrl');
      final raw = await BaseApi.requestEmptyH.get<dynamic>(
        requestUrl,
        params: {},
        header: {'content-type': 'application/json'},
      );
      if (raw == null || raw is! Map) return {'prices': [], 'volumes': []};
      List<double> extractValues(dynamic series) {
        if (series is! List) return [];
        return series
            .where((item) => item is List && item.length >= 2)
            .map((item) => (item[1] as num).toDouble())
            .toList();
      }
      return {
        'prices': extractValues(raw['prices']),
        'volumes': extractValues(raw['total_volumes']),
      };
    } catch (e) {
      debugPrint('MarketApi.getMarketChart error: $e');
      return {'prices': [], 'volumes': []};
    }
  }

  /// 获取币的基本详情信息
  Future<Map<String, dynamic>> getWalletCoinsBaseInfo(String coinName) async {
    try {
      var data = await BaseApi.requestEmptyH.get(
        '$url/r/coinDetail/$coinName',
        params: {},
        header: header,
      );
      
      if (data == null || data['data'] == null) {
        return {"error": true, "data": "未找到该币"};
      }
      return {"error": false, "data": data['data']};
    } catch (e) {
      debugPrint('MarketApi: Error fetching coin detail: $e');
      return {"error": true, "data": e.toString()};
    }
  }
}
