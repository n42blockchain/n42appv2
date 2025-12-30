//walletList中使用
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:decimal/decimal.dart';
import 'package:web3dart/web3dart.dart';

Map<String,dynamic> chainUrlMap={
  CoinType.BTC.name:<String,dynamic>{
    "showList":true,//主链币是否显示在主页列表中
    //"sort":1,//列表排序依据
    "isTest":false,//是否时正式链
    "supportTest":false,
    "addrType":"segwit",//地址类型
    "pathIndex":0,//path具体的账号节点
    "pathList":[0],//path数量
    "baseInfo":<String,dynamic>{
      "blockchainType": BlockchainType.Bitcoin.name,
      "coinType": CoinType.BTC.name,
      "icon": "https://api.n42.ai/market/v1/r/coinImage/Bitcoin.png",
      "name": "Bitcoin",
      "miniName": "BTC",
      "unit":"BTC",
      "chainId": 0,
      "decimals": 8,
      "balance":"0",
      "balance_test":"0",
      "coinPrice":0.0,
      "percentage":0.0,
      "isContract": false,
      "mKey": "BTC",
      "path": {
        "legacy":"m/44'/0'/0'/0/0",
        "segwit":"m/84'/1'/0'/0/0",
        "taproot":"m/86'/0'/0'/0/0",
      },
      "service": "",
      "service_test": "",
      "chainId_test": 0,
      "contract": "",
      "contract_test": "",
      "canEdit": false,
      "rules": "",
    },
    "mainnetWS":"",
    "mainnetRPC":"",
    "mainnetChainID":0,
    "testnetWS":"",
    "testnetRPC":"",
    "testnetChainID":0,
    "testnetIndex":0,//当前选择的测试网络 索引值
    "testnets":[
      {
        "testnetWS":"",
        "testnetRPC":"",
        "testnetChainID":0,
        "testnetContract":<String,dynamic>{}
      },
    ],
    "mainnets":<String,dynamic>{},
    "mainnetContract":{
    },
    "testnetContract":{},
  },
  CoinType.ETH.name:<String,dynamic>{
    "showList":true,//主链币是否显示在主页列表中
    //"sort":2,//列表排序依据
    "isTest":false,//是否时正式链
    "supportTest":true,//是否可以使用测试网络
    "addrType":"legacy",//地址类型
    "pathIndex":0,//path具体的账号节点
    "pathList":[0],//path数量
    "baseInfo":<String,dynamic>{
      "mKey": "ETH",
      "blockchainType": BlockchainType.Ethereum.name,//链类型 字符串类型 Ethereum、Bitcoin、Solana、Tron等
      "coinType": CoinType.ETH.name,//是那种币，ETH、BNB、等
      "icon": "https://api.n42.ai/market/v1/r/coinImage/Ethereum.png",//图标地址
      "name": "Ethereum",//链全名
      "miniName": "ETH",//链 的symbol，
      "unit":"ETH",
      "decimals": 18,//小数位数
      "balance":"0",
      "balance_test":"0",
      "coinPrice":0.0,
      "percentage":0.0,
      "isContract": false,
      "path": {
        "legacy":"m/44'/60'/0'/0/0",//链path，
      },
      "service": "https://mainnet.infura.io/v3/b6bd1324a1b34545b1fdda886dd494f9",//主网rpc地址
      "service_test": "https://eth-sepolia.public.blastapi.io",//测试网rpc地址，如果没有传""
      "chainId": 1,//主网链id
      "chainId_test": 11155111,//测试网链id
      "contract": "",
      "contract_test": "",
      "canEdit": false,//是否可以修改
      "rules": "ERC20",//代币的类型 eth 是ERC20，BNB是BEP20，TRX 是TRC20
    },
    //"mainnetWS":"wss://mainnet.infura.io/ws/v3/b6bd1324a1b34545b1fdda886dd494f9",
    //"mainnetRPC":"https://mainnet.infura.io/v3/b6bd1324a1b34545b1fdda886dd494f9",
    "mainnetChainID":1,
    //"testnetWS":"https://ropsten.infura.io/v3/b6bd1324a1b34545b1fdda886dd494f9",
    //"testnetRPC":"https://ropsten.infura.io/v3/b6bd1324a1b34545b1fdda886dd494f9",
    "testnetChainID":3,
    "testnetIndex":0,//当前选择的测试网络 索引值
    "testnets":[
      {
        "testnetWS":"https://eth-sepolia.public.blastapi.io",
        "testnetRPC":"https://eth-sepolia.public.blastapi.io",
        "testnetChainID":11155111,
        "testnetContract":<String,dynamic>{
          "0X6C30A50430CC615C4659DF2DBE3E42036583BE7E":<String,dynamic>{
            "mKey": "0X6C30A50430CC615C4659DF2DBE3E42036583BE7E",
            "blockchainType": BlockchainType.Ethereum.name,
            "coinType": CoinType.ETH.name,
            "icon": "https://api.astranet.app/market/v1/r/coinImage/vbtc.png",
            "name": "vBTC",
            "miniName": "vBTC",
            "unit":"vBTC",
            "decimals": 8,//小数位数
            "balance":"0",
            "balance_test":"0",
            "coinPrice":0.0,
            "percentage":0.0,
            "isContract": true,
            "path": {
              "legacy":"m/44'/60'/0'/0/0",
            },
            "service": "http://18.170.108.78:20012",
            "service_test": "https://eth-sepolia.public.blastapi.io",
            "chainId": 1,//100100100,
            "chainId_test": 11155111,//100100100,
            "contract": "0x6c30A50430cC615C4659DF2dBe3E42036583bE7E",
            "contract_test": "0x6c30A50430cC615C4659DF2dBe3E42036583bE7E",
            "canEdit": false,
            "rules": "ERC20",
            "customer":false,
          }
        }
      },
    ],
    "mainnets":<String,dynamic>{
    },
  },
  CoinType.N.name:<String,dynamic>{
    "showList":true,//主链币是否显示在主页列表中
    //"sort":4,//列表排序依据
    "isTest":true,//是否时正式链
    "supportTest":true,
    "addrType":"legacy",//地址类型
    "pathIndex":0,//path具体的账号节点
    "pathList":[0],//path数量
    "baseInfo":<String,dynamic>{
      "mKey": "N",
      "blockchainType": BlockchainType.Ethereum.name,
      "coinType": CoinType.N.name,
      "icon": "https://n42.ai/static/n42.png",
      "name": "N42",
      "miniName": "N",
      "unit":"N",
      "decimals": 18,
      "balance":"0",
      "balance_test":"0",
      "coinPrice":0.0,
      "percentage":0.0,
      "isContract": false,
      "path": {
        "legacy":"m/44'/60'/0'/0/0",
      },
      "service": "https://rpc.n42.world",
      "service_test": "http://5.161.252.59:8545",//"https://testrpc.n42.world",
      "chainId": 94,//100100100,
      "chainId_test": 1142,//1143
      "contract": "",
      "contract_test": "",
      "canEdit": false,
      "rules": "ERC20",
    },
    //"mainnetWS":"ws://174.129.114.74:8546",
    //"mainnetRPC":"http://174.129.114.74:8545",//"http://192.168.0.190:20012",//
    "mainnetChainID":94,//100100100,
    //"testnetWS":"ws://174.129.114.74:8546",
    //"testnetRPC":"http://174.129.114.74:8545",//"http://192.168.0.190:20012",//
    "testnetChainID":1142,
    "testnetIndex":0,//当前选择的测试网络 索引值
    "testnets":[
      {
        "testnetWS":"ws://54.175.247.94:20012",
        "testnetRPC":"http://5.161.252.59:8545",//"http://54.243.83.152:20012",
        "testnetChainID":1142,//100100100,//
        "testnetContract":<String,dynamic>{
        }
      },
    ],
    "mainnets":<String,dynamic>{
      /*"0XE062FD6F7B483A648AB9F84AD2BA76F9DEB0A550":<String,dynamic>{
        "mKey": "0XE062FD6F7B483A648AB9F84AD2BA76F9DEB0A550",
        "blockchainType": BlockchainType.Ethereum.name,
        "coinType": CoinType.N.name,
        "icon": "https://api.astranet.app/market/v1/r/coinImage/LoveCoin.png",
        "name": "LoveCoin",
        "miniName": "LOVE",
        "unit":"love",
        "decimals": 0,//小数位数
        "balance":"0",
        "balance_test":"0",
        "coinPrice":0.0,
        "percentage":0.0,
        "isContract": true,
        "path": {
          "legacy":"m/44'/60'/0'/0/0",
        },
        "service": "http://18.170.108.78:20012",
        "service_test": "http://54.243.83.152:20012",
        "chainId": 94,//100100100,
        "chainId_test": 100100100,//100100100,
        "contract": "0xe062fd6f7b483A648Ab9F84AD2BA76F9DEB0a550",
        "contract_test": "0xe062fd6f7b483A648Ab9F84AD2BA76F9DEB0a550",
        "canEdit": true,
        "rules": "ERC20",
        "customer":false,
      }*/
    },
    "mainnetContract":{
      "erc1155":"0x7632cA0FE8CBE97a59c600e5Afb3e75B9eC3Dc05",
      "erc721":"0xD535A5DAC95E5D5C9E121E20257E71a8FED74d95",
      "Market":"0x60a073d2F24884212859B10161590d7A67e225F9",
      "NftAddress":"0x70c8A83193a23Dd49Db33996570A573960Cf7653",//nft转账收款地址
    },
    "testnetContract":{
      "erc1155":"0xfd89417A8BE37e27162376b3a76E1EA2e1d930A9",
      "erc721":"0x1b035d6a285682De59f3b529e53D7D14b652014f",
      "Market":"0x958Bb3Fd435aC84302E8f3dE582730860825f00a",
      "NftAddress":"0xd02Da544Aa8F09F16c0FE28CA0C53772C95FB146",//nft转账收款地址
      /*"erc1155":"0x38523DAc202B9bdCe0c642E0B165F2dafe2d328c",
      "erc721":"0x1EA69cf17D3d249E545190a22213F98E47cb1379",
      "Market":"0xbA020608A5A03602d0C7D0BA64B430f1fBF65E34",*/
    },
    //挖矿合约地址
    "miningContract": "0x581231E78f9C15882ace8b6597b619999aeD5137"
  },
  CoinType.SOL.name:<String,dynamic>{
    "showList":true,//主链币是否显示在主页列表中
    //"sort":5,//列表排序依据
    "isTest":false,//是否时正式链
    "supportTest":true,
    "addrType":"legacy",//地址类型
    "pathIndex":0,//path具体的账号节点
    "pathList":[0],//path数量
    "baseInfo":<String,dynamic>{
      "blockchainType": BlockchainType.Solana.name,
      "coinType": CoinType.SOL.name,
      "icon": "https://api.n42.ai/market/v1/r/coinImage/Solana.png",
      "name": "Solana",
      "miniName": "SOL",
      "unit":"SOL",
      "chainId": 0,
      "decimals": 9,
      "balance":"0",
      "balance_test":"0",
      "coinPrice":0.0,
      "percentage":0.0,
      "isContract": false,
      "mKey": "SOL",
      "path": {
        "legacy":"m/44'/501'/0'",
      },
      "service": "https://api.mainnet-beta.solana.com",
      "service_test": "https://api.testnet.solana.com",
      "chainId_test": 0,
      "contract": "",
      "contract_test": "",
      "canEdit": false,
      "rules": "SPL",
    },
    "mainnetChainID":0,
    "testnetChainID":0,
    "testnetIndex":0,//当前选择的测试网络 索引值
    "testnets":[
      {
        "testnetWS":"",
        "testnetRPC":"",
        "testnetChainID":0,
        "testnetContract":<String,dynamic>{
        }
      },
    ],
    "mainnets":<String,dynamic>{
    },
    "mainnetContract":{
    },
    "testnetContract":{
      "SOL":"7ViD4q77VfADUiE2euhBVmrvYrrMJW3bFbjcgvujmAyZ",
    },
  },
  CoinType.TRX.name:<String,dynamic>{
    "showList":true,//主链币是否显示在主页列表中
    //"sort":6,//列表排序依据
    "isTest":false,//是否时正式链
    "supportTest":false,
    "addrType":"legacy",//地址类型
    "pathIndex":0,//path具体的账号节点
    "pathList":[0],//path数量
    "baseInfo":<String,dynamic>{
      "blockchainType": BlockchainType.Tron.name,
      "coinType": CoinType.TRX.name,
      "icon": "https://api.n42.ai/market/v1/r/coinImage/TRON.png",
      "name": "Tron",
      "miniName": "TRX",
      "unit":"TRX",
      "chainId": 0,
      "decimals": 6,
      "balance":'0',
      "balance_test":'0',
      "coinPrice":0.0,
      "percentage":0.0,
      "isContract": false,
      "mKey": "TRX",
      "path": {
        "legacy":"m/44'/195'/0'/0/0",
      },
      "service": "https://api.trongrid.io/jsonrpc",
      "service_test": "https://nile.trongrid.io/jsonrpc",
      "chainId_test": 0,
      "contract": "",
      "contract_test": "",
      "canEdit": false,
      "rules": "TRC20",
    },
    "mainnetWS":"https://api.trongrid.io",
    "mainnetRPC":"https://api.trongrid.io",
    "mainnetChainID":0,
    "testnetWS":"https://api.shasta.trongrid.io",
    "testnetRPC":"https://api.shasta.trongrid.io",
    "testnetChainID":0,
    "testnetIndex":0,//当前选择的测试网络 索引值
    "testnets":[
      {
        "testnetWS":"https://api.shasta.trongrid.io",
        "testnetRPC":"https://api.shasta.trongrid.io",
        "testnetChainID":0,
        "testnetContract":<String,dynamic>{
        }

      },
    ],
    "mainnets":<String,dynamic>{
    },
    "mainnetContract":{
    },
    "testnetContract":{
    },
  },
  CoinType.BNB.name:<String,dynamic>{
    "showList":true,//主链币是否显示在主页列表中
    "isTest":false,//是否时正式链
    "supportTest":false,
    "addrType":"legacy",//地址类型
    "pathIndex":0,//path具体的账号节点
    "pathList":[0],//path数量
    "baseInfo":<String,dynamic>{
      "blockchainType": BlockchainType.Ethereum.name,
      "coinType": CoinType.BNB.name,
      "icon": "https://api.n42.ai/market/v1/r/coinImage/BNB.png",
      "name": "Binance Smart Chain",
      "miniName": "BNB",
      "unit":"BNB",
      "chainId": 56,
      "decimals": 18,
      "balance":'0',
      "balance_test":'0',
      "coinPrice":0.0,
      "percentage":0.0,
      "isContract": false,
      "mKey": "BNB",
      "path": {
        "legacy":"m/44'/60'/0'/0/0",
      },
      "service": "https://bsc-dataseed1.binance.org/",
      "service_test": "https://data-seed-prebsc-1-s1.binance.org:8545",
      "chainId_test": 97,
      "contract": "",
      "contract_test": "",
      "canEdit": false,
      "rules": "BEP20",
    },
    "mainnetWS":"https://bsc-dataseed1.binance.org",
    "mainnetRPC":"https://bsc-dataseed1.binance.org",
    "mainnetChainID":0,
    "testnetWS":"https://data-seed-prebsc-1-s1.binance.org:8545",
    "testnetRPC":"https://data-seed-prebsc-1-s1.binance.org:8545",
    "testnetChainID":0,
    "testnetIndex":0,//当前选择的测试网络 索引值
    "testnets":[
      {
        "testnetWS":"https://data-seed-prebsc-1-s1.binance.org:8545",
        "testnetRPC":"https://data-seed-prebsc-1-s1.binance.org:8545",
        "testnetChainID":0,
        "testnetContract":<String,dynamic>{
        }

      },
    ],
    "mainnets":<String,dynamic>{
    },
    "mainnetContract":{
    },
    "testnetContract":{
    },
  },
  CoinType.OKT.name:<String,dynamic>{
    "showList":true,//主链币是否显示在主页列表中
    //"sort":6,//列表排序依据
    "isTest":false,//是否时正式链
    "supportTest":false,
    "addrType":"legacy",//地址类型
    "pathIndex":0,//path具体的账号节点
    "pathList":[0],//path数量
    "baseInfo":<String,dynamic>{
      "blockchainType": BlockchainType.Ethereum.name,
      "coinType": CoinType.OKT.name,
      "icon": "https://api.n42.ai/market/v1/r/coinImage/OKT Chain.png",
      "name": "OKX Chain",
      "miniName": "OKT",
      "unit":"OKT",
      "chainId": 66,
      "decimals": 18,
      "balance":'0',
      "balance_test":'0',
      "coinPrice":0.0,
      "percentage":0.0,
      "isContract": false,
      "mKey": "OKT",
      "path": {
        "legacy":"m/44'/60'/0'/0/0",
      },
      "service": "https://exchainrpc.okex.org",
      "service_test": "https://exchaintestrpc.okex.org",
      "chainId_test": 65,
      "contract": "",
      "contract_test": "",
      "canEdit": false,
      "rules": "ERC20",
    },
    "mainnetWS":"https://exchainrpc.okex.org",
    "mainnetRPC":"https://exchainrpc.okex.org",
    "mainnetChainID":66,
    "testnetWS":"https://exchaintestrpc.okex.org",
    "testnetRPC":"https://exchaintestrpc.okex.org",
    "testnetChainID":65,
    "testnetIndex":0,//当前选择的测试网络 索引值
    "testnets":[
      {
        "testnetWS":"https://exchaintestrpc.okex.org",
        "testnetRPC":"https://exchaintestrpc.okex.org",
        "testnetChainID":0,
        "testnetContract":<String,dynamic>{
        }

      },
    ],
    "mainnets":<String,dynamic>{
    },
    "mainnetContract":{
    },
    "testnetContract":{
    },
  },
  CoinType.BASE.name:<String,dynamic>{
    "showList":false,//主链币是否显示在主页列表中
    //"sort":2,//列表排序依据
    "isTest":false,//是否时正式链
    "supportTest":false,//是否可以使用测试网络
    "addrType":"legacy",//地址类型
    "pathIndex":0,//path具体的账号节点
    "pathList":[0],//path数量
    "baseInfo":<String,dynamic>{
      "mKey": "BASE",
      "blockchainType": BlockchainType.Ethereum.name,//链类型 字符串类型 Ethereum、Bitcoin、Solana、Tron等
      "coinType": CoinType.BASE.name,//是那种币，ETH、BNB、等
      "icon": "https://astranet.app/static/base.png",//图标地址
      "name": "Base",//链全名
      "miniName": "BASE",//链 的symbol，
      "unit":"ETH",
      "decimals": 18,//小数位数
      "balance":"0",
      "balance_test":"0",
      "coinPrice":0.0,
      "percentage":0.0,
      "isContract": false,
      "path": {
        "legacy":"m/44'/60'/0'/0/0",//链path，
      },
      "service": "https://mainnet.base.org",//主网rpc地址
      "service_test": "https://mainnet.base.org",//测试网rpc地址，如果没有传""
      "chainId": 8453,//主网链id
      "chainId_test": 8453,//测试网链id
      "contract": "",
      "contract_test": "",
      "canEdit": false,//是否可以修改
      "rules": "ERC20",//代币的类型 eth 是ERC20，BNB是BEP20，TRX 是TRC20
    },
    //"mainnetWS":"wss://mainnet.infura.io/ws/v3/b6bd1324a1b34545b1fdda886dd494f9",
    //"mainnetRPC":"https://mainnet.infura.io/v3/b6bd1324a1b34545b1fdda886dd494f9",
    "mainnetChainID":1,
    //"testnetWS":"https://ropsten.infura.io/v3/b6bd1324a1b34545b1fdda886dd494f9",
    //"testnetRPC":"https://ropsten.infura.io/v3/b6bd1324a1b34545b1fdda886dd494f9",
    "testnetChainID":3,
    "testnetIndex":0,//当前选择的测试网络 索引值
    "testnets":[
      {
        "testnetWS":"https://mainnet.base.org",
        "testnetRPC":"https://mainnet.base.org",
        "testnetChainID":8453,
        "testnetContract":<String,dynamic>{
        }
      },
    ],
    "mainnets":<String,dynamic>{
      "0X833589FCD6EDB6E08F4C7C32D4F71B54BDA02913": <String,dynamic>{
        "mKey": "0X833589FCD6EDB6E08F4C7C32D4F71B54BDA02913",
        "blockchainType": BlockchainType.Ethereum.name,
        "coinType": CoinType.BASE.name,
        "icon": "https://api.astranet.app/market/v1/r/coinImage/USDC.png",
        "name": "USD Coin",
        "miniName": "USDC",
        "unit":"USDC",
        "decimals": 6,//小数位数
        "balance":"0",
        "balance_test":"0",
        "coinPrice":0.0,
        "percentage":0.0,
        "isContract": true,
        "path": {
          "legacy":"m/44'/60'/0'/0/0",
        },
        "service": "https://mainnet.base.org",
        "service_test": "https://mainnet.base.org",
        "chainId": 8453,
        "chainId_test": 8453,
        "contract": "0x833589fcd6edb6e08f4c7c32d4f71b54bda02913",
        "contract_test": "0x833589fcd6edb6e08f4c7c32d4f71b54bda02913",
        "canEdit": true,
        "rules": "ERC20",
      },
    },
  },
  CoinType.FIL.name:{
    "showList":true,//主链币是否显示在主页列表中
    "isTest":false,//是否时正式链
    "supportTest":true,
    "addrType":"legacy",//地址类型
    "pathIndex":0,//path具体的账号节点
    "pathList":[0],//path数量
    "baseInfo":{
      "blockchainType": BlockchainType.Filecoin.name,
      "coinType": CoinType.FIL.name,
      "icon": "https://api.n42.ai/market/v1/r/coinImage/Filecoin.png",
      "name": "Filecoin",
      "miniName": "FIL",
      "unit":"FIL",
      "chainId": 461,
      "decimals": 18,
      "balance":"0",
      "balance_test":"0",
      "coinPrice":0.0,
      "percentage":0.0,
      "isContract": false,
      "mKey": "FIL",
      "path": {
        "legacy":"m/44'/461'/0'/0/0",
      },
      "service": "",
      "service_test": "",
      "chainId_test": 0,
      "contract": "",
      "contract_test": "",
      "canEdit": true,
      "rules": "FIL",
    },
    "mainnetWS":"",
    "mainnetRPC":"",
    "mainnetChainID":0,
    "testnetWS":"",
    "testnetRPC":"",
    "testnetChainID":0,
    "testnetIndex":0,//当前选择的测试网络 索引值
    "testnets":[
      {
        "testnetWS":"",
        "testnetRPC":"",
        "testnetChainID":0,
        "testnetContract":{
        }

      },
    ],
    "mainnets":{
    },
    "mainnetContract":{
    },
    "testnetContract":{
    },
  },
  CoinType.DOT.name:{
    "showList":true,//主链币是否显示在主页列表中
    "isTest":false,//是否时正式链
    "supportTest":true,
    "addrType":"legacy",//地址类型
    "pathIndex":0,//path具体的账号节点
    "pathList":[0],//path数量
    "baseInfo":{
      "blockchainType": BlockchainType.Polkadot.name,
      "coinType": CoinType.DOT.name,
      "icon": "https://api.n42.ai/market/v1/r/coinImage/Polkadot.png",
      "name": "Polkadot",
      "miniName": "DOT",
      "unit":"DOT",
      "chainId": 354,
      "decimals": 10,//test链12，main链10
      "balance":"0",
      "balance_test":"0",
      "coinPrice":0.0,
      "percentage":0.0,
      "isContract": false,
      "mKey": "DOT",
      "path": {
        "legacy":"m/44'/354'/0'/0/0",
      },
      "service": "",
      "service_test": "",
      "chainId_test": 0,
      "contract": "",
      "contract_test": "",
      "canEdit": true,
      "rules": "DOT",
    },
    "mainnetWS":"",
    "mainnetRPC":"",
    "mainnetChainID":0,
    "testnetWS":"",
    "testnetRPC":"",
    "testnetChainID":0,
    "testnetIndex":0,//当前选择的测试网络 索引值
    "testnets":[
      {
        "testnetWS":"",
        "testnetRPC":"",
        "testnetChainID":0,
        "testnetContract":{
        }

      },
    ],
    "mainnets":{
    },
    "mainnetContract":{
    },
    "testnetContract":{
    },
  },

  /*CoinType.ACA.name:{
    "isTest":false,//是否时正式链
    "supportTest":true,
    "addrType":"legacy",//地址类型
    "pathIndex":0,//path具体的账号节点
    "pathList":[0],//path数量
    "baseInfo":{
      "blockchainType": BlockchainType.Polkadot.name,
      "coinType": CoinType.ACA.name,
      "icon": "https://api.n42.ai/market/v1/r/coinImage/Acala.png",
      "name": "Acala",
      "miniName": "ACA",
      "unit":"ACA",
      "chainId": 787,
      "decimals": 12,
      "balance":"0",
      "balance_test":"0",
      "coinPrice":0.0,
      "percentage":0.0,
      "isContract": false,
      "mKey": "ACA",
      "path": {
        "legacy":"m/44'/787'/0'/0/0",
      },
      "service": "",
      "service_test": "",
      "chainId_test": 0,
      "contract": "",
      "contract_test": "",
      "canEdit": true,
      "rules": "ACA",
    },
    "mainnetWS":"",
    "mainnetRPC":"",
    "mainnetChainID":0,
    "testnetWS":"",
    "testnetRPC":"",
    "testnetChainID":0,
    "testnetIndex":0,//当前选择的测试网络 索引值
    "testnets":[
      {
        "testnetWS":"",
        "testnetRPC":"",
        "testnetChainID":0,
        "testnetContract":{
        }

      },
    ],
    "mainnets":{
    },
    "mainnetContract":{
    },
    "testnetContract":{
    },
  },
  CoinType.KSM.name:{
    "isTest":false,//是否时正式链
    "supportTest":true,
    "addrType":"legacy",//地址类型
    "pathIndex":0,//path具体的账号节点
    "pathList":[0],//path数量
    "baseInfo":{
      "blockchainType": BlockchainType.Polkadot.name,
      "coinType": CoinType.ACA.name,
      "icon": "https://api.n42.ai/market/v1/r/coinImage/Kusama.png",
      "name": "Kusama",
      "miniName": "KSM",
      "unit":"KSM",
      "chainId": 434,
      "decimals": 12,
      "balance":"0",
      "balance_test":"0",
      "coinPrice":0.0,
      "percentage":0.0,
      "isContract": false,
      "mKey": "KSM",
      "path": {
        "legacy":"m/44'/434'/0'/0/0",
      },
      "service": "",
      "service_test": "",
      "chainId_test": 0,
      "contract": "",
      "contract_test": "",
      "canEdit": true,
      "rules": "KSM",
    },
    "mainnetWS":"",
    "mainnetRPC":"",
    "mainnetChainID":0,
    "testnetWS":"",
    "testnetRPC":"",
    "testnetChainID":0,
    "testnetIndex":0,//当前选择的测试网络 索引值
    "testnets":[
      {
        "testnetWS":"",
        "testnetRPC":"",
        "testnetChainID":0,
        "testnetContract":{
        }

      },
    ],
    "mainnets":{
    },
    "mainnetContract":{
    },
    "testnetContract":{
    },
  },
  CoinType.APT.name:{
    "isTest":true,//是否时正式链
    "supportTest":true,
    "addrType":"legacy",//地址类型
    "pathIndex":0,//path具体的账号节点
    "pathList":[0],//path数量
    "baseInfo":{
      "blockchainType": BlockchainType.Aptos.name,
      "coinType": CoinType.APT.name,
      "icon": "https://api.n42.ai/market/v1/r/coinImage/Aptos.png",
      "name": "Aptos",
      "miniName": "APT",
      "unit":"APT",
      "chainId": 1,
      "decimals": 8,
      "balance":"0",
      "balance_test":"0",
      "coinPrice":0.0,
      "percentage":0.0,
      "isContract": false,
      "mKey": "APT",
      "path": {
        "legacy":"m/44'/637'/0'/0/0",
      },
      "service": "",
      "service_test": "",
      "chainId_test": 0,
      "contract": "",
      "contract_test": "",
      "canEdit": true,
      "rules": "APT",
    },
    "mainnetWS":"",
    "mainnetRPC":"",
    "mainnetChainID":0,
    "testnetWS":"",
    "testnetRPC":"",
    "testnetChainID":0,
    "testnetIndex":0,//当前选择的测试网络 索引值
    "testnets":[
      {
        "testnetWS":"",
        "testnetRPC":"",
        "testnetChainID":0,
        "testnetContract":{
        }

      },
    ],
    "mainnets":{
    },
    "mainnetContract":{
    },
    "testnetContract":{
    },
  },
  CoinType.SUI.name:{
    "isTest":true,//是否时正式链
    "supportTest":true,
    "addrType":"legacy",//地址类型
    "pathIndex":0,//path具体的账号节点
    "pathList":[0],//path数量
    "baseInfo":{
      "blockchainType": BlockchainType.Sui.name,
      "coinType": CoinType.SUI.name,
      "icon": "https://api.n42.ai/market/v1/r/coinImage/Sui.png",
      "name": "Sui",
      "miniName": "SUI",
      "unit":"SUI",
      "chainId": 1,
      "decimals": 9,
      "balance":"0",
      "balance_test":"0",
      "coinPrice":0.0,
      "percentage":0.0,
      "isContract": false,
      "mKey": "SUI",
      "path": {
        "legacy":"m/44'/784'/0'/0/0",
      },
      "service": "",
      "service_test": "",
      "chainId_test": 0,
      "contract": "",
      "contract_test": "",
      "canEdit": true,
      "rules": "SUI",
    },
    "mainnetWS":"",
    "mainnetRPC":"",
    "mainnetChainID":0,
    "testnetWS":"",
    "testnetRPC":"",
    "testnetChainID":0,
    "testnetIndex":0,//当前选择的测试网络 索引值
    "testnets":[
      {
        "testnetWS":"",
        "testnetRPC":"",
        "testnetChainID":0,
        "testnetContract":{
        }

      },
    ],
    "mainnets":{
    },
    "mainnetContract":{
    },
    "testnetContract":{
    },
  },*/
  CoinType.XRP.name:{
    "showList":true,//主链币是否显示在主页列表中
    "isTest":false,//是否时正式链
    "supportTest":true,
    "addrType":"legacy",//地址类型
    "pathIndex":0,//path具体的账号节点
    "pathList":[0],//path数量
    "baseInfo":{
      "blockchainType": BlockchainType.Ripple.name,
      "coinType": CoinType.XRP.name,
      "icon": "https://api.n42.ai/market/v1/r/coinImage/XRP.png",
      "name": "Ripple",
      "miniName": "XRP",
      "unit":"XRP",
      "chainId": 0,
      "decimals": 6,
      "balance":"0",
      "balance_test":"0",
      "coinPrice":0.0,
      "percentage":0.0,
      "isContract": false,
      "mKey": "XRP",
      "path": {
        "legacy":"m/44'/144'/0'/0/0",
      },
      "service": "",
      "service_test": "",
      "chainId_test": 0,
      "contract": "",
      "contract_test": "",
      "canEdit": true,
      "rules": "XRP",
    },
    "mainnetWS":"https://rpc.tulip.tools/mainnet",
    "mainnetRPC":"https://rpc.tulip.tools/mainnet",
    "mainnetChainID":0,
    "testnetWS":"https://rpc.tulip.tools/mainnet",
    "testnetRPC":"https://rpc.tulip.tools/mainnet",
    "testnetChainID":0,
    "testnetIndex":0,//当前选择的测试网络 索引值
    "testnets":[
      {
        "testnetWS":"https://rpc.tulip.tools/mainnet",
        "testnetRPC":"https://rpc.tulip.tools/mainnet",
        "testnetChainID":0,
        "testnetContract":{
        }

      },
    ],
    "mainnets":{
    },
    "mainnetContract":{
    },
    "testnetContract":{
    },
  },
  CoinType.ATOM.name:{
    "showList":true,//主链币是否显示在主页列表中
    "isTest":false,//是否时正式链
    "supportTest":false,
    "addrType":"legacy",//地址类型
    "pathIndex":0,//path具体的账号节点
    "pathList":[0],//path数量
    "baseInfo":{
      "blockchainType": BlockchainType.Cosmos.name,
      "coinType": CoinType.ATOM.name,
      "icon": "https://api.n42.ai/market/v1/r/coinImage/Cosmos Hub.png",
      "name": "Cosmos",
      "miniName": "ATOM",
      "unit":"ATOM",
      "chainId": "cosmoshub-4",
      "decimals": 6,
      "balance":"0",
      "balance_test":"0",
      "coinPrice":0.0,
      "percentage":0.0,
      "isContract": false,
      "mKey": "ATOM",
      "path": {
        "legacy":"m/44'/118'/0'/0/0",
      },
      "service": "https://cosmos-lcd.quickapi.com/",
      "service_test": "",
      "chainId_test": 0,
      "contract": "",
      "contract_test": "",
      "canEdit": false,
      "rules": "ATOM",
    },
    "mainnetWS":"https://stargate.cosmos.network",
    "mainnetRPC":"https://stargate.cosmos.network",
    "mainnetChainID":0,
    "testnetWS":"https://stargate.cosmos.network",
    "testnetRPC":"https://stargate.cosmos.network",
    "testnetChainID":0,
    "testnetIndex":0,//当前选择的测试网络 索引值
    "testnets":[
      {
        "testnetWS":"https://stargate.cosmos.network",
        "testnetRPC":"https://stargate.cosmos.network",
        "testnetChainID":0,
        "testnetContract":{
        }

      },
    ],
    "mainnets":{
    },
    "mainnetContract":{
    },
    "testnetContract":{
    },
  },
  /*CoinType.TON.name:{
    "showList":true,//主链币是否显示在主页列表中
    "isTest":true,//是否时正式链
    "supportTest":false,
    "addrType":"legacy",//地址类型
    "pathIndex":0,//path具体的账号节点
    "pathList":[0],//path数量
    "baseInfo":{
      "blockchainType": BlockchainType.TheOpenNetwork.name,
      "coinType": CoinType.TON.name,
      "icon": "https://api.n42.ai/market/v1/r/coinImage/TheOpenNetwork.png",
      "name": "TON",
      "miniName": "TON",
      "unit":"TON",
      "chainId": "607",
      "decimals": 9,
      "balance":"0",
      "balance_test":"0",
      "coinPrice":0.0,
      "percentage":0.0,
      "isContract": false,
      "mKey": "TON",
      "path": {
        "legacy":"m/44'/607'/0'",
      },
      "service": "https://toncenter.com/api/v2/jsonRPC",
      "service_test": "",
      "chainId_test": 0,
      "contract": "",
      "contract_test": "",
      "canEdit": false,
      "rules": "TON",
    },
    "mainnetWS":"https://toncenter.com/api/v2/jsonRPC",
    "mainnetRPC":"https://toncenter.com/api/v2/jsonRPC",
    "mainnetChainID":0,
    "testnetWS":"https://testnet.toncenter.com/api/v2/jsonRPC",
    "testnetRPC":"https://testnet.toncenter.com/api/v2/jsonRPC",
    "testnetChainID":0,
    "testnetIndex":0,//当前选择的测试网络 索引值
    "testnets":[
      {
        "testnetWS":"https://testnet.toncenter.com/api/v2/jsonRPC",
        "testnetRPC":"https://testnet.toncenter.com/api/v2/jsonRPC",
        "testnetChainID":0,
        "testnetContract":{
        }

      },
    ],
    "mainnets":{
    },
    "mainnetContract":{
    },
    "testnetContract":{
    },
  },
  CoinType.S.name:{
    "showList":true,//主链币是否显示在主页列表中
    //"sort":2,//列表排序依据
    "isTest":true,//是否时正式链
    "supportTest":true,//是否可以使用测试网络
    "addrType":"legacy",//地址类型
    "pathIndex":0,//path具体的账号节点
    "pathList":[0],//path数量
    "baseInfo":{
      "mKey": "S",
      "blockchainType": BlockchainType.Ethereum.name,//链类型 字符串类型 Ethereum、Bitcoin、Solana、Tron等
      "coinType": CoinType.S.name,//是那种币，ETH、BNB、等
      "icon": "https://api-wallet.walletamaze.com/market/v1/r/coinImage/Sonic.png",//图标地址https://api.astranet.app/market/v1/r/coinImage/Soperme.png
      "name": "Sonic",//链全名
      "miniName": "S",//链 的symbol，
      "unit":"S",
      "decimals": 18,//小数位数
      "balance":"0",
      "balance_test":"0",
      "coinPrice":0.0,
      "percentage":0.0,
      "isContract": false,
      "path": {
        "legacy":"m/44'/60'/0'/0/0",//链path，
      },
      "service": "https://rpc.soniclabs.com",//主网rpc地址
      "service_test": "https://rpc.blaze.soniclabs.com",//测试网rpc地址，如果没有传""
      "chainId": 146,//主网链id
      "chainId_test": 57054,//测试网链id
      "contract": "",
      "contract_test": "",
      "canEdit": false,//是否可以修改
      "rules": "ERC20",//代币的类型 eth 是ERC20，BNB是BEP20，TRX 是TRC20
      "custom": true,
    },
    "mainnetChainID":146,
    "testnetChainID":57054,
    "testnetIndex":0,//当前选择的测试网络 索引值
    "testnets":[
      {
        "testnetWS":"https://rpc.blaze.soniclabs.com",
        "testnetRPC":"https://rpc.blaze.soniclabs.com",
        "testnetChainID":57054,
        "testnetContract":{
        }
      },
    ],
    "mainnets":{
    },
  },
  CoinType.BB.name:{
    "showList":true,//主链币是否显示在主页列表中
    //"sort":2,//列表排序依据
    "isTest":true,//是否时正式链
    "supportTest":true,//是否可以使用测试网络
    "addrType":"legacy",//地址类型
    "pathIndex":0,//path具体的账号节点
    "pathList":[0],//path数量
    "baseInfo":{
      "mKey": "S",
      "blockchainType": BlockchainType.Ethereum.name,//链类型 字符串类型 Ethereum、Bitcoin、Solana、Tron等
      "coinType": CoinType.BB.name,//是那种币，ETH、BNB、等
      "icon": "https://api-wallet.walletamaze.com/market/v1/r/coinImage/BounceBit.png",//图标地址https://api.astranet.app/market/v1/r/coinImage/Soperme.png
      "name": "BounceBit",//链全名
      "miniName": "BB",//链 的symbol，
      "unit":"BB",
      "decimals": 18,//小数位数
      "balance":"0",
      "balance_test":"0",
      "coinPrice":0.0,
      "percentage":0.0,
      "isContract": false,
      "path": {
        "legacy":"m/44'/60'/0'/0/0",//链path，
      },
      "service": "https://fullnode-mainnet.bouncebitapi.com",//主网rpc地址
      "service_test": "https://fullnode-testnet.bouncebitapi.com",//测试网rpc地址，如果没有传""
      "chainId": 6001,//主网链id
      "chainId_test": 6000,//测试网链id
      "contract": "",
      "contract_test": "",
      "canEdit": false,//是否可以修改
      "rules": "ERC20",//代币的类型 eth 是ERC20，BNB是BEP20，TRX 是TRC20
      "custom": true,
    },
    "mainnetChainID":6001,
    "testnetChainID":6000,
    "testnetIndex":0,//当前选择的测试网络 索引值
    "testnets":[
      {
        "testnetWS":"https://fullnode-testnet.bouncebitapi.com",
        "testnetRPC":"https://fullnode-testnet.bouncebitapi.com",
        "testnetChainID":6000,
        "testnetContract":{
        }
      },
    ],
    "mainnets":{
    },
  },*/
  /*CoinType.ALGO.name:{
    "showList":true,//主链币是否显示在主页列表中
    //"sort":7,//列表排序依据
    "isTest":true,//是否时正式链
    "supportTest":true,
    "addrType":"legacy",//地址类型
    "pathIndex":0,//path具体的账号节点
    "pathList":[0],//path数量
    "baseInfo":{
      "blockchainType": BlockchainType.Algorand.name,
      "coinType": CoinType.ALGO.name,
      "icon": "https://api-wallet.walletamaze.com/market/v1/r/coinImage/algo.png",
      "name": "Algorand",
      "miniName": "ALGO",
      "unit":"ALGO",
      "chainId": 0,
      "decimals": 6,
      "balance":"0",
      "balance_test":"0",
      "coinPrice":0.0,
      "percentage":0.0,
      "isContract": false,
      "mKey": "ALGO",
      "path": {
        "legacy":"m/44'/283'/0'/0'/0'",
      },
      "service": "",
      "service_test": "",
      "chainId": 0,
      "chainId_test": 0,
      "contract": "",
      "contract_test": "",
      "canEdit": false,
      "rules": "ALGO",
    },
    "mainnetWS":"https://indexer.algorand.network",
    "mainnetRPC":"https://indexer.algorand.network",
    "mainnetChainID":0,
    "testnetWS":"https://indexer.algorand.network",
    "testnetRPC":"https://indexer.algorand.network",
    "testnetChainID":0,
    "testnetIndex":0,//当前选择的测试网络 索引值
    "testnets":[
      {
        "testnetWS":"https://indexer.algorand.network",
        "testnetRPC":"https://indexer.algorand.network",
        "testnetChainID":0,
        "testnetContract":{
          "12400859": {
            "mKey": "12400859",
            "blockchainType": BlockchainType.Algorand.name,
            "coinType": CoinType.ALGO.name,
            "icon": "https://www.amazechain.org:15801/v1/r/coinImage/usdc.png",
            "name": "Monerium EUR emoney ",
            "miniName": "USDC",
            "unit":"USDC",
            "decimals": 8,//小数位数
            "balance":"0",
            "balance_test":"0",
            "coinPrice":0.0,
            "percentage":0.0,
            "isContract": true,
            "path": {
              "legacy":"m/44'/283'/0'/0'/0'",
            },
            "service": "",
            "service_test": "",
            "chainId": 0,
            "chainId_test": 0,
            "contract": "12400859",
            "contract_test": "12400859",
            "canEdit": false,
            "rules": "Asset",
          },
        }

      },
    ],
    "mainnets":{
    },
    "mainnetContract":{
    },
    "testnetContract":{
    },
  },*/
  /*CoinType.XTZ.name:{
    "isTest":true,//是否时正式链
    "supportTest":true,
    "addrType":"legacy",//地址类型
    "pathIndex":0,//path具体的账号节点
    "pathList":[0],//path数量
    "baseInfo":{
      "blockchainType": BlockchainType.Tezos.name,
      "coinType": CoinType.XTZ.name,
      "icon": "https://www.amazechain.org:15801/v1/r/coinImage/xtz.png",
      "name": "Tezos",
      "miniName": "XTZ",
      "unit":"XTZ",
      "chainId": 0,
      "decimals": 6,
      "balance":"0",
      "balance_test":"0",
      "coinPrice":0.0,
      "percentage":0.0,
      "isContract": false,
      "mKey": "XTZ",
      "path": {
        "legacy":"m/44'/1729'/0'/0'",
      },
      "service": "",
      "service_test": "",
      "chainId_test": 0,
      "contract": "",
      "contract_test": "",
      "canEdit": false,
      "rules": "XTZ",
    },
    "mainnetWS":"https://rpc.tulip.tools/mainnet",
    "mainnetRPC":"https://rpc.tulip.tools/mainnet",
    "mainnetChainID":0,
    "testnetWS":"https://rpc.tulip.tools/mainnet",
    "testnetRPC":"https://rpc.tulip.tools/mainnet",
    "testnetChainID":0,
    "testnetIndex":0,//当前选择的测试网络 索引值
    "testnets":[
      {
        "testnetWS":"https://rpc.tulip.tools/mainnet",
        "testnetRPC":"https://rpc.tulip.tools/mainnet",
        "testnetChainID":0,
        "testnetContract":{
        }

      },
    ],
    "mainnets":{
    },
    "mainnetContract":{
    },
    "testnetContract":{
    },
  },*/
  /*CoinType.XLM.name:{
    "isTest":true,//是否时正式链
    "supportTest":true,
    "addrType":"legacy",//地址类型
    "pathIndex":0,//path具体的账号节点
    "pathList":[0],//path数量
    "baseInfo":{
      "blockchainType": BlockchainType.Stellar.name,
      "coinType": CoinType.XLM.name,
      "icon": "https://www.amazechain.org:15801/v1/r/coinImage/xlm.png",
      "name": "Stellar",
      "miniName": "XLM",
      "unit":"XLM",
      "chainId": 0,
      "decimals": 7,
      "balance":"0",
      "balance_test":"0",
      "coinPrice":0.0,
      "percentage":0.0,
      "isContract": false,
      "mKey": "XLM",
      "path": {
        "legacy":"m/44'/148'/0'",
      },
      "service": "",
      "service_test": "",
      "chainId_test": 0,
      "contract": "",
      "contract_test": "",
      "canEdit": false,
      "rules": "XLM",
    },
    "mainnetWS":"",
    "mainnetRPC":"",
    "mainnetChainID":0,
    "testnetWS":"",
    "testnetRPC":"",
    "testnetChainID":0,
    "testnetIndex":0,//当前选择的测试网络 索引值
    "testnets":[
      {
        "testnetWS":"",
        "testnetRPC":"",
        "testnetChainID":0,
        "testnetContract":{
        }

      },
    ],
    "mainnets":{
    },
    "mainnetContract":{
    },
    "testnetContract":{
    },
  },*/
};
//根据 index和默认path 返回新path
String getPathWithIndex(String path,int index){
  List<String> paths=path.split('/');
  if(paths.length>=4){
    int indexOf=paths[paths.length-1].lastIndexOf("'");
    String rPath="";
    for(int i=0;i<paths.length-1;i++){
      rPath+="${paths[i]}/";
    }
    if(indexOf==-1){
      rPath+="${index}";
    }else{
      rPath+="${index}'";
    }
    return rPath;
  }else{
    return path;
  }
}
Map<String,String>decimalMap={
  "0" :"1.0",
  '1' :"10.0",
  '2' :"100.0",
  '3' :"1000.0",
  '4' :"10000.0",
  '5' :"100000.0",
  '6' :"1000000.0",
  '7' :"10000000.0",
  '8' :"100000000.0",
  '9' :"1000000000.0",
  '10':"10000000000.0",
  '11':"100000000000.0",
  '12':"1000000000000.0",
  '13':"10000000000000.0",
  '14':"100000000000000.0",
  '15':"1000000000000000.0",
  '16':"10000000000000000.0",
  '17':"100000000000000000.0",
  '18':"1000000000000000000.0",
};
Decimal toEther(String wei,int decimal) {
  int weiLength=wei.length;
  if(weiLength>decimal){
    String wei1=wei.substring(0,weiLength-decimal);
    String wei2="0."+wei.substring(weiLength-decimal);
    return Decimal.parse(wei1)+Decimal.parse(wei2);
  }else{
    Decimal dd=(Decimal.parse(wei) / Decimal.parse(decimalMap[decimal.toString()]!)).toDecimal();
    return dd;
  }
}

double toGWei(String wei) {
  int l = wei.length;
  if (l <= 1) {
    return double.parse(wei);
  }

  if (l <= 9) {
    //String formatted = sprintf("0.%018s", [wei]);
    Decimal formatted= (Decimal.parse(wei) / Decimal.parse('1000000000')).toDecimal();
    //double formattedflustars.NumUtil.divide(BigInt.parse(wei).toDouble(), 1000000000);
    return formatted.toDouble();//double.parse(formatted);
  } else {
    int fix = l - 9;
    // String formatted = '${wei.substring(0, fix)}.${wei.substring(fix+1, fix+6)}';
    String formatted ="${wei.substring(0, fix)}.${wei.substring(fix, l)}";
    return Decimal.parse(formatted).toDouble();
    //sprintf("%s.%s", [wei.substring(0, fix), wei.substring(fix, l)]);
    //return double.parse(formatted);
  }
}

BigInt ethToWeiString(String eth,int decimals) {
  List<String> list = eth.split('.');
  if (list.length > 2) {
    return BigInt.from(0);
  }
  BigInt prix = BigInt.parse(list[0]);
  if(decimals==18){
    EtherAmount a = //EtherAmount.fromUnitAndValue(EtherUnit.ether, prix);
    EtherAmount.fromBigInt(EtherUnit.ether, prix);
    if (list.length == 1) {
      return a.getInWei;
    }
    int len = list[1].length;
    if(len>18){
      len=18;
    }
    int diff = 18 - len;
    BigInt bDiff = BigInt.parse(list[1]);
    BigInt n = bDiff * BigInt.from(10).pow(diff);
    return a.getInWei + n;
  }else{
    double dec= double.parse(decimalMap[decimals.toString()]!);
    Decimal rValue=Decimal.parse(eth)*Decimal.parse(dec.toString());
    return rValue.toBigInt();
  }
}
