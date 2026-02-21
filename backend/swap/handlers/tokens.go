package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/n42/n42appv2/backend/swap/models"
)

// 内置代币列表（生产环境可接外部 token list API 或数据库）
var builtinTokens = map[string][]models.TokenInfo{
	"ETH": {
		{Address: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48", Symbol: "USDC", Name: "USD Coin", Decimals: 6, Chain: "ETH", LogoURI: "https://cryptologos.cc/logos/usd-coin-usdc-logo.png"},
		{Address: "0xdAC17F958D2ee523a2206206994597C13D831ec7", Symbol: "USDT", Name: "Tether USD", Decimals: 6, Chain: "ETH", LogoURI: "https://cryptologos.cc/logos/tether-usdt-logo.png"},
		{Address: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2", Symbol: "WETH", Name: "Wrapped Ether", Decimals: 18, Chain: "ETH", LogoURI: "https://cryptologos.cc/logos/ethereum-eth-logo.png"},
		{Address: "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599", Symbol: "WBTC", Name: "Wrapped Bitcoin", Decimals: 8, Chain: "ETH", LogoURI: "https://cryptologos.cc/logos/wrapped-bitcoin-wbtc-logo.png"},
		{Address: "0x6B175474E89094C44Da98b954EedeAC495271d0F", Symbol: "DAI", Name: "Dai Stablecoin", Decimals: 18, Chain: "ETH", LogoURI: "https://cryptologos.cc/logos/multi-collateral-dai-dai-logo.png"},
	},
	"BSC": {
		{Address: "0x55d398326f99059fF775485246999027B3197955", Symbol: "USDT", Name: "Tether USD (BSC)", Decimals: 18, Chain: "BSC", LogoURI: "https://cryptologos.cc/logos/tether-usdt-logo.png"},
		{Address: "0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d", Symbol: "USDC", Name: "USD Coin (BSC)", Decimals: 18, Chain: "BSC", LogoURI: "https://cryptologos.cc/logos/usd-coin-usdc-logo.png"},
		{Address: "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c", Symbol: "WBNB", Name: "Wrapped BNB", Decimals: 18, Chain: "BSC", LogoURI: "https://cryptologos.cc/logos/bnb-bnb-logo.png"},
	},
	"POLYGON": {
		{Address: "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174", Symbol: "USDC", Name: "USD Coin (PoS)", Decimals: 6, Chain: "POLYGON", LogoURI: "https://cryptologos.cc/logos/usd-coin-usdc-logo.png"},
		{Address: "0xc2132D05D31c914a87C6611C10748AEb04B58e8F", Symbol: "USDT", Name: "Tether USD (PoS)", Decimals: 6, Chain: "POLYGON", LogoURI: "https://cryptologos.cc/logos/tether-usdt-logo.png"},
		{Address: "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270", Symbol: "WMATIC", Name: "Wrapped Matic", Decimals: 18, Chain: "POLYGON", LogoURI: "https://cryptologos.cc/logos/polygon-matic-logo.png"},
	},
	"ARB": {
		{Address: "0xaf88d065e77c8cC2239327C5EDb3A432268e5831", Symbol: "USDC", Name: "USD Coin (Arbitrum)", Decimals: 6, Chain: "ARB", LogoURI: "https://cryptologos.cc/logos/usd-coin-usdc-logo.png"},
		{Address: "0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9", Symbol: "USDT", Name: "Tether USD (Arbitrum)", Decimals: 6, Chain: "ARB", LogoURI: "https://cryptologos.cc/logos/tether-usdt-logo.png"},
		{Address: "0x82aF49447D8a07e3bd95BD0d56f35241523fBab1", Symbol: "WETH", Name: "Wrapped Ether (Arbitrum)", Decimals: 18, Chain: "ARB", LogoURI: "https://cryptologos.cc/logos/ethereum-eth-logo.png"},
	},
	"OP": {
		{Address: "0x7F5c764cBc14f9669B88837ca1490cCa17c31607", Symbol: "USDC", Name: "USD Coin (Optimism)", Decimals: 6, Chain: "OP", LogoURI: "https://cryptologos.cc/logos/usd-coin-usdc-logo.png"},
		{Address: "0x4200000000000000000000000000000000000006", Symbol: "WETH", Name: "Wrapped Ether (Optimism)", Decimals: 18, Chain: "OP", LogoURI: "https://cryptologos.cc/logos/ethereum-eth-logo.png"},
	},
	"SOL": {
		{Address: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v", Symbol: "USDC", Name: "USD Coin (Solana)", Decimals: 6, Chain: "SOL", LogoURI: "https://cryptologos.cc/logos/usd-coin-usdc-logo.png"},
		{Address: "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB", Symbol: "USDT", Name: "Tether USD (Solana)", Decimals: 6, Chain: "SOL", LogoURI: "https://cryptologos.cc/logos/tether-usdt-logo.png"},
		{Address: "So11111111111111111111111111111111111111112", Symbol: "WSOL", Name: "Wrapped SOL", Decimals: 9, Chain: "SOL", LogoURI: "https://cryptologos.cc/logos/solana-sol-logo.png"},
	},
}

// GetTokens 处理 GET /v1/dex/tokens?chain=ETH
func GetTokens(c *gin.Context) {
	chain := c.Query("chain")
	if chain == "" {
		c.JSON(http.StatusBadRequest, models.Fail("chain param required"))
		return
	}

	tokens, ok := builtinTokens[chain]
	if !ok {
		// 未知链返回空列表，不报错
		c.JSON(http.StatusOK, models.OK([]models.TokenInfo{}))
		return
	}
	c.JSON(http.StatusOK, models.OK(tokens))
}
