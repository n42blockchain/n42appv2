class AppConfig {
  ///钱包名字最大长度
  static const int walletNameMaxLength = 12;
  ///钱包密码最小长度
  static const int walletPasswordLength = 8;
  static const Map<String,dynamic> apiUrl={
    "walletName":"N42Wallet",
    "walletamazeBrowser":"https://www.n42.ai",//钱包官网
    "walletBuyHost":"https://api-service.walletamaze.com/otc",// 法币模块 host
    "walletBuyHostV2":"https://api.n42.ai/otc/r/onramper/url",// 法币模块 host
    //市场行情
    "marketHost":{
      "main":"https://api.n42.ai/market/v1",
      "test":"http://5.78.28.90:9398/v1",
    },
    //nft host
    "nftHost":{
      "main":'https://api.n42.ai/nft-market',
      "test":"https://5.78.28.90:9397",
    },
    //nft 活动
    "activiteHost":{
      "main":"https://api.n42.ai/activity/v1",
      "test":"https://5.78.28.90:9390/v1",
    },
    //挖矿
    "groupMiningHost":{
      "main":"https://api.n42.ai/activity",
      "test":"https://5.78.28.90:9390",
    },
    //用户中心
    "userInfoHost":{
      "main":'https://api.n42.ai/user',
      "test":'https://5.78.28.90:9393',
    },
    "ipfsHost":"https://api.n42.ai",//"https://api.nft.storage",//ipfs host//https://api.astranet.app/ipfs
    "ipfsAddress":"https://api.astranet.app/ipfs/ipfs/",//".ipfs.nftstorage.link/",//ipfs 接口地址
    //钱包地址
    "tokenViewUri":{
      "main":"https://api.n42.ai/wallet/",
      "test":"https://5.78.28.90:9492/",
    },
    // exchange
    "exchangeHost":{
      "main":"https://api.n42.ai/swap",
      "test":"https://5.78.28.90:9391",
    },
    "newsHostUrl":'https://astranet.world',//新闻//https://walletamaze.com:3088新闻接口：https://astranet.world/newsList?skip=0&limit=5
    //tron
    "tronUri":"https://api.trongrid.io",
    "swap1inch":"https://api.1inch.dev/",
    "imHttpHost":{
      "main":"https://5.161.249.184:10001",//18.170.56.255 -> 5.161.249.184
      "test":"https://5.78.28.90:9394",
    },
    "imWsHost":{
      "main":"ws://5.161.249.184:10002",//18.170.56.255 -> 5.161.249.184
      "test":"ws://5.78.28.90:9395",
    },
    //区块链浏览器 api
    "blockBrowserHost":{
      "main":"https://mainnet.n42.world",
      "test":"https://testnet.n42.world",
    },
    "face":"https://api.n42.ai/face"
  };
  static String getApiUrl_online(String key){
    if(isOnline){
      return apiUrl[key]["main"];
    }
    return apiUrl[key]["test"];
  }
  static String getApiUrl_testHost(String key){
    if(testHost==0){
      return apiUrl[key]["test"];
    }else{
      return apiUrl[key]["main"];
    }
  }

  ///是否打开app的检查更新
  static bool isOpenAppUpdate = true;

  ///true=测试链NFT false=主链NFT
  static bool nftIsTestChain = false;

  ///主网挖矿（true）
  static bool isMainChainMining = true;

  ///是否是线上环境
  static const bool isOnline = true;

  static const int testHost = 0;

}

