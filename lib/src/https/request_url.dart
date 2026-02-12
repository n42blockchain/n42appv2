import 'package:n42appv2/core/config/api_keys_config.dart';
import 'package:n42appv2/core/config/rpc_config.dart';

class RequestUrl{
  /// 是否已初始化 API keys
  static bool _initialized = false;

  /// 初始化 API keys 和 RPC URLs
  /// 在应用启动时调用一次
  static void initializeApiKeys() {
    if (_initialized) return;
    _initialized = true;

    // 更新 testnet URLs with API keys
    _requestUrlTest1['ETH']!['rpc'] = ApiKeysConfig.getInfuraUrl(network: 'sepolia');
    _requestUrlTest1['S']!['api'] = ApiKeysConfig.getSonicscanApiUrl(isTestnet: true);

    // 更新 testnet BTC-like coins RPC (从环境变量或配置)
    final btcTestnetRpc = RpcConfig.btcTestnetRpc;
    for (final coin in ['BTC', 'LTC', 'DOGE', 'DASH', 'VIA', 'DGB', 'MONA', 'FIRO', 'BCH', 'BTG', 'RVN', 'QTUM', 'XEC']) {
      if (_requestUrlTest1.containsKey(coin)) {
        _requestUrlTest1[coin]!['rpc'] = btcTestnetRpc;
      }
    }

    // 更新 mainnet URLs with API keys
    _requestUrlMain1['BNB']!['api'] = ApiKeysConfig.getBscscanApiUrl();
    _requestUrlMain1['ETH']!['api'] = ApiKeysConfig.getEtherscanApiUrl();
    _requestUrlMain1['ETH']!['rpc'] = ApiKeysConfig.getInfuraUrl(network: 'mainnet');
    _requestUrlMain1['BASE']!['api'] = ApiKeysConfig.getBasescanApiUrl();
    _requestUrlMain1['S']!['api'] = ApiKeysConfig.getSonicscanApiUrl();

    // 更新 mainnet BTC-like coins RPC (从环境变量或配置)
    final btcMainnetRpc = RpcConfig.btcMainnetRpc;
    for (final coin in ['BTC', 'LTC', 'DOGE', 'DASH', 'VIA', 'DGB', 'MONA', 'FIRO', 'BCH', 'BTG', 'RVN', 'QTUM', 'XEC']) {
      if (_requestUrlMain1.containsKey(coin)) {
        _requestUrlMain1[coin]!['rpc'] = btcMainnetRpc;
      }
    }
  }

  String getUrl2(String coinKey,String uriKey,{bool? isTest}){
    // 确保 API keys 已初始化
    initializeApiKeys();

    coinKey=coinKey.toUpperCase();
    isTest ??= false;
    if(isTest){
      return requestUrlTest1[coinKey]?[uriKey]??"";
    }else{
      return requestUrlMain1[coinKey]?[uriKey]??"";
    }

  }

  /// Testnet URLs (使用 getter 以支持动态更新)
  Map<String,dynamic> get requestUrlTest1 => _requestUrlTest1;

  /// Mainnet URLs (使用 getter 以支持动态更新)
  Map<String,dynamic> get requestUrlMain1 => _requestUrlMain1;
}

/// Testnet URL 配置 (私有，通过 RequestUrl.requestUrlTest1 访问)
final Map<String,Map<String,dynamic>> _requestUrlTest1={
    'BNB':{
      'api':'https://api-testnet.bscscan.com/api?',
      'browser':'https://testnet.bscscan.com/',
      'rpc':'https://data-seed-prebsc-1-s1.binance.org:8545',
    },
    'ETH':{
      'api':'https://api-sepolia.etherscan.io/api?',
      'browser':'https://sepolia.etherscan.io/',
      'rpc': 'https://sepolia.infura.io/v3/', // 由 initializeApiKeys() 更新
    },
    'MATIC':{
      'api':'https://api-testnet.polygonscan.com/api?',
      'browser':'https://mumbai.polygonscan.com/',
      'rpc':'https://rpc-mumbai.matic.today'
    },
    'SOL':{
      'api':'https://api-testnet.solscan.io/',
      'browser':'https://solscan.io/',//'browser':'https://solscan.io/?cluster=testnet',
      'rpc':'https://api.testnet.solana.com',
    },
    'TRX':{
      'api':'https://nile.trongrid.io',
      'browser':'https://nile.tronscan.org/#/',
      'rpc':'https://nile.trongrid.io'
    },
    'N':{
      'api':'https://testnet2.n42.world/api?',
      'browser':'https://testnet2.n42.world/',
      'rpc':'https://testrpc.n42.world', // SECURITY: Use HTTPS
    },
    'ETC':{
      'api':'https://blockscout.com/etc/kotti/api?',
      'browser':'https://blockscout.com/etc/kotti/',
      'rpc':'https://www.ethercluster.com/kotti',
    },
    'AVAX':{
      'api':'https://api-testnet.snowtrace.io/api?',
      'browser':'https://testnet.snowtrace.io/',
      'rpc':'https://api.avax-test.network/ext/bc/C/rpc',
    },
    'HT':{
      'api':'https://api-testnet.hecoinfo.com/api?',
      'browser':'https://testnet.hecoinfo.com/',
      'rpc':'https://http-testnet.hecochain.com',
    },
    'XDAI':{
      'api':'https://blockscout.com/xdai/optimism/api?',//https://blockscout.com/xdai/testnet/api?',
      'browser':'https://blockscout.com/xdai/optimism/',//'https://blockscout.com/xdai/testnet',
      'rpc':'https://optimism.gnosischain.com',
    },
    'FTM':{
      'api':'https://api-testnet.ftmscan.com/api?',
      'browser':'https://testnet.ftmscan.com/',
      'rpc':'https://rpc.testnet.fantom.network',
    },
    'CELO':{
      'api':'https://alfajores-blockscout.celo-testnet.org/api?',
      'browser':'https://alfajores-blockscout.celo-testnet.org/',
      'rpc':'https://alfajores-forno.celo-testnet.org',
    },
    'CLO':{
      'api':'https://testnet-explorer.callisto.network/api?',
      'browser':'https://testnet-explorer.callisto.network/',
      'rpc':'https://testnet-rpc.callisto.network/',//https://explorer.callisto.network/api/eth-rpc
    },
    'POA':{
      'api':'https://blockscout.com/poa/sokol/api?',
      'browser':'https://blockscout.com/poa/sokol/',
      'rpc':'https://sokol.poa.network',
    },
    'TOMO':{
      'api':'',
      'browser':'',
      'rpc':''
    },
    'TT':{
      'api':'',
      'browser':'',
      'rpc':''
    },
    'GO':{
      'api':'',
      'browser':'',
      'rpc':'https://testnet-rpc.gochain.io'
    },
    'WAN':{
      'api':'',
      'browser':'',
      'rpc':''
    },
    'CRO':{
      'api':'',
      'browser':'',
      'rpc':''
    },
    'KAVA':{
      'api':'',
      'browser':'',
      'rpc':''
    },
    'KCS':{
      'api':'',
      'browser':'',
      'rpc':''
    },
    'BOBA':{
      'api':'',
      'browser':'',
      'rpc':''
    },
    'EVMOS':{
      'api':'',
      'browser':'',
      'rpc':''
    },
    'MOVR':{
      'api':'',
      'browser':'',
      'rpc':''
    },
    'GLMR':{
      'api':'',
      'browser':'',
      'rpc':''
    },
    'KLAY':{
      'api':'',
      'browser':'',
      'rpc':''
    },
    'MTR':{
      'api':'',
      'browser':'',
      'rpc':''
    },
    'OKT':{
      'api':'',
      'browser':'',
      'rpc':'https://exchaintestrpc.okex.org/'
    },
    'OP':{
      'api':'',
      'browser':'',
      'rpc':''
    },
    'ARB':{
      'api':'',
      'browser':'https://stylus-testnet-explorer.arbitrum.io/',
      'rpc':'https://stylus-testnet.arbitrum.io/rpc/'
    },
    'AURORA':{
      'api':'',
      'browser':'',
      'rpc':''
    },
    'METIS':{
      'api':'',
      'browser':'',
      'rpc':'https://stardust.metis.io/?owner=588'
    },
    'BTC':{
      'api':'https://mempool.space/testnet4/api/',
      'api1':'https://api.blockcypher.com/v1/btc/test3',
      'browser':'https://live.blockcypher.com/btc-testnet/',
      'rpc':'', // 由 initializeApiKeys() 从 RpcConfig 更新
    },
    'LTC':{
      'api':'https://198.200.30.38:18390/v1/',
      'api1':'https://api.blockcypher.com/v1/btc/test3',
      'browser':'https://live.blockcypher.com/btc-testnet/',
      'rpc':'', // 由 initializeApiKeys() 从 RpcConfig 更新
    },
    'DOGE':{
      'api':'https://198.200.30.38:18390/v1/',
      'api1':'https://api.blockcypher.com/v1/btc/test3',
      'browser':'https://live.blockcypher.com/btc-testnet/',
      'rpc':'', // 由 initializeApiKeys() 从 RpcConfig 更新
    },
    'DASH':{
      'api':'https://198.200.30.38:18390/v1/',
      'api1':'https://api.blockcypher.com/v1/btc/test3',
      'browser':'https://live.blockcypher.com/btc-testnet/',
      'rpc':'', // 由 initializeApiKeys() 从 RpcConfig 更新
    },
    'VIA':{
      'api':'https://198.200.30.38:18390/v1/',
      'api1':'https://api.blockcypher.com/v1/btc/test3',
      'browser':'https://live.blockcypher.com/btc-testnet/',
      'rpc':'', // 由 initializeApiKeys() 从 RpcConfig 更新
    },
    'DGB':{
      'api':'https://198.200.30.38:18390/v1/',
      'api1':'https://api.blockcypher.com/v1/btc/test3',
      'browser':'https://live.blockcypher.com/btc-testnet/',
      'rpc':'', // 由 initializeApiKeys() 从 RpcConfig 更新
    },
    'MONA':{
      'api':'https://198.200.30.38:18390/v1/',
      'api1':'https://api.blockcypher.com/v1/btc/test3',
      'browser':'https://live.blockcypher.com/btc-testnet/',
      'rpc':'', // 由 initializeApiKeys() 从 RpcConfig 更新
    },
    'FIRO':{
      'api':'https://198.200.30.38:18390/v1/',
      'api1':'https://api.blockcypher.com/v1/btc/test3',
      'browser':'https://live.blockcypher.com/btc-testnet/',
      'rpc':'', // 由 initializeApiKeys() 从 RpcConfig 更新
    },
    'BCH':{
      'api':'https://198.200.30.38:18390/v1/',
      'api1':'https://api.blockcypher.com/v1/btc/test3',
      'browser':'https://live.blockcypher.com/btc-testnet/',
      'rpc':'', // 由 initializeApiKeys() 从 RpcConfig 更新
    },
    'BTG':{
      'api':'https://198.200.30.38:18390/v1/',
      'api1':'https://api.blockcypher.com/v1/btc/test3',
      'browser':'https://live.blockcypher.com/btc-testnet/',
      'rpc':'', // 由 initializeApiKeys() 从 RpcConfig 更新
    },
    'RVN':{
      'api':'https://198.200.30.38:18390/v1/',
      'api1':'https://api.blockcypher.com/v1/btc/test3',
      'browser':'https://live.blockcypher.com/btc-testnet/',
      'rpc':'', // 由 initializeApiKeys() 从 RpcConfig 更新
    },
    'QTUM':{
      'api':'https://198.200.30.38:18390/v1/',
      'api1':'https://api.blockcypher.com/v1/btc/test3',
      'browser':'https://live.blockcypher.com/btc-testnet/',
      'rpc':'', // 由 initializeApiKeys() 从 RpcConfig 更新
    },
    'XEC':{
      'api':'https://198.200.30.38:18390/v1/',
      'api1':'https://api.blockcypher.com/v1/btc/test3',
      'browser':'https://live.blockcypher.com/btc-testnet/',
      'rpc':'', // 由 initializeApiKeys() 从 RpcConfig 更新
    },
    'ALGO':{
      'api':'https://node.testnet.algoexplorerapi.io/',
      'browser':'https://testnet.algoexplorer.io/',
      'rpc':''
    },
    'XTZ':{
      'api':'https://api.nairobi.tzstats.com/',
      'browser':'https://nairobi.tzstats.com/',
      'rpc':'https://rpc.nairobi.tzstats.com/'
    },
    'XRP':{
      'api':'',
      'browser':'https://testnet.xrpl.org/',
      'rpc':'https://s.altnet.rippletest.net:51234/'
    },
    'ATOM':{
      'api':'https://cosmos-lcd.quickapi.com/',//'https://api.cosmos.network/',
      'browser':'https://atomscan.com/',
      'rpc':''
    },
    'ZETA':{
      'api':'',
      'browser':'https://explorer.zetachain.com/',
      'rpc':'https://api.athens2.zetachain.com/evm'
    },
    'BASE':{
      'api':'',
      'browser':'',
      'rpc':''
    },
    'FIL':{
      'api':'',
      'browser':'https://calibration.filfox.info/',
      'rpc':'https://api.calibration.node.glif.io/'
    },
    'DOT':{
      'api':'https://westend.api.subscan.io/',
      'browser':'https://westend.subscan.io/',
      'rpc':'https://westend-rpc.polkadot.io'
    },
    'ACA':{
      'api':'https://acala-testnet.api.subscan.io/',
      'browser':'https://acala-testnet.subscan.io/',
      'rpc':'https://acala-testnet.api.subscan.io'
    },
    'KSM':{
      'api':'https://westend.api.subscan.io/',
      'browser':'https://westend.subscan.io/',
      'rpc':'https://westend-rpc.polkadot.io'
    },
    'APT':{
      'api':"",
      'browser':"https://explorer.aptoslabs.com/",
      'rpc':"https://fullnode.testnet.aptoslabs.com/v1/"
    },
    'SUI':{
      'api':"",
      'browser':"https://suiscan.xyz/testnet/",
      'rpc':"https://fullnode.testnet.sui.io:443"
    },
    'TON':{
      'api':"https://testnet.explorer.tonapi.io/",
      'browser':"https://testnet.tonscan.org/",
      'rpc':"https://testnet.toncenter.com/api/v2/"
    },
    'S':{
      'api':"https://api-testnet.sonicscan.org/api?", // 由 initializeApiKeys() 更新
      'browser':"https://testnet.sonicscan.org/",
      'rpc':"https://rpc.blaze.soniclabs.com/"
    },
    'BB':{
      'api':"",
      'browser':"https://testnet.bbscan.io",
      'rpc':"https://fullnode-testnet.bouncebitapi.com"
    },
    'XLM':{
      'api':'https://horizon-testnet.stellar.org/',
      'browser':'https://stellar.expert/explorer/testnet/',
      'rpc':'https://horizon-testnet.stellar.org'
    },
    'VET':{
      'api':'https://testnet.veblocks.net/',
      'browser':'https://explore-testnet.vechain.org/',
      'rpc':'https://testnet.veblocks.net'
    },
    'ONE':{
      'api':'https://api.s0.b.hmny.io/',
      'browser':'https://explorer.pops.one/',
      'rpc':'https://api.s0.b.hmny.io'
    },
    'IOTX':{
      'api':'https://api.testnet.iotex.one/',
      'browser':'https://testnet.iotexscan.io/',
      'rpc':'https://babel-api.testnet.iotex.io'
    },
    'NEAR':{
      'api':'https://rpc.testnet.near.org/',
      'browser':'https://explorer.testnet.near.org/',
      'rpc':'https://rpc.testnet.near.org'
    },
    'ZIL':{
      'api':'https://dev-api.zilliqa.com/',
      'browser':'https://viewblock.io/zilliqa/',
      'rpc':'https://dev-api.zilliqa.com'
    },
    'THETA':{
      'api':'https://testnet-explorer.thetatoken.org:8443/api/',
      'browser':'https://testnet-explorer.thetatoken.org/',
      'rpc':'https://eth-rpc-api-testnet.thetatoken.org/rpc'
    },
    'ADA':{
      'api':'https://cardano-preprod.blockfrost.io/api/v0/',
      'browser':'https://preprod.cardanoscan.io/',
      'rpc':'https://cardano-preprod.blockfrost.io/api/v0'
    },
    'EGLD':{
      'api':'https://devnet-api.multiversx.com/',
      'browser':'https://devnet-explorer.multiversx.com/',
      'rpc':'https://devnet-gateway.multiversx.com'
    }
  };

/// Mainnet URL 配置 (私有，通过 RequestUrl.requestUrlMain1 访问)
final Map<String,Map<String,dynamic>> _requestUrlMain1={
    'BNB':{
      'api':'https://api.bscscan.com/api?', // 由 initializeApiKeys() 更新
      'browser':'https://bscscan.com/',
      'rpc':'https://bsc-dataseed1.binance.org/',
    },
    'ETH':{
      'api':'https://api.etherscan.io/api?', // 由 initializeApiKeys() 更新
      'browser':'https://etherscan.io/',
      'rpc':'https://mainnet.infura.io/v3/', // 由 initializeApiKeys() 更新
    },
    'MATIC':{
      'api':'https://api.polygonscan.com/api?',
      'browser':'https://polygonscan.com/',
      'rpc':'https://polygon-rpc.com/'
    },
    'SOL':{
      'api':'',//'https://pro-api.solscan.io /v1.0/',//待测试
      'browser':'https://solscan.io/',
      'rpc':'https://api.mainnet-beta.solana.com',
    },
    'TRX':{
      'api':'https://api.trongrid.io',//'https://apilist.tronscan.org/api/',//'https://api.trongrid.io//',//
      'browser':'https://tronscan.org/#/',
      'rpc':'https://api.trongrid.io'
    },
    'N':{
      'api':'https://mainnet.n42.world/api?',
      'browser':'https://mainnet.n42.world/',
      'rpc':'https://rpc.n42.world', // SECURITY: Use HTTPS
    },
    'ETC':{
      'api':'https://blockscout.com/etc/mainnet/api?',
      'browser':'https://blockscout.com/etc/mainnet/',
      'rpc':'https://www.ethercluster.com/etc/',
    },
    'AVAX':{
      'api':"https://api.snowtrace.io/api?",//'https://api.snowtrace.io/api?apikey=ZUBXBXGF3ZEVUSCPKI2A63Z5V4ZBR7ABFW&',//
      'browser':'https://snowtrace.io/',//'https://subnets.avax.network/',
      'rpc':'https://api.avax.network/ext/bc/C/rpc/',
    },
    'HT':{
      'api':"https://api.hecoinfo.com/api?",//'https://api.hecoinfo.com/api?apikey=ZUBXBXGF3ZEVUSCPKI2A63Z5V4ZBR7ABFW&',//
      'browser':'https://www.hecoinfo.com/',
      'rpc':'https://http-mainnet.huobichain.com/',
    },
    'XDAI':{
      'api':"https://blockscout.com/xdai/mainnet/api?",//'https://blockscout.com/xdai/mainnet/api?apikey=ZUBXBXGF3ZEVUSCPKI2A63Z5V4ZBR7ABFW&',//
      'browser':'https://blockscout.com/xdai/mainnet/',
      'rpc':'https://xdai-rpc.gateway.pokt.network/',
    },
    'FTM':{
      'api':"https://api.ftmscan.com/api?",//'https://api.ftmscan.com/api?apikey=ZUBXBXGF3ZEVUSCPKI2A63Z5V4ZBR7ABFW&',//
      'browser':'https://ftmscan.com/',
      'rpc':'https://rpc.ankr.com/fantom/',
    },
    'CELO':{
      'api':"https://explorer.celo.org/api?",//'https://explorer.celo.org/api?apikey=ZUBXBXGF3ZEVUSCPKI2A63Z5V4ZBR7ABFW&',//
      'browser':'https://explorer.celo.org/',
      'rpc':'https://forno.celo.org/',
    },
    'CLO':{
      'api':'https://explorer.callisto.network/api?',//"https://explorer.callisto.network/api?"
      'browser':'https://explorer.callisto.network/',
      'rpc':'https://clo-geth.0xinfra.com',//https://explorer.callisto.network/api/eth-rpc
    },
    'POA':{
      'api':'https://blockscout.com/poa/core/api?',//"https://blockscout.com/poa/core/api?"
      'browser':'https://blockscout.com/poa/core/',
      'rpc':'https://core.poa.network',
    },
    'TOMO':{
      'api':'',
      'browser':'https://tomoscan.io/',
      'rpc':'https://rpc.tomochain.com'
    },
    'TT':{
      'api':'https://explorer-mainnet.thundercore.com/api?', // SECURITY: Upgraded to HTTPS
      'browser':'https://explorer-mainnet.thundercore.com/',
      'rpc':''
    },
    'GO':{
      'api':'',
      'browser':'https://explorer.gochain.io/',
      'rpc':'https://rpc.gochain.io'
    },
    'WAN':{
      'api':'',
      'browser':'https://wanscan.org',
      'rpc':''
    },
    'CRO':{
      'api':'',
      'browser':'https://cronoscan.com/',
      'rpc':''
    },
    'KAVA':{
      'api':'',
      'browser':'https://www.mintscan.io/kava/',
      'rpc':''
    },
    'KCS':{
      'api':'https://explorer.kcc.io/api?',
      'browser':'https://explorer.kcc.io/',
      'rpc':''
    },
    'BOBA':{
      'api':'',
      'browser':'https://bobascan.com/',
      'rpc':'https://mainnet.boba.network'
    },
    'EVMOS':{
      'api':'',
      'browser':'https://www.mintscan.io/evmos/',
      'rpc':''
    },
    'MOVR':{
      'api':'',
      'browser':'https://moonriver.subscan.io/',
      'rpc':''
    },
    'GLMR':{
      'api':'',
      'browser':'https://moonbase.subscan.io/',
      'rpc':''
    },
    'KLAY':{
      'api':'',
      'browser':'https://scope.klaytn.com/',
      'rpc':''
    },
    'MTR':{
      'api':'',
      'browser':'https://scan.meter.io/', // SECURITY: Upgraded to HTTPS
      'rpc':'https://rpc.meter.io'
    },
    'OKT':{
      'api':'',//'https://api.astranet.app/wallet/v1/vipapi/',
      'browser':'https://www.oklink.com/',
      'rpc':'https://exchainrpc.okex.org/'
    },
    'OP':{
      'api':'',
      'browser':'https://optimistic.etherscan.io/',
      'rpc':'https://mainnet.optimism.io'
    },
    'ARB':{
      'api':'',
      'browser':'https://stylus-testnet-explorer.arbitrum.io/',
      'rpc':'https://stylus-testnet.arbitrum.io/rpc/'
    },
    'AURORA':{
      'api':'',
      'browser':'https://aurorascan.dev/',
      'rpc':''
    },
    'METIS':{
      'api':'',
      'browser':'https://metis.tokenview.io/',
      'rpc':'https://andromeda.metis.io/?owner=1088'
    },
    'BTC':{
      'api':'https://blockstream.info/api/',//'https://api.blockcypher.com/v1/btc/main/',
      'browser':'https://www.blockchain.com/btc/',
      'rpc':'', // 由 initializeApiKeys() 从 RpcConfig 更新
    },
    'LTC':{
      'api':'https://api.blockcypher.com/v1/ltc/main',
      'browser':'https://live.blockcypher.com/ltc/',
      'rpc':'', // 由 initializeApiKeys() 从 RpcConfig 更新
    },
    'DOGE':{
      'api':'https://api.blockcypher.com/v1/doge/main',
      'browser':'https://dogechain.info/',
      'rpc':'', // 由 initializeApiKeys() 从 RpcConfig 更新
    },
    'DASH':{
      'api':'https://api.blockcypher.com/v1/dash/main',
      'browser':'https://chainz.cryptoid.info/dash/',
      'rpc':'', // 由 initializeApiKeys() 从 RpcConfig 更新
    },
    'VIA':{
      'api':'',//'https://api.blockcypher.com/v1/btc/main',
      'browser':'https://explorer.viacoin.org/',
      'rpc':'', // 由 initializeApiKeys() 从 RpcConfig 更新
    },
    'DGB':{
      'api':'',//'https://api.blockcypher.com/v1/btc/main',
      'browser':'https://digiexplorer.info/', // SECURITY: Upgraded to HTTPS
      'rpc':'', // 由 initializeApiKeys() 从 RpcConfig 更新
    },
    'MONA':{
      'api':'',//'https://api.blockcypher.com/v1/btc/main',
      'browser':'https://blockbook.electrum-mona.org/',
      'rpc':'', // 由 initializeApiKeys() 从 RpcConfig 更新
    },
    'FIRO':{
      'api':'',//'https://api.blockcypher.com/v1/btc/main',
      'browser':'https://explorer.firo.org/',
      'rpc':'', // 由 initializeApiKeys() 从 RpcConfig 更新
    },
    'BCH':{
      'api':'',//'https://api.blockcypher.com/v1/btc/main',
      'browser':'https://www.blockchain.com/bch/',
      'rpc':'', // 由 initializeApiKeys() 从 RpcConfig 更新
    },
    'BTG':{
      'api':'',//'https://api.blockcypher.com/v1/btc/main',
      'browser':'https://explorer.bitcoingold.org/insight/',
      'rpc':'', // 由 initializeApiKeys() 从 RpcConfig 更新
    },
    'RVN':{
      'api':'',//'https://api.blockcypher.com/v1/btc/main',
      'browser':'https://ravencoin.network/',
      'rpc':'', // 由 initializeApiKeys() 从 RpcConfig 更新
    },
    'QTUM':{
      'api':'',//'https://api.blockcypher.com/v1/btc/main',
      'browser':'https://qtum.info/',
      'rpc':'', // 由 initializeApiKeys() 从 RpcConfig 更新
    },
    'XEC':{
      'api':'',//'https://api.blockcypher.com/v1/btc/main',
      'browser':'https://explorer.bitcoinabc.org/',
      'rpc':'', // 由 initializeApiKeys() 从 RpcConfig 更新
    },
    'ALGO':{
      'api':'https://node.algoexplorerapi.io/',
      'browser':'https://algoexplorer.io/',
      'rpc':''
    },
    'XTZ':{
      'api':'https://api.tzstats.com/',
      'browser':'https://tzstats.com/',
      'rpc':'https://rpc.tzstats.com/'
    },
    'XRP':{
      'api':'',
      'browser':'https://livenet.xrpl.org/',
      'rpc':'https://s2.ripple.com:51234/'
    },
    'ATOM':{
      'api':'https://lcd-cosmoshub.keplr.app/',//'https://cosmos-lcd.quickapi.com/',
      'browser':'https://atomscan.com/',
      'rpc':''
    },
    'ZETA':{
      'api':'',
      'browser':'',
      'rpc':''
    },
    'BASE':{
      'api':'https://api.basescan.org/api?', // 由 initializeApiKeys() 更新
      'browser':'https://basescan.org/',
      'rpc':'https://mainnet.base.org'
    },
    'FIL':{
      'api':'https://filfox.info/api/v1/',
      'browser':'https://filfox.info/',
      'rpc':'https://api.node.glif.io/'
    },
    'DOT':{
      'api':'https://polkadot.api.subscan.io/',
      'browser':'https://polkadot.subscan.io/',
      'rpc':'https://rpc.polkadot.io'
    },
    'ACA':{
      'api':'https://acala.api.subscan.io/',
      'browser':'https://acala.subscan.io/',
      'rpc':'https://acala-rpc.dwellir.com'
    },
    'KSM':{
      'api':'https://kusama.api.subscan.io/',
      'browser':'https://kusama.subscan.io/',
      'rpc':'https://kusama-rpc.polkadot.io/'
    },
    'APT':{
      'api':"",
      'browser':"https://explorer.aptoslabs.com/",
      'rpc':"https://fullnode.mainnet.aptoslabs.com/v1/"
    },
    'SUI':{
      'api':"",
      'browser':"https://suiscan.xyz/mainnet/",
      'rpc':"https://fullnode.mainnet.sui.io:443"
    },
    'TON':{
      'api':"https://explorer.tonapi.io/",
      'browser':"https://tonscan.org/",
      'rpc':"https://toncenter.com/api/v2/"
    },
    'S':{
      'api':"https://api.sonicscan.org/api?", // 由 initializeApiKeys() 更新
      'browser':"https://sonicscan.org/",
      'rpc':"https://rpc.soniclabs.com/"
    },
    'BB':{
      'api':"",
      'browser':"https://bbscan.io/",
      'rpc':"https://fullnode-mainnet.bouncebitapi.com"
    },
    'XLM':{
      'api':'https://horizon.stellar.org/',
      'browser':'https://stellar.expert/explorer/public/',
      'rpc':'https://horizon.stellar.org'
    },
    'VET':{
      'api':'https://mainnet.veblocks.net/',
      'browser':'https://explore.vechain.org/',
      'rpc':'https://mainnet.veblocks.net'
    },
    'ONE':{
      'api':'https://api.s0.t.hmny.io/',
      'browser':'https://explorer.harmony.one/',
      'rpc':'https://api.harmony.one'
    },
    'IOTX':{
      'api':'https://api.iotex.one/',
      'browser':'https://iotexscan.io/',
      'rpc':'https://babel-api.mainnet.iotex.io'
    },
    'NEAR':{
      'api':'https://rpc.mainnet.near.org/',
      'browser':'https://explorer.near.org/',
      'rpc':'https://rpc.mainnet.near.org'
    },
    'ZIL':{
      'api':'https://api.zilliqa.com/',
      'browser':'https://viewblock.io/zilliqa/',
      'rpc':'https://api.zilliqa.com'
    },
    'THETA':{
      'api':'https://explorer.thetatoken.org:8443/api/',
      'browser':'https://explorer.thetatoken.org/',
      'rpc':'https://eth-rpc-api.thetatoken.org/rpc'
    },
    'ADA':{
      'api':'https://cardano-mainnet.blockfrost.io/api/v0/',
      'browser':'https://cardanoscan.io/',
      'rpc':'https://cardano-mainnet.blockfrost.io/api/v0'
    },
    'EGLD':{
      'api':'https://api.multiversx.com/',
      'browser':'https://explorer.multiversx.com/',
      'rpc':'https://gateway.multiversx.com'
    }
  };
