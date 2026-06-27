/// 法币出入金配置
class FiatRampConfig {
  /// 通道：moonpay | transak
  final String provider;

  /// 可发布 key（host 通过 N42ChatConfig 注入；无则功能不可用）
  final String apiKey;

  /// 买入 widget base url（留空用通道默认）
  final String baseUrlBuy;

  /// 卖出 widget base url（留空用通道默认）
  final String baseUrlSell;

  const FiatRampConfig({
    this.provider = 'moonpay',
    this.apiKey = '',
    this.baseUrlBuy = '',
    this.baseUrlSell = '',
  });
}

/// 法币出入金服务
///
/// 生成 MoonPay / Transak 的 widget URL（买/卖），由 [FiatRampPage] 用 WebView 打开。
/// **依赖 host 提供可发布 key**（同 GIF 的 key 模式）；未配置时 `isAvailable=false`，
/// 入口与页面会显示"未配置"降级提示，不会误导为可用。
class FiatRampService {
  final FiatRampConfig _config;

  FiatRampService(this._config);

  bool get isAvailable => _config.apiKey.isNotEmpty;

  String get provider => _config.provider;

  /// 买入 URL（充值法币→加密）
  String? buildBuyUrl({String? walletAddress, String currencyCode = 'usdt'}) {
    if (!isAvailable) return null;
    if (_config.provider == 'transak') {
      return Uri.parse(_config.baseUrlBuy.isEmpty
              ? 'https://global.transak.com'
              : _config.baseUrlBuy)
          .replace(queryParameters: {
        'apiKey': _config.apiKey,
        'defaultCryptoCurrency': currencyCode.toUpperCase(),
        if (walletAddress != null && walletAddress.isNotEmpty)
          'walletAddress': walletAddress,
      }).toString();
    }
    // moonpay
    return Uri.parse(_config.baseUrlBuy.isEmpty
            ? 'https://buy.moonpay.com'
            : _config.baseUrlBuy)
        .replace(queryParameters: {
      'apiKey': _config.apiKey,
      'currencyCode': currencyCode,
      if (walletAddress != null && walletAddress.isNotEmpty)
        'walletAddress': walletAddress,
    }).toString();
  }

  /// 卖出 URL（加密→法币）
  String? buildSellUrl({String currencyCode = 'usdt'}) {
    if (!isAvailable) return null;
    if (_config.provider == 'transak') {
      return Uri.parse(_config.baseUrlSell.isEmpty
              ? 'https://global.transak.com'
              : _config.baseUrlSell)
          .replace(queryParameters: {
        'apiKey': _config.apiKey,
        'productsAvailed': 'SELL',
        'defaultCryptoCurrency': currencyCode.toUpperCase(),
      }).toString();
    }
    return Uri.parse(_config.baseUrlSell.isEmpty
            ? 'https://sell.moonpay.com'
            : _config.baseUrlSell)
        .replace(queryParameters: {
      'apiKey': _config.apiKey,
      'baseCurrencyCode': currencyCode,
    }).toString();
  }
}
