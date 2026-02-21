package handlers

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
	"sync"
	"time"

	"github.com/gin-gonic/gin"

	"github.com/n42/n42appv2/backend/swap/models"
)

// ─── 外部 Token List 缓存 ─────────────────────────────────────────────────────

var (
	tokenCache     = map[string][]models.TokenInfo{}
	tokenCacheMu   sync.RWMutex
	tokenCacheTime = map[string]time.Time{}
	cacheTTL       = 30 * time.Minute
	httpClient     = &http.Client{Timeout: 10 * time.Second}
)

// ─── 内置精选代币（主流钱包常见交易对）────────────────────────────────────────
// 参考：Uniswap Default List / 1inch / MetaMask / CoinGecko Top-100
// 仅作 fallback；生产优先从外部 Token List API 获取完整列表

var popularTokens = map[string][]models.TokenInfo{
	// ════════════════════════════════════════════════
	// Ethereum Mainnet（chainId=1）
	// 覆盖：稳定币、主流 DeFi、LST、RWA、Meme
	// ════════════════════════════════════════════════
	"ETH": {
		// ── Native wrapper ──
		{Address: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2", Symbol: "WETH", Name: "Wrapped Ether", Decimals: 18, Chain: "ETH", LogoURI: "https://assets.coingecko.com/coins/images/2518/small/weth.png"},
		// ── Stablecoins ──
		{Address: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48", Symbol: "USDC", Name: "USD Coin", Decimals: 6, Chain: "ETH", LogoURI: "https://assets.coingecko.com/coins/images/6319/small/usdc.png"},
		{Address: "0xdAC17F958D2ee523a2206206994597C13D831ec7", Symbol: "USDT", Name: "Tether USD", Decimals: 6, Chain: "ETH", LogoURI: "https://assets.coingecko.com/coins/images/325/small/Tether.png"},
		{Address: "0x6B175474E89094C44Da98b954EedeAC495271d0F", Symbol: "DAI", Name: "Dai Stablecoin", Decimals: 18, Chain: "ETH", LogoURI: "https://assets.coingecko.com/coins/images/9956/small/Badge_Dai.png"},
		{Address: "0x853d955aCEf822Db058eb8505911ED77F175b99e", Symbol: "FRAX", Name: "Frax", Decimals: 18, Chain: "ETH", LogoURI: "https://assets.coingecko.com/coins/images/13422/small/frax_logo.png"},
		{Address: "0x4c9EDD5852cd905f086C759E8383e09bff1E68B3", Symbol: "USDE", Name: "USDe (Ethena)", Decimals: 18, Chain: "ETH", LogoURI: "https://assets.coingecko.com/coins/images/33613/small/usde.png"},
		{Address: "0x0000000000085d4780B73119b644AE5ecd22b376", Symbol: "TUSD", Name: "TrueUSD", Decimals: 18, Chain: "ETH", LogoURI: "https://assets.coingecko.com/coins/images/3449/small/tusd.png"},
		// ── BTC-pegged ──
		{Address: "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599", Symbol: "WBTC", Name: "Wrapped Bitcoin", Decimals: 8, Chain: "ETH", LogoURI: "https://assets.coingecko.com/coins/images/7598/small/wrapped_bitcoin_wbtc.png"},
		{Address: "0x18084fbA666a33d37592fA2633fD49a74DD93a88", Symbol: "tBTC", Name: "tBTC v2", Decimals: 18, Chain: "ETH", LogoURI: "https://assets.coingecko.com/coins/images/11224/small/0x18084fbA666a33d37592fA2633fD49a74DD93a88.png"},
		{Address: "0xfE18be6b3Bd88A2D2A7f928d00292E7a9963CfC6", Symbol: "sBTC", Name: "Synth sBTC", Decimals: 18, Chain: "ETH", LogoURI: ""},
		// ── LST (Liquid Staking) ──
		{Address: "0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84", Symbol: "stETH", Name: "Lido Staked ETH", Decimals: 18, Chain: "ETH", LogoURI: "https://assets.coingecko.com/coins/images/13442/small/steth_logo.png"},
		{Address: "0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0", Symbol: "wstETH", Name: "Wrapped stETH", Decimals: 18, Chain: "ETH", LogoURI: "https://assets.coingecko.com/coins/images/18834/small/wstETH.png"},
		{Address: "0xae78736Cd615f374D3085123A210448E74Fc6393", Symbol: "rETH", Name: "Rocket Pool ETH", Decimals: 18, Chain: "ETH", LogoURI: "https://assets.coingecko.com/coins/images/20764/small/reth.png"},
		{Address: "0xA35b1B31Ce002FBF2058D22F30f95D405200A15b", Symbol: "ETHx", Name: "Stader ETHx", Decimals: 18, Chain: "ETH", LogoURI: ""},
		{Address: "0xf1C9acDc66974dFB6dEcB12aA385b9cD01190E38", Symbol: "osETH", Name: "StakeWise Vaulted ETH", Decimals: 18, Chain: "ETH", LogoURI: ""},
		// ── DeFi Blue-chips ──
		{Address: "0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984", Symbol: "UNI", Name: "Uniswap", Decimals: 18, Chain: "ETH", LogoURI: "https://assets.coingecko.com/coins/images/12504/small/uniswap-uni.png"},
		{Address: "0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9", Symbol: "AAVE", Name: "Aave", Decimals: 18, Chain: "ETH", LogoURI: "https://assets.coingecko.com/coins/images/12645/small/AAVE.png"},
		{Address: "0xD533a949740bb3306d119CC777fa900bA034cd52", Symbol: "CRV", Name: "Curve DAO Token", Decimals: 18, Chain: "ETH", LogoURI: "https://assets.coingecko.com/coins/images/12124/small/Curve.png"},
		{Address: "0xc00e94Cb662C3520282E6f5717214004A7f26888", Symbol: "COMP", Name: "Compound", Decimals: 18, Chain: "ETH", LogoURI: "https://assets.coingecko.com/coins/images/10775/small/COMP.png"},
		{Address: "0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2", Symbol: "MKR", Name: "Maker", Decimals: 18, Chain: "ETH", LogoURI: "https://assets.coingecko.com/coins/images/1364/small/Mark_Maker.png"},
		{Address: "0xba100000625a3754423978a60c9317c58a424e3D", Symbol: "BAL", Name: "Balancer", Decimals: 18, Chain: "ETH", LogoURI: "https://assets.coingecko.com/coins/images/11683/small/Balancer.png"},
		{Address: "0x6810e776880C02933D47DB1b9fc05908e5386b96", Symbol: "GNO", Name: "Gnosis Token", Decimals: 18, Chain: "ETH", LogoURI: "https://assets.coingecko.com/coins/images/662/small/logo_square_simple_300px.png"},
		{Address: "0xC011a73ee8576Fb46F5E1c5751cA3B9Fe0af2a6F", Symbol: "SNX", Name: "Synthetix Network Token", Decimals: 18, Chain: "ETH", LogoURI: "https://assets.coingecko.com/coins/images/3406/small/SNX.png"},
		{Address: "0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e", Symbol: "YFI", Name: "yearn.finance", Decimals: 18, Chain: "ETH", LogoURI: "https://assets.coingecko.com/coins/images/11849/small/yfi-192x192.png"},
		// ── Infrastructure ──
		{Address: "0x514910771AF9Ca656af840dff83E8264EcF986CA", Symbol: "LINK", Name: "ChainLink Token", Decimals: 18, Chain: "ETH", LogoURI: "https://assets.coingecko.com/coins/images/877/small/chainlink-new-logo.png"},
		{Address: "0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0", Symbol: "MATIC", Name: "Polygon", Decimals: 18, Chain: "ETH", LogoURI: "https://assets.coingecko.com/coins/images/4713/small/matic-token-icon.png"},
		{Address: "0x4d224452801ACEd8B2F0aebE155379bb5D594381", Symbol: "APE", Name: "ApeCoin", Decimals: 18, Chain: "ETH", LogoURI: "https://assets.coingecko.com/coins/images/24383/small/apecoin.jpg"},
		{Address: "0x0F5D2fB29fb7d3CFeE444a200298f468908cC942", Symbol: "MANA", Name: "Decentraland", Decimals: 18, Chain: "ETH", LogoURI: "https://assets.coingecko.com/coins/images/878/small/decentraland-mana.png"},
		{Address: "0x6f259637dcD74C767781E37Bc6133cd6A68aa161", Symbol: "HT", Name: "Huobi Token", Decimals: 18, Chain: "ETH", LogoURI: ""},
		// ── Meme ──
		{Address: "0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE", Symbol: "SHIB", Name: "Shiba Inu", Decimals: 18, Chain: "ETH", LogoURI: "https://assets.coingecko.com/coins/images/11939/small/shiba.png"},
		{Address: "0x6982508145454Ce325dDbE47a25d4ec3d2311933", Symbol: "PEPE", Name: "Pepe", Decimals: 18, Chain: "ETH", LogoURI: "https://assets.coingecko.com/coins/images/29850/small/pepe-token.jpeg"},
		{Address: "0x163f8C2467924be0ae7B5347228CABF260318753", Symbol: "WLD", Name: "Worldcoin", Decimals: 18, Chain: "ETH", LogoURI: "https://assets.coingecko.com/coins/images/31069/small/worldcoin.jpeg"},
	},

	// ════════════════════════════════════════════════
	// BNB Smart Chain (BSC, chainId=56)
	// ════════════════════════════════════════════════
	"BSC": {
		{Address: "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c", Symbol: "WBNB", Name: "Wrapped BNB", Decimals: 18, Chain: "BSC", LogoURI: "https://assets.coingecko.com/coins/images/825/small/bnb-icon2_2x.png"},
		{Address: "0x55d398326f99059fF775485246999027B3197955", Symbol: "USDT", Name: "Tether USD (BSC)", Decimals: 18, Chain: "BSC", LogoURI: "https://assets.coingecko.com/coins/images/325/small/Tether.png"},
		{Address: "0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d", Symbol: "USDC", Name: "USD Coin (BSC)", Decimals: 18, Chain: "BSC", LogoURI: "https://assets.coingecko.com/coins/images/6319/small/usdc.png"},
		{Address: "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56", Symbol: "BUSD", Name: "Binance USD", Decimals: 18, Chain: "BSC", LogoURI: "https://assets.coingecko.com/coins/images/9576/small/BUSD.png"},
		{Address: "0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3", Symbol: "DAI", Name: "Dai Token (BSC)", Decimals: 18, Chain: "BSC", LogoURI: "https://assets.coingecko.com/coins/images/9956/small/Badge_Dai.png"},
		{Address: "0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c", Symbol: "BTCB", Name: "BTCB Token", Decimals: 18, Chain: "BSC", LogoURI: "https://assets.coingecko.com/coins/images/14108/small/Binance-bitcoin.png"},
		{Address: "0x2170Ed0880ac9A755fd29B2688956BD959F933F8", Symbol: "ETH", Name: "Ethereum Token (BSC)", Decimals: 18, Chain: "BSC", LogoURI: "https://assets.coingecko.com/coins/images/279/small/ethereum.png"},
		{Address: "0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82", Symbol: "CAKE", Name: "PancakeSwap Token", Decimals: 18, Chain: "BSC", LogoURI: "https://assets.coingecko.com/coins/images/12632/small/pancakeswap-cake-logo.png"},
		{Address: "0xCC42724C6683B7E57334c4E856f4c9965ED682bD", Symbol: "MATIC", Name: "Matic Token (BSC)", Decimals: 18, Chain: "BSC", LogoURI: "https://assets.coingecko.com/coins/images/4713/small/matic-token-icon.png"},
		{Address: "0xbA2aE424d960c26247Dd6c32edC70B295c744C43", Symbol: "DOGE", Name: "Dogecoin Token (BSC)", Decimals: 8, Chain: "BSC", LogoURI: "https://assets.coingecko.com/coins/images/5/small/dogecoin.png"},
		{Address: "0x8fF795a6F4D97E7887C79beA79aba5cc76444aDf", Symbol: "BCH", Name: "Bitcoin Cash Token (BSC)", Decimals: 18, Chain: "BSC", LogoURI: ""},
		{Address: "0x4338665CBB7B2485A8855A139b75D5e34AB0DB94", Symbol: "LTC", Name: "Litecoin Token (BSC)", Decimals: 18, Chain: "BSC", LogoURI: ""},
		{Address: "0xF8A0BF9cF54Bb92F17374d9e9A321E6a111a51bD", Symbol: "LINK", Name: "ChainLink Token (BSC)", Decimals: 18, Chain: "BSC", LogoURI: "https://assets.coingecko.com/coins/images/877/small/chainlink-new-logo.png"},
		{Address: "0x1D2F0da169ceB9fC7B3144628dB156f3F6c60dBE", Symbol: "XRP", Name: "XRP Token (BSC)", Decimals: 18, Chain: "BSC", LogoURI: "https://assets.coingecko.com/coins/images/44/small/xrp-symbol-white-128.png"},
		{Address: "0x8595F9dA7b868b1822194fAEd312235E43007b49", Symbol: "BFT", Name: "BnkToTheFuture", Decimals: 18, Chain: "BSC", LogoURI: ""},
		{Address: "0x111111111117dC0aa78b770fA6A738034120C302", Symbol: "1INCH", Name: "1INCH Token (BSC)", Decimals: 18, Chain: "BSC", LogoURI: "https://assets.coingecko.com/coins/images/13469/small/1inch-token.png"},
	},

	// ════════════════════════════════════════════════
	// Polygon (MATIC, chainId=137)
	// ════════════════════════════════════════════════
	"POLYGON": {
		{Address: "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270", Symbol: "WMATIC", Name: "Wrapped Matic", Decimals: 18, Chain: "POLYGON", LogoURI: "https://assets.coingecko.com/coins/images/4713/small/matic-token-icon.png"},
		{Address: "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174", Symbol: "USDC.e", Name: "USD Coin (PoS)", Decimals: 6, Chain: "POLYGON", LogoURI: "https://assets.coingecko.com/coins/images/6319/small/usdc.png"},
		{Address: "0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359", Symbol: "USDC", Name: "USD Coin (Native)", Decimals: 6, Chain: "POLYGON", LogoURI: "https://assets.coingecko.com/coins/images/6319/small/usdc.png"},
		{Address: "0xc2132D05D31c914a87C6611C10748AEb04B58e8F", Symbol: "USDT", Name: "Tether USD (PoS)", Decimals: 6, Chain: "POLYGON", LogoURI: "https://assets.coingecko.com/coins/images/325/small/Tether.png"},
		{Address: "0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063", Symbol: "DAI", Name: "Dai Stablecoin (PoS)", Decimals: 18, Chain: "POLYGON", LogoURI: "https://assets.coingecko.com/coins/images/9956/small/Badge_Dai.png"},
		{Address: "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619", Symbol: "WETH", Name: "Wrapped Ether (PoS)", Decimals: 18, Chain: "POLYGON", LogoURI: "https://assets.coingecko.com/coins/images/2518/small/weth.png"},
		{Address: "0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6", Symbol: "WBTC", Name: "Wrapped Bitcoin (PoS)", Decimals: 8, Chain: "POLYGON", LogoURI: "https://assets.coingecko.com/coins/images/7598/small/wrapped_bitcoin_wbtc.png"},
		{Address: "0xD6DF932A45C0f255f85145f286eA0b292B21C90B", Symbol: "AAVE", Name: "Aave (PoS)", Decimals: 18, Chain: "POLYGON", LogoURI: "https://assets.coingecko.com/coins/images/12645/small/AAVE.png"},
		{Address: "0x53E0bca35eC356BD5ddDFebbD1Fc0fD03FaBad39", Symbol: "LINK", Name: "ChainLink Token (PoS)", Decimals: 18, Chain: "POLYGON", LogoURI: "https://assets.coingecko.com/coins/images/877/small/chainlink-new-logo.png"},
		{Address: "0x172370d5Cd63279eFa6d502DAB29171933a610AF", Symbol: "CRV", Name: "CRV (PoS)", Decimals: 18, Chain: "POLYGON", LogoURI: "https://assets.coingecko.com/coins/images/12124/small/Curve.png"},
		{Address: "0xb33EaAd8d922B1083446DC23f610c2567fB5180f", Symbol: "UNI", Name: "Uniswap (PoS)", Decimals: 18, Chain: "POLYGON", LogoURI: "https://assets.coingecko.com/coins/images/12504/small/uniswap-uni.png"},
		{Address: "0x9a71012B13CA4d3D0Cdc72A177df3ef03b0E76A3", Symbol: "BAL", Name: "Balancer (PoS)", Decimals: 18, Chain: "POLYGON", LogoURI: "https://assets.coingecko.com/coins/images/11683/small/Balancer.png"},
		{Address: "0x2C89bbc92BD86F8075d1DEcc58C7F4E0107f286b", Symbol: "AVAX", Name: "Avalanche Token (PoS)", Decimals: 18, Chain: "POLYGON", LogoURI: "https://assets.coingecko.com/coins/images/12559/small/Avalanche_Circle_RedWhite_Trans.png"},
		{Address: "0x03b54A6e9a984069379fae1a4fC4dBAE93B3bCCD", Symbol: "wstETH", Name: "Wrapped stETH (PoS)", Decimals: 18, Chain: "POLYGON", LogoURI: "https://assets.coingecko.com/coins/images/18834/small/wstETH.png"},
		{Address: "0x45c32fA6DF82ead1e2EF74d17b76547EDdFaFF89", Symbol: "FRAX", Name: "Frax (PoS)", Decimals: 18, Chain: "POLYGON", LogoURI: "https://assets.coingecko.com/coins/images/13422/small/frax_logo.png"},
	},

	// ════════════════════════════════════════════════
	// Arbitrum One (chainId=42161)
	// ════════════════════════════════════════════════
	"ARB": {
		{Address: "0x82aF49447D8a07e3bd95BD0d56f35241523fBab1", Symbol: "WETH", Name: "Wrapped Ether (ARB)", Decimals: 18, Chain: "ARB", LogoURI: "https://assets.coingecko.com/coins/images/2518/small/weth.png"},
		{Address: "0xaf88d065e77c8cC2239327C5EDb3A432268e5831", Symbol: "USDC", Name: "USD Coin (Arbitrum)", Decimals: 6, Chain: "ARB", LogoURI: "https://assets.coingecko.com/coins/images/6319/small/usdc.png"},
		{Address: "0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8", Symbol: "USDC.e", Name: "Bridged USD Coin (ARB)", Decimals: 6, Chain: "ARB", LogoURI: "https://assets.coingecko.com/coins/images/6319/small/usdc.png"},
		{Address: "0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9", Symbol: "USDT", Name: "Tether USD (ARB)", Decimals: 6, Chain: "ARB", LogoURI: "https://assets.coingecko.com/coins/images/325/small/Tether.png"},
		{Address: "0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1", Symbol: "DAI", Name: "Dai Stablecoin (ARB)", Decimals: 18, Chain: "ARB", LogoURI: "https://assets.coingecko.com/coins/images/9956/small/Badge_Dai.png"},
		{Address: "0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f", Symbol: "WBTC", Name: "Wrapped Bitcoin (ARB)", Decimals: 8, Chain: "ARB", LogoURI: "https://assets.coingecko.com/coins/images/7598/small/wrapped_bitcoin_wbtc.png"},
		{Address: "0x912CE59144191C1204E64559FE8253a0e49E6548", Symbol: "ARB", Name: "Arbitrum", Decimals: 18, Chain: "ARB", LogoURI: "https://assets.coingecko.com/coins/images/16547/small/photo_2023-03-29_21.47.00.jpeg"},
		{Address: "0xfc5A1A6EB076a2C7aD06eD22C90d7E710E35ad0a", Symbol: "GMX", Name: "GMX", Decimals: 18, Chain: "ARB", LogoURI: "https://assets.coingecko.com/coins/images/18323/small/arbit.png"},
		{Address: "0x13Ad51ed4F1B7e9Dc168d8a00cB3f4dDD85EfA60", Symbol: "LDO", Name: "Lido DAO (ARB)", Decimals: 18, Chain: "ARB", LogoURI: "https://assets.coingecko.com/coins/images/13573/small/Lido_DAO.png"},
		{Address: "0x5979D7b546E38E414F7E9822514be443A4800529", Symbol: "wstETH", Name: "Wrapped stETH (ARB)", Decimals: 18, Chain: "ARB", LogoURI: "https://assets.coingecko.com/coins/images/18834/small/wstETH.png"},
		{Address: "0x17FC002b466eEc40DaE837Fc4bE5c67993ddBd6F", Symbol: "FRAX", Name: "Frax (ARB)", Decimals: 18, Chain: "ARB", LogoURI: "https://assets.coingecko.com/coins/images/13422/small/frax_logo.png"},
		{Address: "0xf97f4df75117a78c1A5a0DBb814Af92458539FB4", Symbol: "LINK", Name: "ChainLink Token (ARB)", Decimals: 18, Chain: "ARB", LogoURI: "https://assets.coingecko.com/coins/images/877/small/chainlink-new-logo.png"},
		{Address: "0xFa7F8980b0f1E64A2062791cc3b0871572f1F7f0", Symbol: "UNI", Name: "Uniswap (ARB)", Decimals: 18, Chain: "ARB", LogoURI: "https://assets.coingecko.com/coins/images/12504/small/uniswap-uni.png"},
		{Address: "0xba5DdD1f9d7F570dc94a51479a000E3BCE967196", Symbol: "AAVE", Name: "Aave Token (ARB)", Decimals: 18, Chain: "ARB", LogoURI: "https://assets.coingecko.com/coins/images/12645/small/AAVE.png"},
		{Address: "0x4e352cF164E64ADCBad318C3a1e222E9EBa4Ce42", Symbol: "MCB", Name: "MUX Protocol (ARB)", Decimals: 18, Chain: "ARB", LogoURI: ""},
		{Address: "0xEC70Dcb4A1EFa46b8F2D97C310C9c4790ba5ffA8", Symbol: "rETH", Name: "Rocket Pool ETH (ARB)", Decimals: 18, Chain: "ARB", LogoURI: "https://assets.coingecko.com/coins/images/20764/small/reth.png"},
	},

	// ════════════════════════════════════════════════
	// Optimism (chainId=10)
	// ════════════════════════════════════════════════
	"OP": {
		{Address: "0x4200000000000000000000000000000000000006", Symbol: "WETH", Name: "Wrapped Ether (OP)", Decimals: 18, Chain: "OP", LogoURI: "https://assets.coingecko.com/coins/images/2518/small/weth.png"},
		{Address: "0x7F5c764cBc14f9669B88837ca1490cCa17c31607", Symbol: "USDC.e", Name: "USD Coin (OP Bridged)", Decimals: 6, Chain: "OP", LogoURI: "https://assets.coingecko.com/coins/images/6319/small/usdc.png"},
		{Address: "0x0b2C639c533813f4Aa9D7837CAf62653d097Ff85", Symbol: "USDC", Name: "USD Coin (OP Native)", Decimals: 6, Chain: "OP", LogoURI: "https://assets.coingecko.com/coins/images/6319/small/usdc.png"},
		{Address: "0x94b008aA00579c1307B0EF2c499aD98a8ce58e58", Symbol: "USDT", Name: "Tether USD (OP)", Decimals: 6, Chain: "OP", LogoURI: "https://assets.coingecko.com/coins/images/325/small/Tether.png"},
		{Address: "0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1", Symbol: "DAI", Name: "Dai Stablecoin (OP)", Decimals: 18, Chain: "OP", LogoURI: "https://assets.coingecko.com/coins/images/9956/small/Badge_Dai.png"},
		{Address: "0x68f180fcCe6836688e9084f035309E29Bf0A2095", Symbol: "WBTC", Name: "Wrapped Bitcoin (OP)", Decimals: 8, Chain: "OP", LogoURI: "https://assets.coingecko.com/coins/images/7598/small/wrapped_bitcoin_wbtc.png"},
		{Address: "0x4200000000000000000000000000000000000042", Symbol: "OP", Name: "Optimism", Decimals: 18, Chain: "OP", LogoURI: "https://assets.coingecko.com/coins/images/25244/small/Optimism.png"},
		{Address: "0x1F32b1c2345538c0c6f582fCB022739c4A194Ebb", Symbol: "wstETH", Name: "Wrapped stETH (OP)", Decimals: 18, Chain: "OP", LogoURI: "https://assets.coingecko.com/coins/images/18834/small/wstETH.png"},
		{Address: "0x9Bcef72be871e61ED4fBbc7630889beE758eb81D", Symbol: "rETH", Name: "Rocket Pool ETH (OP)", Decimals: 18, Chain: "OP", LogoURI: "https://assets.coingecko.com/coins/images/20764/small/reth.png"},
		{Address: "0xdFA46478F9e5EA86d57387849598dbFB2e964b02", Symbol: "MAI", Name: "Mai Stablecoin (OP)", Decimals: 18, Chain: "OP", LogoURI: ""},
		{Address: "0x350a791Bfc2C21F9Ed5d10980Dad2e2638ffa7f6", Symbol: "LINK", Name: "ChainLink Token (OP)", Decimals: 18, Chain: "OP", LogoURI: "https://assets.coingecko.com/coins/images/877/small/chainlink-new-logo.png"},
		{Address: "0x6fd9d7AD17242c41f7131d257212c54A0e816691", Symbol: "UNI", Name: "Uniswap (OP)", Decimals: 18, Chain: "OP", LogoURI: "https://assets.coingecko.com/coins/images/12504/small/uniswap-uni.png"},
		{Address: "0x76FB31fb4af56892A25e32cFC43De717950c9278", Symbol: "AAVE", Name: "Aave (OP)", Decimals: 18, Chain: "OP", LogoURI: "https://assets.coingecko.com/coins/images/12645/small/AAVE.png"},
		{Address: "0x2E3D870790dC77A83DD1d18184Acc7439A53f475", Symbol: "FRAX", Name: "Frax (OP)", Decimals: 18, Chain: "OP", LogoURI: "https://assets.coingecko.com/coins/images/13422/small/frax_logo.png"},
		{Address: "0x8700dAec35aF8Ff88c16BdF0418774CB3D7599B4", Symbol: "SNX", Name: "Synthetix (OP)", Decimals: 18, Chain: "OP", LogoURI: "https://assets.coingecko.com/coins/images/3406/small/SNX.png"},
	},

	// ════════════════════════════════════════════════
	// Solana（Jupiter 支持的高流动性代币）
	// ════════════════════════════════════════════════
	"SOL": {
		{Address: "So11111111111111111111111111111111111111112", Symbol: "SOL", Name: "Wrapped SOL", Decimals: 9, Chain: "SOL", LogoURI: "https://assets.coingecko.com/coins/images/4128/small/solana.png"},
		{Address: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v", Symbol: "USDC", Name: "USD Coin (Solana)", Decimals: 6, Chain: "SOL", LogoURI: "https://assets.coingecko.com/coins/images/6319/small/usdc.png"},
		{Address: "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB", Symbol: "USDT", Name: "Tether USD (Solana)", Decimals: 6, Chain: "SOL", LogoURI: "https://assets.coingecko.com/coins/images/325/small/Tether.png"},
		{Address: "7vfCXTUXx5WJV5JADk17DUJ4ksgau7utNKj4b963voxs", Symbol: "WETH", Name: "Wrapped Ether (Wormhole)", Decimals: 8, Chain: "SOL", LogoURI: "https://assets.coingecko.com/coins/images/2518/small/weth.png"},
		{Address: "9n4nbM75f5Ui33ZbPYXn59EwSgE8CGsHtAeTH5YFeJ9E", Symbol: "WBTC", Name: "Wrapped Bitcoin (Wormhole)", Decimals: 8, Chain: "SOL", LogoURI: "https://assets.coingecko.com/coins/images/7598/small/wrapped_bitcoin_wbtc.png"},
		{Address: "JUPyiwrYJFskUPiHa7hkeR8VUtAeFoSYbKedZNsDvCN", Symbol: "JUP", Name: "Jupiter", Decimals: 6, Chain: "SOL", LogoURI: "https://assets.coingecko.com/coins/images/34188/small/jup.png"},
		{Address: "4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R", Symbol: "RAY", Name: "Raydium", Decimals: 6, Chain: "SOL", LogoURI: "https://assets.coingecko.com/coins/images/13928/small/PSigc4ie_400x400.jpg"},
		{Address: "7i5KKsX2weiTkry7jA4ZwSuXGhs5eJBEjY8vVxR4pfRx", Symbol: "GMT", Name: "STEPN (Solana)", Decimals: 9, Chain: "SOL", LogoURI: "https://assets.coingecko.com/coins/images/23597/small/gmt.png"},
		{Address: "EchesyfXePKdLtoiZSL8pBe8Myagyy8ZRqsACNCFGnvp", Symbol: "FIDA", Name: "Bonfida", Decimals: 6, Chain: "SOL", LogoURI: "https://assets.coingecko.com/coins/images/13395/small/bonfida.png"},
		{Address: "DezXAZ8z7PnrnRJjz3wXBoRgixCa6xjnB7YaB1pPB263", Symbol: "BONK", Name: "Bonk", Decimals: 5, Chain: "SOL", LogoURI: "https://assets.coingecko.com/coins/images/28600/small/bonk.jpg"},
		{Address: "EKpQGSJtjMFqKZ9KQanSqYXRcF8fBopzLHYxdM65zcjm", Symbol: "WIF", Name: "dogwifhat", Decimals: 6, Chain: "SOL", LogoURI: "https://assets.coingecko.com/coins/images/33566/small/wif.png"},
		{Address: "27G8MtK7VtTcCHkpASjSDdkWWYfoqT6ggEuKidVJidD4", Symbol: "JLP", Name: "Jupiter Perps LP", Decimals: 6, Chain: "SOL", LogoURI: ""},
		{Address: "mSoLzYCxHdYgdzU16g5QSh3i5K3z3KZK7ytfqcJm7So", Symbol: "mSOL", Name: "Marinade staked SOL", Decimals: 9, Chain: "SOL", LogoURI: "https://assets.coingecko.com/coins/images/17752/small/mSOL.png"},
		{Address: "7dHbWXmci3dT8UFYWYZweBLXgycu7Y3iL6trKn1Y7ARj", Symbol: "stSOL", Name: "Lido Staked SOL", Decimals: 9, Chain: "SOL", LogoURI: ""},
		{Address: "HZ1JovNiVvGrGNiiYvEozEVgZ58xaU3RKwX8eACQBCt3", Symbol: "PYTH", Name: "Pyth Network", Decimals: 6, Chain: "SOL", LogoURI: "https://assets.coingecko.com/coins/images/31924/small/pyth.png"},
		{Address: "WENWENvqqNya429ubCdR81ZmD69brwQaaBYY6p3LCpk", Symbol: "WEN", Name: "Wen", Decimals: 5, Chain: "SOL", LogoURI: ""},
	},
}

// ─── 外部 Token List 集成 ─────────────────────────────────────────────────────

// uniswapTokenListURL Uniswap 官方 Default Token List（EVM 链通用）
const uniswapTokenListURL = "https://tokens.uniswap.org"

// jupiterTokenListURL Jupiter 推荐 Token List（Solana）
const jupiterTokenListURL = "https://token.jup.ag/strict"

// uniswapChainID EVM 链 → chainId
var uniswapChainID = map[string]int{
	"ETH":     1,
	"BSC":     56,
	"POLYGON": 137,
	"ARB":     42161,
	"OP":      10,
}

// fetchUniswapTokenList 从 Uniswap Token List 获取代币列表
func fetchUniswapTokenList(ctx context.Context, chain string) ([]models.TokenInfo, error) {
	chainID, ok := uniswapChainID[chain]
	if !ok {
		return nil, fmt.Errorf("no chainId for %s", chain)
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, uniswapTokenListURL, nil)
	if err != nil {
		return nil, err
	}
	resp, err := httpClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	var tl struct {
		Tokens []struct {
			ChainID  int    `json:"chainId"`
			Address  string `json:"address"`
			Symbol   string `json:"symbol"`
			Name     string `json:"name"`
			Decimals int    `json:"decimals"`
			LogoURI  string `json:"logoURI"`
		} `json:"tokens"`
	}
	if err = json.NewDecoder(resp.Body).Decode(&tl); err != nil {
		return nil, err
	}

	var result []models.TokenInfo
	for _, t := range tl.Tokens {
		if t.ChainID != chainID {
			continue
		}
		result = append(result, models.TokenInfo{
			Address:  t.Address,
			Symbol:   t.Symbol,
			Name:     t.Name,
			Decimals: t.Decimals,
			Chain:    chain,
			LogoURI:  t.LogoURI,
		})
	}
	return result, nil
}

// fetchJupiterTokenList 从 Jupiter Token List 获取 Solana 代币列表
func fetchJupiterTokenList(ctx context.Context) ([]models.TokenInfo, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, jupiterTokenListURL, nil)
	if err != nil {
		return nil, err
	}
	resp, err := httpClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	var tokens []struct {
		Address  string `json:"address"`
		Symbol   string `json:"symbol"`
		Name     string `json:"name"`
		Decimals int    `json:"decimals"`
		LogoURI  string `json:"logoURI"`
	}
	if err = json.NewDecoder(resp.Body).Decode(&tokens); err != nil {
		return nil, err
	}

	result := make([]models.TokenInfo, 0, len(tokens))
	for _, t := range tokens {
		result = append(result, models.TokenInfo{
			Address:  t.Address,
			Symbol:   t.Symbol,
			Name:     t.Name,
			Decimals: t.Decimals,
			Chain:    "SOL",
			LogoURI:  t.LogoURI,
		})
	}
	return result, nil
}

// getTokensForChain 获取代币列表：优先外部 Token List，fallback 到内置精选
func getTokensForChain(ctx context.Context, chain string) []models.TokenInfo {
	// 检查缓存
	tokenCacheMu.RLock()
	if tokens, ok := tokenCache[chain]; ok {
		if time.Since(tokenCacheTime[chain]) < cacheTTL {
			tokenCacheMu.RUnlock()
			return tokens
		}
	}
	tokenCacheMu.RUnlock()

	// 尝试拉取外部 Token List
	var (
		tokens []models.TokenInfo
		err    error
	)
	if chain == "SOL" {
		tokens, err = fetchJupiterTokenList(ctx)
	} else {
		tokens, err = fetchUniswapTokenList(ctx, chain)
	}

	if err != nil || len(tokens) == 0 {
		// fallback：使用内置精选列表
		tokens = popularTokens[chain]
	}

	// 写入缓存
	if len(tokens) > 0 {
		tokenCacheMu.Lock()
		tokenCache[chain] = tokens
		tokenCacheTime[chain] = time.Now()
		tokenCacheMu.Unlock()
	}

	return tokens
}

// ─── HTTP Handler ─────────────────────────────────────────────────────────────

// GetTokens 处理 GET /v1/dex/tokens?chain=ETH&q=usdc
//
// - chain: 链标识（ETH / BSC / POLYGON / ARB / OP / SOL）
// - q: 可选搜索词（symbol / name / address 模糊匹配）
func GetTokens(c *gin.Context) {
	chain := strings.ToUpper(c.Query("chain"))
	if chain == "" {
		c.JSON(http.StatusBadRequest, models.Fail("chain param required"))
		return
	}

	tokens := getTokensForChain(c.Request.Context(), chain)
	if len(tokens) == 0 {
		c.JSON(http.StatusOK, models.OK([]models.TokenInfo{}))
		return
	}

	// 可选搜索过滤
	q := strings.ToLower(c.Query("q"))
	if q != "" {
		var filtered []models.TokenInfo
		for _, t := range tokens {
			if strings.Contains(strings.ToLower(t.Symbol), q) ||
				strings.Contains(strings.ToLower(t.Name), q) ||
				strings.EqualFold(t.Address, q) {
				filtered = append(filtered, t)
			}
		}
		tokens = filtered
	}

	c.JSON(http.StatusOK, models.OK(tokens))
}
