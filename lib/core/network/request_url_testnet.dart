part of 'request_url.dart';

/// Testnet URL 配置 (私有，通过 RequestUrl.requestUrlTest1 访问)
final Map<String, Map<String, dynamic>> _requestUrlTest1 = {
  'BNB': {
    'api': 'https://api-testnet.bscscan.com/api?',
    'browser': 'https://testnet.bscscan.com/',
    'rpc': 'https://data-seed-prebsc-1-s1.binance.org:8545',
  },
  'ETH': {
    'api': 'https://api-sepolia.etherscan.io/api?',
    'browser': 'https://sepolia.etherscan.io/',
    'rpc': 'https://sepolia.infura.io/v3/', // 由 initializeApiKeys() 更新
  },
  // Mumbai(80001) 已于 2024-04 关停,继任测试网为 Amoy(80002)；
  // 链注册表侧由 chain_testnet_config_guard_test 守护。
  'MATIC': {
    'api': 'https://api-amoy.polygonscan.com/api?',
    'browser': 'https://amoy.polygonscan.com/',
    'rpc': 'https://polygon-amoy-bor-rpc.publicnode.com',
  },
  'SOL': {
    'api': 'https://api-testnet.solscan.io/',
    'browser': 'https://solscan.io/',
    'rpc': 'https://api.testnet.solana.com',
  },
  'TRX': {
    'api': 'https://nile.trongrid.io',
    'browser': 'https://nile.tronscan.org/#/',
    'rpc': 'https://nile.trongrid.io',
  },
  'N': {
    'api': 'https://testnet2.n42.world/api?',
    'browser': 'https://testnet2.n42.world/',
    'rpc': 'https://testrpc2.n42.world',
  },
  // ETC Kotti 测试网 2022 年已关停,端点置空(过时内容清理 2026-08-15)
  'ETC': {'api': '', 'browser': '', 'rpc': ''},
  'AVAX': {
    'api': 'https://api-testnet.snowtrace.io/api?',
    'browser': 'https://testnet.snowtrace.io/',
    'rpc': 'https://api.avax-test.network/ext/bc/C/rpc',
  },
  // Heco 链 2024 年已停运,测试网端点全部失效(过时内容清理 2026-08-15)
  'HT': {'api': '', 'browser': '', 'rpc': ''},
  'FTM': {
    'api': 'https://api-testnet.ftmscan.com/api?',
    'browser': 'https://testnet.ftmscan.com/',
    'rpc': 'https://rpc.testnet.fantom.network',
  },
  'CELO': {
    'api': 'https://alfajores-blockscout.celo-testnet.org/api?',
    'browser': 'https://alfajores-blockscout.celo-testnet.org/',
    'rpc': 'https://alfajores-forno.celo-testnet.org',
  },
  'CLO': {
    'api': 'https://testnet-explorer.callisto.network/api?',
    'browser': 'https://testnet-explorer.callisto.network/',
    'rpc': 'https://testnet-rpc.callisto.network/',
  },
  // POA Sokol 测试网 2022 年已关停(过时内容清理 2026-08-15)
  'POA': {'api': '', 'browser': '', 'rpc': ''},
  'TOMO': {'api': '', 'browser': '', 'rpc': ''},
  'TT': {'api': '', 'browser': '', 'rpc': ''},
  'GO': {'api': '', 'browser': '', 'rpc': 'https://testnet-rpc.gochain.io'},
  'WAN': {'api': '', 'browser': '', 'rpc': ''},
  'CRO': {'api': '', 'browser': '', 'rpc': 'https://evm-t3.cronos.org'},
  'KAVA': {'api': '', 'browser': '', 'rpc': ''},
  'KCS': {'api': '', 'browser': '', 'rpc': ''},
  'BOBA': {'api': '', 'browser': '', 'rpc': ''},
  'EVMOS': {'api': '', 'browser': '', 'rpc': ''},
  'MOVR': {'api': '', 'browser': '', 'rpc': ''},
  'GLMR': {'api': '', 'browser': '', 'rpc': ''},
  'KLAY': {'api': '', 'browser': '', 'rpc': 'https://rpc.ankr.com/klaytn_testnet'},
  'MTR': {'api': '', 'browser': '', 'rpc': ''},
  'OKT': {
    'api': '',
    'browser': '',
    'rpc': 'https://exchaintestrpc.okex.org/',
  },
  'OP': {'api': '', 'browser': '', 'rpc': ''},
  'ARB': {
    'api': '',
    'browser': 'https://stylus-testnet-explorer.arbitrum.io/',
    'rpc': 'https://sepolia-rollup.arbitrum.io/rpc',
  },
  'LINEA': {
    'api': '',
    'browser': 'https://sepolia.lineascan.build/',
    'rpc': 'https://rpc.sepolia.linea.build',
  },
  'MNT': {
    'api': '',
    'browser': 'https://sepolia.mantlescan.xyz/',
    'rpc': 'https://rpc.sepolia.mantle.xyz',
  },
  'SCROLL': {
    'api': '',
    'browser': 'https://sepolia.scrollscan.com/',
    'rpc': 'https://sepolia-rpc.scroll.io',
  },
  'ZKSYNC': {
    'api': '',
    'browser': 'https://sepolia.explorer.zksync.io/',
    'rpc': 'https://sepolia.era.zksync.dev',
  },
  'AURORA': {'api': '', 'browser': '', 'rpc': ''},
  'METIS': {
    'api': '',
    'browser': '',
    'rpc': 'https://stardust.metis.io/?owner=588',
  },
  // BTC-like coins: rpc 由 initializeApiKeys() 从 RpcConfig 更新
  'BTC': {
    'api': 'https://mempool.space/testnet4/api/',
    'api1': 'https://api.blockcypher.com/v1/btc/test3',
    'browser': 'https://live.blockcypher.com/btc-testnet/',
    'rpc': '',
  },
  'LTC': {
    'api': 'https://198.200.30.38:18390/v1/',
    'api1': 'https://api.blockcypher.com/v1/btc/test3',
    'browser': 'https://live.blockcypher.com/btc-testnet/',
    'rpc': '',
  },
  'DOGE': {
    'api': 'https://198.200.30.38:18390/v1/',
    'api1': 'https://api.blockcypher.com/v1/btc/test3',
    'browser': 'https://live.blockcypher.com/btc-testnet/',
    'rpc': '',
  },
  'DASH': {
    'api': 'https://198.200.30.38:18390/v1/',
    'api1': 'https://api.blockcypher.com/v1/btc/test3',
    'browser': 'https://live.blockcypher.com/btc-testnet/',
    'rpc': '',
  },
  'VIA': {
    'api': 'https://198.200.30.38:18390/v1/',
    'api1': 'https://api.blockcypher.com/v1/btc/test3',
    'browser': 'https://live.blockcypher.com/btc-testnet/',
    'rpc': '',
  },
  'DGB': {
    'api': 'https://198.200.30.38:18390/v1/',
    'api1': 'https://api.blockcypher.com/v1/btc/test3',
    'browser': 'https://live.blockcypher.com/btc-testnet/',
    'rpc': '',
  },
  'MONA': {
    'api': 'https://198.200.30.38:18390/v1/',
    'api1': 'https://api.blockcypher.com/v1/btc/test3',
    'browser': 'https://live.blockcypher.com/btc-testnet/',
    'rpc': '',
  },
  'FIRO': {
    'api': 'https://198.200.30.38:18390/v1/',
    'api1': 'https://api.blockcypher.com/v1/btc/test3',
    'browser': 'https://live.blockcypher.com/btc-testnet/',
    'rpc': '',
  },
  'BCH': {
    'api': 'https://198.200.30.38:18390/v1/',
    'api1': 'https://api.blockcypher.com/v1/btc/test3',
    'browser': 'https://live.blockcypher.com/btc-testnet/',
    'rpc': '',
  },
  'BTG': {
    'api': 'https://198.200.30.38:18390/v1/',
    'api1': 'https://api.blockcypher.com/v1/btc/test3',
    'browser': 'https://live.blockcypher.com/btc-testnet/',
    'rpc': '',
  },
  'RVN': {
    'api': 'https://198.200.30.38:18390/v1/',
    'api1': 'https://api.blockcypher.com/v1/btc/test3',
    'browser': 'https://live.blockcypher.com/btc-testnet/',
    'rpc': '',
  },
  'QTUM': {
    'api': 'https://198.200.30.38:18390/v1/',
    'api1': 'https://api.blockcypher.com/v1/btc/test3',
    'browser': 'https://live.blockcypher.com/btc-testnet/',
    'rpc': '',
  },
  'XEC': {
    'api': 'https://198.200.30.38:18390/v1/',
    'api1': 'https://api.blockcypher.com/v1/btc/test3',
    'browser': 'https://live.blockcypher.com/btc-testnet/',
    'rpc': '',
  },
  'ALGO': {
    'api': 'https://node.testnet.algoexplorerapi.io/',
    'browser': 'https://testnet.algoexplorer.io/',
    'rpc': '',
  },
  'XTZ': {
    'api': 'https://api.nairobi.tzstats.com/',
    'browser': 'https://nairobi.tzstats.com/',
    'rpc': 'https://rpc.nairobi.tzstats.com/',
  },
  'XRP': {
    'api': '',
    'browser': 'https://testnet.xrpl.org/',
    'rpc': 'https://s.altnet.rippletest.net:51234/',
  },
  'ATOM': {
    'api': 'https://cosmos-lcd.quickapi.com/',
    'browser': 'https://atomscan.com/',
    'rpc': '',
  },
  'ZETA': {
    'api': '',
    'browser': 'https://explorer.zetachain.com/',
    'rpc': 'https://api.athens2.zetachain.com/evm',
  },
  'BASE': {'api': '', 'browser': '', 'rpc': ''},
  'FIL': {
    'api': '',
    'browser': 'https://calibration.filfox.info/',
    'rpc': 'https://api.calibration.node.glif.io/',
  },
  'DOT': {
    'api': 'https://westend.api.subscan.io/',
    'browser': 'https://westend.subscan.io/',
    'rpc': 'https://westend-rpc.polkadot.io',
  },
  'ACA': {
    'api': 'https://acala-testnet.api.subscan.io/',
    'browser': 'https://acala-testnet.subscan.io/',
    'rpc': 'https://acala-testnet.api.subscan.io',
  },
  'KSM': {
    'api': 'https://westend.api.subscan.io/',
    'browser': 'https://westend.subscan.io/',
    'rpc': 'https://westend-rpc.polkadot.io',
  },
  'APT': {
    'api': '',
    'browser': 'https://explorer.aptoslabs.com/',
    'rpc': 'https://fullnode.testnet.aptoslabs.com/v1/',
  },
  'SUI': {
    'api': '',
    'browser': 'https://suiscan.xyz/testnet/',
    'rpc': 'https://fullnode.testnet.sui.io:443',
  },
  'TON': {
    'api': 'https://testnet.explorer.tonapi.io/',
    'browser': 'https://testnet.tonscan.org/',
    'rpc': 'https://testnet.toncenter.com/api/v2/',
  },
  'S': {
    'api': 'https://api-testnet.sonicscan.org/api?', // 由 initializeApiKeys() 更新
    'browser': 'https://testnet.sonicscan.org/',
    'rpc': 'https://rpc.blaze.soniclabs.com/',
  },
  'BB': {
    'api': '',
    'browser': 'https://testnet.bbscan.io',
    'rpc': 'https://fullnode-testnet.bouncebitapi.com',
  },
  'XLM': {
    'api': 'https://horizon-testnet.stellar.org/',
    'browser': 'https://stellar.expert/explorer/testnet/',
    'rpc': 'https://horizon-testnet.stellar.org',
  },
  'VET': {
    'api': 'https://testnet.veblocks.net/',
    'browser': 'https://explore-testnet.vechain.org/',
    'rpc': 'https://testnet.veblocks.net',
  },
  'ONE': {
    'api': 'https://api.s0.b.hmny.io/',
    'browser': 'https://explorer.pops.one/',
    'rpc': 'https://api.s0.b.hmny.io',
  },
  'IOTX': {
    'api': 'https://api.testnet.iotex.one/',
    'browser': 'https://testnet.iotexscan.io/',
    'rpc': 'https://babel-api.testnet.iotex.io',
  },
  'NEAR': {
    'api': 'https://rpc.testnet.near.org/',
    'browser': 'https://explorer.testnet.near.org/',
    'rpc': 'https://rpc.testnet.near.org',
  },
  'ZIL': {
    'api': 'https://dev-api.zilliqa.com/',
    'browser': 'https://viewblock.io/zilliqa/',
    'rpc': 'https://dev-api.zilliqa.com',
  },
  'THETA': {
    'api': 'https://testnet-explorer.thetatoken.org:8443/api/',
    'browser': 'https://testnet-explorer.thetatoken.org/',
    'rpc': 'https://eth-rpc-api-testnet.thetatoken.org/rpc',
  },
  'ADA': {
    'api': 'https://cardano-preprod.blockfrost.io/api/v0/',
    'browser': 'https://preprod.cardanoscan.io/',
    'rpc': 'https://cardano-preprod.blockfrost.io/api/v0',
  },
  'EGLD': {
    'api': 'https://devnet-api.multiversx.com/',
    'browser': 'https://devnet-explorer.multiversx.com/',
    'rpc': 'https://devnet-gateway.multiversx.com',
  },
  'CFX': {
    'api': '',
    'browser': 'https://evmtestnet.confluxscan.io/',
    'rpc': 'https://evmtestnet.confluxrpc.com',
  },
  'NEON': {
    'api': '',
    'browser': 'https://devnet.neonscan.org/',
    'rpc': 'https://devnet.neonevm.org',
  },
  'ZEN': {
    'api': 'https://explorer-testnet.horizen.io/api/',
    'browser': 'https://explorer-testnet.horizen.io/',
    'rpc': '',
  },
};
