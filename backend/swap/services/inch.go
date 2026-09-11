package services

import (
	"context"
	"encoding/json"
	"fmt"
	"math/big"
	"net/http"
	"net/url"
	"strings"
	"time"

	"github.com/n42/n42appv2/backend/swap/models"
)

const inchBase = "https://api.1inch.dev/swap/v6.0"

// chainIDMap 链名 → 1inch chainId
var chainIDMap = map[string]int{
	"ETH":     1,
	"BSC":     56,
	"POLYGON": 137,
	"ARB":     42161,
	"OP":      10,
}

// InchAdapter 调用 1inch Aggregation Protocol v6 REST
type InchAdapter struct {
	apiKey string
	client *http.Client
}

// NewInchAdapter 创建 1inch 适配器
func NewInchAdapter(apiKey string) *InchAdapter {
	return &InchAdapter{
		apiKey: apiKey,
		client: &http.Client{Timeout: 10 * time.Second},
	}
}

func (a *InchAdapter) SupportedChains() []string {
	chains := make([]string, 0, len(chainIDMap))
	for c := range chainIDMap {
		chains = append(chains, c)
	}
	return chains
}

func (a *InchAdapter) Quote(
	ctx context.Context,
	req models.QuoteReq,
) (*models.QuoteResp, error) {
	chainID, ok := chainIDMap[req.Chain]
	if !ok {
		return nil, fmt.Errorf("1inch: unsupported chain %s", req.Chain)
	}

	params := url.Values{}
	src := req.TokenIn
	if strings.EqualFold(src, "0x0000000000000000000000000000000000000000") {
		src = "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"
	}
	params.Set("src", src)
	dst := req.TokenOut
	if strings.EqualFold(dst, "0x0000000000000000000000000000000000000000") {
		dst = "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"
	}
	params.Set("dst", dst)
	params.Set("amount", req.AmountIn)
	params.Set("from", req.UserAddr)
	params.Set("receiver", req.UserAddr)
	params.Set("slippage", fmt.Sprintf("%.2f", float64(req.SlippageBps)/100.0))
	params.Set("disableEstimate", "true")
	params.Set("includeTokensInfo", "true")
	endpoint := fmt.Sprintf("%s/%d/swap?%s", inchBase, chainID, params.Encode())

	httpReq, err := http.NewRequestWithContext(ctx, http.MethodGet, endpoint, nil)
	if err != nil {
		return nil, fmt.Errorf("1inch: new request: %w", err)
	}
	httpReq.Header.Set("Authorization", "Bearer "+a.apiKey)
	httpReq.Header.Set("Accept", "application/json")

	resp, err := a.client.Do(httpReq)
	if err != nil {
		return nil, fmt.Errorf("1inch: http: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("1inch: status %d", resp.StatusCode)
	}

	var body struct {
		DstAmount string `json:"dstAmount"`
		SrcToken  struct {
			Symbol string `json:"symbol"`
		} `json:"srcToken"`
		DstToken struct {
			Symbol   string `json:"symbol"`
			Decimals *int   `json:"decimals"`
		} `json:"dstToken"`
		Tx struct {
			Value string `json:"value"`
			Data  string `json:"data"`
			To    string `json:"to"`
		} `json:"tx"`
	}
	if err = json.NewDecoder(resp.Body).Decode(&body); err != nil {
		return nil, fmt.Errorf("1inch: decode: %w", err)
	}
	if body.Tx.Data == "" {
		return nil, fmt.Errorf("1inch: empty calldata")
	}

	amountOut, ok := new(big.Int).SetString(body.DstAmount, 10)
	if !ok || amountOut.Sign() <= 0 {
		return nil, fmt.Errorf("1inch: invalid dstAmount: %q", body.DstAmount)
	}

	if body.DstToken.Decimals == nil || *body.DstToken.Decimals < 0 || *body.DstToken.Decimals > 255 {
		return nil, fmt.Errorf("1inch: missing or invalid output token decimals")
	}
	value, valid := new(big.Int).SetString(body.Tx.Value, 10)
	if !valid || value.Sign() < 0 || value.BitLen() > 256 {
		return nil, fmt.Errorf("1inch: invalid transaction value")
	}
	expected := new(big.Int)
	if strings.EqualFold(src, "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee") {
		if _, valid = expected.SetString(req.AmountIn, 10); !valid || expected.Sign() <= 0 {
			return nil, fmt.Errorf("1inch: invalid native input")
		}
	}
	if value.Cmp(expected) != 0 {
		return nil, fmt.Errorf("1inch: transaction value does not match input")
	}
	return &models.QuoteResp{
		TxValue:        value.String(),
		Source:         "1inch",
		TokenInSymbol:  body.SrcToken.Symbol,
		TokenOutSymbol: body.DstToken.Symbol,
		AmountOutWei:   amountOut,
		AmountOut:      weiToHuman(amountOut, *body.DstToken.Decimals),
		Calldata:       body.Tx.Data,
		RouterAddr:     body.Tx.To,
		Chain:          req.Chain,
	}, nil
}
