import 'package:flutter/foundation.dart';
import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/src/https/base_api.dart';

class MarketApi{
  late String url;
  late Map<String,String> header;
  MarketApi(){
    url=AppConfig.getApiUrl_online('marketHost');
    header={'content-type': 'application/json'};
  }
  //获取币的信息，根据币的symbol查询coins='BNB,eth,mtk
  getWalletCoinsInfo(String coins)async{
    try{
      final requestUrl = '${url}/r/targetCoinMarketsList?coin=$coins';
      debugPrint('MarketApi: Fetching coin info from: $requestUrl');
      
      var data=await BaseApi.RequestEmpty_h.get(
        requestUrl,
        params: {},
        header: header,
      );
      
      // 添加调试日志
      debugPrint('MarketApi: Response received, data type: ${data?.runtimeType}');
      if (data != null && data['data'] != null) {
        final coinData = data['data'];
        debugPrint('MarketApi: Coin data count: ${coinData is List ? coinData.length : 'not a list'}');
      } else {
        debugPrint('MarketApi: No data in response');
      }
      
      return {"error":false,"data":data};
    }catch(e, stackTrace){
      debugPrint('MarketApi: Error fetching coin info: $e');
      debugPrint('MarketApi: Stack trace: $stackTrace');
      return {"error":true,"data":e};
    }
  }
  //获取币的基本信息
  getWalletCoinsBaseInfo(String coinName)async{
    try{
      var data=await BaseApi.RequestEmpty_h.get(
        '${url}/r/coinDetail/${coinName}',
        params: {},
        header: header,
      );
      //var data=await Request_h_new.get('/r/coinDetail/${coinName}', params: {});
      if(data['data']==null){
        return {"error":true,"data":"未找到该币"};
      }else{
        return {"error":false,"data":data['data']};
      }
    }catch(e){
      return {"error":true,"data":e};
    }
  }
}
