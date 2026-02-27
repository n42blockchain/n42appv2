import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/network/base_api.dart';

class ExchangeApi {
  final String _url;
  final Map<String, String> _header;

  ExchangeApi()
      : _url = AppConfig.getApiUrlOnline('exchangeHost'),
        _header = const {'content-type': 'application/x-www-form-urlencoded'};

  // 获取交易所账户的余额
  Future exchangeBalance(String? coin, String? exchangeName) async {
    final params = {
      'coin': coin,
      'platform': exchangeName ?? 'binance',
      'source': 'app',
      'token': AppGlobals.userInfo?.token ?? '',
      'uuid': AppGlobals.userInfo?.uuid ?? '',
    };
    return await BaseApi.requestEmptyH.get(
      '$_url/v1/user_account/list',
      params: params,
      addUserInfo: true,
      header: _header,
    );
  }
}
