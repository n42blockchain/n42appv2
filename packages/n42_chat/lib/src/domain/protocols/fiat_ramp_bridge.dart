/// 法币出入金桥接协议。
///
/// 由宿主应用实现并注入。n42_chat 通过此协议调起 MoonPay / Transak
/// 的 WebView 流程，完成法币 ↔ 加密货币兑换。
///
/// 注入方式：`N42Chat.configureFiatRampBridge(MyImpl())`
abstract class FiatRampBridge {
  /// 获取买入 URL（法币 → 加密货币）。
  ///
  /// [walletAddress] 收款钱包地址。
  /// [cryptoCurrency] 目标币种（如 ETH, USDT）。
  /// [fiatCurrency] 法币币种（如 USD, CNY, EUR）。
  /// [fiatAmount] 法币金额。
  /// [provider] 指定提供商（moonpay / transak），null 为自动选择。
  Future<FiatRampUrl> getBuyUrl({
    required String walletAddress,
    required String cryptoCurrency,
    String fiatCurrency = 'USD',
    double? fiatAmount,
    FiatRampProvider? provider,
  });

  /// 获取卖出 URL（加密货币 → 法币）。
  Future<FiatRampUrl> getSellUrl({
    required String walletAddress,
    required String cryptoCurrency,
    double? cryptoAmount,
    String fiatCurrency = 'USD',
    FiatRampProvider? provider,
  });

  /// 获取支持的法币列表。
  Future<List<String>> getSupportedFiatCurrencies(FiatRampProvider provider);

  /// 获取支持的加密货币列表。
  Future<List<String>> getSupportedCryptoCurrencies(FiatRampProvider provider);

  /// 获取当前汇率。
  Future<FiatRampQuote> getQuote({
    required String cryptoCurrency,
    required String fiatCurrency,
    required double fiatAmount,
    required FiatRampType type,
    FiatRampProvider? provider,
  });
}

enum FiatRampProvider {
  moonpay,
  transak,
}

enum FiatRampType {
  buy,
  sell,
}

class FiatRampUrl {
  const FiatRampUrl({
    required this.url,
    required this.provider,
    required this.type,
  });

  final String url;
  final FiatRampProvider provider;
  final FiatRampType type;
}

class FiatRampQuote {
  const FiatRampQuote({
    required this.cryptoAmount,
    required this.fiatAmount,
    required this.cryptoCurrency,
    required this.fiatCurrency,
    required this.exchangeRate,
    required this.fee,
    required this.provider,
  });

  final double cryptoAmount;
  final double fiatAmount;
  final String cryptoCurrency;
  final String fiatCurrency;
  final double exchangeRate;
  final double fee;
  final FiatRampProvider provider;
}
