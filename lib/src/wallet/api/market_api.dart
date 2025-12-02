import 'package:n42appv2/app_config.dart';
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
      var data=await BaseApi.RequestEmpty_h.get(
        '${url}/r/targetCoinMarketsList?coin=$coins',
        params: {},
        header: header,
      );
      //var data=await Request_h_new.get('/r/targetCoinMarketsList?coin=$coins', params: {});
      return {"error":false,"data":data};
    }catch(e){
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