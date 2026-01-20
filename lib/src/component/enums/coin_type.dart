//主链币种类型
enum CoinType{
  BNB,
  ETH,
  N,
  MATIC,
  ETC,
  AVAX,
  HT,
  XDAI,
  CELO,
  FTM,
  SOL,//solana
  TRX,//tron
  CLO,
  POA,
  METIS,
  MOVE,
  VIC,
  TT,
  GO,
  WAN,
  CRO,
  KAVA,
  //BCH_E,
  KCS,
  BOBA,
  EVMOS,
  MOVR,
  GLMR,
  KLAY,
  MTR,
  OKT,
  OP,
  ARB,
  AURORA,
  ZETA,
  BASE,
  S,
  BB,
  //bitcoin比特币类型
  BTC,
  LTC,
  DOGE,
  DASH,
  VIA,
  DGB,
  MONA,
  //FIRO,
  BCH,
  BTG,
  RVN,
  //QTUM,
  //XEC,
  //Algorand
  ALGO,
  //Tezos
  XTZ,
  //Ripple
  XRP,
  //Cosmos
  ATOM,
  //Filecoin
  FIL,
  //Polkadot
  DOT,
  ACA,
  KSM,
  //Aptos
  APT,
  //Sui
  SUI,
  //TheOpenNetwork
  TON,
  //Stellar
  XLM,
  //VeChain
  VET,
  //Harmony
  ONE,
  //IoTeX
  IOTX,
  //NEAR Protocol
  NEAR,
  //Zilliqa
  ZIL,
  //Theta
  THETA,
  //Cardano
  ADA,
  //MultiversX (Elrond)
  EGLD,
  //Layer 2 chains
  ZKSYNC,  //zkSync Era
  LINEA,   //Linea
  SCROLL,  //Scroll
  MNT,     //Mantle
  BLAST,   //Blast
  //Additional L2/EVM chains
  MANTA,   //Manta Pacific
  MODE,    //Mode
  ZORA,    //Zora
  TAIKO,   //Taiko
  ZIRCUIT, //Zircuit
  ZKPOLYGON, //Polygon zkEVM
  OPBNB,   //opBNB
  FRAX,    //Fraxtal
  KROMA,   //Kroma
  LISK,    //Lisk
  BOB,     //BOB
  UNICHAIN,//Unichain
  INK,     //Ink
  METAL,   //Metal L2
  ZKFAIR,  //zkFair
  XLAYER,  //X Layer
  //Exchange chains
  GT,      //Gate Chain
  //Gaming/NFT chains
  RON,     //Ronin
  IMX,     //Immutable zkEVM
  APE,     //ApeChain
  BONE,    //Shibarium
  CHZ,     //Chiliz
  DOGECHAIN,//Dogechain
  WLD,     //World Chain
  //Bitcoin L2
  RBTC,    //Rootstock
  MERLIN,  //Merlin Chain
  BEVM,    //BEVM
  CORE,    //Core DAO
  BITLAYER,//Bitlayer
  //Other EVM chains
  CFX,     //Conflux eSpace
  TLOS,    //Telos
  ASTR,    //Astar
  SDN,     //Shiden
  BNC,     //Bifrost
  FSN,     //Fusion
  PALM,    //Palm
  EWT,     //Energy Web
  BRISE,   //Bitgert
  REEF,    //Reef
  BTT,     //BitTorrent Chain
  FX,      //Function X
  ISLM,    //Haqq Network
  DYM,     //Dymension
  PLUME,   //Plume
  NEON,    //Neon EVM
  SYS,     //Syscoin
  ELA,     //Elastos
  HEMI,    //Hemi
  HSK,     //HashKey
  CYBER,   //Cyber
  GRAVITY, //Gravity
  SWAN,    //Swan Chain
  MINT,    //Mint
  FUSE,    //Fuse
  CANTO,   //Canto
  ROSE,    //Oasis Emerald
  PLS,     //PulseChain
  FLR,     //Flare
  SGB,     //Songbird
  HBAR,    //Hedera
  BERA,    //Berachain
  SEI,     //Sei
  GNOSIS,  //Gnosis Chain
  NOVA,    //Arbitrum Nova
  //Additional chains batch 7
  ZKLINK,  //zkLink Nova
  REDSTONE,//Redstone
  ANCIENT8,//Ancient8
  STRATO,  //StratoVM
  SAAKURU, //Saakuru
  DFI,     //DeFiChain
  NUM,     //Numbers
  MILKOMEDA,//Milkomeda C1
  GOAT,    //GOAT Network
  BOBAETH, //BOB (Build on Bitcoin)
  EDU,     //Open Campus Codex
  KATANA,  //Katana
  TEMPO,   //Tempo
  BOBBNB,  //Boba BNB
  ZETA2    //Zeta Chain
}
//区块链类型
enum BlockchainType{
  Bitcoin,//比特币类型
  Ethereum,//以太坊类型
  Solana,
  Tron,
  Algorand,
  Tezos,
  Ripple,//若波
  Cosmos,
  Filecoin,
  Polkadot,
  Aptos,
  Sui,
  TheOpenNetwork,
  Stellar,//恒星
  VeChain,//唯链
  Harmony,//和谐链
  IoTeX,//物联网链
  Near,//NEAR协议
  Zilliqa,//Zilliqa
  Theta,//Theta网络
  Cardano,//卡尔达诺
  MultiversX//MultiversX (原Elrond)
}