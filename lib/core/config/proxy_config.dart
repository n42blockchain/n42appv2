/// API 代理配置
///
/// 所有第三方 API 请求通过服务端代理转发，避免在客户端暴露 API Key。
/// 代理服务端地址通过 --dart-define=PROXY_BASE_URL 配置。
class ProxyConfig {
  ProxyConfig._();

  /// 代理服务基础 URL
  static const String baseUrl = String.fromEnvironment(
    'PROXY_BASE_URL',
    defaultValue: 'https://api.n42.ai/proxy',
  );

  /// 代理服务访问令牌。
  ///
  /// 用于访问受保护的 N42 proxy 路由，不是第三方服务自身的 API key。
  static const String authToken = String.fromEnvironment(
    'PROXY_AUTH_TOKEN',
    defaultValue: '',
  );

  static String get _normalizedBaseUrl => baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl;

  // ==================== MoonPay ====================
  static String get moonpaySign => '$_normalizedBaseUrl/v1/moonpay/sign';

  // ==================== Alchemy ====================
  static String alchemyChain(String chain) =>
      '$_normalizedBaseUrl/v1/alchemy/$chain';

  // ==================== RPC ====================
  static String get ethRpc => '$_normalizedBaseUrl/v1/rpc/eth';
  static String get tonRpc => '$_normalizedBaseUrl/v1/rpc/ton';
  static String trxPath(String path, {bool isTest = false}) =>
      '$_normalizedBaseUrl/v1/trx/${isTest ? 'test' : 'main'}/${_normalizePath(path)}';

  // ==================== Explorer ====================
  static String explorerTxlist(String chain) =>
      '$_normalizedBaseUrl/v1/explorer/$chain/txlist';
  static String explorerTokentx(String chain) =>
      '$_normalizedBaseUrl/v1/explorer/$chain/tokentx';
  static String get explorerSonic => '$_normalizedBaseUrl/v1/explorer/sonic';
  static String subscan(String chain) => '$_normalizedBaseUrl/v1/subscan/$chain';

  // ==================== Market ====================
  static String get marketBase => '$_normalizedBaseUrl/v1/market';
  static String get marketOhlcv => '$_normalizedBaseUrl/v1/market/ohlcv';
  static String get marketChart => '$_normalizedBaseUrl/v1/market/chart';
  static String get marketSimplePrice =>
      '$_normalizedBaseUrl/v1/market/simple_price';
  static String get marketTrending => '$_normalizedBaseUrl/v1/market/trending';
  static String get marketSearch => '$_normalizedBaseUrl/v1/market/search';

  // ==================== Bundler ====================
  static String bundler(String chainId) =>
      '$_normalizedBaseUrl/v1/bundler/$chainId';

  // ==================== AI ====================
  static String get aiChat => '$_normalizedBaseUrl/v1/ai/chat';

  // ==================== Translate ====================
  static String get translate => '$_normalizedBaseUrl/v1/translate';

  // ==================== Giphy ====================
  static String get giphyBase => '$_normalizedBaseUrl/v1/giphy';
  static String get giphySearch => '$_normalizedBaseUrl/v1/giphy/search';
  static String get giphyTrending => '$_normalizedBaseUrl/v1/giphy/trending';

  // ==================== DeBank ====================
  static String get debankBase => '$_normalizedBaseUrl/v1/debank';
  static String get debankBalance =>
      '$_normalizedBaseUrl/v1/debank/total_balance';
  static String get debankTokenList =>
      '$_normalizedBaseUrl/v1/debank/token_list';
  static String get debankUsedChainList =>
      '$_normalizedBaseUrl/v1/debank/used_chain_list';

  // ==================== Speech ====================
  static String get speechGoogle => '$_normalizedBaseUrl/v1/speech/google';
  static String get speechAzure => '$_normalizedBaseUrl/v1/speech/azure';

  // ==================== TokenView Enhanced ====================
  static String get tokenviewGasNextBlock =>
      '$_normalizedBaseUrl/v1/tokenview/gas/nextblock';
  static String get tokenviewPendingStat =>
      '$_normalizedBaseUrl/v1/tokenview/pendingstat';
  static String get tokenviewPendingTx =>
      '$_normalizedBaseUrl/v1/tokenview/pending/tx';
  static String get tokenviewContractCreator =>
      '$_normalizedBaseUrl/v1/tokenview/contract/creator';

  static bool isProxyUrl(String url) {
    final normalizedUrl = url.endsWith('/')
        ? url.substring(0, url.length - 1)
        : url;
    return normalizedUrl.startsWith(_normalizedBaseUrl);
  }

  static Map<String, String> mergeAuthHeaders(
    String url, [
    Map<String, String>? headers,
    String? tokenOverride,
  ]) {
    final merged = <String, String>{...?headers};
    final hasAuthorizationHeader = merged.keys.any(
      (key) => key.toLowerCase() == 'authorization',
    );
    final effectiveToken = tokenOverride ?? authToken;
    if (!isProxyUrl(url) || effectiveToken.isEmpty || hasAuthorizationHeader) {
      return merged;
    }
    merged['Authorization'] = 'Bearer $effectiveToken';
    return merged;
  }

  static String _normalizePath(String path) {
    return path.startsWith('/') ? path.substring(1) : path;
  }
}
