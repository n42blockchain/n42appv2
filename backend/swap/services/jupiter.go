package services

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"math/big"
	"net/http"
	"time"

	"github.com/n42/n42appv2/backend/swap/models"
)

const jupBase = "https://quote-api.jup.ag/v6"

// JupiterAdapter 调用 Jupiter Quote API v6（Solana）
type JupiterAdapter struct {
	client *http.Client
}

// NewJupiterAdapter 创建 Jupiter 适配器
func NewJupiterAdapter() *JupiterAdapter {
	return &JupiterAdapter{
		client: &http.Client{Timeout: 10 * time.Second},
	}
}

func (j *JupiterAdapter) SupportedChains() []string {
	return []string{"SOL"}
}

func (j *JupiterAdapter) Quote(
	ctx context.Context,
	req models.QuoteReq,
) (*models.QuoteResp, error) {
	if req.Chain != "SOL" {
		return nil, fmt.Errorf("jupiter: only supports SOL, got %s", req.Chain)
	}

	// Step 1: GET /quote
	quoteURL := fmt.Sprintf(
		"%s/quote?inputMint=%s&outputMint=%s&amount=%s&slippageBps=%d",
		jupBase, req.TokenIn, req.TokenOut, req.AmountIn, req.SlippageBps,
	)
	quoteResp, err := j.fetchQuote(ctx, quoteURL)
	if err != nil {
		return nil, err
	}

	// Step 2: POST /swap → 获取序列化 transaction
	swapTx, err := j.fetchSwap(ctx, quoteResp, req.UserAddr)
	if err != nil {
		return nil, err
	}

	outAmt, ok := new(big.Int).SetString(quoteResp.OutAmount, 10)
	if !ok {
		outAmt = big.NewInt(0)
	}

	return &models.QuoteResp{
		Source:       "Jupiter",
		AmountOutWei: outAmt,
		AmountOut:    quoteResp.OutAmount,
		// Solana：calldata 为 base64 序列化 tx，客户端需特殊处理广播
		Calldata:   swapTx,
		RouterAddr: "", // Solana 无 router 合约地址概念
		Chain:      "SOL",
	}, nil
}

// jupQuoteResp Jupiter /quote 响应（仅关心需要的字段）
type jupQuoteResp struct {
	OutAmount          string      `json:"outAmount"`
	InputMint          string      `json:"inputMint"`
	OutputMint         string      `json:"outputMint"`
	InAmount           string      `json:"inAmount"`
	OtherAmountThreshold string   `json:"otherAmountThreshold"`
	SwapMode           string      `json:"swapMode"`
	SlippageBps        int         `json:"slippageBps"`
	RoutePlan          any         `json:"routePlan"`
}

func (j *JupiterAdapter) fetchQuote(
	ctx context.Context,
	url string,
) (*jupQuoteResp, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return nil, fmt.Errorf("jupiter quote: new request: %w", err)
	}

	resp, err := j.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("jupiter quote: http: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("jupiter quote: status %d", resp.StatusCode)
	}

	var qr jupQuoteResp
	if err = json.NewDecoder(resp.Body).Decode(&qr); err != nil {
		return nil, fmt.Errorf("jupiter quote: decode: %w", err)
	}
	if qr.OutAmount == "" {
		return nil, fmt.Errorf("jupiter quote: empty outAmount")
	}
	return &qr, nil
}

func (j *JupiterAdapter) fetchSwap(
	ctx context.Context,
	quoteResp *jupQuoteResp,
	userPublicKey string,
) (string, error) {
	body := map[string]any{
		"quoteResponse":            quoteResp,
		"userPublicKey":            userPublicKey,
		"wrapAndUnwrapSol":         true,
		"dynamicComputeUnitLimit":  true,
		"prioritizationFeeLamports": "auto",
	}
	bodyBytes, err := json.Marshal(body)
	if err != nil {
		return "", fmt.Errorf("jupiter swap: marshal: %w", err)
	}

	req, err := http.NewRequestWithContext(
		ctx, http.MethodPost, jupBase+"/swap",
		bytes.NewReader(bodyBytes))
	if err != nil {
		return "", fmt.Errorf("jupiter swap: new request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := j.client.Do(req)
	if err != nil {
		return "", fmt.Errorf("jupiter swap: http: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("jupiter swap: status %d", resp.StatusCode)
	}

	var swapResp struct {
		SwapTransaction string `json:"swapTransaction"`
	}
	if err = json.NewDecoder(resp.Body).Decode(&swapResp); err != nil {
		return "", fmt.Errorf("jupiter swap: decode: %w", err)
	}
	if swapResp.SwapTransaction == "" {
		return "", fmt.Errorf("jupiter swap: empty swapTransaction")
	}
	return swapResp.SwapTransaction, nil
}
