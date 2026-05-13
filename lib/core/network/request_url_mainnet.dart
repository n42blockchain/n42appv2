part of 'request_url.dart';

/// Mainnet URL 配置 (私有，通过 RequestUrl.requestUrlMain1 访问)
final Map<String, Map<String, dynamic>> _requestUrlMain1 = {
  'BNB': {
    'api': 'https://api.bscscan.com/api?', // 由 initializeApiKeys() 更新
    'browser': 'https://bscscan.com/',
    'rpc': 'https://bsc-dataseed1.binance.org/',
  },
  'ETH': {
    'api': 'https://api.etherscan.io/api?', // 由 initializeApiKeys() 更新
    'browser': 'https://etherscan.io/',
    'rpc': 'https://mainnet.infura.io/v3/', // 由 initializeApiKeys() 更新
  },
  'MATIC': {
    'api': 'https://api.polygonscan.com/api?',
    'browser': 'https://polygonscan.com/',
    'rpc': 'https://polygon-rpc.com/',
  },
  'SOL': {
    'api': '',
    'browser': 'https://solscan.io/',
    'rpc': 'https://api.mainnet-beta.solana.com',
  },
  'TRX': {
    'api': 'https://api.trongrid.io',
    'browser': 'https://tronscan.org/#/',
    'rpc': 'https://api.trongrid.io',
  },
  'N': {
    'api': 'https://mainnet.n42.world/api?',
    'browser': 'https://mainnet.n42.world/',
    'rpc': 'https://rpc.n42.world',
  },
  'ETC': {
    'api': 'https://blockscout.com/etc/mainnet/api?',
    'browser': 'https://blockscout.com/etc/mainnet/',
    'rpc': 'https://www.ethercluster.com/etc/',
  },
  'AVAX': {
    'api': 'https://api.snowtrace.io/api?',
    'browser': 'https://snowtrace.io/',
    'rpc': 'https://api.avax.network/ext/bc/C/rpc/',
  },
  'HT': {
    'api': 'https://api.hecoinfo.com/api?',
    'browser': 'https://www.hecoinfo.com/',
    'rpc': 'https://http-mainnet.huobichain.com/',
  },
  'FTM': {
    'api': 'https://api.ftmscan.com/api?',
    'browser': 'https://ftmscan.com/',
    'rpc': 'https://rpc.ankr.com/fantom/',
  },
  'CELO': {
    'api': 'https://explorer.celo.org/api?',
    'browser': 'https://explorer.celo.org/',
    'rpc': 'https://forno.celo.org/',
  },
  'CLO': {
    'api': 'https://explorer.callisto.network/api?',
    'browser': 'https://explorer.callisto.network/',
    'rpc': 'https://clo-geth.0xinfra.com',
  },
  'POA': {
    'api': 'https://blockscout.com/poa/core/api?',
    'browser': 'https://blockscout.com/poa/core/',
    'rpc': 'https://core.poa.network',
  },
  'TOMO': {
    'api': '',
    'browser': 'https://tomoscan.io/',
    'rpc': 'https://rpc.tomochain.com',
  },
  'TT': {
    'api': 'https://explorer-mainnet.thundercore.com/api?',
    'browser': 'https://explorer-mainnet.thundercore.com/',
    'rpc': '',
  },
  'GO': {
    'api': '',
    'browser': 'https://explorer.gochain.io/',
    'rpc': 'https://rpc.gochain.io',
  },
  'WAN': {'api': '', 'browser': 'https://wanscan.org', 'rpc': ''},
  'CRO': {'api': '', 'browser': 'https://cronoscan.com/', 'rpc': 'https://evm.cronos.org'},
  'KAVA': {
    'api': '',
    'browser': 'https://www.mintscan.io/kava/',
    'rpc': '',
  },
  'KCS': {
    'api': 'https://explorer.kcc.io/api?',
    'browser': 'https://explorer.kcc.io/',
    'rpc': '',
  },
  'BOBA': {
    'api': '',
    'browser': 'https://bobascan.com/',
    'rpc': 'https://mainnet.boba.network',
  },
  'EVMOS': {
    'api': '',
    'browser': 'https://www.mintscan.io/evmos/',
    'rpc': '',
  },
  'MOVR': {
    'api': '',
    'browser': 'https://moonriver.subscan.io/',
    'rpc': '',
  },
  'GLMR': {
    'api': '',
    'browser': 'https://moonbase.subscan.io/',
    'rpc': '',
  },
  'KLAY': {'api': '', 'browser': 'https://scope.klaytn.com/', 'rpc': 'https://rpc.ankr.com/klaytn'},
  'MTR': {
    'api': '',
    'browser': 'https://scan.meter.io/',
    'rpc': 'https://rpc.meter.io',
  },
  'OKT': {
    'api': '',
    'browser': 'https://www.oklink.com/',
    'rpc': 'https://exchainrpc.okex.org/',
  },
  'OP': {
    'api': '',
    'browser': 'https://optimistic.etherscan.io/',
    'rpc': 'https://mainnet.optimism.io',
  },
  'ARB': {
    'api': '',
    'browser': 'https://arbiscan.io/',
    'rpc': 'https://arb1.arbitrum.io/rpc',
  },
  'LINEA': {
    'api': '',
    'browser': 'https://lineascan.build/',
    'rpc': 'https://rpc.linea.build',
  },
  'MNT': {
    'api': '',
    'browser': 'https://explorer.mantle.xyz/',
    'rpc': 'https://rpc.mantle.xyz',
  },
  'NOVA': {
    'api': '',
    'browser': 'https://nova.arbiscan.io/',
    'rpc': 'https://nova.arbitrum.io/rpc',
  },
  'SCROLL': {
    'api': '',
    'browser': 'https://scrollscan.com/',
    'rpc': 'https://rpc.scroll.io',
  },
  'ZKSYNC': {
    'api': '',
    'browser': 'https://explorer.zksync.io/',
    'rpc': 'https://mainnet.era.zksync.io',
  },
  'AURORA': {'api': '', 'browser': 'https://aurorascan.dev/', 'rpc': ''},
  'METIS': {
    'api': '',
    'browser': 'https://metis.tokenview.io/',
    'rpc': 'https://andromeda.metis.io/?owner=1088',
  },
  // BTC-like coins: rpc 由 initializeApiKeys() 从 RpcConfig 更新
  'BTC': {
    'api': 'https://blockstream.info/api/',
    'browser': 'https://www.blockchain.com/btc/',
    'rpc': '',
  },
  'LTC': {
    'api': 'https://api.blockcypher.com/v1/ltc/main',
    'browser': 'https://live.blockcypher.com/ltc/',
    'rpc': '',
  },
  'DOGE': {
    'api': 'https://api.blockcypher.com/v1/doge/main',
    'browser': 'https://dogechain.info/',
    'rpc': '',
  },
  'DASH': {
    'api': 'https://api.blockcypher.com/v1/dash/main',
    'browser': 'https://chainz.cryptoid.info/dash/',
    'rpc': '',
  },
  'VIA': {'api': '', 'browser': 'https://explorer.viacoin.org/', 'rpc': ''},
  'DGB': {'api': '', 'browser': 'https://digiexplorer.info/', 'rpc': ''},
  'MONA': {
    'api': '',
    'browser': 'https://blockbook.electrum-mona.org/',
    'rpc': '',
  },
  'FIRO': {'api': '', 'browser': 'https://explorer.firo.org/', 'rpc': ''},
  'BCH': {
    'api': '',
    'browser': 'https://www.blockchain.com/bch/',
    'rpc': '',
  },
  'BTG': {
    'api': '',
    'browser': 'https://explorer.bitcoingold.org/insight/',
    'rpc': '',
  },
  'RVN': {'api': '', 'browser': 'https://ravencoin.network/', 'rpc': ''},
  'QTUM': {'api': '', 'browser': 'https://qtum.info/', 'rpc': ''},
  'XEC': {
    'api': '',
    'browser': 'https://explorer.bitcoinabc.org/',
    'rpc': '',
  },
  'ALGO': {
    'api': 'https://node.algoexplorerapi.io/',
    'browser': 'https://algoexplorer.io/',
    'rpc': '',
  },
  'XTZ': {
    'api': 'https://api.tzstats.com/',
    'browser': 'https://tzstats.com/',
    'rpc': 'https://rpc.tzstats.com/',
  },
  'XRP': {
    'api': '',
    'browser': 'https://livenet.xrpl.org/',
    'rpc': 'https://s2.ripple.com:51234/',
  },
  'ATOM': {
    'api': 'https://rest.cosmos.directory/cosmoshub',
    'browser': 'https://atomscan.com/',
    'rpc': '',
  },
  'ZETA': {'api': '', 'browser': '', 'rpc': ''},
  'BASE': {
    'api': 'https://api.basescan.org/api?', // 由 initializeApiKeys() 更新
    'browser': 'https://basescan.org/',
    'rpc': 'https://mainnet.base.org',
  },
  'FIL': {
    'api': 'https://filfox.info/api/v1/',
    'browser': 'https://filfox.info/',
    'rpc': 'https://api.node.glif.io/',
  },
  'DOT': {
    'api': 'https://polkadot.api.subscan.io/',
    'browser': 'https://polkadot.subscan.io/',
    'rpc': 'https://rpc.polkadot.io',
  },
  'ACA': {
    'api': 'https://acala.api.subscan.io/',
    'browser': 'https://acala.subscan.io/',
    'rpc': 'https://acala-rpc.dwellir.com',
  },
  'KSM': {
    'api': 'https://kusama.api.subscan.io/',
    'browser': 'https://kusama.subscan.io/',
    'rpc': 'https://kusama-rpc.polkadot.io/',
  },
  'APT': {
    'api': '',
    'browser': 'https://explorer.aptoslabs.com/',
    'rpc': 'https://fullnode.mainnet.aptoslabs.com/v1/',
  },
  'SUI': {
    'api': '',
    'browser': 'https://suiscan.xyz/mainnet/',
    'rpc': 'https://fullnode.mainnet.sui.io:443',
  },
  'TON': {
    'api': 'https://explorer.tonapi.io/',
    'browser': 'https://tonscan.org/',
    'rpc': 'https://toncenter.com/api/v2/',
  },
  'S': {
    'api': 'https://api.sonicscan.org/api?', // 由 initializeApiKeys() 更新
    'browser': 'https://sonicscan.org/',
    'rpc': 'https://rpc.soniclabs.com/',
  },
  'BB': {
    'api': '',
    'browser': 'https://bbscan.io/',
    'rpc': 'https://fullnode-mainnet.bouncebitapi.com',
  },
  'XLM': {
    'api': 'https://horizon.stellar.org/',
    'browser': 'https://stellar.expert/explorer/public/',
    'rpc': 'https://horizon.stellar.org',
  },
  'VET': {
    'api': 'https://mainnet.veblocks.net/',
    'browser': 'https://explore.vechain.org/',
    'rpc': 'https://mainnet.veblocks.net',
  },
  'ONE': {
    'api': 'https://api.s0.t.hmny.io/',
    'browser': 'https://explorer.harmony.one/',
    'rpc': 'https://api.harmony.one',
  },
  'IOTX': {
    'api': 'https://api.iotex.one/',
    'browser': 'https://iotexscan.io/',
    'rpc': 'https://babel-api.mainnet.iotex.io',
  },
  'NEAR': {
    'api': 'https://rpc.mainnet.near.org/',
    'browser': 'https://explorer.near.org/',
    'rpc': 'https://rpc.mainnet.near.org',
  },
  'ZIL': {
    'api': 'https://api.zilliqa.com/',
    'browser': 'https://viewblock.io/zilliqa/',
    'rpc': 'https://api.zilliqa.com',
  },
  'THETA': {
    'api': 'https://explorer.thetatoken.org:8443/api/',
    'browser': 'https://explorer.thetatoken.org/',
    'rpc': 'https://eth-rpc-api.thetatoken.org/rpc',
  },
  'ADA': {
    'api': 'https://cardano-mainnet.blockfrost.io/api/v0/',
    'browser': 'https://cardanoscan.io/',
    'rpc': 'https://cardano-mainnet.blockfrost.io/api/v0',
  },
  'EGLD': {
    'api': 'https://api.multiversx.com/',
    'browser': 'https://explorer.multiversx.com/',
    'rpc': 'https://gateway.multiversx.com',
  },
  'CFX': {
    'api': '',
    'browser': 'https://evm.confluxscan.io/',
    'rpc': 'https://evm.confluxrpc.com',
  },
  'NEON': {
    'api': '',
    'browser': 'https://neonscan.org/',
    'rpc': 'https://neon-proxy-mainnet.solana.p2p.org',
  },
  'ZEN': {
    'api': 'https://explorer.horizen.io/api/',
    'browser': 'https://explorer.horizen.io/',
    'rpc': '',
  },
};
