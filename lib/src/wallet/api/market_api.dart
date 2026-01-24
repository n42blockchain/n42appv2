import 'package:flutter/foundation.dart';
import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/src/https/base_api.dart';

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
