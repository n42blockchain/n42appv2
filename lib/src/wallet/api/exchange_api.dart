import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/src/https/base_api.dart';

class ExchangeApi{
  late String url;
  late Map<String,String> header;
  ExchangeApi(){
    url=AppConfig.getApiUrlOnline('exchangeHost');
    header={'content-type': 'application/x-www-form-urlencoded'};
  }

  //获取交易所账户的余额
  Future exchangeBalance(String? coin, String? exchangeName) async {
    Map<String, dynamic> params = {};
    params["coin"] = coin;
    params["platform"] = exchangeName ?? 'binance';
    params["source"] = "app";
    params["token"] = AppGlobals.userInfo?.token??"";
    params["uuid"] = AppGlobals.userInfo?.uuid??"";
    final data =
    await BaseApi.requestEmptyH.get('$url/v1/user_account/list', params: params,addUserInfo: true,header: header,);
    return data;
  }
}
