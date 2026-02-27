class AppConfig {
  /// 钱包名字最大长度
  static const int walletNameMaxLength = 12;

  /// 钱包密码最小长度
  static const int walletPasswordLength = 8;

  /// 是否打开 App 检查更新
  static bool isOpenAppUpdate = true;

  /// true = 测试链 NFT，false = 主链 NFT
  static bool nftIsTestChain = false;

  /// 主网挖矿（true）
  static bool isMainChainMining = true;

  /// 是否是线上环境
  static const bool isOnline = true;

  static const int testHost = 0;

  static const Map<String, dynamic> apiUrl = {
    "walletName": "N42Wallet",
    "walletamazeBrowser": "https://www.n42.ai", // 钱包官网
    "walletBuyHost": "https://api-service.walletamaze.com/otc", // 法币模块 host
    "walletBuyHostV2": "https://api.n42.ai/otc/r/onramper/url", // 法币模块 host v2
    // 市场行情
    "marketHost": {
      "main": "https://api.n42.ai/market/v1",
      "test": "http://5.78.28.90:9398/v1",
    },
    // NFT host
    "nftHost": {
      "main": "https://api.n42.ai/nft-market",
      "test": "https://5.78.28.90:9397",
    },
    // NFT 活动
    "activiteHost": {
      "main": "https://api.n42.ai/activity/v1",
      "test": "https://5.78.28.90:9390/v1",
    },
    // 挖矿
    "groupMiningHost": {
      "main": "https://api.n42.ai/activity",
      "test": "https://5.78.28.90:9390",
    },
    // 用户中心
    "userInfoHost": {
      "main": "https://api.n42.ai/user",
      "test": "https://5.78.28.90:9393",
    },
    "ipfsHost": "https://api.n42.ai", // IPFS host
    "ipfsAddress": "https://api.astranet.app/ipfs/ipfs/", // IPFS 接口地址
    // 钱包地址
    "tokenViewUri": {
      "main": "https://api.n42.ai/wallet/",
      "test": "https://5.78.28.90:9492/",
    },
    // 交易所
    "exchangeHost": {
      "main": "https://api.n42.ai/swap",
      "test": "https://5.78.28.90:9391",
    },
    "newsHostUrl": "https://astranet.world", // 新闻
    // Tron
    "tronUri": "https://api.trongrid.io",
    "swap1inch": "https://api.1inch.dev/",
    // IM HTTP
    "imHttpHost": {
      "main": "https://5.161.249.184:10001",
      "test": "https://5.78.28.90:9394",
    },
    // IM WebSocket
    "imWsHost": {
      "main": "ws://5.161.249.184:10002",
      "test": "ws://5.78.28.90:9395",
    },
    // 区块链浏览器 API
    "blockBrowserHost": {
      "main": "https://mainnet.n42.world",
      "test": "https://testnet.n42.world",
    },
    "face": "https://api.n42.ai/face",
  };

  /// 根据 [isOnline] 返回主网或测试网地址
  static String getApiUrlOnline(String key) {
    return _envUrl(apiUrl[key] as Map<String, dynamic>, isOnline);
  }

  /// 根据 [testHost] 返回测试网（0）或主网地址
  static String getApiUrlTestHost(String key) {
    return _envUrl(apiUrl[key] as Map<String, dynamic>, testHost != 0);
  }

  /// 从 [endpoints] 中按环境选取 URL。[useMain] 为 true 时返回主网地址。
  static String _envUrl(Map<String, dynamic> endpoints, bool useMain) {
    return useMain ? endpoints["main"] as String : endpoints["test"] as String;
  }
}
