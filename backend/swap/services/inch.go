package services

import (
	"context"
	"encoding/json"
	"fmt"
	"math/big"
	"net/http"
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

	url := fmt.Sprintf(
		"%s/%d/swap?src=%s&dst=%s&amount=%s&from=%s&slippage=%.2f&disableEstimate=true",
		inchBase, chainID,
		req.TokenIn, req.TokenOut,
		req.AmountIn,
		req.UserAddr,
		float64(req.SlippageBps)/100.0,
	)

	httpReq, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
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
		ToAmount string `json:"toAmount"`
		Tx       struct {
			Data string `json:"data"`
			To   string `json:"to"`
		} `json:"tx"`
	}
	if err = json.NewDecoder(resp.Body).Decode(&body); err != nil {
		return nil, fmt.Errorf("1inch: decode: %w", err)
	}
	if body.Tx.Data == "" {
		return nil, fmt.Errorf("1inch: empty calldata")
	}

	amountOut, ok := new(big.Int).SetString(body.ToAmount, 10)
	if !ok {
		return nil, fmt.Errorf("1inch: invalid toAmount: %q", body.ToAmount)
	}

	return &models.QuoteResp{
		Source:       "1inch",
		AmountOutWei: amountOut,
		AmountOut:    weiToHuman(amountOut, 18),
		Calldata:     body.Tx.Data,
		RouterAddr:   body.Tx.To,
		Chain:        req.Chain,
	}, nil
}
