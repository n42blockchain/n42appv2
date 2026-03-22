package models

import (
	"context"
	"math/big"
)

// ─── 请求 / 响应结构体 ───────────────────────────────────────────────

// QuoteReq 报价请求
type QuoteReq struct {
	Chain       string   `json:"chain"`
	TokenIn     string   `json:"token_in"`
	TokenOut    string   `json:"token_out"`
	AmountIn    string   `json:"amount_in"`    // 最小单位（wei / lamport）
	UserAddr    string   `json:"user_addr"`
	SlippageBps int      `json:"slippage_bps"` // 0.5% = 50

	// 解析后的大整数，不序列化
	AmountInWei *big.Int `json:"-"`
}

// QuoteResp 报价响应（最优来源）
type QuoteResp struct {
	OrderID      string   `json:"order_id"`
	AmountOut    string   `json:"amount_out"`    // 人类可读
	AmountOutWei *big.Int `json:"-"`
	PriceImpact  string   `json:"price_impact"`  // "0.12%"
	GasEstimate  string   `json:"gas_estimate"`  // "0.003 ETH"
	Source       string   `json:"source"`        // "Uniswap V3" / "1inch" / "Jupiter"
	Calldata     string   `json:"calldata"`
	RouterAddr   string   `json:"router_addr"`
	Chain        string   `json:"chain"`

	// 内部字段
	TokenInSymbol  string `json:"token_in_symbol"`
	TokenOutSymbol string `json:"token_out_symbol"`
}

// CommitReq 提交 txHash 请求
type CommitReq struct {
	UUID    string `json:"uuid"`
	OrderID string `json:"order_id"`
	TxHash  string `json:"tx_hash"`
}

// HistoryItem 历史记录条目
type HistoryItem struct {
	OrderID        string  `json:"order_id"`
	Chain          string  `json:"chain"`
	TokenInSymbol  string  `json:"token_in_symbol"`
	TokenOutSymbol string  `json:"token_out_symbol"`
	AmountIn       string  `json:"amount_in"`
	AmountOut      string  `json:"amount_out"`
	Source         string  `json:"source"`
	TxHash         string  `json:"tx_hash"`
	Status         int     `json:"status"` // 0=quoted 1=committed 2=confirmed 3=failed
	CreatedAt      int64   `json:"created_at"`
}

// TokenInfo 代币信息
type TokenInfo struct {
	Address  string `json:"address"`
	Symbol   string `json:"symbol"`
	Name     string `json:"name"`
	LogoURI  string `json:"logo_uri"`
	Decimals int    `json:"decimals"`
	Chain    string `json:"chain"`
}

// ─── 聚合器接口 ───────────────────────────────────────────────────────

// Adapter DEX 适配器接口
type Adapter interface {
	SupportedChains() []string
	Quote(ctx context.Context, req QuoteReq) (*QuoteResp, error)
}

// ─── 订单状态常量 ─────────────────────────────────────────────────────

const (
	StatusQuoted    = 0
	StatusCommitted = 1
	StatusConfirmed = 2
	StatusFailed    = 3
)

// ─── 通用 API 响应 ────────────────────────────────────────────────────

type APIResp struct {
	Code int         `json:"code"`
	Data any `json:"data,omitempty"`
	Err  string      `json:"err,omitempty"`
}

func OK(data any) APIResp {
	return APIResp{Code: 200, Data: data}
}

func Fail(msg string) APIResp {
	return APIResp{Code: 400, Err: msg}
}
