package models

import (
	"context"
	"math/big"
)

// ─── 请求 / 响应结构体 ───────────────────────────────────────────────

// QuoteReq 报价请求
type QuoteReq struct {
	Chain       string `json:"chain"`
	TokenIn     string `json:"token_in"`
	TokenOut    string `json:"token_out"`
	AmountIn    string `json:"amount_in"` // 最小单位（wei / lamport）
	UserAddr    string `json:"user_addr"`
	SlippageBps int    `json:"slippage_bps"` // 0.5% = 50

	// 解析后的大整数，不序列化
	AmountInWei *big.Int `json:"-"`
}

// QuoteResp 报价响应（最优来源）
type QuoteResp struct {
	TxValue      string   `json:"tx_value"`       // native transaction value in wei
	AmountOutRaw string   `json:"amount_out_raw"` // exact output in token base units
	OrderID      string   `json:"order_id"`
	AmountOut    string   `json:"amount_out"` // 人类可读
	AmountOutWei *big.Int `json:"-"`
	PriceImpact  string   `json:"price_impact"` // "0.12%"
	GasEstimate  string   `json:"gas_estimate"` // "0.003 ETH"
	Source       string   `json:"source"`       // "Uniswap V3" / "1inch" / "Jupiter"
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
	OrderID        string `json:"order_id"`
	Chain          string `json:"chain"`
	TokenInSymbol  string `json:"token_in_symbol"`
	TokenOutSymbol string `json:"token_out_symbol"`
	AmountIn       string `json:"amount_in"`
	AmountOut      string `json:"amount_out"`
	Source         string `json:"source"`
	TxHash         string `json:"tx_hash"`
	Status         int    `json:"status"` // 0=quoted 1=committed 2=confirmed 3=failed
	CreatedAt      int64  `json:"created_at"`
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

// ─── 限价单请求 / 响应 ─────────────────────────────────────────────────

// LimitOrderReq 创建限价单请求
type LimitOrderReq struct {
	UUID       string `json:"uuid"`
	Chain      string `json:"chain"`
	TokenIn    string `json:"token_in"`
	TokenOut   string `json:"token_out"`
	SymbolIn   string `json:"symbol_in"`
	SymbolOut  string `json:"symbol_out"`
	AmountIn   string `json:"amount_in"`   // 人类可读数量
	LimitPrice string `json:"limit_price"` // 触发价格（tokenOut per tokenIn）
	ExpiresIn  int64  `json:"expires_in"`  // 有效期（秒），如 86400 = 24h
}

// LimitOrderItem 限价单列表条目
type LimitOrderItem struct {
	OrderID    string `json:"order_id"`
	Chain      string `json:"chain"`
	SymbolIn   string `json:"symbol_in"`
	SymbolOut  string `json:"symbol_out"`
	AmountIn   string `json:"amount_in"`
	LimitPrice string `json:"limit_price"`
	ExpiresAt  int64  `json:"expires_at"`
	Status     int    `json:"status"` // 0=active 1=triggered 2=executed 3=cancelled 4=expired
	TxHash     string `json:"tx_hash"`
	CreatedAt  int64  `json:"created_at"`
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
	Code int    `json:"code"`
	Data any    `json:"data,omitempty"`
	Err  string `json:"err,omitempty"`
}

func OK(data any) APIResp {
	return APIResp{Code: 200, Data: data}
}

func Fail(msg string) APIResp {
	return APIResp{Code: 400, Err: msg}
}

// ─── 价格预警（docs/BACKEND_REQUIREMENTS.md §五）───────────────────────────────

// PriceAlertReq 创建/更新价格预警请求（POST /v1/l/alert/price/set）。
// AlertID 为空 = 创建；非空 = 更新（按 alert_id 幂等，重新武装 triggered）。
type PriceAlertReq struct {
	UUID        string `json:"uuid"`
	AlertID     string `json:"alert_id"`
	Symbol      string `json:"symbol"`
	CoinGeckoID string `json:"coin_gecko_id"`
	Direction   string `json:"direction"`    // "above" | "below"
	TargetPrice string `json:"target_price"` // 十进制字符串
	Enabled     bool   `json:"enabled"`
}

// PriceAlertRemoveReq 删除价格预警请求（DELETE /v1/l/alert/price/remove）
type PriceAlertRemoveReq struct {
	UUID    string `json:"uuid"`
	AlertID string `json:"alert_id"`
}

// PriceAlertItem 预警列表条目（GET /v1/l/alert/price/list）
type PriceAlertItem struct {
	AlertID      string `json:"alert_id"`
	Symbol       string `json:"symbol"`
	CoinGeckoID  string `json:"coin_gecko_id"`
	Direction    string `json:"direction"`
	TargetPrice  string `json:"target_price"`
	CurrentPrice string `json:"current_price,omitempty"` // 监控缓存价，可能为空
	Enabled      bool   `json:"enabled"`
	Triggered    bool   `json:"triggered"`
	TriggerPrice string `json:"trigger_price,omitempty"`
	TriggeredAt  int64  `json:"triggered_at,omitempty"`
	CreatedAt    int64  `json:"created_at"`
}
