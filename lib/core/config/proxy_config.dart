/// API proxy configuration
///
/// Services are routed through proxy ONLY when it makes sense:
/// - Shared/cacheable data (market prices, gas fees) → proxy with server cache
/// - API key protection (explorer, bundler, MoonPay HMAC) → proxy
/// - Per-user streaming/heavy content (AI chat, speech, giphy) → direct client
///
/// Proxy URL configured via --dart-define=PROXY_BASE_URL
class ProxyConfig {
  ProxyConfig._();

  static const String baseUrl = String.fromEnvironment(
    'PROXY_BASE_URL',
    defaultValue: 'https://api.n42.ai/proxy',
  );

  static const String authToken = String.fromEnvironment(
    'PROXY_AUTH_TOKEN',
    defaultValue: 'dd0f3335acaf177bd5bc75b4661b53b87af81216fd198d1503bf5649401e5387',
  );

  static String get _normalizedBaseUrl => baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl;

  // ==================== Market (shared, cacheable) ====================
  static String get marketBase => '$_normalizedBaseUrl/v1/market';
  static String get marketOhlcv => '$_normalizedBaseUrl/v1/market/ohlcv';
  static String get marketChart => '$_normalizedBaseUrl/v1/market/chart';
  static String get marketSimplePrice =>
      '$_normalizedBaseUrl/v1/market/simple_price';
  static String get marketTrending => '$_normalizedBaseUrl/v1/market/trending';
  static String get marketSearch => '$_normalizedBaseUrl/v1/market/search';

  // ==================== TokenView (shared gas data, cacheable) ====================
  static String get tokenviewGasNextBlock =>
      '$_normalizedBaseUrl/v1/tokenview/gas/nextblock';
  static String get tokenviewPendingStat =>
      '$_normalizedBaseUrl/v1/tokenview/pendingstat';
  static String get tokenviewPendingTx =>
      '$_normalizedBaseUrl/v1/tokenview/pending/tx';
  static String get tokenviewContractCreator =>
      '$_normalizedBaseUrl/v1/tokenview/contract/creator';

  // ==================== MoonPay (HMAC signing, must be server-side) ====================
  static String get moonpaySign => '$_normalizedBaseUrl/v1/moonpay/sign';

  // ==================== Bundler (API key protection, low volume) ====================
  static String bundler(String chainId) =>
      '$_normalizedBaseUrl/v1/bundler/$chainId';

  // ==================== Explorer (API key protection, per-address) ====================
  static String explorerTxlist(String chain) =>
      '$_normalizedBaseUrl/v1/explorer/$chain/txlist';
  static String explorerTokentx(String chain) =>
      '$_normalizedBaseUrl/v1/explorer/$chain/tokentx';
  static String get explorerSonic => '$_normalizedBaseUrl/v1/explorer/sonic';

  // ==================== TRX (API key protection) ====================
  static String trxPath(String path, {bool isTest = false}) =>
      '$_normalizedBaseUrl/v1/trx/${isTest ? 'test' : 'main'}/${_normalizePath(path)}';

  // ==================== NFT (API key protection, low volume) ====================
  static String get nftBase => '$_normalizedBaseUrl/v1/nft';

  // ==================== RPC (read ops cacheable, writes need direct) ====================
  static String get ethRpc => '$_normalizedBaseUrl/v1/rpc/eth';
  static String get tonRpc => '$_normalizedBaseUrl/v1/rpc/ton';

  // ==================== Alchemy ====================
  static String alchemyChain(String chain) =>
      '$_normalizedBaseUrl/v1/alchemy/$chain';

  // ============================================================
  // NOT proxied — direct client access is better for these:
  //
  // AI Chat:    per-user streaming, high bandwidth, proxy = bottleneck
  // Translate:  per-message, low latency needed, free API quota sufficient
  // Giphy:      per-user search, image bandwidth heavy, free API key
  // Speech:     audio stream, very high bandwidth, proxy can't help
  // DeBank:     per-address, large responses, free tier adequate
  // Subscan:    per-address, free API available
  // ============================================================

  static bool isProxyUrl(String url) {
    final uri = Uri.tryParse(url);
    final baseUri = Uri.tryParse(_normalizedBaseUrl);
    if (uri == null || baseUri == null) return false;
    return uri.host == baseUri.host &&
        uri.scheme == baseUri.scheme &&
        uri.path.startsWith(baseUri.path);
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
