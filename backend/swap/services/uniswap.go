package services

import (
	"context"
	"fmt"
	"math/big"
	"strings"

	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/ethclient"

	"github.com/n42/n42appv2/backend/swap/models"
)

// QuoterV2 合约地址（各链相同 — Uniswap V3 部署地址统一）
var quoterV2Addresses = map[string]string{
	"ETH":     "0x61fFE014bA17989E743c5F6cB21bF9697530B21e",
	"POLYGON": "0x61fFE014bA17989E743c5F6cB21bF9697530B21e",
	"ARB":     "0x61fFE014bA17989E743c5F6cB21bF9697530B21e",
	"OP":      "0x61fFE014bA17989E743c5F6cB21bF9697530B21e",
}

// SwapRouter02 地址
var swapRouterAddresses = map[string]string{
	"ETH":     "0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45",
	"POLYGON": "0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45",
	"ARB":     "0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45",
	"OP":      "0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45",
}

// UniswapAdapter 调用 Uniswap V3 QuoterV2 的适配器
type UniswapAdapter struct {
	rpcURLs map[string]string // chain → RPC URL
}

// NewUniswapAdapter 创建 Uniswap 适配器
func NewUniswapAdapter(rpcURLs map[string]string) *UniswapAdapter {
	return &UniswapAdapter{rpcURLs: rpcURLs}
}

func (u *UniswapAdapter) SupportedChains() []string {
	chains := make([]string, 0, len(quoterV2Addresses))
	for c := range quoterV2Addresses {
		chains = append(chains, c)
	}
	return chains
}

func (u *UniswapAdapter) Quote(
	ctx context.Context,
	req models.QuoteReq,
) (*models.QuoteResp, error) {
	rpcURL, ok := u.rpcURLs[req.Chain]
	if !ok {
		return nil, fmt.Errorf("uniswap: unsupported chain %s", req.Chain)
	}
	quoterAddr, ok := quoterV2Addresses[req.Chain]
	if !ok {
		return nil, fmt.Errorf("uniswap: no quoter for chain %s", req.Chain)
	}
	routerAddr, ok := swapRouterAddresses[req.Chain]
	if !ok {
		return nil, fmt.Errorf("uniswap: no router for chain %s", req.Chain)
	}

	client, err := ethclient.DialContext(ctx, rpcURL)
	if err != nil {
		return nil, fmt.Errorf("uniswap: dial %s: %w", rpcURL, err)
	}
	defer client.Close()

	amountOut, err := u.callQuoterV2(
		ctx, client,
		common.HexToAddress(quoterAddr),
		common.HexToAddress(req.TokenIn),
		common.HexToAddress(req.TokenOut),
		req.AmountInWei,
		3000, // 默认 0.3% pool，失败时可 fallback 到 500/10000
	)
	if err != nil {
		// fallback：尝试 0.05% pool
		amountOut, err = u.callQuoterV2(
			ctx, client,
			common.HexToAddress(quoterAddr),
			common.HexToAddress(req.TokenIn),
			common.HexToAddress(req.TokenOut),
			req.AmountInWei,
			500,
		)
		if err != nil {
			return nil, fmt.Errorf("uniswap: quote: %w", err)
		}
	}

	calldata, err := u.buildSwapCalldata(req, amountOut)
	if err != nil {
		return nil, fmt.Errorf("uniswap: build calldata: %w", err)
	}

	return &models.QuoteResp{
		Source:       "Uniswap V3",
		AmountOutWei: amountOut,
		AmountOut:    weiToHuman(amountOut, 18), // 调用者可按实际 decimals 覆盖
		Calldata:     fmt.Sprintf("0x%x", calldata),
		RouterAddr:   routerAddr,
		Chain:        req.Chain,
	}, nil
}

// callQuoterV2 调用 QuoterV2.quoteExactInputSingle
func (u *UniswapAdapter) callQuoterV2(
	ctx context.Context,
	client *ethclient.Client,
	quoterAddr,
	tokenIn,
	tokenOut common.Address,
	amountIn *big.Int,
	fee int64,
) (*big.Int, error) {
	const abiJSON = `[{
		"inputs":[{
			"components":[
				{"name":"tokenIn","type":"address"},
				{"name":"tokenOut","type":"address"},
				{"name":"amountIn","type":"uint256"},
				{"name":"fee","type":"uint24"},
				{"name":"sqrtPriceLimitX96","type":"uint160"}
			],
			"name":"params","type":"tuple"
		}],
		"name":"quoteExactInputSingle",
		"outputs":[
			{"name":"amountOut","type":"uint256"},
			{"name":"sqrtPriceX96After","type":"uint160"},
			{"name":"initializedTicksCrossed","type":"uint32"},
			{"name":"gasEstimate","type":"uint256"}
		],
		"stateMutability":"nonpayable","type":"function"
	}]`

	parsedABI, err := abi.JSON(strings.NewReader(abiJSON))
	if err != nil {
		return nil, err
	}

	type Params struct {
		TokenIn           common.Address
		TokenOut          common.Address
		AmountIn          *big.Int
		Fee               *big.Int
		SqrtPriceLimitX96 *big.Int
	}
	params := Params{
		TokenIn:           tokenIn,
		TokenOut:          tokenOut,
		AmountIn:          amountIn,
		Fee:               big.NewInt(fee),
		SqrtPriceLimitX96: big.NewInt(0),
	}

	callData, err := parsedABI.Pack("quoteExactInputSingle", params)
	if err != nil {
		return nil, fmt.Errorf("pack: %w", err)
	}

	contract := bind.NewBoundContract(
		quoterAddr, parsedABI, client, client, client)
	var results []interface{}
	if err = contract.Call(&bind.CallOpts{Context: ctx}, &results,
		"quoteExactInputSingle", params); err != nil {
		_ = callData
		return nil, fmt.Errorf("call: %w", err)
	}
	if len(results) == 0 {
		return nil, fmt.Errorf("empty results from quoter")
	}
	amountOut, ok := results[0].(*big.Int)
	if !ok {
		return nil, fmt.Errorf("unexpected result type %T", results[0])
	}
	return amountOut, nil
}

// buildSwapCalldata 构造 SwapRouter02.exactInputSingle calldata
func (u *UniswapAdapter) buildSwapCalldata(
	req models.QuoteReq,
	amountOut *big.Int,
) ([]byte, error) {
	const routerABI = `[{
		"inputs":[{
			"components":[
				{"name":"tokenIn","type":"address"},
				{"name":"tokenOut","type":"address"},
				{"name":"fee","type":"uint24"},
				{"name":"recipient","type":"address"},
				{"name":"amountIn","type":"uint256"},
				{"name":"amountOutMinimum","type":"uint256"},
				{"name":"sqrtPriceLimitX96","type":"uint160"}
			],
			"name":"params","type":"tuple"
		}],
		"name":"exactInputSingle",
		"outputs":[{"name":"amountOut","type":"uint256"}],
		"stateMutability":"payable","type":"function"
	}]`

	parsedABI, err := abi.JSON(strings.NewReader(routerABI))
	if err != nil {
		return nil, err
	}

	// amountOutMinimum = amountOut * (10000 - slippageBps) / 10000
	slippage := int64(req.SlippageBps)
	minOut := new(big.Int).Mul(amountOut, big.NewInt(10000-slippage))
	minOut.Div(minOut, big.NewInt(10000))

	type ExactInputSingleParams struct {
		TokenIn           common.Address
		TokenOut          common.Address
		Fee               *big.Int
		Recipient         common.Address
		AmountIn          *big.Int
		AmountOutMinimum  *big.Int
		SqrtPriceLimitX96 *big.Int
	}
	params := ExactInputSingleParams{
		TokenIn:           common.HexToAddress(req.TokenIn),
		TokenOut:          common.HexToAddress(req.TokenOut),
		Fee:               big.NewInt(3000),
		Recipient:         common.HexToAddress(req.UserAddr),
		AmountIn:          req.AmountInWei,
		AmountOutMinimum:  minOut,
		SqrtPriceLimitX96: big.NewInt(0),
	}

	return parsedABI.Pack("exactInputSingle", params)
}
